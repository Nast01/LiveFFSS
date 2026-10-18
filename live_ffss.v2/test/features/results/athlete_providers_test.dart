import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/ffss/dtos/deroulement_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/epreuve_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/participant_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/reunion_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/serie_results_dto.dart';
import 'package:live_ffss_v2/data/ffss/mappers/deroulement_mapper.dart';
import 'package:live_ffss_v2/data/ffss/mappers/reunion_mapper.dart';
import 'package:live_ffss_v2/data/ffss/mappers/results_mapper.dart';
import 'package:live_ffss_v2/data/repositories/meeting_repository.dart';
import 'package:live_ffss_v2/data/repositories/results_repository.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/lane_assignment.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/run_status.dart';
import 'package:live_ffss_v2/domain/series_link.dart';
import 'package:live_ffss_v2/features/results/athlete_providers.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/fixtures.dart';

class _MockResultsRepository extends Mock implements ResultsRepository {}

class _MockMeetingRepository extends Mock implements MeetingRepository {}

List<Map<String, dynamic>> _rows(String name) =>
    (fixture(name)['data'] as List<dynamic>).cast<Map<String, dynamic>>();

Programme _fixtureProgramme() {
  final progressions = [
    for (final row in _rows('deroulement'))
      ?DeroulementDto.fromJson(row).toDomain(),
  ];
  final meetings = [
    for (final row in _rows('reunion')) ?ReunionDto.fromJson(row).toDomain(),
  ];
  return Programme(
    meetings: withRaces(meetings, progressions),
    progressions: progressions,
  );
}

/// Le programme dont chaque course prend le statut que [status] lui donne.
Programme _withStatus(
  Programme programme,
  RunStatus Function(Heat heat) status,
) => programme.copyWith(
  meetings: [
    for (final meeting in programme.meetings)
      meeting.copyWith(
        items: [
          for (final item in meeting.items)
            item.copyWith(
              heats: [
                for (final heat in item.heats)
                  heat.copyWith(status: status(heat)),
              ],
            ),
        ],
      ),
  ],
);

