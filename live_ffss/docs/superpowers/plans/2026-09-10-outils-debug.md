# Outils de l'écran de debug — plan d'implémentation

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ajouter trois outils à l'écran de debug — un diagnostic de session, un inspecteur du stockage local, un journal des requêtes HTTP — tous invisibles hors build debug.

**Architecture :** La sonde `/me` déjà privée dans `AuthRepositoryImpl` est exposée derrière un modèle `SessionProbe`, en préservant à l'identique sa règle de décision. Le journal HTTP est un tampon circulaire vivant hors de GetX, alimenté depuis l'unique point de passage `HttpClient._send`, éteint par défaut et dont l'interrupteur est persisté. L'inspecteur de stockage lit `readAll()` et regroupe par `AppEnvironment.owner()`. Les deux outils volumineux prennent chacun leur route, leur binding et leur contrôleur.

**Tech Stack :** Flutter 3.41.9 / Dart 3.11.5, GetX, `flutter_secure_storage`, freezed, `mocktail`. `Clipboard` vient de `flutter/services` — aucune dépendance nouvelle.

**Spec :** `docs/superpowers/specs/2026-09-10-outils-debug-design.md`

## Global Constraints

- **Discipline contrôleur** (CLAUDE.md) : pas de `Get.context!`, `Get.snackbar`, `Get.dialog`, `.tr`, ni paramètre `BuildContext` dans un contrôleur. Injection par constructeur uniquement, jamais de `Get.find()` dans le corps d'un contrôleur. Les dialogues de confirmation appartiennent à la vue.
- **Analyzer strict** : `strict-casts: true`, `strict-raw-types: true`. Aucune coercition `dynamic`, aucun `analyzer.errors.X: ignore`. Aucune API dépréciée — `flutter analyze` doit finir sur « No issues found! ».
- **Tests** : `mocktail`, `class _MockX extends Mock implements X {}` (jamais `extends Fake`). **Aucun test de widget, aucun test d'intégration.**
- **Aucune dépendance nouvelle.**
- **Textes en dur, en français, non traduits** dans tout le module `debug` : l'écran ne part jamais en release, et les deux fichiers de traduction sont tenus symétriques et sans clé morte. N'ajoute aucune clé dans `lib/app/core/translations/`.
- **Tout le module `debug` est sous `kDebugMode`** : les `GetPage` ne sont pas déclarées en release, pas seulement cachées.
- **Codegen** : après création ou modification d'un fichier freezed, `dart run build_runner build --delete-conflicting-outputs`. Les `.freezed.dart` sont commités avec la source.
- **Commentaires** : uniquement là où le *pourquoi* n'est pas évident. Jamais de paraphrase de la ligne suivante.
- **Commandes** en formes courtes : `flutter test`, `flutter analyze`, `dart format`, `dart run build_runner build`.
- **Message de commit** terminé par : `Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>`
- `macos/Flutter/GeneratedPluginRegistrant.swift` apparaît modifié dans l'arbre (normalisation CRLF, diff vide). Hors périmètre : ne pas le commiter.

---

### Task 1: `SessionProbe` et `probeSession`

Le point délicat du lot. `AuthRepositoryImpl._isStillSignedIn()` décide aujourd'hui si une session survit au démarrage ; il est réduit à une ligne au-dessus de la nouvelle méthode publique, et cette réduction doit préserver son comportement **exactement**.

**Files:**
- Create: `lib/app/domain/models/session_probe.dart`
- Modify: `lib/app/data/repositories/auth_repository.dart`
- Test: `test/data/repositories/auth_repository_test.dart`

**Interfaces:**
- Consumes : `UserType` (de `lib/app/domain/models/user.dart`), `AppException` (de `lib/app/core/errors/app_exception.dart`, champ `String message`).
- Produces :
  - `enum SessionProbeOutcome { signedIn, anonymous, unreachable }`
  - `class SessionProbe` (freezed) : `SessionProbeOutcome outcome`, `String? label`, `UserType? type`, `String? message`
  - `Future<SessionProbe> probeSession()` sur l'interface `AuthRepository`

**La règle à préserver.** La méthode actuelle renvoie `true` sur `AppException` **et** sur `TimeoutException` — son commentaire dit pourquoi : « être hors ligne ne prouve rien », seul un « vous n'êtes personne » explicite met fin à une session. La correspondance est donc :

| Ce que fait `getCurrentUser()` | `outcome` | Session gardée ? |
|---|---|---|
| répond, type `licencie` ou `organisme` | `signedIn` | oui |
| répond, tout autre type | `anonymous` | **non** |
| lève `AppException` | `unreachable` | oui |
| dépasse les 4 s | `unreachable` | oui |

- [ ] **Step 1: Écrire les tests qui échouent**

Ajouter dans `test/data/repositories/auth_repository_test.dart` les imports `package:live_ffss/app/domain/models/session_probe.dart` et `dart:async`, puis à la racine de `main()` — en réutilisant les mocks `ds`, `tokens`, `secure` et le `repo` déjà montés dans le `setUp` du fichier :

```dart
  group('AuthRepository.probeSession', () {
    test('un compte licencie est une session vivante', () async {
      when(() => ds.getCurrentUser()).thenAnswer((_) async => const UserDto(
            label: 'Doe John',
            type: 'licencie',
            data: UserDtoData(role: 'user', lastName: 'Doe', firstName: 'John'),
          ));

      final probe = await repo.probeSession();

      expect(probe.outcome, SessionProbeOutcome.signedIn);
      expect(probe.label, 'Doe John');
    });

    test('un organisme est une session vivante', () async {
      when(() => ds.getCurrentUser()).thenAnswer((_) async => const UserDto(
            label: 'SNS 42',
            type: 'organisme',
            data: UserDtoData(role: 'admin'),
          ));

      final probe = await repo.probeSession();

      expect(probe.outcome, SessionProbeOutcome.signedIn);
    });

    test('tout autre type est l\'identite anonyme', () async {
      when(() => ds.getCurrentUser()).thenAnswer((_) async => const UserDto(
            label: 'Utilisateur Anonyme',
            type: 'anonyme',
            data: UserDtoData(role: 'user'),
          ));

      final probe = await repo.probeSession();

      expect(probe.outcome, SessionProbeOutcome.anonymous);
      expect(probe.label, 'Utilisateur Anonyme');
    });

    test('une erreur API laisse la session indeterminee, pas morte', () async {
      when(() => ds.getCurrentUser())
          .thenThrow(const NetworkException('hors ligne'));

      final probe = await repo.probeSession();

      expect(probe.outcome, SessionProbeOutcome.unreachable);
      expect(probe.message, 'hors ligne');
    });

    test('un timeout laisse la session indeterminee, pas morte', () async {
      when(() => ds.getCurrentUser()).thenThrow(TimeoutException('trop long'));

      final probe = await repo.probeSession();

      expect(probe.outcome, SessionProbeOutcome.unreachable);
    });
  });
```

Si le fichier n'importe pas déjà `NetworkException`, ajouter
`package:live_ffss/app/core/errors/app_exception.dart`. Si les champs requis de `UserDto` diffèrent de ce qui est écrit ci-dessus, **calquer sur les instanciations déjà présentes dans le fichier** plutôt que d'inventer.

- [ ] **Step 2: Lancer les tests et vérifier qu'ils échouent**

