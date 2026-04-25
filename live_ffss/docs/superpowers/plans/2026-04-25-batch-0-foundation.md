# Batch 0 — Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the foundational pieces of the new architecture (config, errors, HTTP client, token storage, DI skeleton) without changing any user-visible behavior. Old `ApiService` keeps running; new components live alongside it, fully unit-tested, ready for Batch 1 to start migrating domains.

**Architecture:** Per the design spec ([2026-04-25-architecture-refactor-design.md](../specs/2026-04-25-architecture-refactor-design.md)). 3-layer pragmatic split, GetX kept for DI/routing/i18n, controller discipline enforced from Batch 1 onward. This plan only builds infrastructure.

**Tech Stack:** Dart 3.4+, Flutter, GetX, `package:http`, `flutter_secure_storage`, `mocktail` (new), `freezed` + `json_serializable` + `build_runner` (new — used in later batches but installed here).

---

## Notes & deviations from spec

1. **HttpClient return type:** spec §7 says "return `data` if present, else full body." During planning I noticed the `me` endpoint puts `label`/`type` at the top level *and* nested data under `data`, so unwrapping `data` would lose information. **Refinement:** `HttpClient` returns the full decoded `Map<String, dynamic>` body after envelope validation; datasources extract what they need. Spec amended below in this plan; the design doc remains as-is — the difference is small.

2. **Lint tightening deferred.** Spec §10 lists `prefer_const_constructors`, `prefer_single_quotes`, `unnecessary_lambdas`, `avoid_print`. Adding these now would explode `flutter analyze` against the existing legacy code (4,000+ LOC of double-quoted strings, etc.) and Batch 0 is supposed to be "no behavior change." We only drop the `sized_box_for_whitespace: ignore` override here. Full lint tightening is **moved to Batch 6 (Demolition)**, where existing code is being deleted/rewritten anyway.

3. **No empty folder creation.** Dart doesn't track empty dirs. Folders appear naturally when files are added in Batches 1+.

4. **`InitialBinding` not wired into `main.dart` yet.** Batch 0 builds it; Batch 1 wires it in alongside the auth migration.

---

## File map

**Modify:**
- `pubspec.yaml` — add deps
- `analysis_options.yaml` — drop the `sized_box_for_whitespace: ignore` override

**Create (production):**
- `lib/app/core/config/app_config.dart` — env-driven config
- `lib/app/core/errors/app_exception.dart` — sealed exception hierarchy
- `lib/app/core/network/token_storage.dart` — wraps FlutterSecureStorage
- `lib/app/core/network/http_client.dart` — wraps `package:http`, injects auth, maps errors
- `lib/app/core/di/initial_binding.dart` — DI registration skeleton

**Create (tests):**
- `test/core/errors/app_exception_test.dart`
- `test/core/network/token_storage_test.dart`
- `test/core/config/app_config_test.dart`
- `test/core/network/http_client_test.dart`

---

## Task 1: Project setup — dependencies & lint

**Files:**
- Modify: `pubspec.yaml`
- Modify: `analysis_options.yaml`

- [ ] **Step 1: Update `pubspec.yaml`**

Replace the file with:

```yaml
name: live_ffss
description: "Live tracking of FFSS competitions."

publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=3.4.3 <4.0.0'

dependencies:
  cached_network_image: ^3.4.1
  carousel_slider: ^5.0.0
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  flutter_secure_storage: ^9.2.4
  freezed_annotation: ^2.4.4
  get: ^4.6.6
  getwidget: ^4.0.0
  google_fonts: ^4.0.4
  http: ^1.2.2
  intl: ^0.19.0
  json_annotation: ^4.9.0

dev_dependencies:
  build_runner: ^2.4.13
  flutter_lints: ^3.0.0
  flutter_test:
    sdk: flutter
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  mocktail: ^1.0.4

flutter:
  uses-material-design: true
  generate: true

  assets:
    - assets/images/
```

- [ ] **Step 2: Install dependencies**

Run: `flutter pub get`

Expected output: ends with `Got dependencies!` and lists the new packages (`mocktail`, `freezed`, `json_serializable`, etc.). No errors.

- [ ] **Step 3: Update `analysis_options.yaml`**

Replace the file with:

```yaml
analyzer:
  language:
    strict-casts: true
    strict-raw-types: true
include: package:flutter_lints/flutter.yaml

linter:
  rules:
```

