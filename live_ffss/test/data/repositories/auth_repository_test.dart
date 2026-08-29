import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/core/network/token_storage.dart';
import 'package:live_ffss/app/data/datasources/auth_remote_datasource.dart';
import 'package:live_ffss/app/data/dtos/auth_token_dto.dart';
import 'package:live_ffss/app/data/dtos/user_dto.dart';
import 'package:live_ffss/app/data/repositories/auth_repository.dart';
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

  group('AuthRepository.restoreSession', () {
    test('returns null when nothing stored', () async {
      when(() => secure.read(key: 'user')).thenAnswer((_) async => null);

      expect(await repo.restoreSession(), isNull);
    });

    test('returns null when token is expired', () async {
      final past = DateTime.utc(2000, 1, 1).toIso8601String();
      when(() => secure.read(key: 'user')).thenAnswer((_) async => '''
{"token":"old","tokenExpiration":"$past","label":"X","type":"licensee","role":"user"}
''');
      when(() => tokens.clearToken()).thenAnswer((_) async {});
      when(() => secure.delete(key: 'user')).thenAnswer((_) async {});

      expect(await repo.restoreSession(), isNull);
      verify(() => tokens.clearToken()).called(1);
    });

    test('returns the persisted User when token is still valid', () async {
      final future = DateTime.utc(2099, 12, 31).toIso8601String();
      when(() => secure.read(key: 'user')).thenAnswer((_) async => '''
{"token":"good","tokenExpiration":"$future","label":"X","type":"licensee","role":"admin"}
''');
      when(() => ds.getCurrentUser()).thenAnswer((_) async => const UserDto(
            label: 'X',
            type: 'licencie',
            data: UserDtoData(role: 'admin'),
          ));

      final user = await repo.restoreSession();

      expect(user, isNotNull);
      expect(user!.token, 'good');
      expect(user.role, UserRole.admin);
    });
  });

  // The date `requestToken` hands back proves nothing: a token issued with
  // `expiration: "2026-08-30"` was already dead hours later. And FFSS never
  // says so on a read — it serves an anonymous 200 — so only asking who we are
  // reveals a session that ended.
  group('AuthRepository.restoreSession checks the session is still real', () {
    final future = DateTime.utc(2099, 12, 31).toIso8601String();

    void storedSession() {
      when(() => secure.read(key: 'user')).thenAnswer((_) async => '''
{"token":"good","tokenExpiration":"$future","label":"X","type":"licensee","role":"admin"}
''');
      when(() => tokens.clearToken()).thenAnswer((_) async {});
      when(() => secure.delete(key: 'user')).thenAnswer((_) async {});
    }

    test('drops the session when the server answers anonymously', () async {
      storedSession();
      // What FFSS returns for a dead token: no licencie, no organisme.
      when(() => ds.getCurrentUser()).thenAnswer((_) async => const UserDto(
            label: 'Utilisateur Anonyme',
            type: 'public',
            data: UserDtoData(role: 'user'),
          ));

      expect(await repo.restoreSession(), isNull);
      verify(() => tokens.clearToken()).called(1);
      verify(() => secure.delete(key: 'user')).called(1);
    });

    test('keeps the session when the server names a real account', () async {
      storedSession();
      when(() => ds.getCurrentUser()).thenAnswer((_) async => const UserDto(
            label: 'FFSS',
            type: 'organisme',
            data: UserDtoData(role: 'admin'),
          ));

      expect(await repo.restoreSession(), isNotNull);
      verifyNever(() => tokens.clearToken());
    });

    test('keeps the session when the check cannot be made', () async {
      // Offline is not proof of anything. Signing the operator out on a dead
      // network would be worse than the stale session this guards against.
      storedSession();
      when(() => ds.getCurrentUser())
          .thenThrow(const NetworkException('offline'));

      expect(await repo.restoreSession(), isNotNull);
      verifyNever(() => tokens.clearToken());
    });

    test('keeps the session rather than hanging on a silent network', () async {
      storedSession();
      when(() => ds.getCurrentUser())
          .thenAnswer((_) => Future<UserDto>.delayed(
              const Duration(minutes: 1),
              () => const UserDto(
                  label: 'X', type: 'licencie', data: UserDtoData(role: 'user'))));

      // Startup must not wait on a socket that never answers.
      expect(await repo.restoreSession(), isNotNull);
      verifyNever(() => tokens.clearToken());
    });

    test('an expired date short-circuits before any call', () async {
      final past = DateTime.utc(2000, 1, 1).toIso8601String();
      when(() => secure.read(key: 'user')).thenAnswer((_) async => '''
{"token":"old","tokenExpiration":"$past","label":"X","type":"licensee","role":"user"}
''');
      when(() => tokens.clearToken()).thenAnswer((_) async {});
      when(() => secure.delete(key: 'user')).thenAnswer((_) async {});

      expect(await repo.restoreSession(), isNull);
      verifyNever(() => ds.getCurrentUser());
    });
  });
}