Run : `flutter test test/data/repositories/auth_repository_test.dart`
Expected : échec de compilation, `The method 'probeSession' isn't defined for the type 'AuthRepository'`.

- [ ] **Step 3: Créer le modèle**

Créer `lib/app/domain/models/session_probe.dart` :

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/user.dart';

part 'session_probe.freezed.dart';

/// Ce que le serveur répond quand on lui demande qui nous sommes.
///
/// Pas d'arm `unknown` : cette énumération n'est pas décodée d'une réponse API,
/// elle est construite par l'application à partir de ce qu'elle observe. La
/// règle de forward-compat du dépôt ne vise que les énumérations qui viennent
/// du serveur.
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

Pas de `part '*.g.dart'` et pas de `// ignore_for_file: invalid_annotation_target` : ce modèle n'est jamais sérialisé et ne porte aucun `@JsonKey`.

- [ ] **Step 4: Générer le code**

Run : `dart run build_runner build --delete-conflicting-outputs`
Expected : `session_probe.freezed.dart` créé. Si la commande échoue sur `frontend_server.dart.snapshot not found`, relancer `flutter --version` pour repeupler le cache du SDK — ce n'est pas un bug du code.

- [ ] **Step 5: Exposer la sonde**

Dans `lib/app/data/repositories/auth_repository.dart`, ajouter l'import du modèle, puis la méthode à l'interface :

```dart
abstract class AuthRepository {
  Future<User> login({required String login, required String password});
  Future<void> logout();
  Future<User?> restoreSession();
  Future<SessionProbe> probeSession();
  Stream<User?> get userStream;
}
```

Dans `AuthRepositoryImpl`, **remplacer** la méthode `_isStillSignedIn()` et son long commentaire par ceci — le commentaire déménage sur la méthode publique, il ne disparaît pas :

```dart
  /// Asks the server who we are, because the stored expiration date does not
  /// say: a token issued with `expiration: "2026-08-30"` was already dead hours
  /// later. FFSS never reports that on a read either — it serves an anonymous
  /// 200 — so the app would keep a session that ended and only find out when a
  /// write came back refused, after the operator had done the work.
  ///
  /// A real account is a licencie or an organisme; anything else is the
  /// anonymous identity. The cost of that reading is that a type FFSS may add
  /// later would force a needless sign-in until the mapper learns it — a
  /// nuisance, where the opposite default silently keeps dead sessions alive.
  ///
  /// Anything other than a clear "you are nobody" keeps the session: being
  /// offline proves nothing, and the timeout is there so a socket that never
  /// answers cannot hold up application start.
  @override
  Future<SessionProbe> probeSession() async {
    try {
      final me = await _dataSource
          .getCurrentUser()
          .timeout(const Duration(seconds: 4));
      final user = me.toDomain(token: '', tokenExpiration: DateTime.now());
      final signedIn =
          user.type == UserType.licensee || user.type == UserType.organisme;
      return SessionProbe(
        outcome: signedIn
            ? SessionProbeOutcome.signedIn
            : SessionProbeOutcome.anonymous,
        label: user.label,
        type: user.type,
      );
    } on AppException catch (e) {
      return SessionProbe(
        outcome: SessionProbeOutcome.unreachable,
        message: e.message,
      );
    } on TimeoutException catch (e) {
      return SessionProbe(
        outcome: SessionProbeOutcome.unreachable,
        message: e.message ?? 'Pas de réponse en 4 s',
      );
    }
  }

  /// Seul un « vous n'êtes personne » explicite met fin à la session — voir
  /// [probeSession].
  Future<bool> _isStillSignedIn() async =>
      (await probeSession()).outcome != SessionProbeOutcome.anonymous;
```

`restoreSession()` n'est pas modifiée : elle continue d'appeler `_isStillSignedIn()`.

- [ ] **Step 6: Lancer la suite complète**

Run : `flutter test`
Expected : PASS. **Les tests préexistants de `restoreSession` doivent passer sans retouche** — c'est la preuve que l'équivalence est respectée. Si l'un d'eux échoue, ne l'ajuste pas : la réduction a changé le comportement, corrige l'implémentation.

Run : `flutter analyze`
Expected : `No issues found!`

- [ ] **Step 7: Commit**

```bash
git add lib/app/domain/models/session_probe.dart lib/app/domain/models/session_probe.freezed.dart lib/app/data/repositories/auth_repository.dart test/data/repositories/auth_repository_test.dart
git commit -m "feat(auth): exposer la sonde de session derriere SessionProbe"
```

---

### Task 2: Le tampon `HttpLog`

**Files:**
- Create: `lib/app/core/network/http_log.dart`
- Test: `test/core/network/http_log_test.dart`

**Interfaces:**
- Consumes : rien.
- Produces :
  - `class HttpLogEntry` — constructeur nommé `const HttpLogEntry({required DateTime at, required String method, required String url, required int durationMs, int? statusCode, String? requestBody, String? responseBody, String? error})`
  - `class HttpLog` — `static const int capacity = 50`, `static const int bodyLimit = 8192`, `bool enabled`, `List<HttpLogEntry> get entries`, `void record(HttpLogEntry)`, `void clear()`, `static String? truncate(String?)`
  - `final HttpLog httpLog` — l'instance globale

- [ ] **Step 1: Écrire le test qui échoue**

Créer `test/core/network/http_log_test.dart` :

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/network/http_log.dart';

HttpLogEntry _entry(String url) => HttpLogEntry(
      at: DateTime(2026, 9, 10),
      method: 'GET',
      url: url,
      durationMs: 12,
      statusCode: 200,
    );

void main() {
  setUp(() {
    httpLog
      ..clear()
      ..enabled = false;
  });

  group('HttpLog.record', () {
    test('n\'enregistre rien tant que le journal est eteint', () {
      httpLog.record(_entry('a'));

      expect(httpLog.entries, isEmpty);
    });

    test('enregistre les entrees les plus recentes en premier', () {
      httpLog.enabled = true;

      httpLog.record(_entry('a'));
      httpLog.record(_entry('b'));

      expect(httpLog.entries.map((e) => e.url).toList(), ['b', 'a']);
    });

    test('plafonne a 50 entrees en laissant tomber les plus anciennes', () {
      httpLog.enabled = true;

      for (var i = 0; i < 51; i++) {
        httpLog.record(_entry('url-$i'));
      }

      expect(httpLog.entries.length, HttpLog.capacity);
      expect(httpLog.entries.first.url, 'url-50');
      expect(httpLog.entries.last.url, 'url-1');
    });

    test('la liste exposee n\'est pas modifiable', () {
      httpLog.enabled = true;
      httpLog.record(_entry('a'));

      expect(() => httpLog.entries.add(_entry('b')), throwsUnsupportedError);
    });
  });

  group('HttpLog.truncate', () {
    test('laisse un corps court intact', () {
      expect(HttpLog.truncate('court'), 'court');
    });

    test('rend null pour un corps absent', () {
      expect(HttpLog.truncate(null), isNull);
    });

    test('tronque un corps trop long en le disant', () {
      final long = 'x' * (HttpLog.bodyLimit + 10);

      final result = HttpLog.truncate(long)!;

      expect(result.length, lessThan(long.length));
      expect(result, startsWith('x' * 100));
      expect(result, contains('tronqué'));
    });
  });

  group('HttpLog.clear', () {
    test('vide le journal', () {
      httpLog.enabled = true;
      httpLog.record(_entry('a'));

      httpLog.clear();

      expect(httpLog.entries, isEmpty);
    });
  });
}
```

- [ ] **Step 2: Lancer le test et vérifier qu'il échoue**

Run : `flutter test test/core/network/http_log_test.dart`
Expected : échec de compilation, `Target of URI doesn't exist: '.../http_log.dart'`.

