# Architecture Refactor — Design Spec

**Date:** 2026-04-25
**Author:** Stan
**Project:** live_ffss (Flutter app for FFSS live competition tracking)
**Status:** Approved by user, ready for implementation plan

---

## 1. Context

`live_ffss` is a Flutter / GetX app that consumes the FFSS (Fédération Française de Sauvetage et de Secourisme) public REST API to display competitions, programs, and live results. The app currently has 7,800 lines of Dart across ~70 files.

The codebase is functional but has accumulated architectural debt:

- A 468-line `ApiService` god class handles every HTTP endpoint (competition, race, club, entry, heat, meeting, run, result) plus parsing and shared state.
- Layering is inconsistent: `auth` uses Provider→Repository→Controller; everything else routes controllers directly to `ApiService`. `CompetitionRepository` exists but only delegates 1:1 (dead abstraction).
- Controllers contain UI side-effects: `Get.snackbar`, `Get.dialog`, `showDatePicker(context: Get.context!)`, `TextEditingController`, `.tr` translation. This couples controllers to `BuildContext` and the GetX UI shortcuts, making them hard to test and reason about.
- View files are large and contain hardcoded styling: `slot_view.dart` (742 LOC), `program_view.dart` (573 LOC), `home_view.dart` (567 LOC). Colors, spacing, and radii are hand-rolled per card.
- Several latent bugs exist: `getRuns` returns nothing, `getClubDetail` uses the wrong base URL, `getCompetitions` checks status `201` instead of `200`, the auth token is passed as a URL query parameter (security), and four slot-controller methods are stubbed.
- No environment configuration; no test coverage beyond the default scaffolded files.

## 2. Goals

1. Establish a clean, layered architecture that separates HTTP/parsing, domain logic, and presentation.
2. Decompose `ApiService` into per-domain data sources and repositories.
3. Enforce controller discipline: no UI side-effects, no `BuildContext`, no translation calls.
4. Introduce immutable domain models with code generation (`freezed`, `json_serializable`).
5. Centralize HTTP behavior — auth header injection, error mapping, response envelope handling — so per-endpoint bugs become structurally impossible.
6. Fix the documented bugs as part of the migration, not as separate work.
7. Add pragmatic test coverage on mappers, repositories, and controllers.
8. Leave the app runnable at every commit boundary.

## 3. Non-goals

- Migrating off GetX. Routing, DI, and i18n stay on GetX. State management discipline is what changes.
- Use cases / Clean Architecture lite — controllers will call repositories directly. No `Get-XCommand` classes.
- Widget tests, integration tests, or full TDD. Test the logic layers, not the UI.
- Changing the FFSS API. It is external and fixed; the architecture absorbs its messiness via DTOs and mappers.
- Backwards compatibility / progressive rollout. The app has no users yet; we can break things in a single batch and fix forward.
- Multi-environment infrastructure beyond a single `AppConfig` seam (today `baseUrl == qualBaseUrl`; we leave the seam, no separate dev/prod servers exist yet).

## 4. Decisions made during brainstorming

| Question | Decision |
|---|---|
| Scope | **Full architecture overhaul** — layering, DI, env config, error model, HTTP interceptor, tests |
| State management & DI | **Keep GetX, discipline its use** — no `Get.snackbar`/`Get.dialog`/`Get.context!` in controllers |
| App status | **Solo dev, no users** — full freedom to break things between batches |
| API ownership | **External / fixed** (`ffss.fr`) — must introduce DTOs and mappers |
| Test depth | **Pragmatic core coverage** — unit tests on repositories, mappers, controllers (mocked services) |
| Architectural formality | **3-layer pragmatic**: `Controller → Repository → DataSource`. No use cases. |
| Code generation | **Yes** — `freezed` + `json_serializable` + `build_runner` |

## 5. Target folder structure

