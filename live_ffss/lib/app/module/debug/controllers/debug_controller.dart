import 'package:get/get.dart';
import 'package:live_ffss/app/core/config/app_config.dart';
import 'package:live_ffss/app/core/config/app_environment.dart';

/// L'état de l'écran de debug. Purement descriptif : la bascule elle-même
/// détruit ce contrôleur, elle appartient donc à la vue.
class DebugController extends GetxController {
  DebugController(this._config);

  final AppConfig _config;

  AppEnvironment get current => _config.environment;

  List<AppEnvironment> get environments => AppEnvironment.values;

  String get endpoint => _config.environment.endpoint;

  String get storagePrefixLabel {
    final prefix = _config.environment.storagePrefix;
    return prefix.isEmpty ? 'aucun' : prefix;
  }
}
