import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/repositories/meeting_repository.dart';
import 'package:live_ffss_v2/data/repositories/result_repository.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/lane_assignment.dart';
import 'package:live_ffss_v2/domain/manual_timing.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/race_result.dart';
import 'package:live_ffss_v2/features/auth/competition_roles.dart';
import 'package:live_ffss_v2/features/auth/session.dart';
import 'package:live_ffss_v2/features/common/serial_refresh.dart';
import 'package:live_ffss_v2/features/officiel/entry_view.dart';
import 'package:live_ffss_v2/features/officiel/outbox_service.dart';
import 'package:live_ffss_v2/features/programme/item_detail_refresh.dart';
import 'package:live_ffss_v2/features/programme/programme_providers.dart';

part 'entry_providers.freezed.dart';

/// L'écran de saisie relit sa série à ce rythme : un `temps` posé par le juge
/// la passe en lecture seule.
const Duration entryRefresh = Duration(seconds: 30);

/// L'écran de saisie ouvert depuis un créneau, sur une série s'il y en a une.
typedef EntryKey = ({int competitionId, int itemId, int? heatId});

typedef EntryHeatKey = ({int competitionId, int heatId});

enum EntryAccess { checking, allowed, denied }

/// La saisie ne s'ouvre qu'aux rôles qui le permettent, établis pour la
/// session en cours ; pendant leur lecture, l'écran attend.
final entryAccessProvider = Provider.autoDispose.family<EntryAccess, int>((
  ref,
  competitionId,
) {
  final roles = ref.watch(competitionRolesProvider(competitionId));
  if (roles.isLoading) return EntryAccess.checking;
  return ref.watch(canEnterProvider(competitionId))
      ? EntryAccess.allowed
      : EntryAccess.denied;
});

/// Le couloir suivi (nul : « Tous »), gardé sur l'appareil par compétition :
/// un officiel tient le même couloir toute la réunion, d'une série et d'un
/// lancement à l'autre.
class EntryLaneFilterNotifier extends AsyncNotifier<int?> {
  EntryLaneFilterNotifier(this.competitionId);

  final int competitionId;

  static String storageKey(int competitionId) =>
      'entry_lane_filter_$competitionId';

  /// Une valeur illisible vaut « Tous ».
  @override
  Future<int?> build() async => int.tryParse(
    await ref.watch(localStoreProvider).read(storageKey(competitionId)) ?? '',
  );

  Future<void> select(int? lane) async {
    state = AsyncData(lane);
    final store = ref.read(localStoreProvider);
    final key = storageKey(competitionId);
    await (lane == null ? store.delete(key) : store.write(key, '$lane'));
  }
}

final entryLaneFilterProvider = AsyncNotifierProvider.autoDispose
    .family<EntryLaneFilterNotifier, int?, int>(EntryLaneFilterNotifier.new);

/// La série ouverte et ses voisines, d'après le programme (relu toutes les
/// 30 s, sans perdre la série choisie).
class EntryNavigator extends Notifier<AsyncValue<EntryCursor?>> {
  EntryNavigator(this.key);

  final EntryKey key;

  // Dans un champ, pas seulement dans `state` : chaque relecture du
  // programme reconstruit ce notifier.
  int? _heatId;

  @override
  AsyncValue<EntryCursor?> build() =>
      _cursor(ref.watch(programmeProvider(key.competitionId)));

  AsyncValue<EntryCursor?> _cursor(AsyncValue<Programme> programme) =>
      programme.whenData(
        (p) => entryCursor(
          p.meetings,
          itemId: key.itemId,
          heatId: _heatId ?? key.heatId,
        ),
      );

  /// Faux s'il n'y a pas de série avant.
  bool previous() => _moveTo(state.value?.previous?.heat.id);

  /// Faux s'il n'y a pas de série après.
  bool next() => _moveTo(state.value?.next?.heat.id);

  bool _moveTo(int? heatId) {
    if (heatId == null) return false;
    _heatId = heatId;
    state = _cursor(ref.read(programmeProvider(key.competitionId)));
    return true;
  }
}

final entryNavigatorProvider = NotifierProvider.autoDispose
    .family<EntryNavigator, AsyncValue<EntryCursor?>, EntryKey>(
      EntryNavigator.new,
    );

