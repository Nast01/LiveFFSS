# LiveFFSS v2 — Lot 1 : fondations et accueil — plan d'implémentation

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal :** créer le projet Flutter `live_ffss.v2/` et livrer son écran d'accueil (écran 1 de la maquette) dans une barre à 5 onglets, alimenté par l'API FFSS.

**Architecture :** `features` → `data` → `domain`. Le domaine est fait de classes pures freezed, nommées comme dans FFSSCompetition V3. `data/ffss/` contient les DTO de l'API et leurs mappers. Les repositories appellent `HttpClient` directement. L'état est géré par Riverpod 3, la navigation par go_router 17 (`StatefulShellRoute`).

**Tech Stack :** Flutter 3.41.9 / Dart 3.11.5, flutter_riverpod ^3.3.2, go_router ^17.5.0, freezed ^3.2.5 + json_serializable ^6.14.1, flutter_secure_storage ^11.2.0, http ^1.6.0, intl ^0.20.2, flutter_localizations (gen-l10n), mocktail ^1.0.5, fake_async.

**Spec :** [`live_ffss.v2/docs/specs/2026-10-16-lot1-accueil-design.md`](../specs/2026-10-16-lot1-accueil-design.md)

## Global Constraints

- Le dossier `live_ffss/` (la v1) **ne se modifie pas**, à une seule exception : la mention en tête de son `CLAUDE.md` (tâche 1).
- La v2 ne dépend pas de la v1 : le code utile est **copié**, jamais importé.
- Noms du domaine : ceux de FFSSCompetition V3 (`CompetitionSummary`, `Discipline`, `Meeting`, `MeetingItem`, `Heat`, `RunStatus`, `Gender`). Jamais les noms v1 (`Run`, `Slot`, `Lane`, `Course`), jamais de nom français de l'API dans le domaine.
- « Eau plate » partout, jamais « Piscine ».
- Au lot 1, l'app parle **uniquement à la production** (`https://ffss.fr/api/v1.0/`), debug compris.
- Analyseur : `strict-casts: true`, `strict-raw-types: true`. Pas de coercition `dynamic`, pas de `fromJson` écrit à la main.
- Pas de test de widget. On teste le domaine, les mappers, les repositories et les fournisseurs.
- Les commentaires disent **pourquoi**, jamais ce que fait la ligne suivante.
- Traductions : `app_fr.arb` est la référence, `app_en.arb` a exactement les mêmes clés, sans clé morte.
- Les fichiers générés (`.freezed.dart`, `.g.dart`, `lib/core/l10n/gen/`) sont commités avec le source.
- Le dernier élément d'un écran ne passe jamais sous la barre de navigation du téléphone.
- Commandes (depuis `live_ffss.v2/`) : `flutter test`, `flutter analyze`, `dart format lib test`, `dart run build_runner build --delete-conflicting-outputs`, `flutter gen-l10n`.

## Review Focus

1. **Un rafraîchissement qui échoue alors que l'accueil est affiché** : la liste doit rester à l'écran, un message discret doit s'afficher et l'écran ne doit pas se vider (test dans la tâche 10).
2. **Une compétition au format inattendu** (`Organisme` servi en `[]`, `Specialite` ou `Id` en chaîne, `Fin` absente) : elle est corrigée ou écartée seule, sans faire échouer toute la liste (tests dans la tâche 5).
3. **Les bornes de date** : une compétition qui finit aujourd'hui est en direct ; une qui a fini il y a exactement 14 jours est encore « terminée récemment » ; le calcul ne dérive pas au passage à l'heure d'hiver (25 octobre 2026) (tests dans la tâche 3).
4. **Une heure de course mal formée** (`"08:46:00"`, `""`, `"2026-03-27 08:46:00"`) : la série est gardée, avec une heure lue ou nulle, jamais une exception (tests dans la tâche 6).
5. **Le rafraîchissement de la ligne « MAINTENANT » s'arrête** quand la carte n'est plus affichée, au lieu d'appeler l'API toutes les 30 s en arrière-plan (test dans la tâche 10).

---

## Structure des fichiers

```
LiveFFSS/
├── .github/workflows/ci.yml                 (modifié : matrice v1 + v2)
├── docs/
│   ├── FFSS_API.md                          (déplacé depuis live_ffss/docs/)
│   └── FFSS_API_CONTRACT.md                 (section « API contract » du CLAUDE.md v1)
├── live_ffss/CLAUDE.md                      (mention « référence v1 » en tête)
└── live_ffss.v2/
    ├── CLAUDE.md
    ├── pubspec.yaml, analysis_options.yaml, l10n.yaml
    ├── assets/images/logo_ffss.png, assets/fonts/Barlow-*.ttf
    ├── lib/
    │   ├── main.dart, app.dart
    │   ├── core/
    │   │   ├── config/app_environment.dart, app_config.dart
    │   │   ├── errors/app_exception.dart
    │   │   ├── network/http_client.dart, token_storage.dart
    │   │   ├── storage/local_store.dart
    │   │   ├── providers.dart
    │   │   ├── theme/app_colors.dart, app_theme.dart
    │   │   ├── l10n/app_fr.arb, app_en.arb, gen/…
    │   │   └── router/app_router.dart
    │   ├── domain/
    │   │   ├── discipline.dart, gender.dart, run_status.dart
    │   │   ├── competition_summary.dart, home_partition.dart
    │   │   ├── heat.dart, meeting.dart, now_running.dart
    │   ├── data/
    │   │   ├── ffss/dtos/json_readers.dart, evenement_dto.dart, reunion_dto.dart
    │   │   ├── ffss/mappers/ffss_dates.dart, evenement_mapper.dart, reunion_mapper.dart
    │   │   └── repositories/competition_repository.dart, meeting_repository.dart
    │   └── features/
    │       ├── shell/app_shell.dart, active_competition.dart, current_competition.dart,
    │       │        open_competition.dart, tab_placeholders.dart
    │       └── home/home_view.dart, home_providers.dart, favorites.dart,
    │                now_running_provider.dart, search_provider.dart,
    │                competition_formatting.dart, home_page.dart, all_competitions_page.dart,
    │                widgets/…
    └── test/ (même arborescence que lib/, plus test/support/)
```

---

### Tâche 1 : mise en place du dépôt et du projet Flutter

**Files :**
- Move : `live_ffss/docs/FFSS_API.md` → `docs/FFSS_API.md`
- Create : `docs/FFSS_API_CONTRACT.md`
- Modify : `live_ffss/CLAUDE.md` (en tête seulement)
- Create : `live_ffss.v2/` (projet Flutter), `live_ffss.v2/pubspec.yaml`, `live_ffss.v2/analysis_options.yaml`
- Create : `live_ffss.v2/assets/images/logo_ffss.png`, `live_ffss.v2/assets/fonts/Barlow-{Regular,Medium,SemiBold,Bold}.ttf`, `live_ffss.v2/assets/fonts/OFL.txt`
- Modify : `.github/workflows/ci.yml`
- Test : `live_ffss.v2/test/smoke_test.dart`

**Interfaces :**
- Produces : le package Dart `live_ffss_v2` (imports `package:live_ffss_v2/...`), les familles de polices `Barlow` (400, 500, 600, 700), l'asset `assets/images/logo_ffss.png`.

- [ ] **Étape 1 : remonter la documentation de l'API**

Depuis `LiveFFSS/` :

```bash
mkdir -p docs
git mv live_ffss/docs/FFSS_API.md docs/FFSS_API.md
{
  printf '# Contrat de l'"'"'API FFSS — faits vérifiés\n\n'
  printf '> Section « API contract » du CLAUDE.md de la v1 (`live_ffss/CLAUDE.md`), reprise telle quelle le 2026-10-17. Ce sont des comportements constatés sur de vraies réponses du serveur : là où ils contredisent `FFSS_API.md`, ils gagnent. Les noms de fichiers cités sont ceux de la v1.\n\n'
  awk '/^## API contract/{f=1;next} /^## Domain naming/{f=0} f' live_ffss/CLAUDE.md
} > docs/FFSS_API_CONTRACT.md
```

Vérifier : `head -5 docs/FFSS_API_CONTRACT.md` montre le titre, puis la note, puis la première puce (« `docs/FFSS_API.md` est la référence… »).

- [ ] **Étape 2 : signaler le gel en tête du CLAUDE.md de la v1**

Insérer ces lignes **juste après** la première ligne (`# CLAUDE.md`) de `live_ffss/CLAUDE.md` :

```markdown

> **Référence v1 — ne pas modifier.** Cette application (épreuves côtières, testée en live) est gelée au tag `v1-cotier-final`. La v2 se développe dans `../live_ffss.v2/`, qui en copie le code utile sans jamais l'importer. `docs/FFSS_API.md` a été déplacé à la racine du dépôt : `../docs/FFSS_API.md` ; la section « API contract » ci-dessous y est reprise dans `../docs/FFSS_API_CONTRACT.md`.
```

- [ ] **Étape 3 : créer le projet Flutter**

Depuis `LiveFFSS/live_ffss.v2/` (le dossier existe déjà, il contient `docs/`) :

```bash
flutter create --project-name live_ffss_v2 --org fr.ffss --platforms android,ios,web .
rm test/widget_test.dart
mkdir -p assets/images assets/fonts
cp ../live_ffss/assets/images/logo_ffss.png assets/images/
for w in Regular Medium SemiBold Bold; do
  curl -fsSL -o "assets/fonts/Barlow-$w.ttf" "https://github.com/google/fonts/raw/main/ofl/barlow/Barlow-$w.ttf"
done
curl -fsSL -o assets/fonts/OFL.txt https://github.com/google/fonts/raw/main/ofl/barlow/OFL.txt
```

Vérifier : les quatre `.ttf` font chacun plus de 50 Ko (`ls -l assets/fonts`).

- [ ] **Étape 4 : écrire `pubspec.yaml`**

Remplacer tout `live_ffss.v2/pubspec.yaml` par :

```yaml
name: live_ffss_v2
description: "FFSS-LIVE — suivi en direct des compétitions de sauvetage sportif (v2)."
publish_to: 'none'
version: 2.0.0+1

environment:
  sdk: '>=3.11.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  flutter_riverpod: ^3.3.2
  flutter_secure_storage: ^11.2.0
  freezed_annotation: ^3.1.0
  go_router: ^17.5.0
  http: ^1.6.0
  intl: ^0.20.2
  json_annotation: ^4.12.0

dev_dependencies:
  build_runner: ^2.15.1
  fake_async: ^1.3.1
  flutter_lints: ^6.0.0
  flutter_test:
    sdk: flutter
  freezed: ^3.2.5
  json_serializable: ^6.14.1
  mocktail: ^1.0.5

flutter:
  uses-material-design: true
  generate: true

  assets:
    - assets/images/

  fonts:
    - family: Barlow
      fonts:
        - asset: assets/fonts/Barlow-Regular.ttf
          weight: 400
        - asset: assets/fonts/Barlow-Medium.ttf
          weight: 500
        - asset: assets/fonts/Barlow-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Barlow-Bold.ttf
          weight: 700
```

Run : `flutter pub get`
Expected : `Got dependencies!`. Si `fake_async` est refusé à cause de la version épinglée par `flutter_test`, remplacer la contrainte par `any`.

- [ ] **Étape 5 : écrire `analysis_options.yaml`**

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  language:
    strict-casts: true
    strict-raw-types: true
  # Code généré : il n'est pas écrit à la main, donc ses écarts de style ne se
  # corrigent pas à la main non plus.
  exclude:
    - lib/**/*.freezed.dart
    - lib/**/*.g.dart
    - lib/core/l10n/gen/**

linter:
  rules:
    # flutter_lints 6 a retiré ces trois règles de son jeu ; on les garde, comme
    # en v1, pour qu'une montée de version ne soit pas un relâchement déguisé.
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_const_literals_to_create_immutables
```

- [ ] **Étape 6 : écrire un test minimal pour que la CI ait quelque chose à exécuter**

`live_ffss.v2/test/smoke_test.dart` :

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('la suite de tests démarre', () {
    expect(1 + 1, 2);
  });
}
```

Ce test sera supprimé à la tâche 2, dès qu'existe un vrai test.

- [ ] **Étape 7 : étendre la CI aux deux projets**

Remplacer tout `.github/workflows/ci.yml` par :

```yaml
# Les trois commandes qu'on lance à la main avant chaque commit, sur les deux
# applications : la v1 reste au vert tant que la v2 y puise du code.
name: CI

on:
  push:
    branches: [main, dev, val, dev_v2]
  pull_request:

# Une seule exécution par branche : un second push annule le premier plutôt
# que de faire la queue.
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  verify:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        project: [live_ffss, live_ffss.v2]
    defaults:
      run:
        working-directory: ${{ matrix.project }}
    steps:
      - uses: actions/checkout@v4

      # Épinglée sur la version du poste de développement. Le dossier
      # d'installation s'appelle flutter_windows_3.22.2-stable mais le clone
      # est sur le tag 3.41.9 — voir la section Tooling pins du CLAUDE.md v1.
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: 3.41.9
          channel: stable
          cache: true

      - run: flutter pub get

      # Avant analyze : un écart de formatage se corrige en une commande, et
      # le dire d'abord évite de lire un échec d'analyse pour une virgule.
      - name: dart format
        run: dart format --output=none --set-exit-if-changed lib test

      - name: flutter analyze
        run: flutter analyze

      - name: flutter test
        run: flutter test
```

- [ ] **Étape 8 : vérifier**

Depuis `live_ffss.v2/` :
Run : `dart format lib test && flutter analyze && flutter test`
Expected : `No issues found!` puis `All tests passed!`

- [ ] **Étape 9 : commiter**

Depuis `LiveFFSS/` :

```bash
git add docs live_ffss/CLAUDE.md live_ffss/docs .github/workflows/ci.yml live_ffss.v2
git commit -m "chore(v2): projet Flutter live_ffss.v2, doc API à la racine, CI sur les deux apps"
```

---

### Tâche 2 : le cœur copié de la v1 (erreurs, environnements, réseau, stockage)

**Files :**
- Create : `lib/core/errors/app_exception.dart`, `lib/core/config/app_environment.dart`, `lib/core/config/app_config.dart`, `lib/core/network/token_storage.dart`, `lib/core/network/http_client.dart`, `lib/core/storage/local_store.dart`, `lib/core/providers.dart`
- Test : `test/core/network/http_client_test.dart`, `test/core/network/token_storage_test.dart`, `test/core/storage/local_store_test.dart`, `test/support/in_memory_local_store.dart`
- Delete : `test/smoke_test.dart`

(Tous les chemins de cette tâche et des suivantes sont relatifs à `live_ffss.v2/`, sauf mention contraire.)

**Interfaces :**
- Produces :
  - `sealed class AppException { String message; String get detail; }` et ses sous-classes `NetworkException`, `ApiException({int? statusCode, String? code, bool? authenticated})`, `AuthException`, `UnknownException`
  - `enum AppEnvironment { production, development }` avec `baseUrl`, `apiVersion`, `storagePrefix`, `label`, `static AppEnvironment? owner(String key)`
  - `class AppConfig { baseUrl, apiVersion, environment; const AppConfig.production(); factory AppConfig.forEnvironment(AppEnvironment) }`
  - `class ApiEndpoints { competitionList, meetingList; static String replacePath(String, Map<String, String>) }`
  - `class HttpClient { Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? query}); post(...); set onAuthFailure(...) }`
  - `class TokenStorage { getToken(); setToken(String); clearToken(); }`
  - `abstract interface class LocalStore { Future<String?> read(String key); Future<void> write(String key, String value); Future<void> delete(String key); }`, `class SecureLocalStore implements LocalStore`
  - fournisseurs `secureStorageProvider`, `appConfigProvider`, `tokenStorageProvider`, `httpClientProvider`, `localStoreProvider`, `clockProvider` (`Provider<DateTime Function()>`)
  - `class InMemoryLocalStore implements LocalStore` (tests uniquement, avec `Map<String, String> values`)

- [ ] **Étape 1 : copier les tests du client HTTP et du stockage du jeton**

```bash
mkdir -p test/core/network test/core/storage test/support
cp ../live_ffss/test/core/network/http_client_test.dart test/core/network/
cp ../live_ffss/test/core/network/token_storage_test.dart test/core/network/
sed -i 's#package:live_ffss/app/#package:live_ffss_v2/#g' test/core/network/*.dart
```

Puis, dans `test/core/network/http_client_test.dart` :
1. supprimer la ligne `import 'package:live_ffss_v2/core/network/http_log.dart';` ;
2. supprimer tout le `group('journal HTTP', () { … });` (en v1, de la ligne `group('journal HTTP'` jusqu'à son `});` fermant, juste avant `group('delai de requete'`).

Tous les autres groupes restent tels quels (URL, en-têtes, jeton en paramètre, `"false"`, 403 « Invalid token », `onAuthFailure`, réponses booléennes nues, délai).

- [ ] **Étape 2 : lancer les tests pour les voir échouer**

Run : `flutter test test/core/network`
Expected : FAIL — `Target of URI doesn't exist: 'package:live_ffss_v2/core/config/app_config.dart'`.

- [ ] **Étape 3 : copier le code du cœur**

```bash
mkdir -p lib/core/errors lib/core/config lib/core/network lib/core/storage
cp ../live_ffss/lib/app/core/errors/app_exception.dart lib/core/errors/
cp ../live_ffss/lib/app/core/config/app_environment.dart lib/core/config/
cp ../live_ffss/lib/app/core/network/token_storage.dart lib/core/network/
cp ../live_ffss/lib/app/core/network/http_client.dart lib/core/network/
sed -i 's#package:live_ffss/app/#package:live_ffss_v2/#g' lib/core/*/*.dart
```

Puis appliquer exactement ces modifications :

**`lib/core/errors/app_exception.dart`** : supprimer la classe `RfidException` (le NFC n'existe pas en v2).

**`lib/core/config/app_environment.dart`** : supprimer la méthode `resolve` et son commentaire, ainsi que la constante `httpLogKey` et son commentaire. Remplacer `globalKeys` par :

```dart
  /// Clés qui n'appartiennent à aucun environnement : elles survivent à une
  /// bascule comme à un effacement scopé. `language` est une préférence
  /// d'interface, elle ne vient pas du serveur.
  static const Set<String> globalKeys = {'language', environmentKey};
```

Au lot 1, l'environnement ne se choisit pas (voir la spec, § 4) : `resolve` reviendra au lot 4.

**`lib/core/network/http_client.dart`** :
1. supprimer l'import de `http_log.dart` ;
2. supprimer la méthode `_record` entière et son commentaire ;
3. dans `_send`, supprimer la variable `started` et les quatre appels `_record(...)`, et remplacer `Uri? uri;` + `uri = _buildUri(...)` par une simple variable locale `final uri = _buildUri(path, query, token);` déclarée dans le `try` ;
4. le reste ne change pas, y compris `onAuthFailure` : le lot 4 s'en servira pour la session.

Après modification, le corps de `_send` doit être :

```dart
  Future<Map<String, dynamic>> _send({
    required String method,
    required String path,
    required Future<http.Response> Function(
            Uri uri, Map<String, String> headers)
        send,
    Map<String, dynamic>? query,
    Object? body,
  }) async {
    try {
      final token = await _tokenStorage.getToken();
      final uri = _buildUri(path, query, token);
      // Arme le délai que le `catch` ci-dessous attrape : `http` n'en pose
      // aucun, donc une socket que le serveur laisse pendre ne revenait jamais
      // et l'écran appelant tournait en rond pour toujours.
      final response =
          await send(uri, _buildHeaders(token)).timeout(_requestTimeout);
      return _decode(response,
          authenticated: token != null && token.isNotEmpty);
    } on AppException {
      rethrow;
    } on SocketException catch (e) {
      throw NetworkException(e.message);
    } on TimeoutException catch (e) {
      throw NetworkException(e.message ?? 'Request timed out');
    } on http.ClientException catch (e) {
      // Ce que le web lève à la place de SocketException, qui n'y existe pas.
      throw NetworkException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }
```

Si `method` et `body` deviennent inutilisés, l'analyseur ne le signale pas (ce sont des paramètres nommés) : les garder, `get` et `post` les passent toujours.

**`lib/core/config/app_config.dart`** (créé, pas copié) :

```dart
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

  static String replacePath(String path, Map<String, String> params) {
    var result = path;
    params.forEach((key, value) {
      result = result.replaceAll(':$key', value);
    });
    return result;
  }
}
```

- [ ] **Étape 4 : lancer les tests copiés**

Run : `flutter test test/core/network`
Expected : PASS. Si un test compare deux `AppConfig` avec `==` (la v1 le surchargeait), ajouter à `AppConfig` le même `operator ==` et `hashCode` que la v1 (sur `baseUrl`, `apiVersion`, `environment`).

- [ ] **Étape 5 : écrire le test du stockage local**

`test/support/in_memory_local_store.dart` :

```dart
import 'package:live_ffss_v2/core/storage/local_store.dart';

