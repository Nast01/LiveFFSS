import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';

void main() {
  group('AppException', () {
    test('NetworkException stores message and exposes it via toString', () {
      const e = NetworkException('No internet');
      expect(e.message, 'No internet');
      expect(e.toString(), contains('No internet'));
    });

    test('ApiException stores message and optional statusCode', () {
      const e = ApiException('Server error', statusCode: 500);
      expect(e.message, 'Server error');
      expect(e.statusCode, 500);
    });

    test('AuthException is distinct from ApiException', () {
      const a = AuthException('Token expired');
      const b = ApiException('Server error');
      expect(a, isA<AuthException>());
      expect(a, isA<AppException>());
      expect(b, isNot(isA<AuthException>()));
    });

    test('UnknownException wraps unexpected errors', () {
      const e = UnknownException('Boom');
      expect(e.message, 'Boom');
      expect(e, isA<AppException>());
    });

    test('AppException implements Exception', () {
      const e = NetworkException('x');
      expect(e, isA<Exception>());
    });
  });
}
