import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/repositories/meeting_repository.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/lane_assignment.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
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

  MeetingRepository get _repository => ref.read(meetingRepositoryProvider);

  @override
  Future<MeetingItemDetail> build() async {
    _finishedReadAt.clear();
    final timer = Timer.periodic(itemDetailRefresh, (_) => _tick());
    ref.onDispose(timer.cancel);

    // Le programme se relit seul toutes les 30 s : le surveiller par
    // `ref.watch` reconstruirait le détail, et relirait toutes ses places, à
    // chacune de ses relectures. On n'en tire que la réunion et le déroulement,
    // qui ne bougent pas pendant qu'un créneau est ouvert. L'écoute à vide le
    // garde seulement en vie (`autoDispose`) : pendant l'attente de son
    // premier chargement, et pour que l'onglet le retrouve sans le recharger.
    final competitionId = key.competitionId;
    ref.listen(programmeProvider(competitionId), (_, _) {});
    final programme = await ref.read(programmeProvider(competitionId).future);

    final found = programme.findItem(key.itemId);
    if (found == null) throw NotFoundException('meeting item ${key.itemId}');
    final item = await _readItem(found.meeting.day);
    final roundId = item.roundId;
    final progression = roundId == null
        ? null
        : programme.progressionOfStage(roundId);
    final placeIds = _placeIds(item.heats);
    final lanes = await _repository.getLanes(placeIds);
    _recordReads(item.heats, {for (final heat in item.heats) heat.id});

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
    if (!state.hasValue) {
      ref.invalidateSelf();
      try {
        await future;
      } on AppException {
        // L'échec est déjà dans l'état, que la page affiche.
      }
      return;
    }
    await _inFlight;
    await _run(everything: true);
  }

  void _tick() {
    if (_inFlight != null || !state.hasValue) return;
    _run(everything: false);
  }

  Future<void> _run({required bool everything}) {
    final run = _reload(everything: everything);
    _inFlight = run;
    return run.whenComplete(() => _inFlight = null);
  }

  Future<void> _reload({required bool everything}) async {
    final current = state.value;
    if (current == null) return;
    try {
      final item = await _readItem(current.meeting.day);
      final due = everything
          ? {for (final heat in item.heats) heat.id}
          : heatsToRefresh(item.heats, _finishedReadAt, _now());
      final placeIds = _placeIds([
        for (final heat in item.heats)
          if (due.contains(heat.id)) heat,
      ]);
      final fetched = placeIds.isEmpty
          ? const <int, LaneAssignment?>{}
          : await _repository.getLanes(placeIds);
      if (!ref.mounted) return;
      _recordReads(item.heats, due);
      state = AsyncData(
        current.copyWith(
          item: item,
          lanes: mergeLanes(current.lanes, fetched, placeIds),
        ),
      );
    } on AppException catch (error, stackTrace) {
      if (!ref.mounted) return;
      state = AsyncError(error, stackTrace);
    }
  }

  Future<MeetingItem> _readItem(DateTime day) async =>
      await _repository.getMeetingItem(key.itemId, day: day) ??
      (throw NotFoundException('meeting item ${key.itemId}'));

  DateTime _now() => ref.read(clockProvider)();

  List<int> _placeIds(Iterable<Heat> heats) => [
    for (final heat in heats) ...heat.placeIds,
  ];

  /// Une course qui n'est pas (ou plus) terminée sort du registre : à son
  /// passage à « Terminé », elle sera relue tout de suite.
  void _recordReads(List<Heat> heats, Set<int> read) {
    final now = _now();
    final finished = {
      for (final heat in heats)
        if (heat.status == RunStatus.finished) heat.id,
    };
    _finishedReadAt.removeWhere((id, _) => !finished.contains(id));
    for (final id in read.intersection(finished)) {
      _finishedReadAt[id] = now;
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