class InMemoryLocalStore implements LocalStore {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}
```

`test/core/storage/local_store_test.dart` :

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/config/app_environment.dart';
import 'package:live_ffss_v2/core/storage/local_store.dart';
import 'package:mocktail/mocktail.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockSecureStorage storage;

  setUp(() {
    storage = _MockSecureStorage();
    when(() => storage.read(key: any(named: 'key')))
        .thenAnswer((_) async => 'v');
    when(() => storage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        )).thenAnswer((_) async {});
  });

  test('en production, la clé est lue telle quelle', () async {
    final store = SecureLocalStore(storage, AppEnvironment.production);

    expect(await store.read('favorite_competitions'), 'v');
    verify(() => storage.read(key: 'favorite_competitions')).called(1);
  });

  test('en développement, la clé porte le préfixe dev_', () async {
    final store = SecureLocalStore(storage, AppEnvironment.development);

    await store.write('favorite_competitions', '[1]');

    verify(() => storage.write(key: 'dev_favorite_competitions', value: '[1]'))
        .called(1);
  });

  test('une clé globale n\'est jamais préfixée', () async {
    final store = SecureLocalStore(storage, AppEnvironment.development);

    await store.read('language');

    verify(() => storage.read(key: 'language')).called(1);
  });
}
```

- [ ] **Étape 6 : lancer le test pour le voir échouer**

Run : `flutter test test/core/storage`
Expected : FAIL — `local_store.dart` n'existe pas.

- [ ] **Étape 7 : écrire le stockage local et les fournisseurs du cœur**

`lib/core/storage/local_store.dart` :

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:live_ffss_v2/core/config/app_environment.dart';

/// Les préférences de l'appareil (favoris, compétition active). Une interface
/// pour que les tests des fournisseurs tournent sur une simple Map, sans
/// simuler le stockage sécurisé.
abstract interface class LocalStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// Cloisonne les clés par environnement selon la règle de
/// [AppEnvironment.owner] : préfixe vide en production, `dev_` en
/// développement, aucun préfixe pour une clé globale.
class SecureLocalStore implements LocalStore {
  SecureLocalStore(this._storage, this._environment);

  final FlutterSecureStorage _storage;
  final AppEnvironment _environment;

  String _scoped(String key) => AppEnvironment.globalKeys.contains(key)
      ? key
      : '${_environment.storagePrefix}$key';

  @override
  Future<String?> read(String key) => _storage.read(key: _scoped(key));

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: _scoped(key), value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: _scoped(key));
}
```

`lib/core/providers.dart` :

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:live_ffss_v2/core/config/app_config.dart';
import 'package:live_ffss_v2/core/network/http_client.dart';
import 'package:live_ffss_v2/core/network/token_storage.dart';
import 'package:live_ffss_v2/core/storage/local_store.dart';

final secureStorageProvider =
    Provider<FlutterSecureStorage>((ref) => const FlutterSecureStorage());

final appConfigProvider =
    Provider<AppConfig>((ref) => const AppConfig.production());

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => TokenStorage(
    ref.watch(secureStorageProvider),
    environment: ref.watch(appConfigProvider).environment,
  ),
);

final httpClientProvider = Provider<HttpClient>(
  (ref) => HttpClient(
    config: ref.watch(appConfigProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  ),
);

final localStoreProvider = Provider<LocalStore>(
  (ref) => SecureLocalStore(
    ref.watch(secureStorageProvider),
    ref.watch(appConfigProvider).environment,
  ),
);

/// L'heure courante, remplaçable dans les tests : le découpage de l'accueil
/// et « Jour 1/3 » en dépendent.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
```

- [ ] **Étape 8 : vérifier et commiter**

```bash
rm test/smoke_test.dart
flutter test && flutter analyze && dart format lib test
git add -A . && git commit -m "feat(v2): cœur repris de la v1 — erreurs, environnements, HttpClient, stockage local"
```

Expected : `All tests passed!`, `No issues found!`.

---

### Tâche 3 : domaine — `Discipline`, `CompetitionSummary`, `partitionHome`

**Files :**
- Create : `lib/domain/discipline.dart`, `lib/domain/competition_summary.dart`, `lib/domain/home_partition.dart`
- Test : `test/domain/home_partition_test.dart`, `test/support/competitions.dart`

**Interfaces :**
- Produces :
  - `enum Discipline { flatWater, coastal }`
  - `CompetitionSummary({required int id, required String name, required DateTime startDate, required DateTime endDate, required Set<Discipline> disciplines, String? organizer, String? location})` (freezed)
  - `const int recentWindowDays = 14;`
  - `class HomePartition { final List<CompetitionSummary> live, upcoming, recent; }`
  - `HomePartition partitionHome(List<CompetitionSummary> competitions, DateTime today)`
  - `DateTime dayOf(DateTime moment)` (minuit local du jour de `moment`)
  - (tests) `CompetitionSummary competition(int id, {String? name, required DateTime start, DateTime? end, Set<Discipline> disciplines = const {Discipline.flatWater}})`

- [ ] **Étape 1 : écrire le domaine sans logique (types seulement)**

`lib/domain/discipline.dart` :

```dart
/// Discipline d'une épreuve, comme `Discipline` dans FFSSCompetition V3.
/// « Eau plate » partout, jamais « Piscine ».
enum Discipline { flatWater, coastal }
```

`lib/domain/competition_summary.dart` :

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/domain/discipline.dart';

part 'competition_summary.freezed.dart';

/// Une compétition de la liste en ligne : la forme de
/// `FfssCompetitionSummary` dans FFSSCompetition V3. Les dates sont des jours
/// (minuit local), sans heure.
///
/// `disciplines` est un ensemble parce que Dart n'a pas d'énumération
/// combinable comme le `[Flags] Disciplines` de V3 : une compétition mixte
/// contient les deux.
@freezed
abstract class CompetitionSummary with _$CompetitionSummary {
  const factory CompetitionSummary({
    required int id,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required Set<Discipline> disciplines,
    String? organizer,
    String? location,
  }) = _CompetitionSummary;
}
```

Run : `dart run build_runner build --delete-conflicting-outputs`
Expected : `competition_summary.freezed.dart` créé.

- [ ] **Étape 2 : écrire les tests de `partitionHome`**

`test/support/competitions.dart` :

```dart
import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/domain/discipline.dart';

CompetitionSummary competition(
  int id, {
  String? name,
  required DateTime start,
  DateTime? end,
  Set<Discipline> disciplines = const {Discipline.flatWater},
}) =>
    CompetitionSummary(
      id: id,
      name: name ?? 'Compétition $id',
      startDate: start,
      endDate: end ?? start,
      disciplines: disciplines,
    );
```

`test/domain/home_partition_test.dart` :

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/domain/home_partition.dart';

import '../support/competitions.dart';

void main() {
  final today = DateTime(2026, 10, 17, 9, 42);

  List<int> ids(List<CompetitionSummary> list) => [for (final c in list) c.id];

  group('partitionHome — en direct', () {
    test('une compétition commencée hier et finie demain est en direct', () {
      final p = partitionHome([
        competition(1, start: DateTime(2026, 10, 16), end: DateTime(2026, 10, 18)),
      ], today);

      expect(ids(p.live), [1]);
      expect(p.upcoming, isEmpty);
      expect(p.recent, isEmpty);
    });

    test('une compétition qui commence ou finit aujourd\'hui est en direct', () {
      final p = partitionHome([
        competition(1, start: DateTime(2026, 10, 17), end: DateTime(2026, 10, 19)),
        competition(2, start: DateTime(2026, 10, 15), end: DateTime(2026, 10, 17)),
      ], today);

      expect(ids(p.live), [2, 1]);
    });
  });

  group('partitionHome — à venir', () {
    test('triées par date de début puis par nom', () {
      final p = partitionHome([
        competition(1, name: 'B', start: DateTime(2026, 11, 1)),
        competition(2, name: 'Z', start: DateTime(2026, 10, 18)),
        competition(3, name: 'A', start: DateTime(2026, 11, 1)),
      ], today);

      expect(ids(p.upcoming), [2, 3, 1]);
    });
  });

  group('partitionHome — terminées récemment', () {
    test('finie il y a exactement 14 jours : encore récente', () {
      final p = partitionHome([
        competition(1, start: DateTime(2026, 10, 3)),
      ], today);

      expect(ids(p.recent), [1]);
    });

    test('finie il y a 15 jours : écartée', () {
      final p = partitionHome([
        competition(1, start: DateTime(2026, 10, 2)),
      ], today);

      expect(p.live, isEmpty);
      expect(p.upcoming, isEmpty);
      expect(p.recent, isEmpty);
    });

    test('de la plus récente à la plus ancienne', () {
      final p = partitionHome([
        competition(1, start: DateTime(2026, 10, 5)),
        competition(2, start: DateTime(2026, 10, 12), end: DateTime(2026, 10, 16)),
      ], today);

      expect(ids(p.recent), [2, 1]);
    });

    test('le passage à l\'heure d\'hiver ne décale pas la fenêtre', () {
      // Le 25 octobre 2026, l'heure recule : soustraire 14 × 24 h à minuit
      // tomberait la veille à 23 h et ferait entrer une compétition de trop.
      final afterDst = DateTime(2026, 11, 8, 10);
      final p = partitionHome([
        competition(1, start: DateTime(2026, 10, 25)),
        competition(2, start: DateTime(2026, 10, 24)),
      ], afterDst);

      expect(ids(p.recent), [1]);
    });
  });

  test('dayOf ramène un instant à minuit du même jour', () {
    expect(dayOf(DateTime(2026, 3, 27, 23, 59)), DateTime(2026, 3, 27));
  });
}
```

- [ ] **Étape 3 : lancer les tests pour les voir échouer**

Run : `flutter test test/domain/home_partition_test.dart`
Expected : FAIL — `home_partition.dart` n'existe pas.

- [ ] **Étape 4 : écrire `partitionHome`**

`lib/domain/home_partition.dart` :

```dart
import 'package:live_ffss_v2/domain/competition_summary.dart';

/// Les compétitions terminées depuis au plus ce nombre de jours restent sur
/// l'accueil.
const int recentWindowDays = 14;

/// Minuit local du jour de [moment].
DateTime dayOf(DateTime moment) =>
    DateTime(moment.year, moment.month, moment.day);

/// Les trois groupes de l'accueil.
class HomePartition {
  const HomePartition({
    required this.live,
    required this.upcoming,
    required this.recent,
  });

  final List<CompetitionSummary> live;
  final List<CompetitionSummary> upcoming;
  final List<CompetitionSummary> recent;
}

/// Découpe [competitions] par rapport au jour de [today] :
/// - en direct : début ≤ aujourd'hui ≤ fin, par date de début puis par nom ;
/// - à venir : début > aujourd'hui, même tri ;
/// - terminées récemment : fin dans les [recentWindowDays] jours précédents,
///   de la plus récente à la plus ancienne.
///
/// Les jours sont reconstruits avec `DateTime(y, m, d - n)` plutôt qu'en
/// soustrayant une durée : au changement d'heure, 14 × 24 h depuis minuit ne
/// retombent pas sur minuit.
HomePartition partitionHome(
  List<CompetitionSummary> competitions,
  DateTime today,
) {
  final day = dayOf(today);
  final recentFrom = DateTime(day.year, day.month, day.day - recentWindowDays);

  final live = <CompetitionSummary>[];
  final upcoming = <CompetitionSummary>[];
  final recent = <CompetitionSummary>[];
  for (final c in competitions) {
    if (c.startDate.isAfter(day)) {
      upcoming.add(c);
    } else if (!c.endDate.isBefore(day)) {
      live.add(c);
    } else if (!c.endDate.isBefore(recentFrom)) {
      recent.add(c);
    }
  }

  int byStart(CompetitionSummary a, CompetitionSummary b) {
    final order = a.startDate.compareTo(b.startDate);
    return order != 0 ? order : a.name.compareTo(b.name);
  }

  live.sort(byStart);
  upcoming.sort(byStart);
  recent.sort((a, b) {
    final order = b.endDate.compareTo(a.endDate);
    return order != 0 ? order : a.name.compareTo(b.name);
  });
  return HomePartition(live: live, upcoming: upcoming, recent: recent);
}
```

- [ ] **Étape 5 : lancer les tests**

Run : `flutter test test/domain/home_partition_test.dart`
Expected : PASS (7 tests).

- [ ] **Étape 6 : commiter**

```bash
dart format lib test && flutter analyze
git add -A . && git commit -m "feat(v2): domaine — CompetitionSummary et découpage de l'accueil"
```

---

### Tâche 4 : domaine — réunions, séries et règle « maintenant »

**Files :**
- Create : `lib/domain/gender.dart`, `lib/domain/run_status.dart`, `lib/domain/heat.dart`, `lib/domain/meeting.dart`, `lib/domain/now_running.dart`
- Test : `test/domain/run_status_test.dart`, `test/domain/now_running_test.dart`

**Interfaces :**
- Produces :
  - `enum Gender { female, male, mixed }`
  - `enum RunStatus { waiting(0), marshalling(1), inProgress(2), finished(3); final int code; static RunStatus fromCode(int? code) }`
  - `Heat({required int id, required String name, required int number, required RunStatus status, DateTime? plannedStart, DateTime? plannedEnd, int? raceId, String raceName = '', Gender? gender})` (freezed)
  - `MeetingItem({required int id, required String name, int? roundId, List<Heat> heats = const []})` (freezed)
  - `Meeting({required int id, required String name, required DateTime day, DateTime? startTime, DateTime? endTime, List<MeetingItem> items = const []})` (freezed)
  - `enum NowRunningKind { now, next }`
  - `NowRunning({required Heat heat, required NowRunningKind kind, required int position, required int total})` (freezed)
  - `NowRunning? nowRunning(List<Meeting> meetings)`

- [ ] **Étape 1 : écrire les types**

`lib/domain/gender.dart` :

```dart
/// Genre d'une épreuve, comme `Gender` dans FFSSCompetition V3.
enum Gender { female, male, mixed }
```

`lib/domain/run_status.dart` :

```dart
/// Statut d'une course sur le site FFSS. Les codes sont ceux des constantes de
/// `ResultPublisher` dans FFSSCompetition V3, qui les publie : « En cours »
/// dès que l'heure de début prévue est passée ou qu'un résultat est saisi,
/// « Terminé » une fois la série validée.
enum RunStatus {
  waiting(0),
  marshalling(1),
  inProgress(2),
  finished(3);

  const RunStatus(this.code);

  final int code;

  /// Un code inconnu vaut « En attente », comme `ResultPublisher.StatusName`
  /// dans V3.
  static RunStatus fromCode(int? code) {
    for (final status in values) {
      if (status.code == code) return status;
    }
    return waiting;
  }
}
```

`lib/domain/heat.dart` :

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/domain/gender.dart';
import 'package:live_ffss_v2/domain/run_status.dart';

part 'heat.freezed.dart';

/// Une série telle que le site FFSS la publie (une « course » FFSS), comme
/// `Heat` dans FFSSCompetition V3. Version minimale du lot 1 : ce que la
/// carte en direct affiche. Le lot 2 l'enrichit.
@freezed
abstract class Heat with _$Heat {
  const factory Heat({
    required int id,
    required String name,
    required int number,
    required RunStatus status,
    DateTime? plannedStart,
    DateTime? plannedEnd,
    int? raceId,
    @Default('') String raceName,
    Gender? gender,
  }) = _Heat;
}
```

`lib/domain/meeting.dart` :

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/domain/heat.dart';

part 'meeting.freezed.dart';

/// Un élément de réunion (un « créneau » FFSS), comme `MeetingItem` dans
/// FFSSCompetition V3.
@freezed
abstract class MeetingItem with _$MeetingItem {
  const factory MeetingItem({
    required int id,
    required String name,
    /// La « partie » FFSS que le créneau couvre, comme `MeetingItem.RoundId`
    /// dans V3. Nulle pour un créneau sans tour.
    int? roundId,
    @Default(<Heat>[]) List<Heat> heats,
  }) = _MeetingItem;
}

/// Une réunion d'une compétition, comme `Meeting` dans FFSSCompetition V3.
@freezed
abstract class Meeting with _$Meeting {
  const factory Meeting({
    required int id,
    required String name,
    required DateTime day,
    DateTime? startTime,
    DateTime? endTime,
    @Default(<MeetingItem>[]) List<MeetingItem> items,
  }) = _Meeting;
}
```

`lib/domain/now_running.dart` (types seulement pour l'instant ; la fonction vient à l'étape 4) :

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/meeting.dart';

part 'now_running.freezed.dart';

enum NowRunningKind { now, next }

/// La série à afficher sur la carte en direct, avec son rang parmi les séries
/// de la même épreuve et du même tour (« Série 4/10 »).
@freezed
abstract class NowRunning with _$NowRunning {
  const factory NowRunning({
    required Heat heat,
    required NowRunningKind kind,
    required int position,
    required int total,
  }) = _NowRunning;
}

NowRunning? nowRunning(List<Meeting> meetings) => null;
```

Run : `dart run build_runner build --delete-conflicting-outputs`

- [ ] **Étape 2 : écrire les tests**

`test/domain/run_status_test.dart` :

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/domain/run_status.dart';

void main() {
  test('les codes 0 à 3 sont ceux de ResultPublisher dans V3', () {
    expect(RunStatus.fromCode(0), RunStatus.waiting);
    expect(RunStatus.fromCode(1), RunStatus.marshalling);
    expect(RunStatus.fromCode(2), RunStatus.inProgress);
    expect(RunStatus.fromCode(3), RunStatus.finished);
  });

  test('un code inconnu ou absent vaut « En attente »', () {
    expect(RunStatus.fromCode(9), RunStatus.waiting);
    expect(RunStatus.fromCode(null), RunStatus.waiting);
  });
}
```

`test/domain/now_running_test.dart` :

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/now_running.dart';
import 'package:live_ffss_v2/domain/run_status.dart';

Heat heat(
  int id, {
  required int number,
  required RunStatus status,
  required String at,
  int raceId = 1,
}) {
  final parts = at.split(':');
  return Heat(
    id: id,
    name: 'Série $number',
    number: number,
    status: status,
    plannedStart: DateTime(2026, 3, 27, int.parse(parts[0]), int.parse(parts[1])),
    raceId: raceId,
    raceName: '200 m Obstacles',
  );
}

Meeting meeting(List<MeetingItem> items) =>
    Meeting(id: 1, name: 'Eau Plate 1 – Séries', day: DateTime(2026, 3, 27), items: items);

