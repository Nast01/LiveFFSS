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

    test('ApiException defaults statusCode and code to null', () {
      const e = ApiException('bare');
      expect(e.statusCode, isNull);
      expect(e.code, isNull);
    });

    test('ApiException stores optional code', () {
      const e = ApiException('Rate limited', code: 'E_RATE_LIMIT');
      expect(e.code, 'E_RATE_LIMIT');
      expect(const ApiException('x').code, isNull);
    });

    test('toString format is "<runtimeType>: <message>"', () {
      const e = NetworkException('No internet');
      expect(e.toString(), 'NetworkException: No internet');
    });

    group('detail, the diagnostic line shown under a failure', () {
      test('is the plain message when there is nothing else to say', () {
        expect(const NetworkException('No internet').detail, 'No internet');
        expect(const UnknownException('Boom').detail, 'Boom');
      });

      test('an ApiException adds the status code that came with it', () {
        expect(
          const ApiException('Discipline inconnue', statusCode: 422).detail,
          'Discipline inconnue (HTTP 422)',
        );
      });

      test('an ApiException without a status code stays bare', () {
        expect(const ApiException('Discipline inconnue').detail,
            'Discipline inconnue');
      });

      test('says so when the request went out with no token at all', () {
        // FFSS answers "Invalid Token" both to a bad token and to no token,
        // so the reply alone cannot tell "not logged in" from "token refused".
        expect(
          const ApiException('Invalid Token',
                  statusCode: 200, authenticated: false)
              .detail,
          'Invalid Token (HTTP 200, no token sent)',
        );
      });

      test('stays quiet about auth when the request did carry a token', () {
        expect(
          const ApiException('Invalid Token', authenticated: true).detail,
          'Invalid Token',
        );
      });

      test('says nothing about auth when nobody recorded it', () {
        expect(const ApiException('Boom').authenticated, isNull);
        expect(const ApiException('Boom').detail, 'Boom');
      });
    });
  });
}
