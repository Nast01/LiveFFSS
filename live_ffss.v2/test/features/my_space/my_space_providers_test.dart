import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/network/http_client.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/ffss/dtos/deroulement_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/epreuve_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/officiel_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/participant_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/reunion_dto.dart';
import 'package:live_ffss_v2/data/ffss/mappers/deroulement_mapper.dart';
import 'package:live_ffss_v2/data/ffss/mappers/officiel_mapper.dart';
import 'package:live_ffss_v2/data/ffss/mappers/results_mapper.dart';
import 'package:live_ffss_v2/data/ffss/mappers/reunion_mapper.dart';
import 'package:live_ffss_v2/data/repositories/auth_repository.dart';
import 'package:live_ffss_v2/data/repositories/meeting_repository.dart';
import 'package:live_ffss_v2/data/repositories/officials_repository.dart';
import 'package:live_ffss_v2/data/repositories/results_repository.dart';
import 'package:live_ffss_v2/domain/account.dart';
import 'package:live_ffss_v2/domain/competition_roles.dart';
import 'package:live_ffss_v2/domain/follows.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/my_space.dart';
import 'package:live_ffss_v2/domain/officials.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/run_status.dart';
import 'package:live_ffss_v2/domain/series_link.dart';
import 'package:live_ffss_v2/features/auth/competition_roles.dart';
import 'package:live_ffss_v2/features/auth/session.dart';
import 'package:live_ffss_v2/features/follows/follows_providers.dart';
import 'package:live_ffss_v2/features/follows/reminder_records.dart';
import 'package:live_ffss_v2/features/my_space/my_space_formatting.dart';
import 'package:live_ffss_v2/features/my_space/my_space_providers.dart';
import 'package:live_ffss_v2/features/results/athlete_providers.dart';
import 'package:live_ffss_v2/features/results/results_providers.dart';
import 'package:live_ffss_v2/features/shell/active_competition.dart';
import 'package:live_ffss_v2/features/shell/current_competition.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/competitions.dart';
import '../../support/fixtures.dart';
import '../../support/in_memory_local_store.dart';
import '../../support/in_memory_token_storage.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockHttpClient extends Mock implements HttpClient {}

class _MockResultsRepository extends Mock implements ResultsRepository {}

class _MockMeetingRepository extends Mock implements MeetingRepository {}

class _MockOfficialsRepository extends Mock implements OfficialsRepository {}

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

/// Le programme où chaque course prend le statut que [status] lui donne.
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

const _testAccount = Account(label: 'ATHLETE Compte', type: 'licencie');
const _other = Account(label: 'MARTIN Paul', type: 'licencie');