void main() {
  test('programme vide : rien à afficher', () {
    expect(nowRunning(const []), isNull);
    expect(nowRunning([meeting(const [])]), isNull);
  });

  test('une série en cours : MAINTENANT, avec son rang dans le tour', () {
    final result = nowRunning([
      meeting([
        MeetingItem(id: 10, name: '200 m Obstacles D', roundId: 100, heats: [
          heat(1, number: 1, status: RunStatus.finished, at: '06:45'),
          heat(2, number: 2, status: RunStatus.inProgress, at: '06:48'),
          heat(3, number: 3, status: RunStatus.waiting, at: '06:51'),
        ]),
      ]),
    ]);

    expect(result?.heat.id, 2);
    expect(result?.kind, NowRunningKind.now);
    expect(result?.position, 2);
    expect(result?.total, 3);
  });

  test('plusieurs séries en cours : la dernière partie', () {
    final result = nowRunning([
      meeting([
        MeetingItem(id: 10, name: 'D', roundId: 100, heats: [
          heat(1, number: 1, status: RunStatus.inProgress, at: '06:45'),
          heat(2, number: 2, status: RunStatus.inProgress, at: '06:48'),
        ]),
      ]),
    ]);

    expect(result?.heat.id, 2);
  });

  test('aucune série en cours : la prochaine, libellée À SUIVRE', () {
    final result = nowRunning([
      meeting([
        MeetingItem(id: 10, name: 'D', roundId: 100, heats: [
          heat(1, number: 1, status: RunStatus.finished, at: '06:45'),
          heat(3, number: 3, status: RunStatus.waiting, at: '06:51'),
          heat(2, number: 2, status: RunStatus.marshalling, at: '06:48'),
        ]),
      ]),
    ]);

    expect(result?.heat.id, 2);
    expect(result?.kind, NowRunningKind.next);
  });

  test('tout est terminé : rien à afficher', () {
    expect(
      nowRunning([
        meeting([
          MeetingItem(id: 10, name: 'D', heats: [
            heat(1, number: 1, status: RunStatus.finished, at: '06:45'),
          ]),
        ]),
      ]),
      isNull,
    );
  });

  test('le rang compte les séries du même tour réparties sur deux créneaux', () {
    final result = nowRunning([
      meeting([
        MeetingItem(id: 10, name: 'D (1)', roundId: 100, heats: [
          heat(1, number: 1, status: RunStatus.finished, at: '06:45'),
          heat(2, number: 2, status: RunStatus.finished, at: '06:48'),
        ]),
        MeetingItem(id: 11, name: 'M', roundId: 200, heats: [
          heat(5, number: 1, status: RunStatus.waiting, at: '07:19', raceId: 2),
        ]),
        MeetingItem(id: 12, name: 'D (2)', roundId: 100, heats: [
          heat(3, number: 3, status: RunStatus.inProgress, at: '06:51'),
          heat(4, number: 4, status: RunStatus.waiting, at: '06:54'),
        ]),
      ]),
    ]);

    expect(result?.heat.id, 3);
    expect(result?.position, 3);
    expect(result?.total, 4);
  });

  test('sans partie, les séries sont regroupées par créneau', () {
    final result = nowRunning([
      meeting([
        MeetingItem(id: 10, name: 'A', heats: [
          heat(1, number: 1, status: RunStatus.inProgress, at: '06:45'),
        ]),
        MeetingItem(id: 11, name: 'B', heats: [
          heat(2, number: 2, status: RunStatus.waiting, at: '06:50'),
        ]),
      ]),
    ]);

    expect(result?.total, 1);
  });

  test('une série sans heure prévue n\'empêche pas le calcul', () {
    final result = nowRunning([
      meeting([
        MeetingItem(id: 10, name: 'D', roundId: 100, heats: [
          const Heat(id: 1, name: 'Série 1', number: 1, status: RunStatus.waiting),
          heat(2, number: 2, status: RunStatus.waiting, at: '06:48'),
        ]),
      ]),
    ]);

    expect(result?.heat.id, 2);
  });
}
```

- [ ] **Étape 3 : lancer les tests pour les voir échouer**

Run : `flutter test test/domain`
Expected : `run_status_test` PASS ; `now_running_test` FAIL (la fonction renvoie toujours `null`).

- [ ] **Étape 4 : écrire la règle « maintenant »**

Remplacer la ligne `NowRunning? nowRunning(List<Meeting> meetings) => null;` de `lib/domain/now_running.dart` par :

```dart
/// La série à afficher sur la carte en direct :
/// 1. la dernière série « En cours », d'après son heure de début prévue
///    (« MAINTENANT ») ;
/// 2. sinon la prochaine qui n'a pas commencé, « En attente » ou en
///    chambre d'appel (« À SUIVRE ») ;
/// 3. sinon rien.
///
/// Le rang (« Série 4/10 ») se compte parmi les séries de la même épreuve et
/// du même tour : V3 peut répartir les séries d'un tour sur plusieurs
/// créneaux, d'où le regroupement par partie et non par créneau. Un créneau
/// sans partie forme son propre groupe.
NowRunning? nowRunning(List<Meeting> meetings) {
  final entries = <({Heat heat, String group})>[
    for (final meeting in meetings)
      for (final item in meeting.items)
        for (final heat in item.heats)
          (
            heat: heat,
            group: '${heat.raceId}|'
                '${item.roundId != null ? 'r${item.roundId}' : 'c${item.id}'}',
          ),
  ];

  final early = DateTime(0);
  final late = DateTime(9999);

  ({Heat heat, String group})? current;
  for (final entry in entries) {
    if (entry.heat.status != RunStatus.inProgress) continue;
    final start = entry.heat.plannedStart ?? early;
    if (current == null ||
        !start.isBefore(current.heat.plannedStart ?? early)) {
      current = entry;
    }
  }

  var kind = NowRunningKind.now;
  if (current == null) {
    kind = NowRunningKind.next;
    for (final entry in entries) {
      final status = entry.heat.status;
      if (status != RunStatus.waiting && status != RunStatus.marshalling) {
        continue;
      }
      final start = entry.heat.plannedStart ?? late;
      if (current == null || start.isBefore(current.heat.plannedStart ?? late)) {
        current = entry;
      }
    }
  }
  if (current == null) return null;

  final group = [
    for (final entry in entries)
      if (entry.group == current.group) entry.heat,
  ]..sort((a, b) {
      final order = a.number.compareTo(b.number);
      if (order != 0) return order;
      return (a.plannedStart ?? early).compareTo(b.plannedStart ?? early);
    });

  return NowRunning(
    heat: current.heat,
    kind: kind,
    position: group.indexOf(current.heat) + 1,
    total: group.length,
  );
}
```

La spec dit « la prochaine série En attente » : la chambre d'appel (`marshalling`) y est ajoutée, parce qu'une série appelée au départ est encore plus « à suivre » qu'une série en attente.

- [ ] **Étape 5 : lancer les tests**

Run : `flutter test test/domain`
Expected : PASS.

- [ ] **Étape 6 : commiter**

```bash
dart format lib test && flutter analyze
git add -A . && git commit -m "feat(v2): domaine — Meeting, MeetingItem, Heat et règle « maintenant »"
```

---

### Tâche 5 : données — `EvenementDto` et son mapper

**Files :**
- Create : `lib/data/ffss/dtos/json_readers.dart`, `lib/data/ffss/dtos/evenement_dto.dart`, `lib/data/ffss/mappers/ffss_dates.dart`, `lib/data/ffss/mappers/evenement_mapper.dart`
- Test : `test/data/ffss/mappers/ffss_dates_test.dart`, `test/data/ffss/mappers/evenement_mapper_test.dart`

**Interfaces :**
- Consumes : `CompetitionSummary`, `Discipline` (tâche 3)
- Produces :
  - `Object? readInt(Map<dynamic, dynamic> json, String key)`, `Object? readMap(Map<dynamic, dynamic> json, String key)`
  - `EvenementDto.fromJson(Map<String, dynamic>)` (freezed)
  - `DateTime? parseFfssDay(String? raw)`, `DateTime? atFfssTime(DateTime day, String? raw)`
  - `extension EvenementMapper on EvenementDto { CompetitionSummary? toDomain(); }`

- [ ] **Étape 1 : écrire les tests des dates FFSS**

`test/data/ffss/mappers/ffss_dates_test.dart` :

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/data/ffss/mappers/ffss_dates.dart';

void main() {
  group('parseFfssDay', () {
    test('lit une date seule ou une date avec heure, et garde le jour', () {
      expect(parseFfssDay('2026-03-27'), DateTime(2026, 3, 27));
      expect(parseFfssDay('2026-03-27 14:30:00'), DateTime(2026, 3, 27));
    });

    test('absente, vide ou illisible : nulle', () {
      expect(parseFfssDay(null), isNull);
      expect(parseFfssDay(''), isNull);
      expect(parseFfssDay('bientôt'), isNull);
    });
  });

  group('atFfssTime', () {
    final day = DateTime(2026, 3, 27);

    test('lit HH:mm, HH:mm:ss et une date-heure complète', () {
      expect(atFfssTime(day, '08:46'), DateTime(2026, 3, 27, 8, 46));
      expect(atFfssTime(day, '08:46:00'), DateTime(2026, 3, 27, 8, 46));
      expect(atFfssTime(day, '2026-03-27 08:46:00'), DateTime(2026, 3, 27, 8, 46));
    });

    test('absente, vide ou illisible : nulle', () {
      expect(atFfssTime(day, null), isNull);
      expect(atFfssTime(day, ''), isNull);
      expect(atFfssTime(day, 'midi'), isNull);
      expect(atFfssTime(day, '25:00'), isNull);
    });
  });
}
```

- [ ] **Étape 2 : écrire les tests du mapper**

`test/data/ffss/mappers/evenement_mapper_test.dart` :

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/data/ffss/dtos/evenement_dto.dart';
import 'package:live_ffss_v2/data/ffss/mappers/evenement_mapper.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/domain/discipline.dart';

CompetitionSummary? map(Map<String, dynamic> json) =>
    EvenementDto.fromJson(json).toDomain();

Map<String, dynamic> evenement([Map<String, dynamic> overrides = const {}]) => {
      'Id': 1453,
      'Nom': 'Championnats de France N1 2026',
      'Debut': '2026-03-27',
      'Fin': '2026-03-29',
      'Specialite': 2,
      'specialiteLabel': 'Eau plate',
      'Lieu': 'Montpellier',
      'Organisme': {'NomOrga': 'FFSS', 'label': 'Fédération'},
      ...overrides,
    };

void main() {
  test('une compétition complète', () {
    expect(
      map(evenement()),
      CompetitionSummary(
        id: 1453,
        name: 'Championnats de France N1 2026',
        startDate: DateTime(2026, 3, 27),
        endDate: DateTime(2026, 3, 29),
        disciplines: const {Discipline.flatWater},
        organizer: 'FFSS',
        location: 'Montpellier',
      ),
    );
  });

  group('spécialité (règle de ParseEventDisciplines dans V3)', () {
    test('1 côtier, 2 eau plate, 3 mixte', () {
      expect(map(evenement({'Specialite': 1}))?.disciplines, {Discipline.coastal});
      expect(map(evenement({'Specialite': 2}))?.disciplines, {Discipline.flatWater});
      expect(map(evenement({'Specialite': 3}))?.disciplines,
          {Discipline.flatWater, Discipline.coastal});
    });

    test('servie en chaîne', () {
      expect(map(evenement({'Specialite': '1'}))?.disciplines, {Discipline.coastal});
    });

    test('sans code, le libellé fait foi', () {
      expect(map(evenement({'Specialite': null, 'specialiteLabel': 'Côtier'}))?.disciplines,
          {Discipline.coastal});
      expect(map(evenement({'Specialite': null, 'specialiteLabel': 'Mixte'}))?.disciplines,
          {Discipline.flatWater, Discipline.coastal});
      expect(map(evenement({'Specialite': null, 'specialiteLabel': null}))?.disciplines,
          {Discipline.flatWater});
    });
  });

  group('dates', () {
    test('fin absente : la compétition dure un jour', () {
      expect(map(evenement({'Fin': null}))?.endDate, DateTime(2026, 3, 27));
    });

    test('fin antérieure au début : ramenée au début, comme V3', () {
      expect(map(evenement({'Fin': '2026-03-20'}))?.endDate, DateTime(2026, 3, 27));
    });

    test('début absent ou illisible : écartée', () {
      expect(map(evenement({'Debut': null})), isNull);
      expect(map(evenement({'Debut': 'bientôt'})), isNull);
    });
  });

  group('robustesse', () {
    test('Id servi en chaîne', () {
      expect(map(evenement({'Id': '1453'}))?.id, 1453);
    });

    test('sans Id ou sans nom : écartée', () {
      expect(map(evenement({'Id': null})), isNull);
      expect(map(evenement({'Nom': '  '})), isNull);
    });

    test('Organisme servi en tableau vide (PHP) : pas d\'organisateur', () {
      expect(map(evenement({'Organisme': <Object>[]}))?.organizer, isNull);
    });

    test('Organisme sans NomOrga : son label', () {
      expect(map(evenement({'Organisme': {'label': 'CD 13 FFSS'}}))?.organizer,
          'CD 13 FFSS');
    });

    test('Lieu vide : pas de lieu', () {
      expect(map(evenement({'Lieu': ' '}))?.location, isNull);
    });
  });
}
```

- [ ] **Étape 3 : lancer les tests pour les voir échouer**

Run : `flutter test test/data`
Expected : FAIL — fichiers inexistants.

- [ ] **Étape 4 : écrire les lecteurs JSON, le DTO et les dates**

`lib/data/ffss/dtos/json_readers.dart` :

```dart
/// FFSS sert certains nombres tantôt entiers, tantôt chaînes, selon la route.
Object? readInt(Map<dynamic, dynamic> json, String key) {
  final raw = json[key];
  if (raw is String) return int.tryParse(raw);
  return raw;
}

/// PHP sérialise un objet vide en `[]` : un objet attendu peut donc arriver
/// sous forme de tableau. Lu comme absent, au lieu de faire échouer la
/// lecture de toute la liste.
Object? readMap(Map<dynamic, dynamic> json, String key) {
  final raw = json[key];
  return raw is Map ? raw : null;
}
```

`lib/data/ffss/dtos/evenement_dto.dart` :

```dart
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/data/ffss/dtos/json_readers.dart';

part 'evenement_dto.freezed.dart';
part 'evenement_dto.g.dart';

/// Une ligne de `GET competition/evenement`. Tout est nullable : le mapper
/// écarte ou corrige une ligne incomplète, pour qu'elle ne fasse pas échouer
/// la liste entière.
@freezed
abstract class EvenementDto with _$EvenementDto {
  const factory EvenementDto({
    @JsonKey(name: 'Id', readValue: readInt) int? id,
    @JsonKey(name: 'Nom') String? name,
    @JsonKey(name: 'Debut') String? startDate,
    @JsonKey(name: 'Fin') String? endDate,
    @JsonKey(name: 'Specialite', readValue: readInt) int? speciality,
    @JsonKey(name: 'specialiteLabel') String? specialityLabel,
    // Absent de docs/FFSS_API.md, présent dans les vraies réponses : V3 le lit.
    @JsonKey(name: 'Lieu') String? location,
    @JsonKey(name: 'Organisme', readValue: readMap) OrganismeRefDto? organisme,
  }) = _EvenementDto;

  factory EvenementDto.fromJson(Map<String, dynamic> json) =>
      _$EvenementDtoFromJson(json);
}

@freezed
abstract class OrganismeRefDto with _$OrganismeRefDto {
  const factory OrganismeRefDto({
    @JsonKey(name: 'NomOrga') String? name,
    @JsonKey(name: 'label') String? label,
  }) = _OrganismeRefDto;

  factory OrganismeRefDto.fromJson(Map<String, dynamic> json) =>
      _$OrganismeRefDtoFromJson(json);
}
```

`lib/data/ffss/mappers/ffss_dates.dart` :

```dart
/// Le jour d'une date FFSS (`Y-m-d` ou `Y-m-d H:i:s`), à minuit local.
DateTime? parseFfssDay(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final parsed = DateTime.tryParse(raw.trim());
  return parsed == null
      ? null
      : DateTime(parsed.year, parsed.month, parsed.day);
}

/// L'heure FFSS [raw] (`HH:mm`, `HH:mm:ss`, ou une date-heure complète) posée
/// sur [day]. Nulle si elle est illisible : une heure mal formée ne doit pas
/// faire disparaître la série qui la porte.
DateTime? atFfssTime(DateTime day, String? raw) {
  if (raw == null) return null;
  var text = raw.trim();
  final space = text.indexOf(' ');
  if (space >= 0) text = text.substring(space + 1);
  final parts = text.split(':');
  if (parts.length < 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null || hour > 23 || minute > 59) return null;
  return DateTime(day.year, day.month, day.day, hour, minute);
}
```

- [ ] **Étape 5 : écrire le mapper**

`lib/data/ffss/mappers/evenement_mapper.dart` :

```dart
import 'package:live_ffss_v2/data/ffss/dtos/evenement_dto.dart';
import 'package:live_ffss_v2/data/ffss/mappers/ffss_dates.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/domain/discipline.dart';

extension EvenementMapper on EvenementDto {
  /// Nulle quand la ligne n'a ni id, ni nom, ni date de début lisible :
  /// sans date, la compétition ne peut être placée nulle part sur l'accueil.
  CompetitionSummary? toDomain() {
    final id = this.id;
    final name = this.name?.trim();
    final start = parseFfssDay(startDate);
    if (id == null || name == null || name.isEmpty || start == null) {
      return null;
    }
    final end = parseFfssDay(endDate);
    return CompetitionSummary(
      id: id,
      name: name,
      startDate: start,
      endDate: end == null || end.isBefore(start) ? start : end,
      disciplines: _disciplines(speciality, specialityLabel),
      organizer: _nonEmpty(organisme?.name) ?? _nonEmpty(organisme?.label),
      location: _nonEmpty(location),
    );
  }
}

/// La règle de `ParseEventDisciplines` dans V3 : 1 côtier, 3 mixte, sinon eau
/// plate ; sans code, le libellé fait foi.
Set<Discipline> _disciplines(int? code, String? label) {
  final text = label?.trim() ?? '';
  if (code == 1 || (code == null && text.toUpperCase().startsWith('C'))) {
    return {Discipline.coastal};
  }
  if (code == 3 || text.toLowerCase() == 'mixte') {
    return {Discipline.flatWater, Discipline.coastal};
  }
  return {Discipline.flatWater};
}

