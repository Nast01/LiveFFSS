import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/data/repositories/meeting_repository.dart';
import 'package:live_ffss_v2/data/repositories/results_repository.dart';
import 'package:live_ffss_v2/domain/athlete_search.dart';
import 'package:live_ffss_v2/domain/event_ranking.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/run_status.dart';
import 'package:live_ffss_v2/domain/series_link.dart';
import 'package:live_ffss_v2/features/results/results_providers.dart';

part 'athlete_providers.freezed.dart';

/// Les participants de la compétition, lus une fois tant que la recherche (ou
/// une fiche) les écoute : la liste est lourde, la recherche la filtre sur
/// place.
final participantsProvider = FutureProvider.autoDispose
    .family<List<Participant>, int>(
      (ref, competitionId) =>
          ref.read(resultsRepositoryProvider).getParticipants(competitionId),
    );

/// Une épreuve de la fiche d'un athlète. [series] et [row] nuls : à courir.
@freezed
abstract class AthleteRace with _$AthleteRace {
  const AthleteRace._();

  const factory AthleteRace({
    required CompetitionEvent event,
    required ParticipantEntry entry,
    LinkedSeries? series,
    RankingRow? row,

    /// Place dans sa série, parmi les résultats de sa catégorie.
    int? heatPlace,

    /// Courue : le départ prévu de sa course ; à courir : celui de la première
    /// course du tour séries de l'épreuve.
    DateTime? plannedStart,
  }) = _AthleteRace;

  bool get toRun => row == null;
}

/// La fiche d'un athlète : ses épreuves eau plate, courues d'abord dans
/// l'ordre du programme, puis à courir. Suit les classements, relus par le
/// rafraîchissement des résultats.
final athleteCardProvider = FutureProvider.autoDispose
    .family<List<AthleteRace>, ({int competitionId, int participantId})>((
      ref,
      key,
    ) async {
      final participants = await ref.watch(
        participantsProvider(key.competitionId).future,
      );
      if (!ref.mounted) return const [];
      final participant = participants
          .where((p) => p.id == key.participantId)
          .firstOrNull;
      if (participant == null) {
        throw NotFoundException('participant ${key.participantId}');
      }
      final events = await ref.watch(eventsProvider(key.competitionId).future);
      if (!ref.mounted) return const [];
      final programme = await ref.watch(
        resultsProgrammeProvider(key.competitionId).future,
      );
      if (!ref.mounted) return const [];

      final eventsById = {for (final event in events) event.id: event};
      // Les épreuves côtières ne sont pas dans `events` : elles restent hors
      // de la fiche.
      final entries = [
        for (final entry in participant.entries)
          if (eventsById.containsKey(entry.eventId)) entry,
      ];
      final eventIds = {for (final entry in entries) entry.eventId}.toList();
      final rankings = await Future.wait([
        for (final eventId in eventIds)
          ref.watch(
            eventRankingProvider((
              competitionId: key.competitionId,
              eventId: eventId,
            )).future,
          ),
      ]);
      if (!ref.mounted) return const [];
      final rankingOf = {
        for (final (i, eventId) in eventIds.indexed) eventId: rankings[i],
      };

      final order = programmeOrder(programme);
      final races = <({AthleteRace race, int order})>[];
      for (final entry in entries) {
        final event = eventsById[entry.eventId]!;
        final ranking = rankingOf[entry.eventId]!;
        final row = ranking.rows
            .where((r) => r.result.entryId == entry.entryId)
            .firstOrNull;
        final linked = row == null
            ? null
            : ranking.series
                  .where(
                    (s) => s.series.results.any((r) => r.id == row.result.id),
                  )
                  .firstOrNull;
        final Heat? heat =
            linked?.heat ?? heatsRoundOf(programme, event).firstOrNull;
        races.add((
          race: AthleteRace(
            event: event,
            entry: entry,
            series: linked,
            row: row,
            heatPlace: row == null || linked == null
                ? null
                : heatPlace(row.result, linked.series.results),
            plannedStart: heat?.plannedStart,
          ),
          order: heat == null ? order.length : order[heat.id] ?? order.length,
        ));
      }
      // `sort` n'est pas stable : l'indice départage, l'ordre des épreuves
      // reste celui des engagements à course égale.
      final indexed = races.indexed.toList()
        ..sort((a, b) {
          final byRun = (a.$2.race.toRun ? 1 : 0).compareTo(
            b.$2.race.toRun ? 1 : 0,
          );
          if (byRun != 0) return byRun;
          final byOrder = a.$2.order.compareTo(b.$2.order);
          return byOrder != 0 ? byOrder : a.$1.compareTo(b.$1);
        });
      return [for (final (_, entry) in indexed) entry.race];
    });

/// La course et la ligne d'un engagement à venir.
@freezed
abstract class LaneFound with _$LaneFound {
  const factory LaneFound({required Heat heat, required int lane}) = _LaneFound;
}

/// « Trouver sa série » : lit les places des courses non terminées du tour
/// séries de l'épreuve, course par course, et s'arrête à la première qui porte
/// l'engagement (décision du 2026-10-18, option A : aucune route ne donne la
/// place d'un engagement). Nul si aucune ne le porte.
final laneFinderProvider = FutureProvider.autoDispose
    .family<LaneFound?, ({int competitionId, int eventId, int entryId})>((
      ref,
      key,
    ) async {
      // Tout ce qui sert de `ref` est pris avant la première attente.
      final repository = ref.read(meetingRepositoryProvider);
      final events = await ref.watch(eventsProvider(key.competitionId).future);
      if (!ref.mounted) return null;
      final programme = await ref.watch(
        resultsProgrammeProvider(key.competitionId).future,
      );
      if (!ref.mounted) return null;
      final event = events.where((e) => e.id == key.eventId).firstOrNull;
      if (event == null) throw NotFoundException('event ${key.eventId}');

      var unread = false;
      for (final heat in heatsRoundOf(programme, event)) {
        if (heat.status == RunStatus.finished || heat.placeIds.isEmpty) {
          continue;
        }
        final lanes = await repository.getLanes(heat.placeIds);
        if (!ref.mounted) return null;
        for (final placeId in heat.placeIds) {
          if (!lanes.containsKey(placeId)) {
            unread = true;
          } else if (lanes[placeId] case final lane?
              when lane.entryId == key.entryId) {
            return LaneFound(heat: heat, lane: lane.lane);
          }
        }
      }
      // Une place illisible pouvait le porter : « Pas encore placé » serait
      // faux.
      if (unread) throw const NetworkException('places illisibles');
      return null;
    });