/// Une série lue pour la saisie : ses places et ses résultats.
@freezed
abstract class EntryHeatData with _$EntryHeatData {
  const EntryHeatData._();

  const factory EntryHeatData({
    required Heat heat,

    /// Par id de place, comme dans le détail d'un créneau.
    @Default(<int, LaneAssignment?>{}) Map<int, LaneAssignment?> lanes,

    /// Par id d'engagement.
    @Default(<int, RaceResult>{}) Map<int, RaceResult> results,

    /// Quand la lecture a commencé : une saisie envoyée depuis n'y est pas.
    required DateTime readAt,
  }) = _EntryHeatData;

  List<LaneAssignment> get occupied => lanesOfHeat(heat, lanes);
}

class EntryHeatNotifier extends AsyncNotifier<EntryHeatData>
    with SerialRefresh<EntryHeatData> {
  EntryHeatNotifier(this.key);

  final EntryHeatKey key;

  @override
  Future<EntryHeatData> build() async {
    final timer = Timer.periodic(entryRefresh, (_) => tick());
    ref.onDispose(timer.cancel);
    final competitionId = key.competitionId;
    // Le navigateur l'écoute déjà ; l'écoute à vide le garde en vie si la
    // série est lue avant lui.
    ref.listen(programmeProvider(competitionId), (_, _) {});
    // Lus avant toute attente : si l'écran se ferme pendant une requête,
    // `ref` ne peut plus servir.
    final read = _reader();
    final Programme programme =
        ref.read(programmeProvider(competitionId)).value ??
        await ref.read(programmeProvider(competitionId).future);
    final heat = _findHeat(programme);
    if (heat == null) throw NotFoundException('heat ${key.heatId}');
    return read(heat, const {});
  }

  @override
  Future<void> reloadAll() => _reload();

  @override
  Future<void> reloadIncremental() => _reload();

  @override
  void beforeReloadFromScratch() {
    final programme = ref.read(programmeProvider(key.competitionId));
    if (programme.hasError || !programme.hasValue) {
      ref.invalidate(programmeProvider(key.competitionId));
    }
  }

  Future<void> _reload() async {
    final current = state.value;
    if (current == null) return;
    final runRef = ref;
    final programme = ref.read(programmeProvider(key.competitionId)).value;
    // Les places d'une série peuvent changer quand le bureau la recompose.
    final heat =
        (programme == null ? null : _findHeat(programme)) ?? current.heat;
    try {
      final next = await _reader()(heat, current.lanes);
      if (!runRef.mounted) return;
      state = AsyncData(next);
    } on AppException catch (error, stackTrace) {
      if (!runRef.mounted) return;
      state = AsyncError(error, stackTrace);
    }
  }

  Heat? _findHeat(Programme programme) {
    for (final meeting in programme.meetings) {
      for (final item in meeting.items) {
        for (final heat in item.heats) {
          if (heat.id == key.heatId && canEnterHeat(heat)) return heat;
        }
      }
    }
    return null;
  }

  /// La lecture d'une série, avec ce qu'elle prend de `ref` pris tout de
  /// suite.
  Future<EntryHeatData> Function(Heat, Map<int, LaneAssignment?>) _reader() {
    final clock = ref.read(clockProvider);
    final meetings = ref.read(meetingRepositoryProvider);
    final results = ref.read(resultRepositoryProvider);
    return (heat, previous) async {
      final readAt = clock();
      // Ensemble : la saisie attend les deux.
      final pendingLanes = meetings.getLanes(heat.placeIds);
      final Map<int, RaceResult> read;
      try {
        read = await results.getHeatResults(heat.seriesId!);
      } on AppException {
        pendingLanes.ignore();
        rethrow;
      }
      final lanes = await pendingLanes;
      return EntryHeatData(
        heat: heat,
        lanes: mergeLanes(previous, lanes, heat.placeIds),
        results: read,
        readAt: readAt,
      );
    };
  }
}

final entryHeatProvider = AsyncNotifierProvider.autoDispose
    .family<EntryHeatNotifier, EntryHeatData, EntryHeatKey>(
      EntryHeatNotifier.new,
    );