```
lib/
├── main.dart
├── app/
│   ├── core/
│   │   ├── config/             # AppConfig
│   │   ├── di/                 # InitialBinding
│   │   ├── enums/
│   │   ├── errors/             # AppException hierarchy
│   │   ├── network/            # HttpClient, TokenStorage
│   │   ├── theme/              # AppColors, AppSpacing, AppRadius, AppTypography
│   │   ├── translations/
│   │   └── utils/
│   ├── data/
│   │   ├── dtos/               # *_dto.dart — 1:1 with API JSON, freezed + json_serializable
│   │   ├── datasources/        # one per domain, abstract + Impl
│   │   ├── mappers/            # *_mapper.dart — DTO ↔ domain extensions
│   │   └── repositories/       # one per domain, abstract + Impl
│   ├── domain/
│   │   └── models/             # pure domain models, freezed, no JSON
│   ├── presentation/
│   │   ├── shared/             # EmptyState, ErrorState, LoadingIndicator, StatusBadge, …
│   │   └── modules/
│   │       ├── auth/{controllers,views,widgets,bindings}/
│   │       ├── home/
│   │       ├── competitions/
│   │       ├── program/
│   │       └── slot/
│   └── routes/
```

Key relocations:

- `app/module/` → `app/presentation/modules/`.
- `app/data/services/` → deleted; `ApiService` is split into per-domain `*RemoteDataSource` and `*Repository` pairs.
- `app/data/providers/` → deleted; merged into the corresponding data sources.
- `app/data/models/` → split into `app/data/dtos/` (raw API shape) and `app/domain/models/` (clean domain).
- `app/widgets/` → `app/presentation/shared/`.

## 6. Data layer

For each of the 9 domains (Auth, Competition, Race, Club, Entry, Heat, Meeting, Run, Result) we create a quartet:

```
data/dtos/<domain>_dto.dart         # @freezed, @JsonKey for French API names
data/mappers/<domain>_mapper.dart   # extension <Dto>Mapper on <Dto> { toDomain() }
data/datasources/<domain>_remote_datasource.dart   # abstract + Impl, returns DTOs
data/repositories/<domain>_repository.dart         # abstract + Impl, returns domain models
domain/models/<domain>.dart         # @freezed pure domain model
```

Naming and field conventions:

- DTOs use `@JsonKey(name: 'NomCompletOrga')` to map French/PascalCase API fields. The DTO Dart field uses idiomatic camelCase.
- Mappers handle parsing (`DateTime.parse`), enum conversion, fallback values, and shape changes (e.g., flattening nested `data` envelopes).
- Repositories return domain models exclusively. UI never sees DTOs.
- Both data sources and repositories are defined as `abstract class` with `…Impl` concretes, so tests can mock with `mocktail`.

Pagination state (`currentPage`, `hasMoreData`, `isLoading`) currently held inside `ApiService` moves out of the data layer entirely and into whichever controller needs it.

## 7. Networking, auth, and errors

### `core/network/http_client.dart`

A thin wrapper around `package:http` owned by us. Per request, in order:

1. Build URL: `${config.baseUrl}/${config.apiVersion}/$path` plus encoded query parameters.
2. Inject `Authorization: Bearer <token>` from `TokenStorage` (replaces the current `?token=...` query-string approach — the security fix).
3. Set `Content-Type: application/json` once.
4. Catch `SocketException` / `TimeoutException` → throw `NetworkException`.
5. Decode JSON. Inspect:
   - HTTP 2xx with `success: true` (or no `success` key) → return `data` if present, else full body.
   - HTTP 2xx with `success: false` → throw `ApiException(code, message)`.
   - HTTP 4xx/5xx → throw `ApiException(statusCode, body)`.
   - HTTP 401 specifically → `AuthException` (so controllers can react with redirect-to-login if desired).

This kills three current bugs at once:

- The `200` vs `201` inconsistency (`HttpClient` accepts any 2xx).
- The missing `success` envelope check on `getEntries` / `getHeats`.
- The token leakage via URLs.

### `core/errors/`

```dart
sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);
}
class NetworkException extends AppException { ... }
class ApiException extends AppException { ... }
class AuthException extends AppException { ... }
class UnknownException extends AppException { ... }
```

Repositories rethrow these untouched. Controllers catch `AppException` and update an observable error state. Views observe and surface snackbars.

### `core/network/token_storage.dart`

Wraps `FlutterSecureStorage`. Single source of truth for the auth token; replaces the scattered `_storage.read(key: 'token')` calls.

### `core/config/app_config.dart`

Replaces `ApiConstants`:

