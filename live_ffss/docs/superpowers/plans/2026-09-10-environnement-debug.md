# Sélecteur d'environnement API en debug — plan d'implémentation

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Permettre, en build debug uniquement, de choisir entre l'endpoint FFSS de production et celui de développement depuis un écran dédié, avec un ruban « DEV » sur toutes les pages quand le second est actif.

**Architecture :** Un enum `AppEnvironment` porte les deux backends et le préfixe de stockage de chacun. `AppConfig` en dérive au démarrage, à partir d'un choix persisté relu avant l'injection de dépendances. Chaque classe qui écrit dans le secure storage reçoit l'environnement et en tire son préfixe, ce qui cloisonne les deux jeux de données. La bascule réécrit le choix puis reconstruit toute la DI, en passant par une route d'attente sans contrôleur pour qu'aucun `Get.find` ne s'exécute pendant la reconstruction.

**Tech Stack :** Flutter 3.41.9 / Dart 3.11.5, GetX (DI + routing), `flutter_secure_storage`, `mocktail` pour les tests.

**Spec :** `docs/superpowers/specs/2026-09-10-environnement-debug-design.md`

## Global Constraints

- **Discipline contrôleur** (CLAUDE.md) : dans un contrôleur, pas de `Get.context!`, pas de `Get.snackbar`, pas de `Get.dialog`, pas de `.tr`, pas de paramètre `BuildContext`. Injection par constructeur uniquement, jamais de `Get.find()` dans le corps d'un contrôleur.
- **Analyzer strict** : `strict-casts: true` et `strict-raw-types: true` sont actifs. Aucune coercition `dynamic`, aucun `analyzer.errors.X: ignore`.
- **Tests** : `mocktail`, `class _MockX extends Mock implements X {}` (jamais `extends Fake`). **Aucun test de widget, aucun test d'intégration.**
- **Aucune dépendance nouvelle.** Tout ce plan s'écrit avec ce que `pubspec.yaml` contient déjà.
- **Commentaires** : uniquement là où le *pourquoi* n'est pas évident. Jamais de commentaire qui paraphrase la ligne suivante.
- **Endpoints exacts** : production `https://ffss.fr` + `api/v1.0` ; développement `https://site.ffss.io` + `api/v1.0`.
- **Préfixes exacts** : production `''`, développement `'dev_'`.
- **Commandes** : `flutter test`, `flutter analyze`, `dart format` en formes courtes (le PATH utilisateur les résout ; les chemins `.bat` complets cassent l'allowlist de permissions).
- **Message de commit** : se termine par `Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>`.

---

### Task 1: L'enum `AppEnvironment`

Le socle de tout le reste : les deux backends, leurs préfixes de stockage, la règle de résolution au démarrage et la règle de propriété d'une clé.

**Files:**
- Create: `lib/app/core/config/app_environment.dart`
- Test: `test/core/config/app_environment_test.dart`

**Interfaces:**
- Consumes: rien.
- Produces:
  - `enum AppEnvironment { production, development }`, champs `String baseUrl`, `String apiVersion`, `String storagePrefix`, `String label`
  - `String get endpoint` → `'$baseUrl/$apiVersion/'`
  - `static AppEnvironment? fromName(String? name)`
  - `static AppEnvironment resolve({required bool isDebug, AppEnvironment? stored, String? dartDefine})`
  - `static AppEnvironment? owner(String key)`
  - `static const String environmentKey = 'api_environment'`
  - `static const Set<String> globalKeys`

- [ ] **Step 1: Écrire le test qui échoue**

Créer `test/core/config/app_environment_test.dart` :

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/config/app_environment.dart';

void main() {
  group('AppEnvironment', () {
    test('porte les deux endpoints FFSS', () {
      expect(AppEnvironment.production.endpoint, 'https://ffss.fr/api/v1.0/');
      expect(
        AppEnvironment.development.endpoint,
        'https://site.ffss.io/api/v1.0/',
      );
    });

    test('la production est l\'environnement non prefixe', () {
      expect(AppEnvironment.production.storagePrefix, '');
      expect(AppEnvironment.development.storagePrefix, 'dev_');
    });

    test('fromName decode le nom de l\'enum, et rien d\'autre', () {
      expect(AppEnvironment.fromName('development'), AppEnvironment.development);
      expect(AppEnvironment.fromName('production'), AppEnvironment.production);
      expect(AppEnvironment.fromName('staging'), isNull);
      expect(AppEnvironment.fromName(null), isNull);
    });
  });

  group('AppEnvironment.resolve', () {
    test('une build release est la production, quoi qu\'il soit stocke', () {
      expect(
        AppEnvironment.resolve(
          isDebug: false,
          stored: AppEnvironment.development,
        ),
        AppEnvironment.production,
      );
    });

    test('en debug, le choix memorise l\'emporte sur le dart-define', () {
      expect(
        AppEnvironment.resolve(
          isDebug: true,
          stored: AppEnvironment.production,
          dartDefine: 'development',
        ),
        AppEnvironment.production,
      );
    });

    test('le dart-define s\'applique quand rien n\'est memorise', () {
      expect(
        AppEnvironment.resolve(isDebug: true, dartDefine: 'production'),
        AppEnvironment.production,
      );
    });

    test('un dart-define inconnu retombe sur le defaut au lieu de lever', () {
      expect(
        AppEnvironment.resolve(isDebug: true, dartDefine: 'staging'),
        AppEnvironment.development,
      );
    });

    test('en debug, sans rien, le defaut est le developpement', () {
      expect(AppEnvironment.resolve(isDebug: true), AppEnvironment.development);
    });
  });

  group('AppEnvironment.owner', () {
    test('les cles globales n\'appartiennent a personne', () {
      expect(AppEnvironment.owner('language'), isNull);
      expect(AppEnvironment.owner('api_environment'), isNull);
    });

    test('une cle prefixee dev_ appartient au developpement', () {
      expect(AppEnvironment.owner('dev_token'), AppEnvironment.development);
      expect(
        AppEnvironment.owner('dev_programme_42'),
        AppEnvironment.development,
      );
    });

    test('toute autre cle appartient a la production', () {
      expect(AppEnvironment.owner('token'), AppEnvironment.production);
      expect(AppEnvironment.owner('programme_42'), AppEnvironment.production);
      expect(
        AppEnvironment.owner('favorite_competitions'),
        AppEnvironment.production,
      );
    });
  });
}
```

- [ ] **Step 2: Lancer le test et vérifier qu'il échoue**

Run : `flutter test test/core/config/app_environment_test.dart`
Expected : échec de compilation, `Target of URI doesn't exist: 'package:live_ffss/app/core/config/app_environment.dart'`.

- [ ] **Step 3: Écrire l'implémentation minimale**

Créer `lib/app/core/config/app_environment.dart` :

```dart
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
```

- [ ] **Step 4: Lancer le test et vérifier qu'il passe**

Run : `flutter test test/core/config/app_environment_test.dart`
Expected : PASS, 11 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/app/core/config/app_environment.dart test/core/config/app_environment_test.dart
git commit -m "feat(config): enum AppEnvironment, resolution et propriete des cles"
```

---

### Task 2: `AppConfig` porte son environnement

**Files:**
- Modify: `lib/app/core/config/app_config.dart:1-30`
- Test: `test/core/config/app_config_test.dart`

**Interfaces:**
- Consumes: `AppEnvironment` (Task 1).
- Produces:
  - champ `final AppEnvironment environment` sur `AppConfig`
  - `factory AppConfig.forEnvironment(AppEnvironment environment)`
  - `factory AppConfig.fromEnv({AppEnvironment? stored})`

- [ ] **Step 1: Écrire les tests qui échouent**

Ajouter dans le `group('AppConfig', ...)` de `test/core/config/app_config_test.dart`, et ajouter l'import `package:live_ffss/app/core/config/app_environment.dart` en tête de fichier :

```dart
    test('forEnvironment porte l\'environnement de bout en bout', () {
      final config = AppConfig.forEnvironment(AppEnvironment.development);

      expect(config.baseUrl, 'https://site.ffss.io');
      expect(config.apiVersion, 'api/v1.0');
      expect(config.environment, AppEnvironment.development);
    });

    test('le constructeur production est l\'environnement production', () {
      const config = AppConfig.production();

      expect(config.environment, AppEnvironment.production);
    });

    test('deux configs ne differant que par l\'environnement sont distinctes',
        () {
      final a = AppConfig.forEnvironment(AppEnvironment.production);
      final b = AppConfig.forEnvironment(AppEnvironment.development);

      expect(a == b, isFalse);
    });
```

- [ ] **Step 2: Lancer le test et vérifier qu'il échoue**

Run : `flutter test test/core/config/app_config_test.dart`
Expected : échec de compilation, `The method 'AppConfig.forEnvironment' isn't defined`.

- [ ] **Step 3: Écrire l'implémentation**

Remplacer les lignes 1 à 30 de `lib/app/core/config/app_config.dart` (la classe `AppConfig` seule — `ApiEndpoints` en dessous ne change pas) par :

```dart
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
```

- [ ] **Step 4: Lancer les tests et vérifier qu'ils passent**

Run : `flutter test test/core/config/`
Expected : PASS. Les tests préexistants d'`AppConfig` passent sans modification — le constructeur générique garde son défaut `production`.

- [ ] **Step 5: Vérifier que `HttpClient` construit bien l'URL de développement**

C'est le point où le changement d'endpoint devient visible sur le réseau. Ajouter dans `test/core/network/http_client_test.dart`, en réutilisant le mock `http.Client` et le `TokenStorage` déjà montés dans ce fichier, et en ajoutant l'import `package:live_ffss/app/core/config/app_environment.dart` :

```dart
    test('bâtit ses URLs sur l\'endpoint de developpement', () async {
      final devClient = HttpClient(
        config: AppConfig.forEnvironment(AppEnvironment.development),
        tokenStorage: tokenStorage,
        inner: inner,
      );
      when(() => tokenStorage.getToken()).thenAnswer((_) async => null);
      when(() => inner.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('{"success":true}', 200));

      await devClient.get('competition/evenement');

      final captured = verify(
        () => inner.get(captureAny(), headers: any(named: 'headers')),
      ).captured.single as Uri;
      expect(
        captured.toString(),
        'https://site.ffss.io/api/v1.0/competition/evenement',
      );
    });
```

Run : `flutter test test/core/network/http_client_test.dart`
Expected : PASS. Si les noms des variables locales du fichier diffèrent (`inner`, `tokenStorage`), les adapter — ne pas remonter un second harnais de mocks à côté de celui qui existe.

- [ ] **Step 6: Commit**

```bash
git add lib/app/core/config/app_config.dart test/core/config/app_config_test.dart test/core/network/http_client_test.dart
git commit -m "feat(config): AppConfig derive de AppEnvironment"
```

---

### Task 3: Persistance du choix et environnement actif

Deux petits objets : celui qui écrit le choix sur le disque, et celui qui le tient en mémoire *hors* GetX pour que le ruban survive à la destruction du conteneur d'injection.

**Files:**
- Create: `lib/app/core/config/environment_storage.dart`
- Create: `lib/app/core/config/active_environment.dart`
- Test: `test/core/config/environment_storage_test.dart`

**Interfaces:**
- Consumes: `AppEnvironment` (Task 1).
- Produces:
  - `class EnvironmentStorage { EnvironmentStorage(FlutterSecureStorage storage); Future<AppEnvironment?> read(); Future<void> save(AppEnvironment environment); }`
  - `final ValueNotifier<AppEnvironment> activeEnvironment`

- [ ] **Step 1: Écrire le test qui échoue**

Créer `test/core/config/environment_storage_test.dart` :

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/config/app_environment.dart';
import 'package:live_ffss/app/core/config/environment_storage.dart';
import 'package:mocktail/mocktail.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockSecureStorage secureStorage;
  late EnvironmentStorage environmentStorage;

  setUp(() {
    secureStorage = _MockSecureStorage();
    environmentStorage = EnvironmentStorage(secureStorage);
  });

  group('EnvironmentStorage.read', () {
    test('relit un environnement enregistre', () async {
      when(() => secureStorage.read(key: 'api_environment'))
          .thenAnswer((_) async => 'development');

      expect(await environmentStorage.read(), AppEnvironment.development);
    });

    test('une valeur absente se lit null', () async {
      when(() => secureStorage.read(key: 'api_environment'))
          .thenAnswer((_) async => null);

      expect(await environmentStorage.read(), isNull);
    });

    test('une valeur inconnue se lit null au lieu de lever', () async {
      when(() => secureStorage.read(key: 'api_environment'))
          .thenAnswer((_) async => 'staging');

      expect(await environmentStorage.read(), isNull);
    });
  });

  group('EnvironmentStorage.save', () {
    test('ecrit le nom de l\'enum sous la cle non prefixee', () async {
      when(() => secureStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          )).thenAnswer((_) async {});

      await environmentStorage.save(AppEnvironment.development);

      verify(() => secureStorage.write(
            key: 'api_environment',
            value: 'development',
          )).called(1);
    });
  });
}
```

- [ ] **Step 2: Lancer le test et vérifier qu'il échoue**

Run : `flutter test test/core/config/environment_storage_test.dart`
Expected : échec de compilation, `Target of URI doesn't exist: '.../environment_storage.dart'`.