/// Les couloirs de la série, avec les saisies du compte connecté par-dessus.
final entryLanesProvider = Provider.autoDispose
    .family<AsyncValue<List<EntryLane>>, EntryHeatKey>((ref, key) {
      final data = ref.watch(entryHeatProvider(key));
      final queue = ref.watch(outboxProvider);
      final account = ref.watch(sessionProvider).value?.label;
      return data.whenData(
        (d) => entryLanes(
          heat: d.heat,
          lanes: d.occupied,
          results: d.results,
          queue: queue,
          account: account,
          readAt: d.readAt,
        ),
      );
    });

/// Ce que l'écran de saisie a de propre à l'officiel : le couloir ouvert
/// depuis la liste, les chiffres tapés et pas encore enregistrés, le champ
/// actif du pavé.
@freezed
abstract class EntryEditorState with _$EntryEditorState {
  const factory EntryEditorState({
    int? openPlaceId,

    /// Par id de place : les trois champs, en chiffres tapés au pavé.
    @Default(<int, List<String>>{}) Map<int, List<String>> drafts,
    @Default(0) int field,

    /// Le champ vient d'être choisi : le prochain chiffre le remplace.
    @Default(true) bool replaceNext,
  }) = _EntryEditorState;
}

enum EntrySaveOutcome {
  /// En file : partira dès que possible.
  saved,

  /// Rien de changé : rien à mettre en file.
  unchanged,

  /// En file, mais pas enregistrée sur l'appareil : elle ne tient qu'en
  /// mémoire, et l'écran doit le dire.
  notPersisted,

  /// Un chrono invalide, ou une DQ sans code : rien ne part.
  invalid,

  /// Personne n'est connecté : rien ne part.
  notConnected,

  /// Validé par le juge, ou sans engagement : rien ne part.
  readOnly,
}

/// Une saisie mise en file ne bloque pas l'enchaînement, même si elle n'a pu
/// être enregistrée sur l'appareil : elle partira quand même. Un couloir en
/// lecture seule n'avait rien à enregistrer.
bool _letsMoveOn(EntrySaveOutcome outcome) => switch (outcome) {
  EntrySaveOutcome.saved ||
  EntrySaveOutcome.unchanged ||
  EntrySaveOutcome.notPersisted ||
  EntrySaveOutcome.readOnly => true,
  EntrySaveOutcome.invalid || EntrySaveOutcome.notConnected => false,
};

class EntryEditor extends Notifier<EntryEditorState> {
  EntryEditor(this.key);

  final EntryKey key;

  @override
  EntryEditorState build() => const EntryEditorState();

  void openLane(int placeId) =>
      state = state.copyWith(openPlaceId: placeId, field: 0, replaceNext: true);

  void closeLane() => state = state.copyWith(openPlaceId: null);

  void selectField(int field) =>
      state = state.copyWith(field: field, replaceNext: true);

  void typeDigit(EntryLane lane, String digit) =>
      _edit(lane, (d) => typeChronoDigit(d, digit, replace: state.replaceNext));

  void eraseDigit(EntryLane lane) => _edit(lane, eraseChronoDigit);

  /// Vider un chrono est une correction comme une autre.
  void clearField(EntryLane lane) => _edit(lane, (_) => '');

  void _edit(EntryLane lane, String Function(String) change) {
    if (!lane.editable) return;
    final id = lane.lane.id;
    final digits = [...laneDigits(lane, state.drafts[id])];
    digits[state.field] = change(digits[state.field]);
    state = state.copyWith(
      drafts: {...state.drafts, id: digits},
      replaceNext: false,
    );
  }

  /// Met en file les chronos tapés pour [lane]. Ne rend la main qu'une fois
  /// la file enregistrée sur l'appareil, jamais après le réseau.
  Future<EntrySaveOutcome> saveChronos(EntryLane lane) async {
    if (!lane.editable) return EntrySaveOutcome.readOnly;
    final id = lane.lane.id;
    final draft = state.drafts[id];
    if (!hasUnsavedDraft(lane, draft)) {
      _dropDraft(id, draft);
      return EntrySaveOutcome.unchanged;
    }
    final chronos = draftChronos(draft!);
    if (chronos == null) return EntrySaveOutcome.invalid;
    final runRef = ref;
    final outcome = await _enqueue(lane, ResultChange(chronos: chronos));
    // La saisie est en file et s'affiche par-dessus le site : ses chiffres
    // tapés ne servent plus, sauf si l'officiel a continué à taper.
    if (runRef.mounted && _letsMoveOn(outcome)) _dropDraft(id, draft);
    return outcome;
  }

