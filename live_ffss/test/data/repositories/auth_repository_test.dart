import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/config/app_environment.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/core/network/token_storage.dart';
import 'package:live_ffss/app/data/datasources/auth_remote_datasource.dart';
import 'package:live_ffss/app/data/dtos/auth_token_dto.dart';
import 'package:live_ffss/app/data/dtos/user_dto.dart';
import 'package:live_ffss/app/data/repositories/auth_repository.dart';
import 'package:live_ffss/app/domain/models/session_probe.dart';
import 'package:live_ffss/app/domain/models/user.dart';
import 'package:mocktail/mocktail.dart';

class _MockDataSource extends Mock implements AuthRemoteDataSource {}

class _MockTokenStorage extends Mock implements TokenStorage {}

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockDataSource ds;
  late _MockTokenStorage tokens;
  late _MockSecureStorage secure;
  late AuthRepository repo;

  setUp(() {
    ds = _MockDataSource();
    tokens = _MockTokenStorage();
    secure = _MockSecureStorage();
    repo = AuthRepositoryImpl(
      dataSource: ds,
      tokenStorage: tokens,
      secureStorage: secure,
    );
  });

  group('AuthRepository.probeSession', () {
    test('un compte licencie est une session vivante', () async {
      when(() => ds.getCurrentUser()).thenAnswer((_) async => const UserDto(
            label: 'Doe John',
            type: 'licencie',
            data: UserDtoData(role: 'user', lastName: 'Doe', firstName: 'John'),
          ));

      final probe = await repo.probeSession();

      expect(probe.outcome, SessionProbeOutcome.signedIn);
      expect(probe.label, 'Doe John');
    });

    test('un organisme est une session vivante', () async {
      when(() => ds.getCurrentUser()).thenAnswer((_) async => const UserDto(
            label: 'SNS 42',
            type: 'organisme',
            data: UserDtoData(role: 'admin'),
          ));

      final probe = await repo.probeSession();

      expect(probe.outcome, SessionProbeOutcome.signedIn);
    });

    test('tout autre type est l\'identite anonyme', () async {
      when(() => ds.getCurrentUser()).thenAnswer((_) async => const UserDto(
            label: 'Utilisateur Anonyme',
            type: 'anonyme',
            data: UserDtoData(role: 'user'),
          ));

      final probe = await repo.probeSession();

      expect(probe.outcome, SessionProbeOutcome.anonymous);
      expect(probe.label, 'Utilisateur Anonyme');
    });

    test('une erreur API laisse la session indeterminee, pas morte', () async {
      when(() => ds.getCurrentUser())
          .thenThrow(const NetworkException('hors ligne'));

      final probe = await repo.probeSession();

      expect(probe.outcome, SessionProbeOutcome.unreachable);
      expect(probe.message, 'hors ligne');
    });

    test('un timeout laisse la session indeterminee, pas morte', () async {
      when(() => ds.getCurrentUser()).thenThrow(TimeoutException('trop long'));

      final probe = await repo.probeSession();

      expect(probe.outcome, SessionProbeOutcome.unreachable);
    });
  });

  group('AuthRepository.login', () {
    test('orchestrates: requestToken -> setToken -> getCurrentUser -> persist',
        () async {
      when(() => ds.requestToken(login: 'a', password: 'b')).thenAnswer(
          (_) async => const AuthTokenDto(
              token: 'T', expiration: '2030-01-01T00:00:00.000Z'));
      when(() => tokens.setToken('T')).thenAnswer((_) async {});
      when(() => ds.getCurrentUser()).thenAnswer((_) async => const UserDto(
            label: 'Doe John',
            type: 'licencie',
            data: UserDtoData(role: 'user', lastName: 'Doe', firstName: 'John'),
          ));
      when(() => secure.write(key: 'user', value: any(named: 'value')))
          .thenAnswer((_) async {});

      final user = await repo.login(login: 'a', password: 'b');

      expect(user.token, 'T');
      expect(user.label, 'Doe John');
      expect(user.firstName, 'John');
      expect(user.tokenExpiration, DateTime.utc(2030, 1, 1));
      verifyInOrder([
        () => ds.requestToken(login: 'a', password: 'b'),
        () => tokens.setToken('T'),
        () => ds.getCurrentUser(),
        () => secure.write(key: 'user', value: any(named: 'value')),
      ]);
    });

    test('emits the new user on userStream', () async {
      when(() => ds.requestToken(login: 'a', password: 'b')).thenAnswer(
          (_) async => const AuthTokenDto(
              token: 'T', expiration: '2030-01-01T00:00:00Z'));
      when(() => tokens.setToken(any())).thenAnswer((_) async {});
      when(() => ds.getCurrentUser()).thenAnswer((_) async => const UserDto(
            label: 'X',
            type: 'organisme',
            data: UserDtoData(role: 'admin'),
          ));
      when(() => secure.write(key: 'user', value: any(named: 'value')))
          .thenAnswer((_) async {});

      final stream = repo.userStream;
      final emitted = stream.first;

      await repo.login(login: 'a', password: 'b');

      final user = await emitted;
      expect(user, isNotNull);
      expect(user!.role, UserRole.admin);
    });
  });

  group('AuthRepository.logout', () {
    test('clears token + persisted user, emits null on userStream', () async {
      when(() => tokens.clearToken()).thenAnswer((_) async {});
      when(() => secure.delete(key: 'user')).thenAnswer((_) async {});

      final stream = repo.userStream;
      final emitted = stream.first;

      await repo.logout();

      verify(() => tokens.clearToken()).called(1);
      verify(() => secure.delete(key: 'user')).called(1);
      expect(await emitted, isNull);
    });
  });

  group('AuthRepository.restoreStoredSession', () {
    test('returns null when nothing stored', () async {
      when(() => secure.read(key: 'user')).thenAnswer((_) async => null);

      expect(await repo.restoreStoredSession(), isNull);
    });

    test('returns null when token is expired', () async {
      final past = DateTime.utc(2000, 1, 1).toIso8601String();
      when(() => secure.read(key: 'user')).thenAnswer((_) async => '''
{"token":"old","tokenExpiration":"$past","label":"X","type":"licensee","role":"user"}
''');
      when(() => tokens.clearToken()).thenAnswer((_) async {});
      when(() => secure.delete(key: 'user')).thenAnswer((_) async {});

      expect(await repo.restoreStoredSession(), isNull);
      verify(() => tokens.clearToken()).called(1);
    });

    test('returns the persisted User when token is still valid', () async {
      final future = DateTime.utc(2099, 12, 31).toIso8601String();
      when(() => secure.read(key: 'user')).thenAnswer((_) async => '''
{"token":"good","tokenExpiration":"$future","label":"X","type":"licensee","role":"admin"}
''');

      final user = await repo.restoreStoredSession();

      expect(user, isNotNull);
      expect(user!.token, 'good');
      expect(user.role, UserRole.admin);
    });

    // Tout l'objet de la separation : le demarrage ne touche pas au reseau.
    test('ne demande rien au serveur', () async {
      final future = DateTime.utc(2099, 12, 31).toIso8601String();
      when(() => secure.read(key: 'user')).thenAnswer((_) async => '''
{"token":"good","tokenExpiration":"$future","label":"X","type":"licensee","role":"admin"}
''');

      await repo.restoreStoredSession();

      verifyNever(() => ds.getCurrentUser());
    });
  });

  // The date `requestToken` hands back proves nothing: a token issued with
  // `expiration: "2026-08-30"` was already dead hours later. And FFSS never
  // says so on a read — it serves an anonymous 200 — so only asking who we are
  // reveals a session that ended.
  // La date que `requestToken` rend ne prouve rien : un jeton emis avec
  // `expiration: "2026-08-30"` etait deja mort quelques heures plus tard. Et
  // FFSS ne le dit jamais sur une lecture — il sert un 200 anonyme — donc seul
  // « qui suis-je » revele une session terminee. Cette verification tourne
  // apres le premier rendu, jamais avant.
  group('AuthRepository.revalidateSession', () {
    void heldToken() {
      when(() => tokens.getToken()).thenAnswer((_) async => 'good');
      when(() => tokens.clearToken()).thenAnswer((_) async {});
      when(() => secure.delete(key: 'user')).thenAnswer((_) async {});
    }

    test('ferme la session quand le serveur repond anonymement', () async {
      heldToken();
      // Ce que FFSS rend pour un jeton mort : ni licencie, ni organisme.
      when(() => ds.getCurrentUser()).thenAnswer((_) async => const UserDto(
            label: 'Utilisateur Anonyme',
            type: 'public',
            data: UserDtoData(role: 'user'),
          ));
      final emitted = repo.userStream.first;

      await repo.revalidateSession();

      verify(() => tokens.clearToken()).called(1);
      verify(() => secure.delete(key: 'user')).called(1);
      // La fermeture passe par le flux : c'est ce que UserService ecoute.
      expect(await emitted, isNull);
    });

    test('garde la session quand le serveur nomme un vrai compte', () async {
      heldToken();
      when(() => ds.getCurrentUser()).thenAnswer((_) async => const UserDto(
            label: 'FFSS',
            type: 'organisme',
            data: UserDtoData(role: 'admin'),
          ));

      await repo.revalidateSession();

      verifyNever(() => tokens.clearToken());
    });

    test('garde la session quand la verification est impossible', () async {
      // Etre hors ligne ne prouve rien. Deconnecter sur un reseau mort serait
      // pire que la session perimee contre laquelle ceci protege.
      heldToken();
      when(() => ds.getCurrentUser())
          .thenThrow(const NetworkException('offline'));

      await repo.revalidateSession();

      verifyNever(() => tokens.clearToken());
    });

    test('garde la session plutot que de pendre sur un reseau muet', () async {
      heldToken();
      when(() => ds.getCurrentUser()).thenAnswer((_) => Future<UserDto>.delayed(
          const Duration(minutes: 1),
          () => const UserDto(
              label: 'X', type: 'licencie', data: UserDtoData(role: 'user'))));

      await repo.revalidateSession();

      verifyNever(() => tokens.clearToken());
    });

    test('sans jeton memorise, aucun appel', () async {
      when(() => tokens.getToken()).thenAnswer((_) async => null);

      await repo.revalidateSession();

      verifyNever(() => ds.getCurrentUser());
    });

    // La sonde porte le jeton d'avant : une connexion survenue pendant qu'elle
    // etait en vol ne doit pas se faire fermer par sa reponse.
    test('une connexion survenue pendant la sonde n est pas fermee', () async {
      var reads = 0;
      when(() => tokens.getToken()).thenAnswer((_) async {
        reads++;
        return reads == 1 ? 'ancien' : 'tout-neuf';
      });
      when(() => tokens.clearToken()).thenAnswer((_) async {});
      when(() => secure.delete(key: 'user')).thenAnswer((_) async {});
      when(() => ds.getCurrentUser()).thenAnswer((_) async => const UserDto(
            label: 'Utilisateur Anonyme',
            type: 'public',
            data: UserDtoData(role: 'user'),
          ));

      await repo.revalidateSession();

      verifyNever(() => tokens.clearToken());
    });
  });

  group('AuthRepository cloisonne par environnement', () {
    test('lit le profil sous la cle prefixee', () async {
      final scoped = AuthRepositoryImpl(
        dataSource: ds,
        tokenStorage: tokens,
        secureStorage: secure,
        environment: AppEnvironment.development,
      );
      when(() => secure.read(key: 'dev_user')).thenAnswer((_) async => null);

      await scoped.restoreStoredSession();

      verify(() => secure.read(key: 'dev_user')).called(1);
    });
  });

  // Le controleur de flux n'etait jamais ferme : il survivait a chaque bascule
  // d'environnement, qui est le seul moment ou ce depot est jete.
  group('AuthRepository.dispose', () {
    test('ferme userStream', () async {
      var closed = false;
      repo.userStream.listen((_) {}, onDone: () => closed = true);

      await repo.dispose();
      await Future<void>.delayed(Duration.zero);

      expect(closed, isTrue);
    });
  });
}