- [ ] **Step 3: Écrire l'implémentation**

Créer `lib/app/core/config/environment_storage.dart` :

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:live_ffss/app/core/config/app_environment.dart';

/// Le choix d'endpoint, persisté sous une clé globale — voir
/// [AppEnvironment.environmentKey].
class EnvironmentStorage {
  EnvironmentStorage(this._storage);

  final FlutterSecureStorage _storage;

  Future<AppEnvironment?> read() async => AppEnvironment.fromName(
        await _storage.read(key: AppEnvironment.environmentKey),
      );

  Future<void> save(AppEnvironment environment) => _storage.write(
        key: AppEnvironment.environmentKey,
        value: environment.name,
      );
}
```

Créer `lib/app/core/config/active_environment.dart` :

```dart
import 'package:flutter/foundation.dart';
import 'package:live_ffss/app/core/config/app_environment.dart';

/// L'environnement actif, tenu hors de GetX délibérément.
///
/// Le ruban « DEV » vit dans le `builder:` de `GetMaterialApp`, donc au-dessus
/// du `Navigator` : il survit à la bascule, qui détruit et reconstruit tout le
/// conteneur d'injection sous lui. Un `Get.find<AppConfig>()` y lèverait
/// pendant la fenêtre de reconstruction, et une lecture ponctuelle resterait
/// figée sur l'ancienne valeur puisque `Get.offAllNamed` change la pile de
/// routes, pas le `builder`. Un ValueNotifier règle les deux.
///
/// C'est le seul état mutable global du dépôt ; il l'est parce qu'il doit
/// survivre à `Get.deleteAll()`.
final ValueNotifier<AppEnvironment> activeEnvironment =
    ValueNotifier<AppEnvironment>(AppEnvironment.production);