- [ ] **Step 4: Verify analyzer still passes existing code**

Run: `flutter analyze`

Expected: warnings/info only — no compile errors. (We dropped `sized_box_for_whitespace: ignore`, so a few new warnings may appear in legacy view files. That's fine; they'll be cleaned up in Batch 6.)

If you see actual *errors* (red), stop and investigate — likely a missing dep or a typo in the yaml.

- [ ] **Step 5: Commit**

```bash
git add pubspec.yaml pubspec.lock analysis_options.yaml
git commit -m "chore: add freezed, json_serializable, mocktail; tighten analyzer

Foundation deps for the architecture refactor (Batch 0)."
```

---

## Task 2: AppException hierarchy

**Files:**
- Create: `lib/app/core/errors/app_exception.dart`
- Create: `test/core/errors/app_exception_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/core/errors/app_exception_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';

void main() {
  group('AppException', () {
    test('NetworkException stores message and exposes it via toString', () {
      const e = NetworkException('No internet');
      expect(e.message, 'No internet');
      expect(e.toString(), contains('No internet'));
    });

    test('ApiException stores message and optional statusCode', () {
      const e = ApiException('Server error', statusCode: 500);
      expect(e.message, 'Server error');
      expect(e.statusCode, 500);
    });

    test('AuthException is distinct from ApiException', () {
      const a = AuthException('Token expired');
      const b = ApiException('Server error');
      expect(a, isA<AuthException>());
      expect(a, isA<AppException>());
      expect(b, isNot(isA<AuthException>()));
    });

    test('UnknownException wraps unexpected errors', () {
      const e = UnknownException('Boom');
      expect(e.message, 'Boom');
      expect(e, isA<AppException>());
    });

    test('AppException implements Exception', () {
      const e = NetworkException('x');
      expect(e, isA<Exception>());
    });
  });
}
```

- [ ] **Step 2: Run the test and verify it fails**

Run: `flutter test test/core/errors/app_exception_test.dart`

Expected: failures with "Target of URI doesn't exist: 'package:live_ffss/app/core/errors/app_exception.dart'".

- [ ] **Step 3: Implement `AppException`**

Create `lib/app/core/errors/app_exception.dart`:

```dart
sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class ApiException extends AppException {
  const ApiException(super.message, {this.statusCode, this.code});

  final int? statusCode;
  final String? code;
}

class AuthException extends AppException {
  const AuthException(super.message);
}

class UnknownException extends AppException {
  const UnknownException(super.message);
}
```

- [ ] **Step 4: Run the test and verify it passes**

Run: `flutter test test/core/errors/app_exception_test.dart`

Expected: `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/app/core/errors/app_exception.dart test/core/errors/app_exception_test.dart
git commit -m "feat(core): add sealed AppException hierarchy

NetworkException, ApiException, AuthException, UnknownException.
Used by HttpClient and rethrown unchanged through repositories."
```

---

## Task 3: TokenStorage

**Files:**
- Create: `lib/app/core/network/token_storage.dart`
- Create: `test/core/network/token_storage_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/core/network/token_storage_test.dart`:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/network/token_storage.dart';
import 'package:mocktail/mocktail.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockSecureStorage secureStorage;
  late TokenStorage tokenStorage;

  setUp(() {
    secureStorage = _MockSecureStorage();
    tokenStorage = TokenStorage(secureStorage);
  });

  group('TokenStorage', () {
    test('getToken reads the "token" key', () async {
      when(() => secureStorage.read(key: 'token'))
          .thenAnswer((_) async => 'abc');

      final token = await tokenStorage.getToken();

      expect(token, 'abc');
      verify(() => secureStorage.read(key: 'token')).called(1);
    });

    test('getToken returns null when no token stored', () async {
      when(() => secureStorage.read(key: 'token'))
          .thenAnswer((_) async => null);

      final token = await tokenStorage.getToken();

      expect(token, isNull);
    });

    test('setToken writes to the "token" key', () async {
      when(() => secureStorage.write(key: 'token', value: 'xyz'))
          .thenAnswer((_) async {});

      await tokenStorage.setToken('xyz');

      verify(() => secureStorage.write(key: 'token', value: 'xyz')).called(1);
    });

    test('clearToken deletes the "token" key', () async {
      when(() => secureStorage.delete(key: 'token'))
          .thenAnswer((_) async {});

      await tokenStorage.clearToken();

      verify(() => secureStorage.delete(key: 'token')).called(1);
    });
  });
}
```

- [ ] **Step 2: Run the test and verify it fails**

Run: `flutter test test/core/network/token_storage_test.dart`

Expected: import error for `package:live_ffss/app/core/network/token_storage.dart`.

- [ ] **Step 3: Implement `TokenStorage`**

Create `lib/app/core/network/token_storage.dart`:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage(this._storage);

  static const _tokenKey = 'token';
  final FlutterSecureStorage _storage;

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<void> setToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<void> clearToken() => _storage.delete(key: _tokenKey);
}
```