String? _nonEmpty(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
```

- [ ] **Étape 6 : générer et lancer les tests**

Run : `dart run build_runner build --delete-conflicting-outputs && flutter test test/data`
Expected : PASS.

- [ ] **Étape 7 : commiter**

```bash
dart format lib test && flutter analyze
git add -A . && git commit -m "feat(v2): données — EvenementDto et mapper vers CompetitionSummary"
```

---

### Tâche 6 : données — DTO de l'arbre des réunions et son mapper

**Files :**
- Create : `lib/data/ffss/dtos/reunion_dto.dart`, `lib/data/ffss/mappers/reunion_mapper.dart`
- Test : `test/data/ffss/mappers/reunion_mapper_test.dart`

**Interfaces :**
- Consumes : `readInt`, `readMap`, `parseFfssDay`, `atFfssTime` (tâche 5) ; `Meeting`, `MeetingItem`, `Heat`, `RunStatus`, `Gender` (tâche 4)
- Produces :
  - `ReunionDto.fromJson(Map<String, dynamic>)` et `CreneauDto`, `PartieRefDto`, `CourseDto`, `SerieDto`, `EpreuveRefDto`, `DisciplineRefDto` (freezed)
  - `extension ReunionMapper on ReunionDto { Meeting? toDomain(); }`
  - `Gender? parseGender(String? genre)`

Les clés JSON sont celles que la v1 a vérifiées sur de vraies réponses (`live_ffss/lib/app/data/dtos/meeting_dto.dart`, `slot_dto.dart`, `run_dto.dart`, `heat_dto.dart`, `race_dto.dart`). Attention à la casse : `Id`/`Nom`/`Jour`/`Debut`/`Fin` pour la réunion, `id` pour le créneau et la course, `debut`/`fin`/`statut`/`serie` en minuscules pour la course, `Id`/`Numero`/`epreuve` pour la série.

- [ ] **Étape 1 : écrire les tests**

`test/data/ffss/mappers/reunion_mapper_test.dart` :

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/data/ffss/dtos/reunion_dto.dart';
import 'package:live_ffss_v2/data/ffss/mappers/reunion_mapper.dart';
import 'package:live_ffss_v2/domain/gender.dart';
import 'package:live_ffss_v2/domain/run_status.dart';

Map<String, dynamic> course([Map<String, dynamic> overrides = const {}]) => {
      'id': 20,
      'Nom': 'Série 4',
      'statut': 2,
      'debut': '06:54',
      'fin': '06:58',
      'serie': {
        'Id': 300,
        'Nom': 'Série 4',
        'Numero': 4,
        'epreuve': {
          'Id': 7,
          'Genre': 'F',
          'discipline': {'Nom': '200 m Obstacles'},
        },
      },
      ...overrides,
    };

Map<String, dynamic> reunion({List<Map<String, dynamic>>? courses}) => {
      'Id': 1,
      'Nom': 'Eau Plate 1 – Séries',
      'Description': 'Piscine olympique',
      'Jour': '2026-03-27',
      'Debut': '06:45',
      'Fin': '11:30',
      'creneaus': [
        {
          'id': 10,
          'Nom': '200 m Obstacles D',
          'partie': {'id': 100},
          'courses': courses ?? [course()],
        },
      ],
    };

void main() {
  test('une réunion, son créneau et sa course', () {
    final meeting = ReunionDto.fromJson(reunion()).toDomain()!;

    expect(meeting.id, 1);
    expect(meeting.name, 'Eau Plate 1 – Séries');
    expect(meeting.day, DateTime(2026, 3, 27));
    expect(meeting.startTime, DateTime(2026, 3, 27, 6, 45));
    expect(meeting.endTime, DateTime(2026, 3, 27, 11, 30));

    final item = meeting.items.single;
    expect(item.id, 10);
    expect(item.roundId, 100);

    final heat = item.heats.single;
    expect(heat.id, 20);
    expect(heat.name, 'Série 4');
    expect(heat.number, 4);
    expect(heat.status, RunStatus.inProgress);
    expect(heat.plannedStart, DateTime(2026, 3, 27, 6, 54));
    expect(heat.plannedEnd, DateTime(2026, 3, 27, 6, 58));
    expect(heat.raceId, 7);
    expect(heat.raceName, '200 m Obstacles');
    expect(heat.gender, Gender.female);
  });

  test('statut et numéro servis en chaîne', () {
    final heat = ReunionDto.fromJson(reunion(courses: [
      course({
        'statut': '3',
        'serie': {'Id': 300, 'Numero': '4'},
      }),
    ])).toDomain()!.items.single.heats.single;

    expect(heat.status, RunStatus.finished);
    expect(heat.number, 4);
  });

  test('une heure de course mal formée garde la série, sans heure', () {
    final heat = ReunionDto.fromJson(reunion(courses: [
      course({'debut': '', 'fin': 'midi'}),
    ])).toDomain()!.items.single.heats.single;

    expect(heat.plannedStart, isNull);
    expect(heat.plannedEnd, isNull);
  });

  test('une course sans série : numéro 0, sans épreuve ni genre', () {
    final heat = ReunionDto.fromJson(reunion(courses: [
      course({'serie': null}),
    ])).toDomain()!.items.single.heats.single;

    expect(heat.number, 0);
    expect(heat.raceId, isNull);
    expect(heat.raceName, '');
    expect(heat.gender, isNull);
  });

  test('partie ou série servies en tableau vide (PHP)', () {
    final json = reunion(courses: [course({'serie': <Object>[]})]);
    (json['creneaus'] as List<Map<String, dynamic>>).single['partie'] = <Object>[];

    final item = ReunionDto.fromJson(json).toDomain()!.items.single;

    expect(item.roundId, isNull);
    expect(item.heats.single.raceId, isNull);
  });

  test('une course sans id est écartée, les autres restent', () {
    final item = ReunionDto.fromJson(reunion(courses: [
      course({'id': null}),
      course({'id': 21}),
    ])).toDomain()!.items.single;

    expect([for (final h in item.heats) h.id], [21]);
  });

  test('une réunion sans jour lisible est écartée', () {
    expect(ReunionDto.fromJson({...reunion(), 'Jour': null}).toDomain(), isNull);
  });

  test('parseGender : H, F, M et le reste', () {
    expect(parseGender('H'), Gender.male);
    expect(parseGender('F'), Gender.female);
    expect(parseGender('M'), Gender.mixed);
    expect(parseGender('X'), isNull);
    expect(parseGender(null), isNull);
  });
}
```

- [ ] **Étape 2 : lancer les tests pour les voir échouer**

Run : `flutter test test/data/ffss/mappers/reunion_mapper_test.dart`
Expected : FAIL — fichiers inexistants.

- [ ] **Étape 3 : écrire les DTO**

`lib/data/ffss/dtos/reunion_dto.dart` :

```dart
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/data/ffss/dtos/json_readers.dart';

part 'reunion_dto.freezed.dart';
part 'reunion_dto.g.dart';

// Clés vérifiées par la v1 sur de vraies réponses : la casse change d'un
// niveau à l'autre (`Id` pour la réunion, `id` pour le créneau et la course,
// `debut`/`fin`/`statut` en minuscules pour la course).

@freezed
abstract class ReunionDto with _$ReunionDto {
  const factory ReunionDto({
    @JsonKey(name: 'Id', readValue: readInt) int? id,
    @JsonKey(name: 'Nom') String? name,
    @JsonKey(name: 'Jour') String? day,
    @JsonKey(name: 'Debut') String? start,
    @JsonKey(name: 'Fin') String? end,
    @JsonKey(name: 'creneaus') @Default(<CreneauDto>[]) List<CreneauDto> creneaus,
  }) = _ReunionDto;

  factory ReunionDto.fromJson(Map<String, dynamic> json) =>
      _$ReunionDtoFromJson(json);
}

@freezed
abstract class CreneauDto with _$CreneauDto {
  const factory CreneauDto({
    @JsonKey(name: 'id', readValue: readInt) int? id,
    @JsonKey(name: 'Nom') String? name,
    @JsonKey(name: 'partie', readValue: readMap) PartieRefDto? partie,
    @JsonKey(name: 'courses') @Default(<CourseDto>[]) List<CourseDto> courses,
  }) = _CreneauDto;

  factory CreneauDto.fromJson(Map<String, dynamic> json) =>
      _$CreneauDtoFromJson(json);
}

@freezed
abstract class PartieRefDto with _$PartieRefDto {
  const factory PartieRefDto({
    @JsonKey(name: 'id', readValue: readInt) int? id,
  }) = _PartieRefDto;

  factory PartieRefDto.fromJson(Map<String, dynamic> json) =>
      _$PartieRefDtoFromJson(json);
}

@freezed
abstract class CourseDto with _$CourseDto {
  const factory CourseDto({
    @JsonKey(name: 'id', readValue: readInt) int? id,
    @JsonKey(name: 'Nom') String? name,
    @JsonKey(name: 'statut', readValue: readInt) int? status,
    @JsonKey(name: 'debut') String? start,
    @JsonKey(name: 'fin') String? end,
    @JsonKey(name: 'serie', readValue: readMap) SerieDto? serie,
  }) = _CourseDto;

  factory CourseDto.fromJson(Map<String, dynamic> json) =>
      _$CourseDtoFromJson(json);
}

@freezed
abstract class SerieDto with _$SerieDto {
  const factory SerieDto({
    @JsonKey(name: 'Id', readValue: readInt) int? id,
    @JsonKey(name: 'Nom') String? name,
    @JsonKey(name: 'Numero', readValue: readInt) int? number,
    @JsonKey(name: 'epreuve', readValue: readMap) EpreuveRefDto? epreuve,
  }) = _SerieDto;

  factory SerieDto.fromJson(Map<String, dynamic> json) =>
      _$SerieDtoFromJson(json);
}

@freezed
abstract class EpreuveRefDto with _$EpreuveRefDto {
  const factory EpreuveRefDto({
    @JsonKey(name: 'Id', readValue: readInt) int? id,
    @JsonKey(name: 'Genre') String? gender,
    @JsonKey(name: 'discipline', readValue: readMap) DisciplineRefDto? discipline,
  }) = _EpreuveRefDto;

  factory EpreuveRefDto.fromJson(Map<String, dynamic> json) =>
      _$EpreuveRefDtoFromJson(json);
}

@freezed
abstract class DisciplineRefDto with _$DisciplineRefDto {
  const factory DisciplineRefDto({
    @JsonKey(name: 'Nom') String? name,
  }) = _DisciplineRefDto;

  factory DisciplineRefDto.fromJson(Map<String, dynamic> json) =>
      _$DisciplineRefDtoFromJson(json);
}
```

- [ ] **Étape 4 : écrire le mapper**

`lib/data/ffss/mappers/reunion_mapper.dart` :

```dart
import 'package:live_ffss_v2/data/ffss/dtos/reunion_dto.dart';
import 'package:live_ffss_v2/data/ffss/mappers/ffss_dates.dart';
import 'package:live_ffss_v2/domain/gender.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/run_status.dart';

/// `Genre` FFSS : H (homme), F (femme), M (mixte).
Gender? parseGender(String? genre) => switch (genre?.trim().toUpperCase()) {
      'H' => Gender.male,
      'F' => Gender.female,
      'M' => Gender.mixed,
      _ => null,
    };

extension ReunionMapper on ReunionDto {
  /// Nulle sans id ni jour lisible : les heures des séries se posent sur ce
  /// jour.
  Meeting? toDomain() {
    final id = this.id;
    final day = parseFfssDay(this.day);
    if (id == null || day == null) return null;
    return Meeting(
      id: id,
      name: name?.trim() ?? '',
      day: day,
      startTime: atFfssTime(day, start),
      endTime: atFfssTime(day, end),
      items: [
        for (final creneau in creneaus)
          if (creneau.toDomain(day) case final item?) item,
      ],
    );
  }
}

extension CreneauMapper on CreneauDto {
  MeetingItem? toDomain(DateTime day) {
    final id = this.id;
    if (id == null) return null;
    return MeetingItem(
      id: id,
      name: name?.trim() ?? '',
      roundId: partie?.id,
      heats: [
        for (final course in courses)
          if (course.toDomain(day) case final heat?) heat,
      ],
    );
  }
}

extension CourseMapper on CourseDto {
  Heat? toDomain(DateTime day) {
    final id = this.id;
    if (id == null) return null;
    final epreuve = serie?.epreuve;
    return Heat(
      id: id,
      name: name?.trim() ?? '',
      number: serie?.number ?? 0,
      status: RunStatus.fromCode(status),
      plannedStart: atFfssTime(day, start),
      plannedEnd: atFfssTime(day, end),
      raceId: epreuve?.id,
      raceName: epreuve?.discipline?.name?.trim() ?? '',
      gender: parseGender(epreuve?.gender),
    );
  }
}
```

- [ ] **Étape 5 : générer et lancer les tests**

Run : `dart run build_runner build --delete-conflicting-outputs && flutter test test/data`
Expected : PASS.

- [ ] **Étape 6 : commiter**

```bash
dart format lib test && flutter analyze
git add -A . && git commit -m "feat(v2): données — arbre des réunions vers Meeting, MeetingItem, Heat"
```

---

### Tâche 7 : `CompetitionRepository`

**Files :**
- Create : `lib/data/repositories/competition_repository.dart`
- Test : `test/data/repositories/competition_repository_test.dart`

**Interfaces :**
- Consumes : `HttpClient`, `ApiEndpoints.competitionList`, `httpClientProvider` (tâche 2) ; `EvenementDto`, `EvenementMapper` (tâche 5)
- Produces :
  - `abstract class CompetitionRepository { Future<List<CompetitionSummary>> getCompetitionsFrom(DateTime from); Future<List<CompetitionSummary>> search(String query); }`
  - `class CompetitionRepositoryImpl implements CompetitionRepository { CompetitionRepositoryImpl(HttpClient); static const int pageSize = 100; static const int searchLimit = 50; }`
  - `final competitionRepositoryProvider = Provider<CompetitionRepository>`

- [ ] **Étape 1 : écrire les tests**

`test/data/repositories/competition_repository_test.dart` :

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/network/http_client.dart';
import 'package:live_ffss_v2/data/repositories/competition_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockHttpClient extends Mock implements HttpClient {}

Map<String, dynamic> row(int id, {String start = '2026-10-20'}) =>
    {'Id': id, 'Nom': 'Compétition $id', 'Debut': start, 'Specialite': 2};

void main() {
  late _MockHttpClient http;
  late CompetitionRepositoryImpl repository;

  setUp(() {
    http = _MockHttpClient();
    repository = CompetitionRepositoryImpl(http);
  });

  void answerPages(List<List<Map<String, dynamic>>> pages) {
    var call = 0;
    when(() => http.get(any(), query: any(named: 'query'))).thenAnswer(
      (_) async => {'data': pages[call++]},
    );
  }

  group('getCompetitionsFrom', () {
    test('envoie debut, le type 3 (toutes spécialités) et la fenêtre', () async {
      answerPages([[row(1)]]);

      await repository.getCompetitionsFrom(DateTime(2026, 10, 3));

      final query = verify(() => http.get('competition/evenement',
              query: captureAny(named: 'query')))
          .captured
          .single as Map<String, dynamic>;
      expect(query, {
        'debut': '2026-10-03',
        'type': 3,
        'start': 0,
        'length': CompetitionRepositoryImpl.pageSize,
      });
    });

    test('lit la page suivante tant qu\'une page est pleine', () async {
      final full = [for (var i = 0; i < CompetitionRepositoryImpl.pageSize; i++) row(i)];
      answerPages([full, [row(1000)]]);

      final result = await repository.getCompetitionsFrom(DateTime(2026, 10, 3));

      expect(result.length, CompetitionRepositoryImpl.pageSize + 1);
      final starts = verify(() => http.get(any(), query: captureAny(named: 'query')))
          .captured
          .map((q) => (q as Map<String, dynamic>)['start'])
          .toList();
      expect(starts, [0, CompetitionRepositoryImpl.pageSize]);
    });

    test('compte les lignes brutes, pas les lignes retenues, pour paginer', () async {
      // Une page pleine dont une ligne est écartée par le mapper reste pleine :
      // s'arrêter là perdrait la page suivante.
      final full = [
        {'Id': null},
        for (var i = 1; i < CompetitionRepositoryImpl.pageSize; i++) row(i),
      ];
      answerPages([full, <Map<String, dynamic>>[]]);

      final result = await repository.getCompetitionsFrom(DateTime(2026, 10, 3));

      expect(result.length, CompetitionRepositoryImpl.pageSize - 1);
      verify(() => http.get(any(), query: any(named: 'query'))).called(2);
    });

    test('data absent : liste vide', () async {
      when(() => http.get(any(), query: any(named: 'query')))
          .thenAnswer((_) async => <String, dynamic>{});

      expect(await repository.getCompetitionsFrom(DateTime(2026, 10, 3)), isEmpty);
    });

    test('une erreur réseau remonte telle quelle', () async {
      when(() => http.get(any(), query: any(named: 'query')))
          .thenThrow(const NetworkException('offline'));

      expect(
        () => repository.getCompetitionsFrom(DateTime(2026, 10, 3)),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('search', () {
    test('envoie la recherche nettoyée, sans date, une seule page', () async {
      answerPages([[row(1)]]);

      await repository.search('  girard ');

      final query = verify(() => http.get('competition/evenement',
              query: captureAny(named: 'query')))
          .captured
          .single as Map<String, dynamic>;
      expect(query, {
        'search': 'girard',
        'type': 3,
        'start': 0,
        'length': CompetitionRepositoryImpl.searchLimit,
      });
    });

    test('trie de la plus récente à la plus ancienne', () async {
      answerPages([[row(1, start: '2025-05-01'), row(2, start: '2026-03-27')]]);

      final result = await repository.search('france');

      expect([for (final c in result) c.id], [2, 1]);
    });

    test('une recherche vide n\'appelle pas l\'API', () async {
      expect(await repository.search('   '), isEmpty);
      verifyNever(() => http.get(any(), query: any(named: 'query')));
    });
  });
}
```

- [ ] **Étape 2 : lancer les tests pour les voir échouer**

Run : `flutter test test/data/repositories/competition_repository_test.dart`
Expected : FAIL — fichier inexistant.

- [ ] **Étape 3 : écrire le repository**

`lib/data/repositories/competition_repository.dart` :

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:live_ffss_v2/core/config/app_config.dart';
import 'package:live_ffss_v2/core/network/http_client.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/ffss/dtos/evenement_dto.dart';
import 'package:live_ffss_v2/data/ffss/mappers/evenement_mapper.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';

abstract class CompetitionRepository {
  /// Toutes les compétitions qui commencent à partir du jour [from], toutes
  /// pages lues.
  Future<List<CompetitionSummary>> getCompetitionsFrom(DateTime from);

  /// La recherche de l'API : une page, sans filtre de date, de la plus récente
  /// à la plus ancienne.
  Future<List<CompetitionSummary>> search(String query);
}

class CompetitionRepositoryImpl implements CompetitionRepository {
  CompetitionRepositoryImpl(this._http);

  final HttpClient _http;

  /// FFSS retombe à 30 lignes quand on ne demande rien.
  static const int pageSize = 100;

  static const int searchLimit = 50;

  /// `type` 3 (« mixte ») est la valeur qui rend les trois spécialités : c'est
  /// celle que la v1 envoyait pour « toutes ».
  static const int _allSpecialities = 3;

  static final DateFormat _day = DateFormat('yyyy-MM-dd');

  @override
  Future<List<CompetitionSummary>> getCompetitionsFrom(DateTime from) async {
    final all = <CompetitionSummary>[];
    for (var start = 0;; start += pageSize) {
      final rows = await _rows({
        'debut': _day.format(from),
        'type': _allSpecialities,
        'start': start,
        'length': pageSize,
      });
      all.addAll(_summaries(rows));
      // Compté sur les lignes brutes : une ligne écartée par le mapper ne
      // doit pas faire passer une page pleine pour la dernière.
      if (rows.length < pageSize) return all;
    }
  }

  @override
  Future<List<CompetitionSummary>> search(String query) async {
    final text = query.trim();
    if (text.isEmpty) return const [];
    final rows = await _rows({
      'search': text,
      'type': _allSpecialities,
      'start': 0,
      'length': searchLimit,
    });
    return _summaries(rows)
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  Future<List<Map<String, dynamic>>> _rows(Map<String, dynamic> query) async {
    final body = await _http.get(ApiEndpoints.competitionList, query: query);
    final data = body['data'];
    return data is List ? data.whereType<Map<String, dynamic>>().toList() : [];
  }

  List<CompetitionSummary> _summaries(List<Map<String, dynamic>> rows) => [
        for (final row in rows)
          if (EvenementDto.fromJson(row).toDomain() case final summary?) summary,
      ];
}

final competitionRepositoryProvider = Provider<CompetitionRepository>(
  (ref) => CompetitionRepositoryImpl(ref.watch(httpClientProvider)),
);
```

- [ ] **Étape 4 : lancer les tests**

Run : `flutter test test/data/repositories`
Expected : PASS.

- [ ] **Étape 5 : commiter**

```bash
dart format lib test && flutter analyze
git add -A . && git commit -m "feat(v2): CompetitionRepository — liste paginée et recherche"
```

---

### Tâche 8 : `MeetingRepository`

**Files :**
- Create : `lib/data/repositories/meeting_repository.dart`
- Test : `test/data/repositories/meeting_repository_test.dart`

**Interfaces :**
- Consumes : `HttpClient`, `ApiEndpoints.meetingList`, `httpClientProvider` (tâche 2) ; `ReunionDto`, `ReunionMapper` (tâche 6)
- Produces :
  - `abstract class MeetingRepository { Future<List<Meeting>> getMeetings(int competitionId); }`
  - `class MeetingRepositoryImpl implements MeetingRepository { MeetingRepositoryImpl(HttpClient); static const int pageSize = 100; }`
  - `final meetingRepositoryProvider = Provider<MeetingRepository>`

**Écart assumé avec la v1 :** la v1 demandait, pour chaque créneau, `GET competition/reunion/creneau/:id/course`, puis retombait sur les courses portées par la réponse `reunion` quand cette route refusait. Elle refuse **pour tous les créneaux depuis le 2026-08-31** (voir `docs/FFSS_API_CONTRACT.md`, Known gaps de la v1). La v2 lit donc **directement** les courses portées par la réponse `reunion` : avec un rafraîchissement toutes les 30 s, l'appel par créneau ne ferait qu'ajouter, à chaque passage, une requête vouée à l'échec par créneau. À reconsidérer si la route est réparée et que les courses portées par `reunion` s'avèrent tronquées.

- [ ] **Étape 1 : écrire les tests**

`test/data/repositories/meeting_repository_test.dart` :

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/network/http_client.dart';
import 'package:live_ffss_v2/data/repositories/meeting_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockHttpClient extends Mock implements HttpClient {}

Map<String, dynamic> reunion(int id, {String day = '2026-03-27', String start = '06:45'}) => {
      'Id': id,
      'Nom': 'Réunion $id',
      'Jour': day,
      'Debut': start,
      'Fin': '11:30',
      'creneaus': [
        {
          'id': id * 10,
          'Nom': 'Créneau',
          'courses': [
            {'id': id * 100, 'Nom': 'Série 1', 'statut': 2, 'debut': '06:54', 'fin': '06:58'},
          ],
        },
      ],
    };

void main() {
  late _MockHttpClient http;
  late MeetingRepositoryImpl repository;

  setUp(() {
    http = _MockHttpClient();
    repository = MeetingRepositoryImpl(http);
  });

  test('appelle la route des réunions de la compétition, avec une fenêtre', () async {
    when(() => http.get(any(), query: any(named: 'query')))
        .thenAnswer((_) async => {'data': [reunion(1)]});

    await repository.getMeetings(1453);

    final query = verify(() => http.get('competition/1453/reunion',
            query: captureAny(named: 'query')))
        .captured
        .single as Map<String, dynamic>;
    expect(query, {'start': 0, 'length': MeetingRepositoryImpl.pageSize});
  });

  test('lit les courses portées par la réponse, sans appel par créneau', () async {
    when(() => http.get(any(), query: any(named: 'query')))
        .thenAnswer((_) async => {'data': [reunion(1)]});

    final meetings = await repository.getMeetings(1453);

    expect(meetings.single.items.single.heats.single.id, 100);
    verify(() => http.get(any(), query: any(named: 'query'))).called(1);
  });

  test('pagine les réunions et les trie par jour puis par heure', () async {
    final full = [
      for (var i = 1; i <= MeetingRepositoryImpl.pageSize; i++)
        reunion(i, day: '2026-03-28'),
    ];
    var call = 0;
    when(() => http.get(any(), query: any(named: 'query'))).thenAnswer((_) async {
      call++;
      return {
        'data': call == 1
            ? full
            : [reunion(999, day: '2026-03-27', start: '13:55'), reunion(998, day: '2026-03-27')],
      };
    });

    final meetings = await repository.getMeetings(1453);

    expect(meetings.length, MeetingRepositoryImpl.pageSize + 2);
    expect(meetings.first.id, 998);
    expect(meetings[1].id, 999);
  });

  test('une réunion illisible est écartée, les autres restent', () async {
    when(() => http.get(any(), query: any(named: 'query'))).thenAnswer(
      (_) async => {
        'data': [
          {...reunion(1), 'Jour': null},
          reunion(2),
        ],
      },
    );

    final meetings = await repository.getMeetings(1453);

    expect([for (final m in meetings) m.id], [2]);
  });
}
```

- [ ] **Étape 2 : lancer les tests pour les voir échouer**

Run : `flutter test test/data/repositories/meeting_repository_test.dart`
Expected : FAIL — fichier inexistant.

- [ ] **Étape 3 : écrire le repository**

`lib/data/repositories/meeting_repository.dart` :

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/config/app_config.dart';
import 'package:live_ffss_v2/core/network/http_client.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/ffss/dtos/reunion_dto.dart';
import 'package:live_ffss_v2/data/ffss/mappers/reunion_mapper.dart';
import 'package:live_ffss_v2/domain/meeting.dart';

abstract class MeetingRepository {
  /// Les réunions d'une compétition, avec leurs créneaux et leurs séries,
  /// triées par jour puis par heure de début.
  Future<List<Meeting>> getMeetings(int competitionId);
}

class MeetingRepositoryImpl implements MeetingRepository {
  MeetingRepositoryImpl(this._http);

  final HttpClient _http;

  /// FFSS retombe à 30 lignes quand on ne demande rien, bien en dessous d'un
  /// vrai programme.
  static const int pageSize = 100;

  /// Les courses viennent de la réponse `reunion` elle-même, et non de
  /// `creneau/:id/course` : cette route refuse tous les créneaux depuis le
  /// 2026-08-31, et la v1 retombait de toute façon sur ces mêmes courses.
  /// Avec un rafraîchissement toutes les 30 s, l'appeler quand même ajouterait
  /// une requête vouée à l'échec par créneau et par passage.
  @override
  Future<List<Meeting>> getMeetings(int competitionId) async {
    final path = ApiEndpoints.replacePath(
      ApiEndpoints.meetingList,
      {'id': competitionId.toString()},
    );
    final meetings = <Meeting>[];
    for (var start = 0;; start += pageSize) {
      final body = await _http.get(path, query: {'start': start, 'length': pageSize});
      final data = body['data'];
      final rows =
          data is List ? data.whereType<Map<String, dynamic>>().toList() : <Map<String, dynamic>>[];
      for (final row in rows) {
        if (ReunionDto.fromJson(row).toDomain() case final meeting?) {
          meetings.add(meeting);
        }
      }
      if (rows.length < pageSize) break;
    }
    return meetings
      ..sort((a, b) {
        final byDay = a.day.compareTo(b.day);
        if (byDay != 0) return byDay;
        return (a.startTime ?? a.day).compareTo(b.startTime ?? b.day);
      });
  }
}

final meetingRepositoryProvider = Provider<MeetingRepository>(
  (ref) => MeetingRepositoryImpl(ref.watch(httpClientProvider)),
);
```

- [ ] **Étape 4 : lancer les tests**

Run : `flutter test test/data/repositories`
Expected : PASS.

- [ ] **Étape 5 : commiter**

```bash
dart format lib test && flutter analyze
git add -A . && git commit -m "feat(v2): MeetingRepository — réunions paginées, courses lues dans la réponse"
```

---

### Tâche 9 : favoris et compétition active (persistés)

**Files :**
- Create : `lib/features/home/favorites.dart`, `lib/features/shell/active_competition.dart`
- Test : `test/features/home/favorites_test.dart`, `test/features/shell/active_competition_test.dart`

**Interfaces :**
- Consumes : `LocalStore`, `localStoreProvider` (tâche 2) ; `CompetitionSummary` (tâche 3) ; `InMemoryLocalStore` (tests, tâche 2)
- Produces :
  - `class FavoritesNotifier extends AsyncNotifier<Set<int>> { static const storageKey = 'favorite_competitions'; Future<void> toggle(int id); }`
  - `final favoritesProvider = AsyncNotifierProvider<FavoritesNotifier, Set<int>>`
  - `typedef ActiveSelection = ({int id, CompetitionSummary? summary});`
  - `class ActiveCompetitionNotifier extends AsyncNotifier<ActiveSelection?> { static const storageKey = 'active_competition'; Future<void> select(CompetitionSummary competition); }`
  - `final activeCompetitionProvider = AsyncNotifierProvider<ActiveCompetitionNotifier, ActiveSelection?>`

- [ ] **Étape 1 : écrire les tests**

`test/features/home/favorites_test.dart` :

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/features/home/favorites.dart';

import '../../support/in_memory_local_store.dart';

void main() {
  late InMemoryLocalStore store;
  late ProviderContainer container;

  setUp(() {
    store = InMemoryLocalStore();
    container = ProviderContainer(
      overrides: [localStoreProvider.overrideWithValue(store)],
      retry: (_, __) => null,
    );
    addTearDown(container.dispose);
  });

  test('rien d\'enregistré : aucun favori', () async {
    expect(await container.read(favoritesProvider.future), isEmpty);
  });

  test('relit les favoris enregistrés', () async {
    store.values[FavoritesNotifier.storageKey] = '[3,1]';

    expect(await container.read(favoritesProvider.future), {1, 3});
  });

  test('une valeur illisible vaut aucun favori, sans erreur', () async {
    store.values[FavoritesNotifier.storageKey] = 'pas du json';

    expect(await container.read(favoritesProvider.future), isEmpty);
  });

  test('toggle ajoute puis retire, et enregistre à chaque fois', () async {
    await container.read(favoritesProvider.future);
    final notifier = container.read(favoritesProvider.notifier);

    await notifier.toggle(5);
    expect(container.read(favoritesProvider).value, {5});
    expect(store.values[FavoritesNotifier.storageKey], '[5]');

    await notifier.toggle(5);
    expect(container.read(favoritesProvider).value, isEmpty);
    expect(store.values[FavoritesNotifier.storageKey], '[]');
  });
}
```

`test/features/shell/active_competition_test.dart` :

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/features/shell/active_competition.dart';

import '../../support/competitions.dart';
import '../../support/in_memory_local_store.dart';

void main() {
  late InMemoryLocalStore store;
  late ProviderContainer container;

  setUp(() {
    store = InMemoryLocalStore();
    container = ProviderContainer(
      overrides: [localStoreProvider.overrideWithValue(store)],
      retry: (_, __) => null,
    );
    addTearDown(container.dispose);
  });

  test('rien d\'enregistré : aucune sélection', () async {
    expect(await container.read(activeCompetitionProvider.future), isNull);
  });

  test('relit l\'id enregistré, sans résumé', () async {
    store.values[ActiveCompetitionNotifier.storageKey] = '1453';

    final selection = await container.read(activeCompetitionProvider.future);

    expect(selection?.id, 1453);
    expect(selection?.summary, isNull);
  });

  test('un id illisible vaut aucune sélection', () async {
    store.values[ActiveCompetitionNotifier.storageKey] = 'abc';

    expect(await container.read(activeCompetitionProvider.future), isNull);
  });

  test('select garde le résumé en mémoire et enregistre l\'id', () async {
    await container.read(activeCompetitionProvider.future);
    final c = competition(42, start: DateTime(2025, 5, 1));

    await container.read(activeCompetitionProvider.notifier).select(c);

    expect(container.read(activeCompetitionProvider).value, (id: 42, summary: c));
    expect(store.values[ActiveCompetitionNotifier.storageKey], '42');
  });
}
```

- [ ] **Étape 2 : lancer les tests pour les voir échouer**

Run : `flutter test test/features`
Expected : FAIL — fichiers inexistants.

- [ ] **Étape 3 : écrire les deux notifiers**

`lib/features/home/favorites.dart` :

```dart
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/providers.dart';

/// Les compétitions favorites, gardées sur l'appareil.
class FavoritesNotifier extends AsyncNotifier<Set<int>> {
  static const storageKey = 'favorite_competitions';

  @override
  Future<Set<int>> build() async =>
      _decode(await ref.watch(localStoreProvider).read(storageKey));

  Future<void> toggle(int id) async {
    final next = {...(state.value ?? await future)};
    if (!next.remove(id)) next.add(id);
    state = AsyncData(next);
    await ref
        .read(localStoreProvider)
        .write(storageKey, jsonEncode(next.toList()..sort()));
  }

  /// Une valeur illisible vaut « aucun favori » : perdre des favoris est
  /// moins grave qu'un accueil qui ne s'ouvre plus.
  static Set<int> _decode(String? raw) {
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw);
      return decoded is List ? decoded.whereType<int>().toSet() : {};
    } on FormatException {
      return {};
    }
  }
}

final favoritesProvider =
    AsyncNotifierProvider<FavoritesNotifier, Set<int>>(FavoritesNotifier.new);
```

`lib/features/shell/active_competition.dart` :

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';

/// La compétition que suivent les onglets Programme, Live et Résultats.
///
/// Seul l'id est enregistré. Le résumé n'est gardé qu'en mémoire, pour une
/// compétition ouverte depuis la recherche et absente de la liste de
/// l'accueil. Après un redémarrage, une telle compétition retombe sur le choix
/// par défaut : le lot 2 la relira par son id.
typedef ActiveSelection = ({int id, CompetitionSummary? summary});

class ActiveCompetitionNotifier extends AsyncNotifier<ActiveSelection?> {
  static const storageKey = 'active_competition';

  @override
  Future<ActiveSelection?> build() async {
    final id = int.tryParse(
      await ref.watch(localStoreProvider).read(storageKey) ?? '',
    );
    return id == null ? null : (id: id, summary: null);
  }

  Future<void> select(CompetitionSummary competition) async {
    state = AsyncData((id: competition.id, summary: competition));
    await ref
        .read(localStoreProvider)
        .write(storageKey, competition.id.toString());
  }
}

final activeCompetitionProvider =
    AsyncNotifierProvider<ActiveCompetitionNotifier, ActiveSelection?>(
  ActiveCompetitionNotifier.new,
);
```

- [ ] **Étape 4 : lancer les tests**

Run : `flutter test test/features`
Expected : PASS.

- [ ] **Étape 5 : commiter**

```bash
dart format lib test && flutter analyze
git add -A . && git commit -m "feat(v2): favoris et compétition active, persistés sur l'appareil"
```

---

### Tâche 10 : l'état de l'accueil (filtre, carrousel, compétition courante, « maintenant », recherche)

**Files :**
- Create : `lib/features/home/home_view.dart`, `lib/features/home/home_providers.dart`, `lib/features/home/now_running_provider.dart`, `lib/features/home/search_provider.dart`, `lib/features/shell/current_competition.dart`
- Test : `test/features/home/home_view_test.dart`, `test/features/home/home_providers_test.dart`, `test/features/home/now_running_provider_test.dart`, `test/features/home/search_provider_test.dart`, `test/features/shell/current_competition_test.dart`

**Interfaces :**
- Consumes : `partitionHome`, `dayOf`, `recentWindowDays` (tâche 3) ; `nowRunning`, `NowRunning` (tâche 4) ; `competitionRepositoryProvider` (tâche 7) ; `meetingRepositoryProvider` (tâche 8) ; `favoritesProvider`, `activeCompetitionProvider`, `ActiveSelection` (tâche 9) ; `clockProvider` (tâche 2)
- Produces :
  - `enum HomeFilter { all, flatWater, coastal, favorites }`
  - `bool matchesFilter(CompetitionSummary c, HomeFilter filter, Set<int> favorites)`
  - `List<CompetitionSummary> orderLive(List<CompetitionSummary> live, {required Set<int> favorites, int? activeId})`
  - `const int upcomingPreviewCount = 5;`
  - `class HomeView { live, upcoming, upcomingCount, recent }`
  - `HomeView buildHomeView({required List<CompetitionSummary> competitions, required DateTime today, required HomeFilter filter, required Set<int> favorites, int? activeId})`
  - `homeCompetitionsProvider` (`FutureProvider<List<CompetitionSummary>>`), `homeFilterProvider` (`NotifierProvider<HomeFilterNotifier, HomeFilter>`, méthode `select(HomeFilter)`), `homeViewProvider` (`Provider<HomeView?>`)
  - `CompetitionSummary? currentCompetition({required List<CompetitionSummary> competitions, required ActiveSelection? selection, required Set<int> favorites, required DateTime today})`, `currentCompetitionProvider` (`Provider<CompetitionSummary?>`)
  - `const Duration nowRunningRefresh = Duration(seconds: 30);`, `nowRunningProvider` (`FutureProvider.autoDispose.family<NowRunning?, int>`)
  - `const Duration searchDebounce = Duration(milliseconds: 300);`, `const int searchMinLength = 2;`, `searchResultsProvider` (`FutureProvider.autoDispose.family<List<CompetitionSummary>, String>`)

- [ ] **Étape 1 : écrire les tests des fonctions pures**

`test/features/home/home_view_test.dart` :

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/domain/discipline.dart';
import 'package:live_ffss_v2/features/home/home_view.dart';

import '../../support/competitions.dart';

void main() {
  final today = DateTime(2026, 10, 17);
  final flat = competition(1, start: DateTime(2026, 10, 20));
  final coastal = competition(2,
      start: DateTime(2026, 10, 21), disciplines: {Discipline.coastal});
  final mixed = competition(3,
      start: DateTime(2026, 10, 22),
      disciplines: {Discipline.flatWater, Discipline.coastal});

  group('matchesFilter', () {
    test('une compétition mixte apparaît sous les deux filtres', () {
      expect(matchesFilter(mixed, HomeFilter.flatWater, {}), isTrue);
      expect(matchesFilter(mixed, HomeFilter.coastal, {}), isTrue);
    });

    test('eau plate et côtier se séparent', () {
      expect(matchesFilter(flat, HomeFilter.coastal, {}), isFalse);
      expect(matchesFilter(coastal, HomeFilter.flatWater, {}), isFalse);
    });

    test('favoris : seulement les favorites', () {
      expect(matchesFilter(flat, HomeFilter.favorites, {1}), isTrue);
      expect(matchesFilter(coastal, HomeFilter.favorites, {1}), isFalse);
    });
  });

  group('orderLive', () {
    final a = competition(10, name: 'A', start: DateTime(2026, 10, 16));
    final b = competition(11, name: 'B', start: DateTime(2026, 10, 15));
    final c = competition(12, name: 'C', start: DateTime(2026, 10, 17));

    test('favoris, puis compétition active, puis date de début', () {
      final ordered = orderLive([a, b, c], favorites: {12}, activeId: 10);

      expect([for (final x in ordered) x.id], [12, 10, 11]);
    });

    test('sans favori ni active : par date de début', () {
      final ordered = orderLive([a, b, c], favorites: {});

      expect([for (final x in ordered) x.id], [11, 10, 12]);
    });
  });

  group('buildHomeView', () {
    test('à venir limité à 5, avec le compte total', () {
      final list = [
        for (var i = 1; i <= 7; i++) competition(i, start: DateTime(2026, 10, 17 + i)),
      ];

      final view = buildHomeView(
        competitions: list,
        today: today,
        filter: HomeFilter.all,
        favorites: {},
      );

      expect(view.upcoming.length, upcomingPreviewCount);
      expect(view.upcomingCount, 7);
    });

    test('le filtre s\'applique aux trois groupes', () {
      final live = competition(20, start: DateTime(2026, 10, 17), disciplines: {Discipline.coastal});
      final recent = competition(21, start: DateTime(2026, 10, 10), disciplines: {Discipline.coastal});

      final view = buildHomeView(
        competitions: [flat, live, recent],
        today: today,
        filter: HomeFilter.flatWater,
        favorites: {},
      );

      expect(view.live, isEmpty);
      expect(view.recent, isEmpty);
      expect([for (final x in view.upcoming) x.id], [1]);
    });
  });
}
```

`test/features/shell/current_competition_test.dart` :

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/features/shell/current_competition.dart';

import '../../support/competitions.dart';

void main() {
  final today = DateTime(2026, 10, 17);
  final liveA = competition(1, name: 'A', start: DateTime(2026, 10, 16), end: DateTime(2026, 10, 18));
  final liveB = competition(2, name: 'B', start: DateTime(2026, 10, 15), end: DateTime(2026, 10, 18));
  final upcoming = competition(3, start: DateTime(2026, 11, 1));

  test('la compétition choisie, si elle est dans la liste', () {
    expect(
      currentCompetition(
        competitions: [liveA, liveB, upcoming],
        selection: (id: 3, summary: null),
        favorites: {},
        today: today,
      ),
      upcoming,
    );
  });

  test('choisie hors de la liste : le résumé gardé en mémoire', () {
    final old = competition(99, start: DateTime(2025, 5, 1));

    expect(
      currentCompetition(
        competitions: [liveA],
        selection: (id: 99, summary: old),
        favorites: {},
        today: today,
      ),
      old,
    );
  });

  test('rien de choisi : la première du carrousel, favoris d\'abord', () {
    expect(
      currentCompetition(
        competitions: [liveA, liveB],
        selection: null,
        favorites: {1},
        today: today,
      ),
      liveA,
    );
    expect(
      currentCompetition(
        competitions: [liveA, liveB],
        selection: null,
        favorites: {},
        today: today,
      ),
      liveB,
    );
  });

  test('choisie mais introuvable, sans résumé : le défaut', () {
    expect(
      currentCompetition(
        competitions: [liveA],
        selection: (id: 99, summary: null),
        favorites: {},
        today: today,
      ),
      liveA,
    );
  });

  test('rien en direct et rien de choisi : aucune', () {
    expect(
      currentCompetition(
        competitions: [upcoming],
        selection: null,
        favorites: {},
        today: today,
      ),
      isNull,
    );
  });
}
```

- [ ] **Étape 2 : lancer les tests pour les voir échouer**

Run : `flutter test test/features`
Expected : FAIL — `home_view.dart` et `current_competition.dart` n'existent pas.

- [ ] **Étape 3 : écrire les fonctions pures**

`lib/features/home/home_view.dart` :

```dart
import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/domain/discipline.dart';
import 'package:live_ffss_v2/domain/home_partition.dart';

enum HomeFilter { all, flatWater, coastal, favorites }

/// Une compétition mixte contient les deux disciplines : elle passe donc les
/// filtres Eau plate et Côtier.
bool matchesFilter(
  CompetitionSummary competition,
  HomeFilter filter,
  Set<int> favorites,
) =>
    switch (filter) {
      HomeFilter.all => true,
      HomeFilter.flatWater =>
        competition.disciplines.contains(Discipline.flatWater),
      HomeFilter.coastal => competition.disciplines.contains(Discipline.coastal),
      HomeFilter.favorites => favorites.contains(competition.id),
    };

/// L'ordre du carrousel « EN DIRECT » : les favoris, puis la compétition
/// active, puis les autres par date de début et par nom.
List<CompetitionSummary> orderLive(
  List<CompetitionSummary> live, {
  required Set<int> favorites,
  int? activeId,
}) {
  int rank(CompetitionSummary c) =>
      favorites.contains(c.id) ? 0 : (c.id == activeId ? 1 : 2);
  return [...live]..sort((a, b) {
      final byRank = rank(a).compareTo(rank(b));
      if (byRank != 0) return byRank;
      final byStart = a.startDate.compareTo(b.startDate);
      return byStart != 0 ? byStart : a.name.compareTo(b.name);
    });
}

const int upcomingPreviewCount = 5;

/// Ce que l'accueil affiche.
class HomeView {
  const HomeView({
    required this.live,
    required this.upcoming,
    required this.upcomingCount,
    required this.recent,
  });

  final List<CompetitionSummary> live;

  /// Les [upcomingPreviewCount] premières ; « Tout voir » montre le reste.
  final List<CompetitionSummary> upcoming;
  final int upcomingCount;
  final List<CompetitionSummary> recent;

  bool get isEmpty => live.isEmpty && upcomingCount == 0 && recent.isEmpty;
}

HomeView buildHomeView({
  required List<CompetitionSummary> competitions,
  required DateTime today,
  required HomeFilter filter,
  required Set<int> favorites,
  int? activeId,
}) {
  final partition = partitionHome(
    [
      for (final c in competitions)
        if (matchesFilter(c, filter, favorites)) c,
    ],
    today,
  );
  return HomeView(
    live: orderLive(partition.live, favorites: favorites, activeId: activeId),
    upcoming: partition.upcoming.take(upcomingPreviewCount).toList(),
    upcomingCount: partition.upcoming.length,
    recent: partition.recent,
  );
}
```

`lib/features/shell/current_competition.dart` (la fonction pure seulement ; le fournisseur arrive à l'étape 7) :

```dart
import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/domain/home_partition.dart';
import 'package:live_ffss_v2/features/home/home_view.dart';
import 'package:live_ffss_v2/features/shell/active_competition.dart';

/// La compétition que suivent les onglets : celle qu'on a choisie, sinon la
/// première du carrousel « EN DIRECT » (un favori s'il y en a un en direct),
/// sinon aucune.
CompetitionSummary? currentCompetition({
  required List<CompetitionSummary> competitions,
  required ActiveSelection? selection,
  required Set<int> favorites,
  required DateTime today,
}) {
  if (selection != null) {
    for (final c in competitions) {
      if (c.id == selection.id) return c;
    }
    if (selection.summary case final summary?) return summary;
  }
  final live = orderLive(
    partitionHome(competitions, today).live,
    favorites: favorites,
  );
  return live.isEmpty ? null : live.first;
}
```

- [ ] **Étape 4 : lancer les tests des fonctions pures**

Run : `flutter test test/features/home/home_view_test.dart test/features/shell/current_competition_test.dart`
Expected : PASS.

- [ ] **Étape 5 : écrire les tests des fournisseurs**

`test/features/home/home_providers_test.dart` :

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/repositories/competition_repository.dart';
import 'package:live_ffss_v2/features/home/home_providers.dart';
import 'package:live_ffss_v2/features/home/home_view.dart';
import 'package:live_ffss_v2/features/shell/current_competition.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/competitions.dart';
import '../../support/in_memory_local_store.dart';

class _MockCompetitionRepository extends Mock implements CompetitionRepository {}

void main() {
  late _MockCompetitionRepository repository;
  late ProviderContainer container;

  setUpAll(() => registerFallbackValue(DateTime(2000)));

  setUp(() {
    repository = _MockCompetitionRepository();
    container = ProviderContainer(
      overrides: [
        competitionRepositoryProvider.overrideWithValue(repository),
        localStoreProvider.overrideWithValue(InMemoryLocalStore()),
        clockProvider.overrideWithValue(() => DateTime(2026, 10, 17, 9, 42)),
      ],
      retry: (_, __) => null,
    );
    addTearDown(container.dispose);
  });

  test('demande les compétitions à partir d\'aujourd\'hui − 14 jours', () async {
    when(() => repository.getCompetitionsFrom(any())).thenAnswer((_) async => []);

    await container.read(homeCompetitionsProvider.future);

    verify(() => repository.getCompetitionsFrom(DateTime(2026, 10, 3))).called(1);
  });

  test('la vue suit le filtre', () async {
    when(() => repository.getCompetitionsFrom(any())).thenAnswer((_) async => [
          competition(1, start: DateTime(2026, 10, 20)),
        ]);
    container.listen(homeViewProvider, (_, __) {});
    await container.read(homeCompetitionsProvider.future);

    expect(container.read(homeViewProvider)?.upcomingCount, 1);

    container.read(homeFilterProvider.notifier).select(HomeFilter.coastal);

    expect(container.read(homeViewProvider)?.upcomingCount, 0);
  });

  test('un rafraîchissement en échec garde la liste affichée', () async {
    var calls = 0;
    when(() => repository.getCompetitionsFrom(any())).thenAnswer((_) async {
      if (calls++ == 0) return [competition(1, start: DateTime(2026, 10, 20))];
      throw const NetworkException('offline');
    });
    container.listen(homeViewProvider, (_, __) {});
    await container.read(homeCompetitionsProvider.future);

    await expectLater(
      container.refresh(homeCompetitionsProvider.future),
      throwsA(isA<NetworkException>()),
    );

    final state = container.read(homeCompetitionsProvider);
    expect(state.hasError, isTrue);
    expect(state.hasValue, isTrue);
    expect(container.read(homeViewProvider)?.upcomingCount, 1);
  });

  test('la compétition courante par défaut est celle en direct', () async {
    final live = competition(7, start: DateTime(2026, 10, 17));
    when(() => repository.getCompetitionsFrom(any())).thenAnswer((_) async => [live]);
    container.listen(currentCompetitionProvider, (_, __) {});
    await container.read(homeCompetitionsProvider.future);

    expect(container.read(currentCompetitionProvider), live);
  });
}
```

Si le test « un rafraîchissement en échec garde la liste affichée » échoue sur `state.hasValue`, c'est que Riverpod ne conserve pas la valeur précédente dans ce cas : faire alors de `homeCompetitionsProvider` un `AsyncNotifierProvider` qui, dans un `refresh()` explicite, attrape l'`AppException` et pose `AsyncError(e, st).copyWithPrevious(state)`. Ne pas affaiblir le test.

`test/features/home/now_running_provider_test.dart` :

```dart
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/data/repositories/meeting_repository.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/now_running.dart';
import 'package:live_ffss_v2/domain/run_status.dart';
import 'package:live_ffss_v2/features/home/now_running_provider.dart';
import 'package:mocktail/mocktail.dart';

class _MockMeetingRepository extends Mock implements MeetingRepository {}

void main() {
  late _MockMeetingRepository repository;

  setUp(() {
    repository = _MockMeetingRepository();
    when(() => repository.getMeetings(any())).thenAnswer(
      (_) async => [
        Meeting(id: 1, name: 'R', day: DateTime(2026, 3, 27), items: const [
          MeetingItem(id: 10, name: 'C', heats: [
            Heat(id: 20, name: 'Série 1', number: 1, status: RunStatus.inProgress),
          ]),
        ]),
      ],
    );
  });

  test('calcule la série en cours de la compétition', () async {
    final container = ProviderContainer(
      overrides: [meetingRepositoryProvider.overrideWithValue(repository)],
      retry: (_, __) => null,
    );
    addTearDown(container.dispose);
    container.listen(nowRunningProvider(1453), (_, __) {});

    final result = await container.read(nowRunningProvider(1453).future);

    expect(result?.heat.id, 20);
    expect(result?.kind, NowRunningKind.now);
    verify(() => repository.getMeetings(1453)).called(1);
  });

  test('se rafraîchit toutes les 30 s, et s\'arrête quand plus personne n\'écoute', () {
    fakeAsync((async) {
      final container = ProviderContainer(
        overrides: [meetingRepositoryProvider.overrideWithValue(repository)],
        retry: (_, __) => null,
      );
      final subscription = container.listen(nowRunningProvider(1453), (_, __) {});
      async.flushMicrotasks();
      verify(() => repository.getMeetings(1453)).called(1);

      async.elapse(nowRunningRefresh);
      async.flushMicrotasks();
      verify(() => repository.getMeetings(1453)).called(1);

      subscription.close();
      async.elapse(nowRunningRefresh * 3);
      async.flushMicrotasks();
      verifyNever(() => repository.getMeetings(1453));

      container.dispose();
    });
  });
}
```

`test/features/home/search_provider_test.dart` :

```dart
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/data/repositories/competition_repository.dart';
import 'package:live_ffss_v2/features/home/search_provider.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/competitions.dart';

class _MockCompetitionRepository extends Mock implements CompetitionRepository {}

void main() {
  late _MockCompetitionRepository repository;

  setUp(() {
    repository = _MockCompetitionRepository();
    when(() => repository.search(any())).thenAnswer(
      (_) async => [competition(1, start: DateTime(2026, 3, 27))],
    );
  });

  ProviderContainer containerFor() => ProviderContainer(
        overrides: [competitionRepositoryProvider.overrideWithValue(repository)],
        retry: (_, __) => null,
      );

  test('moins de 2 caractères : aucun appel, aucun résultat', () async {
    final container = containerFor();
    addTearDown(container.dispose);
    container.listen(searchResultsProvider(' g '), (_, __) {});

    expect(await container.read(searchResultsProvider(' g ').future), isEmpty);
    verifyNever(() => repository.search(any()));
  });

  test('appelle la recherche 300 ms après la dernière frappe', () {
    fakeAsync((async) {
      final container = containerFor();
      container.listen(searchResultsProvider('gir'), (_, __) {});

      async.elapse(searchDebounce - const Duration(milliseconds: 1));
      verifyNever(() => repository.search(any()));

      async.elapse(const Duration(milliseconds: 1));
      async.flushMicrotasks();
      verify(() => repository.search('gir')).called(1);

      container.dispose();
    });
  });

  test('une frappe abandonnée avant 300 ms n\'appelle jamais l\'API', () {
    fakeAsync((async) {
      final container = containerFor();
      final subscription = container.listen(searchResultsProvider('gi'), (_, __) {});

      async.elapse(const Duration(milliseconds: 100));
      subscription.close();
      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();

      verifyNever(() => repository.search('gi'));
      container.dispose();
    });
  });
}
```

- [ ] **Étape 6 : lancer les tests pour les voir échouer**

Run : `flutter test test/features`
Expected : FAIL — `home_providers.dart`, `now_running_provider.dart`, `search_provider.dart` n'existent pas.

- [ ] **Étape 7 : écrire les fournisseurs**

`lib/features/home/home_providers.dart` :

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/repositories/competition_repository.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/domain/home_partition.dart';
import 'package:live_ffss_v2/features/home/favorites.dart';
import 'package:live_ffss_v2/features/home/home_view.dart';
import 'package:live_ffss_v2/features/shell/active_competition.dart';

/// Les compétitions de l'accueil. On part d'aujourd'hui − 14 jours et non du
/// début de saison : sinon, au 1er octobre, les compétitions terminées la
/// semaine d'avant disparaîtraient de « Terminées récemment ».
final homeCompetitionsProvider =
    FutureProvider<List<CompetitionSummary>>((ref) {
  final today = dayOf(ref.watch(clockProvider)());
  return ref.watch(competitionRepositoryProvider).getCompetitionsFrom(
        DateTime(today.year, today.month, today.day - recentWindowDays),
      );
});

class HomeFilterNotifier extends Notifier<HomeFilter> {
  @override
  HomeFilter build() => HomeFilter.all;

  void select(HomeFilter filter) => state = filter;
}

final homeFilterProvider =
    NotifierProvider<HomeFilterNotifier, HomeFilter>(HomeFilterNotifier.new);

/// Nulle tant qu'aucune liste n'a été chargée. Après un rafraîchissement en
/// échec, elle garde la dernière liste : au bord d'un bassin, un écran qui se
/// vide à chaque coupure serait pire que des données vieilles de 30 s.
final homeViewProvider = Provider<HomeView?>((ref) {
  final competitions = ref.watch(homeCompetitionsProvider).value;
  if (competitions == null) return null;
  return buildHomeView(
    competitions: competitions,
    today: ref.watch(clockProvider)(),
    filter: ref.watch(homeFilterProvider),
    favorites: ref.watch(favoritesProvider).value ?? const {},
    activeId: ref.watch(activeCompetitionProvider).value?.id,
  );
});
```

Ajouter à la fin de `lib/features/shell/current_competition.dart` (avec les imports `package:flutter_riverpod/flutter_riverpod.dart`, `package:live_ffss_v2/core/providers.dart`, `package:live_ffss_v2/features/home/favorites.dart`, `package:live_ffss_v2/features/home/home_providers.dart`) :

```dart
final currentCompetitionProvider = Provider<CompetitionSummary?>((ref) {
  return currentCompetition(
    competitions: ref.watch(homeCompetitionsProvider).value ?? const [],
    selection: ref.watch(activeCompetitionProvider).value,
    favorites: ref.watch(favoritesProvider).value ?? const {},
    today: ref.watch(clockProvider)(),
  );
});
```

`lib/features/home/now_running_provider.dart` :

```dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/data/repositories/meeting_repository.dart';
import 'package:live_ffss_v2/domain/now_running.dart';

/// L'API ne pousse rien : la carte en direct se relit à ce rythme.
const Duration nowRunningRefresh = Duration(seconds: 30);

/// La série à afficher pour une compétition en direct. Libéré dès que sa
/// carte n'est plus affichée (`autoDispose`), ce qui annule la minuterie :
/// aucun appel ne part pour une carte que personne ne regarde.
final nowRunningProvider =
    FutureProvider.autoDispose.family<NowRunning?, int>((ref, competitionId) async {
  final timer = Timer(nowRunningRefresh, ref.invalidateSelf);
  ref.onDispose(timer.cancel);
  final meetings =
      await ref.watch(meetingRepositoryProvider).getMeetings(competitionId);
  return nowRunning(meetings);
});
```

`lib/features/home/search_provider.dart` :

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/data/repositories/competition_repository.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';

const Duration searchDebounce = Duration(milliseconds: 300);

/// En dessous, une recherche rend presque toute la base : on n'appelle pas.
const int searchMinLength = 2;

/// Chaque frappe crée un nouveau fournisseur (paramétré par le texte) et
/// libère le précédent : seul celui qui survit [searchDebounce] appelle l'API.
/// Un fournisseur libéré entre-temps rend une liste vide que personne ne lit,
/// plutôt qu'une erreur que personne n'attrape.
final searchResultsProvider = FutureProvider.autoDispose
    .family<List<CompetitionSummary>, String>((ref, query) async {
  final text = query.trim();
  if (text.length < searchMinLength) return const [];
  var disposed = false;
  ref.onDispose(() => disposed = true);
  await Future<void>.delayed(searchDebounce);
  if (disposed) return const [];
  return ref.read(competitionRepositoryProvider).search(text);
});
```

- [ ] **Étape 8 : lancer les tests**

Run : `flutter test test/features`
Expected : PASS. Si le test de la minuterie de `nowRunningProvider` voit encore un appel après `subscription.close()`, c'est que la libération `autoDispose` n'a pas encore eu lieu : ajouter `async.elapse(Duration.zero); async.flushMicrotasks();` juste après `subscription.close()`. Ne pas supprimer l'assertion.

- [ ] **Étape 9 : commiter**

```bash
dart format lib test && flutter analyze
git add -A . && git commit -m "feat(v2): état de l'accueil — filtre, carrousel, compétition courante, maintenant, recherche"
```

---

### Tâche 11 : thème, traductions et formatage

**Files :**
- Create : `lib/core/theme/app_colors.dart`, `lib/core/theme/app_theme.dart`, `l10n.yaml`, `lib/core/l10n/app_fr.arb`, `lib/core/l10n/app_en.arb`, `lib/features/home/competition_formatting.dart`
- Generated : `lib/core/l10n/gen/app_localizations*.dart`
- Test : `test/features/home/competition_formatting_test.dart`

**Interfaces :**
- Consumes : `CompetitionSummary`, `Discipline`, `dayOf` (tâche 3) ; `Gender` (tâche 4) ; `NowRunning` (tâche 4)
- Produces :
  - `abstract final class AppColors { navy, navyRaised, blue, yellow, red, background, surface, border, textPrimary, textSecondary, flatWaterBackground, flatWaterText, coastalBackground, coastalText, dateBox }`
  - `ThemeData buildAppTheme()`
  - `AppLocalizations` (généré, `AppLocalizations.of(context)`), clés listées à l'étape 3
  - `extension CompetitionFormatting on CompetitionSummary { String dateRangeLabel(String locale); ({int current, int total})? dayOfCompetition(DateTime today); String disciplineLabel(AppLocalizations l10n); }`
  - `String shortDayLabel(DateTime day)`, `String monthLabel(DateTime day, String locale)`
  - `String heatLine(NowRunning now, AppLocalizations l10n)`

- [ ] **Étape 1 : écrire les tests du formatage**

`test/features/home/competition_formatting_test.dart` :

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:live_ffss_v2/features/home/competition_formatting.dart';

import '../../support/competitions.dart';

void main() {
  setUpAll(() => initializeDateFormatting('fr'));

  group('dateRangeLabel', () {
    test('un seul jour', () {
      expect(competition(1, start: DateTime(2026, 3, 27)).dateRangeLabel('fr'),
          '27 mars 2026');
    });

    test('même mois', () {
      expect(
        competition(1, start: DateTime(2026, 3, 27), end: DateTime(2026, 3, 29))
            .dateRangeLabel('fr'),
        '27 – 29 mars 2026',
      );
    });

    test('deux mois de la même année', () {
      expect(
        competition(1, start: DateTime(2026, 3, 30), end: DateTime(2026, 4, 2))
            .dateRangeLabel('fr'),
        '30 mars – 2 avr. 2026',
      );
    });

    test('à cheval sur deux années', () {
      expect(
        competition(1, start: DateTime(2026, 12, 30), end: DateTime(2027, 1, 2))
            .dateRangeLabel('fr'),
        '30 déc. 2026 – 2 janv. 2027',
      );
    });
  });

  group('dayOfCompetition', () {
    final c = competition(1, start: DateTime(2026, 3, 27), end: DateTime(2026, 3, 29));

    test('pendant la compétition : jour courant et nombre de jours', () {
      expect(c.dayOfCompetition(DateTime(2026, 3, 27, 18)), (current: 1, total: 3));
      expect(c.dayOfCompetition(DateTime(2026, 3, 29, 8)), (current: 3, total: 3));
    });

    test('hors de la compétition ou compétition d\'un jour : rien', () {
      expect(c.dayOfCompetition(DateTime(2026, 3, 30)), isNull);
      expect(
        competition(2, start: DateTime(2026, 3, 27)).dayOfCompetition(DateTime(2026, 3, 27)),
        isNull,
      );
    });
  });

  test('libellés de la case date d\'une ligne', () {
    expect(shortDayLabel(DateTime(2026, 10, 18)), '18');
    expect(monthLabel(DateTime(2026, 10, 18), 'fr'), 'OCT.');
  });
}
```

- [ ] **Étape 2 : lancer le test pour le voir échouer**

Run : `flutter test test/features/home/competition_formatting_test.dart`
Expected : FAIL — `competition_formatting.dart` n'existe pas.

- [ ] **Étape 3 : écrire les traductions**

`l10n.yaml` (à la racine de `live_ffss.v2/`) :

```yaml
arb-dir: lib/core/l10n
template-arb-file: app_fr.arb
output-localization-file: app_localizations.dart
output-dir: lib/core/l10n/gen
nullable-getter: false
```

`lib/core/l10n/app_fr.arb` :

```json
{
  "@@locale": "fr",
  "appTitle": "FFSS-LIVE",
  "appTagline": "Sauvetage sportif en direct",
  "signIn": "Se connecter",
  "searchHint": "Compétition, ville, club…",
  "filterAll": "Toutes",
  "filterFlatWater": "Eau plate",
  "filterCoastal": "Côtier",
  "filterFavorites": "Mes favoris",
  "disciplineFlatWater": "Eau plate",
  "disciplineCoastal": "Côtier",
  "disciplineMixed": "Mixte",
  "liveBadge": "EN DIRECT",
  "dayOfTotal": "Jour {current}/{total}",
  "@dayOfTotal": {
    "placeholders": {
      "current": {"type": "int"},
      "total": {"type": "int"}
    }
  },
  "nowRunning": "MAINTENANT",
  "nextUp": "À SUIVRE",
  "heatOfTotal": "Série {position}/{total}",
  "@heatOfTotal": {
    "placeholders": {
      "position": {"type": "int"},
      "total": {"type": "int"}
    }
  },
  "genderFemale": "Dames",
  "genderMale": "Messieurs",
  "genderMixed": "Mixte",
  "upcoming": "À venir",
  "seeAll": "Tout voir",
  "recentlyFinished": "Terminées récemment",
  "allCompetitions": "Compétitions",
  "noCompetition": "Aucune compétition",
  "loadError": "Impossible de charger les compétitions.",
  "retry": "Réessayer",
  "refreshFailed": "Mise à jour impossible : les données affichées sont conservées.",
  "addFavorite": "Ajouter aux favoris",
  "removeFavorite": "Retirer des favoris",
  "tabHome": "Accueil",
  "tabProgramme": "Programme",
  "tabLive": "Live",
  "tabResults": "Résultats",
  "tabMySpace": "Mon espace",
  "availableInLot": "Disponible au lot {lot}",
  "@availableInLot": {
    "placeholders": {
      "lot": {"type": "int"}
    }
  },
  "chooseCompetition": "Choisir une compétition",
  "chooseCompetitionHint": "Ouvrez une compétition depuis l'accueil pour suivre son programme, son live et ses résultats.",
  "comingSoon": "Bientôt",
  "mySpaceComingSoon": "La connexion et votre espace arrivent bientôt."
}
```

`lib/core/l10n/app_en.arb` :

```json
{
  "@@locale": "en",
  "appTitle": "FFSS-LIVE",
  "appTagline": "Lifesaving sport, live",
  "signIn": "Sign in",
  "searchHint": "Competition, city, club…",
  "filterAll": "All",
  "filterFlatWater": "Pool",
  "filterCoastal": "Ocean",
  "filterFavorites": "My favourites",
  "disciplineFlatWater": "Pool",
  "disciplineCoastal": "Ocean",
  "disciplineMixed": "Mixed",
  "liveBadge": "LIVE",
  "dayOfTotal": "Day {current}/{total}",
  "nowRunning": "NOW",
  "nextUp": "UP NEXT",
  "heatOfTotal": "Heat {position}/{total}",
  "genderFemale": "Women",
  "genderMale": "Men",
  "genderMixed": "Mixed",
  "upcoming": "Upcoming",
  "seeAll": "See all",
  "recentlyFinished": "Recently finished",
  "allCompetitions": "Competitions",
  "noCompetition": "No competition",
  "loadError": "Could not load competitions.",
  "retry": "Retry",
  "refreshFailed": "Update failed: the data shown is kept.",
  "addFavorite": "Add to favourites",
  "removeFavorite": "Remove from favourites",
  "tabHome": "Home",
  "tabProgramme": "Programme",
  "tabLive": "Live",
  "tabResults": "Results",
  "tabMySpace": "My space",
  "availableInLot": "Coming in batch {lot}",
  "chooseCompetition": "Choose a competition",
  "chooseCompetitionHint": "Open a competition from the home screen to follow its programme, live heats and results.",
  "comingSoon": "Coming soon",
  "mySpaceComingSoon": "Sign-in and your personal space are coming soon."
}
```

« Eau plate » se traduit par « Pool » et « Côtier » par « Ocean » : ce sont les termes de l'ILS, la fédération internationale. La règle « jamais Piscine » vaut pour le français.

Run : `flutter gen-l10n`
Expected : `lib/core/l10n/gen/app_localizations.dart`, `app_localizations_fr.dart`, `app_localizations_en.dart` créés.

- [ ] **Étape 4 : écrire le thème**

`lib/core/theme/app_colors.dart` :

```dart
import 'package:flutter/painting.dart';

/// Les couleurs de la maquette « FFSS LIVE — visualisation ».
abstract final class AppColors {
  static const navy = Color(0xFF13285E);
  static const navyRaised = Color(0xFF2B3D70);
  static const blue = Color(0xFF1E3F8F);
  static const yellow = Color(0xFFFFCC00);
  static const red = Color(0xFFDC2626);
  static const background = Color(0xFFF3F5F9);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFE2E6EE);
  static const textPrimary = Color(0xFF0F1B3D);
  static const textSecondary = Color(0xFF5B6478);
  static const flatWaterBackground = Color(0xFFE3E9F7);
  static const flatWaterText = Color(0xFF1E3A8A);
  static const coastalBackground = Color(0xFFE2F3EA);
  static const coastalText = Color(0xFF17643B);
  static const dateBox = Color(0xFFEEF2F9);
}
```

`lib/core/theme/app_theme.dart` :

```dart
import 'package:flutter/material.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.navy,
    primary: AppColors.navy,
    secondary: AppColors.yellow,
    surface: AppColors.surface,
    error: AppColors.red,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: 'Barlow',
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.navy,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        side: BorderSide(color: AppColors.border),
      ),
    ),
    chipTheme: const ChipThemeData(
      selectedColor: AppColors.navy,
      backgroundColor: AppColors.surface,
      side: BorderSide(color: AppColors.border),
      shape: StadiumBorder(),
      showCheckmark: false,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.yellow.withValues(alpha: 0.35),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    ),
  );
}
```

- [ ] **Étape 5 : écrire le formatage**

`lib/features/home/competition_formatting.dart` :

```dart
import 'package:intl/intl.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/domain/discipline.dart';
import 'package:live_ffss_v2/domain/gender.dart';
import 'package:live_ffss_v2/domain/home_partition.dart';
import 'package:live_ffss_v2/domain/now_running.dart';

extension CompetitionFormatting on CompetitionSummary {
  /// « 27 mars 2026 », « 27 – 29 mars 2026 », « 30 mars – 2 avr. 2026 »,
  /// « 30 déc. 2026 – 2 janv. 2027 ».
  String dateRangeLabel(String locale) {
    final full = DateFormat('d MMMM y', locale);
    final short = DateFormat('d MMM', locale);
    final shortYear = DateFormat('d MMM y', locale);
    if (startDate == endDate) return full.format(startDate);
    if (startDate.year == endDate.year && startDate.month == endDate.month) {
      return '${startDate.day} – ${full.format(endDate)}';
    }
    if (startDate.year == endDate.year) {
      return '${short.format(startDate)} – ${shortYear.format(endDate)}';
    }
    return '${shortYear.format(startDate)} – ${shortYear.format(endDate)}';
  }

  /// « Jour 1/3 » : nul hors de la compétition, et pour une compétition d'un
  /// seul jour, où il n'apprendrait rien.
  ({int current, int total})? dayOfCompetition(DateTime today) {
    final day = dayOf(today);
    if (day.isBefore(startDate) || day.isAfter(endDate)) return null;
    final total = _daysBetween(startDate, endDate) + 1;
    if (total <= 1) return null;
    return (current: _daysBetween(startDate, day) + 1, total: total);
  }

  String disciplineLabel(AppLocalizations l10n) {
    final flat = disciplines.contains(Discipline.flatWater);
    final coastal = disciplines.contains(Discipline.coastal);
    if (flat && coastal) return l10n.disciplineMixed;
    return coastal ? l10n.disciplineCoastal : l10n.disciplineFlatWater;
  }
}

/// En jours civils : un écart en heures se trompe d'un jour au changement
/// d'heure.
int _daysBetween(DateTime from, DateTime to) =>
    DateTime.utc(to.year, to.month, to.day)
        .difference(DateTime.utc(from.year, from.month, from.day))
        .inDays;

String shortDayLabel(DateTime day) => '${day.day}';

String monthLabel(DateTime day, String locale) =>
    DateFormat('MMM', locale).format(day).toUpperCase();

String genderLabel(Gender gender, AppLocalizations l10n) => switch (gender) {
      Gender.female => l10n.genderFemale,
      Gender.male => l10n.genderMale,
      Gender.mixed => l10n.genderMixed,
    };

/// « 200 m Obstacles · Dames · Série 4/10 », sans les morceaux inconnus.
String heatLine(NowRunning now, AppLocalizations l10n) => [
      if (now.heat.raceName.isNotEmpty) now.heat.raceName,
      if (now.heat.gender case final gender?) genderLabel(gender, l10n),
      if (now.total > 1)
        l10n.heatOfTotal(now.position, now.total)
      else if (now.heat.name.isNotEmpty)
        now.heat.name,
    ].join(' · ');
```

- [ ] **Étape 6 : lancer les tests**

Run : `flutter test test/features/home/competition_formatting_test.dart`
Expected : PASS. Si `intl` abrège un mois autrement que prévu (par exemple « avr. » sans point), corriger **l'attendu du test** pour qu'il reflète la sortie réelle d'`intl` en français, pas le code.

- [ ] **Étape 7 : commiter**

```bash
dart format lib test && flutter analyze
git add -A . && git commit -m "feat(v2): thème de la maquette, traductions fr/en, formatage des dates"
```

---

### Tâche 12 : application, routeur, barre à 5 onglets et pages provisoires

**Files :**
- Create/replace : `lib/main.dart`, `lib/app.dart`, `lib/core/router/app_router.dart`, `lib/features/shell/app_shell.dart`, `lib/features/shell/tab_placeholders.dart`, `lib/features/shell/open_competition.dart`
- Create (provisoire, remplacée à la tâche 13) : `lib/features/home/home_page.dart`, `lib/features/home/all_competitions_page.dart`

**Interfaces :**
- Consumes : `buildAppTheme`, `AppLocalizations` (tâche 11) ; `currentCompetitionProvider` (tâche 10) ; `activeCompetitionProvider` (tâche 9)
- Produces :
  - `abstract final class Routes { home = '/', allCompetitions = '/competitions', programme = '/programme', live = '/live', results = '/resultats', mySpace = '/espace' }`
  - `final routerProvider = Provider<GoRouter>`
  - `class LiveFfssApp extends ConsumerWidget`
  - `Future<void> openCompetition(BuildContext context, WidgetRef ref, CompetitionSummary competition, {String route = Routes.programme})`
  - `class HomePage extends ConsumerWidget`, `class AllCompetitionsPage extends ConsumerStatefulWidget` (contenu final à la tâche 13)

Pas de test automatisé dans cette tâche (pas de test de widget) : la vérification est `flutter analyze`, puis un lancement réel à l'étape 6.

- [ ] **Étape 1 : écrire les pages provisoires de l'accueil**

`lib/features/home/home_page.dart` :

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      const Scaffold(body: Center(child: Text('Accueil')));
}
```

`lib/features/home/all_competitions_page.dart` :

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AllCompetitionsPage extends ConsumerStatefulWidget {
  const AllCompetitionsPage({super.key});

  @override
  ConsumerState<AllCompetitionsPage> createState() =>
      _AllCompetitionsPageState();
}

class _AllCompetitionsPageState extends ConsumerState<AllCompetitionsPage> {
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Compétitions')));
}
```

- [ ] **Étape 2 : écrire l'ouverture d'une compétition et les pages provisoires des onglets**

`lib/features/shell/open_competition.dart` :

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:live_ffss_v2/core/router/app_router.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/features/shell/active_competition.dart';

/// Rend [competition] active et ouvre l'onglet [route] (Programme par défaut).
/// La navigation part tout de suite : l'enregistrement de l'id ne la retarde
/// pas.
Future<void> openCompetition(
  BuildContext context,
  WidgetRef ref,
  CompetitionSummary competition, {
  String route = Routes.programme,
}) {
  final saved =
      ref.read(activeCompetitionProvider.notifier).select(competition);
  context.go(route);
  return saved;
}
```

`lib/features/shell/tab_placeholders.dart` :

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/router/app_router.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/features/shell/current_competition.dart';

/// Les onglets qui suivent la compétition active, avec le lot qui les livre.
enum CompetitionTab {
  programme(2),
  live(3),
  results(5);

  const CompetitionTab(this.lot);

  final int lot;

  String title(AppLocalizations l10n) => switch (this) {
        CompetitionTab.programme => l10n.tabProgramme,
        CompetitionTab.live => l10n.tabLive,
        CompetitionTab.results => l10n.tabResults,
      };
}

class CompetitionTabPlaceholder extends ConsumerWidget {
  const CompetitionTabPlaceholder({super.key, required this.tab});

  final CompetitionTab tab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final competition = ref.watch(currentCompetitionProvider);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (competition != null)
              Text(
                competition.name,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            Text(
              tab.title(l10n),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: competition == null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.chooseCompetitionHint,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.go(Routes.home),
                      child: Text(l10n.chooseCompetition),
                    ),
                  ],
                )
              : Text(
                  l10n.availableInLot(tab.lot),
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
        ),
      ),
    );
  }
}

