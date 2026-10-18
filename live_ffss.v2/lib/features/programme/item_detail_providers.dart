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
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/progression.dart';
import 'package:live_ffss_v2/domain/run_status.dart';
import 'package:live_ffss_v2/features/auth/competition_roles.dart';
import 'package:live_ffss_v2/features/common/serial_refresh.dart';
import 'package:live_ffss_v2/features/programme/item_detail_refresh.dart';
import 'package:live_ffss_v2/features/programme/programme_providers.dart';

part 'item_detail_providers.freezed.dart';

/// L'API ne pousse rien : le créneau ouvert se relit à ce rythme.
const Duration itemDetailRefresh = Duration(seconds: 30);

/// Comme pour les places : sans borne, une page de séries ouvrirait autant de
/// connexions en parallèle.
const int maxConcurrentChronos = 6;

/// Un créneau ouvert : sa réunion, son étape dans le déroulement de l'épreuve
/// et les places de ses courses.
@freezed
abstract class MeetingItemDetail with _$MeetingItemDetail {
  const MeetingItemDetail._();

  const factory MeetingItemDetail({
    required Meeting meeting,
    required MeetingItem item,
    Progression? progression,
    Stage? stage,

    /// Par id de place. Une valeur nulle est une place vide ; une clé absente,
    /// une place jamais lue.
    @Default(<int, LaneAssignment?>{}) Map<int, LaneAssignment?> lanes,

    /// TempsLive1..3 par id d'engagement. Vide pour un spectateur : le temps
    /// manuel n'est montré qu'aux officiels connectés.
    @Default(<int, List<int?>>{}) Map<int, List<int?>> chronos,
  }) = _MeetingItemDetail;

  /// Les places occupées de [heat], dans l'ordre des couloirs.
  List<LaneAssignment> lanesOf(Heat heat) => lanesOfHeat(heat, lanes);

  /// Le temps manuel des places de [heat] qui n'ont pas de temps publié.
  Map<int, ManualTime> manualTimesOf(Heat heat) =>
      chronos.isEmpty ? const {} : manualTimesOfLanes(lanesOf(heat), chronos);
}

/// Le lien vers un créneau porte la compétition : `creneau/:id` ne dit ni la
/// réunion ni le jour, que seul le programme donne.
typedef ItemKey = ({int competitionId, int itemId});

final meetingItemDetailProvider = AsyncNotifierProvider.autoDispose
    .family<MeetingItemDetailNotifier, MeetingItemDetail, ItemKey>(
      MeetingItemDetailNotifier.new,
    );

