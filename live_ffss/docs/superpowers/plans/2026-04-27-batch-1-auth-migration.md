# Batch 1 — Auth Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate the Auth module end-to-end onto the Batch 0 infrastructure: typed `User` domain model + freezed DTOs, an `AuthRemoteDataSource` calling `HttpClient`, an `AuthRepository` returning domain types, and a refactored `AuthController` with constructor-injected dependencies and no `BuildContext`/form-state baggage. Wire `InitialBinding` into `main.dart`. Delete the legacy auth code at the end.

**Architecture:** Per design spec §6-9 ([2026-04-25-architecture-refactor-design.md](../specs/2026-04-25-architecture-refactor-design.md)). Three-layer pragmatic split applied to one domain (auth): `data/dtos/` ↔ `data/datasources/` ↔ `data/repositories/` ↔ `domain/models/`. `LoginView` becomes a `StatefulWidget` to own the form. The token + persisted user move from a 9-key secure-storage shred to a single JSON blob behind `TokenStorage` (token) + `UserService` (user JSON).

**Tech Stack:** freezed + json_serializable + build_runner (added in Batch 0), mocktail, GetX (DI/routing only — no `Get.snackbar`/`Get.dialog`/`Get.context!` in the new controllers).

---

## Notes & deviations from spec

1. **Scope discipline.** The spec also flags `UserController` and `ProfileController` as needing a controller-discipline cleanup (no `.tr` / `Get.snackbar` in controllers). That's a *cross-module* concern and most of those controllers' coupling will resolve naturally when their dependent batches land. **In this batch we only touch them enough to keep them compile-clean against the new `User` domain model.** Their full discipline pass moves to Batch 2 or wherever each controller's view is being touched. Documented at the top of the plan so it isn't a silent miss.

2. **Generated code (`.freezed.dart`, `.g.dart`) is committed.** Standard Flutter practice — treated as source, not build output. Each freezed task ends with `dart run build_runner build --delete-conflicting-outputs` and commits both the hand-written and generated files together.

3. **`AuthProvider` (legacy) is deleted as the final step**, not first, so the working tree compiles at every commit boundary (the legacy code keeps running until the new path is wired up via `InitialBinding`).

4. **`UserService` is rewritten in this batch** rather than left for later — its current shape (9 individual storage reads) is incompatible with the new single-JSON-blob persistence model, and `AuthRepository` needs it as the session holder.

5. **Logout strategy.** The legacy `UserController.logout()` does manual fallback via `FlutterSecureStorage.deleteAll()` and direct navigation. The refactored version delegates to `AuthRepository.logout()` (which calls `TokenStorage.clearToken()` and clears the persisted user) and exposes a `loggedOut` event the view watches for navigation. Eliminates the dual logout paths.

---

## File map

**Create (production):**
- `lib/app/domain/models/user.dart` — domain model (freezed, no JSON)
- `lib/app/data/dtos/auth_token_dto.dart` — `requestToken` response shape (freezed + json)
- `lib/app/data/dtos/user_dto.dart` — `me` response shape (freezed + json)
- `lib/app/data/mappers/user_mapper.dart` — `UserDto + tokenExpiration` → `User` extension
- `lib/app/data/datasources/auth_remote_datasource.dart` — abstract + Impl
- `lib/app/data/repositories/auth_repository.dart` — abstract + Impl (REPLACES the legacy file at the same path — note: the legacy file is `lib/app/data/repositories/auth_repository.dart`. Same path; file is fully rewritten.)

**Create (tests):**
- `test/data/mappers/user_mapper_test.dart`
- `test/data/repositories/auth_repository_test.dart`
- `test/presentation/modules/auth/controllers/auth_controller_test.dart`

**Modify:**
- `lib/main.dart` — call `InitialBinding.register()` instead of scattered `Get.putAsync`
- `lib/app/core/di/initial_binding.dart` — also register `UserService`, `AuthRemoteDataSource`, `AuthRepository`
- `lib/app/data/services/user_service.dart` — rewrite to load/save `User` (single key), drop the 9 individual reads
- `lib/app/module/auth/controllers/auth_controller.dart` — constructor inject `AuthRepository`; drop `TextEditingController`/`GlobalKey`/`onClose`; expose `Rxn<User> user`, `Rxn<AppException> error`, `RxBool isLoading`, `Rx<AuthEvent> event` for navigation triggers; remove `Get.snackbar`
- `lib/app/module/auth/views/login_view.dart` — convert to `StatefulWidget`; own form controllers/key; watch controller events; surface error message reactively
- `lib/app/module/auth/bindings/auth_binding.dart` — `AuthController(Get.find<AuthRepository>())` (constructor injection)
- `lib/app/module/auth/controllers/user_controller.dart` — switch to new `User` domain type; route logout through `AuthRepository`; **leave snackbars in place for now** (Batch-2+ cleanup)
- `lib/app/module/auth/controllers/profile_controller.dart` — switch to new `User` domain type (compile-only changes); leave `.tr`/`Get.snackbar` for later
- `lib/app/module/auth/views/profile_view.dart` — compile-only updates if `User` field renames change references
- `lib/app/module/auth/views/user_avatar.dart` — compile-only updates

**Delete (final task):**
- `lib/app/data/providers/auth_provider.dart`
- `lib/app/data/models/user_model.dart` (legacy class — replaced by `domain/models/user.dart`)

---

## Key types and contracts

### `User` (domain)

```dart
@freezed
class User with _$User {
  const factory User({
    required String token,
    required DateTime tokenExpiration,
    required String label,
    required UserType type,
    required UserRole role,
    String? firstName,
    String? lastName,
    String? licenseeNumber,
    String? clubName,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

enum UserType { licensee, organisme, unknown }
enum UserRole { admin, user, unknown }
```

`User.fromJson`/`toJson` exist so `UserService` can persist the full domain object as a single secure-storage value.

### `AuthTokenDto` (raw `requestToken` response)

```dart
@freezed
class AuthTokenDto with _$AuthTokenDto {
  const factory AuthTokenDto({
    required String token,
    required String expiration, // ISO 8601 string from server
  }) = _AuthTokenDto;

  factory AuthTokenDto.fromJson(Map<String, dynamic> json) =>
      _$AuthTokenDtoFromJson(json);
}
```

### `UserDto` (raw `me` response)

```dart
@freezed
class UserDto with _$UserDto {
  const factory UserDto({
    required String label,
    required String type,
    @JsonKey(name: 'data') required UserDtoData data,
  }) = _UserDto;

  factory UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json);
}

@freezed
class UserDtoData with _$UserDtoData {
  const factory UserDtoData({
    required String role,
    @JsonKey(name: 'nom') String? lastName,
    @JsonKey(name: 'prenom') String? firstName,
    @JsonKey(name: 'numero') String? licenseeNumber,
    @JsonKey(name: 'club') UserDtoClub? club,
  }) = _UserDtoData;

  factory UserDtoData.fromJson(Map<String, dynamic> json) =>
      _$UserDtoDataFromJson(json);
}

@freezed
class UserDtoClub with _$UserDtoClub {
  const factory UserDtoClub({
    required String label,
  }) = _UserDtoClub;

  factory UserDtoClub.fromJson(Map<String, dynamic> json) =>
      _$UserDtoClubFromJson(json);
}
```

### `UserMapper` extension

