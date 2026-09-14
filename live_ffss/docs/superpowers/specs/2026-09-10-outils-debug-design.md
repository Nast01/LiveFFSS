# Outils de l'écran de debug : session, stockage, réseau

Date : 2026-09-10
Branche : `dev_prod_environnement_debug`
Précédent : `2026-09-10-environnement-debug-design.md`, qui a créé l'écran que ce
spec étoffe.

## Problème

L'écran de debug ne sait faire qu'une chose : changer d'endpoint. Trois
difficultés récurrentes du dépôt n'ont aujourd'hui aucun outil.

**On ne sait pas si le jeton est vivant.** Un jeton FFSS meurt bien avant la date
d'`expiration` que `requestToken` renvoie. La fédération ne répond jamais 401 :
une lecture portant un jeton mort est servie anonymement en 200, et seule une
écriture révèle le problème, par un `403 Invalid token` — après que l'opérateur a
fait le travail. L'application porte déjà la sonde qui tranche
(`AuthRepositoryImpl._isStillSignedIn`), mais elle est privée, muette, et ne
tourne qu'au démarrage.

**On ne voit pas ce que le téléphone stocke.** Six clés du secure storage sont
désormais préfixées par environnement, deux sont globales. Rien ne permet de le
constater, ni de savoir ce qu'une clé contient. La seule action offerte est
« Effacer les données locales », qui prend tout.

**On ne voit pas passer les requêtes.** FFSS renvoie des `success: false` sous un
HTTP 200, des `true` nus sur les suppressions, et des accents mal encodés si l'on
lit `response.body` au lieu des octets. Ces trois-là ne se diagnostiquent qu'en
voyant l'enveloppe brute, que rien n'expose.

## Objectif

Trois outils sur l'écran de debug : un diagnostic de session, un inspecteur du
stockage local, un journal des requêtes HTTP. Comme l'écran qui les héberge,
aucun n'existe hors build debug.

## Décisions

| Question | Décision |
|---|---|
| Profondeur de l'inspecteur | Clés **et** valeurs, copie universelle, sans masquage |
| Export du programme local | Absorbé par l'inspecteur — un programme est une clé comme une autre |
| Rétention du journal HTTP | Éteint par défaut, activable, interrupteur persisté |
| Structure de l'écran | Sommaire, avec une sous-page par outil volumineux |

L'export du programme n'est pas une fonctionnalité distincte : dès lors que
l'inspecteur affiche et copie la valeur d'une clé, copier `programme_412` **est**
l'export. Un mécanisme au lieu de deux.

Le journal éteint par défaut plutôt que toujours actif : c'est le choix de
l'utilisateur, motivé par le coût d'un tampon permanent. Sa contrepartie est
qu'il faut avoir pensé à l'allumer — d'où l'interrupteur persisté, sans lequel un
bug qui demande de relancer l'application ferait perdre l'activation au pire
moment.

## Architecture

### Diagnostic de session

`AuthRepositoryImpl._isStillSignedIn()` fait déjà le bon appel : `GET /me` avec
un timeout de 4 s, puis vérification que le type est `licencie` ou `organisme`.
Il est privé et ne renvoie qu'un booléen.

Un modèle le remplace, `lib/app/domain/models/session_probe.dart`, freezed :

```dart
enum SessionProbeOutcome { signedIn, anonymous, unreachable }

@freezed
class SessionProbe with _$SessionProbe {
  const factory SessionProbe({
    required SessionProbeOutcome outcome,
    String? label,
    UserType? type,
    String? message,
  }) = _SessionProbe;
}
```

Pas d'arm `unknown` : l'énumération n'est pas décodée d'une réponse API, elle est
construite par l'application. La règle de forward-compat de CLAUDE.md ne
s'applique qu'aux énumérations qui viennent du serveur.

L'interface `AuthRepository` gagne `Future<SessionProbe> probeSession()`, et
`_isStillSignedIn()` devient une ligne :

```dart
Future<bool> _isStillSignedIn() async =>
    (await probeSession()).outcome != SessionProbeOutcome.anonymous;
```

Cette équivalence est exacte, et c'est le point délicat du lot. La méthode
actuelle renvoie `true` sur `AppException` **et** sur `TimeoutException` — « être
hors ligne ne prouve rien », dit son commentaire, et la seule chose qui met fin à
une session est un « vous n'êtes personne » explicite. La correspondance est
donc :

| Ce que fait `getCurrentUser()` | `outcome` | Session gardée ? |
|---|---|---|
| répond, type `licencie` ou `organisme` | `signedIn` | oui |
| répond, tout autre type | `anonymous` | **non** |
| lève `AppException` | `unreachable` | oui |
| dépasse les 4 s | `unreachable` | oui |

