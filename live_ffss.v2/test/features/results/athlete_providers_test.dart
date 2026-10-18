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
import 'package:live_ffss_v2/features/results/results_providers.dart';
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
  // Places qui échouent à leur première lecture seulement.
  late Set<int> flaky;

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
    flaky = {};
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
          if (!flaky.remove(id) && lanes.containsKey(id)) id: lanes[id],
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

    Future<void> openAndClose(ProviderContainer c, int participantId) async {
      final key = (competitionId: competitionId, participantId: participantId);
      final subscription = c.listen(athleteCardProvider(key), (_, _) {});
      await c.read(athleteCardProvider(key).future);
      subscription.close();
      await pumpEventQueue();
    }

    test(
      "deux fiches de suite, l'onglet Résultats ouvert : lus une fois",
      () async {
        final c = container();
        addTearDown(c.dispose);
        // Ce qu'écoute l'onglet Résultats.
        c.listen(participantsKeeperProvider(competitionId), (_, _) {});

        await openAndClose(c, 632572);
        await openAndClose(c, 632821);

        verify(() => results.getParticipants(competitionId)).called(1);
      },
    );

    test("l'onglet Résultats fermé : plus rien ne les garde", () async {
      final c = container();
      addTearDown(c.dispose);
      final tab = c.listen(
        participantsKeeperProvider(competitionId),
        (_, _) {},
      );
      await openAndClose(c, 632572);
      tab.close();
      await pumpEventQueue();

      await openAndClose(c, 632821);

      verify(() => results.getParticipants(competitionId)).called(2);
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
      // Série 2 (course 480) : 15917, 16136, puis 16195. Seules les séries 1
      // et 2 sont au programme des fixtures : le rang de l'épreuve se fait
      // sur elles, et 16195 y est aussi troisième.
      expect(race.row!.result.time, 16195);
      expect(race.row!.rank, 3);
      expect(race.series, isNotNull);
      expect(race.series!.heat.id, 480);
      expect(race.series!.round, EventRound.heats);
      expect(
        race.series!.series.results.map((r) => r.entryId),
        contains(566082),
      );
      expect(race.heatPlace, 3);
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

    test(
      "publiée sans temps ni statut : à courir, à l'heure de sa course",
      () async {
        // Un engagement de 36074 qui a couru, et 566082 dont la série est
        // publiée mais pas encore courue.
        final run36074 = series[36074]!
            .firstWhere((s) => s.start != null && s.number == 2)
            .results
            .first;
        final unrun = {
          ...series,
          36073: [
            for (final one in series[36073]!)
              one.copyWith(
                results: [
                  for (final r in one.results)
                    r.entryId == 566082 ? r.copyWith(time: null) : r,
                ],
              ),
          ],
        };
        when(() => results.getEventSeries(any())).thenAnswer(
          (invocation) async =>
              unrun[invocation.positionalArguments.first as int] ?? const [],
        );
        final n020 = participants.firstWhere((p) => p.id == 632572);
        when(() => results.getParticipants(any())).thenAnswer(
          (_) async => [
            n020.copyWith(
              entries: [
                const ParticipantEntry(
                  entryId: 566082,
                  eventId: 36073,
                  categoryName: 'Cadet',
                ),
                ParticipantEntry(
                  entryId: run36074.entryId,
                  eventId: 36074,
                  categoryName: 'Junior',
                ),
              ],
            ),
          ],
        );
        final c = container();
        addTearDown(c.dispose);

        final races = await card(c, 632572);

        expect(races.map((r) => r.event.id), [36074, 36073]);
        expect(races.first.toRun, isFalse);
        final toRun = races.last;
        expect(toRun.toRun, isTrue);
        expect(toRun.row, isNull);
        expect(toRun.heatPlace, isNull);
        // Sa série est connue : l'heure est celle de sa course, pas du tour.
        expect(toRun.series, isNotNull);
        expect(toRun.plannedStart, toRun.series!.heat.plannedStart);
      },
    );

    test('une épreuve illisible : indisponible, le reste listé', () async {
      when(() => results.getEventSeries(any())).thenAnswer((invocation) async {
        final id = invocation.positionalArguments.first as int;
        if (id == 36073) throw const NetworkException('hors ligne');
        return series[id] ?? const [];
      });
      final c = container();
      addTearDown(c.dispose);

      final races = await card(c, 632572);

      expect(races, hasLength(6));
      final failed = races.firstWhere((r) => r.event.id == 36073);
      expect(failed.unavailable, isTrue);
      expect(failed.row, isNull);
      expect(failed.series, isNull);
      expect(failed.heatPlace, isNull);
      expect(failed.plannedStart, heats[479]!.plannedStart);
      // Avec les « à courir », dans l'ordre du programme : sa course est la
      // seule au programme.
      expect(races.first, failed);
      expect(races.skip(1).map((r) => r.unavailable), everyElement(isFalse));
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

  group('retryAthleteCard', () {
    const key = (competitionId: competitionId, participantId: 632572);

    Future<AsyncValue<List<AthleteRace>>> settled(ProviderContainer c) async {
      try {
        await c.read(athleteCardProvider(key).future);
      } on AppException {
        // L'état porte l'erreur.
      }
      return c.read(athleteCardProvider(key));
    }

    test('participants en échec, puis lus : la fiche se charge', () async {
      var fail = true;
      when(() => results.getParticipants(any())).thenAnswer((_) async {
        if (fail) throw const NetworkException('hors ligne');
        return participants;
      });
      final c = container();
      addTearDown(c.dispose);
      c.listen(athleteCardProvider(key), (_, _) {});
      expect((await settled(c)).hasError, isTrue);

      fail = false;
      retryAthleteCard(c, key);

      expect((await settled(c)).value, hasLength(6));
      verify(() => results.getParticipants(competitionId)).called(2);
    });

    test('épreuves en échec, puis lues : la fiche se charge', () async {
      var fail = true;
      when(() => results.getEvents(any())).thenAnswer((_) async {
        if (fail) throw const NetworkException('hors ligne');
        return events;
      });
      final c = container();
      addTearDown(c.dispose);
      c.listen(athleteCardProvider(key), (_, _) {});
      expect((await settled(c)).hasError, isTrue);

      fail = false;
      retryAthleteCard(c, key);

      expect((await settled(c)).value, hasLength(6));
      verify(() => results.getEvents(competitionId)).called(2);
    });
    test('ne relit pas les classements des clubs', () async {
      var fail = true;
      when(() => results.getEvents(any())).thenAnswer((_) async {
        if (fail) throw const NetworkException('hors ligne');
        return events;
      });
      final c = container();
      addTearDown(c.dispose);
      c.listen(standingsProvider(competitionId), (_, _) {});
      c.listen(athleteCardProvider(key), (_, _) {});
      expect((await settled(c)).hasError, isTrue);
      clearInteractions(results);

      fail = false;
      retryAthleteCard(c, key);
      final races = (await settled(c)).value!;
      await pumpEventQueue();

      // Les épreuves de la fiche seulement, pas une lecture par épreuve.
      expect(
        verify(() => results.getEventSeries(captureAny())).captured.toSet(),
        {for (final race in races) race.event.id},
      );
    });
  });

  group('refreshAthleteCard', () {
    test('relit les classements de ses épreuves, ni participants ni '
        'épreuves', () async {
      const key = (competitionId: competitionId, participantId: 632572);
      final c = container();
      addTearDown(c.dispose);
      c.listen(athleteCardProvider(key), (_, _) {});
      final races = await c.read(athleteCardProvider(key).future);
      final eventIds = {for (final race in races) race.event.id};
      clearInteractions(results);

      await refreshAthleteCard(c, key);

      expect(c.read(athleteCardProvider(key)).value, hasLength(6));
      verifyNever(() => results.getEvents(any()));
      verifyNever(() => results.getParticipants(any()));
      for (final eventId in eventIds) {
        verify(() => results.getEventSeries(eventId)).called(1);
      }
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
      verify(() => meetings.getLanes(any())).called(1);
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
      final unread = heats[480]!.placeIds.first;
      lanes.remove(unread);
      final c = container();
      addTearDown(c.dispose);

      await expectLater(find(c), throwsA(isA<NetworkException>()));
      // Relue une fois avant d'abandonner.
      verify(() => meetings.getLanes([unread])).called(1);
    });

    test("une place illisible, l'athlète dans une course suivante", () async {
      programme = _withStatus(fixtureProgramme, (_) => RunStatus.waiting);
      allPlacesEmpty();
      lanes.remove(heats[479]!.placeIds.first);
      final second = heats[480]!;
      lanes[second.placeIds[1]] = lane(second.placeIds[1], 2, entry: entryId);
      final c = container();
      addTearDown(c.dispose);

      final found = await find(c);

      expect(found?.heat.id, 480);
      expect(found?.lane, 2);
    });

    test('une place illisible relue avec succès : trouvé', () async {
      programme = _withStatus(fixtureProgramme, (_) => RunStatus.waiting);
      allPlacesEmpty();
      final first = heats[479]!;
      final placeId = first.placeIds[4];
      lanes[placeId] = lane(placeId, 5, entry: entryId);
      flaky = {placeId};
      final c = container();
      addTearDown(c.dispose);

      final found = await find(c);

      expect(found?.heat.id, 479);
      expect(found?.lane, 5);
      verify(() => meetings.getLanes([placeId])).called(1);
    });
  });
}
