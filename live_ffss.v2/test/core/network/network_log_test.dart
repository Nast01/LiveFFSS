import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:live_ffss_v2/core/app_host.dart';
import 'package:live_ffss_v2/core/config/app_config.dart';
import 'package:live_ffss_v2/core/config/app_environment.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/network/http_client.dart';
import 'package:live_ffss_v2/core/network/network_log.dart';
import 'package:live_ffss_v2/core/network/token_storage.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:mocktail/mocktail.dart';

class _MockHttp extends Mock implements http.Client {}

class _MockTokenStorage extends Mock implements TokenStorage {}

class _FakeUri extends Fake implements Uri {}

NetworkLogEntry _entry(int i) => NetworkLogEntry(
  at: DateTime(2026, 10, 19),
  method: 'GET',
  path: '/api/v1.0/n$i',
  duration: Duration.zero,
  server: 'Développement',
);

void main() {
  setUpAll(() => registerFallbackValue(_FakeUri()));

  group('HttpClient.onRequest', () {
    late _MockHttp inner;
    late _MockTokenStorage tokens;
    late List<NetworkLogEntry> logged;
    late HttpClient client;
    final now = DateTime(2026, 10, 19, 14, 30);

    setUp(() {
      inner = _MockHttp();
      tokens = _MockTokenStorage();
      logged = [];
      when(() => tokens.getToken()).thenAnswer((_) async => 'SECRET-TOKEN');
      client = HttpClient(
        config: AppConfig.forEnvironment(AppEnvironment.development),
        tokenStorage: tokens,
        inner: inner,
        onRequest: logged.add,
        clock: () => now,
      );
    });

    test('une requête réussie est consignée', () async {
      when(() => inner.get(any(), headers: any(named: 'headers'))).thenAnswer(
        (_) async => http.Response('{"success": true, "data": []}', 200),
      );

      await client.get('competition/evenement', query: {'type': 3});

      final e = logged.single;
      expect(e.method, 'GET');
      expect(e.path, '/api/v1.0/competition/evenement');
      expect(e.status, 200);
      expect(e.bytes, '{"success": true, "data": []}'.length);
      expect(e.error, isNull);
      expect(e.at, now);
      expect(e.server, 'Développement');
    });

    test("un refus du serveur garde le statut et le type d'erreur", () async {
      when(
        () => inner.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => http.Response('{"message": "non"}', 404));

      await expectLater(client.get('x/1'), throwsA(isA<ApiException>()));

      expect(logged.single.status, 404);
      expect(logged.single.error, 'ApiException');
    });

    test('hors ligne: pas de statut, NetworkException', () async {
      when(
        () => inner.get(any(), headers: any(named: 'headers')),
      ).thenThrow(const SocketException('down'));

      await expectLater(client.get('x/1'), throwsA(isA<NetworkException>()));

      expect(logged.single.status, isNull);
      expect(logged.single.bytes, isNull);
      expect(logged.single.error, 'NetworkException');
    });

    test('ni jeton, ni requête, ni corps dans le journal', () async {
      when(
        () => inner.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response('{"success": true}', 200));
      when(
        () => inner.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => http.Response('{"success": true}', 200));

      await client.post(
        'auth/login?email=a@b.fr',
        query: {'saisie': 'PASSWORD-1234'},
        form: {'password': 'PASSWORD-1234'},
      );
      await client.get('competition/1/reunion', query: {'x': 'SECRET-TOKEN'});

      expect(logged, hasLength(2));
      for (final e in logged) {
        final all = '${e.path} ${e.method} ${e.server} ${e.error}';
        expect(all, isNot(contains('?')));
        expect(all, isNot(contains('token')));
        expect(all, isNot(contains('SECRET-TOKEN')));
        expect(all, isNot(contains('PASSWORD')));
        expect(all, isNot(contains('a@b.fr')));
      }
      expect(logged.first.path, '/api/v1.0/auth/login');
    });
  });

  group('NetworkLogStore', () {
    test("garde 200 entrées au plus, la plus récente d'abord", () {
      final container = ProviderContainer(retry: noRetry);
      addTearDown(container.dispose);
      final store = container.read(networkLogStoreProvider);
      container.listen(networkLogProvider, (_, _) {});

      for (var i = 0; i < 250; i++) {
        store.add(_entry(i));
      }

      final entries = container.read(networkLogProvider);
      expect(entries, hasLength(200));
      expect(entries.first.path, '/api/v1.0/n249');
      expect(entries.last.path, '/api/v1.0/n50');
    });

    test('clear() vide le journal', () {
      final container = ProviderContainer(retry: noRetry);
      addTearDown(container.dispose);
      container.listen(networkLogProvider, (_, _) {});
      container.read(networkLogStoreProvider).add(_entry(1));

      container.read(networkLogProvider.notifier).clear();

      expect(container.read(networkLogProvider), isEmpty);
    });

    test('les entrées traversent un changement de serveur', () {
      final host = AppContainerHost(
        environment: AppEnvironment.development,
        disposeOld: (old) => old.dispose(),
      );
      addTearDown(host.dispose);
      final before = host.container;
      before.listen(networkLogProvider, (_, _) {});
      before.read(networkLogStoreProvider).add(_entry(1));

      host.restartOn(AppEnvironment.production);

      final after = host.container;
      expect(after, isNot(same(before)));
      after.read(networkLogStoreProvider).add(_entry(2));
      expect(after.read(networkLogProvider).map((e) => e.path), [
        '/api/v1.0/n2',
        '/api/v1.0/n1',
      ]);
    });
  });
}
