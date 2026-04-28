# CLAUDE.md

Rules and conventions for working in this codebase. Reference for future Claude sessions.

## Architecture (3-layer pragmatic)

`Controller → Repository → DataSource`. State + DI via GetX. Each domain owns one of each:

- **`lib/app/data/dtos/`** — freezed + json_serializable, 1:1 with FFSS API JSON. French field names mapped via `@JsonKey(name: 'NomCompletOrga')` etc. First line: `// ignore_for_file: invalid_annotation_target` when using `@JsonKey` on freezed factory params.
- **`lib/app/data/mappers/`** — extension `XMapper on XDto { X toDomain() => ... }`. Date parsing, enum decoding, default-handling all live here.
- **`lib/app/data/datasources/`** — abstract `XRemoteDataSource` + `Impl(HttpClient)`. Returns DTOs.
- **`lib/app/data/repositories/`** — abstract `XRepository` + `Impl(XRemoteDataSource)`. Returns domain models. Owns auto-pagination, orchestration.
- **`lib/app/domain/models/`** — freezed pure types, no `@JsonKey`. Enums for status/role/discipline.
- **`lib/app/presentation/modules/<feature>/`** — view-side extensions (`CompetitionFormatting`, `RaceFormatting`, etc.) for date strings, status labels, colors.
- **`lib/app/presentation/shared/`** — `LoadingIndicator`, `EmptyState`, `ErrorState`, `StatusBadge`, `SectionHeader`, `UiMessage`, `LanguageSelector`.
- **`lib/app/core/`** — `config/AppConfig`, `network/HttpClient`+`TokenStorage`, `errors/AppException` (sealed), `theme/AppColors`+`AppSpacing`+`AppRadius`+`AppTypography`, `di/InitialBinding` (single registration point).

## Controller discipline (enforce by review)

- **No `Get.context!`** in controllers. Date/time pickers, dialogs → views with local `context`.
- **No `Get.snackbar`** in controllers. Use `Rxn<UiMessage>` (sealed `UiMessageSuccess`/`UiMessageError`); view watches with `ever()`.
- **No `Get.dialog`** in controllers. View triggers based on controller state.
- **No `.tr`** in controllers. Controllers store translation keys; views translate at render.
- **No `BuildContext` parameters** in controller methods.
- **No `TextEditingController`/`GlobalKey`** in controllers when scoped to one view — make the view a `StatefulWidget`.
- **Constructor injection only.** `Get.lazyPut<X>(() => X(Get.find<Y>()))` in bindings. NEVER `Get.find()` inside controller body.
- **Catch `AppException`** (the sealed type from `core/errors/`), not raw `Exception`. Let other throwables propagate.

Exceptions: `UserController` and `ProfileController` still have `Get.snackbar`/`.tr` calls — explicitly deferred, marked with `// TODO(later):`. Don't propagate the pattern; clean them up if you touch the views.

## Testing (`mocktail`, no widget tests)

