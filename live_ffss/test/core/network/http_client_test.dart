import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:live_ffss/app/core/config/app_config.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/core/network/http_client.dart';
import 'package:live_ffss/app/core/network/token_storage.dart';
import 'package:mocktail/mocktail.dart';

class _MockHttp extends Mock implements http.Client {}

class _MockTokenStorage extends Mock implements TokenStorage {}

class _FakeUri extends Fake implements Uri {}

http.Response responseWith(String body, int status) =>
    http.Response(body, status);

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeUri());
  });

  late _MockHttp httpMock;
  late _MockTokenStorage tokens;
  late HttpClient client;

  const config = AppConfig(
    baseUrl: 'https://example.test',
    apiVersion: 'api/v1.0',
  );

  setUp(() {
    httpMock = _MockHttp();
    tokens = _MockTokenStorage();
    client = HttpClient(config: config, tokenStorage: tokens, inner: httpMock);
    when(() => tokens.getToken()).thenAnswer((_) async => null);
  });

  group('HttpClient.get URL building', () {
    test('joins baseUrl, apiVersion, and path with single slashes', () async {
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
              (_) async => responseWith('{"success": true, "data": []}', 200));

      await client.get('competition/evenement');

      final captured = verify(
              () => httpMock.get(captureAny(), headers: any(named: 'headers')))
          .captured;
      expect(captured.single,
          Uri.parse('https://example.test/api/v1.0/competition/evenement'));
    });

    test('appends query parameters', () async {
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
              (_) async => responseWith('{"success": true}', 200));

      await client.get('competition/evenement', query: {
        'saison': '2023-2024',
        'page': 2,
      });

      final captured = verify(
              () => httpMock.get(captureAny(), headers: any(named: 'headers')))
          .captured;
      final uri = captured.single as Uri;
      expect(uri.path, '/api/v1.0/competition/evenement');
      expect(uri.queryParameters, {'saison': '2023-2024', 'page': '2'});
    });

    test('null query values are omitted', () async {
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
              (_) async => responseWith('{"success": true}', 200));

      await client.get('x', query: {'a': 'kept', 'b': null});

      final captured = verify(
              () => httpMock.get(captureAny(), headers: any(named: 'headers')))
          .captured;
      expect((captured.single as Uri).queryParameters, {'a': 'kept'});
    });
  });

  group('HttpClient headers', () {
    test('always sends Content-Type: application/json; charset=UTF-8',
        () async {
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
              (_) async => responseWith('{"success": true}', 200));

      await client.get('x');

      final captured = verify(
              () => httpMock.get(any(), headers: captureAny(named: 'headers')))
          .captured;
      final headers = captured.single as Map<String, String>;
      expect(headers['Content-Type'], 'application/json; charset=UTF-8');
    });

    test('omits Authorization when no token', () async {
      when(() => tokens.getToken()).thenAnswer((_) async => null);
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
              (_) async => responseWith('{"success": true}', 200));

      await client.get('x');

      final captured = verify(
              () => httpMock.get(any(), headers: captureAny(named: 'headers')))
          .captured;
      final headers = captured.single as Map<String, String>;
      expect(headers.containsKey('Authorization'), isFalse);
    });

    test('omits Authorization when token is empty string', () async {
      when(() => tokens.getToken()).thenAnswer((_) async => '');
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
              (_) async => responseWith('{"success": true}', 200));

      await client.get('x');

      final captured = verify(
              () => httpMock.get(any(), headers: captureAny(named: 'headers')))
          .captured;
      expect((captured.single as Map<String, String>).containsKey('Authorization'),
          isFalse);
    });

    test('sends Authorization: Bearer <token> when token present', () async {
      when(() => tokens.getToken()).thenAnswer((_) async => 'abc123');
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
              (_) async => responseWith('{"success": true}', 200));

      await client.get('x');

      final captured = verify(
              () => httpMock.get(any(), headers: captureAny(named: 'headers')))
          .captured;
      final headers = captured.single as Map<String, String>;
      expect(headers['Authorization'], 'Bearer abc123');
    });

    test('token is NOT included as a query parameter', () async {
      when(() => tokens.getToken()).thenAnswer((_) async => 'abc123');
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
              (_) async => responseWith('{"success": true}', 200));

      await client.get('x', query: {'a': 'b'});

      final captured = verify(
              () => httpMock.get(captureAny(), headers: any(named: 'headers')))
          .captured;
      final uri = captured.single as Uri;
      expect(uri.queryParameters.containsKey('token'), isFalse);
    });
  });

  group('HttpClient success responses', () {
    test('returns full body on 2xx with success: true', () async {
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => responseWith(
              '{"success": true, "data": [1, 2, 3], "meta": "x"}', 200));

      final body = await client.get('x');

      expect(body['success'], true);
      expect(body['data'], [1, 2, 3]);
      expect(body['meta'], 'x');
    });

    test('returns full body on 2xx without a success key', () async {
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
              (_) async => responseWith('{"data": [1, 2]}', 200));

      final body = await client.get('x');
      expect(body['data'], [1, 2]);
    });

    test('accepts 200 and 201 as success', () async {
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
              (_) async => responseWith('{"success": true}', 201));

      final body = await client.get('x');
      expect(body['success'], true);
    });

    test('throws ApiException when body is not a JSON object', () async {
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => responseWith('"a string"', 200));

      expect(client.get('x'), throwsA(isA<ApiException>()));
    });

    test('throws ApiException on invalid JSON', () async {
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => responseWith('not json', 200));

      expect(client.get('x'), throwsA(isA<ApiException>()));
    });
  });

  group('HttpClient API errors', () {
    test('throws ApiException on 2xx with success: false', () async {
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => responseWith(
              '{"success": false, "message": "Bad input"}', 200));

      expect(
        client.get('x'),
        throwsA(isA<ApiException>().having(
            (e) => e.message, 'message', contains('Bad input'))),
      );
    });

    test('throws ApiException with statusCode on 4xx', () async {
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => responseWith(
              '{"success": false, "message": "Not found"}', 404));

      expect(
        client.get('x'),
        throwsA(isA<ApiException>().having(
            (e) => e.statusCode, 'statusCode', 404)),
      );
    });

    test('throws ApiException on 5xx even with non-JSON body', () async {
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async =>
              responseWith('<html>Internal Server Error</html>', 500));

      expect(
        client.get('x'),
        throwsA(isA<ApiException>().having(
            (e) => e.statusCode, 'statusCode', 500)),
      );
    });

    test('throws AuthException on 401', () async {
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => responseWith(
              '{"success": false, "message": "Token expired"}', 401));

      expect(client.get('x'), throwsA(isA<AuthException>()));
    });
  });
}