void main() {
  const competitionId = 1416;
  final fixtureProgramme = _fixtureProgramme();
  final events = [
    for (final row in _rows('epreuves_1416'))
      ?EpreuveDto.fromJson(row).toDomain(),
  ];
  final series = {
    for (final id in const [36073, 36074, 36087])
      id: [
        for (final row in _rows('serie_epreuve_$id'))
          ?SerieResultsDto.fromJson(row).toDomain(),
      ],
  };
  final participants = [
    for (final row in _rows('participants_1416'))
      ?ParticipantDto.fromJson(row).toDomain(),
  ];
  // Courses 479 et 480 : le tour séries de 36073 et 36074 (créneau 177).
  final heats = {
    for (final meeting in fixtureProgramme.meetings)
      for (final item in meeting.items)
        for (final heat in item.heats) heat.id: heat,
  };

  late _MockResultsRepository results;
  late _MockMeetingRepository meetings;
  late Programme programme;
  late Map<int, LaneAssignment?> lanes;

  ProviderContainer container() => ProviderContainer(
    overrides: [
      resultsRepositoryProvider.overrideWithValue(results),
      meetingRepositoryProvider.overrideWithValue(meetings),
      clockProvider.overrideWithValue(() => DateTime(2026, 3, 27, 7)),
    ],
    retry: noRetry,
  );

  setUpAll(() => registerFallbackValue(<int>[]));

  setUp(() {
    results = _MockResultsRepository();
    meetings = _MockMeetingRepository();
    programme = fixtureProgramme;
    lanes = {};
    when(() => meetings.getProgramme(any())).thenAnswer((_) async => programme);
    when(() => results.getEvents(any())).thenAnswer((_) async => events);
    when(() => results.getEventSeries(any())).thenAnswer(
      (invocation) async =>
          series[invocation.positionalArguments.first as int] ?? const [],
    );
    when(
      () => results.getParticipants(any()),
    ).thenAnswer((_) async => participants);
    when(() => meetings.getLanes(any())).thenAnswer((invocation) async {
      final ids = invocation.positionalArguments.first as Iterable<int>;
      return {
        for (final id in ids)
          if (lanes.containsKey(id)) id: lanes[id],
      };
    });
  });

  group('participantsProvider', () {
    test('lus une fois tant que la recherche vit', () async {
      final c = container();
      addTearDown(c.dispose);
      c.listen(participantsProvider(competitionId), (_, _) {});

      final first = await c.read(participantsProvider(competitionId).future);
      final second = await c.read(participantsProvider(competitionId).future);

      expect(first, hasLength(participants.length));
      expect(second, same(first));
      verify(() => results.getParticipants(competitionId)).called(1);
    });
  });

  group('athleteCardProvider', () {
    Future<List<AthleteRace>> card(ProviderContainer c, int participantId) {
      final key = (competitionId: competitionId, participantId: participantId);
      c.listen(athleteCardProvider(key), (_, _) {});
      return c.read(athleteCardProvider(key).future);
    }

    test('une course courue : série, rang dans l\'épreuve, place', () async {
      final c = container();
      addTearDown(c.dispose);

      // ATHLETE N020 : 566082 en 36073, seule de ses épreuves dont les
      // séries sont dans les fixtures.
      final races = await card(c, 632572);

      expect(races, hasLength(6));
      final race = races.first;
      expect(races.skip(1).map((r) => r.toRun), everyElement(isTrue));
      expect(race.event.id, 36073);
      expect(race.entry.entryId, 566082);
      expect(race.row, isNotNull);
      expect(race.row!.result.entryId, 566082);
      expect(race.row!.rank, isNotNull);
      expect(race.series, isNotNull);
      expect(race.series!.round, EventRound.heats);
      expect(
        race.series!.series.results.map((r) => r.entryId),
        contains(566082),
      );
      expect(race.heatPlace, isNotNull);
      expect(race.heatPlace, greaterThanOrEqualTo(1));
      expect(race.plannedStart, race.series!.heat.plannedStart);
    });

    test('une épreuve sans résultat : à courir, après les courues', () async {
      final n020 = participants.firstWhere((p) => p.id == 632572);
      when(() => results.getParticipants(any())).thenAnswer(
        (_) async => [
          n020.copyWith(
            entries: [
              // Engagé en 36074 sans résultat : le tour séries de 36074
              // commence par la course 479.
              const ParticipantEntry(
                entryId: 1,
                eventId: 36074,
                categoryName: 'Junior',
              ),
              ...n020.entries,
            ],
          ),
        ],
      );
      final c = container();
      addTearDown(c.dispose);

      final races = await card(c, 632572);

      // 36074 a une course au programme, les autres épreuves non : elles
      // viennent après.
      expect(races.map((r) => r.event.id).take(2), [36073, 36074]);
      expect(races.skip(2).map((r) => r.plannedStart), everyElement(isNull));
      final toRun = races[1];
      expect(toRun.row, isNull);
      expect(toRun.series, isNull);
      expect(toRun.heatPlace, isNull);
      expect(toRun.plannedStart, heats[479]!.plannedStart);
    });

    test('un relais sans série rattachée : à courir, sans heure', () async {
      final c = container();
      addTearDown(c.dispose);

      // ATHLETE N081 : seulement le relais 36087, que nul déroulement ne
      // couvre dans les fixtures.
      final races = await card(c, 632821);

      expect(races, hasLength(1));
      expect(races.single.event.id, 36087);
      expect(races.single.row, isNull);
      expect(races.single.plannedStart, isNull);
    });

    test('un participant inconnu échoue', () async {
      final c = container();
      addTearDown(c.dispose);

      await expectLater(card(c, 1), throwsA(isA<NotFoundException>()));
    });
  });

  group('laneFinderProvider', () {
    const entryId = 424242;
    const key = (
      competitionId: competitionId,
      eventId: 36074,
      entryId: entryId,
    );

    Future<LaneFound?> find(ProviderContainer c) {
      c.listen(laneFinderProvider(key), (_, _) {});
      return c.read(laneFinderProvider(key).future);
    }

    LaneAssignment lane(int placeId, int number, {int? entry}) =>
        LaneAssignment(
          id: placeId,
          lane: number,
          athletes: const ['ATHLETE Un'],
          entryId: entry,
        );

    void allPlacesEmpty() {
      for (final heat in heats.values) {
        for (final id in heat.placeIds) {
          lanes[id] = null;
        }
      }
    }

    test('s\'arrête à la première course qui le porte', () async {
      programme = _withStatus(fixtureProgramme, (_) => RunStatus.waiting);
      allPlacesEmpty();
      final first = heats[479]!;
      lanes[first.placeIds[2]] = lane(first.placeIds[2], 3, entry: entryId);
      final c = container();
      addTearDown(c.dispose);

      final found = await find(c);

      expect(found, isNotNull);
      expect(found!.heat.id, 479);
      expect(found.lane, 3);
      verify(() => meetings.getLanes(first.placeIds)).called(1);
      verifyNever(() => meetings.getLanes(heats[480]!.placeIds));
    });

    test('absent de toutes les places : nul', () async {
      programme = _withStatus(fixtureProgramme, (_) => RunStatus.waiting);
      allPlacesEmpty();
      final second = heats[480]!;
      lanes[second.placeIds.first] = lane(
        second.placeIds.first,
        1,
        entry: entryId + 1,
      );
      final c = container();
      addTearDown(c.dispose);

      expect(await find(c), isNull);
      verify(() => meetings.getLanes(heats[479]!.placeIds)).called(1);
      verify(() => meetings.getLanes(second.placeIds)).called(1);
    });

    test('les courses terminées sont sautées', () async {
      programme = _withStatus(
        fixtureProgramme,
        (heat) => heat.id == 479 ? RunStatus.finished : RunStatus.waiting,
      );
      allPlacesEmpty();
      final second = heats[480]!;
      lanes[second.placeIds.last] = lane(
        second.placeIds.last,
        8,
        entry: entryId,
      );
      final c = container();
      addTearDown(c.dispose);

      final found = await find(c);

      expect(found?.heat.id, 480);
      expect(found?.lane, 8);
      verifyNever(() => meetings.getLanes(heats[479]!.placeIds));
    });

    test('toutes terminées : nul, sans aucune lecture', () async {
      final c = container();
      addTearDown(c.dispose);

      expect(await find(c), isNull);
      verifyNever(() => meetings.getLanes(any()));
    });

    test('une place illisible sans l\'athlète ailleurs : échec', () async {
      programme = _withStatus(fixtureProgramme, (_) => RunStatus.waiting);
      allPlacesEmpty();
      lanes.remove(heats[480]!.placeIds.first);
      final c = container();
      addTearDown(c.dispose);

      await expectLater(find(c), throwsA(isA<NetworkException>()));
    });
  });
}
