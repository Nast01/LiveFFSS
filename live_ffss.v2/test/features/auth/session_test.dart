import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http_package;
import 'package:http/testing.dart';
import 'package:live_ffss_v2/core/config/app_config.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/network/http_client.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/repositories/auth_repository.dart';
import 'package:live_ffss_v2/domain/account.dart';
import 'package:live_ffss_v2/features/auth/session.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/in_memory_local_store.dart';
import '../../support/in_memory_token_storage.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockHttpClient extends Mock implements HttpClient {}

const _jean = Account(label: 'DUPONT Jean', type: 'licencie');

void main() {
  late _MockAuthRepository auth;
  late _MockHttpClient http;
  late InMemoryTokenStorage tokens;
  late InMemoryLocalStore store;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(() async {});
  });

  setUp(() {
    auth = _MockAuthRepository();
    http = _MockHttpClient();
    tokens = InMemoryTokenStorage();
    store = InMemoryLocalStore();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        httpClientProvider.overrideWithValue(http),
        tokenStorageProvider.overrideWithValue(tokens),
        localStoreProvider.overrideWithValue(store),
      ],
      retry: noRetry,
    );
    addTearDown(container.dispose);
  });

  /// Le gestionnaire que la session a branché sur `HttpClient.onAuthFailure`.
  Future<void> Function() authFailureHandler() =>
      verify(() => http.onAuthFailure = captureAny()).captured.last
          as Future<void> Function();

  void storeSession(String token, String label) {
    tokens.token = token;
    store.values[SessionNotifier.accountKey] = label;
  }

  group('restauration', () {
    test('sans jeton : déconnecté, sans appeler le site', () async {
      expect(await container.read(sessionProvider.future), isNull);
      verifyNever(() => auth.me());
    });

    test('jeton vérifié par /me : connecté', () async {
      storeSession('abc', 'DUPONT Jean');
      when(() => auth.me()).thenAnswer((_) async => _jean);

      expect(await container.read(sessionProvider.future), _jean);
      expect(tokens.token, 'abc');
    });

    test('compte anonyme : déconnecté, jeton effacé', () async {
      storeSession('abc', 'DUPONT Jean');
      when(() => auth.me()).thenThrow(const AuthException('anonyme'));

      expect(await container.read(sessionProvider.future), isNull);
      expect(tokens.token, isNull);
      expect(store.values[SessionNotifier.accountKey], isNull);
    });

    test('refus du site : déconnecté, jeton effacé', () async {
      storeSession('abc', 'DUPONT Jean');
      when(() => auth.me()).thenThrow(const ApiException('refus'));

      expect(await container.read(sessionProvider.future), isNull);
      expect(tokens.token, isNull);
    });

    test('autre compte que celui enregistré : déconnecté', () async {
      storeSession('abc', 'MARTIN Paul');
      when(() => auth.me()).thenAnswer((_) async => _jean);

      expect(await container.read(sessionProvider.future), isNull);
      expect(tokens.token, isNull);
    });

    test('même compte, casse et espaces près : connecté', () async {
      storeSession('abc', ' dupont jean ');
      when(() => auth.me()).thenAnswer((_) async => _jean);

      expect(await container.read(sessionProvider.future), _jean);
    });

    test('stockage sécurisé en panne : AppException', () async {
      tokens.failing = true;

      await expectLater(
        container.read(sessionProvider.future),
        throwsA(isA<UnknownException>()),
      );
    });

    test('jeton refusé pendant la reprise : session expirée', () async {
      storeSession('abc', 'DUPONT Jean');
      final pending = Completer<Account>();
      when(() => auth.me()).thenAnswer((_) => pending.future);
      final restore = container.read(sessionProvider.future);
      await pumpEventQueue();

      await authFailureHandler()();
      pending.complete(_jean);

      expect(await restore, isNull);
      expect(container.read(sessionProvider).value, isNull);
      expect(container.read(sessionExpiredProvider), isTrue);
      expect(tokens.token, isNull);
    });

    test('site injoignable : la session enregistrée est gardée', () async {
      storeSession('abc', 'DUPONT Jean');
      when(() => auth.me()).thenThrow(const NetworkException('hors ligne'));

      expect(
        await container.read(sessionProvider.future),
        const Account(label: 'DUPONT Jean'),
      );
      expect(tokens.token, 'abc');
    });
  });

  group('connexion', () {
    test('efface l\'ancien jeton avant de demander le nouveau', () async {
      await container.read(sessionProvider.future);
      tokens.token = 'perime';
      String? tokenDuringRequest = 'non lu';
      when(() => auth.requestToken('jdupont', 'secret')).thenAnswer((_) async {
        tokenDuringRequest = tokens.token;
        return 'neuf';
      });
      when(() => auth.me()).thenAnswer((_) async => _jean);

      await container.read(sessionProvider.notifier).login('jdupont', 'secret');

      expect(tokenDuringRequest, isNull);
      expect(tokens.token, 'neuf');
      expect(container.read(sessionProvider).value, _jean);
      expect(store.values[SessionNotifier.accountKey], 'DUPONT Jean');
    });

    test(
      'identifiants refusés : reste déconnecté, l\'erreur remonte',
      () async {
        await container.read(sessionProvider.future);
        when(
          () => auth.requestToken(any(), any()),
        ).thenThrow(const ApiException('Identifiants incorrects'));

        await expectLater(
          container.read(sessionProvider.notifier).login('jdupont', 'mauvais'),
          throwsA(isA<ApiException>()),
        );
        expect(container.read(sessionProvider).value, isNull);
        expect(tokens.token, isNull);
      },
    );

    test('compte non décrit : connecté sous l\'identifiant (V3)', () async {
      await container.read(sessionProvider.future);
      store.values[SessionNotifier.accountKey] = 'MARTIN Paul';
      when(
        () => auth.requestToken(any(), any()),
      ).thenAnswer((_) async => 'neuf');
      when(() => auth.me()).thenThrow(const ApiException('refus'));

      await container
          .read(sessionProvider.notifier)
          .login(' jdupont ', 'secret');

      expect(
        container.read(sessionProvider).value,
        const Account(label: 'jdupont'),
      );
      expect(tokens.token, 'neuf');
      // Ni l'identifiant ni le nom d'un compte précédent : la prochaine
      // reprise acceptera le nom que /me donnera.
      expect(store.values[SessionNotifier.accountKey], isNull);
    });

    test('jeton neuf servi comme anonyme : la connexion échoue', () async {
      await container.read(sessionProvider.future);
      when(
        () => auth.requestToken(any(), any()),
      ).thenAnswer((_) async => 'neuf');
      when(() => auth.me()).thenThrow(const AuthException('anonyme'));

      await expectLater(
        container.read(sessionProvider.notifier).login('jdupont', 'secret'),
        throwsA(isA<AuthException>()),
      );
      expect(container.read(sessionProvider).value, isNull);
      expect(tokens.token, isNull);
    });

    test('une déconnexion pendant la connexion l\'emporte', () async {
      await container.read(sessionProvider.future);
      final pending = Completer<String>();
      when(
        () => auth.requestToken(any(), any()),
      ).thenAnswer((_) => pending.future);
      when(() => auth.me()).thenAnswer((_) async => _jean);

      final login = container
          .read(sessionProvider.notifier)
          .login('jdupont', 'secret');
      await pumpEventQueue();
      await container.read(sessionProvider.notifier).logout();
      pending.complete('neuf');
      await login;

      expect(container.read(sessionProvider).value, isNull);
      expect(tokens.token, isNull);
      verifyNever(() => auth.me());
    });

    test('stockage sécurisé en panne : AppException', () async {
      await container.read(sessionProvider.future);
      tokens.failing = true;

      await expectLater(
        container.read(sessionProvider.notifier).login('jdupont', 'secret'),
        throwsA(isA<UnknownException>()),
      );
    });

    test('site injoignable après le jeton : pas de session à moitié', () async {
      await container.read(sessionProvider.future);
      when(
        () => auth.requestToken(any(), any()),
      ).thenAnswer((_) async => 'neuf');
      when(() => auth.me()).thenThrow(const NetworkException('hors ligne'));

      await expectLater(
        container.read(sessionProvider.notifier).login('jdupont', 'secret'),
        throwsA(isA<NetworkException>()),
      );
      expect(container.read(sessionProvider).value, isNull);
      expect(tokens.token, isNull);
    });
  });

  test('déconnexion : jeton et compte effacés', () async {
    storeSession('abc', 'DUPONT Jean');
    when(() => auth.me()).thenAnswer((_) async => _jean);
    await container.read(sessionProvider.future);

    await container.read(sessionProvider.notifier).logout();

    expect(container.read(sessionProvider).value, isNull);
    expect(tokens.token, isNull);
    expect(store.values[SessionNotifier.accountKey], isNull);
    expect(container.read(sessionExpiredProvider), isFalse);
  });

  group('jeton refusé à l\'écriture', () {
    test('ferme la session et la dit expirée', () async {
      storeSession('abc', 'DUPONT Jean');
      store.values['autre'] = 'gardé';
      when(() => auth.me()).thenAnswer((_) async => _jean);
      await container.read(sessionProvider.future);

      await authFailureHandler()();

      expect(container.read(sessionProvider).value, isNull);
      expect(container.read(sessionExpiredProvider), isTrue);
      expect(tokens.token, isNull);
      expect(store.values['autre'], 'gardé');
    });

    test('sans session ouverte : rien n\'expire', () async {
      await container.read(sessionProvider.future);

      await authFailureHandler()();

      expect(container.read(sessionExpiredProvider), isFalse);
    });

    test('une nouvelle connexion lève l\'expiration', () async {
      storeSession('abc', 'DUPONT Jean');
      when(() => auth.me()).thenAnswer((_) async => _jean);
      await container.read(sessionProvider.future);
      await authFailureHandler()();
      when(
        () => auth.requestToken(any(), any()),
      ).thenAnswer((_) async => 'neuf');

      await container.read(sessionProvider.notifier).login('jdupont', 'secret');

      expect(container.read(sessionExpiredProvider), isFalse);
      expect(container.read(sessionProvider).value, _jean);
    });

    test(
      'de bout en bout : un 403 « Invalid token » expire la session',
      () async {
        final client = HttpClient(
          config: const AppConfig(
            baseUrl: 'https://example.test',
            apiVersion: 'api/v1.0',
          ),
          tokenStorage: tokens,
          inner: MockClient(
            (_) async => http_package.Response(
              '{"error":"Forbiden","message":"Invalid token"}',
              403,
            ),
          ),
        );
        final real = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(auth),
            httpClientProvider.overrideWithValue(client),
            tokenStorageProvider.overrideWithValue(tokens),
            localStoreProvider.overrideWithValue(store),
          ],
          retry: noRetry,
        );
        addTearDown(real.dispose);
        storeSession('abc', 'DUPONT Jean');
        when(() => auth.me()).thenAnswer((_) async => _jean);
        expect(await real.read(sessionProvider.future), _jean);

        await expectLater(
          client.post('competition/resultat/submit', query: {'serie': 1}),
          throwsA(isA<AuthException>()),
        );
        await pumpEventQueue();

        expect(real.read(sessionProvider).value, isNull);
        expect(real.read(sessionExpiredProvider), isTrue);
        expect(tokens.token, isNull);
      },
    );
  });
}