- [ ] **Step 3: Écrire l'implémentation**

Créer `lib/app/core/network/http_log.dart` :

```dart
import 'package:flutter/foundation.dart';

/// Une requête telle qu'elle est passée, avec ce qu'il faut pour comprendre
/// après coup ce que FFSS a répondu.
@immutable
class HttpLogEntry {
  const HttpLogEntry({
    required this.at,
    required this.method,
    required this.url,
    required this.durationMs,
    this.statusCode,
    this.requestBody,
    this.responseBody,
    this.error,
  });

  final DateTime at;
  final String method;
  final String url;
  final int durationMs;
  final int? statusCode;
  final String? requestBody;
  final String? responseBody;

  /// Renseigné quand la requête n'a pas abouti — coupure réseau, timeout.
  final String? error;
}

/// Tampon circulaire des dernières requêtes, tenu **hors de GetX**.
///
/// Hors du conteneur d'injection pour la même raison qu'`activeEnvironment` :
/// une bascule d'environnement le détruit, et un journal qui s'effacerait au
/// moment précis où l'on change de backend n'aurait aucun intérêt.
///
/// Éteint par défaut : rien n'est capturé tant que [enabled] est faux, et rien
/// ne l'est jamais hors build debug.
///
/// N'expose aucun objet réactif : le contrôleur en prend un instantané à
/// l'ouverture de l'écran et sur son bouton « rafraîchir ». Un second système
/// réactif à côté de celui de GetX coûterait plus que ce que gagnerait une
/// liste qui s'anime seule, sur un écran qu'on ne regarde pas pendant que les
/// requêtes partent.
class HttpLog {
  static const int capacity = 50;
  static const int bodyLimit = 8192;

  bool enabled = false;

  final List<HttpLogEntry> _entries = [];

  /// Les plus récentes d'abord.
  List<HttpLogEntry> get entries => List.unmodifiable(_entries);

  void record(HttpLogEntry entry) {
    if (!kDebugMode || !enabled) return;
    _entries.insert(0, entry);
    if (_entries.length > capacity) {
      _entries.removeRange(capacity, _entries.length);
    }
  }

  void clear() => _entries.clear();

  /// Borne un corps à [bodyLimit] caractères, en disant qu'il a été coupé —
  /// sans quoi on lirait une réponse tronquée en la croyant complète.
  static String? truncate(String? body) {
    if (body == null) return null;
    if (body.length <= bodyLimit) return body;
    return '${body.substring(0, bodyLimit)}\n'
        '… tronqué (${body.length} caractères au total)';
  }
}

final HttpLog httpLog = HttpLog();
```

- [ ] **Step 4: Lancer le test et vérifier qu'il passe**

Run : `flutter test test/core/network/http_log_test.dart`
Expected : PASS, 8 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/app/core/network/http_log.dart test/core/network/http_log_test.dart
git commit -m "feat(network): tampon circulaire des requetes, eteint par defaut"
```

---

### Task 3: `HttpClient` alimente le journal

`_send` est aujourd'hui appelée avec une closure qui construit elle-même son URI. Pour journaliser il faut connaître la méthode, l'URI et le corps envoyé, donc la closure change de forme. C'est le seul remaniement de code de production de ce plan.

**Files:**
- Modify: `lib/app/core/network/http_client.dart`
- Test: `test/core/network/http_client_test.dart`

**Interfaces:**
- Consumes : `httpLog`, `HttpLogEntry`, `HttpLog.truncate` (Task 2).
- Produces : rien de nouveau — `get` et `post` gardent leur signature publique.

- [ ] **Step 1: Écrire les tests qui échouent**

Ajouter dans `test/core/network/http_client_test.dart` l'import `package:live_ffss/app/core/network/http_log.dart`, puis à la racine de `main()`, en réutilisant le harnais de mocks du fichier.

Les tests ci-dessous nomment `httpMock` le mock de `http.Client`, `tokens` celui de `TokenStorage`, et `client` l'instance d'`HttpClient` sous test. Les deux premiers sont ceux du fichier ; **ouvre-le et vérifie le troisième**, puis aligne-toi sur ce qu'il utilise réellement. Ne monte pas un second harnais à côté de celui qui existe.

```dart
  group('journal HTTP', () {
    setUp(() {
      httpLog
        ..clear()
        ..enabled = false;
    });

    tearDown(() {
      httpLog
        ..clear()
        ..enabled = false;
    });

    test('n\'enregistre rien quand le journal est eteint', () async {
      when(() => tokens.getToken()).thenAnswer((_) async => null);
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('{"success":true}', 200));

      await client.get('competition/evenement');

      expect(httpLog.entries, isEmpty);
    });

    test('enregistre une requete reussie quand il est actif', () async {
      httpLog.enabled = true;
      when(() => tokens.getToken()).thenAnswer((_) async => null);
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('{"success":true}', 200));

      await client.get('competition/evenement');

      expect(httpLog.entries.length, 1);
      final entry = httpLog.entries.single;
      expect(entry.method, 'GET');
      expect(entry.url, contains('competition/evenement'));
      expect(entry.statusCode, 200);
      expect(entry.responseBody, '{"success":true}');
    });

    test('enregistre une reponse en erreur, une seule fois', () async {
      httpLog.enabled = true;
      when(() => tokens.getToken()).thenAnswer((_) async => null);
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('{"message":"boom"}', 500));

      await expectLater(
        client.get('competition/evenement'),
        throwsA(isA<ApiException>()),
      );

      expect(httpLog.entries.length, 1);
      expect(httpLog.entries.single.statusCode, 500);
    });

    test('enregistre une coupure reseau', () async {
      httpLog.enabled = true;
      when(() => tokens.getToken()).thenAnswer((_) async => null);
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenThrow(const SocketException('pas de route'));

      await expectLater(
        client.get('competition/evenement'),
        throwsA(isA<NetworkException>()),
      );

      expect(httpLog.entries.single.error, contains('pas de route'));
      expect(httpLog.entries.single.statusCode, isNull);
    });
  });