class MySpacePlaceholder extends StatelessWidget {
  const MySpacePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabMySpace)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.comingSoon,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.mySpaceComingSoon,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Étape 3 : écrire la barre à 5 onglets et le routeur**

`lib/features/shell/app_shell.dart` :

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        // Toucher l'onglet déjà ouvert revient à sa racine.
        onDestinationSelected: (index) =>
            shell.goBranch(index, initialLocation: index == shell.currentIndex),
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: l10n.tabHome),
          NavigationDestination(
              icon: const Icon(Icons.calendar_today_outlined),
              selectedIcon: const Icon(Icons.calendar_today),
              label: l10n.tabProgramme),
          NavigationDestination(
              icon: const Icon(Icons.sensors_outlined),
              selectedIcon: const Icon(Icons.sensors),
              label: l10n.tabLive),
          NavigationDestination(
              icon: const Icon(Icons.bar_chart_outlined),
              selectedIcon: const Icon(Icons.bar_chart),
              label: l10n.tabResults),
          NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
              label: l10n.tabMySpace),
        ],
      ),
    );
  }
}
```

`lib/core/router/app_router.dart` :

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:live_ffss_v2/features/home/all_competitions_page.dart';
import 'package:live_ffss_v2/features/home/home_page.dart';
import 'package:live_ffss_v2/features/shell/app_shell.dart';
import 'package:live_ffss_v2/features/shell/tab_placeholders.dart';

abstract final class Routes {
  static const home = '/';
  static const allCompetitions = '/competitions';
  static const programme = '/programme';
  static const live = '/live';
  static const results = '/resultats';
  static const mySpace = '/espace';
}

/// Une branche par onglet : chacune garde sa propre pile, donc sa position
/// quand on passe d'un onglet à l'autre.
final routerProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: Routes.home,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.home,
              builder: (context, state) => const HomePage(),
              routes: [
                GoRoute(
                  path: 'competitions',
                  builder: (context, state) => const AllCompetitionsPage(),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.programme,
              builder: (context, state) =>
                  const CompetitionTabPlaceholder(tab: CompetitionTab.programme),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.live,
              builder: (context, state) =>
                  const CompetitionTabPlaceholder(tab: CompetitionTab.live),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.results,
              builder: (context, state) =>
                  const CompetitionTabPlaceholder(tab: CompetitionTab.results),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.mySpace,
              builder: (context, state) => const MySpacePlaceholder(),
            ),
          ]),
        ],
      ),
    ],
  ),
);
```

