import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/domain/account.dart';
import 'package:live_ffss_v2/domain/outbox.dart';
import 'package:live_ffss_v2/domain/race_result.dart';
import 'package:live_ffss_v2/features/auth/auth_formatting.dart';

OutboxOperation op(
  String id, {
  String account = 'DUPONT Jean',
  OutboxState state = OutboxState.pending,
}) => OutboxOperation(
  id: id,
  account: account,
  competitionId: 1,
  placeId: 2,
  seriesId: 3,
  entryId: 4,
  change: const ResultChange(),
  state: state,
);

void main() {
  group('loginFailureOf', () {
    test('maps each exception type', () {
      expect(loginFailureOf(const AuthException('x')), LoginFailure.rejected);
      expect(
        loginFailureOf(const NetworkException('x')),
        LoginFailure.unreachable,
      );
      expect(
        loginFailureOf(const ApiException('x', malformedResponse: true)),
        LoginFailure.unreachable,
      );
      expect(
        loginFailureOf(const ApiException('x', statusCode: 500)),
        LoginFailure.other,
      );
      expect(loginFailureOf(const UnknownException('x')), LoginFailure.other);
    });
  });

  group('logoutNeedsConfirmation', () {
    const account = Account(label: 'DUPONT Jean');

    test('false with an empty queue', () {
      expect(logoutNeedsConfirmation(const [], account), isFalse);
    });

    test('true when the account has a pending operation', () {
      expect(logoutNeedsConfirmation([op('a')], account), isTrue);
    });

    test('ignores sent, rejected and other accounts', () {
      final queue = [
        op('a', state: OutboxState.sent),
        op('b', state: OutboxState.rejected),
        op('c', account: 'MARTIN Paul'),
      ];
      expect(logoutNeedsConfirmation(queue, account), isFalse);
    });

    test('matches the account name loosely and counts operations', () {
      final queue = [op('a', account: ' dupont jean '), op('b')];
      expect(pendingOperationCount(queue, account), 2);
    });
  });

  test('canSubmitLogin needs both fields', () {
    expect(canSubmitLogin('', 'x'), isFalse);
    expect(canSubmitLogin('  ', 'x'), isFalse);
    expect(canSubmitLogin('a', ''), isFalse);
    expect(canSubmitLogin('a', 'x'), isTrue);
  });
}
