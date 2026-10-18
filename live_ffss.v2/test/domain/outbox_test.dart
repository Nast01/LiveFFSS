import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/domain/account.dart';
import 'package:live_ffss_v2/domain/outbox.dart';
import 'package:live_ffss_v2/domain/race_result.dart';

void main() {
  OutboxOperation op(
    String id, {
    String account = 'DUPONT Jean',
    int placeId = 11,
    ResultChange change = const ResultChange(),
    OutboxState state = OutboxState.pending,
    int? resultId,
    int entryId = 7,
  }) => OutboxOperation(
    id: id,
    account: account,
    competitionId: 1416,
    placeId: placeId,
    resultId: resultId,
    seriesId: 5,
    entryId: entryId,
    change: change,
    state: state,
  );

  group('enqueue', () {
    test('une saisie sur une autre place s\'ajoute à la fin', () {
      final queue = enqueue([op('a')], op('b', placeId: 12));
      expect(queue.map((o) => o.id), ['a', 'b']);
    });

    test('deux saisies du même couloir fusionnent, la dernière gagne', () {
      final queue = enqueue([
        op(
          'a',
          change: const ResultChange(
            chronos: [100, 200, null],
            mark: ResultMark.disqualified,
            code: '12',
          ),
        ),
      ], op('b', change: const ResultChange(chronos: [300, null, null])));
      expect(queue, hasLength(1));
      expect(queue.single.id, 'a');
      expect(
        queue.single.change,
        const ResultChange(
          chronos: [300, null, null],
          mark: ResultMark.disqualified,
          code: '12',
        ),
      );
    });

    test('un nouveau statut remplace le statut et son code', () {
      final queue = enqueue([
        op(
          'a',
          change: const ResultChange(
            chronos: [100, null, null],
            mark: ResultMark.disqualified,
            code: '12',
          ),
        ),
      ], op('b', change: const ResultChange(mark: ResultMark.forfeit)));
      expect(
        queue.single.change,
        const ResultChange(
          chronos: [100, null, null],
          mark: ResultMark.forfeit,
        ),
      );
    });

    test('l\'id de résultat connu est gardé', () {
      final queue = enqueue([op('a', resultId: 99)], op('b'));
      expect(queue.single.resultId, 99);
    });

    test('une nouvelle saisie n\'hérite pas des échecs passés', () {
      final queue = enqueue([
        op('a').copyWith(attempts: 7, faults: 4),
      ], op('b'));
      expect(queue.single.attempts, 0);
      expect(queue.single.faults, 0);
    });

    test('pas de fusion avec un autre compte', () {
      final queue = enqueue([op('a')], op('b', account: 'MARTIN Paul'));
      expect(queue.map((o) => o.id), ['a', 'b']);
    });

    test('pas de fusion quand la place porte un autre engagement', () {
      // Série recomposée par le bureau pendant l'attente : les chronos du
      // nouveau nageur ne se mêlent pas à ceux de l'ancien.
      final queue = enqueue([op('a')], op('b', entryId: 8));
      expect(queue.map((o) => o.id), ['a', 'b']);
    });

    test('pas de fusion avec une opération envoyée ou refusée', () {
      final queue = enqueue([
        op('a', state: OutboxState.sent),
        op('b', state: OutboxState.rejected),
      ], op('c'));
      expect(queue.map((o) => o.id), ['a', 'b', 'c']);
    });
  });

  test('isSameAccount ignore la casse et les espaces', () {
    expect(isSameAccount(' Dupont JEAN', 'DUPONT Jean '), isTrue);
    expect(isSameAccount('DUPONT Jean', 'MARTIN Paul'), isFalse);
  });

  test('pruneSent oublie les envoyées de plus de 24 h, garde le reste', () {
    final now = DateTime(2026, 10, 18, 10);
    final queue = [
      op(
        'vieille',
        state: OutboxState.sent,
      ).copyWith(sentAt: now.subtract(const Duration(hours: 24))),
      op(
        'récente',
        state: OutboxState.sent,
      ).copyWith(sentAt: now.subtract(const Duration(hours: 23))),
      op('refusée', state: OutboxState.rejected),
      op('en attente'),
    ];
    expect(pruneSent(queue, now).map((o) => o.id), [
      'récente',
      'refusée',
      'en attente',
    ]);
  });

  test('retryDelay croît puis plafonne à 60 s', () {
    expect(retryDelay(1), const Duration(seconds: 5));
    expect(retryDelay(2), const Duration(seconds: 15));
    expect(retryDelay(3), const Duration(seconds: 60));
    expect(retryDelay(10), const Duration(seconds: 60));
  });
}
