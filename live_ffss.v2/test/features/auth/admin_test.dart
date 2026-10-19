import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/config/app_environment.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/network/http_client.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/repositories/auth_repository.dart';
import 'package:live_ffss_v2/domain/account.dart';
import 'package:live_ffss_v2/features/auth/admin.dart';
import 'package:live_ffss_v2/features/auth/session.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/in_memory_local_store.dart';
import '../../support/in_memory_token_storage.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockHttpClient extends Mock implements HttpClient {}

const _admin = Account(
  label: 'ORGANISME TEST',
  type: 'organisme',
  role: 'admin',
);
const _jean = Account(label: 'DUPONT Jean', type: 'licencie', role: 'user');

void main() {
  late _MockAuthRepository auth;
  late InMemoryTokenStorage tokens;
  late InMemoryLocalStore store;
  late ProviderContainer container;

  setUp(() {
    auth = _MockAuthRepository();
    tokens = InMemoryTokenStorage();
    store = InMemoryLocalStore();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        httpClientProvider.overrideWithValue(_MockHttpClient()),
        tokenStorageProvider.overrideWithValue(tokens),
        localStoreProvider.overrideWithValue(store),
      ],
      retry: noRetry,
    );
    addTearDown(container.dispose);
    when(() => auth.requestToken(any(), any())).thenAnswer((_) async => 'neuf');
  });

  Future<void> loginAs(Account account) async {
    when(() => auth.me()).thenAnswer((_) async => account);
    await container.read(sessionProvider.future);
    await container.read(sessionProvider.notifier).login('x', 'secret');
  }

  group('isAdminProvider', () {
    test('personne de connecté : non', () async {
      await container.read(sessionProvider.future);

      expect(container.read(isAdminProvider), isFalse);
    });

    test('compte admin : oui', () async {
      await loginAs(_admin);

      expect(container.read(isAdminProvider), isTrue);
    });

    test('licencié : non', () async {
      await loginAs(_jean);

      expect(container.read(isAdminProvider), isFalse);
    });

    test('lancement hors ligne d\'un admin : oui', () async {
      tokens.token = 'abc';
      store.values[SessionNotifier.accountKey] = 'ORGANISME TEST';
      store.values[SessionNotifier.roleKey] = 'admin';
      when(() => auth.me()).thenThrow(const NetworkException('hors ligne'));

      await container.read(sessionProvider.future);

      expect(container.read(isAdminProvider), isTrue);
    });
  });

  group('adminSeenProvider', () {
    test('jamais d\'admin sur ce téléphone : non', () async {
      await container.read(sessionProvider.future);

      expect(await container.read(adminSeenProvider.future), isFalse);
    });

    test('un licencié ne pose pas le drapeau', () async {
      container.listen(adminSeenProvider, (_, _) {});
      await loginAs(_jean);

      expect(await container.read(adminSeenProvider.future), isFalse);
      expect(store.values[AdminSeenNotifier.storageKey], isNull);
    });

    test('posé à la connexion admin, gardé après la déconnexion', () async {
      container.listen(adminSeenProvider, (_, _) {});
      await loginAs(_admin);

      expect(await container.read(adminSeenProvider.future), isTrue);
      expect(store.values[AdminSeenNotifier.storageKey], 'true');

      await container.read(sessionProvider.notifier).logout();

      expect(await container.read(adminSeenProvider.future), isTrue);
      expect(store.values[AdminSeenNotifier.storageKey], 'true');
    });

    test('relu au lancement suivant, sans session', () async {
      store.values[AdminSeenNotifier.storageKey] = 'true';

      expect(await container.read(adminSeenProvider.future), isTrue);
    });

    test('clé globale : pas de préfixe par serveur', () {
      expect(AppEnvironment.globalKeys, contains(AdminSeenNotifier.storageKey));
      expect(AppEnvironment.owner(AdminSeenNotifier.storageKey), isNull);
    });
  });
}
