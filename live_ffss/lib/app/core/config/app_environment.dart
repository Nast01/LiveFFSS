/// Les deux backends FFSS. Le second n'est joignable qu'en build debug — voir
/// [resolve].
enum AppEnvironment {
  production(
    baseUrl: 'https://ffss.fr',
    apiVersion: 'api/v1.0',
    storagePrefix: '',
    label: 'Production',
  ),
  development(
    baseUrl: 'https://site.ffss.io',
    apiVersion: 'api/v1.0',
    storagePrefix: 'dev_',
    label: 'Développement',
  );

  const AppEnvironment({
    required this.baseUrl,
    required this.apiVersion,
    required this.storagePrefix,
    required this.label,
  });

  final String baseUrl;
  final String apiVersion;

  /// Préfixe des clés du secure storage. Vide pour la production : c'est ce
  /// qui rend le cloisonnement transparent pour les téléphones déjà déployés,
  /// dont les clés restent lisibles telles quelles.
  final String storagePrefix;

  final String label;

  /// L'endpoint tel qu'il apparaît dans la documentation fédérale.
  String get endpoint => '$baseUrl/$apiVersion/';

  /// La clé qui porte l'environnement choisi. Jamais préfixée : c'est elle qui
  /// détermine le préfixe, elle ne peut pas vivre à l'intérieur.
  static const String environmentKey = 'api_environment';

  /// Clés qui n'appartiennent à aucun environnement : elles survivent à une
  /// bascule comme à un effacement scopé. `language` est une préférence
  /// d'interface, elle ne vient pas du serveur.
  static const Set<String> globalKeys = {'language', environmentKey};

  static AppEnvironment? fromName(String? name) {
    for (final environment in values) {
      if (environment.name == name) return environment;
    }
    return null;
  }

  /// L'environnement à utiliser au démarrage.
  ///
  /// Hors build debug la réponse est la production sans condition : un choix
  /// « développement » resté dans le storage ne doit pas pouvoir suivre une
  /// build release.
  ///
  /// Un `dartDefine` non reconnu retombe sur le défaut plutôt que de lever —
  /// une faute de frappe dans une commande de build ne doit pas empêcher
  /// l'application de démarrer.
  static AppEnvironment resolve({
    required bool isDebug,
    AppEnvironment? stored,
    String? dartDefine,
  }) {
    if (!isDebug) return production;
    if (stored != null) return stored;
    return fromName(dartDefine) ?? development;
  }

  /// À quel environnement appartient une clé du secure storage, ou `null` si
  /// elle est globale. Sert à effacer les données d'un seul environnement.
  static AppEnvironment? owner(String key) {
    if (globalKeys.contains(key)) return null;
    if (key.startsWith(development.storagePrefix)) return development;
    return production;
  }
}