```

- [ ] **Step 4: Lancer le test et vérifier qu'il passe**

Run : `flutter test test/core/config/environment_storage_test.dart`
Expected : PASS, 4 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/app/core/config/environment_storage.dart lib/app/core/config/active_environment.dart test/core/config/environment_storage_test.dart
git commit -m "feat(config): persistance du choix d'endpoint et environnement actif"
```

---

### Task 4: Cloisonner le token et le profil

**Files:**
- Modify: `lib/app/core/network/token_storage.dart:1-15`
- Modify: `lib/app/data/repositories/auth_repository.dart:18-30`
- Test: `test/core/network/token_storage_test.dart`
- Test: `test/data/repositories/auth_repository_test.dart`

**Interfaces:**
- Consumes: `AppEnvironment` (Task 1).
- Produces:
  - `TokenStorage(FlutterSecureStorage storage, {AppEnvironment environment = AppEnvironment.production})`
  - `AuthRepositoryImpl({..., AppEnvironment environment = AppEnvironment.production})`

Le défaut `production` a un préfixe vide : les tests existants, qui construisent ces deux classes sans le nouveau paramètre, continuent de vérifier les clés `token` et `user` sans être touchés.

- [ ] **Step 1: Écrire les tests qui échouent**

Dans `test/core/network/token_storage_test.dart`, ajouter l'import `package:live_ffss/app/core/config/app_environment.dart` et, dans le `group('TokenStorage', ...)` :

```dart
    test('prefixe sa cle avec l\'environnement de developpement', () async {
      final scoped =
          TokenStorage(secureStorage, environment: AppEnvironment.development);
      when(() => secureStorage.read(key: 'dev_token'))
          .thenAnswer((_) async => 'abc');

      expect(await scoped.getToken(), 'abc');
      verify(() => secureStorage.read(key: 'dev_token')).called(1);
    });
```

Dans `test/data/repositories/auth_repository_test.dart`, ajouter l'import `package:live_ffss/app/core/config/app_environment.dart` et, à la racine de `main()` :

```dart
  group('AuthRepository cloisonne par environnement', () {
    test('lit le profil sous la cle prefixee', () async {
      final scoped = AuthRepositoryImpl(
        dataSource: ds,
        tokenStorage: tokens,
        secureStorage: secure,
        environment: AppEnvironment.development,
      );
      when(() => secure.read(key: 'dev_user')).thenAnswer((_) async => null);
      when(() => tokens.getToken()).thenAnswer((_) async => null);

      await scoped.restoreSession();

      verify(() => secure.read(key: 'dev_user')).called(1);
    });
  });
```