```

Si `dart:io` n'est pas importé dans le fichier de test, l'ajouter pour `SocketException`.

- [ ] **Step 2: Lancer les tests et vérifier qu'ils échouent**

Run : `flutter test test/core/network/http_client_test.dart`
Expected : les quatre nouveaux tests échouent (`httpLog.entries` vide, ou `length` valant 0 au lieu de 1). Les 43 tests préexistants passent.

- [ ] **Step 3: Remanier `get`, `post` et `_send`**

Dans `lib/app/core/network/http_client.dart`, ajouter l'import `package:live_ffss/app/core/network/http_log.dart`, puis remplacer `get`, `post` et `_send` par :

```dart
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) =>
      _send(
        method: 'GET',
        path: path,
        query: query,
        send: (uri, headers) => _inner.get(uri, headers: headers),
      );

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? query,
    Object? body,
  }) =>
      _send(
        method: 'POST',
        path: path,
        query: query,
        body: body,
        send: (uri, headers) => _inner.post(
          uri,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        ),
      );

  /// Reads the token here rather than in [get] and [post] so a failing
  /// TokenStorage is caught by the same mapping as a failing request, and so
  /// the decoder can say whether the call went out authenticated.
  Future<Map<String, dynamic>> _send({
    required String method,
    required String path,
    required Future<http.Response> Function(Uri uri, Map<String, String> headers)
        send,
    Map<String, dynamic>? query,
    Object? body,
  }) async {
    final started = DateTime.now();
    Uri? uri;
    try {
      final token = await _tokenStorage.getToken();
      uri = _buildUri(path, query, token);
      final response = await send(uri, _buildHeaders(token));
      _record(started, method, uri, body, response: response);
      return _decode(response,
          authenticated: token != null && token.isNotEmpty);
    } on AppException {
      // Déjà journalisée : l'entrée écrite juste avant `_decode` porte le
      // statut et le corps qui expliquent le refus. La ré-enregistrer ici en
      // ferait un doublon.
      rethrow;
    } on SocketException catch (e) {
      _record(started, method, uri, body, error: e.message);
      throw NetworkException(e.message);
    } on TimeoutException catch (e) {
      final message = e.message ?? 'Request timed out';
      _record(started, method, uri, body, error: message);
      throw NetworkException(message);
    } catch (e) {
      _record(started, method, uri, body, error: e.toString());
      throw UnknownException(e.toString());
    }
  }

  /// Le corps est décodé en UTF-8 comme dans [_decode] : un journal qui
  /// afficherait des accents mangés ne servirait justement pas à diagnostiquer
  /// le bug d'encodage qu'il est là pour montrer.
  ///
  /// Sort avant tout travail quand le journal est éteint — c'est ce qui rend
  /// son coût nul par défaut.
  void _record(
    DateTime started,
    String method,
    Uri? uri,
    Object? requestBody, {
    http.Response? response,
    String? error,
  }) {
    if (!httpLog.enabled) return;
    httpLog.record(HttpLogEntry(
      at: started,
      method: method,
      url: uri?.toString() ?? '(URI non construite)',
      durationMs: DateTime.now().difference(started).inMilliseconds,
      statusCode: response?.statusCode,
      requestBody: HttpLog.truncate(
        requestBody == null ? null : jsonEncode(requestBody),
      ),
      responseBody: response == null
          ? null
          : HttpLog.truncate(
              utf8.decode(response.bodyBytes, allowMalformed: true),
            ),
      error: error,
    ));
  }
```

Le reste du fichier — `_buildUri`, `_buildHeaders`, `_decode`, `_notifyAuthFailure`, `_extractMessage`, `onAuthFailure` — ne change pas d'une ligne, commentaires compris.

- [ ] **Step 4: Lancer les tests**

Run : `flutter test test/core/network/http_client_test.dart`
Expected : PASS, les 43 préexistants **et** les 4 nouveaux. Si un test préexistant casse, c'est le remaniement de `get`/`post` qui a changé un comportement observable : corrige l'implémentation, pas le test.

- [ ] **Step 5: Commit**

```bash
git add lib/app/core/network/http_client.dart test/core/network/http_client_test.dart
git commit -m "feat(network): alimenter le journal depuis HttpClient"
```

---

### Task 4: L'interrupteur persisté

**Files:**
- Modify: `lib/app/core/config/app_environment.dart`
- Modify: `lib/app/core/di/initial_binding.dart`
- Test: `test/core/config/app_environment_test.dart`

**Interfaces:**
- Consumes : `httpLog` (Task 2).
- Produces : `AppEnvironment.httpLogKey` (vaut `'debug_http_log'`), ajoutée à `AppEnvironment.globalKeys`.

- [ ] **Step 1: Écrire le test qui échoue**

Ajouter dans le `group('AppEnvironment.owner', ...)` de `test/core/config/app_environment_test.dart` :

```dart
    test('l\'interrupteur du journal HTTP est une cle globale', () {
      expect(AppEnvironment.owner('debug_http_log'), isNull);
      expect(AppEnvironment.httpLogKey, 'debug_http_log');
      expect(AppEnvironment.globalKeys, contains('debug_http_log'));
    });
```

- [ ] **Step 2: Lancer le test et vérifier qu'il échoue**

Run : `flutter test test/core/config/app_environment_test.dart`
Expected : échec de compilation, `The getter 'httpLogKey' isn't defined`.

- [ ] **Step 3: Ajouter la clé**

Dans `lib/app/core/config/app_environment.dart`, sous `environmentKey` :

```dart
  /// L'interrupteur du journal HTTP de debug. Globale comme les deux autres :
  /// rangée dans un environnement, l'effacement scopé de `clearEverything()`
  /// l'attribuerait à la production et l'emporterait au premier nettoyage.
  static const String httpLogKey = 'debug_http_log';

  /// Clés qui n'appartiennent à aucun environnement : elles survivent à une
  /// bascule comme à un effacement scopé. `language` est une préférence
  /// d'interface, elle ne vient pas du serveur.
  static const Set<String> globalKeys = {
    'language',
    environmentKey,
    httpLogKey,
  };
```

- [ ] **Step 4: Relire l'interrupteur au démarrage**

Dans `lib/app/core/di/initial_binding.dart`, ajouter l'import `package:live_ffss/app/core/network/http_log.dart`, puis juste après la ligne `activeEnvironment.value = environment;` :

```dart
    // Restaure l'interrupteur du journal HTTP. Sans persistance, reproduire un
    // bug qui demande de relancer l'application ferait perdre l'activation au
    // pire moment.
    if (kDebugMode) {
      httpLog.enabled = await Get.find<FlutterSecureStorage>()
              .read(key: AppEnvironment.httpLogKey) ==
          'true';
    }
```

`kDebugMode` et `AppEnvironment` doivent être importés dans ce fichier — `kDebugMode` l'est déjà via `package:flutter/foundation.dart` ; vérifie que `app_environment.dart` l'est aussi et ajoute l'import s'il manque.

- [ ] **Step 5: Vérifier**

Run : `flutter test`
Expected : PASS, suite complète.

Run : `flutter analyze`
Expected : `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add lib/app/core/config/app_environment.dart lib/app/core/di/initial_binding.dart test/core/config/app_environment_test.dart
git commit -m "feat(debug): persister l'interrupteur du journal HTTP"
```

---

### Task 5: La carte « session » sur l'écran de debug

**Files:**
- Modify: `lib/app/module/debug/controllers/debug_controller.dart`
- Modify: `lib/app/module/debug/bindings/debug_binding.dart`
- Modify: `lib/app/module/debug/views/debug_view.dart`
- Test: `test/presentation/modules/debug/controllers/debug_controller_test.dart`

**Interfaces:**
- Consumes : `SessionProbe`, `SessionProbeOutcome`, `AuthRepository.probeSession()` (Task 1).
- Produces : sur `DebugController` — `RxBool isProbing`, `Rxn<SessionProbe> probe`, `RxnString token`, `DateTime? get announcedExpiration`, `Future<void> runProbe()`, `Future<void> loadToken()`.

- [ ] **Step 1: Écrire les tests qui échouent**