```dart
class AppConfig {
  final String baseUrl;
  final String apiVersion;
  // endpoint paths remain as static strings
  factory AppConfig.fromEnv() { /* dart-define driven */ }
}
```

Today `baseUrl == qualBaseUrl == "https://ffss.fr/"`, so `AppConfig.fromEnv()` returns the same value regardless of `--dart-define=ENV=...`. The seam will exist for the day that changes.

## 8. Controllers and UI discipline

The largest behavioral change. Goal: controllers become **pure state machines** that depend only on repositories. Views handle all UI side-effects.

Discipline rules (enforced via review):

1. **No `Get.context!` in controllers.** Date/time pickers, dialogs, bottom sheets move to views. Controller exposes `Rx<DateTime>`; view watches and opens pickers.
2. **No `Get.snackbar` in controllers.** Replaced by reactive `Rxn<UiMessage>` state + `ever()` listener in the view.
3. **No `Get.dialog` in controllers.** View triggers dialogs based on controller state changes.
4. **No `.tr` in controllers.** Controllers store translation keys (or enum values); views translate at render time.
5. **No `BuildContext` parameters in controller methods.**
6. **No `TextEditingController` / `GlobalKey` in controllers** when scoped to a single view. Views become `StatefulWidget` for form state, exposing parsed values back to the controller.

Example controller shape after refactor:

```dart
class SlotController extends GetxController with GetSingleTickerProviderStateMixin {
  SlotController(this._results);  // constructor injection, not Get.find()
  final ResultRepository _results;

  late TabController tabController;
  final Rxn<Slot> slot = Rxn<Slot>();
  final RxBool isLoading = false.obs;
  final Rxn<AppException> error = Rxn<AppException>();
  final RxMap<int, List<LiveResult>> runResults = <int, List<LiveResult>>{}.obs;
  // No UI bits, no .tr, no Get.snackbar, no TextEditingController.
}
```

View discipline:

- Split big files. `slot_view.dart` (742 LOC) splits into `slot_view.dart` shell + `widgets/run_tab.dart`, `widgets/result_card.dart`, `widgets/athlete_card.dart`, `widgets/empty_runs_view.dart`. Same treatment for `program_view.dart` (573) and `home_view.dart` (567). Target: no view file over ~200 LOC.
- Hardcoded `Colors.blue` / `Colors.white` / `BorderRadius.circular(12)` etc. → `AppColors.primary`, `AppRadius.md` from `core/theme/`.
- Views may use `Get.put` / `Get.find`. The flow is one-directional: views know controllers, controllers know repositories, repositories know data sources. Never the reverse.

## 9. Dependency injection

GetX remains the DI container.

`core/di/initial_binding.dart` is the single registration point, called once from `main.dart`:

```dart
class InitialBinding extends Bindings {
  @override
  Future<void> dependencies() async {
    Get.put<AppConfig>(AppConfig.fromEnv(), permanent: true);

    Get.put<FlutterSecureStorage>(const FlutterSecureStorage(), permanent: true);
    Get.put<TokenStorage>(TokenStorage(Get.find()), permanent: true);
    Get.put<HttpClient>(HttpClient(Get.find(), Get.find()), permanent: true);

    await Get.putAsync<UserService>(() async => await UserService(Get.find()).init());
    await Get.putAsync<LanguageService>(() async => await LanguageService().init());

    // One per domain
    Get.lazyPut<CompetitionRemoteDataSource>(
        () => CompetitionRemoteDataSourceImpl(Get.find()), fenix: true);
    Get.lazyPut<CompetitionRepository>(
        () => CompetitionRepositoryImpl(Get.find()), fenix: true);
    // … repeated for Auth, Race, Club, Entry, Heat, Meeting, Run, Result
  }
}
```

Per-module bindings then only register controllers — the right scope for them:

```dart
class SlotBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SlotController>(() => SlotController(Get.find()));
  }
}
```

