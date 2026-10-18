import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/network/http_client.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/ffss/dtos/deroulement_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/epreuve_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/participant_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/reunion_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/serie_results_dto.dart';
import 'package:live_ffss_v2/data/ffss/mappers/deroulement_mapper.dart';
import 'package:live_ffss_v2/data/ffss/mappers/results_mapper.dart';
import 'package:live_ffss_v2/data/ffss/mappers/reunion_mapper.dart';
import 'package:live_ffss_v2/data/repositories/auth_repository.dart';
import 'package:live_ffss_v2/data/repositories/meeting_repository.dart';
import 'package:live_ffss_v2/data/repositories/results_repository.dart';
import 'package:live_ffss_v2/domain/competition_roles.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/my_space.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/series_link.dart';
import 'package:live_ffss_v2/features/my_space/my_space_formatting.dart';
import 'package:live_ffss_v2/features/my_space/my_space_providers.dart';
import 'package:live_ffss_v2/features/results/athlete_providers.dart';
import 'package:live_ffss_v2/features/results/results_formatting.dart';
import 'package:live_ffss_v2/features/results/results_providers.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/fixtures.dart';

class _MockResultsRepository extends Mock implements ResultsRepository {}

class _MockMeetingRepository extends Mock implements MeetingRepository {}

class _MockHttpClient extends Mock implements HttpClient {}

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

