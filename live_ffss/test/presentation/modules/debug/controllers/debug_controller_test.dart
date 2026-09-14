import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/config/app_config.dart';
import 'package:live_ffss/app/core/config/app_environment.dart';
import 'package:live_ffss/app/core/network/token_storage.dart';
import 'package:live_ffss/app/data/repositories/auth_repository.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import 'package:live_ffss/app/domain/models/session_probe.dart';
import 'package:live_ffss/app/domain/models/user.dart';
import 'package:live_ffss/app/module/debug/controllers/debug_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockUserService extends Mock implements UserService {}

class _MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  group('DebugController', () {
    test('expose l\'environnement courant et son endpoint', () {
      final controller = DebugController(
        AppConfig.forEnvironment(AppEnvironment.development),
        _MockAuthRepository(),
        _MockUserService(),
        _MockTokenStorage(),
      );

      expect(controller.current, AppEnvironment.development);
      expect(controller.endpoint, 'https://site.ffss.io/api/v1.0/');
    });

    test('propose les deux environnements', () {
      final controller = DebugController(
        const AppConfig.production(),
        _MockAuthRepository(),
        _MockUserService(),
        _MockTokenStorage(),
      );

      expect(controller.environments, AppEnvironment.values);
      expect(controller.environments.length, 2);
    });

    test('nomme le prefixe vide de la production plutot que de l\'afficher',
        () {
      final controller = DebugController(
        const AppConfig.production(),
        _MockAuthRepository(),
        _MockUserService(),
        _MockTokenStorage(),
      );

      expect(controller.storagePrefixLabel, 'aucun');
    });

    test('affiche le prefixe du developpement tel quel', () {
      final controller = DebugController(
        AppConfig.forEnvironment(AppEnvironment.development),
        _MockAuthRepository(),
        _MockUserService(),
        _MockTokenStorage(),
      );

      expect(controller.storagePrefixLabel, 'dev_');
    });
  });

  group('DebugController — session', () {
    late _MockAuthRepository auth;
    late _MockUserService userService;
    late _MockTokenStorage tokenStorage;
    late DebugController controller;

    setUp(() {
      auth = _MockAuthRepository();
      userService = _MockUserService();
      tokenStorage = _MockTokenStorage();
      controller = DebugController(
        const AppConfig.production(),
        auth,
        userService,
        tokenStorage,
      );
    });

    test('la sonde part au repos', () {
      expect(controller.isProbing.value, isFalse);
      expect(controller.probe.value, isNull);
    });

    test('runProbe stocke le resultat et retombe au repos', () async {
      when(() => auth.probeSession()).thenAnswer(
        (_) async => const SessionProbe(
          outcome: SessionProbeOutcome.anonymous,
          label: 'Utilisateur Anonyme',
        ),
      );

      await controller.runProbe();

      expect(controller.probe.value?.outcome, SessionProbeOutcome.anonymous);
      expect(controller.isProbing.value, isFalse);
    });

    test('loadToken lit le jeton du stockage', () async {
      when(() => tokenStorage.getToken()).thenAnswer((_) async => 'abc123');

      await controller.loadToken();

      expect(controller.token.value, 'abc123');
    });

    test('l\'expiration annoncee vient du profil en memoire', () {
      final user = User(
        token: 'abc',
        tokenExpiration: DateTime.utc(2030),
        label: 'Doe John',
        type: UserType.licensee,
        role: UserRole.user,
      );
      when(() => userService.currentUser).thenReturn(Rx<User?>(user));

      expect(controller.announcedExpiration, DateTime.utc(2030));
    });
  });
}