Dans `test/presentation/modules/debug/controllers/debug_controller_test.dart`, ajouter les imports `package:get/get.dart`, `package:mocktail/mocktail.dart`, `package:live_ffss/app/core/network/token_storage.dart`, `package:live_ffss/app/data/repositories/auth_repository.dart`, `package:live_ffss/app/data/services/user_service.dart`, `package:live_ffss/app/domain/models/session_probe.dart` et `package:live_ffss/app/domain/models/user.dart`, puis à la racine de `main()` :

```dart
class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockUserService extends Mock implements UserService {}

class _MockTokenStorage extends Mock implements TokenStorage {}
```

puis :

```dart
  group('DebugController — session', () {
    late _MockAuthRepository auth;
    late _MockUserService userService;
    late _MockTokenStorage tokenStorage;
    late DebugController controller;

    setUp(() {
      auth = _MockAuthRepository();
      userService = _MockUserService();
      tokenStorage = _MockTokenStorage();
      controller = DebugController(
        const AppConfig.production(),
        auth,
        userService,
        tokenStorage,
      );
    });

    test('la sonde part au repos', () {
      expect(controller.isProbing.value, isFalse);
      expect(controller.probe.value, isNull);
    });

    test('runProbe stocke le resultat et retombe au repos', () async {
      when(() => auth.probeSession()).thenAnswer(
        (_) async => const SessionProbe(
          outcome: SessionProbeOutcome.anonymous,
          label: 'Utilisateur Anonyme',
        ),
      );

      await controller.runProbe();

      expect(controller.probe.value?.outcome, SessionProbeOutcome.anonymous);
      expect(controller.isProbing.value, isFalse);
    });

    test('loadToken lit le jeton du stockage', () async {
      when(() => tokenStorage.getToken()).thenAnswer((_) async => 'abc123');

      await controller.loadToken();

      expect(controller.token.value, 'abc123');
    });

    test('l\'expiration annoncee vient du profil en memoire', () {
      final user = User(
        token: 'abc',
        tokenExpiration: DateTime.utc(2030),
        label: 'Doe John',
        type: UserType.licensee,
        role: UserRole.user,
      );
      when(() => userService.currentUser).thenReturn(Rx<User?>(user));

      expect(controller.announcedExpiration, DateTime.utc(2030));
    });
  });
```

Si `User` exige d'autres champs, calquer sur une instanciation déjà présente ailleurs dans `test/` plutôt que d'inventer.

- [ ] **Step 2: Lancer les tests et vérifier qu'ils échouent**

Run : `flutter test test/presentation/modules/debug/`
Expected : échec de compilation, `Too many positional arguments: 1 expected, but 4 found`.

- [ ] **Step 3: Étendre le contrôleur**

Remplacer `lib/app/module/debug/controllers/debug_controller.dart` par :

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/core/config/app_config.dart';
import 'package:live_ffss/app/core/config/app_environment.dart';
import 'package:live_ffss/app/core/network/token_storage.dart';
import 'package:live_ffss/app/data/repositories/auth_repository.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import 'package:live_ffss/app/domain/models/session_probe.dart';

/// L'état de l'écran de debug. La bascule d'environnement, elle, détruit ce
/// contrôleur : elle appartient à la vue.
class DebugController extends GetxController {
  DebugController(
    this._config,
    this._auth,
    this._userService,
    this._tokenStorage,
  );

  final AppConfig _config;
  final AuthRepository _auth;
  final UserService _userService;
  final TokenStorage _tokenStorage;

  final RxBool isProbing = false.obs;
  final Rxn<SessionProbe> probe = Rxn<SessionProbe>();
  final RxnString token = RxnString();

  AppEnvironment get current => _config.environment;

  List<AppEnvironment> get environments => AppEnvironment.values;

  String get endpoint => _config.environment.endpoint;

  String get storagePrefixLabel {
    final prefix = _config.environment.storagePrefix;
    return prefix.isEmpty ? 'aucun' : prefix;
  }

  /// La date que FFSS a annoncée à la connexion. Elle ne dit pas si le jeton
  /// est encore vivant — c'est tout l'objet de [runProbe].
  DateTime? get announcedExpiration =>
      _userService.currentUser.value?.tokenExpiration;

  @override
  void onInit() {
    super.onInit();
    loadToken();
  }

  Future<void> loadToken() async => token.value = await _tokenStorage.getToken();

  /// [AuthRepository.probeSession] ne lève pas : elle traduit ses échecs en
  /// `unreachable`.
  Future<void> runProbe() async {
    isProbing.value = true;
    try {
      probe.value = await _auth.probeSession();
    } finally {
      isProbing.value = false;
    }
  }
}
```

Et `lib/app/module/debug/bindings/debug_binding.dart` :

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/core/config/app_config.dart';
import 'package:live_ffss/app/core/network/token_storage.dart';
import 'package:live_ffss/app/data/repositories/auth_repository.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import 'package:live_ffss/app/module/debug/controllers/debug_controller.dart';

class DebugBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DebugController>(
      () => DebugController(
        Get.find<AppConfig>(),
        Get.find<AuthRepository>(),
        Get.find<UserService>(),
        Get.find<TokenStorage>(),
      ),
    );
  }
}
```

- [ ] **Step 4: Lancer les tests et vérifier qu'ils passent**

Run : `flutter test test/presentation/modules/debug/`
Expected : PASS. Les 4 tests préexistants du `DebugController` doivent passer après ajout des arguments au constructeur dans leur `setUp` — c'est la seule retouche autorisée sur eux.

- [ ] **Step 5: Ajouter la carte à la vue**

Dans `lib/app/module/debug/views/debug_view.dart`, ajouter les imports de `session_probe.dart` et de `app_colors.dart` (déjà présent), puis insérer, entre la carte « Environnement actif » et le titre « Changer d'environnement » :

```dart
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Session',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Obx(() => _row(
                        'Jeton',
                        controller.token.value == null
                            ? 'absent'
                            : 'présent (${controller.token.value!.length} caractères)',
                      )),
                  Obx(() => _row(
                        'Expiration annoncée',
                        controller.announcedExpiration?.toIso8601String() ??
                            'inconnue',
                      )),
                  const SizedBox(height: 8),
                  Obx(() {
                    final probe = controller.probe.value;
                    if (probe == null) return const SizedBox.shrink();
                    return _row('État réel', _probeLabel(probe));
                  }),
                  const SizedBox(height: 8),
                  Obx(() => OutlinedButton.icon(
                        onPressed: controller.isProbing.value
                            ? null
                            : controller.runProbe,
                        icon: controller.isProbing.value
                            ? const LoadingIndicator(compact: true, size: 16)
                            : const Icon(Icons.network_ping, size: 18),
                        label: const Text('Tester la session'),
                      )),
                ],
              ),
            ),
          ),
```

et ajouter, à côté de `_confirmSwitch` en bas du fichier :

```dart
/// Ce que la sonde a constaté, dit en clair — l'écart entre cette ligne et
/// l'expiration annoncée est précisément ce que l'écran sert à voir.
String _probeLabel(SessionProbe probe) => switch (probe.outcome) {
      SessionProbeOutcome.signedIn => 'session vivante — ${probe.label}',
      SessionProbeOutcome.anonymous =>
        'jeton mort — FFSS répond « ${probe.label} »',
      SessionProbeOutcome.unreachable =>
        'indéterminé — ${probe.message ?? 'serveur injoignable'}',
    };
```

Importer `package:live_ffss/app/presentation/shared/loading_indicator.dart` pour le spinner compact — c'est la forme prévue pour un slot de bouton, ne pas hand-roller un `CircularProgressIndicator`.

