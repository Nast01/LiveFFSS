import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/network/token_storage.dart';
import 'package:mocktail/mocktail.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockSecureStorage secureStorage;
  late TokenStorage tokenStorage;

  setUp(() {
    secureStorage = _MockSecureStorage();
    tokenStorage = TokenStorage(secureStorage);
  });

  group('TokenStorage', () {
    test('getToken reads the "token" key', () async {
      when(() => secureStorage.read(key: 'token'))
          .thenAnswer((_) async => 'abc');

      final token = await tokenStorage.getToken();

      expect(token, 'abc');
      verify(() => secureStorage.read(key: 'token')).called(1);
    });

    test('getToken returns null when no token stored', () async {
      when(() => secureStorage.read(key: 'token'))
          .thenAnswer((_) async => null);

      final token = await tokenStorage.getToken();

      expect(token, isNull);
    });

    test('setToken writes to the "token" key', () async {
      when(() => secureStorage.write(key: 'token', value: 'xyz'))
          .thenAnswer((_) async {});

      await tokenStorage.setToken('xyz');

      verify(() => secureStorage.write(key: 'token', value: 'xyz')).called(1);
    });

    test('clearToken deletes the "token" key', () async {
      when(() => secureStorage.delete(key: 'token'))
          .thenAnswer((_) async {});

      await tokenStorage.clearToken();

      verify(() => secureStorage.delete(key: 'token')).called(1);
    });
  });
}
