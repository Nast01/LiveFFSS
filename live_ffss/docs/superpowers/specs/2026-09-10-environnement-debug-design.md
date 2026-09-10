# Sélecteur d'environnement API en mode debug

Date : 2026-09-10
Branche : `dev_prod_environnement_debug`

## Problème

L'application ne connaît qu'un seul backend, figé à la compilation :
`AppConfig.production()` porte `baseUrl = 'https://ffss.fr'` et
`apiVersion = 'api/v1.0'`, et `AppConfig.fromEnv()` renvoie cette même valeur
quelle que soit la valeur de `--dart-define=ENV`. Tester une modification
contre l'environnement de développement fédéral impose donc de recompiler.

Deux endpoints existent :

| Environnement | Endpoint |
|---|---|
| production | `https://ffss.fr/api/v1.0/` |
| développement | `https://site.ffss.io/api/v1.0/` |

## Objectif

En build debug, pouvoir choisir l'endpoint dans un écran dédié, et voir sur
toutes les pages quand l'endpoint de développement est actif. En build release,
ni l'écran ni le marqueur n'existent, et l'endpoint est la production.

## Ce qui rend l'exercice non trivial

Ce n'est pas un changement d'URL. Deux contraintes structurent tout le reste.

**La configuration est capturée une fois.** `AppConfig` est un `const` injecté
dans `HttpClient` à la construction, dans `InitialBinding.register()`. Rien ne
relit l'URL après le démarrage.

**L'état persisté est indexé sur des ids FFSS.** Le token, le profil, les
favoris, les derniers consultés, le programme local et les présences sont
stockés sous des identifiants de compétition qui ne désignent pas la même chose
d'un environnement à l'autre. Un favori d'id 1234 pris en production
pointerait, côté développement, sur une compétition sans rapport ; et un token
de production est refusé côté développement, ce que l'application affiche
aujourd'hui non pas comme une déconnexion mais comme une écriture qui échoue.

## Décisions

| Question | Décision |
|---|---|
| État local à la bascule | Cloisonné par environnement : la production garde ses clés actuelles, le développement les préfixe |
| Accès au sélecteur | Route `/debug` dédiée, avec son binding et son contrôleur |
| Marqueur visuel | Ruban d'angle `Banner`, à l'identique de `debugShowCheckedModeBanner` |
| Application de la bascule | Redémarrage à froid de la DI |
| Environnement par défaut | Développement en debug, production partout ailleurs |

Le cloisonnement plutôt que la purge : perdre un tirage de production parce
qu'on est allé jeter un œil au développement serait un prix disproportionné
pour un outil de confort.

Le redémarrage à froid plutôt qu'une configuration réactive : rendre l'URL et
les clés de stockage relues à chaud demanderait de doter chaque service d'un
`reload()` correct et de les appeler dans le bon ordre — quatre chemins de code
qui n'existeraient que pour le debug, et dont un oubli se traduirait par les
données d'un environnement affichées sous l'autre. Le redémarrage réutilise le
chemin de démarrage nominal, déjà exercé à chaque lancement. Il coûte la
position dans la navigation.

## Architecture

### Le modèle d'environnement

`lib/app/core/config/app_environment.dart` — un enum qui porte ses données :

| | `production` | `development` |
|---|---|---|
| `baseUrl` | `https://ffss.fr` | `https://site.ffss.io` |
| `apiVersion` | `api/v1.0` | `api/v1.0` |
| `storagePrefix` | `''` | `'dev_'` |
| `label` | `Production` | `Développement` |

`AppConfig` gagne un champ `environment` et une fabrique
`AppConfig.forEnvironment(env)`. Son constructeur générique reste en place,
donc les tests qui construisent un `AppConfig` à la main ne changent pas.

La résolution est une fonction pure, testable sans toucher à `kDebugMode` :

```dart
static AppEnvironment resolve({
  required bool isDebug,
  AppEnvironment? stored,
  String? dartDefine,
})
```

1. `!isDebug` → `production`, sans condition. Un choix « développement » resté
   dans le storage n'a aucun effet dans une build release.
2. `stored != null` → le choix mémorisé. Il l'emporte sur le `--dart-define`,
   parce qu'il est postérieur et explicite.
3. `dartDefine` reconnu → celui-là. Une chaîne non reconnue tombe en 4 plutôt
   que de lever : un `--dart-define` mal orthographié ne doit pas empêcher
   l'application de démarrer.
4. sinon → `development`.