- [ ] **Étape 4 : écrire l'application et le point d'entrée**

`lib/app.dart` :

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/router/app_router.dart';
import 'package:live_ffss_v2/core/theme/app_theme.dart';

class LiveFfssApp extends ConsumerWidget {
  const LiveFfssApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: buildAppTheme(),
      routerConfig: ref.watch(routerProvider),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

`lib/main.dart` (remplace celui de `flutter create`) :

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:live_ffss_v2/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Les formats de date des extensions de présentation (`DateFormat('d MMMM
  // y', locale)`) lèvent tant que les données de la langue ne sont pas
  // chargées.
  await initializeDateFormatting();
  runApp(const ProviderScope(child: LiveFfssApp()));
}
```

- [ ] **Étape 5 : vérifier**

Run : `flutter analyze && flutter test`
Expected : `No issues found!`, `All tests passed!`

- [ ] **Étape 6 : lancer l'application**

Run : `flutter run -d chrome` (ou `-d edge`). Si aucun navigateur n'est disponible, passer à l'étape suivante en notant que la vérification visuelle revient à l'utilisateur.

Vérifier : les cinq onglets s'affichent et se sélectionnent ; Programme montre « Choisir une compétition », qui ramène à l'accueil ; Mon espace montre « Bientôt ».

- [ ] **Étape 7 : commiter**

```bash
dart format lib test
git add -A . && git commit -m "feat(v2): application, routeur et barre à 5 onglets"
```

---

### Tâche 13 : l'écran d'accueil et l'écran « Tout voir »

**Files :**
- Replace : `lib/features/home/home_page.dart`, `lib/features/home/all_competitions_page.dart`
- Create : `lib/features/home/widgets/home_header.dart`, `search_entry.dart`, `filter_bar.dart`, `discipline_badge.dart`, `competition_row.dart`, `competition_section.dart`, `live_carousel.dart`, `live_card.dart`

**Interfaces :**
- Consumes : `homeCompetitionsProvider`, `homeViewProvider`, `homeFilterProvider`, `HomeFilter`, `matchesFilter`, `HomeView` (tâche 10) ; `favoritesProvider` (tâche 9) ; `nowRunningProvider`, `searchResultsProvider`, `searchMinLength` (tâche 10) ; `CompetitionFormatting`, `heatLine`, `shortDayLabel`, `monthLabel` (tâche 11) ; `openCompetition`, `Routes` (tâche 12) ; `clockProvider` (tâche 2) ; `NowRunningKind` (tâche 4) ; `AppColors`, `AppLocalizations` (tâche 11)
- Produces : l'accueil complet de l'écran 1.

Pas de test de widget : la vérification est `flutter analyze` puis un lancement réel (étape 5).

- [ ] **Étape 1 : écrire les petits widgets**

`lib/features/home/widgets/home_header.dart` :

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/router/app_router.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      color: AppColors.navy,
      padding: EdgeInsets.fromLTRB(
          16, MediaQuery.of(context).padding.top + 12, 16, 16),
      child: Row(
        children: [
          Image.asset('assets/images/logo_ffss.png', width: 44, height: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.appTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  l10n.appTagline,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            // Au lot 1, « Se connecter » mène à la page « Bientôt » de Mon
            // espace : la connexion arrive au lot 4.
            onPressed: () => context.go(Routes.mySpace),
            icon: const Icon(Icons.person_outline, size: 20),
            label: Text(l10n.signIn),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white54),
              shape: const StadiumBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
```

