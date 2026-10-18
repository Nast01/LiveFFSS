import 'dart:async';
import 'dart:convert';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/repositories/meeting_repository.dart';
import 'package:live_ffss_v2/data/repositories/result_repository.dart';
import 'package:live_ffss_v2/domain/account.dart';
import 'package:live_ffss_v2/domain/lane_assignment.dart';
import 'package:live_ffss_v2/domain/outbox.dart';
import 'package:live_ffss_v2/domain/race_result.dart';
import 'package:live_ffss_v2/features/auth/session.dart';
import 'package:live_ffss_v2/features/officiel/outbox_service.dart';
import 'package:live_ffss_v2/features/officiel/outbox_store.dart';
import 'package:mocktail/mocktail.dart';

import 'package:live_ffss_v2/core/storage/local_store.dart';

import '../../support/in_memory_local_store.dart';

class _MockMeetingRepository extends Mock implements MeetingRepository {}

class _MockResultRepository extends Mock implements ResultRepository {}

class _FakeSession extends SessionNotifier {
  _FakeSession(this._initial, [this._pending]);

  final Account? _initial;
  final Future<Account?>? _pending;

  @override
  Future<Account?> build() async => _pending ?? _initial;

  void set(Account? account) => state = AsyncData(account);
}

const _jean = Account(label: 'DUPONT Jean');
const _paul = Account(label: 'MARTIN Paul');

LaneAssignment _lane(int placeId, {int? resultId, int entryId = 7}) =>
    LaneAssignment(
      id: placeId,
      lane: 1,
      athletes: const ['Alice'],
      resultId: resultId,
      entryId: entryId,
    );

