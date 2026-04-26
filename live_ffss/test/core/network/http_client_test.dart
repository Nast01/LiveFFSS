import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:live_ffss/app/core/config/app_config.dart';
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
}