Seul `anonymous` met fin à la session, avant comme après. Le commentaire long qui
documente ce raisonnement suit la logique et vit désormais sur `probeSession()`.

La carte affiche trois lignes : présence d'un jeton, date d'expiration
**annoncée** par FFSS (lue sur `UserService.currentUser`), et le résultat de la
sonde. Les deux dernières se contredisent souvent — c'est exactement le piège que
l'outil sert à voir.

### Inspecteur de stockage

Route `/debug/storage`, avec son binding, son contrôleur et sa vue.

`FlutterSecureStorage.readAll()`, puis groupement par `AppEnvironment.owner(key)`
en trois sections, dans cet ordre : environnement courant, autre environnement,
clés globales. Chaque entrée porte sa clé, sa valeur et sa taille en octets ; les
entrées d'une section sont triées par clé.

Deux actions par entrée :

- **Copier** — met la **chaîne brute** dans le presse-papier, pour qu'elle puisse
  être ré-injectée ou jointe à un rapport telle quelle. `Clipboard` vient de
  `flutter/services`, aucune dépendance à ajouter.
- **Supprimer** — sous confirmation portée par la vue, nommant la clé.

La valeur affichée, elle, est **ré-indentée** si elle parse en JSON. C'est ce qui
rend un blob `programme_412` lisible, et c'est la seule différence entre ce qu'on
voit et ce qu'on copie.

Un avertissement figure en tête de l'écran, parce qu'il n'est pas devinable :
**l'inspecteur écrit sur le disque, pas dans les objets vivants**. Supprimer
`favorite_competitions` ne vide pas le `RxSet` que `UserPreferencesService` tient
en mémoire ; il faut un redémarrage, ou une bascule d'environnement, pour que les
services le constatent.

Aucune clé n'est protégée contre la suppression, y compris `api_environment` et
`token`. C'est un outil de debug : la confirmation nomme la clé, cela suffit.

### Journal HTTP

`lib/app/core/network/http_log.dart`. Le tampon vit **hors de GetX**, comme
`activeEnvironment` et pour la même raison : une bascule d'environnement détruit
le conteneur d'injection, et un journal qui s'effacerait au moment précis où l'on
change de backend n'aurait aucun intérêt.

```dart
class HttpLogEntry {
  final DateTime at;
  final String method;
  final String url;
  final int? statusCode;
  final int durationMs;
  final String? requestBody;
  final String? responseBody;
  final String? error;
}

class HttpLog {
  static const int capacity = 50;
  static const int bodyLimit = 8192;

  bool enabled = false;
  List<HttpLogEntry> get entries; // vue non modifiable, plus récentes d'abord

  void record(HttpLogEntry entry);
  void clear();
}

final HttpLog httpLog = HttpLog();
```

`record` ne fait rien si `enabled` est faux ou hors `kDebugMode`. Les corps sont
tronqués à `bodyLimit` caractères chacun, ce qui borne le tampon à environ
800 Ko dans le pire cas.

`HttpLog` n'expose **aucun objet réactif** — ni `ValueNotifier`, ni `Rx`. Il est
lu à la demande : le contrôleur en prend un instantané à l'ouverture de l'écran
et sur son bouton « rafraîchir ». Faire cohabiter un second système réactif à
côté de celui de GetX coûterait plus cher que ce que gagnerait une liste qui se
met à jour toute seule, sur un écran qu'on ne regarde pas pendant que les
requêtes partent. `activeEnvironment` reste le seul `ValueNotifier` du dépôt,
et il l'est pour une raison qui ne vaut pas ici : survivre à `Get.deleteAll`
tout en repeignant un widget monté au-dessus du `Navigator`.

`HttpClient._send` l'alimente : il mesure la durée autour de l'appel, et
enregistre aussi bien la réponse obtenue que l'échec levé — une `SocketException`
ou un `ApiException` est précisément ce qu'on veut voir. Les corps de requête des
`POST` sont journalisés au même titre que les réponses : un payload
`course/submit` refusé est inutile sans ce qui a été envoyé.

L'interrupteur est persisté sous une **troisième clé globale**,
`debug_http_log`, exposée par `AppEnvironment.httpLogKey` et ajoutée à
`AppEnvironment.globalKeys` — faute de quoi l'effacement scopé de
`ProgrammeService.clearEverything()` l'attribuerait à la production et
l'emporterait. `InitialBinding` la relit au démarrage, sous `kDebugMode`
uniquement, et positionne `httpLog.enabled` ; `HttpLogController` la réécrit à
chaque bascule de l'interrupteur, via le `FlutterSecureStorage` que son binding
lui injecte.