```dart
extension UserMapper on UserDto {
  User toDomain({required String token, required DateTime tokenExpiration}) =>
      User(
        token: token,
        tokenExpiration: tokenExpiration,
        label: label,
        type: _parseType(type),
        role: _parseRole(data.role),
        firstName: data.firstName,
        lastName: data.lastName,
        licenseeNumber: data.licenseeNumber,
        clubName: data.club?.label,
      );
}

UserType _parseType(String raw) => switch (raw) {
      'licencie' => UserType.licensee,
      'organisme' => UserType.organisme,
      _ => UserType.unknown,
    };

UserRole _parseRole(String raw) => switch (raw) {
      'admin' => UserRole.admin,
      'user' => UserRole.user,
      _ => UserRole.unknown,
    };
```

### `AuthRemoteDataSource`

```dart
abstract class AuthRemoteDataSource {
  Future<AuthTokenDto> requestToken({
    required String login,
    required String password,
  });
  Future<UserDto> getCurrentUser();
}
```

`requestToken` POSTs `requestToken?login=X&password=Y` (FFSS API uses query params for credentials — not ideal but matches the contract). `getCurrentUser` GETs `me` (token attached automatically by `HttpClient.Authorization` header).

### `AuthRepository`

```dart
abstract class AuthRepository {
  Future<User> login({required String login, required String password});
  Future<void> logout();
  Future<User?> restoreSession();
  Stream<User?> get userStream;
}
```

`login` orchestrates: requestToken → setToken → getCurrentUser → mapper → persist user JSON → emit on userStream.
`logout` clears token + persisted user, emits null.
`restoreSession` loads persisted user JSON (returns null if absent or token expired).

### `AuthController` (post-refactor)

```dart
class AuthController extends GetxController {
  AuthController(this._auth);
  final AuthRepository _auth;

  final Rxn<User> user = Rxn<User>();
  final RxBool isLoading = false.obs;
  final Rxn<AppException> error = Rxn<AppException>();
  final Rxn<AuthEvent> event = Rxn<AuthEvent>(); // navigation trigger

  Future<void> login({required String login, required String password}) async {
    isLoading.value = true;
    error.value = null;
    try {
      user.value = await _auth.login(login: login, password: password);
      event.value = AuthEvent.loggedIn;
    } on AppException catch (e) {
      error.value = e;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.logout();
      user.value = null;
      event.value = AuthEvent.loggedOut;
    } on AppException catch (e) {
      error.value = e;
    }
  }
}

enum AuthEvent { loggedIn, loggedOut }
```

No `TextEditingController`, no `GlobalKey`, no `Get.context!`, no `Get.snackbar`, no navigation. The view watches `event` with `ever()` and navigates accordingly.

---

## Task 1: User domain model (freezed)

**Files:**
- Create: `lib/app/domain/models/user.dart`

- [ ] **Step 1: Create the file**

Create `lib/app/domain/models/user.dart` with EXACTLY this content:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

enum UserType { licensee, organisme, unknown }

enum UserRole { admin, user, unknown }

