import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/network/network_log.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/repositories/results_repository.dart';
import 'package:live_ffss_v2/domain/account.dart';
import 'package:live_ffss_v2/domain/competition_roles.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/domain/discipline.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/features/admin/admin_providers.dart';
import 'package:live_ffss_v2/features/auth/admin.dart';
import 'package:live_ffss_v2/features/auth/competition_roles.dart';
import 'package:live_ffss_v2/features/auth/session.dart';
import 'package:live_ffss_v2/features/my_space/official_space_providers.dart';
import 'package:live_ffss_v2/features/shell/space_competition.dart';
import 'package:mocktail/mocktail.dart';

class _MockResultsRepository extends Mock implements ResultsRepository {}

/// Une session qu'on change en cours de test : connexion, déconnexion.
class _FakeSession extends SessionNotifier {
  _FakeSession(this._account);

  final Account? _account;

  @override
  Future<Account?> build() async => _account;

  void set(Account? account) => state = AsyncData(account);
}

const _competition = 1416;
const _admin = Account(
  label: 'ORGANISME TEST',
  type: 'organisme',
  role: 'admin',
);
const _licensee = Account(label: 'DUPONT Jean', type: 'licencie', role: 'user');

const _decisions = (
  events: <EventDecisions>[],
  unreadEvents: 2,
  entries: <int, ({CompetitionEvent event, EventResult result})>{},
);

CompetitionSummary _summary(Set<Discipline> disciplines) => CompetitionSummary(
  id: _competition,
  name: 'Championnat',
  startDate: DateTime(2026, 10, 18),
  endDate: DateTime(2026, 10, 19),
  disciplines: disciplines,
);