- [ ] **Step 6: Vérifier**

Run : `flutter analyze`
Expected : `No issues found!`

Run : `flutter test`
Expected : PASS, suite complète.

- [ ] **Step 7: Commit**

```bash
git add lib/app/module/debug test/presentation/modules/debug
git commit -m "feat(debug): carte de diagnostic de session"
```

---

### Task 6: L'inspecteur de stockage

**Files:**
- Create: `lib/app/module/debug/controllers/storage_inspector_controller.dart`
- Create: `lib/app/module/debug/bindings/storage_inspector_binding.dart`
- Create: `lib/app/module/debug/views/storage_inspector_view.dart`
- Modify: `lib/app/routes/app_routes.dart`
- Modify: `lib/app/routes/app_pages.dart`
- Modify: `lib/app/module/debug/views/debug_view.dart`
- Test: `test/presentation/modules/debug/controllers/storage_inspector_controller_test.dart`

**Interfaces:**
- Consumes : `AppEnvironment.owner(String)`, `AppConfig.environment`.
- Produces : `Routes.debugStorage` = `'/debug/storage'`, `class StorageEntry { String key; String value; int get sizeInBytes; }`, `StorageInspectorController(FlutterSecureStorage, AppConfig)` avec `RxList<StorageEntry> currentEnvironment / otherEnvironment / global`, `Future<void> load()`, `Future<void> delete(String key)`, `static String prettify(String raw)`.

- [ ] **Step 1: Écrire le test qui échoue**

Créer `test/presentation/modules/debug/controllers/storage_inspector_controller_test.dart` :

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/config/app_config.dart';
import 'package:live_ffss/app/core/config/app_environment.dart';
import 'package:live_ffss/app/module/debug/controllers/storage_inspector_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockSecureStorage storage;

  setUp(() {
    storage = _MockSecureStorage();
    when(() => storage.readAll()).thenAnswer((_) async => {
          'token': 'T',
          'programme_7': '{"a":1}',
          'favorite_competitions': '[1,2]',
          'dev_token': 'D',
          'language': 'fr',
          'api_environment': 'production',
        });
  });

  group('StorageInspectorController.load', () {
    test('groupe les cles en trois sections, triees', () async {
      final controller = StorageInspectorController(
        storage,
        const AppConfig.production(),
      );

      await controller.load();

      expect(
        controller.currentEnvironment.map((e) => e.key).toList(),
        ['favorite_competitions', 'programme_7', 'token'],
      );
      expect(controller.otherEnvironment.map((e) => e.key).toList(),
          ['dev_token']);
      expect(controller.global.map((e) => e.key).toList(),
          ['api_environment', 'language']);
    });

    test('le point de vue change avec l\'environnement courant', () async {
      final controller = StorageInspectorController(
        storage,
        AppConfig.forEnvironment(AppEnvironment.development),
      );

      await controller.load();

      expect(
          controller.currentEnvironment.map((e) => e.key).toList(),
          ['dev_token']);
      expect(controller.otherEnvironment.length, 3);
    });

    test('la taille est celle des octets UTF-8', () async {
      final controller = StorageInspectorController(
        storage,
        const AppConfig.production(),
      );

      await controller.load();

      final entry =
          controller.currentEnvironment.firstWhere((e) => e.key == 'token');
      expect(entry.sizeInBytes, 1);
    });
  });

  group('StorageInspectorController.delete', () {
    test('supprime la cle puis recharge', () async {
      when(() => storage.delete(key: any(named: 'key')))
          .thenAnswer((_) async {});
      final controller = StorageInspectorController(
        storage,
        const AppConfig.production(),
      );
      await controller.load();

      await controller.delete('token');

      verify(() => storage.delete(key: 'token')).called(1);
      verify(() => storage.readAll()).called(2);
    });
  });

  group('StorageInspectorController.prettify', () {
    test('re-indente du JSON', () {
      expect(
        StorageInspectorController.prettify('{"a":1}'),
        '{\n  "a": 1\n}',
      );
    });

    test('laisse intacte une valeur qui n\'est pas du JSON', () {
      expect(StorageInspectorController.prettify('fr'), 'fr');
    });
  });
}
```

- [ ] **Step 2: Lancer le test et vérifier qu'il échoue**

Run : `flutter test test/presentation/modules/debug/controllers/storage_inspector_controller_test.dart`
Expected : échec de compilation, `Target of URI doesn't exist: '.../storage_inspector_controller.dart'`.

- [ ] **Step 3: Écrire le contrôleur et son binding**

Créer `lib/app/module/debug/controllers/storage_inspector_controller.dart` :

```dart
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/config/app_config.dart';
import 'package:live_ffss/app/core/config/app_environment.dart';

class StorageEntry {
  const StorageEntry({required this.key, required this.value});

  final String key;
  final String value;

  int get sizeInBytes => utf8.encode(value).length;
}

/// Ce que le téléphone garde, rangé par propriétaire.
class StorageInspectorController extends GetxController {
  StorageInspectorController(this._storage, this._config);

  final FlutterSecureStorage _storage;
  final AppConfig _config;

  final RxBool isLoading = false.obs;
  final RxList<StorageEntry> currentEnvironment = <StorageEntry>[].obs;
  final RxList<StorageEntry> otherEnvironment = <StorageEntry>[].obs;
  final RxList<StorageEntry> global = <StorageEntry>[].obs;

  AppEnvironment get environment => _config.environment;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final all = await _storage.readAll();
      final mine = <StorageEntry>[];
      final theirs = <StorageEntry>[];
      final globals = <StorageEntry>[];
      for (final raw in all.entries) {
        final entry = StorageEntry(key: raw.key, value: raw.value);
        final owner = AppEnvironment.owner(raw.key);
        if (owner == null) {
          globals.add(entry);
        } else if (owner == _config.environment) {
          mine.add(entry);
        } else {
          theirs.add(entry);
        }
      }
      for (final list in [mine, theirs, globals]) {
        list.sort((a, b) => a.key.compareTo(b.key));
      }
      currentEnvironment.assignAll(mine);
      otherEnvironment.assignAll(theirs);
      global.assignAll(globals);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
    await load();
  }

  /// Ré-indente si la valeur parse en JSON : c'est ce qui rend un blob
  /// `programme_412` lisible. La copie, elle, emporte la chaîne brute, pour
  /// qu'elle puisse être ré-injectée telle quelle.
  static String prettify(String raw) {
    try {
      return const JsonEncoder.withIndent('  ').convert(jsonDecode(raw));
    } on FormatException {
      return raw;
    }
  }
}
```

Créer `lib/app/module/debug/bindings/storage_inspector_binding.dart` :

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/config/app_config.dart';
import 'package:live_ffss/app/module/debug/controllers/storage_inspector_controller.dart';

class StorageInspectorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StorageInspectorController>(
      () => StorageInspectorController(
        Get.find<FlutterSecureStorage>(),
        Get.find<AppConfig>(),
      ),
    );
  }
}
```

- [ ] **Step 4: Lancer le test et vérifier qu'il passe**

Run : `flutter test test/presentation/modules/debug/controllers/storage_inspector_controller_test.dart`
Expected : PASS, 6 tests.

- [ ] **Step 5: Écrire la vue**

Créer `lib/app/module/debug/views/storage_inspector_view.dart` :

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/module/debug/controllers/storage_inspector_controller.dart';
import 'package:live_ffss/app/presentation/shared/loading_indicator.dart';

/// Textes en dur, non traduits : le module debug ne part jamais en release.
class StorageInspectorView extends GetView<StorageInspectorController> {
  const StorageInspectorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stockage local'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir',
            onPressed: controller.load,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingIndicator();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Cet écran écrit sur le disque, pas dans les objets vivants. '
                'Supprimer une clé ne vide pas ce que les services tiennent '
                'déjà en mémoire — il faut relancer l\'application, ou '
                'basculer d\'environnement, pour qu\'ils le constatent.',
              ),
            ),
            const SizedBox(height: 16),
            ..._section(
              context,
              'Environnement courant — ${controller.environment.label}',
              controller.currentEnvironment,
            ),
            ..._section(context, 'Autre environnement',
                controller.otherEnvironment),
            ..._section(context, 'Clés globales', controller.global),
          ],
        );
      }),
    );
  }

  List<Widget> _section(
    BuildContext context,
    String title,
    List<StorageEntry> entries,
  ) =>
      [
        Text(
          '$title (${entries.length})',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (entries.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text('aucune clé', style: TextStyle(color: AppColors.textMuted)),
          )
        else
          ...entries.map((entry) => Card(
                child: ExpansionTile(
                  title: Text(entry.key),
                  subtitle: Text('${entry.sizeInBytes} octets'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: SelectableText(
                        StorageInspectorController.prettify(entry.value),
                        style: const TextStyle(
                            fontFamily: 'monospace', fontSize: 12),
                      ),
                    ),
                    OverflowBar(
                      alignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.copy, size: 18),
                          label: const Text('Copier'),
                          onPressed: () => _copy(context, entry.value),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('Supprimer'),
                          style:
                              TextButton.styleFrom(foregroundColor: Colors.red),
                          onPressed: () =>
                              _confirmDelete(context, controller, entry.key),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
        const SizedBox(height: 16),
      ];
}

/// Copie la chaîne brute, pas la version ré-indentée : c'est elle qui peut être
/// ré-injectée ou jointe à un rapport.
Future<void> _copy(BuildContext context, String raw) async {
  await Clipboard.setData(ClipboardData(text: raw));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Copié')),
  );
}

Future<void> _confirmDelete(
  BuildContext context,
  StorageInspectorController controller,
  String key,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Supprimer cette clé ?'),
      content: Text(
        '« $key » sera effacée du stockage. Si elle porte un tirage non poussé, '
        'il n\'existe nulle part ailleurs.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Supprimer'),
        ),
      ],
    ),
  );
  if (confirmed == true) await controller.delete(key);
}
```

- [ ] **Step 6: Brancher la route et l'entrée**

Dans `lib/app/routes/app_routes.dart`, à côté de `debug` :

```dart
  static const debugStorage = '/debug/storage';
```

Dans `lib/app/routes/app_pages.dart`, ajouter les imports du binding et de la vue, puis, à la suite du `GetPage` de `Routes.debug` :

```dart
    if (kDebugMode)
      GetPage(
        name: Routes.debugStorage,
        page: () => const StorageInspectorView(),
        binding: StorageInspectorBinding(),
      ),
```

Dans `lib/app/module/debug/views/debug_view.dart`, ajouter l'import `package:live_ffss/app/routes/app_pages.dart` et, à la fin de la liste `children` du `ListView` :

```dart
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.storage_outlined),
              title: const Text('Stockage local'),
              subtitle: const Text('Voir, copier et supprimer les clés'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Get.toNamed<void>(Routes.debugStorage),
            ),
          ),
```

- [ ] **Step 7: Vérifier**

Run : `flutter analyze`
Expected : `No issues found!`

Run : `flutter test`
Expected : PASS, suite complète.

- [ ] **Step 8: Commit**

```bash
git add lib/app/module/debug lib/app/routes test/presentation/modules/debug
git commit -m "feat(debug): inspecteur du stockage local"
```

---

### Task 7: L'écran du journal HTTP

**Files:**
- Create: `lib/app/module/debug/controllers/http_log_controller.dart`
- Create: `lib/app/module/debug/bindings/http_log_binding.dart`
- Create: `lib/app/module/debug/views/http_log_view.dart`
- Modify: `lib/app/routes/app_routes.dart`
- Modify: `lib/app/routes/app_pages.dart`
- Modify: `lib/app/module/debug/views/debug_view.dart`
- Test: `test/presentation/modules/debug/controllers/http_log_controller_test.dart`

**Interfaces:**
- Consumes : `httpLog`, `HttpLogEntry` (Task 2), `AppEnvironment.httpLogKey` (Task 4).
- Produces : `Routes.debugHttp` = `'/debug/http'`, `HttpLogController(FlutterSecureStorage)` avec `RxBool isEnabled`, `RxList<HttpLogEntry> entries`, `void refreshEntries()`, `Future<void> setEnabled(bool)`, `void clear()`.

- [ ] **Step 1: Écrire le test qui échoue**

Créer `test/presentation/modules/debug/controllers/http_log_controller_test.dart` :

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/network/http_log.dart';
import 'package:live_ffss/app/module/debug/controllers/http_log_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

HttpLogEntry _entry(String url) => HttpLogEntry(
      at: DateTime(2026, 9, 10),
      method: 'GET',
      url: url,
      durationMs: 5,
      statusCode: 200,
    );

void main() {
  late _MockSecureStorage storage;
  late HttpLogController controller;

  setUp(() {
    storage = _MockSecureStorage();
    when(() => storage.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((_) async {});
    httpLog
      ..clear()
      ..enabled = false;
    controller = HttpLogController(storage);
  });

  tearDown(() {
    httpLog
      ..clear()
      ..enabled = false;
  });

  test('refreshEntries prend un instantane du journal', () {
    httpLog.enabled = true;
    httpLog.record(_entry('a'));

    controller.refreshEntries();

    expect(controller.entries.map((e) => e.url).toList(), ['a']);
  });

  test('setEnabled allume le journal et persiste le choix', () async {
    await controller.setEnabled(true);

    expect(httpLog.enabled, isTrue);
    expect(controller.isEnabled.value, isTrue);
    verify(() => storage.write(key: 'debug_http_log', value: 'true')).called(1);
  });

  test('setEnabled eteint le journal et persiste le choix', () async {
    await controller.setEnabled(true);

    await controller.setEnabled(false);

    expect(httpLog.enabled, isFalse);
    verify(() => storage.write(key: 'debug_http_log', value: 'false'))
        .called(1);
  });

  test('clear vide le journal et l\'instantane', () {
    httpLog.enabled = true;
    httpLog.record(_entry('a'));
    controller.refreshEntries();

    controller.clear();

    expect(httpLog.entries, isEmpty);
    expect(controller.entries, isEmpty);
  });
}
```

- [ ] **Step 2: Lancer le test et vérifier qu'il échoue**

Run : `flutter test test/presentation/modules/debug/controllers/http_log_controller_test.dart`
Expected : échec de compilation, `Target of URI doesn't exist: '.../http_log_controller.dart'`.

- [ ] **Step 3: Écrire le contrôleur et son binding**

Créer `lib/app/module/debug/controllers/http_log_controller.dart` :

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/config/app_environment.dart';
import 'package:live_ffss/app/core/network/http_log.dart';

/// L'écran du journal HTTP. Le tampon vit hors de GetX ; ce contrôleur n'en
/// tient qu'un instantané, rafraîchi à la demande.
class HttpLogController extends GetxController {
  HttpLogController(this._storage);

  final FlutterSecureStorage _storage;

  final RxBool isEnabled = false.obs;
  final RxList<HttpLogEntry> entries = <HttpLogEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    isEnabled.value = httpLog.enabled;
    refreshEntries();
  }

  void refreshEntries() => entries.assignAll(httpLog.entries);

  Future<void> setEnabled(bool value) async {
    httpLog.enabled = value;
    isEnabled.value = value;
    await _storage.write(
      key: AppEnvironment.httpLogKey,
      value: value.toString(),
    );
  }

  void clear() {
    httpLog.clear();
    refreshEntries();
  }
}
```

Créer `lib/app/module/debug/bindings/http_log_binding.dart` :

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/module/debug/controllers/http_log_controller.dart';

class HttpLogBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HttpLogController>(
      () => HttpLogController(Get.find<FlutterSecureStorage>()),
    );
  }
}
```