class MeetingItemDetailNotifier extends AsyncNotifier<MeetingItemDetail>
    with SerialRefresh<MeetingItemDetail> {
  MeetingItemDetailNotifier(this.key);

  final ItemKey key;

  /// Par course, quand ses places ont été lues pour la dernière fois alors
  /// qu'elle était terminée.
  final Map<int, DateTime> _finishedReadAt = {};

  @override
  Future<MeetingItemDetail> build() async {
    _finishedReadAt.clear();
    final timer = Timer.periodic(itemDetailRefresh, (_) => tick());
    ref.onDispose(timer.cancel);
    ref.listen(
      canEnterProvider(key.competitionId),
      (_, next) => _onCanEnterChanged(next),
    );
    // Lus avant toute attente : si la page se ferme pendant une requête,
    // `ref` ne peut plus servir.
    final repository = ref.read(meetingRepositoryProvider);
    final clock = ref.read(clockProvider);

    // Le programme se relit seul toutes les 30 s : le surveiller par
    // `ref.watch` reconstruirait le détail, et relirait toutes ses places, à
    // chacune de ses relectures. On n'en tire que la réunion et le déroulement,
    // qui ne bougent pas pendant qu'un créneau est ouvert. L'écoute à vide le
    // garde seulement en vie (`autoDispose`) : pendant l'attente de son
    // premier chargement, et pour que l'onglet le retrouve sans le recharger.
    final competitionId = key.competitionId;
    ref.listen(programmeProvider(competitionId), (_, _) {});
    // `.future` échouerait sur un programme en échec et attendrait un
    // programme qui se relit, alors que sa dernière valeur suffit.
    final Programme programme =
        ref.read(programmeProvider(competitionId)).value ??
        await ref.read(programmeProvider(competitionId).future);

    final found = programme.findItem(key.itemId);
    if (found == null) throw NotFoundException('meeting item ${key.itemId}');
    final readAt = clock();
    final item = await _readItem(repository, found.meeting.day);
    // Les chronos suivent l'affichage au lieu de le retarder ; la lecture
    // attend la fin de ce chargement et passe en série avec les relectures.
    scheduleMicrotask(() => runInSeries(() => _loadChronos(null)));
    final roundId = item.roundId;
    final progression = roundId == null
        ? null
        : programme.progressionOfStage(roundId);
    final placeIds = _placeIds(item.heats);
    final lanes = await repository.getLanes(placeIds);
    _recordReads(
      item.heats,
      {for (final heat in item.heats) heat.id},
      lanes,
      readAt,
    );

    return MeetingItemDetail(
      meeting: found.meeting,
      item: item,
      progression: progression,
      stage: roundId == null ? null : progression?.stageById(roundId),
      lanes: mergeLanes(const {}, lanes, placeIds),
    );
  }

  /// Les droits d'un officiel arrivent après le détail (rôles lus en ligne) :
  /// à leur arrivée les chronos se lisent, à leur perte ils disparaissent à
  /// l'instant. Avant le premier affichage, le chargement s'en charge.
  void _onCanEnterChanged(bool canEnter) {
    final current = state.value;
    if (current == null) return;
    if (!canEnter) {
      if (current.chronos.isNotEmpty) {
        state = AsyncData(current.copyWith(chronos: const {}));
      }
      return;
    }
    runInSeries(() => _loadChronos(null));
  }

  /// Lit les chronos des séries [heatIds] (toutes si nul) et les ajoute au
  /// détail déjà affiché. Un droit perdu pendant la lecture les jette.
  Future<void> _loadChronos(Set<int>? heatIds) async {
    final runRef = ref;
    if (state.value == null) {
      try {
        await future;
      } on AppException {
        return;
      }
      if (!runRef.mounted) return;
    }
    final current = state.value;
    if (current == null) return;
    final chronos = await _readChronos([
      for (final heat in current.item.heats)
        if (heatIds == null || heatIds.contains(heat.id)) heat,
    ]);
    if (!runRef.mounted) return;
    final latest = state.value;
    if (latest == null) return;
    if (!ref.read(canEnterProvider(key.competitionId))) {
      if (latest.chronos.isNotEmpty) {
        state = AsyncData(latest.copyWith(chronos: const {}));
      }
      return;
    }
    if (chronos.isEmpty) return;
    state = AsyncData(
      latest.copyWith(chronos: {...latest.chronos, ...chronos}),
    );
  }

  /// Les chronos des séries [heats], pour un officiel seulement : un
  /// spectateur ne déclenche aucun appel. Un échec ne fait jamais échouer le
  /// détail, il n'affiche simplement pas de temps manuel.
  Future<Map<int, List<int?>>> _readChronos(Iterable<Heat> heats) async {
    final runRef = ref;
    if (!ref.read(canEnterProvider(key.competitionId))) return const {};
    final repository = ref.read(resultRepositoryProvider);
    final chronos = <int, List<int?>>{};
    final seriesIds = [for (final heat in heats) ?heat.seriesId].iterator;
    // Les travailleurs tirent dans le même itérateur : `moveNext` + `current`
    // sans `await` entre les deux est sûr, le code n'est pas préemptif.
    Future<void> worker() async {
      while (runRef.mounted && seriesIds.moveNext()) {
        try {
          chronos.addAll(await repository.getHeatChronos(seriesIds.current));
        } on AppException {
          // Pas de temps manuel pour cette série.
        }
      }
    }

    await Future.wait([
      for (var i = 0; i < maxConcurrentChronos; i++) worker(),
    ]);
    return runRef.mounted ? chronos : const {};
  }

  /// Relit le créneau et toutes ses places, quel que soit l'état des courses.
  @override
  Future<void> reloadAll() => _reload(everything: true);

  @override
  Future<void> reloadIncremental() => _reload(everything: false);

  /// Un programme en échec garderait son échec en cache : le relire aussi,
  /// sans quoi le détail retomberait sur la même erreur.
  @override
  void beforeReloadFromScratch() {
    final competitionId = key.competitionId;
    final programme = ref.read(programmeProvider(competitionId));
    if (programme.hasError || !programme.hasValue) {
      ref.invalidate(programmeProvider(competitionId));
    }
  }

  Future<void> _reload({required bool everything}) async {
    final current = state.value;
    if (current == null) return;
    // Cette lecture peut survivre à la page, ou à une reconstruction du
    // détail : seul le `Ref` de son départ dit si son résultat compte encore,
    // et rien de `ref` ne doit servir après une attente sans l'avoir vérifié.
    final runRef = ref;
    final repository = ref.read(meetingRepositoryProvider);
    final clock = ref.read(clockProvider);
    try {
      final item = await _readItem(repository, current.meeting.day);
      if (!runRef.mounted) return;
      final readAt = clock();
      final due = everything
          ? {for (final heat in item.heats) heat.id}
          : heatsToRefresh(item.heats, _finishedReadAt, readAt);
      final placeIds = _placeIds([
        for (final heat in item.heats)
          if (due.contains(heat.id)) heat,
      ]);
      final fetched = placeIds.isEmpty
          ? const <int, LaneAssignment?>{}
          : await repository.getLanes(placeIds);
      if (!runRef.mounted) return;
      _recordReads(item.heats, due, fetched, readAt);
      // Les chronos déjà lus restent affichés pendant que les nouveaux se
      // lisent, sans retarder cette relecture.
      final latest = state.value ?? current;
      state = AsyncData(
        current.copyWith(
          item: item,
          lanes: mergeLanes(current.lanes, fetched, placeIds),
          chronos: ref.read(canEnterProvider(key.competitionId))
              ? latest.chronos
              : const {},
        ),
      );
      runInSeries(() => _loadChronos(due));
    } on AppException catch (error, stackTrace) {
      if (!runRef.mounted) return;
      state = AsyncError(error, stackTrace);
    }
  }

  Future<MeetingItem> _readItem(
    MeetingRepository repository,
    DateTime day,
  ) async =>
      await repository.getMeetingItem(key.itemId, day: day) ??
      (throw NotFoundException('meeting item ${key.itemId}'));

  /// Une course sans série (finale pas encore générée) n'est pas affichée :
  /// lire ses places ne servirait à rien.
  List<int> _placeIds(Iterable<Heat> heats) => [
    for (final heat in heats)
      if (heat.seriesId != null) ...heat.placeIds,
  ];

  /// Une course qui n'est pas (ou plus) terminée sort du registre : à son
  /// passage à « Terminé », elle sera relue tout de suite. Une course dont une
  /// place a échoué n'y entre pas : sinon elle attendrait 2 minutes, avec un
  /// nageur manquant, avant le nouvel essai.
  void _recordReads(
    List<Heat> heats,
    Set<int> due,
    Map<int, LaneAssignment?> fetched,
    DateTime readAt,
  ) {
    final finished = {
      for (final heat in heats)
        if (heat.status == RunStatus.finished) heat.id,
    };
    _finishedReadAt.removeWhere((id, _) => !finished.contains(id));
    for (final heat in heats) {
      if (finished.contains(heat.id) &&
          due.contains(heat.id) &&
          heat.placeIds.every(fetched.containsKey)) {
        _finishedReadAt[heat.id] = readAt;
      }
    }
  }
}

/// Le déroulement, déplié ou replié. Replié au départ : la ligne de résumé
/// suffit le plus souvent, et les séries restent en haut de l'écran. Sans
/// `autoDispose` : le choix vaut pour toute la session, d'un créneau à
/// l'autre.
final progressionExpandedProvider =
    NotifierProvider<ProgressionExpandedNotifier, bool>(
      ProgressionExpandedNotifier.new,
    );

class ProgressionExpandedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}
