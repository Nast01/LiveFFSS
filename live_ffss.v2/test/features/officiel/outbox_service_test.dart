import 'dart:async';

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

import '../../support/in_memory_local_store.dart';

class _MockMeetingRepository extends Mock implements MeetingRepository {}

class _MockResultRepository extends Mock implements ResultRepository {}

class _FakeSession extends SessionNotifier {
  _FakeSession(this._initial);

  final Account? _initial;

  @override
  Future<Account?> build() async => _initial;

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

  setUpAll(() {
    registerFallbackValue(const RaceResult(seriesId: 0, entryId: 0));
    registerFallbackValue(<int>[]);
  });

  setUp(() {
    meetings = _MockMeetingRepository();
    results = _MockResultRepository();
    local = InMemoryLocalStore();
    serverResultIds = {};
    // La place dit si un résultat existe déjà sur le serveur.
    when(() => meetings.getLanes(any())).thenAnswer((invocation) async {
      final ids = invocation.positionalArguments.single as Iterable<int>;
      return {
        for (final id in ids) id: _lane(id, resultId: serverResultIds[id]),
      };
    });
  });

  ProviderContainer container({Account? account = _jean}) {
    final c = ProviderContainer(
      overrides: [
        meetingRepositoryProvider.overrideWithValue(meetings),
        resultRepositoryProvider.overrideWithValue(results),
        localStoreProvider.overrideWithValue(local),
        sessionProvider.overrideWith(() => _FakeSession(account)),
        clockProvider.overrideWithValue(() => DateTime(2026, 10, 18, 10)),
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
      OutboxStore.decode(local.values[OutboxStore.storageKey]);

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
      expect(op.reason, 'validé par le juge des résultats');
      expect(stored().single.state, OutboxState.rejected);
      c.dispose();
    });
  });

  test('résultat illisible : refusé sans écriture', () {
    fakeAsync((async) {
      serverResultIds[11] = 42;
      when(() => results.getResult(42)).thenAnswer((_) async => null);
      final c = container();
      async.flushMicrotasks();

      unawaited(add(c));
      async.flushMicrotasks();

      verifyNever(() => results.submit(any()));
      final op = c.read(outboxProvider).single;
      expect(op.state, OutboxState.rejected);
      expect(op.reason, 'résultat illisible');
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
      expect(queue[0].reason, 'engagement inconnu');
      expect(queue[1].state, OutboxState.sent);
      c.dispose();
    });
  });

  test('panne du serveur (5xx) : nouvel essai, pas un refus', () {
    fakeAsync((async) {
      var calls = 0;
      when(() => results.submit(any())).thenAnswer((_) async {
        calls++;
        if (calls == 1) throw const ApiException('HTTP 502', statusCode: 502);
        return 99;
      });
      final c = container();
      async.flushMicrotasks();

      unawaited(add(c));
      async.flushMicrotasks();
      expect(c.read(outboxProvider).single.state, OutboxState.pending);

      async.elapse(const Duration(seconds: 5));
      expect(c.read(outboxProvider).single.state, OutboxState.sent);
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
}
