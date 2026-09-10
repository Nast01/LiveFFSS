import 'package:get/get.dart';
import 'package:live_ffss/app/core/config/app_environment.dart';
import 'package:live_ffss/app/core/config/environment_storage.dart';
import 'package:live_ffss/app/core/di/initial_binding.dart';
import 'package:live_ffss/app/routes/app_pages.dart';

/// Bascule d'environnement : un démarrage à froid sans relancer le processus.
///
/// Appelé depuis une vue, jamais depuis un contrôleur — l'étape 3 détruit le
/// contrôleur appelant, et une méthode ne survit pas à sa propre destruction.
abstract class AppRestart {
  AppRestart._();

  static Future<void> switchTo(AppEnvironment environment) async {
    // 1. Avant le deleteAll, qui désenregistre EnvironmentStorage.
    await Get.find<EnvironmentStorage>().save(environment);

    // 2. Vide la pile de vues. Entre le deleteAll et le register, aucun
    // `Get.find` ne doit s'exécuter : /restarting n'a ni binding ni
    // contrôleur, ce qui rend cette fenêtre vide par construction.
    await Get.offAllNamed<void>(Routes.restarting);

    // 3-4. Le conteneur repart de zéro, avec le nouvel environnement.
    Get.deleteAll(force: true);
    await InitialBinding.register();

    await Get.offAllNamed<void>(Routes.home);
  }
}