void main() {
  late _MockResultsRepository results;
  late _FakeSession session;
  late List<String> competitionRoles;
  late int rolesReads;
  late bool rolesFail;
  late int decisionsReads;
  late Set<Discipline> disciplines;
  late NetworkLogStore log;

  setUp(() {
    results = _MockResultsRepository();
    competitionRoles = const ['public'];
    rolesReads = 0;
    rolesFail = false;
    decisionsReads = 0;
    disciplines = const {Discipline.flatWater};
    log = NetworkLogStore();
    when(() => results.getParticipants(any())).thenAnswer(
      (_) async => const [
        Participant(
          id: 1,
          firstName: 'Un',
          lastName: 'ATHLETE',
          club: 'TOULON',
          clubId: 15,
        ),
        Participant(
          id: 2,
          firstName: 'Deux',
          lastName: 'ATHLETE',
          club: 'ANTIBES',
          clubId: 16,
        ),
        Participant(
          id: 3,
          firstName: 'Trois',
          lastName: 'ATHLETE',
          club: 'TOULON',
          clubId: 15,
        ),
      ],
    );
  });

  ProviderContainer container(
    Account? account, {
    List<Override> overrides = const [],
  }) {
    session = _FakeSession(account);
    final c = ProviderContainer(
      overrides: [
        sessionProvider.overrideWith(() => session),
        resultsRepositoryProvider.overrideWithValue(results),
        competitionRolesProvider.overrideWith((ref, id) async {
          rolesReads++;
          await ref.watch(sessionProvider.future);
          if (rolesFail) throw const NetworkException('hors ligne');
          return CompetitionRoles(roles: competitionRoles);
        }),
        officialDecisionsProvider.overrideWith((ref, id) async {
          decisionsReads++;
          return _decisions;
        }),
        spaceCompetitionProvider.overrideWith(
          (ref, id) async => _summary(disciplines),
        ),
        networkLogStoreProvider.overrideWithValue(log),
        ...overrides,
      ],
      retry: noRetry,
    );
    addTearDown(c.dispose);
    return c;
  }

  Future<T> read<T>(ProviderContainer c, ProviderListenable<Future<T>> p) {
    final sub = c.listen(p, (_, _) {});
    addTearDown(sub.close);
    return sub.read();
  }

  group('adminAccessProvider', () {
    test('admin du compte (/me) : oui, sans lire les rôles, même sans '
        'compétition', () async {
      final c = container(_admin);

      expect(await read(c, adminAccessProvider(null).future), isTrue);
      expect(await read(c, adminAccessProvider(_competition).future), isTrue);
      expect(rolesReads, 0);
    });

    test('admin de la compétition seulement : oui sur elle', () async {
      competitionRoles = const ['public', 'admin'];
      final c = container(_licensee);

      expect(await read(c, adminAccessProvider(_competition).future), isTrue);
      expect(await read(c, adminAccessProvider(null).future), isFalse);
    });

    test('licencié, ou personne de connecté : non', () async {
      competitionRoles = const ['public', 'licencie', 'officiel'];
      expect(
        await read(
          container(_licensee),
          adminAccessProvider(_competition).future,
        ),
        isFalse,
      );
      expect(
        await read(container(null), adminAccessProvider(_competition).future),
        isFalse,
      );
    });

    test('rôles en échec : non', () async {
      competitionRoles = const ['public', 'admin'];
      rolesFail = true;
      final c = container(_licensee);

      expect(await read(c, adminAccessProvider(_competition).future), isFalse);
    });
  });

  group('adminDecisionsProvider', () {
    test('admin : les DQ et forfaits de la compétition', () async {
      final c = container(_admin);

      expect(
        await read(c, adminDecisionsProvider(_competition).future),
        _decisions,
      );
      expect(decisionsReads, 1);
    });

    test('compte non admin : refusé, rien de lu', () async {
      final c = container(_licensee);

      await expectLater(
        read(c, adminDecisionsProvider(_competition).future),
        throwsA(isA<AdminOnlyException>()),
      );
      expect(decisionsReads, 0);
    });

    test('sans session : refusé', () async {
      final c = container(null);

      await expectLater(
        read(c, adminDecisionsProvider(_competition).future),
        throwsA(isA<AdminOnlyException>()),
      );
      expect(decisionsReads, 0);
    });

    test('déconnexion : refusé aussitôt', () async {
      final c = container(_admin);
      final sub = c.listen(adminDecisionsProvider(_competition), (_, _) {});
      addTearDown(sub.close);
      await c.read(adminDecisionsProvider(_competition).future);

      session.set(null);

      await expectLater(
        c.read(adminDecisionsProvider(_competition).future),
        throwsA(isA<AdminOnlyException>()),
      );
    });

    test('compétition côtière : rien de lu, liste vide', () async {
      final c = ProviderContainer(
        overrides: [
          sessionProvider.overrideWith(() => _FakeSession(_admin)),
          resultsRepositoryProvider.overrideWithValue(results),
          spaceCompetitionProvider.overrideWith(
            (ref, id) async => _summary({Discipline.coastal}),
          ),
        ],
        retry: noRetry,
      );
      addTearDown(c.dispose);

      final read0 = await read(c, adminDecisionsProvider(_competition).future);

      expect(read0.events, isEmpty);
      verifyNever(() => results.getEvents(any()));
      verifyNever(() => results.getEventSeries(any()));
    });
  });

  group('adminClubsProvider', () {
    test('admin : les clubs engagés, par libellé', () async {
      final c = container(_admin);

      final clubs = await read(c, adminClubsProvider(_competition).future);

      expect(clubs, [
        (id: 16, label: 'ANTIBES', athletes: 1),
        (id: 15, label: 'TOULON', athletes: 2),
      ]);
    });

    test('compte non admin : refusé, participants non lus', () async {
      final c = container(_licensee);

      await expectLater(
        read(c, adminClubsProvider(_competition).future),
        throwsA(isA<AdminOnlyException>()),
      );
      verifyNever(() => results.getParticipants(any()));
    });

    test('participants en échec : « Réessayer » les relit', () async {
      when(
        () => results.getParticipants(any()),
      ).thenThrow(const NetworkException('hors ligne'));
      final c = container(_admin);
      final sub = c.listen(adminClubsProvider(_competition), (_, _) {});
      addTearDown(sub.close);
      await expectLater(
        c.read(adminClubsProvider(_competition).future),
        throwsA(isA<NetworkException>()),
      );
      when(() => results.getParticipants(any())).thenAnswer((_) async => []);

      retryAdminClubs(c, _competition);

      expect(await c.read(adminClubsProvider(_competition).future), isEmpty);
    });

    test('admin de la compétition seulement : les clubs', () async {
      competitionRoles = const ['public', 'admin'];
      final c = container(_licensee);

      expect(
        await read(c, adminClubsProvider(_competition).future),
        hasLength(2),
      );
    });

    test('déconnexion : refusé aussitôt', () async {
      final c = container(_admin);
      final sub = c.listen(adminClubsProvider(_competition), (_, _) {});
      addTearDown(sub.close);
      await c.read(adminClubsProvider(_competition).future);

      session.set(null);

      await expectLater(
        c.read(adminClubsProvider(_competition).future),
        throwsA(isA<AdminOnlyException>()),
      );
    });

    test('compétition côtière : rien de lu, liste vide', () async {
      disciplines = const {Discipline.coastal};
      final c = container(_admin);

      expect(await read(c, adminClubsProvider(_competition).future), isEmpty);
      verifyNever(() => results.getParticipants(any()));
    });
  });

  group('adminNetworkLogProvider', () {
    NetworkLogEntry entry(String path) => NetworkLogEntry(
      at: DateTime(2026, 10, 19),
      method: 'GET',
      path: path,
      duration: Duration.zero,
      server: 'Recette',
    );

    test('admin : le journal, suivi', () async {
      log.add(entry('/a'));
      final c = container(_admin);
      final sub = c.listen(adminNetworkLogProvider(_competition), (_, _) {});
      addTearDown(sub.close);

      expect(
        (await c.read(
          adminNetworkLogProvider(_competition).future,
        )).map((e) => e.path),
        ['/a'],
      );
      log.add(entry('/b'));
      expect(
        (await c.read(
          adminNetworkLogProvider(_competition).future,
        )).map((e) => e.path),
        ['/b', '/a'],
      );
    });

    test('compte non admin, ou déconnexion : refusé', () async {
      log.add(entry('/a'));
      await expectLater(
        read(
          container(_licensee),
          adminNetworkLogProvider(_competition).future,
        ),
        throwsA(isA<AdminOnlyException>()),
      );

      final c = container(_admin);
      final sub = c.listen(adminNetworkLogProvider(null), (_, _) {});
      addTearDown(sub.close);
      await c.read(adminNetworkLogProvider(null).future);
      session.set(null);
      await expectLater(
        c.read(adminNetworkLogProvider(null).future),
        throwsA(isA<AdminOnlyException>()),
      );
    });
  });
}
