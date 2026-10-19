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

  /// L'environnement choisi (`appConfigProvider`).
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
  static const String result = 'competition/resultat/:id';
  static const String resultSubmit = 'competition/resultat/submit';
  static const String engagementSubmit = 'competition/engagement/:id/submit';
  static const String series = 'competition/serie/:id';
  static const String eventList = 'competition/epreuve';
  static const String eventSeries = 'competition/serie';
  static const String participants = 'competition/evenement/:id/participants';
  static const String officials = 'competition/evenement/:id/officiels';
  static const String requestToken = 'requestToken';
  static const String me = 'me';
  static const String competitionMe = 'competition/evenement/:id/me';

  static String replacePath(String path, Map<String, String> params) {
    var result = path;
    params.forEach((key, value) {
      result = result.replaceAll(':$key', value);
    });
    return result;
  }
}
