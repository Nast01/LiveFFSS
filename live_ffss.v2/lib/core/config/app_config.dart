import 'package:live_ffss_v2/core/config/app_environment.dart';

class AppConfig {
  const AppConfig({
    required this.baseUrl,
    required this.apiVersion,
    this.environment = AppEnvironment.production,
  });

  const AppConfig.production()
    : baseUrl = 'https://ffss.fr',
      apiVersion = 'api/v1.0',
      environment = AppEnvironment.production;

  /// Réservé aux tests au lot 1 : l'app ne parle qu'à la production tant que
  /// le choix de l'environnement n'existe pas (lot 4).
  factory AppConfig.forEnvironment(AppEnvironment environment) => AppConfig(
    baseUrl: environment.baseUrl,
    apiVersion: environment.apiVersion,
    environment: environment,
  );

  final String baseUrl;
  final String apiVersion;
  final AppEnvironment environment;
}

class ApiEndpoints {
  ApiEndpoints._();

  static const String competitionList = 'competition/evenement';
  static const String meetingList = 'competition/:id/reunion';
  static const String progressionList = 'competition/:id/deroulement';
  static const String meetingItem = 'competition/reunion/creneau/:id';
  static const String lane = 'competition/reunion/creneau/course/place/:id';
  static const String competition = 'competition/evenement/:id';

  static String replacePath(String path, Map<String, String> params) {
    var result = path;
    params.forEach((key, value) {
      result = result.replaceAll(':$key', value);
    });
    return result;
  }
}