- [ ] **Step 4: Run the test and verify it passes**

Run: `flutter test test/core/network/token_storage_test.dart`

Expected: `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/app/core/network/token_storage.dart test/core/network/token_storage_test.dart
git commit -m "feat(core): add TokenStorage wrapper around FlutterSecureStorage

Single source of truth for the auth token. Replaces scattered
_storage.read(key: 'token') calls in upcoming batches."
```

---

## Task 4: AppConfig

**Files:**
- Create: `lib/app/core/config/app_config.dart`
- Create: `test/core/config/app_config_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/core/config/app_config_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/config/app_config.dart';

void main() {
  group('AppConfig', () {
    test('production config has correct base URL and api version', () {
      const config = AppConfig.production();

      expect(config.baseUrl, 'https://ffss.fr');
      expect(config.apiVersion, 'api/v1.0');
    });

    test('two configs with same fields are equal', () {
      const a = AppConfig(baseUrl: 'https://x.test', apiVersion: 'v1');
      const b = AppConfig(baseUrl: 'https://x.test', apiVersion: 'v1');
      expect(a, b);
    });

    test('endpoint paths are exposed as static constants', () {
      expect(ApiEndpoints.requestToken, 'requestToken');
      expect(ApiEndpoints.me, 'me');
      expect(ApiEndpoints.competitionList, 'competition/evenement');
      expect(ApiEndpoints.clubDetail, 'organisme/:id');
    });

    test('replacePath substitutes :param tokens', () {
      final result = ApiEndpoints.replacePath(
          'organisme/:id/detail', {'id': '42'});
      expect(result, 'organisme/42/detail');
    });

    test('replacePath supports multiple substitutions', () {
      final result = ApiEndpoints.replacePath(
          ':a/:b', {'a': 'x', 'b': 'y'});
      expect(result, 'x/y');
    });
  });
}
```

- [ ] **Step 2: Run the test and verify it fails**

Run: `flutter test test/core/config/app_config_test.dart`

Expected: import error for `app_config.dart`.

- [ ] **Step 3: Implement `AppConfig`**

Create `lib/app/core/config/app_config.dart`:

```dart
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
```

- [ ] **Step 4: Run the test and verify it passes**

Run: `flutter test test/core/config/app_config_test.dart`

Expected: `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/app/core/config/app_config.dart test/core/config/app_config_test.dart
git commit -m "feat(core): add AppConfig and ApiEndpoints

Replaces ApiConstants. AppConfig is env-driven (currently single env);
ApiEndpoints holds the path templates. The legacy ApiConstants stays
in place until Batch 6 demolition."
```

---

## Task 5: HttpClient — URL building

This task creates the `HttpClient` skeleton and tests URL construction. Subsequent tasks expand it for headers, success responses, and errors. Each task adds a new behavior with its own tests; all live in one file.