- **Mappers**: one test per non-trivial transformation. Cover null/optional fields, JSON quirks (e.g., `Annee` int/String).
- **Repositories**: mock the data source. Verify orchestration (pagination loop, named-param forwarding, mapper composition).
- **Controllers**: mock the repository. Verify state transitions on success/error/loading.
- **`HttpClient`**: mock `http.Client`. Cover URL building, header injection, error mapping, transport failures.
- **No widget tests, no integration tests.** Pragmatic core coverage = mapper/repo/controller layers.
- For mocktail: `class _MockX extends Mock implements X {}` (NOT `extends Fake` — Fake doesn't support `when()`). For non-primitive `any()` matchers, register fallback values: `setUpAll(() { registerFallbackValue(_FakeUri()); })`.

## Codegen workflow

```bash
dart run build_runner build --delete-conflicting-outputs
```

After creating/modifying a freezed file. `.freezed.dart` and `.g.dart` are committed alongside the hand-written source — they're treated as source, not build output.

When `build_runner` regenerates other files via CRLF normalization (Windows quirk), commit them in a `chore: sync regenerated codegen output` cleanup commit if they accumulate.

## Tooling pins

- Flutter 3.22.2 / Dart 3.4.3 (per `environment.sdk` constraint).
- `build_runner: ^2.4.8` (NOT `^2.4.13` — that requires Dart `>=3.5.0`).
- `freezed: ^2.5.2` (NOT `^2.5.7` — that requires `meta ^1.14.0`, but Flutter 3.22.2 pins `meta 1.12.0`).
- Analyzer: `strict-casts: true` + `strict-raw-types: true` are ON. Don't reintroduce `dynamic` coercions.
- `flutter` may not be on bash PATH on Windows — fall back to `C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat` (and `dart.bat`).

## API contract (FFSS, external, fixed)

- Base URL: `https://ffss.fr` (single env). `AppConfig.fromEnv()` is the seam.
- `HttpClient.get/post` returns the **full decoded body** as `Map<String, dynamic>`. Datasources extract `body['data']` themselves — `me` endpoint has fields at both top-level and nested under `data`, so unwrapping in HttpClient would lose info.
- Auth: `Authorization: Bearer <token>` from `TokenStorage`. NEVER pass token as a URL query parameter.
- Success envelope: `success: true` (or absent). HttpClient throws `ApiException` on `success: false`, `AuthException` on 401, `ApiException` with statusCode on 4xx/5xx, `NetworkException` on `SocketException`/`TimeoutException`, `UnknownException` for anything else. **`AppException` rethrows pass through unchanged** — don't catch and re-wrap.
- Single secure-storage key for the persisted user: `'user'` (JSON blob). Don't shred into per-field keys.

## Domain naming

- Enums for typed states: `UserType { licensee, organisme, unknown }`, `UserRole { admin, user, unknown }`, `Gender { male, female, mixed, unknown }`, `RunStatus { waiting, marshalling, inProgress, finished, unknown }`, `CompetitionStatus`, `EntryStatus`, `HomeFilter`. Always include an `unknown` arm for forward-compat with API changes.
- Field names are camelCase domain English: `clubName`, `licenseeNumber`, `tokenExpiration`, `beginHour`, `specialityLabel`. NEVER carry the API's French names into the domain.
- `Gender` lives in `athlete.dart` and is reused by `Race`, `Referee`. The `parseGender(String) → Gender` helper is in `athlete_mapper.dart` (exported, no leading `_`).
- Computed UI helpers (`formattedBeginDate`, `phaseLabel`, `entryStatusColor`) go in **presentation extensions**, NOT on the domain model.

## DI registration order in `InitialBinding`

1. `AppConfig`
2. `FlutterSecureStorage` → `TokenStorage`
3. `HttpClient`
4. Per-domain DataSource → Repository (Auth, Competition, Club, Race, Meeting, Result)
5. `UserService` (async — `Get.putAsync`, depends on `AuthRepository`)
6. `LanguageService` (async)

All `permanent: true`. Per-route bindings register **only controllers** — no datasource/repository registrations leak into route bindings.

## Things to NOT do

- Don't reintroduce `Get.find<ApiService>()` — `ApiService` is gone, every controller goes through a repository.
- Don't add `Get.lazyPut<X>(() => X())` (no-arg construction) for any class that depends on a service. Constructor-inject via `Get.find<Service>()` in the lambda.
- Don't add `dart:mirrors`-style runtime reflection. Don't add `analyzer.errors.X: ignore` overrides — fix the issue or document why.
- Don't write hand-rolled `fromJson`. Use freezed + json_serializable. The analyzer is strict-cast and will flag dynamic coercions.
- Don't add new dependencies without justification — `getwidget` and `google_fonts` were dropped because nothing imported them.
- Don't add comments that narrate what the next line does. Add comments only where the **why** is non-obvious (a hidden constraint, a workaround, a backend quirk).
- Don't widget-test. Test the logic layers; verify UI manually with `flutter run`.

## Known gaps (documented, not bugs)

- **Live results / mutations:** `getRunResults`, `updateBeachRankings`, `updateSwimmingTimes`, `withdrawAthlete` throw `UnimplementedError`. The FFSS endpoints aren't documented. `ResultRepository` is the typed seam — wire when backend confirmed.
- **Rankings feature:** `CompetitionDetailController.clubRankingsLimited` returns `List.empty()`. The "Rankings" tab in competition detail shows no data.
- **`slot_view.dart` is 700+ LOC** — mechanical widget split deferred.
- **`Discipline` string-matching** in `SlotController.isBeachDiscipline`/`isSwimmingDiscipline` — typed enum on `RaceFormatDetail` deferred.

## Where to look first

- Plans: `docs/superpowers/plans/` — 8 markdown files, one per batch (0, 1, 2, 3a, 3b, 4a, 5, 6).
- Spec: `docs/superpowers/specs/2026-04-25-architecture-refactor-design.md` — original design.
- Examples to follow: Auth (Batch 1), Competition (Batch 3a) — the cleanest end-to-end demonstrations of the pattern.
