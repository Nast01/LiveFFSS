import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/network/http_client.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/ffss/dtos/epreuve_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/officiel_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/participant_dto.dart';
import 'package:live_ffss_v2/data/ffss/mappers/officiel_mapper.dart';
import 'package:live_ffss_v2/data/ffss/mappers/results_mapper.dart';
import 'package:live_ffss_v2/data/repositories/auth_repository.dart';
import 'package:live_ffss_v2/data/repositories/meeting_repository.dart';
import 'package:live_ffss_v2/data/repositories/officials_repository.dart';
import 'package:live_ffss_v2/data/repositories/results_repository.dart';
import 'package:live_ffss_v2/domain/account.dart';
import 'package:live_ffss_v2/domain/competition_roles.dart';
import 'package:live_ffss_v2/domain/my_space.dart';
import 'package:live_ffss_v2/domain/officials.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/features/auth/session.dart';
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
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        httpClientProvider.overrideWithValue(_MockHttpClient()),
        tokenStorageProvider.overrideWithValue(InMemoryTokenStorage()),
        localStoreProvider.overrideWithValue(InMemoryLocalStore()),
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

  Future<List<MySpaceCard>> cards() {
    final sub = container.listen(
      mySpaceCardsProvider(competitionId),
      (_, _) {},
    );
    addTearDown(sub.close);
    return container.read(mySpaceCardsProvider(competitionId).future);
  }

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

    test('participants en échec : Réessayer les relit', () async {
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

      await expectLater(cards(), throwsA(isA<NetworkException>()));

      when(
        () => results.getParticipants(any()),
      ).thenAnswer((_) async => participants);
      retryMySpaceCards(container, competitionId);

      expect(await cards(), [MySpaceCard.athlete(engaged)]);
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
}