**Files:**
- Create: `lib/app/core/network/http_client.dart`
- Create: `test/core/network/http_client_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/core/network/http_client_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:live_ffss/app/core/config/app_config.dart';
import 'package:live_ffss/app/core/network/http_client.dart';
import 'package:live_ffss/app/core/network/token_storage.dart';
import 'package:mocktail/mocktail.dart';

class _MockHttp extends Mock implements http.Client {}

class _MockTokenStorage extends Mock implements TokenStorage {}

class _FakeUri extends Fake implements Uri {}

http.Response responseWith(String body, int status) =>
    http.Response(body, status);

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeUri());
  });

  late _MockHttp httpMock;
  late _MockTokenStorage tokens;
  late HttpClient client;

  const config = AppConfig(
    baseUrl: 'https://example.test',
    apiVersion: 'api/v1.0',
  );

  setUp(() {
    httpMock = _MockHttp();
    tokens = _MockTokenStorage();
    client = HttpClient(config: config, tokenStorage: tokens, inner: httpMock);
    when(() => tokens.getToken()).thenAnswer((_) async => null);
  });

  group('HttpClient.get URL building', () {
    test('joins baseUrl, apiVersion, and path with single slashes', () async {
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
              (_) async => responseWith('{"success": true, "data": []}', 200));

      await client.get('competition/evenement');

      final captured = verify(
              () => httpMock.get(captureAny(), headers: any(named: 'headers')))
          .captured;
      expect(captured.single,
          Uri.parse('https://example.test/api/v1.0/competition/evenement'));
    });

    test('appends query parameters', () async {
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
              (_) async => responseWith('{"success": true}', 200));

      await client.get('competition/evenement', query: {
        'saison': '2023-2024',
        'page': 2,
      });

      final captured = verify(
              () => httpMock.get(captureAny(), headers: any(named: 'headers')))
          .captured;
      final uri = captured.single as Uri;
      expect(uri.path, '/api/v1.0/competition/evenement');
      expect(uri.queryParameters, {'saison': '2023-2024', 'page': '2'});
    });

    test('null query values are omitted', () async {
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
              (_) async => responseWith('{"success": true}', 200));

      await client.get('x', query: {'a': 'kept', 'b': null});

      final captured = verify(
              () => httpMock.get(captureAny(), headers: any(named: 'headers')))
          .captured;
      expect((captured.single as Uri).queryParameters, {'a': 'kept'});
    });
  });
}
```

- [ ] **Step 2: Run the test and verify it fails**

Run: `flutter test test/core/network/http_client_test.dart`

Expected: import error for `http_client.dart`.

- [ ] **Step 3: Implement minimal `HttpClient`**

Create `lib/app/core/network/http_client.dart`:

```dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:live_ffss/app/core/config/app_config.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/core/network/token_storage.dart';

class HttpClient {
  HttpClient({
    required AppConfig config,
    required TokenStorage tokenStorage,
    http.Client? inner,
  })  : _config = config,
        _tokenStorage = tokenStorage,
        _inner = inner ?? http.Client();

  final AppConfig _config;
  final TokenStorage _tokenStorage;
  final http.Client _inner;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final uri = _buildUri(path, query);
    final headers = await _buildHeaders();
    final response = await _inner.get(uri, headers: headers);
    return _decode(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? query,
    Object? body,
  }) async {
    final uri = _buildUri(path, query);
    final headers = await _buildHeaders();
    final response = await _inner.post(
      uri,
      headers: headers,
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(response);
  }

  Uri _buildUri(String path, Map<String, dynamic>? query) {
    final base = _trimSlashes(_config.baseUrl);
    final version = _trimSlashes(_config.apiVersion);
    final cleanPath = _trimSlashes(path);
    final fullPath = '$base/$version/$cleanPath';

    final filtered = <String, String>{};
    query?.forEach((key, value) {
      if (value != null) filtered[key] = value.toString();
    });

    final uri = Uri.parse(fullPath);
    return filtered.isEmpty ? uri : uri.replace(queryParameters: filtered);
  }

  String _trimSlashes(String s) {
    var out = s;
    while (out.startsWith('/')) {
      out = out.substring(1);
    }
    while (out.endsWith('/')) {
      out = out.substring(0, out.length - 1);
    }
    return out;
  }

  Future<Map<String, String>> _buildHeaders() async {
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
    final token = await _tokenStorage.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Map<String, dynamic> _decode(http.Response response) {
    final dynamic body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) {
      throw const ApiException('Unexpected response shape');
    }
    return body;
  }
}
```

- [ ] **Step 4: Run the test and verify it passes**

Run: `flutter test test/core/network/http_client_test.dart`

