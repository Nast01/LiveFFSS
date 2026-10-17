import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/repositories/meeting_repository.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/lane_assignment.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/progression.dart';
import 'package:live_ffss_v2/domain/run_status.dart';
import 'package:live_ffss_v2/features/programme/item_detail_refresh.dart';
import 'package:live_ffss_v2/features/programme/programme_providers.dart';

part 'item_detail_providers.freezed.dart';

/// L'API ne pousse rien : le créneau ouvert se relit à ce rythme.
const Duration itemDetailRefresh = Duration(seconds: 30);

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
  }) = _MeetingItemDetail;

  /// Les places occupées de [heat], dans l'ordre des couloirs.
  List<LaneAssignment> lanesOf(Heat heat) => [
    for (final id in heat.placeIds)
      if (lanes[id] case final lane? when !lane.isEmpty) lane,
  ]..sort((a, b) => a.lane.compareTo(b.lane));
}

/// Le lien vers un créneau porte la compétition : `creneau/:id` ne dit ni la
/// réunion ni le jour, que seul le programme donne.
typedef ItemKey = ({int competitionId, int itemId});

final meetingItemDetailProvider = AsyncNotifierProvider.autoDispose
    .family<MeetingItemDetailNotifier, MeetingItemDetail, ItemKey>(
      MeetingItemDetailNotifier.new,
    );

class MeetingItemDetailNotifier extends AsyncNotifier<MeetingItemDetail> {
  MeetingItemDetailNotifier(this.key);

  final ItemKey key;

  /// Par course, quand ses places ont été lues pour la dernière fois alors
  /// qu'elle était terminée.
  final Map<int, DateTime> _finishedReadAt = {};

  /// Deux relectures qui se chevauchent écriraient l'une sur l'autre, la plus
  /// lente gagnant avec des données plus vieilles.
  Future<void>? _inFlight;

  @override
  Future<MeetingItemDetail> build() async {
    _finishedReadAt.clear();
    final timer = Timer.periodic(itemDetailRefresh, (_) => _tick());
    ref.onDispose(timer.cancel);
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

  /// Relit le créneau et toutes ses places, quel que soit l'état des courses.
  Future<void> refresh() async {
    final runRef = ref;
    // En boucle : un autre `refresh` peut avoir pris la place entre-temps.
    for (var running = _inFlight; running != null; running = _inFlight) {
      await running;
      // Page fermée pendant l'attente : `state` et `ref` ne servent plus.
      if (!runRef.mounted) return;
    }
    await _run(
      state.hasValue ? () => _reload(everything: true) : _reloadFromScratch,
    );
  }

  /// La minuterie tient aussi lieu de nouvel essai après un premier
  /// chargement en échec.
  void _tick() {
    if (_inFlight != null) return;
    if (state.hasValue) {
      _run(() => _reload(everything: false));
    } else if (state.hasError && !state.isLoading) {
      _run(_reloadFromScratch);
    }
  }

  Future<void> _run(Future<void> Function() reload) {
    late final Future<void> run;
    run = reload().whenComplete(() {
      if (identical(_inFlight, run)) _inFlight = null;
    });
    _inFlight = run;
    return run;
  }

  Future<void> _reloadFromScratch() async {
    final competitionId = key.competitionId;
    // Un programme en échec garderait son échec en cache : le relire aussi,
    // sans quoi le détail retomberait sur la même erreur.
    final programme = ref.read(programmeProvider(competitionId));
    if (programme.hasError || !programme.hasValue) {
      ref.invalidate(programmeProvider(competitionId));
    }
    ref.invalidateSelf();
    try {
      await future;
    } on AppException {
      // L'échec est déjà dans l'état, que la page affiche.
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
      state = AsyncData(
        current.copyWith(
          item: item,
          lanes: mergeLanes(current.lanes, fetched, placeIds),
        ),
      );
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

/// La frise du déroulement, dépliée ou repliée. Sans `autoDispose` : le choix
/// vaut pour toute la session, d'un créneau à l'autre.
final progressionExpandedProvider =
    NotifierProvider<ProgressionExpandedNotifier, bool>(
      ProgressionExpandedNotifier.new,
    );

class ProgressionExpandedNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() => state = !state;
}