  /// Enregistre le couloir en grand, puis passe à la série suivante, le même
  /// couloir suivi. [moved] faux : pas de série après, ou rien n'a pu partir.
  Future<({EntrySaveOutcome outcome, bool moved})> saveAndNext(
    EntryLane? lane,
  ) async {
    final runRef = ref;
    final outcome = lane == null
        ? EntrySaveOutcome.unchanged
        : await saveChronos(lane);
    if (!runRef.mounted || !_letsMoveOn(outcome)) {
      return (outcome: outcome, moved: false);
    }
    return (outcome: outcome, moved: nextHeat());
  }

  /// Enregistre le couloir ouvert depuis « Tous », puis revient à la liste.
  Future<EntrySaveOutcome> saveAndClose(EntryLane lane) async {
    final runRef = ref;
    final outcome = await saveChronos(lane);
    if (runRef.mounted && _letsMoveOn(outcome)) closeLane();
    return outcome;
  }

  /// [code] est libre (aucune liste n'est publiée), mais pas vide.
  Future<EntrySaveOutcome> disqualify(EntryLane lane, String code) {
    final trimmed = code.trim();
    if (trimmed.isEmpty) return Future.value(EntrySaveOutcome.invalid);
    return _mark(
      lane,
      ResultChange(mark: ResultMark.disqualified, code: trimmed),
    );
  }

  Future<EntrySaveOutcome> forfeit(EntryLane lane) =>
      _mark(lane, const ResultChange(mark: ResultMark.forfeit));

  /// « Annuler la DQ » comme « Annuler le forfait » : retour au statut OK.
  Future<EntrySaveOutcome> cancelMark(EntryLane lane) =>
      _mark(lane, const ResultChange(mark: ResultMark.ok));

  Future<EntrySaveOutcome> _mark(EntryLane lane, ResultChange change) async {
    if (!lane.editable) return EntrySaveOutcome.readOnly;
    return _enqueue(lane, change);
  }

  bool previousHeat() =>
      _move(ref.read(entryNavigatorProvider(key).notifier).previous);

  bool nextHeat() => _move(ref.read(entryNavigatorProvider(key).notifier).next);

  /// Une autre série : son premier chrono attend le premier chiffre.
  bool _move(bool Function() move) {
    final moved = move();
    if (moved) {
      state = state.copyWith(openPlaceId: null, field: 0, replaceNext: true);
    }
    return moved;
  }

  Future<EntrySaveOutcome> _enqueue(EntryLane lane, ResultChange change) async {
    final entryId = lane.lane.entryId;
    if (entryId == null) return EntrySaveOutcome.readOnly;
    try {
      await ref
          .read(outboxProvider.notifier)
          .add(
            competitionId: key.competitionId,
            placeId: lane.lane.id,
            seriesId: lane.result.seriesId,
            entryId: entryId,
            resultId: lane.lane.resultId ?? lane.result.id,
            change: change,
          );
    } on AuthException {
      return EntrySaveOutcome.notConnected;
    } on AppException {
      return EntrySaveOutcome.notPersisted;
    }
    return EntrySaveOutcome.saved;
  }

  void _dropDraft(int placeId, List<String>? draft) {
    if (draft == null || !identical(state.drafts[placeId], draft)) return;
    state = state.copyWith(drafts: {...state.drafts}..remove(placeId));
  }
}

final entryEditorProvider = NotifierProvider.autoDispose
    .family<EntryEditor, EntryEditorState, EntryKey>(EntryEditor.new);

/// Le temps manuel des champs affichés, recalculé à chaque chiffre.
({int hundredths, ManualTimeRule rule})? draftManualTime(List<String> digits) =>
    manualTime([for (final d in digits) chronoValue(d)]);