`AppConfig.fromEnv()` reste le seul appelant et lui passe `kDebugMode`.

### Persistance du choix

`EnvironmentStorage` (`lib/app/core/config/`), une seule clé
`'api_environment'`, **jamais préfixée** : c'est elle qui détermine le préfixe,
elle ne peut pas vivre à l'intérieur. Une valeur inconnue est lue comme `null`
et laisse la résolution suivre son cours.

C'est une classe d'instance qui prend `FlutterSecureStorage` au constructeur,
comme le reste du dépôt, et elle est enregistrée dans `InitialBinding` juste
après le storage et juste avant `AppConfig`. `AppRestart` la récupère par
`Get.find`, à l'étape 1, donc avant le `deleteAll` qui la désenregistre.

Cela impose de déplacer `FlutterSecureStorage` **avant** `AppConfig` dans
`InitialBinding` : la configuration dépend désormais du storage. L'ordre
documenté passe de `1. AppConfig / 2. Storage` à `1. Storage / 2. AppConfig`.

### Cloisonnement du stockage

Six clés portent des données propres à un backend et sont préfixées :

| Clé | Propriétaire |
|---|---|
| `token` | `TokenStorage` |
| `user` | `AuthRepositoryImpl` |
| `favorite_competitions` | `UserPreferencesService` |
| `last_viewed_competitions` | `UserPreferencesService` |
| `race_attendance` | `AttendanceService` |
| `programme_<id>` | `ProgrammeService` |

Deux clés restent globales : `language`, une préférence d'interface qui ne
vient pas du serveur, et `api_environment` elle-même.

Mécanique : un paramètre nommé `keyPrefix` de **défaut `''`** sur les cinq
classes concernées ; `InitialBinding` passe `config.environment.storagePrefix`.
Le préfixe de production étant vide, les données déjà présentes sur les
téléphones sont intactes, aucune migration n'est nécessaire, et aucun test
existant ne change.

### Effacement scopé

`ProgrammeService.clearEverything()` appelle aujourd'hui `_storage.deleteAll()`.
Avec deux environnements dans le même storage, cet appel détruirait aussi les
données de l'autre environnement, la langue et le choix d'endpoint lui-même.

Une règle de propriété unique et testée le remplace :

```dart
static AppEnvironment? owner(String key)
```

- `language` et `api_environment` → `null`, personne ne les possède ;
- une clé commençant par `dev_` → `development` ;
- toute autre clé → `production`.

`clearEverything()` passe de `deleteAll()` à un `readAll()` suivi de la
suppression des seules clés dont l'environnement courant est propriétaire. En
production le comportement observable est identique à aujourd'hui, à ceci près
que la langue et le choix d'endpoint survivent.

### La bascule

`AppRestart.switchTo(env)` dans `lib/app/core/di/` — hors contrôleur, au même
titre que `_wireSessionExpirationHandler` qui navigue déjà depuis là :

```
1. EnvironmentStorage.save(env)
2. Get.offAllNamed(Routes.restarting)
3. Get.deleteAll(force: true)
4. InitialBinding.register()
5. Get.offAllNamed(Routes.home)
```

L'étape 2 a une raison précise. Entre le `deleteAll` et le `register`, aucune
vue vivante ne doit exécuter un `Get.find` : un `GetView` qui se reconstruirait
dans cette fenêtre lèverait. `/restarting` est une page sans binding et sans
contrôleur, ce qui rend la fenêtre vide par construction plutôt que par chance.

C'est la **vue** qui appelle `AppRestart.switchTo`, après sa confirmation, et
non le contrôleur : l'étape 3 détruit le `DebugController`, et une méthode ne
survit pas à sa propre destruction.

### Le ruban

`DevEnvironmentBanner` (`lib/app/presentation/shared/`), branché une seule fois
dans le `builder:` de `GetMaterialApp`. Il rend son `child` tel quel si
`!kDebugMode` ou si l'environnement est la production ; sinon il l'enveloppe
dans un `Banner` Flutter — `message: 'DEV'`, `location: BannerLocation.topEnd`,
couleur `AppColors.statusWaiting`, l'orange déjà présent au thème.

C'est le mécanisme exact de `debugShowCheckedModeBanner`. Comme le `builder`
enveloppe le `Navigator`, le ruban reste au-dessus des routes, des dialogues et
des bottom sheets sans qu'aucune vue ait à le savoir. Aucune réactivité n'est
nécessaire : la bascule reconstruit toute l'application.