Conséquence assumée, cohérente avec le choix d'un inspecteur sans masquage :
**l'URL journalisée porte le jeton en clair**, puisqu'il voyage en query string.
Le même jeton est déjà lisible dans l'inspecteur ; le masquer ici ne protégerait
rien.

Route `/debug/http`. La liste montre, par entrée, méthode, chemin, statut et
durée, colorés selon l'issue ; une entrée dépliée montre l'URL complète, le corps
de requête et le corps de réponse, chacun copiable. La barre d'actions porte
l'interrupteur et le bouton qui vide le journal.

### Structure de l'écran

`/debug` devient un sommaire :

1. la carte « environnement actif » et les boutons radio de bascule, inchangés ;
2. la carte « session » et son bouton de sonde ;
3. deux entrées vers `/debug/storage` et `/debug/http`.

Les deux nouvelles routes sont déclarées sous `kDebugMode`, comme les deux
existantes, et l'exception à la règle de reachability déjà inscrite dans
CLAUDE.md les couvre sans modification.

Les textes restent en dur, en français, non traduits, pour la raison déjà
retenue : l'écran ne part jamais en release, et les deux fichiers de traduction
sont tenus symétriques et sans clé morte.

## Tests

`mocktail`, pas de test de widget, pas de test d'intégration.

| Cible | Ce qui est vérifié |
|---|---|
| `AuthRepository.probeSession` | les quatre lignes du tableau de correspondance ci-dessus |
| `AuthRepository.restoreSession` | comportement inchangé — les tests existants doivent passer sans retouche |
| `HttpLog` | plafond à 50, ordre le plus récent d'abord, troncature à 8 Ko, `clear`, et silence total quand `enabled` est faux |
| `HttpClient` | enregistre une requête réussie et un échec quand le journal est actif ; n'enregistre rien quand il est éteint |
| `StorageInspectorController` | groupement en trois sections, tri par clé, tailles, suppression déléguée au storage puis rechargement |
| `HttpLogController` | bascule de l'interrupteur, vidage, ordre des entrées exposées |
| `DebugController` | états de la sonde : au repos, en cours, résultat |

Les vues et le presse-papier ne sont pas testés : widgets et plugin de
plateforme, hors périmètre de test du dépôt.

## Fichiers

**Créés**

- `lib/app/domain/models/session_probe.dart` (+ `.freezed.dart`)
- `lib/app/core/network/http_log.dart`
- `lib/app/module/debug/bindings/storage_inspector_binding.dart`
- `lib/app/module/debug/controllers/storage_inspector_controller.dart`
- `lib/app/module/debug/views/storage_inspector_view.dart`
- `lib/app/module/debug/bindings/http_log_binding.dart`
- `lib/app/module/debug/controllers/http_log_controller.dart`
- `lib/app/module/debug/views/http_log_view.dart`
- `test/core/network/http_log_test.dart`
- `test/presentation/modules/debug/controllers/storage_inspector_controller_test.dart`
- `test/presentation/modules/debug/controllers/http_log_controller_test.dart`

**Modifiés**

- `lib/app/data/repositories/auth_repository.dart` — `probeSession` sur
  l'interface, `_isStillSignedIn` réduit à une ligne
- `lib/app/core/network/http_client.dart` — alimentation du journal
- `lib/app/core/config/app_environment.dart` — clé globale `debug_http_log`
- `lib/app/core/di/initial_binding.dart` — relecture de l'interrupteur en debug
- `lib/app/module/debug/controllers/debug_controller.dart` — état de la sonde
- `lib/app/module/debug/views/debug_view.dart` — carte session, deux entrées
- `lib/app/routes/app_pages.dart` et `app_routes.dart` — deux routes
- `test/data/repositories/auth_repository_test.dart` — les cas de `probeSession`
- `test/presentation/modules/debug/controllers/debug_controller_test.dart` — les
  états de la sonde
- `CLAUDE.md` — les trois outils, la troisième clé globale

## Hors périmètre

- **Masquage du jeton**, écarté explicitement : incohérent avec un inspecteur qui
  montre tout, et sans effet protecteur puisque la même valeur est lisible à deux
  endroits.
- **Rejeu d'une requête depuis le journal.** Séduisant, mais rejouer une écriture
  sur la production depuis un écran de debug est précisément le genre de bouton
  qu'on finit par regretter.
- **Édition d'une valeur dans l'inspecteur.** Lire, copier et supprimer
  couvrent les besoins ; écrire un blob à la main invite à corrompre un programme
  plus sûrement qu'à le réparer.
- **Version et numéro de build**, qui demanderaient `package_info_plus` — une
  dépendance nouvelle, ce que CLAUDE.md n'accepte pas sans justification.
- **Sonde des routes FFSS cassées** et **déclencheur d'expiration de session**,
  proposés puis non retenus dans ce lot.