- [ ] **Step 4: Lancer le test et vérifier qu'il passe**

Run : `flutter test test/presentation/modules/debug/controllers/http_log_controller_test.dart`
Expected : PASS, 4 tests.

- [ ] **Step 5: Écrire la vue**

Créer `lib/app/module/debug/views/http_log_view.dart` :

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/network/http_log.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/module/debug/controllers/http_log_controller.dart';

/// Textes en dur, non traduits : le module debug ne part jamais en release.
class HttpLogView extends GetView<HttpLogController> {
  const HttpLogView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal HTTP'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir',
            onPressed: controller.refreshEntries,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Vider',
            onPressed: controller.clear,
          ),
        ],
      ),
      body: Column(
        children: [
          Obx(() => SwitchListTile(
                value: controller.isEnabled.value,
                onChanged: controller.setEnabled,
                title: const Text('Enregistrer les requêtes'),
                subtitle: Text(
                  controller.isEnabled.value
                      ? 'Les ${HttpLog.capacity} dernières, corps tronqués à '
                          '${HttpLog.bodyLimit} caractères. L\'URL contient le '
                          'jeton en clair.'
                      : 'Éteint — rien n\'est capturé.',
                ),
              )),
          const Divider(height: 1),
          Expanded(
            child: Obx(() {
              if (controller.entries.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'Aucune requête enregistrée.\n'
                      'Allumez le journal, refaites l\'action, puis '
                      'rafraîchissez.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return ListView.builder(
                itemCount: controller.entries.length,
                itemBuilder: (context, index) =>
                    _tile(context, controller.entries[index]),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, HttpLogEntry entry) {
    final status = entry.error != null
        ? 'échec'
        : '${entry.statusCode ?? '?'}';
    final failed = entry.error != null || (entry.statusCode ?? 0) >= 400;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ExpansionTile(
        leading: Text(
          entry.method,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        title: Text(
          Uri.parse(entry.url).path,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '$status · ${entry.durationMs} ms',
          style: TextStyle(
            color: failed ? AppColors.statusError : AppColors.statusFinished,
          ),
        ),
        children: [
          _block(context, 'URL', entry.url),
          if (entry.requestBody != null)
            _block(context, 'Corps envoyé', entry.requestBody!),
          if (entry.responseBody != null)
            _block(context, 'Réponse', entry.responseBody!),
          if (entry.error != null) _block(context, 'Erreur', entry.error!),
        ],
      ),
    );
  }

  Widget _block(BuildContext context, String title, String content) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                TextButton.icon(
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copier'),
                  onPressed: () => _copy(context, content),
                ),
              ],
            ),
            SelectableText(
              content,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ],
        ),
      );
}

Future<void> _copy(BuildContext context, String raw) async {
  await Clipboard.setData(ClipboardData(text: raw));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Copié')),
  );
}
```

- [ ] **Step 6: Brancher la route et l'entrée**

Dans `lib/app/routes/app_routes.dart` :

```dart
  static const debugHttp = '/debug/http';
```

Dans `lib/app/routes/app_pages.dart`, imports puis, à la suite du `GetPage` de `Routes.debugStorage` :

```dart
    if (kDebugMode)
      GetPage(
        name: Routes.debugHttp,
        page: () => const HttpLogView(),
        binding: HttpLogBinding(),
      ),
```

Dans `lib/app/module/debug/views/debug_view.dart`, à la suite de l'entrée « Stockage local » :

```dart
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.swap_vert),
              title: const Text('Journal HTTP'),
              subtitle: const Text('Les dernières requêtes et leurs réponses'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Get.toNamed<void>(Routes.debugHttp),
            ),
          ),
```

- [ ] **Step 7: Vérifier**

Run : `flutter analyze`
Expected : `No issues found!`

Run : `flutter test`
Expected : PASS, suite complète.

- [ ] **Step 8: Commit**

```bash
git add lib/app/module/debug lib/app/routes test/presentation/modules/debug
git commit -m "feat(debug): ecran du journal HTTP"
```

---

### Task 8: Documentation et vérification finale

**Files:**
- Modify: `CLAUDE.md`

- [ ] **Step 1: Mettre `CLAUDE.md` au niveau**

Quatre retouches chirurgicales, sans réécrire les passages voisins :

1. Dans la description du module `debug` (section « Feature modules »), dire ce que l'écran contient désormais :

```markdown
`debug` n'est déclaré que sous `kDebugMode`, routes comprises : en release ses `GetPage` n'existent pas. Ses textes sont en dur et non traduits, délibérément. Trois outils : bascule d'environnement, diagnostic de session (`AuthRepository.probeSession()`), et deux sous-écrans — `/debug/storage` (inspecteur du secure storage) et `/debug/http` (journal des requêtes).
```

2. Dans la section « API contract », à la puce sur les clés préfixées, corriger le compte des clés globales : elles sont désormais **trois** — `language`, `api_environment` et `debug_http_log`. La règle unique reste `AppEnvironment.owner(key)`.

3. Dans la liste de `core/network/`, ajouter `http_log.dart` :

```markdown
- `network/` — `HttpClient`, `TokenStorage`, `HttpLog` (tampon des dernières requêtes, hors GetX, éteint par défaut ; alimenté depuis `HttpClient._send`).
```

4. Dans la liste des modèles du domaine, ajouter `session_probe` à l'énumération existante.

- [ ] **Step 2: Formater**

Run : `dart format lib/ test/`
Expected : quelques fichiers reformatés, ou aucun. S'il y en a **beaucoup** (plus de dix) et qu'ils n'ont rien à voir avec ce plan, c'est une dérive de formateur préexistante : commite-les à part, dans un commit `chore: sync formatage`, plutôt que de les mêler à la documentation.

- [ ] **Step 3: Vérification complète**

Run : `flutter analyze`
Expected : `No issues found!`

Run : `flutter test`
Expected : PASS, suite complète.

- [ ] **Step 4: Vérifier la garde release**

Run : `flutter build apk --release`
Expected : build réussie. C'est la seule chose qui prouve que tout le code sous `kDebugMode` — quatre `GetPage` conditionnelles, désormais — compile aussi en release.

- [ ] **Step 5: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: les trois outils de l'ecran de debug"
```