void main() {
  const competitionId = 1416;
  final participants = [
    for (final row in _rows('participants_1416'))
      ?ParticipantDto.fromJson(row).toDomain(),
  ];
  final events = [
    for (final row in _rows('epreuves_1416'))
      ?EpreuveDto.fromJson(row).toDomain(),
  ];
  final officials = [
    for (final row in _rows('officiels_1416'))
      ?OfficielDto.fromJson(row).toDomain(),
  ];
  // Un licencié engagé de la fixture.
  final engaged = participants.firstWhere((p) => p.licenseeId != null);
  final summary = competition(
    competitionId,
    start: DateTime(2026, 3, 27),
    end: DateTime(2026, 3, 29),
  );

  late _MockAuthRepository auth;
  late _MockHttpClient http;
  late _MockResultsRepository results;
  late _MockMeetingRepository meetings;
  late _MockOfficialsRepository officialsRepository;
  late ProviderContainer container;
  late InMemoryLocalStore store;

  setUp(() {
    auth = _MockAuthRepository();
    http = _MockHttpClient();
    results = _MockResultsRepository();
    meetings = _MockMeetingRepository();
    officialsRepository = _MockOfficialsRepository();
    when(
      () => results.getParticipants(any()),
    ).thenAnswer((_) async => participants);
    when(() => results.getEvents(any())).thenAnswer((_) async => events);
    when(
      () => meetings.getProgramme(any()),
    ).thenAnswer((_) async => const Programme(meetings: []));
    when(
      () => officialsRepository.getOfficials(any()),
    ).thenAnswer((_) async => officials);
    // Le compte de test : les rôles de la recette, lus par le vrai mapper.
    when(
      () => http.get('competition/evenement/$competitionId/me'),
    ).thenAnswer((_) async => fixture('evenement_me_1416'));
    store = InMemoryLocalStore();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        httpClientProvider.overrideWithValue(_MockHttpClient()),
        tokenStorageProvider.overrideWithValue(InMemoryTokenStorage()),
        localStoreProvider.overrideWithValue(store),
        resultsRepositoryProvider.overrideWithValue(results),
        meetingRepositoryProvider.overrideWithValue(meetings),
        officialsRepositoryProvider.overrideWithValue(officialsRepository),
        currentCompetitionProvider.overrideWithValue(summary),
        clockProvider.overrideWithValue(() => DateTime(2026, 3, 27, 7)),
      ],
      retry: noRetry,
    );
    addTearDown(container.dispose);
  });

  Future<void> logIn(Account account) async {
    when(() => auth.requestToken(any(), any())).thenAnswer((_) async => 'abc');
    when(() => auth.me()).thenAnswer((_) async => account);
    await container.read(sessionProvider.future);
    await container.read(sessionProvider.notifier).login('login', 'secret');
  }

  void rolesOfTestAccount() => when(
    () => auth.competitionRoles(competitionId),
  ).thenAnswer((_) => AuthRepositoryImpl(http).competitionRoles(competitionId));

  Future<MySpaceCards> spaces() {
    final sub = container.listen(
      mySpaceCardsProvider(competitionId),
      (_, _) {},
    );
    addTearDown(sub.close);
    return container.read(mySpaceCardsProvider(competitionId).future);
  }

  Future<List<MySpaceCard>> cards() async => (await spaces()).cards;

  group('mySpaceCardsProvider', () {
    test('compte de test : Club 15 et Officiel, pas Athlète', () async {
      await logIn(_testAccount);
      rolesOfTestAccount();

      expect(await cards(), [
        const MySpaceCard.club(
          ClubRef(id: 15, label: "Les Dauphins du Frontonnais et de l'Union"),
        ),
        const MySpaceCard.official(
          OfficialRole(
            level: 'B',
            levelLabel: 'B - Juge de virage/obstacles',
            principal: false,
          ),
        ),
      ]);
      // Licencié 1326 : les participants sont lus pour le chercher.
      verify(() => results.getParticipants(competitionId)).called(1);
    });

    test('un licencié engagé : carte Athlète', () async {
      await logIn(_other);
      when(() => auth.competitionRoles(competitionId)).thenAnswer(
        (_) async => CompetitionRoles(
          roles: const ['public', 'licencie'],
          licenseeId: engaged.licenseeId,
        ),
      );

      expect(await cards(), [MySpaceCard.athlete(engaged)]);
    });

    test("admin : carte Admin, sans lire les participants", () async {
      await logIn(_other);
      when(() => auth.competitionRoles(competitionId)).thenAnswer(
        (_) async => const CompetitionRoles(roles: ['public', 'admin']),
      );

      expect(await cards(), [const MySpaceCard.admin()]);
      verifyNever(() => results.getParticipants(any()));
    });

    test('sans session : aucune carte', () async {
      expect(await cards(), isEmpty);
      verifyNever(() => auth.competitionRoles(any()));
      verifyNever(() => results.getParticipants(any()));
    });

    test('rôles en échec : erreur, puis Réessayer relit les rôles', () async {
      await logIn(_testAccount);
      when(
        () => auth.competitionRoles(competitionId),
      ).thenThrow(const NetworkException('hors ligne'));

      await expectLater(cards(), throwsA(isA<NetworkException>()));

      rolesOfTestAccount();
      retryMySpaceCards(container, competitionId);

      expect(await cards(), hasLength(2));
    });

    test(
      'participants en échec : Club et Officiel quand même, Athlète à relire',
      () async {
        await logIn(_testAccount);
        rolesOfTestAccount();
        when(
          () => results.getParticipants(any()),
        ).thenThrow(const NetworkException('hors ligne'));

        final partial = await spaces();
        expect(partial.cards, [
          const MySpaceCard.club(
            ClubRef(id: 15, label: "Les Dauphins du Frontonnais et de l'Union"),
          ),
          isA<OfficialSpaceCard>(),
        ]);
        expect(partial.athleteUnknown, isTrue);

        when(
          () => results.getParticipants(any()),
        ).thenAnswer((_) async => participants);
        retryMySpaceCards(container, competitionId);

        final read = await spaces();
        expect(read.athleteUnknown, isFalse);
        expect(read.cards, hasLength(2));
      },
    );

    test(
      'participants en échec, licencié engagé : Réessayer le retrouve',
      () async {
        await logIn(_other);
        when(() => auth.competitionRoles(competitionId)).thenAnswer(
          (_) async => CompetitionRoles(
            roles: const ['public', 'licencie'],
            licenseeId: engaged.licenseeId,
          ),
        );
        when(
          () => results.getParticipants(any()),
        ).thenThrow(const NetworkException('hors ligne'));

        expect((await spaces()).athleteUnknown, isTrue);

        when(
          () => results.getParticipants(any()),
        ).thenAnswer((_) async => participants);
        retryMySpaceCards(container, competitionId);

        expect(await cards(), [MySpaceCard.athlete(engaged)]);
      },
    );

    group("l'athlète connecté gardé pour les rappels", () {
      const key = 'reminder_self_$competitionId';

      Future<void> engagedAccount() async {
        await logIn(_other);
        when(() => auth.competitionRoles(competitionId)).thenAnswer(
          (_) async => CompetitionRoles(
            roles: const ['public', 'licencie'],
            licenseeId: engaged.licenseeId,
          ),
        );
        await cards();
        // Enregistré sans être attendu, une fois sa première lecture finie.
        await pumpEventQueue();
      }

      Future<FollowedAthlete?> self() {
        final sub = container.listen(
          selfAthleteProvider(competitionId),
          (_, _) {},
        );
        addTearDown(sub.close);
        return container.read(selfAthleteProvider(competitionId).future);
      }

      test('la carte Athlète l’enregistre, avec son compte', () async {
        await engagedAccount();

        expect(store.values[key], contains('"account":"${_other.label}"'));
        final athlete = await self();
        expect(athlete?.participantId, engaged.id);
        expect(athlete?.eventIds, {
          for (final entry in engaged.entries) entry.eventId,
        });
      });

      test('déconnexion : effacé', () async {
        await engagedAccount();
        expect(await self(), isNotNull);

        await container.read(sessionProvider.notifier).logout();

        expect(await self(), isNull);
        expect(store.values.containsKey(key), isFalse);
      });

      test('un compte non engagé : effacé', () async {
        await engagedAccount();
        when(() => auth.competitionRoles(competitionId)).thenAnswer(
          (_) async => const CompetitionRoles(roles: ['public', 'admin']),
        );
        container.invalidate(competitionRolesProvider(competitionId));

        await cards();
        await pumpEventQueue();

        expect(store.values.containsKey(key), isFalse);
      });

      test('participants en échec : gardé', () async {
        await engagedAccount();
        when(
          () => results.getParticipants(any()),
        ).thenThrow(const NetworkException('hors ligne'));
        container.invalidate(participantsProvider(competitionId));
        container.invalidate(mySpaceCardsProvider(competitionId));

        expect((await spaces()).athleteUnknown, isTrue);
        expect(store.values.containsKey(key), isTrue);
      });
    });

    test('changement de compte : cartes recalculées', () async {
      await logIn(_testAccount);
      rolesOfTestAccount();
      expect(await cards(), hasLength(2));

      await container.read(sessionProvider.notifier).logout();
      expect(await cards(), isEmpty);

      when(() => auth.competitionRoles(competitionId)).thenAnswer(
        (_) async => const CompetitionRoles(roles: ['public', 'admin']),
      );
      await logIn(_other);
      expect(await cards(), [const MySpaceCard.admin()]);
    });

    test("pendant la relecture d'un autre compte : en chargement, jamais "
        "l'ancien", () async {
      await logIn(_testAccount);
      rolesOfTestAccount();
      expect(await cards(), hasLength(2));

      final pending = Completer<CompetitionRoles>();
      when(
        () => auth.competitionRoles(competitionId),
      ).thenAnswer((_) => pending.future);
      await logIn(_other);

      final state = container.read(mySpaceCardsProvider(competitionId));
      expect(
        spacesView(
          loading: state.isLoading,
          failed: state.hasError,
          cards: state.value,
        ),
        const SpacesLoading(),
      );

      pending.complete(const CompetitionRoles(roles: ['public', 'admin']));
      expect(await cards(), [const MySpaceCard.admin()]);
    });
  });

  group('mySpaceCards', () {
    test("l'ordre : athlète, clubs, officiel, admin", () {
      final roles = CompetitionRoles(
        roles: const ['public', 'licencie', 'officiel', 'admin'],
        licenseeId: engaged.licenseeId,
        official: const OfficialRole(
          level: 'A',
          levelLabel: 'A',
          principal: true,
        ),
        refereeClubs: const [
          ClubRef(id: 15, label: 'Quinze'),
          ClubRef(id: 16, label: 'Seize'),
        ],
      );

      expect(mySpaceCards(roles, participants), [
        MySpaceCard.athlete(engaged),
        const MySpaceCard.club(ClubRef(id: 15, label: 'Quinze')),
        const MySpaceCard.club(ClubRef(id: 16, label: 'Seize')),
        const MySpaceCard.official(
          OfficialRole(level: 'A', levelLabel: 'A', principal: true),
        ),
        const MySpaceCard.admin(),
      ]);
    });

    test("officiel sans détail : la carte quand même", () {
      expect(
        mySpaceCards(
          const CompetitionRoles(roles: ['public', 'officiel']),
          const [],
        ),
        [const MySpaceCard.official(null)],
      );
    });
  });

  group('competitionInfoProvider', () {
    Future<CompetitionInfo> info() {
      final sub = container.listen(
        competitionInfoProvider(competitionId),
        (_, _) {},
      );
      addTearDown(sub.close);
      return container.read(competitionInfoProvider(competitionId).future);
    }

    test('la compétition, ses athlètes, ses clubs, ses épreuves', () async {
      final read = await info();
      final flatWater = await container.read(
        eventsProvider(competitionId).future,
      );

      expect(read.competition, summary);
      expect(read.athletes, participants.length);
      expect(read.clubs, competitionClubs(participants));
      expect(read.clubs, isNotEmpty);
      expect(read.events, flatWater.length);
      expect(read.events, greaterThan(0));
    });

    test("une autre compétition que l'active : relue par son id", () async {
      final other = competition(1453, start: DateTime(2026, 4, 1));
      container = ProviderContainer(
        overrides: [
          resultsRepositoryProvider.overrideWithValue(results),
          meetingRepositoryProvider.overrideWithValue(meetings),
          currentCompetitionProvider.overrideWithValue(summary),
          competitionByIdProvider(1453).overrideWith((ref) async => other),
        ],
        retry: noRetry,
      );
      addTearDown(container.dispose);
      final sub = container.listen(competitionInfoProvider(1453), (_, _) {});
      addTearDown(sub.close);

      expect(
        (await container.read(
          competitionInfoProvider(1453).future,
        )).competition,
        other,
      );
    });

    test('participants en échec : Réessayer les relit', () async {
      when(
        () => results.getParticipants(any()),
      ).thenThrow(const NetworkException('hors ligne'));
      await expectLater(info(), throwsA(isA<NetworkException>()));

      when(
        () => results.getParticipants(any()),
      ).thenAnswer((_) async => participants);
      retryCompetitionInfo(container, competitionId);

      expect((await info()).athletes, participants.length);
    });

    test('participants gardés : la liste des clubs ne les relit pas', () async {
      await info();
      container.invalidate(competitionInfoProvider(competitionId));
      await info();

      verify(() => results.getParticipants(competitionId)).called(1);
      expect(
        container.exists(participantsKeeperProvider(competitionId)),
        isTrue,
      );
    });
  });

  group('officialsProvider', () {
    test('les officiels groupés, juge principal en tête', () async {
      final sub = container.listen(officialsProvider(competitionId), (_, _) {});
      addTearDown(sub.close);

      final groups = await container.read(
        officialsProvider(competitionId).future,
      );

      // Un record compare ses listes par identité : on compare leur contenu.
      List<String> shape(List<OfficialGroup> g) => [
        for (final group in g)
          '${group.label}: ${[for (final o in group.officials) o.id]}',
      ];
      expect(shape(groups), shape(groupOfficials(officials)));
      expect(groups.first.label, isNull);
      expect(
        groups.fold<int>(0, (n, g) => n + g.officials.length),
        officials.length,
      );
      verify(() => officialsRepository.getOfficials(competitionId)).called(1);
    });

    test('en échec : relu par invalidate', () async {
      when(
        () => officialsRepository.getOfficials(any()),
      ).thenThrow(const NetworkException('hors ligne'));
      final sub = container.listen(officialsProvider(competitionId), (_, _) {});
      addTearDown(sub.close);
      await expectLater(
        container.read(officialsProvider(competitionId).future),
        throwsA(isA<NetworkException>()),
      );

      when(
        () => officialsRepository.getOfficials(any()),
      ).thenAnswer((_) async => <CompetitionOfficial>[]);
      container.invalidate(officialsProvider(competitionId));

      expect(
        await container.read(officialsProvider(competitionId).future),
        isEmpty,
      );
    });
  });

  group('prochaine course des athlètes suivis', () {
    final programme = _fixtureProgramme();
    final event36074 = events.firstWhere((e) => e.id == 36074);
    final heats36073 = heatsRoundOf(
      programme,
      events.firstWhere((e) => e.id == 36073),
    );
    final heats36074 = heatsRoundOf(programme, event36074);
    FollowedAthlete followed(List<int> eventIds) => FollowedAthlete(
      participantId: 1,
      name: 'Un ATHLETE',
      eventIds: eventIds,
    );

    test('le tour séries en cours : sa première course non terminée', () {
      expect(heats36073, isNotEmpty);
      final waiting = _withStatus(programme, (_) => RunStatus.waiting);
      final firstDone = _withStatus(
        programme,
        (heat) => heat.id == heats36073.first.id
            ? RunStatus.finished
            : RunStatus.waiting,
      );

      final next = followedNextRace(followed([36073]), events, waiting);
      expect(next?.event.id, 36073);
      expect(next?.start, heats36073.first.plannedStart);

      if (heats36073.length > 1) {
        expect(
          followedNextRace(followed([36073]), events, firstDone)?.start,
          heats36073[1].plannedStart,
        );
      }
    });

    test('ses épreuves sans tour séries écartées, terminées aussi', () {
      // La fixture n'a qu'un tour séries (479, 480), partagé par 36073-36075 :
      // 36087 n'en a pas au programme.
      final waiting = _withStatus(programme, (_) => RunStatus.waiting);
      expect(
        heatsRoundOf(programme, events.firstWhere((e) => e.id == 36087)),
        isEmpty,
      );
      final next = followedNextRace(followed([36087, 36074]), events, waiting);
      expect(next?.event.id, 36074);
      expect(next?.start, heats36074.first.plannedStart);

      final allDone = _withStatus(programme, (_) => RunStatus.finished);
      expect(
        followedNextRace(followed([36073, 36074]), events, allDone),
        isNull,
      );
    });

    test('une épreuve inconnue ou sans tour séries : rien', () {
      expect(followedNextRace(followed([999]), events, programme), isNull);
      expect(followedNextRace(followed(const []), events, programme), isNull);
    });

    test(
      'le fournisseur lit le programme et les épreuves, ni séries ni participants',
      () async {
        final store = InMemoryLocalStore()
          ..values['follows_$competitionId'] =
              '{"athletes":['
              '{"participantId":1,"name":"Un","entryIds":[5],'
              '"eventIds":[36073]},'
              '{"participantId":2,"name":"Deux","club":"C","entryIds":[6]}'
              '],"clubs":[]}';
        final waiting = _withStatus(programme, (_) => RunStatus.waiting);
        when(
          () => meetings.getProgramme(any()),
        ).thenAnswer((_) async => waiting);
        container = ProviderContainer(
          overrides: [
            localStoreProvider.overrideWithValue(store),
            resultsRepositoryProvider.overrideWithValue(results),
            meetingRepositoryProvider.overrideWithValue(meetings),
          ],
          retry: noRetry,
        );
        addTearDown(container.dispose);
        final sub = container.listen(
          followedRacesProvider(competitionId),
          (_, _) {},
        );
        addTearDown(sub.close);

        final races = await container.read(
          followedRacesProvider(competitionId).future,
        );

        expect(races[1]?.event.id, 36073);
        // Suivi sans épreuves (enregistré avant) : pas de ligne, son club.
        expect(races.containsKey(2), isFalse);
        verifyNever(() => results.getEventSeries(any()));
        verifyNever(() => results.getParticipants(any()));
        expect(container.read(followsProvider(competitionId)).hasValue, isTrue);
      },
    );
  });
}