`lib/features/home/widgets/search_entry.dart` :

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/router/app_router.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';

/// Le champ de recherche de l'accueil : un raccourci vers « Tout voir », où
/// la saisie a lieu.
class SearchEntry extends StatelessWidget {
  const SearchEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        onTap: () => context.go(Routes.allCompetitions),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context).searchHint,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

`lib/features/home/widgets/filter_bar.dart` :

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/features/home/home_providers.dart';
import 'package:live_ffss_v2/features/home/home_view.dart';

class FilterBar extends ConsumerWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected = ref.watch(homeFilterProvider);
    String label(HomeFilter filter) => switch (filter) {
          HomeFilter.all => l10n.filterAll,
          HomeFilter.flatWater => l10n.filterFlatWater,
          HomeFilter.coastal => l10n.filterCoastal,
          HomeFilter.favorites => l10n.filterFavorites,
        };
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in HomeFilter.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(label(filter)),
                selected: filter == selected,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: filter == selected
                      ? Colors.white
                      : AppColors.textPrimary,
                ),
                onSelected: (_) =>
                    ref.read(homeFilterProvider.notifier).select(filter),
              ),
            ),
        ],
      ),
    );
  }
}
```

`lib/features/home/widgets/discipline_badge.dart` :

```dart
import 'package:flutter/material.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/domain/discipline.dart';
import 'package:live_ffss_v2/features/home/competition_formatting.dart';

