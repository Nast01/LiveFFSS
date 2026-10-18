import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/data/repositories/meeting_repository.dart';
import 'package:live_ffss_v2/data/repositories/results_repository.dart';
import 'package:live_ffss_v2/domain/event_ranking.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/lane_assignment.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/run_status.dart';
import 'package:live_ffss_v2/domain/series_link.dart';
import 'package:live_ffss_v2/features/results/results_providers.dart';

part 'athlete_providers.freezed.dart';

/// Les participants de la compétition (3,6 Mo pour 1416), filtrés sur place
/// par la recherche. Lus une fois : [participantsKeeperProvider] les garde
/// tant que l'onglet Résultats vit.
final participantsProvider = FutureProvider.autoDispose
    .family<List<Participant>, int>(
      (ref, competitionId) =>
          ref.read(resultsRepositoryProvider).getParticipants(competitionId),
    );

/// Garde [participantsProvider] en vie dès sa première lecture (recherche ou
/// fiche) et tant que l'onglet Résultats l'écoute : sans lui, chaque fiche
/// ouverte relirait la liste. Rien ne la lit avant : la recherche peut ne
/// jamais servir.
final participantsKeeperProvider = NotifierProvider.autoDispose
    .family<ParticipantsKeeper, void, int>(ParticipantsKeeper.new);

class ParticipantsKeeper extends Notifier<void> {
  ParticipantsKeeper(this.competitionId);

  final int competitionId;

  ProviderSubscription<AsyncValue<List<Participant>>>? _subscription;

  @override
  void build() {}

  /// Sans écoute de l'onglet, ce gardien est jeté aussitôt, et son écoute
  /// avec lui.
  void keep() => _subscription ??= ref.listen(
    participantsProvider(competitionId),
    (_, _) {},
  );
}

/// Une épreuve de la fiche d'un athlète. [row] nul : à courir.
@freezed
abstract class AthleteRace with _$AthleteRace {
  const AthleteRace._();

  const factory AthleteRace({
    required CompetitionEvent event,
    required ParticipantEntry entry,

    /// Sa série rattachée, connue aussi d'une course publiée mais pas encore
    /// courue.
    LinkedSeries? series,

    /// Son résultat dans le classement de l'épreuve, nul tant qu'il n'a pas
    /// couru.
    RankingRow? row,

    /// Place dans sa série, parmi les résultats de sa catégorie.
    int? heatPlace,

    /// Le départ prévu de sa course, sinon celui de la première course du
    /// tour séries de l'épreuve.
    DateTime? plannedStart,

    /// Le classement de l'épreuve n'a pu être lu : ni série ni résultat.
    @Default(false) bool unavailable,
  }) = _AthleteRace;

  bool get toRun => row == null;
}

/// La fiche d'un athlète : ses épreuves eau plate, courues d'abord, puis à
/// courir (et celles dont le classement est illisible), chacune dans l'ordre
/// du programme. Suit les classements, relus par le rafraîchissement des
/// résultats.
final athleteCardProvider = FutureProvider.autoDispose
    .family<List<AthleteRace>, ({int competitionId, int participantId})>((
      ref,
      key,
    ) async {
      ref.read(participantsKeeperProvider(key.competitionId).notifier).keep();
      // Les trois lectures partent ensemble. Celles qu'on n'attend pas encore
      // ne doivent pas remonter leur échec comme non traité : `await` le
      // reçoit quand même.
      final participantsRead = ref.watch(
        participantsProvider(key.competitionId).future,
      );
      final eventsRead = ref.watch(eventsProvider(key.competitionId).future)
        ..ignore();
      final programmeRead = ref.watch(
        resultsProgrammeProvider(key.competitionId).future,
      )..ignore();
      final participants = await participantsRead;
      final events = await eventsRead;
      final programme = await programmeRead;
      if (!ref.mounted) return const [];
      final participant = participants
          .where((p) => p.id == key.participantId)
          .firstOrNull;
      if (participant == null) {
        throw NotFoundException('participant ${key.participantId}');
      }

      final eventsById = {for (final event in events) event.id: event};
      // Les épreuves côtières ne sont pas dans `events` : elles restent hors
      // de la fiche.
      final entries = [
        for (final entry in participant.entries)
          if (eventsById.containsKey(entry.eventId)) entry,
      ];
      final eventIds = {for (final entry in entries) entry.eventId}.toList();
      // Une épreuve illisible ne doit pas emporter la fiche.
      Future<EventRanking?> ranking(int eventId) async {
        try {
          return await ref.watch(
            eventRankingProvider((
              competitionId: key.competitionId,
              eventId: eventId,
            )).future,
          );
        } on AppException {
          return null;
        }
      }

      final rankings = await Future.wait([
        for (final eventId in eventIds) ranking(eventId),
      ]);
      if (!ref.mounted) return const [];
      final rankingOf = {
        for (final (i, eventId) in eventIds.indexed) eventId: rankings[i],
      };

      final order = programmeOrder(programme);
      int orderOf(AthleteRace race) {
        final heat =
            race.series?.heat ??
            heatsRoundOf(programme, race.event).firstOrNull;
        return heat == null ? order.length : order[heat.id] ?? order.length;
      }

      final races = [
        for (final entry in entries)
          _race(
            eventsById[entry.eventId]!,
            entry,
            rankingOf[entry.eventId],
            programme,
          ),
      ];
      // `sort` n'est pas stable : l'indice départage, l'ordre des engagements
      // reste à course égale.
      final indexed = races.indexed.toList()
        ..sort((a, b) {
          final byRun = (a.$2.toRun ? 1 : 0).compareTo(b.$2.toRun ? 1 : 0);
          if (byRun != 0) return byRun;
          final byOrder = orderOf(a.$2).compareTo(orderOf(b.$2));
          return byOrder != 0 ? byOrder : a.$1.compareTo(b.$1);
        });
      return [for (final (_, race) in indexed) race];
    });