Le ruban est décoratif et peut recouvrir une action d'AppBar située dans le
coin haut-droit — c'est déjà le cas du ruban de debug de Flutter, et c'est
accepté.

### L'écran de debug

Module `lib/app/module/debug/` : `DebugBinding`, `DebugController`,
`DebugView`, sur la route `/debug`, atteinte par une icône dans l'AppBar du
Profil à côté de `LanguageSelector`.

Le `GetPage` **et** l'entrée d'AppBar sont sous `if (kDebugMode)`. En release la
route n'est pas cachée, elle n'est pas déclarée : `Get.toNamed('/debug')` ne
mènerait nulle part.

L'écran affiche l'environnement courant, l'URL réellement construite, le
préfixe de stockage actif, et les deux environnements en boutons radio. Une
confirmation précède la bascule, avec l'avertissement qui compte : *tu
repartiras sur la session et le programme local de cet environnement-là —
probablement aucun la première fois*.

Ses textes sont écrits en dur en français, non traduits, avec un commentaire
qui le justifie : l'écran ne part jamais en release, et les deux fichiers de
traduction sont tenus symétriques et sans clé morte.

Le `DebugController` respecte la discipline du dépôt : pas de `Get.context!`,
pas de `Get.snackbar`, pas de `Get.dialog`, pas de `.tr`. La confirmation et
l'appel à `AppRestart` appartiennent à la vue.

## Tests

Conventions du dépôt : `mocktail`, pas de test de widget, pas de test
d'intégration.

| Cible | Ce qui est vérifié |
|---|---|
| `AppEnvironment.resolve` | les quatre branches, dont « stored = development mais `isDebug: false` → production » |
| `AppEnvironment.owner` | les deux préfixes et les deux clés globales |
| `EnvironmentStorage` | aller-retour, et valeur inconnue lue comme `null` |
| Préfixage | une assertion par service : `write(key: 'dev_favorite_competitions', …)` |
| `clearEverything()` | ne supprime que les clés de l'environnement courant, épargne `language` et `api_environment` |
| `HttpClient` | construction d'URL sous la configuration de développement |
| `DebugController` | environnement courant, URL effective, liste des choix |

`AppRestart` et `DevEnvironmentBanner` ne sont pas testés : navigation et
widget, hors périmètre de test du dépôt.

## Fichiers

**Créés**

- `lib/app/core/config/app_environment.dart`
- `lib/app/core/config/environment_storage.dart`
- `lib/app/core/di/app_restart.dart`
- `lib/app/presentation/shared/dev_banner.dart`
- `lib/app/module/debug/bindings/debug_binding.dart`
- `lib/app/module/debug/controllers/debug_controller.dart`
- `lib/app/module/debug/views/debug_view.dart`
- `lib/app/module/debug/views/restarting_view.dart`
- `test/core/config/app_environment_test.dart`
- `test/core/config/environment_storage_test.dart`
- `test/presentation/modules/debug/controllers/debug_controller_test.dart`

**Modifiés**

- `lib/app/core/config/app_config.dart` — champ `environment`, `forEnvironment`, `fromEnv` déléguant à `resolve`
- `lib/app/core/di/initial_binding.dart` — storage avant config, propagation du préfixe
- `lib/app/core/network/token_storage.dart` — `keyPrefix`
- `lib/app/data/repositories/auth_repository.dart` — `keyPrefix`
- `lib/app/data/services/user_preferences_service.dart` — `keyPrefix`
- `lib/app/data/services/programme_service.dart` — `keyPrefix`, effacement scopé
- `lib/app/data/services/attendance_service.dart` — `keyPrefix`
- `lib/main.dart` — `DevEnvironmentBanner` dans le `builder:`
- `lib/app/routes/app_pages.dart` et `app_routes.dart` — `/debug` et `/restarting`
- `lib/app/module/auth/views/profile_view.dart` — entrée vers `/debug`
- `CLAUDE.md` — ordre de DI, module `debug`, section environnements

## Hors périmètre

- Un troisième environnement. L'enum en accepterait un sans changement de
  structure, mais rien ne le demande.
- Une migration des clés de production vers un préfixe `prod_`. Le préfixe vide
  est ce qui rend l'opération sans risque pour les téléphones déjà déployés.
- Le partage de session entre environnements, qui n'a pas de sens : les tokens
  ne sont pas interchangeables.
- Un indicateur d'environnement en release. Par construction, une build release
  n'a qu'un environnement.