- [ ] **Step 2: Lancer les tests et vérifier qu'ils échouent**

Run : `flutter test test/core/network/token_storage_test.dart test/data/repositories/auth_repository_test.dart`
Expected : échec de compilation, `No named parameter with the name 'environment'`.

- [ ] **Step 3: Écrire l'implémentation**

Remplacer `lib/app/core/network/token_storage.dart` en entier :

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:live_ffss/app/core/config/app_environment.dart';

class TokenStorage {
  TokenStorage(
    this._storage, {
    AppEnvironment environment = AppEnvironment.production,
  }) : _key = '${environment.storagePrefix}token';

  final FlutterSecureStorage _storage;
  final String _key;

  Future<String?> getToken() => _storage.read(key: _key);

  Future<void> setToken(String token) =>
      _storage.write(key: _key, value: token);

  Future<void> clearToken() => _storage.delete(key: _key);
}
```

Dans `lib/app/data/repositories/auth_repository.dart`, ajouter l'import
`package:live_ffss/app/core/config/app_environment.dart`, puis remplacer le constructeur et la constante de clé (lignes 18 à 30) par :

```dart
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource dataSource,
    required TokenStorage tokenStorage,
    required FlutterSecureStorage secureStorage,
    AppEnvironment environment = AppEnvironment.production,
  })  : _dataSource = dataSource,
        _tokenStorage = tokenStorage,
        _secureStorage = secureStorage,
        _userKey = '${environment.storagePrefix}user';

  final String _userKey;
```

- [ ] **Step 4: Lancer les tests et vérifier qu'ils passent**

Run : `flutter test test/core/network/ test/data/repositories/auth_repository_test.dart`
Expected : PASS, y compris tous les tests préexistants.

- [ ] **Step 5: Commit**

```bash
git add lib/app/core/network/token_storage.dart lib/app/data/repositories/auth_repository.dart test/core/network/token_storage_test.dart test/data/repositories/auth_repository_test.dart
git commit -m "feat(auth): cloisonner le token et le profil par environnement"
```

---

### Task 5: Cloisonner les préférences et les présences

**Files:**
- Modify: `lib/app/data/services/user_preferences_service.dart:6-21`
- Modify: `lib/app/data/services/attendance_service.dart:13-25`
- Test: `test/data/services/user_preferences_service_test.dart`
- Test: `test/data/services/attendance_service_test.dart`

**Interfaces:**
- Consumes: `AppEnvironment` (Task 1).
- Produces:
  - `UserPreferencesService(FlutterSecureStorage storage, {AppEnvironment environment = AppEnvironment.production})`
  - `AttendanceService(FlutterSecureStorage storage, {AppEnvironment environment = AppEnvironment.production})`

- [ ] **Step 1: Écrire les tests qui échouent**

Dans `test/data/services/user_preferences_service_test.dart`, ajouter l'import `package:live_ffss/app/core/config/app_environment.dart` et, à la racine de `main()` :

```dart
  group('UserPreferencesService cloisonne par environnement', () {
    test('lit et ecrit sous les cles prefixees', () async {
      final scoped = UserPreferencesService(
        storage,
        environment: AppEnvironment.development,
      );
      when(() => storage.read(key: 'dev_favorite_competitions'))
          .thenAnswer((_) async => null);
      when(() => storage.read(key: 'dev_last_viewed_competitions'))
          .thenAnswer((_) async => null);
      when(() => storage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          )).thenAnswer((_) async {});

      await scoped.init();
      await scoped.toggleFavorite(7);

      verify(() => storage.write(
            key: 'dev_favorite_competitions',
            value: '[7]',
          )).called(1);
    });
  });
```

Dans `test/data/services/attendance_service_test.dart`, ajouter l'import `package:live_ffss/app/core/config/app_environment.dart` et, à la racine de `main()` — en réutilisant le mock de storage déjà déclaré dans ce fichier :

```dart
  group('AttendanceService cloisonne par environnement', () {
    test('lit sous la cle prefixee', () async {
      final scoped =
          AttendanceService(storage, environment: AppEnvironment.development);
      when(() => storage.read(key: 'dev_race_attendance'))
          .thenAnswer((_) async => null);

      await scoped.init();

      verify(() => storage.read(key: 'dev_race_attendance')).called(1);
    });
  });
```

- [ ] **Step 2: Lancer les tests et vérifier qu'ils échouent**

Run : `flutter test test/data/services/`
Expected : échec de compilation, `No named parameter with the name 'environment'`.

- [ ] **Step 3: Écrire l'implémentation**

Dans `lib/app/data/services/user_preferences_service.dart`, ajouter l'import `package:live_ffss/app/core/config/app_environment.dart`, puis remplacer le constructeur et les deux constantes de clé par :

```dart
class UserPreferencesService extends GetxService {
  UserPreferencesService(
    this._storage, {
    AppEnvironment environment = AppEnvironment.production,
  })  : _favoritesKey = '${environment.storagePrefix}favorite_competitions',
        _lastViewedKey =
            '${environment.storagePrefix}last_viewed_competitions';

  final String _favoritesKey;
  final String _lastViewedKey;

  static const _lastViewedCap = 20;
```

Le reste de la classe est inchangé : `_favoritesKey` et `_lastViewedKey` sont utilisés aux mêmes endroits, ils cessent simplement d'être `static const`.

Dans `lib/app/data/services/attendance_service.dart`, ajouter le même import, puis remplacer le constructeur et la constante `_key` par :

```dart
class AttendanceService extends GetxService {
  AttendanceService(
    this._storage, {
    AppEnvironment environment = AppEnvironment.production,
  }) : _key = '${environment.storagePrefix}race_attendance';