typedef AthleteKey = ({int competitionId, int participantId});

/// « Réessayer » d'une fiche en échec. Les lectures en amont gardent leur
/// erreur tant qu'on ne les relance pas : relancer la fiche seule rendrait la
/// même erreur. La page passe le conteneur de son `ProviderScope`.
void retryAthleteCard(ProviderContainer container, AthleteKey key) {
  final competitionId = key.competitionId;
  if (container.read(participantsProvider(competitionId)).hasError) {
    container.invalidate(participantsProvider(competitionId));
  }
  if (container.read(eventsProvider(competitionId)).hasError ||
      container.read(resultsProgrammeProvider(competitionId)).hasError) {
    // `refresh` porte son échec dans l'état, qu'il n'y a pas à attendre.
    unawaited(container.read(eventsProvider(competitionId).notifier).refresh());
  }
  container.invalidate(athleteCardProvider(key));
}

/// Rafraîchissement d'une fiche : les classements de ses épreuves seulement.
/// Les participants (3,6 Mo) ne sont relus que par « Réessayer » s'ils ont
/// échoué ; les engagements changent peu pendant une compétition.
Future<void> refreshAthleteCard(
  ProviderContainer container,
  AthleteKey key,
) async {
  final competitionId = key.competitionId;
  final races = container.read(athleteCardProvider(key)).value ?? const [];
  for (final eventId in {for (final race in races) race.event.id}) {
    container.invalidate(
      eventRankingProvider((competitionId: competitionId, eventId: eventId)),
    );
  }
  try {
    await container.read(athleteCardProvider(key).future);
  } on AppException {
    // L'échec est dans l'état de la fiche, que la page montre.
  }
}

AthleteRace _race(
  CompetitionEvent event,
  ParticipantEntry entry,
  EventRanking? ranking,
  Programme programme,
) {
  final roundStart = heatsRoundOf(programme, event).firstOrNull?.plannedStart;
  if (ranking == null) {
    return AthleteRace(
      event: event,
      entry: entry,
      plannedStart: roundStart,
      unavailable: true,
    );
  }
  final row = ranking.rows
      .where((r) => r.result.entryId == entry.entryId)
      .firstOrNull;
  if (row == null) {
    return AthleteRace(event: event, entry: entry, plannedStart: roundStart);
  }
  final series = row.series;
  final run = hasRun(row.result);
  return AthleteRace(
    event: event,
    entry: entry,
    series: series,
    row: run ? row : null,
    heatPlace: run ? heatPlace(row.result, series.series.results) : null,
    plannedStart: series.heat.plannedStart ?? roundStart,
  );
}

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

      LaneFound? match(Heat heat, Map<int, LaneAssignment?> lanes, int id) =>
          switch (lanes[id]) {
            final lane? when lane.entryId == key.entryId => LaneFound(
              heat: heat,
              lane: lane.lane,
            ),
            _ => null,
          };

      final unread = <int, Heat>{};
      for (final heat in heatsRoundOf(programme, event)) {
        if (heat.status == RunStatus.finished || heat.placeIds.isEmpty) {
          continue;
        }
        final lanes = await repository.getLanes(heat.placeIds);
        if (!ref.mounted) return null;
        for (final placeId in heat.placeIds) {
          if (!lanes.containsKey(placeId)) {
            unread[placeId] = heat;
          } else if (match(heat, lanes, placeId) case final found?) {
            return found;
          }
        }
      }
      if (unread.isEmpty) return null;

      // Un échec passager ne doit pas laisser l'athlète introuvable : les
      // places illisibles sont relues une fois.
      final retried = await repository.getLanes(unread.keys);
      if (!ref.mounted) return null;
      for (final MapEntry(key: placeId, value: heat) in unread.entries) {
        if (match(heat, retried, placeId) case final found?) return found;
      }
      // Une place encore illisible pouvait le porter : « Pas encore placé »
      // serait faux.
      if (unread.keys.any((id) => !retried.containsKey(id))) {
        throw const NetworkException('places illisibles');
      }
      return null;
    });