class DisciplineBadge extends StatelessWidget {
  const DisciplineBadge({super.key, required this.competition});

  final CompetitionSummary competition;

  @override
  Widget build(BuildContext context) {
    final coastalOnly = competition.disciplines.length == 1 &&
        competition.disciplines.contains(Discipline.coastal);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: coastalOnly
            ? AppColors.coastalBackground
            : AppColors.flatWaterBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          competition.disciplineLabel(AppLocalizations.of(context)),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: coastalOnly ? AppColors.coastalText : AppColors.flatWaterText,
          ),
        ),
      ),
    );
  }
}
```

`lib/features/home/widgets/competition_row.dart` :

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/features/home/competition_formatting.dart';
import 'package:live_ffss_v2/features/home/favorites.dart';
import 'package:live_ffss_v2/features/home/widgets/discipline_badge.dart';
import 'package:live_ffss_v2/features/shell/open_competition.dart';

/// Une ligne de liste : case date, nom, organisateur, badge, étoile.
class CompetitionRow extends ConsumerWidget {
  const CompetitionRow({super.key, required this.competition});

  final CompetitionSummary competition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final isFavorite =
        ref.watch(favoritesProvider).value?.contains(competition.id) ?? false;
    return InkWell(
      onTap: () => openCompetition(context, ref, competition),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
        child: Row(
          children: [
            Container(
              width: 56,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.dateBox,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    shortDayLabel(competition.startDate),
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    monthLabel(competition.startDate, locale),
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    competition.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  if (competition.organizer case final organizer?)
                    Text(
                      organizer,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            DisciplineBadge(competition: competition),
            IconButton(
              tooltip: isFavorite ? l10n.removeFavorite : l10n.addFavorite,
              onPressed: () =>
                  ref.read(favoritesProvider.notifier).toggle(competition.id),
              icon: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: isFavorite ? AppColors.yellow : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

`lib/features/home/widgets/competition_section.dart` :

```dart
import 'package:flutter/material.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/features/home/widgets/competition_row.dart';

/// Une carte blanche titrée (« À venir », « Terminées récemment »).
class CompetitionSection extends StatelessWidget {
  const CompetitionSection({
    super.key,
    required this.title,
    required this.competitions,
    this.action,
  });

  final String title;
  final List<CompetitionSummary> competitions;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                ),
                if (action != null) action!,
              ],
            ),
          ),
          for (final (index, competition) in competitions.indexed) ...[
            if (index > 0)
              const Divider(height: 1, color: AppColors.border),
            CompetitionRow(competition: competition),
          ],
        ],
      ),
    );
  }
}
```

- [ ] **Étape 2 : écrire la carte et le carrousel « EN DIRECT »**

`lib/features/home/widgets/live_card.dart` :

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/core/router/app_router.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/domain/now_running.dart';
import 'package:live_ffss_v2/features/home/competition_formatting.dart';
import 'package:live_ffss_v2/features/home/now_running_provider.dart';
import 'package:live_ffss_v2/features/shell/open_competition.dart';

class LiveCard extends ConsumerWidget {
  const LiveCard({super.key, required this.competition});

  final CompetitionSummary competition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final today = ref.watch(clockProvider)();
    final day = competition.dayOfCompetition(today);
    // En échec, la ligne disparaît simplement : la carte reste utile sans elle.
    final now = ref.watch(nowRunningProvider(competition.id)).value;
    final place = [
      if (competition.location case final location?) location,
      competition.dateRangeLabel(locale),
    ].join(' · ');

    return Material(
      color: AppColors.navy,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openCompetition(context, ref, competition),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: Text(
                        '● ${l10n.liveBadge}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      [
                        competition.disciplineLabel(l10n),
                        if (day != null) l10n.dayOfTotal(day.current, day.total),
                      ].join(' · '),
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                competition.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                place,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
              if (now != null) ...[
                const Spacer(),
                _NowRunningTile(competition: competition, now: now),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NowRunningTile extends ConsumerWidget {
  const _NowRunningTile({required this.competition, required this.now});

  final CompetitionSummary competition;
  final NowRunning now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: AppColors.navyRaised,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () =>
            openCompetition(context, ref, competition, route: Routes.live),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      now.kind == NowRunningKind.now
                          ? l10n.nowRunning
                          : l10n.nextUp,
                      style: const TextStyle(
                        color: AppColors.yellow,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      heatLine(now, l10n),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
```

`lib/features/home/widgets/live_carousel.dart` :

```dart
import 'package:flutter/material.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/features/home/widgets/live_card.dart';

/// Les compétitions en direct, une carte par page. La carte voisine dépasse
/// au bord de l'écran pour montrer qu'on peut glisser.
class LiveCarousel extends StatefulWidget {
  const LiveCarousel({super.key, required this.competitions});

  final List<CompetitionSummary> competitions;

  @override
  State<LiveCarousel> createState() => _LiveCarouselState();
}

class _LiveCarouselState extends State<LiveCarousel> {
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _controllerFor(widget.competitions.length);
  }

  @override
  void didUpdateWidget(LiveCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasSingle = oldWidget.competitions.length <= 1;
    final isSingle = widget.competitions.length <= 1;
    if (wasSingle != isSingle) {
      _controller.dispose();
      _controller = _controllerFor(widget.competitions.length);
    }
  }

  PageController _controllerFor(int count) =>
      PageController(viewportFraction: count > 1 ? 0.92 : 1);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final multiple = widget.competitions.length > 1;
    return SizedBox(
      height: 250,
      child: PageView.builder(
        controller: _controller,
        padEnds: false,
        itemCount: widget.competitions.length,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.only(right: multiple ? 12 : 0),
          child: LiveCard(competition: widget.competitions[index]),
        ),
      ),
    );
  }
}
```

- [ ] **Étape 3 : écrire l'accueil**

Remplacer `lib/features/home/home_page.dart` par :

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/router/app_router.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/features/home/home_providers.dart';
import 'package:live_ffss_v2/features/home/home_view.dart';
import 'package:live_ffss_v2/features/home/widgets/competition_section.dart';
import 'package:live_ffss_v2/features/home/widgets/filter_bar.dart';
import 'package:live_ffss_v2/features/home/widgets/home_header.dart';
import 'package:live_ffss_v2/features/home/widgets/live_carousel.dart';
import 'package:live_ffss_v2/features/home/widgets/search_entry.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    ref.listen(homeCompetitionsProvider, (previous, next) {
      // Un rafraîchissement en échec garde la liste : on le dit sans la vider.
      if (next.hasError && next.hasValue && !next.isLoading) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.refreshFailed)));
      }
    });
    final competitions = ref.watch(homeCompetitionsProvider);
    final view = ref.watch(homeViewProvider);

    final Widget body;
    if (view != null) {
      body = RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: _HomeContent(view: view),
      );
    } else if (competitions.hasError) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.loadError, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(homeCompetitionsProvider),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    } else {
      body = const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Column(
        children: [
          const HomeHeader(),
          Expanded(child: body),
        ],
      ),
    );
  }

  Future<void> _refresh(WidgetRef ref) async {
    try {
      await ref.refresh(homeCompetitionsProvider.future);
    } on AppException {
      // Signalé par le `ref.listen` de build, qui garde la liste affichée.
    }
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.view});

  final HomeView view;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      // Toujours défilable : sans cela, le geste de rafraîchissement ne
      // part pas sur un accueil plus court que l'écran.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, 16 + MediaQuery.of(context).viewPadding.bottom),
      children: [
        const SearchEntry(),
        const SizedBox(height: 12),
        const FilterBar(),
        const SizedBox(height: 16),
        if (view.live.isNotEmpty) ...[
          LiveCarousel(competitions: view.live),
          const SizedBox(height: 16),
        ],
        if (view.upcomingCount > 0) ...[
          CompetitionSection(
            title: l10n.upcoming,
            competitions: view.upcoming,
            action: TextButton(
              onPressed: () => context.go(Routes.allCompetitions),
              child: Text(
                l10n.seeAll,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: AppColors.blue),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (view.recent.isNotEmpty)
          CompetitionSection(
            title: l10n.recentlyFinished,
            competitions: view.recent,
          ),
        if (view.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 48),
            child: Text(
              l10n.noCompetition,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
      ],
    );
  }
}
```

- [ ] **Étape 4 : écrire l'écran « Tout voir »**

Remplacer `lib/features/home/all_competitions_page.dart` par :

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/features/home/favorites.dart';
import 'package:live_ffss_v2/features/home/home_providers.dart';
import 'package:live_ffss_v2/features/home/home_view.dart';
import 'package:live_ffss_v2/features/home/search_provider.dart';
import 'package:live_ffss_v2/features/home/widgets/competition_row.dart';
import 'package:live_ffss_v2/features/home/widgets/filter_bar.dart';

/// La liste complète. Sans recherche : les compétitions de l'accueil, par
/// date de début. Avec au moins [searchMinLength] caractères : la recherche
/// de l'API. Le filtre de l'accueil s'applique dans les deux cas.
class AllCompetitionsPage extends ConsumerStatefulWidget {
  const AllCompetitionsPage({super.key});

  @override
  ConsumerState<AllCompetitionsPage> createState() =>
      _AllCompetitionsPageState();
}

class _AllCompetitionsPageState extends ConsumerState<AllCompetitionsPage> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = _query.text.trim();
    final searching = text.length >= searchMinLength;
    final AsyncValue<List<CompetitionSummary>> source = searching
        ? ref.watch(searchResultsProvider(text))
        : ref.watch(homeCompetitionsProvider).whenData(
              (list) => [...list]
                ..sort((a, b) => a.startDate.compareTo(b.startDate)),
            );
    final filter = ref.watch(homeFilterProvider);
    final favorites = ref.watch(favoritesProvider).value ?? const <int>{};

    return Scaffold(
      appBar: AppBar(title: Text(l10n.allCompetitions)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _query,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(_query.clear),
                      ),
                filled: true,
                fillColor: AppColors.surface,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: FilterBar(),
          ),
          Expanded(
            child: switch (source) {
              AsyncValue(:final value?) => _Results(
                  competitions: [
                    for (final c in value)
                      if (matchesFilter(c, filter, favorites)) c,
                  ],
                ),
              AsyncValue(hasError: true) => Center(child: Text(l10n.loadError)),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ],
      ),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.competitions});

  final List<CompetitionSummary> competitions;

  @override
  Widget build(BuildContext context) {
    if (competitions.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context).noCompetition,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.only(
          top: 8, bottom: 16 + MediaQuery.of(context).viewPadding.bottom),
      itemCount: competitions.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: AppColors.border),
      itemBuilder: (context, index) =>
          CompetitionRow(competition: competitions[index]),
    );
  }
}
```

- [ ] **Étape 5 : vérifier et lancer**

Run : `dart format lib test && flutter analyze && flutter test`
Expected : `No issues found!`, `All tests passed!`

Run : `flutter run -d chrome` (si aucun navigateur n'est disponible, noter que la vérification visuelle revient à l'utilisateur).

Vérifier sur les vraies données de production :
1. L'accueil se charge : « À venir » (5 au plus) et, s'il y en a, le carrousel « EN DIRECT » et « Terminées récemment ».
2. Les filtres Eau plate, Côtier et Mes favoris changent les trois groupes.
3. L'étoile ajoute et retire un favori ; le favori reste après un rechargement de la page.
4. Toucher une compétition ouvre l'onglet Programme, avec son nom en en-tête.
5. « Tout voir » montre la liste ; taper « france » lance une recherche.
6. Tirer vers le bas recharge l'accueil.
7. Dans les outils de développement du navigateur, onglet réseau : `competition/evenement` part une fois au chargement de l'accueil ; `competition/:id/reunion` repart toutes les 30 s par compétition en direct, et plus du tout une fois sur l'onglet Programme.

- [ ] **Étape 6 : commiter**

```bash
git add -A . && git commit -m "feat(v2): écran d'accueil et écran « Tout voir »"
```

---

### Tâche 14 : `CLAUDE.md` de la v2 et vérification finale

**Files :**
- Create : `live_ffss.v2/CLAUDE.md`

- [ ] **Étape 1 : écrire `CLAUDE.md`**

`live_ffss.v2/CLAUDE.md` :

```markdown
# CLAUDE.md — LiveFFSS v2

Règles et conventions de la v2 de l'application mobile. Référence pour les sessions Claude futures.

## Contexte

- **Réécriture** de l'application mobile, sur le modèle de `FFSS-Competition.V3` dans le dépôt FFSSCompetition. La v1 (`../live_ffss/`, épreuves côtières, testée en live) est **gelée** au tag `v1-cotier-final` : on y puise, on ne la modifie pas.
- **Le code utile de la v1 est copié, jamais importé.** La v2 ne dépend pas de la v1.
- **Le seul lien avec FFSSCompetition (le bureau) est l'API FFSS.** Le bureau publie programme, séries et résultats ; le mobile les lit.
- **On reprend FFSSCompetition V3** : noms de classes et d'attributs, règles de calcul, décisions. Le domaine mobile est un sous-ensemble du domaine V3 (`FFSS-Competition.V3.Core/Domain`), limité à ce que l'API transporte. Le dossier `Core/Ffss` de V3 est la référence de la correspondance entre l'API et le domaine.
- Specs : `docs/specs/`. Plans : `docs/plans/`. Lots : voir la spec du lot 1, § 2.

## Architecture

`features` → `data` → `domain`, dans ce sens uniquement.

- **`lib/domain/`** : classes pures (freezed, sans JSON), nommées comme V3 : `CompetitionSummary`, `Discipline`, `Gender`, `Meeting`, `MeetingItem`, `Heat`, `RunStatus`. Les calculs purs y vivent (`partitionHome`, `nowRunning`) et se testent sans simulation.
- **`lib/data/ffss/`** : DTO freezed de l'API (noms français mappés par `@JsonKey`, tout nullable) et mappers `extension XMapper on XDto { X? toDomain() }`. Un mapper **écarte** une ligne inutilisable (renvoie `null`) au lieu de faire échouer la liste. `readInt` (nombre servi en chaîne) et `readMap` (objet vide servi en `[]` par PHP) sont dans `dtos/json_readers.dart`.
- **`lib/data/repositories/`** : `XRepository` abstrait + `XRepositoryImpl(HttpClient)` + `xRepositoryProvider`. Pagination et conversion ici. **Pas de couche datasource.**
- **`lib/features/<fonction>/`** : fournisseurs Riverpod, fonctions pures de présentation (`home_view.dart`), extensions de formatage (`competition_formatting.dart`), pages et `widgets/`.
- **`lib/core/`** : `config/` (environnements, endpoints), `errors/` (`AppException`), `network/` (`HttpClient`, `TokenStorage`), `storage/` (`LocalStore`), `providers.dart` (fournisseurs du cœur, dont `clockProvider`), `theme/`, `l10n/`, `router/`.

## État et navigation

- **Riverpod 3.** Fournisseurs déclarés à la main (pas de `riverpod_generator`). Les tests créent `ProviderContainer(overrides: [...], retry: (_, __) => null)` : sans `retry`, Riverpod 3 relance un fournisseur en échec et le test attend.
- **`clockProvider`** donne l'heure : ne jamais appeler `DateTime.now()` dans un fournisseur ou une page.
- **go_router 17**, `StatefulShellRoute.indexedStack` : une branche par onglet. Les routes sont dans `Routes` (`core/router/app_router.dart`).
- **Compétition active** : `activeCompetitionProvider` (id persisté, résumé en mémoire) ; `currentCompetitionProvider` en déduit la compétition des onglets. On ouvre une compétition avec `openCompetition(...)`.

## Règles

- Analyseur : `strict-casts`, `strict-raw-types`. Pas de `dynamic` implicite, pas de `fromJson` écrit à la main.
- Pas de test de widget. On teste le domaine, les mappers, les repositories et les fournisseurs (mocktail, `fake_async` pour les minuteries).
- Une page ne contient pas de logique testable : elle la prend à une fonction pure ou à un fournisseur.
- Traductions : `lib/core/l10n/app_fr.arb` fait référence, `app_en.arb` a exactement les mêmes clés, sans clé morte. Après modification : `flutter gen-l10n`.
- « Eau plate » partout en français, jamais « Piscine ».
- Le dernier élément d'un écran ne passe jamais sous la barre de navigation du téléphone : ajouter `MediaQuery.of(context).viewPadding.bottom` au bas d'une liste défilante.
- Les commentaires disent pourquoi, jamais ce que fait la ligne suivante.
- Erreurs : on attrape `AppException`, jamais `Exception` brut.

## API FFSS

- Surface : `../docs/FFSS_API.md`. Faits vérifiés (qui l'emportent sur la doc) : `../docs/FFSS_API_CONTRACT.md`. Les lire avant d'ajouter un appel.
- Au lot 1, l'app ne parle **qu'à la production**, debug compris ; le choix de l'environnement arrive au lot 4.
- `type=3` sur `competition/evenement` rend les trois spécialités.
- `MeetingRepository` lit les courses **dans la réponse `reunion`**, sans appeler `creneau/:id/course` (cassée depuis le 2026-08-31). À revoir si la route est réparée et que les courses portées par `reunion` s'avèrent tronquées.

## Lacunes connues

- Une compétition ouverte depuis la recherche et absente de l'accueil est oubliée au redémarrage (seul l'id est enregistré) : les onglets retombent sur le choix par défaut. Le lot 2 la relira par `GET competition/evenement/:id`.
- Le paramètre `saison` n'est pas envoyé (la doc le dit désactivé). À vérifier au journal réseau si la liste de l'accueil semble incomplète.

## Commandes

Depuis `live_ffss.v2/` :

    flutter test
    flutter analyze
    dart format lib test
    dart run build_runner build --delete-conflicting-outputs
    flutter gen-l10n
    flutter run -d chrome

Outils : Flutter 3.41.9 / Dart 3.11.5 (voir la section Tooling pins du CLAUDE.md v1). Les fichiers générés (`.freezed.dart`, `.g.dart`, `lib/core/l10n/gen/`) sont commités.
```

- [ ] **Étape 2 : vérification finale**

Depuis `live_ffss.v2/` :
Run : `dart format --output=none --set-exit-if-changed lib test && flutter analyze && flutter test`
Expected : aucun fichier à reformater, `No issues found!`, `All tests passed!`

Depuis `live_ffss/` (la v1 doit rester au vert) :
Run : `flutter analyze && flutter test`
Expected : `No issues found!`, `All tests passed!`

- [ ] **Étape 3 : commiter**

```bash
git add CLAUDE.md && git commit -m "docs(v2): CLAUDE.md de la v2"
```