  final String _key;

  /// Sliding cap. Races are held newest-touched first, so going past this drops
  /// the least recently pointed one.
  static const _raceCap = 100;
```

- [ ] **Step 4: Lancer les tests et vérifier qu'ils passent**

Run : `flutter test test/data/services/`
Expected : PASS, y compris tous les tests préexistants de ces deux services.

- [ ] **Step 5: Commit**

```bash
git add lib/app/data/services/user_preferences_service.dart lib/app/data/services/attendance_service.dart test/data/services/user_preferences_service_test.dart test/data/services/attendance_service_test.dart
git commit -m "feat(services): cloisonner preferences et presences par environnement"
```

---

### Task 6: Cloisonner le programme et scoper l'effacement

Le seul changement de comportement observable du lot : `clearEverything()` cesse d'être un `deleteAll()` global.

**Files:**
- Modify: `lib/app/data/services/programme_service.dart:10-14,60-70`
- Test: `test/data/services/programme_service_test.dart:115-132`

**Interfaces:**
- Consumes: `AppEnvironment` (Task 1).
- Produces: `ProgrammeService(FlutterSecureStorage storage, {AppEnvironment environment = AppEnvironment.production})`, avec `Future<void> clearEverything()` inchangé côté signature.

- [ ] **Step 1: Écrire les tests qui échouent**

Dans `test/data/services/programme_service_test.dart`, ajouter l'import `package:live_ffss/app/core/config/app_environment.dart`, puis **remplacer** le `group('clearEverything', ...)` existant (lignes 115 à 132) par :

```dart
  group('clearEverything', () {
    // La porte de sortie quand le stockage d'un appareil a derive de FFSS.
    // Depuis le cloisonnement par environnement, elle ne prend plus que les
    // cles de l'environnement courant : effacer la production ne doit pas
    // emporter le developpement, ni la langue, ni le choix d'endpoint.
    test('ne supprime que les cles de la production', () async {
      when(() => storage.readAll()).thenAnswer((_) async => {
            'token': 'T',
            'user': '{}',
            'programme_42': '{}',
            'dev_token': 'D',
            'dev_programme_42': '{}',
            'language': 'fr',
            'api_environment': 'production',
          });
      when(() => storage.delete(key: any(named: 'key')))
          .thenAnswer((_) async {});
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);
      final service = ProgrammeService(storage);
      await service.load(42);

      await service.clearEverything();

      verify(() => storage.delete(key: 'token')).called(1);
      verify(() => storage.delete(key: 'user')).called(1);
      verify(() => storage.delete(key: 'programme_42')).called(1);
      verifyNever(() => storage.delete(key: 'dev_token'));
      verifyNever(() => storage.delete(key: 'dev_programme_42'));
      verifyNever(() => storage.delete(key: 'language'));
      verifyNever(() => storage.delete(key: 'api_environment'));
      expect(service.current.value, isNull);
    });

    test('ne supprime que les cles du developpement', () async {
      when(() => storage.readAll()).thenAnswer((_) async => {
            'token': 'T',
            'dev_token': 'D',
            'language': 'fr',
          });
      when(() => storage.delete(key: any(named: 'key')))
          .thenAnswer((_) async {});
      final service = ProgrammeService(
        storage,
        environment: AppEnvironment.development,
      );

      await service.clearEverything();

      verify(() => storage.delete(key: 'dev_token')).called(1);
      verifyNever(() => storage.delete(key: 'token'));
      verifyNever(() => storage.delete(key: 'language'));
    });

    test('prefixe la cle du programme', () async {
      when(() => storage.read(key: 'dev_programme_42'))
          .thenAnswer((_) async => null);
      final service = ProgrammeService(
        storage,
        environment: AppEnvironment.development,
      );

      await service.load(42);

      verify(() => storage.read(key: 'dev_programme_42')).called(1);
    });
  });
```

- [ ] **Step 2: Lancer les tests et vérifier qu'ils échouent**

Run : `flutter test test/data/services/programme_service_test.dart`
Expected : échec de compilation (`No named parameter with the name 'environment'`) puis, une fois ce point réglé, échec sur `storage.delete` jamais appelé.

- [ ] **Step 3: Écrire l'implémentation**

Dans `lib/app/data/services/programme_service.dart`, ajouter l'import `package:live_ffss/app/core/config/app_environment.dart`, puis remplacer le constructeur :

```dart
class ProgrammeService extends GetxService {
  ProgrammeService(
    this._storage, {
    AppEnvironment environment = AppEnvironment.production,
  }) : _environment = environment;

  final FlutterSecureStorage _storage;
  final AppEnvironment _environment;
```

Remplacer `clearEverything()` et `_key` par :

```dart
  /// Wipes every key of the current environment — programmes of every
  /// competition, attendance, favourites, and the session token with them.
  ///
  /// The escape hatch for a device whose stored programme has drifted from
  /// what FFSS holds: everything here is either re-fetched from the
  /// federation or re-entered, so losing it costs a reload, not work — with
  /// one exception the caller must warn about, a draw or a ranking not yet
  /// pushed, which exists nowhere else.
  ///
  /// Scopé à un environnement plutôt qu'un `deleteAll()` : effacer la
  /// production ne doit pas emporter les données de développement, ni la
  /// langue, ni le choix d'endpoint — qui, lui, décide du préfixe.
  Future<void> clearEverything() async {
    final all = await _storage.readAll();
    for (final key in all.keys) {
      if (AppEnvironment.owner(key) == _environment) {
        await _storage.delete(key: key);
      }
    }
    current.value = null;
  }