`main.dart` collapses to:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await InitialBinding().dependencies();
  runApp(const LiveFfssApp());
}
```

`LiveFfssApp` is a `StatelessWidget` returning `GetMaterialApp` with locale wired from `LanguageService`.

DI rule going forward: controllers receive their repository via constructor, not `Get.find()` inside the body. Keeps controller unit tests trivial.

## 10. Models and code generation

Domain model example:

```dart
@freezed
class Competition with _$Competition {
  const factory Competition({
    required int id,
    required String name,
    String? shortName,
    DateTime? startDate,
    DateTime? endDate,
    required CompetitionType type,
  }) = _Competition;
}
```

DTO example:

```dart
@freezed
class CompetitionDto with _$CompetitionDto {
  const factory CompetitionDto({
    @JsonKey(name: 'Id') required int id,
    @JsonKey(name: 'NomCompletOrga') required String name,
    @JsonKey(name: 'NomCourt') String? shortName,
    @JsonKey(name: 'DebutEngagement') String? startDate,
  }) = _CompetitionDto;
  factory CompetitionDto.fromJson(Map<String, dynamic> json) =>
      _$CompetitionDtoFromJson(json);
}
```

Wins: free `==` / `hashCode` / `copyWith`, immutability, exhaustive `when` on sealed unions (used for `UiMessage`, `AppException`).

`pubspec.yaml` changes:

```yaml
dependencies:
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0
  # Drop: getwidget (used in 1-2 places, replaceable)
  # Bump: google_fonts ^4.0.4 → ^6.x (3 majors stale) or remove

