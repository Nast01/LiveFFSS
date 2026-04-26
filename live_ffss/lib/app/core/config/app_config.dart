class AppConfig {
  const AppConfig({
    required this.baseUrl,
    required this.apiVersion,
  });

  const AppConfig.production()
      : baseUrl = 'https://ffss.fr',
        apiVersion = 'api/v1.0';

  factory AppConfig.fromEnv() {
    const env = String.fromEnvironment('ENV', defaultValue: 'production');
    return switch (env) {
      'production' => const AppConfig.production(),
      _ => const AppConfig.production(),
    };
  }

  final String baseUrl;
  final String apiVersion;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppConfig &&
          other.baseUrl == baseUrl &&
          other.apiVersion == apiVersion;

  @override
  int get hashCode => Object.hash(baseUrl, apiVersion);
}

class ApiEndpoints {
  ApiEndpoints._();

  static const String requestToken = 'requestToken';
  static const String me = 'me';
  static const String competitionList = 'competition/evenement';
  static const String competitionDetail = 'competition/evenement/:id';
  static const String competitionRanking = 'organisme/classement';
  static const String raceList = 'competition/epreuve';
  static const String clubList = 'competition/evenement/:id/organismes';
  static const String entryList = 'competition/engagement';
  static const String heatList = 'competition/serie';
  static const String clubDetail = 'organisme/:id';
  static const String meetingSubmit =
      'competition/:competition/reunion/submit';
  static const String meetingList = 'competition/:id/reunion';
  static const String meetingDelete = 'competition/reunion/:id/delete';
  static const String runList = 'competition/reunion/creneau/:id/course';

  static String replacePath(String path, Map<String, String> params) {
    var result = path;
    params.forEach((key, value) {
      result = result.replaceAll(':$key', value);
    });
    return result;
  }
}