  String _key(int competitionId) =>
      '${_environment.storagePrefix}programme_$competitionId';
```

`_key` cesse d'être `static` ; ses deux appels dans `load()` et `save()` ne changent pas de forme.

- [ ] **Step 4: Lancer les tests et vérifier qu'ils passent**

Run : `flutter test test/data/services/programme_service_test.dart`
Expected : PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/app/data/services/programme_service.dart test/data/services/programme_service_test.dart
git commit -m "feat(programme): cloisonner le programme et scoper l'effacement"
```

---

### Task 7: Recâbler `InitialBinding`

Le storage passe devant la config, qui dépend désormais de lui, et l'environnement est propagé aux cinq classes cloisonnées.

**Files:**
- Modify: `lib/app/core/di/initial_binding.dart:38-60,78-90,150-175`

**Interfaces:**
- Consumes: tout ce que produisent les tâches 1 à 6.
- Produces: `EnvironmentStorage` enregistré dans le conteneur GetX ; `activeEnvironment` positionné.

Pas de test : la DI n'est pas testée dans ce dépôt. La vérification est `flutter analyze` plus la suite complète.

- [ ] **Step 1: Réordonner et propager**

Dans `lib/app/core/di/initial_binding.dart`, ajouter les imports :

```dart
import 'package:live_ffss/app/core/config/active_environment.dart';
import 'package:live_ffss/app/core/config/app_environment.dart';
import 'package:live_ffss/app/core/config/environment_storage.dart';
```

Remplacer le bloc « 1. Config » + « 2. Storage » (lignes 38 à 60) par :

```dart
    // 1. Storage. Devant la config, qui dépend maintenant de lui : le choix
    // d'endpoint est persisté, et il faut l'avoir relu pour construire
    // AppConfig.
    Get.put<FlutterSecureStorage>(
      const FlutterSecureStorage(),
      permanent: true,
    );
    Get.put<EnvironmentStorage>(
      EnvironmentStorage(Get.find<FlutterSecureStorage>()),
      permanent: true,
    );

    // 2. Config. Hors build debug, `fromEnv` ignore le choix mémorisé et
    // renvoie la production — voir AppEnvironment.resolve.
    final config = AppConfig.fromEnv(
      stored: await Get.find<EnvironmentStorage>().read(),
    );
    Get.put<AppConfig>(config, permanent: true);
    final environment = config.environment;
    activeEnvironment.value = environment;

    Get.put<TokenStorage>(
      TokenStorage(
        Get.find<FlutterSecureStorage>(),
        environment: environment,
      ),
      permanent: true,
    );
```

- [ ] **Step 2: Propager aux quatre autres consommateurs**

Dans le même fichier, `AuthRepositoryImpl` reçoit l'environnement :

```dart
    Get.put<AuthRepository>(
      AuthRepositoryImpl(
        dataSource: Get.find<AuthRemoteDataSource>(),
        tokenStorage: Get.find<TokenStorage>(),
        secureStorage: Get.find<FlutterSecureStorage>(),
        environment: environment,
      ),
      permanent: true,
    );
```

Et les trois services du bloc 8 :

```dart
    await Get.putAsync<UserPreferencesService>(
      () async => UserPreferencesService(
        Get.find<FlutterSecureStorage>(),
        environment: environment,
      ).init(),
    );
    await Get.putAsync<ProgrammeService>(
      () async => ProgrammeService(
        Get.find<FlutterSecureStorage>(),
        environment: environment,
      ),
    );
    await Get.putAsync<AttendanceService>(
      () async => AttendanceService(
        Get.find<FlutterSecureStorage>(),
        environment: environment,
      ).init(),
    );
```

- [ ] **Step 3: Vérifier**

Run : `flutter analyze`
Expected : `No issues found!`

Run : `flutter test`
Expected : PASS, suite complète.

- [ ] **Step 4: Commit**

```bash
git add lib/app/core/di/initial_binding.dart
git commit -m "feat(di): storage avant config, propagation de l'environnement"
```

---

### Task 8: La bascule

**Files:**
- Create: `lib/app/module/debug/views/restarting_view.dart`
- Create: `lib/app/core/di/app_restart.dart`
- Modify: `lib/app/routes/app_routes.dart`
- Modify: `lib/app/routes/app_pages.dart`

**Interfaces:**
- Consumes: `EnvironmentStorage` (Task 3), `InitialBinding.register()` (Task 7).
- Produces:
  - `Routes.restarting` = `'/restarting'`, `Routes.debug` = `'/debug'`
  - `abstract class AppRestart { static Future<void> switchTo(AppEnvironment environment); }`

Pas de test : navigation et widget, hors périmètre de test du dépôt.

- [ ] **Step 1: La page d'attente**

Créer `lib/app/module/debug/views/restarting_view.dart` :

```dart
import 'package:flutter/material.dart';
import 'package:live_ffss/app/presentation/shared/loading_indicator.dart';

/// L'écran affiché pendant qu'une bascule d'environnement reconstruit
/// l'injection de dépendances.
///
/// Volontairement sans binding et sans contrôleur : sa seule raison d'être est
/// qu'aucune vue vivante n'exécute un `Get.find` entre le `Get.deleteAll()` et
/// le `InitialBinding.register()` d'[AppRestart.switchTo].
class RestartingView extends StatelessWidget {
  const RestartingView({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: LoadingIndicator(),
      );
}
```

- [ ] **Step 2: Les routes**

Dans `lib/app/routes/app_routes.dart`, ajouter avant le commentaire `// Add other routes here` :

```dart
  static const debug = '/debug';
  static const restarting = '/restarting';
```

Dans `lib/app/routes/app_pages.dart`, ajouter les imports :

```dart
import 'package:flutter/foundation.dart';
import 'package:live_ffss/app/module/debug/views/restarting_view.dart';
```

et, à la fin de la liste `routes`, en gardant la structure de liste existante :

```dart
    // Les deux routes de debug ne sont pas seulement cachées en release :
    // elles ne sont pas déclarées, donc `Get.toNamed('/debug')` n'y mène nulle
    // part.
    if (kDebugMode)
      GetPage(
        name: Routes.restarting,
        page: () => const RestartingView(),
      ),
```

La route `/debug` elle-même est ajoutée en Task 9, quand sa vue existe.

- [ ] **Step 3: La séquence de bascule**

Créer `lib/app/core/di/app_restart.dart` :

```dart
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
```

- [ ] **Step 4: Vérifier**

Run : `flutter analyze`
Expected : `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/app/core/di/app_restart.dart lib/app/module/debug/views/restarting_view.dart lib/app/routes/app_pages.dart lib/app/routes/app_routes.dart
git commit -m "feat(debug): bascule d'environnement par redemarrage a froid"
```

---

### Task 9: L'écran de debug

**Files:**
- Create: `lib/app/module/debug/controllers/debug_controller.dart`
- Create: `lib/app/module/debug/bindings/debug_binding.dart`
- Create: `lib/app/module/debug/views/debug_view.dart`
- Modify: `lib/app/routes/app_pages.dart`
- Modify: `lib/app/module/auth/views/profile_view.dart:13-20`
- Test: `test/presentation/modules/debug/controllers/debug_controller_test.dart`

**Interfaces:**
- Consumes: `AppConfig` (Task 2), `AppRestart.switchTo` (Task 8).
- Produces: `DebugController(AppConfig config)` avec `AppEnvironment get current`, `List<AppEnvironment> get environments`, `String get endpoint`, `String get storagePrefixLabel`.

- [ ] **Step 1: Écrire le test qui échoue**

Créer `test/presentation/modules/debug/controllers/debug_controller_test.dart` :

```dart
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
```

- [ ] **Step 2: Lancer le test et vérifier qu'il échoue**

Run : `flutter test test/presentation/modules/debug/`
Expected : échec de compilation, `Target of URI doesn't exist: '.../debug_controller.dart'`.

- [ ] **Step 3: Le contrôleur et son binding**

Créer `lib/app/module/debug/controllers/debug_controller.dart` :

```dart
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
```

Créer `lib/app/module/debug/bindings/debug_binding.dart` :

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/core/config/app_config.dart';
import 'package:live_ffss/app/module/debug/controllers/debug_controller.dart';

class DebugBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DebugController>(
      () => DebugController(Get.find<AppConfig>()),
    );
  }
}
```

- [ ] **Step 4: Lancer le test et vérifier qu'il passe**

Run : `flutter test test/presentation/modules/debug/`
Expected : PASS, 4 tests.

- [ ] **Step 5: La vue**

Créer `lib/app/module/debug/views/debug_view.dart` :

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/config/app_environment.dart';
import 'package:live_ffss/app/core/di/app_restart.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/module/debug/controllers/debug_controller.dart';

/// Écran de debug. Ses textes sont en dur, non traduits : il ne part jamais en
/// release, et les deux fichiers de traduction sont tenus symétriques et sans
/// clé morte — huit clés de debug n'y rendraient service à personne.
class DebugView extends GetView<DebugController> {
  const DebugView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Environnement actif',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _row('Endpoint', controller.endpoint),
                  _row('Préfixe de stockage', controller.storagePrefixLabel),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Changer d\'environnement',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // ListTile plutôt que RadioListTile : `groupValue`/`onChanged` sont
          // dépréciés sur le SDK du projet, et une dépréciation fait sortir
          // `flutter analyze` en erreur.
          for (final environment in controller.environments)
            Card(
              child: ListTile(
                leading: Icon(
                  environment == controller.current
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: environment == controller.current
                      ? AppColors.primary
                      : AppColors.textMuted,
                ),
                title: Text(environment.label),
                subtitle: Text(environment.endpoint),
                onTap: environment == controller.current
                    ? null
                    : () => _confirmSwitch(context, environment),
              ),
            ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 150,
              child: Text(
                label,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
            Expanded(child: Text(value)),
          ],
        ),
      );
}

/// Confirme la bascule puis la déclenche. Portée par la vue, pas par le
/// contrôleur : `AppRestart.switchTo` détruit le contrôleur en cours de route.
Future<void> _confirmSwitch(
  BuildContext context,
  AppEnvironment environment,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Basculer sur ${environment.label} ?'),
      content: Text(
        'L\'application va redémarrer sur ${environment.endpoint}.\n\n'
        'Chaque environnement garde sa propre session et son propre '
        'programme local : tu repartiras sur ceux de celui-ci, '
        'probablement aucun la première fois. Rien n\'est effacé.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Basculer'),
        ),
      ],
    ),
  );
  if (confirmed == true) await AppRestart.switchTo(environment);
}
```

