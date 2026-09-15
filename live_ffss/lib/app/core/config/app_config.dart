import 'package:flutter/foundation.dart';
import 'package:live_ffss/app/core/config/app_environment.dart';

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

  /// Construit une config directement depuis un [AppEnvironment], en
  /// contournant `AppEnvironment.resolve` et donc sa garde `kDebugMode`.
  /// Réservé à [fromEnv] et aux tests — n'appeler ceci ailleurs revient à
  /// rendre l'environnement de développement joignable hors debug.
  factory AppConfig.forEnvironment(AppEnvironment environment) => AppConfig(
        baseUrl: environment.baseUrl,
        apiVersion: environment.apiVersion,
        environment: environment,
      );

  /// [stored] est le choix mémorisé par l'utilisateur, relu du secure storage
  /// par `InitialBinding` avant que la config n'existe. Ignoré hors debug.
  factory AppConfig.fromEnv({AppEnvironment? stored}) {
    const dartDefine = String.fromEnvironment('ENV');
    return AppConfig.forEnvironment(
      AppEnvironment.resolve(
        isDebug: kDebugMode,
        stored: stored,
        dartDefine: dartDefine.isEmpty ? null : dartDefine,
      ),
    );
  }

  final String baseUrl;
  final String apiVersion;
  final AppEnvironment environment;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppConfig &&
          other.baseUrl == baseUrl &&
          other.apiVersion == apiVersion &&
          other.environment == environment;

  @override
  int get hashCode => Object.hash(baseUrl, apiVersion, environment);
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
  // Les athlètes d'une compétition, avec leur dossard. Un élément Participant a
  // la forme d'un athlète : le même DTO le décode.
  static const String participantList =
      'competition/evenement/:id/participants';
  static const String entryList = 'competition/engagement';
  static const String clubDetail = 'organisme/:id';
  static const String meetingSubmit = 'competition/:competition/reunion/submit';
  static const String meetingList = 'competition/:id/reunion';
  // Supprime la réunion ET, côté serveur, ses créneaux et ses courses — la
  // réponse ne le détaille pas.
  static const String meetingDelete = 'competition/reunion/:id/delete';
  // Cassé côté FFSS au 2026-08-31, comme `runSubmit` : tout GET répond
  // `success: false, filterByCreneau() only accepts arguments of type Creneau`.
  // Le repository retombe sur les courses déjà portées par la réponse
  // `reunion`, faute de quoi un seul créneau illisible viderait l'onglet.
  static const String runList = 'competition/reunion/creneau/:id/course';
  static const String slotSubmit =
      'competition/reunion/:reunion/creneau/submit';
  static const String slotDelete = 'competition/reunion/creneau/:id/delete';
  // Corrigé côté FFSS et vérifié en production le 2026-09-01, après deux
  // pannes successives (« Unknown named parameter $creneau », puis un id de
  // créneau résolu en `Evenement`). Attention : `runList` ci-dessus, lui,
  // reste cassé — la correction n'a porté que sur l'écriture.
  static const String runSubmit =
      'competition/reunion/creneau/:creneau/course/submit';
  static const String runDelete =
      'competition/reunion/creneau/course/:id/delete';
  // « Place » : un emplacement numéroté d'une course. Contrairement à
  // `course/submit`, ces trois routes fonctionnent — création, mise à jour et
  // suppression vérifiées en production le 2026-09-01. Le seul paramètre
  // métier attendu par `submit` est `numero` ; la documentation fédérale, qui
  // annonce nom/debut/fin/partie, recopie celle du créneau.
  static const String laneSubmit =
      'competition/reunion/creneau/course/:course/place/submit';
  static const String laneDelete =
      'competition/reunion/creneau/course/place/:id/delete';
  // La seule route qui montre QUI occupe une place : l'arbre `reunion` liste
  // les mêmes places avec `engagement: null` même quand elles sont prises
  // (vérifié le 2026-09-03). La synchronisation d'un tirage entre appareils
  // passe donc par ici, une place à la fois.
  static const String laneDetail =
      'competition/reunion/creneau/course/place/:id';
  // Une « serie » s'accroche à l'épreuve, pas à la course : c'est
  // `course/submit` qui porte ensuite le lien via son paramètre `serie`. Un
  // « resultat » se rattache à la série, à l'engagement ET à la place — c'est
  // `place` qui le pose dans le bon couloir. Vérifié le 2026-09-04.
  static const String heatSubmit = 'competition/serie/submit';
  static const String resultSubmit = 'competition/resultat/submit';
  static const String resultList = 'competition/resultat';
  // "Déroulement": one entry per (discipline, gender), carrying its categories
  // and its rounds (`parties`). The FFSS doc publishes these under
  // api.ffss.fr, but that host 301s to a 404 page — they resolve on the base
  // the rest of the app already uses.
  static const String raceFormatList = 'competition/:id/deroulement';
  static const String raceFormatSubmit =
      'competition/:competition/deroulement/submit';
  static const String raceFormatDelete = 'competition/deroulement/:id/delete';
  static const String raceFormatDetailSubmit =
      'competition/deroulement/:deroulement/partie/submit';
  static const String raceFormatDetailDelete =
      'competition/deroulement/partie/:id/delete';

  static String replacePath(String path, Map<String, String> params) {
    var result = path;
    params.forEach((key, value) {
      result = result.replaceAll(':$key', value);
    });
    return result;
  }
}
