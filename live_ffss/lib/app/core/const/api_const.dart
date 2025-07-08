class ApiConstants {
  ApiConstants._();

  static const String baseUrl = "https://ffss.fr/";
  static const String qualBaseUrl = "https://ffss.fr/";
  static const String apiVersion = "api/v1.0/";
  static const String requestToken = "requestToken";
  static const String me = "me";
  static const String competitionList = "competition/evenement";
  static const String baseCompetition = "competition/evenement/";
  static const String competitionRanking = "organisme/classement";
  static const String raceList = "competition/epreuve";
  static const String clubList = "competition/evenement/:id/organismes";
  static const String entryList = "competition/engagement";
  static const String heatList = "competition/serie";
  static const String clubDetail = "organisme/:id";
  static const String meetingSubmit = "competition/:competition/reunion/submit";
  static const String meetingList = "competition/:id/reunion";
  static const String meetingDelete = "competition/reunion/:id/delete";

  static String replacePath(String path, Map<String, dynamic> params) {
    String result = path;
    params.forEach((key, value) {
      result = result.replaceAll(':$key', value.toString());
    });
    return result;
  }
}
