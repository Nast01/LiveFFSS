import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/config/app_environment.dart';
import 'package:live_ffss/app/core/config/environment_storage.dart';
import 'package:mocktail/mocktail.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockSecureStorage secureStorage;
  late EnvironmentStorage environmentStorage;

  setUp(() {
    secureStorage = _MockSecureStorage();
    environmentStorage = EnvironmentStorage(secureStorage);
  });

  group('EnvironmentStorage.read', () {
    test('relit un environnement enregistre', () async {
      when(() => secureStorage.read(key: 'api_environment'))
          .thenAnswer((_) async => 'development');

      expect(await environmentStorage.read(), AppEnvironment.development);
    });

    test('une valeur absente se lit null', () async {
      when(() => secureStorage.read(key: 'api_environment'))
          .thenAnswer((_) async => null);

      expect(await environmentStorage.read(), isNull);
    });

    test('une valeur inconnue se lit null au lieu de lever', () async {
      when(() => secureStorage.read(key: 'api_environment'))
          .thenAnswer((_) async => 'staging');

      expect(await environmentStorage.read(), isNull);
    });
  });

  group('EnvironmentStorage.save', () {
    test('ecrit le nom de l\'enum sous la cle non prefixee', () async {
      when(() => secureStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          )).thenAnswer((_) async {});

      await environmentStorage.save(AppEnvironment.development);

      verify(() => secureStorage.write(
            key: 'api_environment',
            value: 'development',
          )).called(1);
    });
  });
}
