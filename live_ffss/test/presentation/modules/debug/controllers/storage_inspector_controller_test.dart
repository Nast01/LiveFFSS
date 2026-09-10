import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/config/app_config.dart';
import 'package:live_ffss/app/core/config/app_environment.dart';
import 'package:live_ffss/app/module/debug/controllers/storage_inspector_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockSecureStorage storage;

  setUp(() {
    storage = _MockSecureStorage();
    when(() => storage.readAll()).thenAnswer((_) async => {
          'token': 'T',
          'programme_7': '{"a":1}',
          'favorite_competitions': '[1,2]',
          'dev_token': 'D',
          'language': 'fr',
          'api_environment': 'production',
        });
  });

  group('StorageInspectorController.load', () {
    test('groupe les cles en trois sections, triees', () async {
      final controller = StorageInspectorController(
        storage,
        const AppConfig.production(),
      );

      await controller.load();

      expect(
        controller.currentEnvironment.map((e) => e.key).toList(),
        ['favorite_competitions', 'programme_7', 'token'],
      );
      expect(controller.otherEnvironment.map((e) => e.key).toList(),
          ['dev_token']);
      expect(controller.global.map((e) => e.key).toList(),
          ['api_environment', 'language']);
    });

    test('le point de vue change avec l\'environnement courant', () async {
      final controller = StorageInspectorController(
        storage,
        AppConfig.forEnvironment(AppEnvironment.development),
      );

      await controller.load();

      expect(
          controller.currentEnvironment.map((e) => e.key).toList(),
          ['dev_token']);
      expect(controller.otherEnvironment.length, 3);
    });

    test('la taille est celle des octets UTF-8', () async {
      final controller = StorageInspectorController(
        storage,
        const AppConfig.production(),
      );

      await controller.load();

      final entry =
          controller.currentEnvironment.firstWhere((e) => e.key == 'token');
      expect(entry.sizeInBytes, 1);
    });
  });

  group('StorageInspectorController.delete', () {
    test('supprime la cle puis recharge', () async {
      when(() => storage.delete(key: any(named: 'key')))
          .thenAnswer((_) async {});
      final controller = StorageInspectorController(
        storage,
        const AppConfig.production(),
      );
      await controller.load();

      await controller.delete('token');

      verify(() => storage.delete(key: 'token')).called(1);
      verify(() => storage.readAll()).called(2);
    });
  });

  group('StorageInspectorController.prettify', () {
    test('re-indente du JSON', () {
      expect(
        StorageInspectorController.prettify('{"a":1}'),
        '{\n  "a": 1\n}',
      );
    });

    test('laisse intacte une valeur qui n\'est pas du JSON', () {
      expect(StorageInspectorController.prettify('fr'), 'fr');
    });
  });
}
