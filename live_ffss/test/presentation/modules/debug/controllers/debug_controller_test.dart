import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/config/app_config.dart';
import 'package:live_ffss/app/core/config/app_environment.dart';
import 'package:live_ffss/app/module/debug/controllers/debug_controller.dart';

void main() {
  group('DebugController', () {
    test('expose l\'environnement courant et son endpoint', () {
      final controller = DebugController(
        AppConfig.forEnvironment(AppEnvironment.development),
      );

      expect(controller.current, AppEnvironment.development);
      expect(controller.endpoint, 'https://site.ffss.io/api/v1.0/');
    });

    test('propose les deux environnements', () {
      final controller = DebugController(const AppConfig.production());

      expect(controller.environments, AppEnvironment.values);
      expect(controller.environments.length, 2);
    });

    test('nomme le prefixe vide de la production plutot que de l\'afficher',
        () {
      final controller = DebugController(const AppConfig.production());

      expect(controller.storagePrefixLabel, 'aucun');
    });

    test('affiche le prefixe du developpement tel quel', () {
      final controller = DebugController(
        AppConfig.forEnvironment(AppEnvironment.development),
      );

      expect(controller.storagePrefixLabel, 'dev_');
    });
  });
}