void main() {
  late _MockMeetingRepository meetings;
  late _MockResultRepository results;
  late InMemoryLocalStore local;
  late Map<int, int?> serverResultIds;
  late DateTime now;

  setUpAll(() {
    registerFallbackValue(const RaceResult(seriesId: 0, entryId: 0));
    registerFallbackValue(<int>[]);
  });

  setUp(() {
    meetings = _MockMeetingRepository();
    results = _MockResultRepository();
    local = InMemoryLocalStore();
    serverResultIds = {};
    now = DateTime(2026, 10, 18, 10);
    // La place dit si un résultat existe déjà sur le serveur.
    when(() => meetings.getLanes(any())).thenAnswer((invocation) async {
      final ids = invocation.positionalArguments.single as Iterable<int>;
      return {
        for (final id in ids) id: _lane(id, resultId: serverResultIds[id]),
      };
    });
  });

  ProviderContainer container({
    Account? account = _jean,
    Future<Account?>? pendingSession,
    LocalStore? store,
  }) {
    final c = ProviderContainer(
      overrides: [
        meetingRepositoryProvider.overrideWithValue(meetings),
        resultRepositoryProvider.overrideWithValue(results),
        localStoreProvider.overrideWithValue(store ?? local),
        sessionProvider.overrideWith(
          () => _FakeSession(account, pendingSession),
        ),
        clockProvider.overrideWithValue(() => now),
      ],
      retry: noRetry,
    );
    c.listen(outboxProvider, (_, _) {});
    return c;
  }

  _FakeSession session(ProviderContainer c) =>
      c.read(sessionProvider.notifier) as _FakeSession;

  Future<void> add(
    ProviderContainer c, {
    int placeId = 11,
    ResultChange change = const ResultChange(chronos: [5000, 5100, null]),
  }) => c
      .read(outboxProvider.notifier)
      .add(
        competitionId: 1416,
        placeId: placeId,
        seriesId: 5,
        entryId: 7,
        change: change,
      );

  List<OutboxOperation> stored() =>
      (OutboxStore.decode(local.values[OutboxStore.storageKey]) as OutboxLoaded)
          .operations;

  List<RaceResult> submitted() => verify(
    () => results.submit(captureAny()),
  ).captured.cast<RaceResult>().toList();

  test('une place sans résultat : création, puis envoyée', () {
    fakeAsync((async) {
      when(() => results.submit(any())).thenAnswer((_) async => 99);
      final c = container();
      async.flushMicrotasks();

      unawaited(add(c));
      async.flushMicrotasks();

      expect(submitted(), [
        const RaceResult(seriesId: 5, entryId: 7, chronos: [5000, 5100, null]),
      ]);
      final op = c.read(outboxProvider).single;
      expect(op.state, OutboxState.sent);
      expect(op.resultId, 99);
      expect(op.account, 'DUPONT Jean');
      expect(stored(), [op]);
      c.dispose();
    });
  });

  test('un résultat existant est relu, modifié et renvoyé en entier', () {
    fakeAsync((async) {
      serverResultIds[11] = 42;
      when(() => results.getResult(42)).thenAnswer(
        (_) async => const RaceResult(
          id: 42,
          seriesId: 5,
          entryId: 7,
          rank: 3,
          status: 1,
          complement: '12',
          points: 8,
        ),
      );
      when(() => results.submit(any())).thenAnswer((_) async => 42);
      final c = container();
      async.flushMicrotasks();

      unawaited(add(c, change: const ResultChange(mark: ResultMark.ok)));
      async.flushMicrotasks();

      expect(submitted(), [
        const RaceResult(
          id: 42,
          seriesId: 5,
          entryId: 7,
          rank: 3,
          status: 0,
          complement: '12',
          points: 8,
        ),
      ]);
      expect(c.read(outboxProvider).single.state, OutboxState.sent);
      c.dispose();
    });
  });

  test('validé par le juge entre-temps : refusé sans écriture', () {
    fakeAsync((async) {
      serverResultIds[11] = 42;
      when(() => results.getResult(42)).thenAnswer(
        (_) async =>
            const RaceResult(id: 42, seriesId: 5, entryId: 7, time: 5050),
      );
      final c = container();
      async.flushMicrotasks();

      unawaited(add(c));
      async.flushMicrotasks();

      verifyNever(() => results.submit(any()));
      final op = c.read(outboxProvider).single;
      expect(op.state, OutboxState.rejected);
      expect(op.rejection, OutboxRejection.validatedByJudge);
      expect(stored().single.state, OutboxState.rejected);
      c.dispose();
    });
  });

  test('résultat illisible : réessayé, refusé au 5e échec sans écriture', () {
    fakeAsync((async) {
      serverResultIds[11] = 42;
      when(() => results.getResult(42)).thenAnswer((_) async => null);
      final c = container();
      async.flushMicrotasks();

      unawaited(add(c));
      async.flushMicrotasks();
      expect(c.read(outboxProvider).single.state, OutboxState.pending);

      // 5 s, 15 s, puis 60 s entre les essais.
      async.elapse(const Duration(seconds: 5 + 15 + 60 + 59));
      expect(c.read(outboxProvider).single.state, OutboxState.pending);
      async.elapse(const Duration(seconds: 1));

      verify(() => results.getResult(42)).called(maxFaults);
      verifyNever(() => results.submit(any()));
      final op = c.read(outboxProvider).single;
      expect(op.state, OutboxState.rejected);
      expect(op.rejection, OutboxRejection.unreadableResult);
      c.dispose();
    });
  });

  test('envoi dans l\'ordre, une opération à la fois', () {
    fakeAsync((async) {
      final first = Completer<int>();
      final order = <int>[];
      when(() => results.submit(any())).thenAnswer((invocation) {
        final r = invocation.positionalArguments.single as RaceResult;
        order.add(r.chronos.first!);
        return order.length == 1 ? first.future : Future.value(100);
      });
      final c = container();
      async.flushMicrotasks();

      unawaited(add(c, change: const ResultChange(chronos: [1])));
      unawaited(add(c, placeId: 12, change: const ResultChange(chronos: [2])));
      async.flushMicrotasks();
      expect(order, [1]);

      first.complete(99);
      async.flushMicrotasks();
      expect(order, [1, 2]);
      expect(c.read(outboxProvider).map((o) => o.state), [
        OutboxState.sent,
        OutboxState.sent,
      ]);
      c.dispose();
    });
  });

  test('serveur injoignable : nouvel essai après 5 s, puis 15 s', () {
    fakeAsync((async) {
      var calls = 0;
      when(() => results.submit(any())).thenAnswer((_) async {
        calls++;
        if (calls <= 2) throw const NetworkException('hors ligne');
        return 99;
      });
      final c = container();
      async.flushMicrotasks();

      unawaited(add(c));
      async.flushMicrotasks();
      expect(calls, 1);
      expect(c.read(outboxProvider).single.state, OutboxState.pending);
      expect(stored().single.attempts, 1);

      async.elapse(const Duration(seconds: 4));
      expect(calls, 1);
      async.elapse(const Duration(seconds: 1));
      expect(calls, 2);

      async.elapse(const Duration(seconds: 14));
      expect(calls, 2);
      async.elapse(const Duration(seconds: 1));
      expect(calls, 3);
      final op = c.read(outboxProvider).single;
      expect(op.state, OutboxState.sent);
      expect(op.attempts, 0);
      c.dispose();
    });
  });

  test('place illisible : traitée comme une coupure', () {
    fakeAsync((async) {
      var laneCalls = 0;
      when(() => meetings.getLanes(any())).thenAnswer((_) async {
        laneCalls++;
        return laneCalls == 1 ? {} : {11: _lane(11)};
      });
      when(() => results.submit(any())).thenAnswer((_) async => 99);
      final c = container();
      async.flushMicrotasks();

      unawaited(add(c));
      async.flushMicrotasks();
      verifyNever(() => results.submit(any()));
      expect(c.read(outboxProvider).single.state, OutboxState.pending);

      async.elapse(const Duration(seconds: 5));
      expect(c.read(outboxProvider).single.state, OutboxState.sent);
      c.dispose();
    });
  });

  test('réponse perdue sur une création : pas de doublon', () {
    fakeAsync((async) {
      var calls = 0;
      when(() => results.submit(any())).thenAnswer((invocation) async {
        calls++;
        if (calls == 1) {
          // La création arrive sur le serveur, mais pas sa réponse.
          serverResultIds[11] = 99;
          throw const NetworkException('réponse perdue');
        }
        return 99;
      });
      when(() => results.getResult(99)).thenAnswer(
        (_) async => const RaceResult(
          id: 99,
          seriesId: 5,
          entryId: 7,
          chronos: [5000, 5100, null],
        ),
      );
      final c = container();
      async.flushMicrotasks();

      unawaited(add(c));
      async.flushMicrotasks();
      async.elapse(const Duration(seconds: 5));

      expect(submitted().map((r) => r.id), [null, 99]);
      final op = c.read(outboxProvider).single;
      expect(op.state, OutboxState.sent);
      expect(op.resultId, 99);
      c.dispose();
    });
  });

  test('session expirée : arrêt, puis reprise après reconnexion', () {
    fakeAsync((async) {
      var calls = 0;
      when(() => results.submit(any())).thenAnswer((_) async {
        calls++;
        if (calls == 1) throw const AuthException('Invalid token');
        return 99;
      });
      final c = container();
      async.flushMicrotasks();

      unawaited(add(c));
      unawaited(add(c, placeId: 12));
      async.flushMicrotasks();
      expect(calls, 1);

      // Rien ne repart tout seul, même longtemps après.
      async.elapse(const Duration(minutes: 5));
      expect(calls, 1);
      expect(c.read(outboxProvider).map((o) => o.state), [
        OutboxState.pending,
        OutboxState.pending,
      ]);

      session(c).set(null);
      async.flushMicrotasks();
      expect(calls, 1);

      session(c).set(_jean);
      async.flushMicrotasks();
      expect(calls, 3);
      expect(c.read(outboxProvider).map((o) => o.state), [
        OutboxState.sent,
        OutboxState.sent,
      ]);
      c.dispose();
    });
  });

  test('refus métier : refusée avec le message, la suivante part', () {
    fakeAsync((async) {
      var calls = 0;
      when(() => results.submit(any())).thenAnswer((_) async {
        calls++;
        if (calls == 1) throw const ApiException('engagement inconnu');
        return 99;
      });
      final c = container();
      async.flushMicrotasks();

      unawaited(add(c));
      unawaited(add(c, placeId: 12));
      async.flushMicrotasks();

      final queue = c.read(outboxProvider);
      expect(queue[0].state, OutboxState.rejected);
      expect(queue[0].rejection, OutboxRejection.server);
      expect(queue[0].reason, 'engagement inconnu');
      expect(queue[1].state, OutboxState.sent);
      c.dispose();
    });
  });

  for (final status in [502, 408, 429]) {
    test('HTTP $status : nouvel essai, pas un refus', () {
      fakeAsync((async) {
        var calls = 0;
        when(() => results.submit(any())).thenAnswer((_) async {
          calls++;
          if (calls <= maxFaults + 1) {
            throw ApiException('HTTP $status', statusCode: status);
          }
          return 99;
        });
        final c = container();
        async.flushMicrotasks();

        unawaited(add(c));
        async.flushMicrotasks();
        expect(c.read(outboxProvider).single.state, OutboxState.pending);

        // Pas de plafond : une panne du serveur ne refuse pas la saisie.
        async.elapse(const Duration(minutes: 10));
        expect(c.read(outboxProvider).single.state, OutboxState.sent);
        c.dispose();
      });
    });
  }

  test('erreur inattendue : réessayée, refusée au 5e échec', () {
    fakeAsync((async) {
      when(
        () => results.submit(any()),
      ).thenThrow(const UnknownException('HandshakeException'));
      final c = container();
      async.flushMicrotasks();

      unawaited(add(c));
      async.flushMicrotasks();
      async.elapse(const Duration(minutes: 10));

      verify(() => results.submit(any())).called(maxFaults);
      final op = c.read(outboxProvider).single;
      expect(op.state, OutboxState.rejected);
      expect(op.rejection, OutboxRejection.server);
      expect(op.reason, 'HandshakeException');
      c.dispose();
    });
  });

  test('coupure : jamais refusée, même longtemps', () {
    fakeAsync((async) {
      when(
        () => results.submit(any()),
      ).thenThrow(const NetworkException('hors ligne'));
      final c = container();
      async.flushMicrotasks();

      unawaited(add(c));
      async.flushMicrotasks();
      async.elapse(const Duration(hours: 1));

      expect(c.read(outboxProvider).single.state, OutboxState.pending);
      c.dispose();
    });
  });

  test('les saisies d\'un autre compte attendent leur compte', () {
    fakeAsync((async) {
      local.values[OutboxStore.storageKey] = OutboxStore.encode([
        const OutboxOperation(
          id: 'p',
          account: 'MARTIN Paul',
          competitionId: 1416,
          placeId: 12,
          seriesId: 5,
          entryId: 8,
          change: ResultChange(chronos: [1]),
        ),
      ]);
      when(() => results.submit(any())).thenAnswer((_) async => 99);
      final c = container();
      async.flushMicrotasks();

      unawaited(add(c));
      async.flushMicrotasks();

      expect(submitted().map((r) => r.entryId), [7]);
      final queue = c.read(outboxProvider);
      expect(queue.map((o) => (o.account, o.state)), [
        ('MARTIN Paul', OutboxState.pending),
        ('DUPONT Jean', OutboxState.sent),
      ]);

      session(c).set(_paul);
      async.flushMicrotasks();
      expect(c.read(outboxProvider).first.state, OutboxState.sent);
      c.dispose();
    });
  });

  test('au redémarrage, la file enregistrée repart', () {
    fakeAsync((async) {
      when(
        () => results.submit(any()),
      ).thenThrow(const NetworkException('hors ligne'));
      final first = container();
      async.flushMicrotasks();
      unawaited(add(first));
      async.flushMicrotasks();
      first.dispose();
      // Plus de minuterie après la fermeture.
      async.elapse(const Duration(minutes: 2));
      verify(() => results.submit(any())).called(1);

      when(() => results.submit(any())).thenAnswer((_) async => 99);
      final second = container();
      async.flushMicrotasks();

      verify(() => results.submit(any())).called(1);
      expect(second.read(outboxProvider).single.state, OutboxState.sent);
      second.dispose();
    });
  });

  test('une saisie fusionnée pendant l\'envoi repart', () {
    fakeAsync((async) {
      final first = Completer<int>();
      var calls = 0;
      when(() => results.submit(any())).thenAnswer((_) {
        calls++;
        return calls == 1 ? first.future : Future.value(99);
      });
      when(() => results.getResult(99)).thenAnswer(
        (_) async => const RaceResult(
          id: 99,
          seriesId: 5,
          entryId: 7,
          chronos: [5000, 5100, null],
        ),
      );
      final c = container();
      async.flushMicrotasks();

      unawaited(add(c));
      async.flushMicrotasks();
      unawaited(add(c, change: const ResultChange(mark: ResultMark.forfeit)));
      async.flushMicrotasks();
      expect(c.read(outboxProvider), hasLength(1));

      serverResultIds[11] = 99;
      first.complete(99);
      async.flushMicrotasks();

      final sent = submitted();
      expect(sent, hasLength(2));
      expect(sent.last.id, 99);
      expect(sent.last.status, statusForfeit);
      expect(sent.last.chronos, [5000, 5100, null]);
      expect(c.read(outboxProvider).single.state, OutboxState.sent);
      c.dispose();
    });
  });

  test('sans session, une saisie est refusée', () async {
    final c = container(account: null);
    await c.read(sessionProvider.future);
    await expectLater(add(c), throwsA(isA<AuthException>()));
    expect(c.read(outboxProvider), isEmpty);
    c.dispose();
  });

  test('session en cours de reprise : la saisie attend son compte', () {
    fakeAsync((async) {
      when(() => results.submit(any())).thenAnswer((_) async => 99);
      final resumed = Completer<Account?>();
      final c = container(pendingSession: resumed.future);
      async.flushMicrotasks();

      var done = false;
      unawaited(add(c).then((_) => done = true));
      async.flushMicrotasks();
      expect(done, isFalse);

      resumed.complete(_jean);
      async.flushMicrotasks();
      expect(done, isTrue);
      expect(c.read(outboxProvider).single.account, 'DUPONT Jean');
      c.dispose();
    });
  });

  group('jamais sous un autre compte', () {
    test('session changée pendant la relecture : rien n\'est écrit', () {
      fakeAsync((async) {
        serverResultIds[11] = 42;
        final read = Completer<RaceResult?>();
        var reads = 0;
        when(() => results.getResult(42)).thenAnswer((_) {
          reads++;
          return reads == 1
              ? read.future
              : Future.value(const RaceResult(id: 42, seriesId: 5, entryId: 7));
        });
        when(() => results.submit(any())).thenAnswer((_) async => 42);
        final c = container();
        async.flushMicrotasks();

        unawaited(add(c));
        async.flushMicrotasks();
        session(c).set(_paul);
        async.flushMicrotasks();
        read.complete(const RaceResult(id: 42, seriesId: 5, entryId: 7));
        async.flushMicrotasks();

        verifyNever(() => results.submit(any()));
        expect(c.read(outboxProvider).single.state, OutboxState.pending);

        session(c).set(_jean);
        async.flushMicrotasks();
        expect(c.read(outboxProvider).single.state, OutboxState.sent);
        c.dispose();
      });
    });

    test('session changée pendant la relecture de la place', () {
      fakeAsync((async) {
        final lanes = Completer<Map<int, LaneAssignment?>>();
        when(() => meetings.getLanes(any())).thenAnswer((_) => lanes.future);
        when(() => results.submit(any())).thenAnswer((_) async => 99);
        final c = container();
        async.flushMicrotasks();

        unawaited(add(c));
        async.flushMicrotasks();
        session(c).set(null);
        async.flushMicrotasks();
        lanes.complete({11: _lane(11)});
        async.flushMicrotasks();

        verifyNever(() => results.submit(any()));
        expect(c.read(outboxProvider).single.state, OutboxState.pending);
        c.dispose();
      });
    });
  });

  group('rien de perdu', () {
    const saved = OutboxOperation(
      id: 'ancienne',
      account: 'DUPONT Jean',
      competitionId: 1416,
      placeId: 12,
      seriesId: 5,
      entryId: 8,
      change: ResultChange(chronos: [1]),
    );

    test('relecture en échec : la file enregistrée survit à une saisie', () {
      fakeAsync((async) {
        when(
          () => results.submit(any()),
        ).thenThrow(const NetworkException('hors ligne'));
        final flaky = _FlakyStore(local)..readFailures = 1000;
        local.values[OutboxStore.storageKey] = OutboxStore.encode([saved]);
        final c = container(store: flaky);
        async.flushMicrotasks();
        expect(c.read(outboxPersistenceFailedProvider), isTrue);

        Object? error;
        unawaited(add(c).catchError((Object e) => error = e));
        async.flushMicrotasks();
        expect(error, isA<AppException>());
        // Gardée en mémoire, mais rien n'a été écrit par-dessus.
        expect(c.read(outboxProvider).single.placeId, 11);
        expect(stored(), [saved]);
        verifyNever(() => results.submit(any()));

        // La relecture est réessayée, avec un délai croissant.
        flaky.readFailures = 0;
        async.elapse(const Duration(seconds: 60));
        expect(stored().map((o) => o.id), ['ancienne', isNot('ancienne')]);
        expect(c.read(outboxProvider).map((o) => o.placeId), [12, 11]);
        expect(c.read(outboxPersistenceFailedProvider), isFalse);
        c.dispose();
      });
    });

    test('relecture en échec une fois : la saisie suivante la relance', () {
      fakeAsync((async) {
        when(
          () => results.submit(any()),
        ).thenThrow(const NetworkException('hors ligne'));
        final flaky = _FlakyStore(local)..readFailures = 1;
        local.values[OutboxStore.storageKey] = OutboxStore.encode([saved]);
        final c = container(store: flaky);
        async.flushMicrotasks();

        unawaited(add(c));
        async.flushMicrotasks();

        expect(stored().map((o) => o.placeId), [12, 11]);
        c.dispose();
      });
    });

    test('valeur illisible : mise de côté avant d\'être remplacée', () {
      fakeAsync((async) {
        when(() => results.submit(any())).thenAnswer((_) async => 99);
        local.values[OutboxStore.storageKey] = '{pas du json';
        final c = container();
        async.flushMicrotasks();

        unawaited(add(c));
        async.flushMicrotasks();

        final backupKey =
            '${OutboxStore.backupKeyPrefix}${now.millisecondsSinceEpoch}';
        expect(local.values[backupKey], '{pas du json');
        expect(stored().single.placeId, 11);
        c.dispose();
      });
    });

    test('ligne d\'une autre version : réécrite telle quelle', () {
      fakeAsync((async) {
        when(() => results.submit(any())).thenAnswer((_) async => 99);
        const future = {'id': 'z', 'state': 'archived'};
        local.values[OutboxStore.storageKey] = '[${jsonEncode(future)}]';
        final c = container();
        async.flushMicrotasks();

        unawaited(add(c));
        async.flushMicrotasks();

        final raw = jsonDecode(local.values[OutboxStore.storageKey]!) as List;
        expect(raw, hasLength(2));
        expect(raw, contains(equals(future)));
        c.dispose();
      });
    });

    test('enregistrement en échec : la saisie le dit, reste et part', () {
      fakeAsync((async) {
        final sent = Completer<int>();
        when(() => results.submit(any())).thenAnswer((_) => sent.future);
        final flaky = _FlakyStore(local);
        final c = container(store: flaky);
        async.flushMicrotasks();

        flaky.writeFailures = 1;
        Object? error;
        unawaited(add(c).catchError((Object e) => error = e));
        async.flushMicrotasks();
        expect(error, isA<AppException>());
        expect(c.read(outboxPersistenceFailedProvider), isTrue);
        expect(c.read(outboxProvider), hasLength(1));

        sent.complete(99);
        async.flushMicrotasks();
        expect(stored().single.state, OutboxState.sent);
        expect(c.read(outboxPersistenceFailedProvider), isFalse);
        c.dispose();
      });
    });
  });

  group('hors ligne jamais rejeté, relance', () {
    const rejected = OutboxOperation(
      id: 'refusée',
      account: 'DUPONT Jean',
      competitionId: 1416,
      placeId: 11,
      seriesId: 5,
      entryId: 7,
      change: ResultChange(chronos: [1]),
      state: OutboxState.rejected,
      rejection: OutboxRejection.unreadableResult,
      faults: 4,
    );

    test('place jamais relue pendant 1 h : toujours en attente', () {
      fakeAsync((async) {
        when(() => meetings.getLanes(any())).thenAnswer((_) async => {});
        final c = container();
        async.flushMicrotasks();

        unawaited(add(c));
        async.flushMicrotasks();
        async.elapse(const Duration(hours: 1));

        verifyNever(() => results.submit(any()));
        final op = c.read(outboxProvider).single;
        expect(op.state, OutboxState.pending);
        expect(op.rejection, isNull);
        c.dispose();
      });
    });

    test('retry remet une refusée en attente, et elle part', () {
      fakeAsync((async) {
        when(() => results.submit(any())).thenAnswer((_) async => 99);
        local.values[OutboxStore.storageKey] = OutboxStore.encode([rejected]);
        final c = container();
        async.flushMicrotasks();
        verifyNever(() => results.submit(any()));

        var done = false;
        unawaited(
          c.read(outboxProvider.notifier).retry('refusée').then((_) {
            done = true;
          }),
        );
        async.flushMicrotasks();

        expect(done, isTrue);
        final op = c.read(outboxProvider).single;
        expect(op.state, OutboxState.sent);
        expect(op.rejection, isNull);
        expect(op.faults, 0);
        expect(stored().single.state, OutboxState.sent);
        c.dispose();
      });
    });

    test('dismiss refusé tant que la file enregistrée est illisible', () {
      fakeAsync((async) {
        final flaky = _FlakyStore(local)..readFailures = 1000;
        local.values[OutboxStore.storageKey] = OutboxStore.encode([rejected]);
        final c = container(store: flaky);
        async.flushMicrotasks();

        Object? error;
        unawaited(
          c
              .read(outboxProvider.notifier)
              .dismiss('refusée')
              .catchError((Object e) => error = e),
        );
        async.flushMicrotasks();

        expect(error, isA<AppException>());
        expect(stored(), [rejected]);

        // Relue ensuite, elle est toujours là.
        flaky.readFailures = 0;
        async.elapse(const Duration(minutes: 2));
        expect(c.read(outboxProvider).single.id, 'refusée');
        c.dispose();
      });
    });

    test('file illisible : pas de relecture à chaque relance', () {
      fakeAsync((async) {
        final flaky = _FlakyStore(local)..readFailures = 1000;
        final c = container(store: flaky);
        async.flushMicrotasks();
        // Le lancement et la session relancent tous deux la file.
        expect(flaky.reads, 1);

        session(c).set(null);
        session(c).set(_jean);
        async.flushMicrotasks();
        expect(flaky.reads, 1);

        // Une saisie, elle, relit tout de suite.
        unawaited(add(c).catchError((Object _) {}));
        async.flushMicrotasks();
        expect(flaky.reads, 2);

        async.elapse(const Duration(seconds: 15));
        expect(flaky.reads, 3);
        c.dispose();
      });
    });
  });

  group('ménage', () {
    OutboxOperation settled(String id, OutboxState state, {DateTime? at}) =>
        OutboxOperation(
          id: id,
          account: 'DUPONT Jean',
          competitionId: 1416,
          placeId: id.hashCode,
          seriesId: 5,
          entryId: 7,
          change: const ResultChange(chronos: [1]),
          state: state,
          sentAt: at,
          rejection: state == OutboxState.rejected
              ? OutboxRejection.validatedByJudge
              : null,
        );

    test('les envoyées de plus de 24 h sont oubliées, pas les refusées', () {
      fakeAsync((async) {
        local.values[OutboxStore.storageKey] = OutboxStore.encode([
          settled(
            'vieille',
            OutboxState.sent,
            at: now.subtract(const Duration(hours: 25)),
          ),
          settled(
            'récente',
            OutboxState.sent,
            at: now.subtract(const Duration(hours: 1)),
          ),
          settled('refusée', OutboxState.rejected),
        ]);
        final c = container();
        async.flushMicrotasks();

        expect(c.read(outboxProvider).map((o) => o.id), ['récente', 'refusée']);
        expect(stored().map((o) => o.id), ['récente', 'refusée']);

        // Le ménage repasse après chaque envoi.
        when(() => results.submit(any())).thenAnswer((_) async => 99);
        now = now.add(const Duration(hours: 24));
        unawaited(add(c));
        async.flushMicrotasks();
        expect(c.read(outboxProvider).map((o) => o.id), [
          'refusée',
          isNot('récente'),
        ]);
        c.dispose();
      });
    });

    test('dismiss écarte une refusée, jamais une en attente', () {
      fakeAsync((async) {
        when(
          () => results.submit(any()),
        ).thenThrow(const NetworkException('hors ligne'));
        local.values[OutboxStore.storageKey] = OutboxStore.encode([
          settled('refusée', OutboxState.rejected),
        ]);
        final c = container();
        async.flushMicrotasks();
        unawaited(add(c));
        async.flushMicrotasks();
        final pendingId = c.read(outboxProvider).last.id;

        unawaited(c.read(outboxProvider.notifier).dismiss('refusée'));
        unawaited(c.read(outboxProvider.notifier).dismiss(pendingId));
        async.flushMicrotasks();

        expect(c.read(outboxProvider).map((o) => o.id), [pendingId]);
        expect(stored().map((o) => o.id), [pendingId]);
        c.dispose();
      });
    });
  });
}

/// Un stockage qui échoue à la demande, comme le stockage sécurisé qui lève
/// ses propres erreurs.
class _FlakyStore implements LocalStore {
  _FlakyStore(this._inner);

  final LocalStore _inner;
  int readFailures = 0;
  int writeFailures = 0;
  int reads = 0;

  @override
  Future<String?> read(String key) async {
    reads++;
    if (readFailures > 0) {
      readFailures--;
      throw StateError('stockage indisponible');
    }
    return _inner.read(key);
  }

  @override
  Future<void> write(String key, String value) async {
    if (writeFailures > 0) {
      writeFailures--;
      throw StateError('stockage plein');
    }
    return _inner.write(key, value);
  }

  @override
  Future<void> delete(String key) => _inner.delete(key);
}