@freezed
class User with _$User {
  const factory User({
    required String token,
    required DateTime tokenExpiration,
    required String label,
    required UserType type,
    required UserRole role,
    String? firstName,
    String? lastName,
    String? licenseeNumber,
    String? clubName,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

- [ ] **Step 2: Generate freezed code**

Run: `dart run build_runner build --delete-conflicting-outputs`

Expected: creates `lib/app/domain/models/user.freezed.dart` and `lib/app/domain/models/user.g.dart`. No errors.

- [ ] **Step 3: Verify it compiles**

Run: `flutter analyze lib/app/domain/models/`

Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/app/domain/models/user.dart lib/app/domain/models/user.freezed.dart lib/app/domain/models/user.g.dart
git commit -m "feat(domain): add User domain model

Freezed immutable record + UserType/UserRole enums + JSON serialization
for single-key persistence by UserService."
```

---

## Task 2: Auth DTOs (freezed + json_serializable)

**Files:**
- Create: `lib/app/data/dtos/auth_token_dto.dart`
- Create: `lib/app/data/dtos/user_dto.dart`

- [ ] **Step 1: Create `auth_token_dto.dart`**

Create `lib/app/data/dtos/auth_token_dto.dart` with EXACTLY this content:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_token_dto.freezed.dart';
part 'auth_token_dto.g.dart';

@freezed
class AuthTokenDto with _$AuthTokenDto {
  const factory AuthTokenDto({
    required String token,
    required String expiration,
  }) = _AuthTokenDto;

  factory AuthTokenDto.fromJson(Map<String, dynamic> json) =>
      _$AuthTokenDtoFromJson(json);
}
```

- [ ] **Step 2: Create `user_dto.dart`**

Create `lib/app/data/dtos/user_dto.dart` with EXACTLY this content:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_dto.freezed.dart';
part 'user_dto.g.dart';

@freezed
class UserDto with _$UserDto {
  const factory UserDto({
    required String label,
    required String type,
    required UserDtoData data,
  }) = _UserDto;

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);
}

@freezed
class UserDtoData with _$UserDtoData {
  const factory UserDtoData({
    required String role,
    @JsonKey(name: 'nom') String? lastName,
    @JsonKey(name: 'prenom') String? firstName,
    @JsonKey(name: 'numero') String? licenseeNumber,
    UserDtoClub? club,
  }) = _UserDtoData;

  factory UserDtoData.fromJson(Map<String, dynamic> json) =>
      _$UserDtoDataFromJson(json);
}

@freezed
class UserDtoClub with _$UserDtoClub {
  const factory UserDtoClub({
    required String label,
  }) = _UserDtoClub;

  factory UserDtoClub.fromJson(Map<String, dynamic> json) =>
      _$UserDtoClubFromJson(json);
}
```

- [ ] **Step 3: Generate code**

Run: `dart run build_runner build --delete-conflicting-outputs`

Expected: creates 6 generated files (`*.freezed.dart` and `*.g.dart` for each of the two DTO files).

- [ ] **Step 4: Verify**

Run: `flutter analyze lib/app/data/dtos/`

Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/app/data/dtos/auth_token_dto.dart \
        lib/app/data/dtos/auth_token_dto.freezed.dart \
        lib/app/data/dtos/auth_token_dto.g.dart \
        lib/app/data/dtos/user_dto.dart \
        lib/app/data/dtos/user_dto.freezed.dart \
        lib/app/data/dtos/user_dto.g.dart
git commit -m "feat(data): add AuthTokenDto and UserDto

Maps the FFSS requestToken and me endpoint responses 1:1.
French field names (nom, prenom, numero) renamed via @JsonKey."
```

---

## Task 3: UserMapper (DTO → domain)

**Files:**
- Create: `lib/app/data/mappers/user_mapper.dart`
- Create: `test/data/mappers/user_mapper_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/data/mappers/user_mapper_test.dart` with EXACTLY this content:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/dtos/user_dto.dart';
import 'package:live_ffss/app/data/mappers/user_mapper.dart';
import 'package:live_ffss/app/domain/models/user.dart';

void main() {
  final fixedExpiry = DateTime.utc(2030, 1, 1);
  const token = 'tok-abc';

  group('UserMapper', () {
    test('maps a licencie UserDto with admin role to User', () {
      const dto = UserDto(
        label: 'Doe John',
        type: 'licencie',
        data: UserDtoData(
          role: 'admin',
          lastName: 'Doe',
          firstName: 'John',
          licenseeNumber: '12345',
          club: UserDtoClub(label: 'Marseille SC'),
        ),
      );

      final user = dto.toDomain(token: token, tokenExpiration: fixedExpiry);

      expect(user.token, token);
      expect(user.tokenExpiration, fixedExpiry);
      expect(user.label, 'Doe John');
      expect(user.type, UserType.licensee);
      expect(user.role, UserRole.admin);
      expect(user.firstName, 'John');
      expect(user.lastName, 'Doe');
      expect(user.licenseeNumber, '12345');
      expect(user.clubName, 'Marseille SC');
    });

    test('maps an organisme UserDto with no personal fields', () {
      const dto = UserDto(
        label: 'CN Marseille',
        type: 'organisme',
        data: UserDtoData(role: 'user'),
      );

      final user = dto.toDomain(token: token, tokenExpiration: fixedExpiry);

      expect(user.type, UserType.organisme);
      expect(user.role, UserRole.user);
      expect(user.firstName, isNull);
      expect(user.lastName, isNull);
      expect(user.licenseeNumber, isNull);
      expect(user.clubName, isNull);
    });

    test('maps unknown type and role to UserType.unknown / UserRole.unknown',
        () {
      const dto = UserDto(
        label: 'X',
        type: 'martian',
        data: UserDtoData(role: 'overlord'),
      );

      final user = dto.toDomain(token: token, tokenExpiration: fixedExpiry);

      expect(user.type, UserType.unknown);
      expect(user.role, UserRole.unknown);
    });

    test('preserves token + tokenExpiration verbatim', () {
      const dto = UserDto(
        label: 'X',
        type: 'licencie',
        data: UserDtoData(role: 'user'),
      );

      final user = dto.toDomain(
        token: 'special-token',
        tokenExpiration: DateTime.utc(2099, 12, 31, 23, 59, 59),
      );

      expect(user.token, 'special-token');
      expect(user.tokenExpiration, DateTime.utc(2099, 12, 31, 23, 59, 59));
    });
  });
}
```

- [ ] **Step 2: Run, verify it fails**

Run: `flutter test test/data/mappers/user_mapper_test.dart`
Expected: import error for `user_mapper.dart`.

- [ ] **Step 3: Create the mapper**

Create `lib/app/data/mappers/user_mapper.dart` with EXACTLY this content:

```dart
import 'package:live_ffss/app/data/dtos/user_dto.dart';
import 'package:live_ffss/app/domain/models/user.dart';

extension UserMapper on UserDto {
  User toDomain({
    required String token,
    required DateTime tokenExpiration,
  }) =>
      User(
        token: token,
        tokenExpiration: tokenExpiration,
        label: label,
        type: _parseType(type),
        role: _parseRole(data.role),
        firstName: data.firstName,
        lastName: data.lastName,
        licenseeNumber: data.licenseeNumber,
        clubName: data.club?.label,
      );
}

UserType _parseType(String raw) => switch (raw) {
      'licencie' => UserType.licensee,
      'organisme' => UserType.organisme,
      _ => UserType.unknown,
    };

UserRole _parseRole(String raw) => switch (raw) {
      'admin' => UserRole.admin,
      'user' => UserRole.user,
      _ => UserRole.unknown,
    };
```

- [ ] **Step 4: Run, verify pass**

Run: `flutter test test/data/mappers/user_mapper_test.dart`
Expected: `All tests passed!` (4 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/app/data/mappers/user_mapper.dart test/data/mappers/user_mapper_test.dart
git commit -m "feat(data): add UserMapper extension

Translates UserDto + token/expiration pair to domain User.
French enum strings (licencie/organisme, admin/user) decoded to
typed enums; unknown values fall through to UserType.unknown."
```

---

## Task 4: AuthRemoteDataSource

**Files:**
- Create: `lib/app/data/datasources/auth_remote_datasource.dart`

This task has no separate test file — the data source is tested transitively through the repository tests in Task 5. Direct testing would require mocking `HttpClient`, which adds little value over mocking the whole datasource at the repository boundary.

- [ ] **Step 1: Create the file**

Create `lib/app/data/datasources/auth_remote_datasource.dart` with EXACTLY this content:

```dart
import 'package:live_ffss/app/core/config/app_config.dart';
import 'package:live_ffss/app/core/network/http_client.dart';
import 'package:live_ffss/app/data/dtos/auth_token_dto.dart';
import 'package:live_ffss/app/data/dtos/user_dto.dart';

abstract class AuthRemoteDataSource {
  Future<AuthTokenDto> requestToken({
    required String login,
    required String password,
  });

  Future<UserDto> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._http);

  final HttpClient _http;

  @override
  Future<AuthTokenDto> requestToken({
    required String login,
    required String password,
  }) async {
    final body = await _http.post(
      ApiEndpoints.requestToken,
      query: {'login': login, 'password': password},
    );
    return AuthTokenDto.fromJson(body);
  }

  @override
  Future<UserDto> getCurrentUser() async {
    final body = await _http.get(ApiEndpoints.me);
    return UserDto.fromJson(body);
  }
}
```

NB: `requestToken` legitimately puts credentials in query params because that's the FFSS server contract. Migrating away from this is a server-side concern, not ours. The token returned then flows through the secure `Authorization: Bearer` header on all subsequent calls.

- [ ] **Step 2: Verify it compiles**

Run: `flutter analyze lib/app/data/datasources/`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/app/data/datasources/auth_remote_datasource.dart
git commit -m "feat(data): add AuthRemoteDataSource

Abstract + Impl. Wraps the FFSS requestToken POST and the me GET.
HttpClient handles auth header injection, error mapping, and the
success-envelope check."
```

---

## Task 5: AuthRepository (replaces legacy file)

**Files:**
- Modify (rewrite): `lib/app/data/repositories/auth_repository.dart`
- Create: `test/data/repositories/auth_repository_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/data/repositories/auth_repository_test.dart` with EXACTLY this content:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/network/token_storage.dart';
import 'package:live_ffss/app/data/datasources/auth_remote_datasource.dart';
import 'package:live_ffss/app/data/dtos/auth_token_dto.dart';
import 'package:live_ffss/app/data/dtos/user_dto.dart';
import 'package:live_ffss/app/data/repositories/auth_repository.dart';
import 'package:live_ffss/app/domain/models/user.dart';
import 'package:mocktail/mocktail.dart';

class _MockDataSource extends Mock implements AuthRemoteDataSource {}

class _MockTokenStorage extends Mock implements TokenStorage {}

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockDataSource ds;
  late _MockTokenStorage tokens;
  late _MockSecureStorage secure;
  late AuthRepository repo;

  setUp(() {
    ds = _MockDataSource();
    tokens = _MockTokenStorage();
    secure = _MockSecureStorage();
    repo = AuthRepositoryImpl(
      dataSource: ds,
      tokenStorage: tokens,
      secureStorage: secure,
    );
  });

  group('AuthRepository.login', () {
    test('orchestrates: requestToken -> setToken -> getCurrentUser -> persist',
        () async {
      when(() => ds.requestToken(login: 'a', password: 'b')).thenAnswer(
          (_) async => const AuthTokenDto(
              token: 'T', expiration: '2030-01-01T00:00:00.000Z'));
      when(() => tokens.setToken('T')).thenAnswer((_) async {});
      when(() => ds.getCurrentUser()).thenAnswer((_) async => const UserDto(
            label: 'Doe John',
            type: 'licencie',
            data: UserDtoData(role: 'user', lastName: 'Doe', firstName: 'John'),
          ));
      when(() => secure.write(key: 'user', value: any(named: 'value')))
          .thenAnswer((_) async {});

      final user = await repo.login(login: 'a', password: 'b');

      expect(user.token, 'T');
      expect(user.label, 'Doe John');
      expect(user.firstName, 'John');
      expect(user.tokenExpiration, DateTime.utc(2030, 1, 1));
      verifyInOrder([
        () => ds.requestToken(login: 'a', password: 'b'),
        () => tokens.setToken('T'),
        () => ds.getCurrentUser(),
        () => secure.write(key: 'user', value: any(named: 'value')),
      ]);
    });

    test('emits the new user on userStream', () async {
      when(() => ds.requestToken(login: 'a', password: 'b')).thenAnswer(
          (_) async => const AuthTokenDto(
              token: 'T', expiration: '2030-01-01T00:00:00Z'));
      when(() => tokens.setToken(any())).thenAnswer((_) async {});
      when(() => ds.getCurrentUser()).thenAnswer((_) async => const UserDto(
            label: 'X',
            type: 'organisme',
            data: UserDtoData(role: 'admin'),
          ));
      when(() => secure.write(key: 'user', value: any(named: 'value')))
          .thenAnswer((_) async {});

      final stream = repo.userStream;
      final emitted = stream.first;

      await repo.login(login: 'a', password: 'b');

      final user = await emitted;
      expect(user, isNotNull);
      expect(user!.role, UserRole.admin);
    });
  });

  group('AuthRepository.logout', () {
    test('clears token + persisted user, emits null on userStream', () async {
      when(() => tokens.clearToken()).thenAnswer((_) async {});
      when(() => secure.delete(key: 'user')).thenAnswer((_) async {});

      final stream = repo.userStream;
      final emitted = stream.first;

      await repo.logout();

      verify(() => tokens.clearToken()).called(1);
      verify(() => secure.delete(key: 'user')).called(1);
      expect(await emitted, isNull);
    });
  });

  group('AuthRepository.restoreSession', () {
    test('returns null when nothing stored', () async {
      when(() => secure.read(key: 'user')).thenAnswer((_) async => null);

      expect(await repo.restoreSession(), isNull);
    });

    test('returns null when token is expired', () async {
      final past = DateTime.utc(2000, 1, 1).toIso8601String();
      when(() => secure.read(key: 'user')).thenAnswer((_) async => '''
{"token":"old","tokenExpiration":"$past","label":"X","type":"licensee","role":"user"}
''');
      when(() => tokens.clearToken()).thenAnswer((_) async {});
      when(() => secure.delete(key: 'user')).thenAnswer((_) async {});

      expect(await repo.restoreSession(), isNull);
      verify(() => tokens.clearToken()).called(1);
    });

    test('returns the persisted User when token is still valid', () async {
      final future = DateTime.utc(2099, 12, 31).toIso8601String();
      when(() => secure.read(key: 'user')).thenAnswer((_) async => '''
{"token":"good","tokenExpiration":"$future","label":"X","type":"licensee","role":"admin"}
''');

      final user = await repo.restoreSession();

      expect(user, isNotNull);
      expect(user!.token, 'good');
      expect(user.role, UserRole.admin);
    });
  });
}
```

- [ ] **Step 2: Run, verify it fails**

Run: `flutter test test/data/repositories/auth_repository_test.dart`
Expected: import error for the new `auth_repository.dart` shape (the legacy file at the same path has a different API).

- [ ] **Step 3: Rewrite the repository file**

REPLACE the entire content of `lib/app/data/repositories/auth_repository.dart` (currently uses `AuthProvider`) with EXACTLY this content:

```dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:live_ffss/app/core/network/token_storage.dart';
import 'package:live_ffss/app/data/datasources/auth_remote_datasource.dart';
import 'package:live_ffss/app/data/mappers/user_mapper.dart';
import 'package:live_ffss/app/domain/models/user.dart';

abstract class AuthRepository {
  Future<User> login({required String login, required String password});
  Future<void> logout();
  Future<User?> restoreSession();
  Stream<User?> get userStream;
}

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource dataSource,
    required TokenStorage tokenStorage,
    required FlutterSecureStorage secureStorage,
  })  : _dataSource = dataSource,
        _tokenStorage = tokenStorage,
        _secureStorage = secureStorage;

  static const _userKey = 'user';

  final AuthRemoteDataSource _dataSource;
  final TokenStorage _tokenStorage;
  final FlutterSecureStorage _secureStorage;
  final StreamController<User?> _userController =
      StreamController<User?>.broadcast();

  @override
  Stream<User?> get userStream => _userController.stream;

  @override
  Future<User> login({
    required String login,
    required String password,
  }) async {
    final tokenDto =
        await _dataSource.requestToken(login: login, password: password);
    await _tokenStorage.setToken(tokenDto.token);

    final userDto = await _dataSource.getCurrentUser();
    final user = userDto.toDomain(
      token: tokenDto.token,
      tokenExpiration: DateTime.parse(tokenDto.expiration),
    );

    await _secureStorage.write(
      key: _userKey,
      value: jsonEncode(user.toJson()),
    );
    _userController.add(user);
    return user;
  }

  @override
  Future<void> logout() async {
    await _tokenStorage.clearToken();
    await _secureStorage.delete(key: _userKey);
    _userController.add(null);
  }

  @override
  Future<User?> restoreSession() async {
    final raw = await _secureStorage.read(key: _userKey);
    if (raw == null || raw.isEmpty) return null;

    final json = jsonDecode(raw) as Map<String, dynamic>;
    final user = User.fromJson(json);

    if (user.tokenExpiration.isBefore(DateTime.now().toUtc())) {
      // Token expired — clean up so we don't hand back a stale session.
      await _tokenStorage.clearToken();
      await _secureStorage.delete(key: _userKey);
      return null;
    }

    return user;
  }
}
```

- [ ] **Step 4: Run, verify pass**

Run: `flutter test test/data/repositories/auth_repository_test.dart`
Expected: `All tests passed!` (5 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/app/data/repositories/auth_repository.dart \
        test/data/repositories/auth_repository_test.dart
git commit -m "feat(data): rewrite AuthRepository on the new infrastructure

Composes AuthRemoteDataSource + TokenStorage + FlutterSecureStorage.
Persists the full User as a single JSON blob under the 'user' key
(replaces the 9-key shred). Exposes a userStream broadcast for
reactive consumers. restoreSession discards expired tokens."
```

---

## Task 6: UserService rewrite

The legacy `UserService` does its own 9-individual-keys read in `checkUserSession`. Now it delegates to `AuthRepository.restoreSession()`. It still owns the *current user* observable for backwards compatibility with `UserController`/`ProfileController`.

**Files:**
- Modify (rewrite): `lib/app/data/services/user_service.dart`

- [ ] **Step 1: Replace the file**

REPLACE the entire content of `lib/app/data/services/user_service.dart` with EXACTLY this content:

```dart
import 'dart:async';

import 'package:get/get.dart';
import 'package:live_ffss/app/data/repositories/auth_repository.dart';
import 'package:live_ffss/app/domain/models/user.dart';

class UserService extends GetxService {
  UserService(this._auth);

  final AuthRepository _auth;
  final Rx<User?> currentUser = Rx<User?>(null);
  StreamSubscription<User?>? _sub;

  Future<UserService> init() async {
    currentUser.value = await _auth.restoreSession();
    _sub = _auth.userStream.listen((user) => currentUser.value = user);
    return this;
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  bool get isLoggedIn => currentUser.value != null;

  String? get userFirstLetter {
    final u = currentUser.value;
    if (u == null || u.label.isEmpty) return null;
    return u.label[0].toUpperCase();
  }
}
```

- [ ] **Step 2: Verify it compiles**

Run: `flutter analyze lib/app/data/services/user_service.dart`
Expected: `No issues found!`

(Other files referencing the OLD `UserService.setCurrentUser`/`clearCurrentUser`/`checkUserSession` signatures will now have analyzer errors — they're fixed in Tasks 8 and 11. That's expected at this commit boundary; the next task that touches those files will resolve them.)

- [ ] **Step 3: Commit**

```bash
git add lib/app/data/services/user_service.dart
git commit -m "refactor(data): UserService now delegates to AuthRepository

Single source of truth for the current user moves to the repository.
UserService becomes a thin reactive wrapper over the userStream so
existing GetX consumers (UserController/ProfileController) keep working.
Will introduce transient analyzer errors on those callers — fixed in
the next two commits."
```

---

## Task 7: AuthController refactor

**Files:**
- Modify (rewrite): `lib/app/module/auth/controllers/auth_controller.dart`
- Create: `test/presentation/modules/auth/controllers/auth_controller_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/presentation/modules/auth/controllers/auth_controller_test.dart` with EXACTLY this content:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/auth_repository.dart';
import 'package:live_ffss/app/domain/models/user.dart';
import 'package:live_ffss/app/module/auth/controllers/auth_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repo;
  late AuthController controller;

  final fakeUser = User(
    token: 'T',
    tokenExpiration: DateTime.utc(2030, 1, 1),
    label: 'X',
    type: UserType.licensee,
    role: UserRole.user,
  );

  setUp(() {
    repo = _MockAuthRepository();
    controller = AuthController(repo);
  });

  group('AuthController.login', () {
    test('on success: sets user, fires loggedIn event, clears error', () async {
      when(() => repo.login(login: 'a', password: 'b'))
          .thenAnswer((_) async => fakeUser);

      await controller.login(login: 'a', password: 'b');

      expect(controller.user.value, fakeUser);
      expect(controller.error.value, isNull);
      expect(controller.event.value, AuthEvent.loggedIn);
      expect(controller.isLoading.value, false);
    });

    test('on AppException: sets error, leaves user null, no event', () async {
      const failure = ApiException('Invalid credentials', statusCode: 401);
      when(() => repo.login(login: 'a', password: 'b')).thenThrow(failure);

      await controller.login(login: 'a', password: 'b');

      expect(controller.user.value, isNull);
      expect(controller.error.value, failure);
      expect(controller.event.value, isNull);
      expect(controller.isLoading.value, false);
    });

    test('isLoading is true while in flight', () async {
      var seenLoadingTrue = false;
      when(() => repo.login(login: 'a', password: 'b')).thenAnswer((_) async {
        seenLoadingTrue = controller.isLoading.value;
        return fakeUser;
      });

      await controller.login(login: 'a', password: 'b');

      expect(seenLoadingTrue, true);
      expect(controller.isLoading.value, false);
    });
  });

  group('AuthController.logout', () {
    test('clears user and fires loggedOut event', () async {
      controller.user.value = fakeUser;
      when(() => repo.logout()).thenAnswer((_) async {});

      await controller.logout();

      expect(controller.user.value, isNull);
      expect(controller.event.value, AuthEvent.loggedOut);
    });

    test('on AppException sets error, leaves user untouched', () async {
      controller.user.value = fakeUser;
      const failure = NetworkException('offline');
      when(() => repo.logout()).thenThrow(failure);

      await controller.logout();

      expect(controller.user.value, fakeUser);
      expect(controller.error.value, failure);
    });
  });
}
```

- [ ] **Step 2: Run, verify it fails**

Run: `flutter test test/presentation/modules/auth/controllers/auth_controller_test.dart`
Expected: import errors / type mismatches against the legacy AuthController.

- [ ] **Step 3: Rewrite AuthController**

REPLACE the entire content of `lib/app/module/auth/controllers/auth_controller.dart` with EXACTLY this content:

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/auth_repository.dart';
import 'package:live_ffss/app/domain/models/user.dart';

enum AuthEvent { loggedIn, loggedOut }

class AuthController extends GetxController {
  AuthController(this._auth);

  final AuthRepository _auth;

  final Rxn<User> user = Rxn<User>();
  final RxBool isLoading = false.obs;
  final Rxn<AppException> error = Rxn<AppException>();
  final Rxn<AuthEvent> event = Rxn<AuthEvent>();

  Future<void> login({
    required String login,
    required String password,
  }) async {
    isLoading.value = true;
    error.value = null;
    try {
      user.value = await _auth.login(login: login, password: password);
      event.value = AuthEvent.loggedIn;
    } on AppException catch (e) {
      error.value = e;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.logout();
      user.value = null;
      event.value = AuthEvent.loggedOut;
    } on AppException catch (e) {
      error.value = e;
    }
  }
}
```

No `TextEditingController`. No `GlobalKey`. No `Get.snackbar`. No `Get.offAllNamed`. No `Get.find()` inside the body. Form state and navigation move to the view.

- [ ] **Step 4: Run, verify pass**

Run: `flutter test test/presentation/modules/auth/controllers/auth_controller_test.dart`
Expected: `All tests passed!` (5 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/app/module/auth/controllers/auth_controller.dart \
        test/presentation/modules/auth/controllers/auth_controller_test.dart
git commit -m "refactor(auth): controller is a pure state machine

Constructor-injects AuthRepository. Form state, navigation, and
snackbars move to LoginView. Exposes Rxn<User>/RxBool/Rxn<AppException>
plus an Rxn<AuthEvent> for navigation triggers. Tested against a
mocked repository."
```

---

## Task 8: LoginView refactor (StatefulWidget)

**Files:**
- Modify (rewrite): `lib/app/module/auth/views/login_view.dart`
- Modify: `lib/app/module/auth/bindings/auth_binding.dart`

- [ ] **Step 1: Update the binding to constructor-inject the repository**

REPLACE `lib/app/module/auth/bindings/auth_binding.dart` with EXACTLY this content:

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/data/repositories/auth_repository.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(
      () => AuthController(Get.find<AuthRepository>()),
    );
  }
}
```

`AuthRepository` itself is registered as a singleton in `InitialBinding` (Task 10).

- [ ] **Step 2: Rewrite the view as a StatefulWidget**

REPLACE the entire content of `lib/app/module/auth/views/login_view.dart` with EXACTLY this content:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/utils/validators.dart';
import 'package:live_ffss/app/module/auth/controllers/auth_controller.dart';
import 'package:live_ffss/app/routes/app_pages.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final AuthController _controller = Get.find<AuthController>();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Worker? _eventWorker;

  @override
  void initState() {
    super.initState();
    _eventWorker = ever<AuthEvent?>(_controller.event, (e) {
      if (e == AuthEvent.loggedIn) {
        Get.offAllNamed(Routes.home);
      }
    });
  }

  @override
  void dispose() {
    _eventWorker?.dispose();
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _controller.login(
      login: _idController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('login'.tr), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  kToolbarHeight -
                  48,
            ),
            child: IntrinsicHeight(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    Icon(
                      Icons.lock_outline,
                      size: 80,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _idController,
                      decoration: InputDecoration(
                        labelText: 'id'.tr,
                        prefixIcon: const Icon(Icons.person_outline),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmail,
                      autocorrect: false,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'password'.tr,
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: Validators.validatePassword,
                    ),
                    const SizedBox(height: 32),
                    Obx(() => ElevatedButton(
                          onPressed:
                              _controller.isLoading.value ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _controller.isLoading.value
                              ? const CircularProgressIndicator()
                              : Text('login'.tr),
                        )),
                    Obx(() {
                      final err = _controller.error.value;
                      if (err == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          err.message,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Verify it compiles**

Run: `flutter analyze lib/app/module/auth/`
Expected: `No issues found!` for `login_view.dart` and `auth_binding.dart`. (`user_controller.dart` and `profile_controller.dart` will still error out — fixed in Tasks 9 and 11.)

- [ ] **Step 4: Commit**

```bash
git add lib/app/module/auth/views/login_view.dart \
        lib/app/module/auth/bindings/auth_binding.dart
git commit -m "refactor(auth): LoginView owns form state, watches AuthEvent

StatefulWidget hosts TextEditingController/GlobalKey. Subscribes to
controller.event via ever() and navigates on AuthEvent.loggedIn.
Error message rendered reactively from controller.error.
AuthBinding now constructor-injects AuthRepository."
```

---

## Task 9: UserController compile-fix (minimal)

The legacy `UserController` calls `_userService.setCurrentUser` / `clearCurrentUser` / accesses `_userService.isLoggedIn` (now a getter that returns `bool`, not `Rx<bool>`). Goal of THIS task: keep it compiling against the new `UserService`/`AuthRepository`. **Do not** clean up `Get.snackbar`/`.tr` — that's for a later batch.

**Files:**
- Modify: `lib/app/module/auth/controllers/user_controller.dart`

- [ ] **Step 1: Apply the compile-fix rewrite**

REPLACE the entire content of `lib/app/module/auth/controllers/user_controller.dart` with EXACTLY this content:

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/data/repositories/auth_repository.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import 'package:live_ffss/app/module/auth/controllers/auth_controller.dart';
import 'package:live_ffss/app/module/home/controllers/home_controller.dart';
import 'package:live_ffss/app/routes/app_pages.dart';

class UserController extends GetxController {
  final UserService _userService = Get.find<UserService>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  bool get isLoggedIn => _userService.isLoggedIn;
  String? get userFirstLetter => _userService.userFirstLetter;

  Rx<bool> get isUserLoggedIn => _userService.isLoggedIn.obs;

  void navigateToLogin() {
    try {
      Get.toNamed(Routes.login);
    } catch (e) {
      _showErrorSnackbar('navigation_error'.tr);
    }
  }

  void navigateToProfile() {
    try {
      if (!isLoggedIn) {
        navigateToLogin();
        return;
      }
      Get.toNamed(Routes.profile);
    } catch (e) {
      _showErrorSnackbar('navigation_error'.tr);
    }
  }

  void navigateToSettings() {
    try {
      if (!isLoggedIn) {
        navigateToLogin();
        return;
      }
      Get.toNamed(Routes.settings);
    } catch (e) {
      _showErrorSnackbar('navigation_error'.tr);
    }
  }

  Future<void> logout() async {
    try {
      // Refresh dependent controllers BEFORE the user is cleared so they can
      // capture any state they need.
      _refreshDependentControllers();

      // If AuthController is around, prefer it (so its event stream fires).
      if (Get.isRegistered<AuthController>()) {
        await Get.find<AuthController>().logout();
      } else {
        await _authRepository.logout();
      }
      _showSuccessSnackbar('logout_success'.tr);
      Get.offAllNamed(Routes.home);
    } catch (e) {
      // Last-ditch fallback: clear the repo state and navigate.
      try {
        await _authRepository.logout();
      } catch (_) {
        // Ignore — UserService stream still observed currentUser==null
        // if either path completed.
      }
      Get.offAllNamed(Routes.home);
    }
  }

  void _refreshDependentControllers() {
    if (Get.isRegistered<HomeController>()) {
      try {
        Get.find<HomeController>().refreshAfterLogout();
      } catch (_) {/* ignore */}
    }
    Get.forceAppUpdate();
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'error'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
      duration: const Duration(seconds: 3),
    );
  }

  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'success'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Get.theme.colorScheme.onPrimary,
      duration: const Duration(seconds: 2),
    );
  }
}
```

Key changes from legacy:
- Drops the direct `FlutterSecureStorage.deleteAll()` fallback (token/user clearing now goes through `AuthRepository.logout()`).
- `_userService.isLoggedIn` is now a `bool` getter (was a `Rx<bool>` in the legacy interface — though the previous code was already calling it as a bool).
- The Get.snackbar / .tr / navigation are kept exactly as before. Discipline cleanup deferred.

- [ ] **Step 2: Verify it compiles**

Run: `flutter analyze lib/app/module/auth/controllers/user_controller.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/app/module/auth/controllers/user_controller.dart
git commit -m "refactor(auth): UserController compiles against new UserService

Drops the FlutterSecureStorage.deleteAll fallback in logout — token
and user clearing now run through AuthRepository.logout() exclusively.
Get.snackbar/.tr usage left in place; full discipline cleanup deferred
to the batch that touches the corresponding view."
```

---

## Task 10: ProfileController + views compile-fix

**Files:**
- Modify: `lib/app/module/auth/controllers/profile_controller.dart`
- Modify (only if necessary): `lib/app/module/auth/views/profile_view.dart`
- Modify (only if necessary): `lib/app/module/auth/views/user_avatar.dart`

The new `User` domain has `clubName` (was `club`), `licenseeNumber` (was `number`), and `tokenExpiration` (was `tokenExpirationDate`). Field renames must be propagated.

- [ ] **Step 1: Replace ProfileController**

REPLACE the entire content of `lib/app/module/auth/controllers/profile_controller.dart` with EXACTLY this content:

```dart
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import 'package:live_ffss/app/domain/models/user.dart';
import 'package:live_ffss/app/module/auth/controllers/user_controller.dart';
import 'package:live_ffss/app/module/home/controllers/home_controller.dart';

class ProfileController extends GetxController {
  final UserService _userService = Get.find<UserService>();
  final UserController _userController = Get.find<UserController>();

  bool get isLoggedIn => _userService.isLoggedIn;
  User? get currentUser => _userService.currentUser.value;

  String get userDisplayName {
    final u = currentUser;
    if (u == null) return 'unknown_user'.tr;
    if (hasFirstName && hasLastName) return '${u.firstName} ${u.lastName}';
    if (hasFirstName) return u.firstName!;
    if (hasLastName) return u.lastName!;
    return u.label;
  }

  String get userInitials {
    final u = currentUser;
    if (u == null) return '?';
    if (hasFirstName && hasLastName) return '${u.firstName![0]}${u.lastName![0]}';
    if (hasFirstName) return u.firstName![0];
    if (hasLastName) return u.lastName![0];
    return u.label.isNotEmpty ? u.label[0] : '?';
  }

  String get userLabel => currentUser?.label ?? 'unknown'.tr;
  String? get firstName => currentUser?.firstName;
  String? get lastName => currentUser?.lastName;
  String? get licenseeNumber => currentUser?.licenseeNumber;
  String? get clubName => currentUser?.clubName;

  String get userTypeLabel {
    final u = currentUser;
    if (u == null) return 'unknown'.tr;
    return switch (u.type) {
      UserType.licensee => 'licensee'.tr,
      UserType.organisme => 'organisme'.tr,
      UserType.unknown => 'unknown'.tr,
    };
  }

  String get userRole {
    final u = currentUser;
    if (u == null) return 'unknown'.tr;
    return switch (u.role) {
      UserRole.admin => 'administrator'.tr,
      UserRole.user => 'user'.tr,
      UserRole.unknown => 'unknown'.tr,
    };
  }

  String? get birthYear => null;

  String get tokenExpirationFormatted {
    final exp = currentUser?.tokenExpiration;
    if (exp == null) return 'unknown'.tr;
    if (exp.isBefore(DateTime.now())) return 'expired'.tr;
    return DateFormat('dd/MM/yyyy HH:mm').format(exp);
  }

  String get sessionStatus {
    if (!isLoggedIn) return 'not_connected'.tr;
    final exp = currentUser?.tokenExpiration;
    if (exp == null) return 'unknown'.tr;
    final now = DateTime.now();
    if (exp.isBefore(now)) return 'session_expired'.tr;
    final d = exp.difference(now);
    if (d.inDays > 0) return 'expires_in_days'.trParams({'days': d.inDays.toString()});
    if (d.inHours > 0) return 'expires_in_hours'.trParams({'hours': d.inHours.toString()});
    return 'expires_soon'.tr;
  }

  bool get hasFirstName => currentUser?.firstName?.isNotEmpty == true;
  bool get hasLastName => currentUser?.lastName?.isNotEmpty == true;
  bool get hasLicenseeNumber => currentUser?.licenseeNumber?.isNotEmpty == true;
  bool get hasClub => currentUser?.clubName?.isNotEmpty == true;
  bool get hasYear => birthYear?.isNotEmpty == true;
  bool get isLicensee => currentUser?.type == UserType.licensee;
  bool get isOrganization => currentUser?.type == UserType.organisme;

  void navigateToLogin() => _userController.navigateToLogin();

  Future<void> logout() async {
    _refreshDependentControllers();
    await _userController.logout();
  }

  void _refreshDependentControllers() {
    if (Get.isRegistered<HomeController>()) {
      try {
        Get.find<HomeController>().refreshAfterLogout();
      } catch (_) {/* ignore */}
    }
    Get.forceAppUpdate();
  }

  Future<void> refreshProfile() async {
    // Re-fetching user info is owned by AuthRepository.restoreSession() and
    // will be wired up in a later batch when the profile gains a refresh button.
    Get.snackbar(
      'success'.tr,
      'profile_refreshed'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Get.theme.colorScheme.onPrimary,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void onInit() {
    super.onInit();
    ever(_userService.currentUser, (_) => update());
  }
}
```

- [ ] **Step 2: Run analyzer over the auth module**

Run: `flutter analyze lib/app/module/auth/`

If errors appear in `profile_view.dart` or `user_avatar.dart` because they reference old field names (e.g., `currentUser.club` or `currentUser.number`), fix them with simple find-and-replace:

| Old | New |
|---|---|
| `currentUser.club` | `currentUser.clubName` |
| `currentUser.number` | `currentUser.licenseeNumber` |
| `currentUser.tokenExpirationDate` | `currentUser.tokenExpiration` |

Edit ONLY the offending lines. Do not refactor view structure.

If there are NO errors in those files, no changes needed — skip and proceed to Step 3.

- [ ] **Step 3: Verify the whole module compiles**

Run: `flutter analyze lib/app/module/auth/`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/app/module/auth/controllers/profile_controller.dart \
        lib/app/module/auth/views/
git commit -m "refactor(auth): ProfileController switches to new User type

Field renames (clubName/licenseeNumber/tokenExpiration), enum-based
type/role formatting via switch expressions. UI side-effects in this
controller stay for now — full discipline cleanup at the batch that
revisits the profile view."
```

---

## Task 11: Wire `InitialBinding` into `main.dart`

**Files:**
- Modify: `lib/app/core/di/initial_binding.dart`
- Modify: `lib/main.dart`

- [ ] **Step 1: Extend InitialBinding with the auth-layer registrations**

REPLACE the entire content of `lib/app/core/di/initial_binding.dart` with EXACTLY this content:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/config/app_config.dart';
import 'package:live_ffss/app/core/network/http_client.dart';
import 'package:live_ffss/app/core/network/token_storage.dart';
import 'package:live_ffss/app/core/services/language_service.dart';
import 'package:live_ffss/app/data/datasources/auth_remote_datasource.dart';
import 'package:live_ffss/app/data/repositories/auth_repository.dart';
import 'package:live_ffss/app/data/services/user_service.dart';

class InitialBinding {
  InitialBinding._();

  static Future<void> register() async {
    // 1. Config
    Get.put<AppConfig>(AppConfig.fromEnv(), permanent: true);

    // 2. Storage
    Get.put<FlutterSecureStorage>(
      const FlutterSecureStorage(),
      permanent: true,
    );
    Get.put<TokenStorage>(
      TokenStorage(Get.find<FlutterSecureStorage>()),
      permanent: true,
    );

    // 3. HTTP
    Get.put<HttpClient>(
      HttpClient(
        config: Get.find<AppConfig>(),
        tokenStorage: Get.find<TokenStorage>(),
      ),
      permanent: true,
    );

    // 4. Auth data layer
    Get.put<AuthRemoteDataSource>(
      AuthRemoteDataSourceImpl(Get.find<HttpClient>()),
      permanent: true,
    );
    Get.put<AuthRepository>(
      AuthRepositoryImpl(
        dataSource: Get.find<AuthRemoteDataSource>(),
        tokenStorage: Get.find<TokenStorage>(),
        secureStorage: Get.find<FlutterSecureStorage>(),
      ),
      permanent: true,
    );

    // 5. Long-lived state holders (depend on the auth repo)
    await Get.putAsync<UserService>(
      () async => UserService(Get.find<AuthRepository>()).init(),
    );
    await Get.putAsync<LanguageService>(
      () async => LanguageService().init(),
    );
  }
}
```

- [ ] **Step 2: Replace `main.dart`**

REPLACE the entire content of `lib/main.dart` with EXACTLY this content:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/di/initial_binding.dart';
import 'package:live_ffss/app/core/services/language_service.dart';
import 'package:live_ffss/app/core/themes/app_theme.dart';
import 'package:live_ffss/app/core/translations/app_translations.dart';
import 'package:live_ffss/app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await InitialBinding.register();

  final languageService = Get.find<LanguageService>();
  final initialLocale = languageService
      .getLocaleFromString(languageService.currentLanguage.value);

  runApp(
    GetMaterialApp(
      title: 'app_title'.tr,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      theme: appThemeData,
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: initialLocale,
      fallbackLocale: const Locale('fr', 'FR'),
    ),
  );
}
```

Note: the legacy `ApiService` is no longer registered in `main.dart`. Other callers (`HomeController`, `CompetitionDetailController`, `ProgramController`, `SlotController`, etc.) still construct it via `Get.find<ApiService>()`. We need to keep `ApiService` registered for them OR they'll fail at runtime — see Step 3.

- [ ] **Step 3: Keep the legacy ApiService registered (transitional)**

INSIDE `InitialBinding.register()`, AFTER the AuthRepository registration but BEFORE the `Get.putAsync` for UserService, add a **transitional** registration of the legacy `ApiService`. This block stays until Batches 3-5 fully migrate the remaining domains.

In `lib/app/core/di/initial_binding.dart`, in the section labeled `// 4. Auth data layer`, after `Get.put<AuthRepository>(...)` and before the `// 5. Long-lived state holders` comment, insert:

```dart
    // Transitional: legacy ApiService stays alive until per-domain data
    // sources replace it in Batches 3-5.
    Get.put<ApiService>(ApiService(), permanent: true);
```

And add this import at the top of the file:

```dart
import 'package:live_ffss/app/data/services/api_service.dart';
```

- [ ] **Step 4: Run the analyzer over the project**

Run: `flutter analyze`
Expected: zero errors. Pre-existing legacy warnings/infos are acceptable.

- [ ] **Step 5: Run all tests**

Run: `flutter test`
Expected: `All tests passed!`. Tests added in Batch 1 join the Batch 0 suite for a total around 60 tests.

- [ ] **Step 6: Commit**

```bash
git add lib/app/core/di/initial_binding.dart lib/main.dart
git commit -m "feat(core): wire InitialBinding into main; register auth layer

main.dart now calls InitialBinding.register() once. The new auth
data sources, repositories, and the rebuilt UserService are
registered here. ApiService is kept registered transitionally
until Batches 3-5 retire it."
```

---

## Task 12: Demolition + final verification

**Files:**
- Delete: `lib/app/data/providers/auth_provider.dart`
- Delete: `lib/app/data/models/user_model.dart`
- Verify: full test suite + analyzer + smoke-test branch state

- [ ] **Step 1: Confirm nothing imports the legacy classes**

Run: `flutter analyze`
Expected: no errors. (Files referenced by other modules — `ApiService`, `competition_repository.dart`, etc. — should not need `user_model.dart` or `auth_provider.dart`.)

If anything still imports them, STOP and report — those references should have been migrated by Tasks 5-10. Do NOT delete the files; ask for direction.

If only `auth_provider.dart` and `user_model.dart` themselves are unreferenced, proceed.

- [ ] **Step 2: Delete the legacy files**

```bash
git rm lib/app/data/providers/auth_provider.dart
git rm lib/app/data/models/user_model.dart
```

If `lib/app/data/providers/` becomes empty, it stays in the working tree (Dart doesn't track empty dirs; `git` won't either).

- [ ] **Step 3: Run analyzer and tests once more**

Run: `flutter analyze`
Run: `flutter test`

Expected: zero errors, all tests green.

- [ ] **Step 4: Commit the deletions**

```bash
git commit -m "chore(auth): delete legacy AuthProvider and UserModel

Replaced by AuthRemoteDataSource, AuthRepositoryImpl, and the freezed
User domain model. Marks the end of Batch 1 (Auth migration)."
```

- [ ] **Step 5: Final verification report**

Run these and confirm in the report:
- `git log --oneline main..HEAD` — should show ~12 commits for Batch 1.
- `git diff main..HEAD --stat` — total LOC change.
- `flutter analyze` — zero errors.
- `flutter test` — all green, ~60 tests.

- [ ] **Step 6 (manual, by user): Smoke-test the login flow**

Run the app: `flutter run`. Log in, check that:
- The home loads pre-login.
- Tapping "login" opens `LoginView` with the form.
- A wrong password surfaces an error message under the button.
- A correct password navigates back to home.
- Profile view shows the logged-in user.
- Logout returns to home and the login button reappears.

This step requires real credentials and a working network connection — not something a subagent or analyzer can verify.

---

## Self-review

**Spec coverage** (against §14 "Batch 1 — Migrate Auth"):
- `UserDto` (freezed) replacing the 9-key shred → Task 2 ✓
- `AuthRemoteDataSource` + `AuthRepository` → Tasks 4 + 5 ✓
- `AuthController` constructor-injects `AuthRepository`. Snackbars/dialogs move to `LoginView` → Tasks 7 + 8 ✓
- Unit tests: `UserDtoMapper`, `AuthRepository` (mocked datasource), `AuthController` (mocked repo) → Tasks 3 + 5 + 7 ✓
- Delete `AuthProvider` → Task 12 ✓
- Domain model `User` (implicit in spec; required for repo return type) → Task 1 ✓
- `UserService` rewrite (transitive — old API breaks with new domain type) → Task 6 ✓
- `InitialBinding` wired into `main.dart` (spec §9 + Batch 0 deferred) → Task 11 ✓
- `UserController`/`ProfileController` compile-fixes → Tasks 9 + 10 ✓

**Placeholder scan:** None. The one explicit deferral (Batch-2+ discipline cleanup of `UserController`/`ProfileController` snackbars) is documented at the top and called out in Tasks 9 and 10 with rationale.

**Type consistency:**
- `AuthRepository` constructor: `AuthRepositoryImpl({required AuthRemoteDataSource dataSource, required TokenStorage tokenStorage, required FlutterSecureStorage secureStorage})` — used identically in Task 5 (impl), Task 5 (test), and Task 11 (binding registration). ✓
- `AuthController` constructor: `AuthController(this._auth)` — same in Task 7 (impl + test) and Task 8 (binding). ✓
- `User` field names (`tokenExpiration`, `clubName`, `licenseeNumber`) — consistent across Task 1 (model), Task 3 (mapper), Task 5 (repo), Task 10 (ProfileController). ✓
- `UserService` constructor: `UserService(this._auth)` — consistent between Task 6 (impl) and Task 11 (registration). ✓
- `UserDtoData` field `licenseeNumber` (mapped from `numero`) — consistent. ✓

---

## Done criteria for Batch 1

- All 12 commits on a feature branch (`refactor/batch-1-auth` or back on `refactor/architecture`).
- New files: 1 domain model + 3 DTOs + 1 mapper + 1 datasource + 1 repository + 3 test files = 9 hand-written + 6 generated.
- Modified files: `main.dart`, `initial_binding.dart`, `user_service.dart`, `auth_controller.dart`, `login_view.dart`, `auth_binding.dart`, `user_controller.dart`, `profile_controller.dart`, possibly `profile_view.dart`/`user_avatar.dart`.
- Deleted: `auth_provider.dart`, `user_model.dart`.
- `flutter analyze`: zero errors.
- `flutter test`: ~60 tests, all green (Batch 0's 44 + ~16 new in Batch 1).
- App still launches and login/logout flow still works (manual smoke test).
- Legacy `ApiService` still registered transitionally for Batches 3-5 to consume.