Expected: `All tests passed!` (3 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/app/core/network/http_client.dart test/core/network/http_client_test.dart
git commit -m "feat(core): HttpClient skeleton with URL building

Joins baseUrl + apiVersion + path, encodes query params, drops nulls.
Headers, response handling, and error mapping land in subsequent commits."
```

---

## Task 6: HttpClient — Headers & auth

**Files:**
- Modify: `test/core/network/http_client_test.dart` — add a new `group`

- [ ] **Step 1: Append the failing tests**

Append the following inside `void main() { ... }` in `test/core/network/http_client_test.dart`, after the existing `group('HttpClient.get URL building', ...)`:

```dart
  group('HttpClient headers', () {
    test('always sends Content-Type: application/json; charset=UTF-8',
        () async {
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
              (_) async => responseWith('{"success": true}', 200));

      await client.get('x');

      final captured = verify(
              () => httpMock.get(any(), headers: captureAny(named: 'headers')))
          .captured;
      final headers = captured.single as Map<String, String>;
      expect(headers['Content-Type'], 'application/json; charset=UTF-8');
    });

    test('omits Authorization when no token', () async {
      when(() => tokens.getToken()).thenAnswer((_) async => null);
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
              (_) async => responseWith('{"success": true}', 200));

      await client.get('x');

      final captured = verify(
              () => httpMock.get(any(), headers: captureAny(named: 'headers')))
          .captured;
      final headers = captured.single as Map<String, String>;
      expect(headers.containsKey('Authorization'), isFalse);
    });

    test('omits Authorization when token is empty string', () async {
      when(() => tokens.getToken()).thenAnswer((_) async => '');
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
              (_) async => responseWith('{"success": true}', 200));

      await client.get('x');

      final captured = verify(
              () => httpMock.get(any(), headers: captureAny(named: 'headers')))
          .captured;
      expect((captured.single as Map<String, String>).containsKey('Authorization'),
          isFalse);
    });

    test('sends Authorization: Bearer <token> when token present', () async {
      when(() => tokens.getToken()).thenAnswer((_) async => 'abc123');
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
              (_) async => responseWith('{"success": true}', 200));

      await client.get('x');

      final captured = verify(
              () => httpMock.get(any(), headers: captureAny(named: 'headers')))
          .captured;
      final headers = captured.single as Map<String, String>;
      expect(headers['Authorization'], 'Bearer abc123');
    });

    test('token is NOT included as a query parameter', () async {
      when(() => tokens.getToken()).thenAnswer((_) async => 'abc123');
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
              (_) async => responseWith('{"success": true}', 200));

      await client.get('x', query: {'a': 'b'});

      final captured = verify(
              () => httpMock.get(captureAny(), headers: any(named: 'headers')))
          .captured;
      final uri = captured.single as Uri;
      expect(uri.queryParameters.containsKey('token'), isFalse);
    });
  });
```

- [ ] **Step 2: Run the tests and verify they pass**

The header logic was already implemented in Task 5's `_buildHeaders`. These tests should pass without further code changes.

Run: `flutter test test/core/network/http_client_test.dart`

Expected: `All tests passed!` (3 + 5 = 8 tests).

If any fail (especially the empty-token case), check that `_buildHeaders` does `if (token != null && token.isNotEmpty)` and not just `if (token != null)`.

- [ ] **Step 3: Commit**

```bash
git add test/core/network/http_client_test.dart
git commit -m "test(core): cover HttpClient header & auth behavior

Authorization: Bearer header is set from TokenStorage; token never
leaks into the URL. Empty/null tokens omit the header."
```

---

## Task 7: HttpClient — Success response handling

Define how 2xx responses are interpreted. Per the refinement at the top of this plan: HttpClient returns the **full decoded body** (not an unwrapped `data` field), so endpoints with mixed top-level / nested fields (`me`) work uniformly.

**Files:**
- Modify: `lib/app/core/network/http_client.dart` — flesh out `_decode` for success cases
- Modify: `test/core/network/http_client_test.dart` — add a `group`

- [ ] **Step 1: Append the failing tests**

Append inside `void main() { ... }`:

```dart
  group('HttpClient success responses', () {
    test('returns full body on 2xx with success: true', () async {
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => responseWith(
              '{"success": true, "data": [1, 2, 3], "meta": "x"}', 200));

      final body = await client.get('x');

      expect(body['success'], true);
      expect(body['data'], [1, 2, 3]);
      expect(body['meta'], 'x');
    });

    test('returns full body on 2xx without a success key', () async {
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
              (_) async => responseWith('{"data": [1, 2]}', 200));

      final body = await client.get('x');
      expect(body['data'], [1, 2]);
    });

    test('accepts 200 and 201 as success', () async {
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
              (_) async => responseWith('{"success": true}', 201));

      final body = await client.get('x');
      expect(body['success'], true);
    });

    test('throws ApiException when body is not a JSON object', () async {
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => responseWith('"a string"', 200));

      expect(client.get('x'), throwsA(isA<ApiException>()));
    });

    test('throws ApiException on invalid JSON', () async {
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => responseWith('not json', 200));

      expect(client.get('x'), throwsA(isA<ApiException>()));
    });
  });
