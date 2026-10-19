import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/config/app_environment.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/network/network_log.dart';
import 'package:live_ffss_v2/core/notifications/reminder_scheduler.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/domain/account.dart';
import 'package:live_ffss_v2/domain/competition_roles.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/domain/discipline.dart';
import 'package:live_ffss_v2/domain/outbox.dart';
import 'package:live_ffss_v2/domain/race_result.dart';
import 'package:live_ffss_v2/features/admin/maintenance_providers.dart';
import 'package:live_ffss_v2/features/auth/competition_roles.dart';
import 'package:live_ffss_v2/features/auth/session.dart';
import 'package:live_ffss_v2/features/follows/follows_providers.dart';
import 'package:live_ffss_v2/features/officiel/outbox_service.dart';
import 'package:live_ffss_v2/features/officiel/outbox_store.dart';
import 'package:live_ffss_v2/features/reminders/reminders_providers.dart';
import 'package:live_ffss_v2/features/settings/reminder_lead.dart';
import 'package:live_ffss_v2/features/shell/space_competition.dart';

import '../../support/in_memory_local_store.dart';
import '../../support/in_memory_token_storage.dart';

class _FakeSession extends SessionNotifier {
  _FakeSession(this._account);

  final Account? _account;

  @override
  Future<Account?> build() async => _account;
}

/// Un stockage dont les écritures attendent [gate], et dont la file d'envoi
/// est illisible si [outboxFails].
class _Store extends InMemoryLocalStore {
  Completer<void>? gate;
  bool outboxFails = false;

  @override
  Future<String?> read(String key) async {
    if (outboxFails && key == OutboxStore.storageKey) {
      throw const StorageException('illisible');
    }
    return super.read(key);
  }

  @override
  Future<void> write(String key, String value) async {
    await gate?.future;
    return super.write(key, value);
  }
}

class _FakeOutbox extends OutboxService {
  _FakeOutbox(this._initial);

  final List<OutboxOperation> _initial;

  @override
  List<OutboxOperation> build() => _initial;
}

class _FakeReminders extends RemindersNotifier {
  _FakeReminders(super.competitionId, this._reminders);

  final List<Reminder> _reminders;

  @override
  Future<List<Reminder>> build() async => _reminders;
}

class _FakeScheduler implements ReminderScheduler {
  bool permitted = true;
  bool failing = false;
  final List<Reminder> shown = [];

  @override
  Future<bool> isPermitted() async => permitted;

  @override
  Future<bool> requestPermission() async => permitted;

  final List<List<Reminder>> replaced = [];

  @override
  Future<void> replaceAll(List<Reminder> reminders) async =>
      replaced.add(reminders);

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> show(Reminder reminder) async {
    if (failing) throw const UnknownException('plateforme');
    shown.add(reminder);
  }
}

const _competition = 1416;
const _admin = Account(
  label: 'ORGANISME SECRET',
  type: 'organisme',
  role: 'admin',
);
const _licensee = Account(label: 'ATHLETE Un', type: 'licencie', role: 'user');
final _now = DateTime(2026, 10, 19, 14, 30, 5);

OutboxOperation _op(String id, OutboxState state) => OutboxOperation(
  id: id,
  account: 'ATHLETE Deux',
  competitionId: _competition,
  // Une place par saisie : deux en attente sur la même se fondraient.
  placeId: id.codeUnitAt(0),
  seriesId: 2,
  entryId: 3,
  change: const ResultChange(mark: ResultMark.forfeit),
  state: state,
);