- [ ] **Step 6: Brancher la route et l'entrée du profil**

Dans `lib/app/routes/app_pages.dart`, ajouter les imports du binding et de la vue, puis, à côté de la route `/restarting` ajoutée en Task 8 :

```dart
    if (kDebugMode)
      GetPage(
        name: Routes.debug,
        page: () => const DebugView(),
        binding: DebugBinding(),
      ),
```

Dans `lib/app/module/auth/views/profile_view.dart`, ajouter les imports `package:flutter/foundation.dart`, `package:get/get.dart` (déjà présent) et `package:live_ffss/app/routes/app_pages.dart`, puis remplacer les `actions` de l'`AppBar` (lignes 13 à 20) par :

```dart
        actions: [
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.bug_report_outlined),
              tooltip: 'Debug',
              onPressed: () => Get.toNamed<void>(Routes.debug),
            ),
          const LanguageSelector(),
          const SizedBox(width: 16),
        ],
```

- [ ] **Step 7: Vérifier**

Run : `flutter analyze`
Expected : `No issues found!`

Run : `flutter test`
Expected : PASS, suite complète.

- [ ] **Step 8: Commit**

```bash
git add lib/app/module/debug lib/app/routes/app_pages.dart lib/app/module/auth/views/profile_view.dart test/presentation/modules/debug
git commit -m "feat(debug): ecran de selection d'environnement"
```

---

### Task 10: Le ruban « DEV »