```

Add this import at the top of the test file if not already present:

```dart
import 'package:live_ffss/app/core/errors/app_exception.dart';
```

- [ ] **Step 2: Run the tests and verify which pass / fail**

Run: `flutter test test/core/network/http_client_test.dart`

Expected:
- The first four tests pass with the existing minimal `_decode` (which already throws `ApiException` when the decoded body is not a Map).
- The "invalid JSON" test currently fails — `jsonDecode` throws `FormatException`, which escapes uncaught instead of becoming `ApiException`.

- [ ] **Step 3: Update `_decode` to wrap JSON errors**

In `lib/app/core/network/http_client.dart`, replace `_decode` with:

```dart
  Map<String, dynamic> _decode(http.Response response) {
    final status = response.statusCode;

    final dynamic body;
    try {
      body = jsonDecode(response.body);
    } on FormatException catch (e) {
      throw ApiException('Invalid JSON: ${e.message}', statusCode: status);
    }

    if (body is! Map<String, dynamic>) {
      throw ApiException('Unexpected response shape', statusCode: status);
    }

    return body;
  }
```

- [ ] **Step 4: Run all tests**

Run: `flutter test test/core/network/http_client_test.dart`

Expected: `All tests passed!` (8 + 5 = 13 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/app/core/network/http_client.dart test/core/network/http_client_test.dart
git commit -m "feat(core): HttpClient returns full body on 2xx

Wraps malformed JSON in ApiException. The unwrap-data refinement
documented in the Batch 0 plan: caller picks the field it needs."
```

---

## Task 8: HttpClient — API errors and auth errors

**Files:**
- Modify: `lib/app/core/network/http_client.dart` — extend `_decode` for failure paths
- Modify: `test/core/network/http_client_test.dart` — add a `group`

- [ ] **Step 1: Append the failing tests**

```dart
  group('HttpClient API errors', () {
    test('throws ApiException on 2xx with success: false', () async {
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => responseWith(
              '{"success": false, "message": "Bad input"}', 200));

      expect(
        client.get('x'),
        throwsA(isA<ApiException>().having(
            (e) => e.message, 'message', contains('Bad input'))),
      );
    });

    test('throws ApiException with statusCode on 4xx', () async {
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => responseWith(
              '{"success": false, "message": "Not found"}', 404));

      expect(
        client.get('x'),
        throwsA(isA<ApiException>().having(
            (e) => e.statusCode, 'statusCode', 404)),
      );
    });

    test('throws ApiException on 5xx even with non-JSON body', () async {
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async =>
              responseWith('<html>Internal Server Error</html>', 500));

      expect(
        client.get('x'),
        throwsA(isA<ApiException>().having(
            (e) => e.statusCode, 'statusCode', 500)),
      );
    });

    test('throws AuthException on 401', () async {
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => responseWith(
              '{"success": false, "message": "Token expired"}', 401));

      expect(client.get('x'), throwsA(isA<AuthException>()));
    });
  });
```

- [ ] **Step 2: Run the tests and verify they fail**

Run: `flutter test test/core/network/http_client_test.dart`

Expected: 4 failures — current `_decode` doesn't handle non-2xx or `success: false`.

- [ ] **Step 3: Update `_decode` to handle errors**

Replace `_decode` in `lib/app/core/network/http_client.dart` with:

```dart
  Map<String, dynamic> _decode(http.Response response) {
    final status = response.statusCode;

    if (status == 401) {
      throw AuthException(_extractMessage(response.body) ?? 'Unauthorized');
    }

    if (status >= 400) {
      throw ApiException(
        _extractMessage(response.body) ?? 'HTTP $status',
        statusCode: status,
      );
    }

    final dynamic body;
    try {
      body = jsonDecode(response.body);
    } on FormatException catch (e) {
      throw ApiException('Invalid JSON: ${e.message}', statusCode: status);
    }

    if (body is! Map<String, dynamic>) {
      throw ApiException('Unexpected response shape', statusCode: status);
    }

    if (body['success'] == false) {
      throw ApiException(
        body['message']?.toString() ?? 'API returned success: false',
        statusCode: status,
        code: body['code']?.toString(),
      );
    }

    return body;
  }

  String? _extractMessage(String rawBody) {
    try {
      final dynamic decoded = jsonDecode(rawBody);
      if (decoded is Map<String, dynamic>) {
        final msg = decoded['message'];
        if (msg is String) return msg;
      }
    } on FormatException {
      // Body wasn't JSON. Fall through.
    }
    return null;
  }
```