void main() {
  late _Store store;
  late _FakeScheduler scheduler;
  late NetworkLogStore log;
  late InMemoryTokenStorage tokens;
  late List<AppEnvironment> restarts;

  setUp(() {
    store = _Store();
    scheduler = _FakeScheduler();
    log = NetworkLogStore();
    tokens = InMemoryTokenStorage()..token = 'jeton-secret-123';
    restarts = [];
  });

  ProviderContainer container({
    Account? account = _admin,
    bool supported = true,
    List<OutboxOperation> queue = const [],
    List<Override> overrides = const [],
  }) {
    final c = ProviderContainer(
      overrides: [
        sessionProvider.overrideWith(() => _FakeSession(account)),
        localStoreProvider.overrideWithValue(store),
        tokenStorageProvider.overrideWithValue(tokens),
        reminderSchedulerProvider.overrideWithValue(scheduler),
        remindersSupportedProvider.overrideWithValue(supported),
        networkLogStoreProvider.overrideWithValue(log),
        launchEnvironmentProvider.overrideWithValue(AppEnvironment.development),
        serverRestartProvider.overrideWithValue(restarts.add),
        outboxProvider.overrideWith(() => _FakeOutbox(queue)),
        clockProvider.overrideWithValue(() => _now),
        competitionRolesProvider.overrideWith(
          (ref, id) async => const CompetitionRoles(roles: ['public']),
        ),
        spaceCompetitionProvider.overrideWith(
          (ref, id) async => CompetitionSummary(
            id: id,
            name: 'Championnat de France',
            startDate: DateTime(2026, 3, 27),
            endDate: DateTime(2026, 3, 29),
            disciplines: const {Discipline.flatWater},
          ),
        ),
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

  group('clearCompetitionData', () {
    void seed() {
      store.values.addAll({
        'follows_1416': '{"athletes":[],"clubs":[{"id":15,"label":"TOULON"}]}',
        'known_heats_1416': '[]',
        'reminder_self_1416': '{}',
        'entry_lane_filter_1416': '4',
        'follows_99': '{}',
        'known_heats_99': '[]',
        'outbox': '[]',
        'outbox_backups': '[]',
        'session_account': 'ORGANISME SECRET',
        'session_role': 'admin',
        'active_competition': '1416',
        'favorite_competitions': '[1416]',
      });
    }

    test('efface les données de la compétition, rien d\'autre', () async {
      seed();
      final c = container();

      expect(await clearCompetitionData(c, _competition), isTrue);

      expect(
        store.values.keys,
        unorderedEquals([
          'follows_99',
          'known_heats_99',
          'outbox',
          'outbox_backups',
          'session_account',
          'session_role',
          'active_competition',
          'favorite_competitions',
        ]),
      );
      expect(tokens.token, 'jeton-secret-123');
    });

    test('les suivis en mémoire repartent de rien', () async {
      seed();
      final c = container();
      final follows = await read(c, followsProvider(_competition).future);
      expect(follows.clubs, hasLength(1));

      await clearCompetitionData(c, _competition);

      expect(
        (await read(c, followsProvider(_competition).future)).clubs,
        isEmpty,
      );
    });

    test('une écriture des suivis en cours est attendue : elle ne revient '
        'pas après l\'effacement', () async {
      seed();
      final c = container();
      await read(c, followsProvider(_competition).future);
      store.gate = Completer<void>();
      final toggled = c
          .read(followsProvider(_competition).notifier)
          .toggleClub(16, 'ANTIBES');
      await pumpEventQueue();

      final clearing = clearCompetitionData(c, _competition);
      await pumpEventQueue();
      store.gate!.complete();
      store.gate = null;
      await toggled;
      expect(await clearing, isTrue);

      expect(store.values.containsKey('follows_1416'), isFalse);
      expect(
        (await read(c, followsProvider(_competition).future)).clubs,
        isEmpty,
      );
    });

    test('les clés effacées', () {
      expect(competitionLocalKeys(_competition), [
        'follows_1416',
        'known_heats_1416',
        'reminder_self_1416',
        'entry_lane_filter_1416',
      ]);
    });

    test('compte non admin : refusé, rien d\'effacé', () async {
      seed();
      final c = container(account: _licensee);

      await expectLater(
        clearCompetitionData(c, _competition),
        throwsA(isA<AdminOnlyException>()),
      );
      expect(store.values, hasLength(12));
    });
  });

  group('forceReload', () {
    test('relance l\'app sur le même serveur', () async {
      final c = container();

      await forceReload(c, _competition);

      expect(restarts, [AppEnvironment.development]);
    });

    test('compte non admin : refusé', () async {
      final c = container(account: _licensee);

      await expectLater(
        forceReload(c, _competition),
        throwsA(isA<AdminOnlyException>()),
      );
      expect(restarts, isEmpty);
    });
  });

  group('sendTestNotification', () {
    Future<TestNotificationOutcome> send(ProviderContainer c) =>
        sendTestNotification(c, _competition, title: 'Test', body: 'Corps');

    test('montrée tout de suite par le planificateur', () async {
      final c = container();

      expect(await send(c), TestNotificationOutcome.sent);

      expect(scheduler.shown, hasLength(1));
      expect(scheduler.shown.single.id, testReminderId);
      expect(scheduler.shown.single.title, 'Test');
      expect(scheduler.shown.single.at, _now);
    });

    test('hors Android : rien', () async {
      final c = container(supported: false);

      expect(await send(c), TestNotificationOutcome.unsupported);
      expect(scheduler.shown, isEmpty);
    });

    test('sans permission : rien, et dit', () async {
      scheduler.permitted = false;
      final c = container();

      expect(await send(c), TestNotificationOutcome.notPermitted);
      expect(scheduler.shown, isEmpty);
    });

    test('plateforme en échec : dit', () async {
      scheduler.failing = true;
      final c = container();

      expect(await send(c), TestNotificationOutcome.failed);
    });

    test('compte non admin : refusé', () async {
      final c = container(account: _licensee);

      await expectLater(send(c), throwsA(isA<AdminOnlyException>()));
      expect(scheduler.shown, isEmpty);
    });

    test('l\'id de test n\'est celui d\'aucun rappel', () {
      // `reminderId` est pris modulo 0x7fffffff.
      expect(testReminderId, 0x7fffffff);
    });
  });

  group('plannedRemindersProvider', () {
    final reminders = [
      Reminder(id: 1, at: _now, title: 'ATHLETE Un : départ', body: 'b'),
    ];

    test('les rappels planifiés de la compétition', () async {
      final c = container(
        overrides: [
          remindersProvider(
            _competition,
          ).overrideWith(() => _FakeReminders(_competition, reminders)),
        ],
      );
      // Les rappels de la compétition des onglets, que l'app écoute.
      c.listen(remindersProvider(_competition), (_, _) {});

      expect(
        await read(c, plannedRemindersProvider(_competition).future),
        reminders,
      );
    });

    test('aucun rappel en cours pour la compétition : rien, et rien de '
        'planifié pour autant', () async {
      final c = container();

      expect(
        await read(c, plannedRemindersProvider(_competition).future),
        isEmpty,
      );
      expect(c.exists(remindersProvider(_competition)), isFalse);
      expect(scheduler.replaced, isEmpty);
    });

    test('compte non admin : refusé', () async {
      final c = container(account: _licensee);

      await expectLater(
        read(c, plannedRemindersProvider(_competition).future),
        throwsA(isA<AdminOnlyException>()),
      );
    });
  });

  group('diagnosticReportProvider', () {
    test('serveur, compétition, rôle, file et erreurs ; ni jeton, ni nom, '
        'ni chaîne de requête', () async {
      log
        ..add(
          NetworkLogEntry(
            at: _now,
            method: 'GET',
            path: '/api/v1.0/competition/1416/reunion',
            status: 500,
            duration: const Duration(milliseconds: 80),
            error: 'ApiException',
            server: 'Recette',
          ),
        )
        ..add(
          NetworkLogEntry(
            at: _now,
            method: 'GET',
            path: '/api/v1.0/competition/evenement',
            status: 200,
            duration: const Duration(milliseconds: 80),
            server: 'Recette',
          ),
        );
      final c = container(
        queue: [
          _op('a', OutboxState.pending),
          _op('b', OutboxState.pending),
          _op('c', OutboxState.rejected),
        ],
      );

      final report = await read(
        c,
        diagnosticReportProvider(_competition).future,
      );

      expect(report, contains('1416'));
      expect(report, contains('Championnat de France'));
      expect(report, contains('Serveur : Recette'));
      expect(report, contains('/api/v1.0/competition/1416/reunion'));
      expect(report, isNot(contains('/competition/evenement')));
      expect(report, contains('2 en attente'));
      for (final secret in [
        'jeton-secret-123',
        'ORGANISME SECRET',
        'ATHLETE',
        '?',
      ]) {
        expect(report, isNot(contains(secret)), reason: secret);
      }
    });

    test("la file d'envoi relue de l'appareil, pas seulement celle en "
        'mémoire', () async {
      store.values[OutboxStore.storageKey] = OutboxStore.encode([
        _op('a', OutboxState.pending),
        _op('b', OutboxState.rejected),
      ]);
      final c = container();

      final report = await read(
        c,
        diagnosticReportProvider(_competition).future,
      );

      expect(report, contains('1 en attente'));
      expect(report, contains('1 refusée(s)'));
    });

    test("file d'envoi illisible : celle en mémoire", () async {
      store.outboxFails = true;
      final c = container(queue: [_op('a', OutboxState.pending)]);

      final report = await read(
        c,
        diagnosticReportProvider(_competition).future,
      );

      expect(report, contains('1 en attente'));
    });

    test('compte non admin : refusé', () async {
      final c = container(account: _licensee);

      await expectLater(
        read(c, diagnosticReportProvider(_competition).future),
        throwsA(isA<AdminOnlyException>()),
      );
    });
  });
}