void main() {
  const competitionId = 1416;
  const clubId = 99;
  final programme = _fixtureProgramme();
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
  final fixtureParticipants = [
    for (final row in _rows('participants_1416'))
      ?ParticipantDto.fromJson(row).toDomain(),
  ];
  Participant byId(int id) => fixtureParticipants.firstWhere((p) => p.id == id);

  // Un club fait pour l'ordre : ATHLETE N020, N028 et N022 ont couru 36073
  // (séries dans les fixtures) ; N020 est aussi engagé en 36074, sans
  // résultat : son tour séries (course 479) est au programme, avec une heure.
  final n020 = byId(632572).copyWith(
    clubId: clubId,
    entries: [
      const ParticipantEntry(
        entryId: 1,
        eventId: 36074,
        categoryName: 'Junior',
      ),
      ...byId(632572).entries,
    ],
  );
  final n028 = byId(633044).copyWith(clubId: clubId);
  final n022 = byId(630812).copyWith(clubId: clubId);
  final participants = [
    for (final p in fixtureParticipants)
      switch (p.id) {
        632572 => n020,
        633044 => n028,
        630812 => n022,
        _ => p,
      },
  ];

  late _MockResultsRepository results;
  late _MockMeetingRepository meetings;

  ProviderContainer container({List<Override> overrides = const []}) {
    final c = ProviderContainer(
      overrides: [
        resultsRepositoryProvider.overrideWithValue(results),
        meetingRepositoryProvider.overrideWithValue(meetings),
        clockProvider.overrideWithValue(() => DateTime(2026, 3, 27, 7)),
        ...overrides,
      ],
      retry: noRetry,
    );
    addTearDown(c.dispose);
    return c;
  }

  setUp(() {
    results = _MockResultsRepository();
    meetings = _MockMeetingRepository();
    when(() => meetings.getProgramme(any())).thenAnswer((_) async => programme);
    when(() => results.getEvents(any())).thenAnswer((_) async => events);
    when(() => results.getEventSeries(any())).thenAnswer(
      (invocation) async =>
          series[invocation.positionalArguments.first as int] ?? const [],
    );
    when(
      () => results.getParticipants(any()),
    ).thenAnswer((_) async => participants);
  });

  final flatWater = {for (final e in events) e.id};
  final club27Events = {
    for (final a in clubAthletes27(fixtureParticipants))
      for (final e in a.entries)
        if (flatWater.contains(e.eventId)) e.eventId,
  };

  /// Les séries lues à partir de maintenant, chacune un peu lente, et le
  /// plus de lectures en vol.
  _Reads countReads() {
    final reads = _Reads();
    var inFlight = 0;
    when(() => results.getEventSeries(any())).thenAnswer((invocation) async {
      final id = invocation.positionalArguments.first as int;
      reads.ids.add(id);
      inFlight++;
      if (inFlight > reads.peak) reads.peak = inFlight;
      await Future<void>.delayed(const Duration(milliseconds: 5));
      inFlight--;
      return series[id] ?? const [];
    });
    return reads;
  }

  Future<ClubSchedule> schedule(ProviderContainer c, int clubId) {
    final key = (competitionId: competitionId, clubId: clubId);
    final sub = c.listen(clubScheduleProvider(key), (_, _) {});
    addTearDown(sub.close);
    return c.read(clubScheduleProvider(key).future);
  }

  group('clubProvider', () {
    test('le libellé et les athlètes du club, par nom', () async {
      final c = container();
      const key = (competitionId: competitionId, clubId: 27);
      final sub = c.listen(clubProvider(key), (_, _) {});
      addTearDown(sub.close);

      final club = await c.read(clubProvider(key).future);

      expect(club.id, 27);
      expect(club.label, byId(631868).club);
      expect(club.athletes.map((a) => a.id), [
        for (final a in clubAthletes27(fixtureParticipants)) a.id,
      ]);
      expect(club.athletes, hasLength(6));
    });
  });

  group('clubScheduleProvider', () {
    test('à venir par heure, puis courues par épreuve et rang', () async {
      final c = container();

      final read = await schedule(c, clubId);
      final races = read.races;

      expect(read.failedAthletes, 0);
      final split = splitClubRaces(races);
      // À venir d'abord : 36074 (course 479, avec une heure) en tête.
      expect(split.toRun.first.race.event.id, 36074);
      expect(split.toRun.first.athletes, [n020]);
      expect(split.toRun.first.race.plannedStart, isNotNull);
      // Les autres à venir sont sans heure : après.
      expect(
        split.toRun.skip(1).map((r) => r.race.plannedStart),
        everyElement(isNull),
      );
      // Puis les courues, toutes de 36073, au rang.
      expect(races.indexOf(split.run.first), split.toRun.length);
      expect(split.run.map((r) => r.race.event.id), everyElement(36073));
      expect(split.run.map((r) => r.athletes.single.id).toSet(), {
        632572,
        633044,
        630812,
      });
      final ranks = [for (final r in split.run) r.race.row!.rank ?? 1 << 30];
      expect(ranks, [...ranks]..sort());
      // Chaque engagement une fois.
      final entries = [for (final r in races) r.race.entry.entryId];
      expect(entries.toSet(), hasLength(entries.length));
    });

    test('un relais : une ligne, ses relayeurs du club', () async {
      final c = container();

      final read = await schedule(c, 27);

      // 565685 : N060, N061 et N062 en 36087.
      final relay = read.races
          .where((r) => r.race.entry.entryId == 565685)
          .toList();
      expect(relay, hasLength(1));
      expect(relay.single.athletes.map((a) => a.id).toSet(), {
        631868,
        631869,
        631870,
      });
    });

    test("une fiche en échec n'empêche pas les autres", () async {
      final c = container(
        overrides: [
          athleteCardProvider((
            competitionId: competitionId,
            participantId: 633044,
          )).overrideWith(
            (ref) async => throw const NetworkException('hors ligne'),
          ),
        ],
      );

      final read = await schedule(c, clubId);

      expect(read.failedAthletes, 1);
      final athletes = {
        for (final r in read.races)
          for (final a in r.athletes) a.id,
      };
      expect(athletes, {632572, 630812});
    });

    test('6 classements au plus en vol, chacun lu une fois', () async {
      final reads = countReads();
      final c = container();

      await schedule(c, 27);

      expect(club27Events.length, greaterThan(6));
      expect(reads.peak, lessThanOrEqualTo(6));
      expect(reads.ids.toSet(), club27Events);
      expect(reads.ids.toSet(), hasLength(reads.ids.length));
    });

    test('rafraîchir : 6 au plus en vol aussi, chacun relu une fois', () async {
      final c = container();
      await schedule(c, 27);
      final reads = countReads();

      await refreshClubSchedule(c, (competitionId: competitionId, clubId: 27));

      expect(reads.peak, lessThanOrEqualTo(6));
      expect(reads.ids.toSet(), club27Events);
      expect(reads.ids.toSet(), hasLength(reads.ids.length));
    });

    test("le rafraîchissement des Épreuves ne relit pas les classements du "
        "club", () async {
      final c = container();
      // L'onglet Résultats écoute ses épreuves.
      final tab = c.listen(eventsProvider(competitionId), (_, _) {});
      addTearDown(tab.close);
      final before = await schedule(c, 27);
      final reads = countReads();

      await c.read(eventsProvider(competitionId).notifier).refresh();
      await pumpEventQueue();

      expect(reads.ids, isEmpty);
      const key = (competitionId: competitionId, clubId: 27);
      expect(c.read(clubScheduleProvider(key)).value, before);
    });

    test('rafraîchir relit les classements, pas les participants', () async {
      final c = container();
      const key = (competitionId: competitionId, clubId: clubId);
      // L'onglet Résultats garde ce classement : il est relu quand même.
      final tab = c.listen(
        eventRankingProvider((competitionId: competitionId, eventId: 36073)),
        (_, _) {},
      );
      addTearDown(tab.close);
      await schedule(c, clubId);
      clearInteractions(results);

      await refreshClubSchedule(c, key);

      verify(() => results.getEventSeries(36073)).called(1);
      verifyNever(() => results.getParticipants(any()));
    });

    test('participants en échec : Réessayer les relit', () async {
      when(
        () => results.getParticipants(any()),
      ).thenThrow(const NetworkException('hors ligne'));
      final c = container();
      await expectLater(schedule(c, clubId), throwsA(isA<NetworkException>()));

      when(
        () => results.getParticipants(any()),
      ).thenAnswer((_) async => participants);
      await refreshClubSchedule(c, (
        competitionId: competitionId,
        clubId: clubId,
      ));

      expect((await schedule(c, clubId)).races, isNotEmpty);
    });
  });

  group('forfaits du club', () {
    test('statut 2 ou complément F / FF des résultats publiés', () async {
      final c = container();
      final run = splitClubRaces((await schedule(c, clubId)).races).run;
      ClubRace withResult(
        ClubRace race, {
        int status = 0,
        String? complement,
      }) => race.copyWith(
        race: race.race.copyWith(
          row: race.race.row!.copyWith(
            result: race.race.row!.result.copyWith(
              status: status,
              complement: complement ?? '',
            ),
          ),
        ),
      );
      final forfeit = withResult(run[0], status: 2);
      final finalForfeit = withResult(run[1], complement: 'FF');
      final dq = withResult(run[2], status: 1, complement: '12');

      final forfeits = clubForfeits([forfeit, finalForfeit, dq]);

      expect(forfeits, [forfeit, finalForfeit]);
      expect(clubForfeits(run), isEmpty);
      expect(clubForfeits([withResult(run[0], complement: 'F')]), hasLength(1));
    });
  });

  group('étiquette du club', () {
    test('compte de test : référent du club 15 seulement', () async {
      final http = _MockHttpClient();
      when(
        () => http.get('competition/evenement/$competitionId/me'),
      ).thenAnswer((_) async => fixture('evenement_me_1416'));
      final roles = await AuthRepositoryImpl(
        http,
      ).competitionRoles(competitionId);

      expect(clubRole(roles, 15), ClubRole.referee);
      expect(clubRole(roles, 27), ClubRole.none);
      expect(clubRole(null, 15), ClubRole.none);
      expect(
        clubRole(const CompetitionRoles(roles: ['public', 'admin']), 27),
        ClubRole.admin,
      );
    });
  });

  group('espace athlète', () {
    test('la prochaine course : la plus tôt à courir de sa fiche', () async {
      final c = container();
      const key = (competitionId: competitionId, participantId: 632572);
      final sub = c.listen(athleteCardProvider(key), (_, _) {});
      addTearDown(sub.close);

      final races = await c.read(athleteCardProvider(key).future);
      final next = nextRace(races)!;

      expect(next.event.id, 36074);
      final heat = heatsRoundOf(
        programme,
        events.firstWhere((e) => e.id == 36074),
      ).first;
      expect(next.plannedStart, heat.plannedStart);
      final cells = nextRaceCells(next, null);
      expect(cells.time, athleteRaceTime(next));
      expect(cells.lane, '–');
    });
  });
}

class _Reads {
  final ids = <int>[];
  var peak = 0;
}

/// Les athlètes du club 27 de la fixture, dans l'ordre de `clubAthletes`.
List<Participant> clubAthletes27(List<Participant> participants) =>
    clubAthletes(participants, 27);