- [ ] **Step 4: Run all tests**

Run: `flutter test test/core/network/http_client_test.dart`

Expected: `All tests passed!` (13 + 4 = 17 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/app/core/network/http_client.dart test/core/network/http_client_test.dart
git commit -m "feat(core): HttpClient maps API errors to ApiException/AuthException

401 -> AuthException. Other 4xx/5xx + 2xx with success:false -> ApiException
with statusCode and message extracted from the body when possible."
```

---

## Task 9: HttpClient — Network errors

**Files:**
- Modify: `lib/app/core/network/http_client.dart` — wrap transport-layer errors
- Modify: `test/core/network/http_client_test.dart` — add a `group`

- [ ] **Step 1: Append the failing tests**

```dart
  group('HttpClient network errors', () {
    test('SocketException becomes NetworkException', () async {
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenThrow(const SocketException('No internet'));

      expect(client.get('x'), throwsA(isA<NetworkException>()));
    });

    test('TimeoutException becomes NetworkException', () async {
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenThrow(TimeoutException('slow'));

      expect(client.get('x'), throwsA(isA<NetworkException>()));
    });

    test('AppException is rethrown unchanged (not wrapped)', () async {
      // Server returned HTML 500 -> ApiException; ensure that is what bubbles up,
      // not a wrapping UnknownException.
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => responseWith('html', 500));

      expect(client.get('x'), throwsA(isA<ApiException>()));
    });

    test('Unexpected error becomes UnknownException', () async {
      when(() => httpMock.get(any(), headers: any(named: 'headers')))
          .thenThrow(StateError('weird'));

      expect(client.get('x'), throwsA(isA<UnknownException>()));
    });
  });