**Files:**
- Create: `lib/app/presentation/shared/dev_banner.dart`
- Modify: `lib/main.dart:24-34`

**Interfaces:**
- Consumes: `activeEnvironment` (Task 3).
- Produces: `DevEnvironmentBanner({required Widget child})`.

Pas de test : widget, hors périmètre de test du dépôt.

- [ ] **Step 1: Le widget**

Créer `lib/app/presentation/shared/dev_banner.dart` :

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:live_ffss/app/core/config/active_environment.dart';
import 'package:live_ffss/app/core/config/app_environment.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';

/// Le ruban « DEV », posé sur toutes les pages quand l'endpoint de
/// développement est actif — même mécanisme que
/// `debugShowCheckedModeBanner`.
///
/// Branché dans le `builder:` de `GetMaterialApp`, donc au-dessus du
/// `Navigator` : il couvre routes, dialogues et bottom sheets sans qu'aucune
/// vue ait à le savoir. Il lit [activeEnvironment] et non `AppConfig` parce
/// qu'il survit au `Get.deleteAll()` d'une bascule — voir la doc de ce
/// notifier.
class DevEnvironmentBanner extends StatelessWidget {
  const DevEnvironmentBanner({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return child;
    return ValueListenableBuilder<AppEnvironment>(
      valueListenable: activeEnvironment,
      builder: (context, environment, banneredChild) {
        if (environment != AppEnvironment.development) return banneredChild!;
        return Banner(
          message: 'DEV',
          location: BannerLocation.topEnd,
          color: AppColors.statusWaiting,
          child: banneredChild!,
        );
      },
      child: child,
    );
  }
}
```

- [ ] **Step 2: Le brancher**

Dans `lib/main.dart`, ajouter l'import `package:live_ffss/app/presentation/shared/dev_banner.dart` et ajouter le `builder` au `GetMaterialApp`, juste après `debugShowCheckedModeBanner: false,` :

```dart
      builder: (context, child) => DevEnvironmentBanner(
        child: child ?? const SizedBox.shrink(),
      ),
```

- [ ] **Step 3: Vérifier**

Run : `flutter analyze`
Expected : `No issues found!`

- [ ] **Step 4: Vérification manuelle**

Run : `flutter run`
Expected, dans cet ordre :
1. l'application démarre sur le développement (défaut en debug), ruban « DEV » orange visible en haut à droite sur l'accueil ;
2. Profil → icône insecte → l'écran Debug indique `https://site.ffss.io/api/v1.0/` et le préfixe `dev_` ;
3. sélectionner « Production », confirmer → écran d'attente bref, retour sur l'accueil, **ruban disparu** ;
4. rouvrir Debug → `https://ffss.fr/api/v1.0/`, préfixe `aucun` ;
5. tuer et relancer l'application → elle redémarre sur la production, sans ruban : le choix a survécu.

- [ ] **Step 5: Commit**

```bash
git add lib/app/presentation/shared/dev_banner.dart lib/main.dart
git commit -m "feat(ui): ruban DEV sur toutes les pages"
```

---

### Task 11: Documentation et vérification finale

**Files:**
- Modify: `CLAUDE.md`

- [ ] **Step 1: Mettre CLAUDE.md au niveau**

Quatre passages à corriger, qui décrivent tous un état devenu faux :

1. Section **« DI registration order in `InitialBinding` »** — les points 1 et 2 sont inversés. Les remplacer par :

```markdown
1. `FlutterSecureStorage` → `EnvironmentStorage` → `TokenStorage`
2. `AppConfig` — construite à partir du choix d'endpoint relu dans `EnvironmentStorage`. Le storage passe donc **devant** la config, contrairement à ce que faisait la version d'origine.
```

2. Section **« API contract (FFSS, external, fixed) »**, première puce — « Base URL: `https://ffss.fr` (single env) » est faux. Remplacer par :

```markdown
- Deux environnements : production `https://ffss.fr/api/v1.0/`, développement `https://site.ffss.io/api/v1.0/`. `AppEnvironment` (`core/config/app_environment.dart`) les porte ; `AppConfig.fromEnv()` en choisit un au démarrage. **Le développement n'est joignable qu'en build debug** — hors debug `AppEnvironment.resolve` renvoie la production sans condition, même si un choix « développement » traîne dans le secure storage.
```

3. Même section, dernière puce — la clé `'user'` n'est plus littérale. Remplacer par :

```markdown
- Clés du secure storage préfixées par environnement : production `''`, développement `'dev_'`. Six clés sont cloisonnées (`token`, `user`, `favorite_competitions`, `last_viewed_competitions`, `race_attendance`, `programme_<id>`), deux restent globales (`language`, `api_environment`). La règle unique est `AppEnvironment.owner(key)` — ne pas la dupliquer ailleurs. Le préfixe de production est vide, ce qui rend le cloisonnement rétro-compatible : ne pas lui en donner un.
```

4. Section **« Feature modules »** — ajouter `debug` à la liste des modules, avec une phrase :

```markdown
`debug` n'est déclaré que sous `kDebugMode`, routes comprises : en release ses `GetPage` n'existent pas. Ses textes sont en dur et non traduits, délibérément.
```

- [ ] **Step 2: Formater**

Run : `dart format lib/ test/`
Expected : quelques fichiers reformatés, ou aucun.

- [ ] **Step 3: Vérification complète**

Run : `flutter analyze`
Expected : `No issues found!`

Run : `flutter test`
Expected : PASS, suite complète, aucun test ignoré.

- [ ] **Step 4: Vérifier la garde release**

Run : `flutter build apk --release`
Expected : build réussie. C'est ce qui prouve que le code sous `kDebugMode` compile bien dans les deux modes — un `if (kDebugMode)` mal placé dans une liste de `GetPage` ne se voit pas autrement.

- [ ] **Step 5: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: environnements API, ordre de DI et module debug"
```