dev_dependencies:
  build_runner: ^2.4.13
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  mocktail: ^1.0.4
```

`analysis_options.yaml` tightening: drop the `sized_box_for_whitespace: ignore` override; add `prefer_const_constructors`, `unnecessary_lambdas`, `avoid_print`, `prefer_single_quotes`.

## 11. Bug fixes batched into the migration

| # | Bug | Where | Resolution |
|---|---|---|---|
| 1 | `getRuns` returns nothing | `api_service.dart:452-467` | Implement properly inside new `RunRemoteDataSource` |
| 2 | `getClubDetail` uses `apiVersion` as base URL | `api_service.dart:251` | `HttpClient` always uses `AppConfig.baseUrl` — bug becomes structurally impossible |
| 3 | `getCompetitions` checks status `201` instead of `200` | `api_service.dart:61` | Centralized `HttpClient` accepts any 2xx |
| 4 | Token in URL query strings (security) | every endpoint | `Authorization: Bearer` header in `HttpClient` |
| 5 | `getEntries` / `getHeats` skip `success` envelope check | `api_service.dart:294,322` | `HttpClient` enforces it |
| 6 | `Rx<bool> isLoggedIn` creates a fresh `Rx` every getter call | `home_controller.dart:85-91` | Replace with computed bool or `Rx<bool>` field on `UserService` |
| 7 | 4 stubbed methods in slot controller (`_saveBeachRankings`, `_saveSwimmingTimes`, `withdrawAthlete`, etc.) | `slot_controller.dart:274-303` | Implement against real `ResultRepository` if endpoints exist; otherwise leave repo methods throwing `UnimplementedError` so seam is correct (open question — see §13) |
| 8 | `runResults` keyed by list index (fragile) | `slot_controller.dart:28` | Key by `runId` |
| 9 | `setFilter` resets to literal `'TOUS'` (untranslated) | `home_controller.dart:111` | Use a `FilterType` enum |
| 10 | `AuthRepository` writes 9 separate keys to secure storage; `UserService` reads them back individually | `auth_repository.dart:14-25` | Serialize one `UserDto` JSON blob to a single `'user'` key |
| 11 | Default Flutter starter README | `README.md` | Project-specific setup, env, run instructions |
| 12 | Beach/swim discipline detection via string-matching (`'côtier'`/`'beach'`/`'coastal'`) | `slot_controller.dart:152-183` | `Discipline` enum on `RaceFormatDetail` |
| 13 | Duplicate `ApiService` registration | `slot_binding.dart:8` | All data-layer registration moves to `InitialBinding`; module bindings only register controllers |

## 12. Testing strategy

Pragmatic core coverage. Three tiers:

1. **Mappers** — pure functions, easy. One test per domain verifying the DTO → domain transformation, including null/optional handling and date parsing.
2. **Repositories** — mock the data source, verify mapping orchestration. One test per repository method.
3. **Controllers** — mock the repository, verify state transitions. One test per public method.
4. **`HttpClient`** — mock `http.Client`, verify auth header, 2xx/4xx/`success: false` handling.

Tooling: `mocktail` for mocking. No widget or integration tests in this refactor.

Rough target: ~40-60% line coverage on the logic layers. UI not covered.

## 13. Open question

**Bug #7 — Slot controller stubbed methods.** Four methods (`_saveBeachRankings`, `_saveSwimmingTimes`, `withdrawAthlete`, plus a placeholder run-results loader) need real backend endpoints. If the endpoints don't exist on the FFSS API yet, we'll still create the repository methods with the correct signatures and have them throw `UnimplementedError`. The architecture seam is correct; only the wire format remains unknown.

To be confirmed during implementation, once we look at the FFSS API documentation or attempt the calls.

## 14. Migration order (batches)

Each batch ≈ one focused PR-sized chunk. The app remains runnable at every batch boundary.

### Batch 0 — Foundation (no behavior change)
- Add `freezed`, `json_serializable`, `build_runner`, `mocktail` to `pubspec.yaml`.
- Tighten `analysis_options.yaml`.
- Create new folders: `core/network/`, `core/errors/`, `core/config/`, `core/di/`, `data/dtos/`, `data/datasources/`, `data/mappers/`, `domain/models/`, `presentation/`.
- Implement `AppConfig`, `AppException` hierarchy, `TokenStorage`, `HttpClient` with unit tests.
- Skeleton `InitialBinding`. Old `ApiService` still functional and used.

### Batch 1 — Migrate Auth (validates the pattern end-to-end)
- `UserDto` (freezed) replacing the 9-key secure-storage shred.
- `AuthRemoteDataSource`, `AuthRepository`.
- `AuthController` constructor-injects `AuthRepository`. Snackbars/dialogs move to `LoginView`.
- Unit tests: `UserDtoMapper`, `AuthRepository` (mocked datasource), `AuthController` (mocked repo).
- Delete `AuthProvider`.

### Batch 2 — Theme + shared widgets
- `core/theme/`: `AppColors`, `AppSpacing`, `AppRadius`, `AppTypography`. Wire into `appThemeData`.
- Extract reusable widgets to `presentation/shared/`: `EmptyState`, `ErrorState`, `LoadingIndicator`, `StatusBadge`, `SectionHeader`.
- No controller changes.

### Batch 3 — Competition + Race + Club domains
- DTOs, mappers, datasources, repositories.
- `HomeController` and `CompetitionDetailController` switch to repos; UI side-effects move to views.
- Split `home_view.dart` and `competition_detail_view.dart` into widgets.
- Tests for mappers + repos + controllers.

### Batch 4 — Meeting + Entry + Heat domains (Program module)
- Same recipe.
- Move `TextEditingController` / `GlobalKey` out of `ProgramController`.
- Split `program_view.dart` into widgets.

### Batch 5 — Run + Result domains (Slot module — biggest)
- Implement the four stubbed methods (or keep `UnimplementedError` if endpoints absent — see §13).
- Re-key `runResults` by `runId`.
- Split `slot_view.dart` (742 LOC) into widgets.
- Replace beach/swim string-matching with a `Discipline` enum.

### Batch 6 — Demolition
- Delete `api_service.dart`, `auth_provider.dart`, dead `CompetitionRepository`.
- Drop unused `getwidget`, bump `google_fonts`.
- Rewrite `README.md`.
- Final `flutter analyze` + run all tests.

### Loose sizing (solo dev, full focus)

| Batch | Estimate |
|---|---|
| 0 | ½ day |
| 1 | ½ day |
| 2 | 2-4 hours |
| 3 | 1 day |
| 4 | 1 day |
| 5 | 1 day |
| 6 | 1-2 hours |
| **Total** | **≈ 4-5 focused dev days** |

## 15. Success criteria

- `ApiService` deleted; no file in `lib/` exceeds ~250 LOC except justified ones (translations, generated code).
- No occurrences of `Get.context!`, `Get.snackbar`, `Get.dialog`, or `.tr` inside files under `controllers/`.
- All 13 documented bugs resolved.
- `flutter analyze` clean with the tightened lint set.
- Mappers, repositories, controllers, and `HttpClient` covered by unit tests; `flutter test` green.
- App runs end-to-end with the same user-visible behavior as today.