```

Add these imports to the top of the test file:

```dart
import 'dart:async';
import 'dart:io';
```

- [ ] **Step 2: Run and verify the network tests fail**

Run: `flutter test test/core/network/http_client_test.dart`

Expected: the SocketException and TimeoutException tests currently throw raw — they don't become `NetworkException`. The "rethrown unchanged" test passes already; the "unexpected error" test currently bubbles `StateError`.

- [ ] **Step 3: Wrap `_inner.get` and `_inner.post` calls**

In `lib/app/core/network/http_client.dart`, replace the `get` and `post` methods with:

```dart
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final uri = _buildUri(path, query);
    final headers = await _buildHeaders();
    return _send(() => _inner.get(uri, headers: headers));
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? query,
    Object? body,
  }) async {
    final uri = _buildUri(path, query);
    final headers = await _buildHeaders();
    return _send(
      () => _inner.post(
        uri,
        headers: headers,
        body: body == null ? null : jsonEncode(body),
      ),
    );
  }

  Future<Map<String, dynamic>> _send(
      Future<http.Response> Function() request) async {
    try {
      final response = await request();
      return _decode(response);
    } on AppException {
      rethrow;
    } on SocketException catch (e) {
      throw NetworkException(e.message);
    } on TimeoutException catch (e) {
      throw NetworkException(e.message ?? 'Request timed out');
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }
```

- [ ] **Step 4: Run all tests**

Run: `flutter test test/core/network/http_client_test.dart`

Expected: `All tests passed!` (17 + 4 = 21 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/app/core/network/http_client.dart test/core/network/http_client_test.dart
git commit -m "feat(core): HttpClient maps transport errors to AppException

SocketException/TimeoutException -> NetworkException.
Unexpected throwables -> UnknownException. AppExceptions pass through."
```

---

## Task 10: InitialBinding skeleton

This is a configuration class — registration logic only, no behavior to test directly. It is **not yet wired into `main.dart`**; that happens in Batch 1 alongside the auth migration. Until then, the legacy startup in `main.dart` keeps running.

**Files:**
- Create: `lib/app/core/di/initial_binding.dart`

- [ ] **Step 1: Implement `InitialBinding`**

Create `lib/app/core/di/initial_binding.dart`:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/config/app_config.dart';
import 'package:live_ffss/app/core/network/http_client.dart';
import 'package:live_ffss/app/core/network/token_storage.dart';

class InitialBinding {
  InitialBinding._();

  static Future<void> register() async {
    Get.put<AppConfig>(AppConfig.fromEnv(), permanent: true);

    Get.put<FlutterSecureStorage>(
      const FlutterSecureStorage(),
      permanent: true,
    );

    Get.put<TokenStorage>(
      TokenStorage(Get.find<FlutterSecureStorage>()),
      permanent: true,
    );

    Get.put<HttpClient>(
      HttpClient(
        config: Get.find<AppConfig>(),
        tokenStorage: Get.find<TokenStorage>(),
      ),
      permanent: true,
    );
  }
}
```

- [ ] **Step 2: Verify it compiles**

Run: `flutter analyze lib/app/core/di/initial_binding.dart`

Expected: `No issues found!` (or only pre-existing warnings unrelated to this file).

- [ ] **Step 3: Commit**

```bash
git add lib/app/core/di/initial_binding.dart
git commit -m "feat(core): add InitialBinding skeleton

Registers AppConfig, FlutterSecureStorage, TokenStorage, HttpClient.
Not yet wired into main.dart — Batch 1 will add the call site
alongside the auth migration. Per-domain registrations land in
later batches as data sources/repositories are introduced."
```

---

## Task 11: Final verification

- [ ] **Step 1: Run the full test suite**

Run: `flutter test`

Expected: every test green. Including the original `test/unit_test.dart` and `test/widget_test.dart` (they still test trivial things and should be unaffected).

- [ ] **Step 2: Run the analyzer over the whole project**

Run: `flutter analyze`

Expected: no errors. Warnings/info from the legacy code are acceptable; we're explicitly leaving them for Batch 6.

- [ ] **Step 3: Verify the app still launches**

Run: `flutter run -d chrome` (or your usual target).

Expected: the app starts, the home screen appears, lists/details work as before. **None of the new code is on the runtime path yet** — the old `ApiService` is still doing the work. So if anything is broken, it's a regression we caused, not "the new stuff doesn't work."

Stop the app once you've confirmed it starts.

- [ ] **Step 4: Confirm git state**

Run: `git log --oneline -15`

Expected: a clean sequence of small commits, one per task. Work-tree should be clean (`git status`).

- [ ] **Step 5: Mark Batch 0 done**

No commit needed — Batch 0 is complete when all tests are green and the app still runs. The code path is fully shadowed: new infrastructure exists, tested, but unused. Batch 1 brings it online.

---

## Self-review

**Spec coverage** (against §14 "Batch 0 — Foundation"):
- Add `freezed`, `json_serializable`, `build_runner`, `mocktail` to `pubspec.yaml` → Task 1 ✓
- Tighten `analysis_options.yaml` → Task 1 (partial — full lint tightening deferred to Batch 6, documented at top) ✓
- Create new folders → deliberately deferred (folders appear when files appear) ✓
- Implement `AppConfig` → Task 4 ✓
- `AppException` hierarchy → Task 2 ✓
- `TokenStorage` → Task 3 ✓
- `HttpClient` with unit tests → Tasks 5-9 ✓
- Skeleton `InitialBinding` → Task 10 ✓
- Old `ApiService` still functional → confirmed in Task 11 step 3 ✓

**Placeholder scan:** none. Every step has full code or full commands. No "TBD", "TODO", "implement appropriately."

**Type consistency:**
- `HttpClient` constructor: `HttpClient({required AppConfig config, required TokenStorage tokenStorage, http.Client? inner})` — same shape used in tests, in `InitialBinding`, and in the implementation file. ✓
- `TokenStorage` API: `getToken()`, `setToken()`, `clearToken()` — used uniformly in tests and `HttpClient`. ✓
- `AppException`: `message` field on all subclasses; `statusCode` and `code` only on `ApiException`. Tests match. ✓
- `_decode` is private to `HttpClient`; tests exercise it through public `get`/`post`. ✓

**Scope:** Batch 0 only. Batches 1-6 will get their own plans, each producing working software at their boundary.

---

## Done criteria for Batch 0

- All 5 new source files exist and compile.
- All 4 new test files exist and pass (~21 tests for HttpClient + 5 for AppException + 4 for TokenStorage + 5 for AppConfig = ~35 tests).
- `flutter test` green; `flutter analyze` reports no errors.
- App still launches and behaves identically to before the refactor.
- Git history shows ~10 small, focused commits — one per task, sometimes per step.
