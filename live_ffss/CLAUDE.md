# CLAUDE.md

Rules and conventions for working in this codebase. Reference for future Claude sessions.

## Architecture (3-layer pragmatic)

`Controller → Repository → DataSource`. State + DI via GetX. Each domain owns one of each.

**Data + domain layers:**
- **`lib/app/data/dtos/`** — freezed + json_serializable, 1:1 with FFSS API JSON. French field names mapped via `@JsonKey(name: 'NomCompletOrga')` etc. First line: `// ignore_for_file: invalid_annotation_target` when using `@JsonKey` on freezed factory params.
- **`lib/app/data/mappers/`** — extension `XMapper on XDto { X toDomain() => ... }`. Date parsing, enum decoding, default-handling all live here.
- **`lib/app/data/datasources/`** — abstract `XRemoteDataSource` + `Impl(HttpClient)`. Returns DTOs. Seven domains: auth, club, competition, meeting, race, ranking, result. `result` and `ranking` are stubs (see Known gaps) and their `Impl` takes no `HttpClient`; `RankingRemoteDataSource` also returns domain models rather than DTOs, because there are no ranking DTOs to write until the endpoints are documented.
- **`lib/app/data/repositories/`** — abstract `XRepository` + `Impl(XRemoteDataSource)`. Returns domain models. Owns auto-pagination, orchestration.
- **`lib/app/data/services/`** — `UserService` (long-lived auth state, exposes `Rx<User?>`, listens to `AuthRepository.userStream`) and `UserPreferencesService` (favorite + last-viewed competition ids, persisted to secure storage under `'favorite_competitions'` / `'last_viewed_competitions'`; last-viewed is capped at 20, newest first).
- **`lib/app/domain/models/`** — freezed pure types, no `@JsonKey`. Enums for status/role/discipline. Includes `athlete`, `category`, `club`, `club_ranking`, `competition`, `discipline`, `entry`, `heat`, `individual_ranking`, `live_result`, `meeting`, `race`, `race_format_configuration`, `race_format_detail`, `referee`, `relay_ranking`, `result`, `run`, `slot`, `user`.

**Feature modules (dual location — both are live):**
- **`lib/app/module/<feature>/{bindings,controllers,views}/`** — actual feature code: GetX bindings, controllers, view widgets. Modules: `auth`, `competitions`, `favorites`, `home`, `main_shell`, `program`, `slot`. Auth module also holds `profile_*` and `user_*`. `main_shell` is the bottom-nav host mounted at `Routes.home`; `home` and `favorites` are tabs inside it, not standalone routes.
- **`lib/app/presentation/modules/<feature>/`** — view-side `*_formatting.dart` extensions only (`CompetitionFormatting`, `HeatFormatting`, `RaceFormatting`, `MeetingFormatting`, `RunFormatting`) for date strings, status labels, colors. Currently covers `competitions`, `program`, `slot` (no `auth` or `home` extension).
- **`lib/app/presentation/shared/`** — `LoadingIndicator`, `EmptyState`, `ErrorState`, `StatusBadge`, `SectionHeader`, `UiMessage`, `LanguageSelector`, `CompetitionCard`, `HomeWave`.
- **`lib/app/routes/`** — `app_pages.dart` (GetPage list, per-route bindings) + `app_routes.dart` (route name constants, `part of 'app_pages.dart'`). `AppPages.initial = Routes.home`. `Routes` still declares `userDashboard`, `adminDashboard`, and `settings`, but no `GetPage` is registered for them — they're dead constants, not routes.

**Core (`lib/app/core/`):**
- `config/` — `AppConfig.fromEnv()`.
- `const/` — `ApiConstants` (path templates + `replacePath`), `FormatConst` (intl `DateFormat`s).
- `enum/` — UI-side enums (`CompetitionVisibility`, `CompetitionType`); domain enums live with their model.
- `errors/` — sealed `AppException` family (`ApiException`, `AuthException`, `NetworkException`, `UnknownException`).
- `network/` — `HttpClient`, `TokenStorage`.
- `services/` — `LanguageService` (locale persistence via secure storage; async-init).
- `theme/` — `AppColors`, `AppRadius`, `AppSpacing`, `AppTypography` (design tokens).
- `themes/` — `app_theme.dart` (assembles tokens into `ThemeData`).
- `translations/` — `AppTranslations` + `en_us.dart`, `fr_fr.dart`.
- `utils/` — `url_builder.dart`, `validators.dart`.
- `di/InitialBinding` — single registration point (see DI order section).
- Empty scaffold dirs that survived the cleanup: `core/bindings/`, `core/controllers/`, `core/middleware/`. Don't add to them — register in `InitialBinding` or per-module bindings instead.

## Controller discipline (enforce by review)

- **No `Get.context!`** in controllers. Date/time pickers, dialogs → views with local `context`.
- **No `Get.snackbar`** in controllers. Use `Rxn<UiMessage>` (sealed `UiMessageSuccess`/`UiMessageError`); view watches with `ever()`.
- **No `Get.dialog`** in controllers. View triggers based on controller state.
- **No `.tr`** in controllers. Controllers store translation keys (defined in `core/translations/`); views translate at render.
- **No `BuildContext` parameters** in controller methods.
- **No `TextEditingController`/`GlobalKey`** in controllers when scoped to one view — make the view a `StatefulWidget`.
- **Constructor injection only.** `Get.lazyPut<X>(() => X(Get.find<Y>()))` in bindings. NEVER `Get.find()` inside controller body.
- **Catch `AppException`** (the sealed type from `core/errors/`), not raw `Exception`. Let other throwables propagate.

Known violations: `UserController` and `ProfileController` still have `Get.snackbar`/`.tr` calls, and `SlotController` has `Get.dialog` + `Get.snackbar` + `.tr` (athlete-withdrawal confirmation). All explicitly deferred. Don't propagate the pattern; clean them up if you touch the views.

One deliberate exception outside controllers: `InitialBinding._wireSessionExpirationHandler` uses `Get.snackbar` + `.tr` + `Get.offAllNamed`. It hangs off `HttpClient.onAuthFailure` and has no view to delegate to, so the rule doesn't apply there.

## Testing (`mocktail`, no widget tests)

- **Mappers**: one test per non-trivial transformation. Cover null/optional fields, JSON quirks (e.g., `Annee` int/String).
- **Repositories**: mock the data source. Verify orchestration (pagination loop, named-param forwarding, mapper composition).
- **Controllers**: mock the repository. Verify state transitions on success/error/loading.
- **`HttpClient`**: mock `http.Client`. Cover URL building, header injection, error mapping, transport failures.
- **No widget tests, no integration tests.** Pragmatic core coverage = mapper/repo/controller layers.
- For mocktail: `class _MockX extends Mock implements X {}` (NOT `extends Fake` — Fake doesn't support `when()`). For non-primitive `any()` matchers, register fallback values: `setUpAll(() { registerFallbackValue(_FakeUri()); })`.
- **Test layout**: mappers/repos/datasources/services/core mirror their source paths (`test/data/mappers/`, `test/data/repositories/`, `test/data/datasources/`, `test/data/services/`, `test/core/...`). Controller tests live at `test/presentation/modules/<feature>/controllers/` even though the controllers themselves are at `lib/app/module/<feature>/controllers/` — the test path follows the architectural intent, not the current source location. The legacy `test/widget_test.dart` and `test/unit_test.dart` are scaffold leftovers; don't extend them.

## Codegen workflow

```bash
dart run build_runner build --delete-conflicting-outputs
```

(On Windows use the full path: `C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\dart.bat run build_runner ...`.)

After creating/modifying a freezed file. `.freezed.dart` and `.g.dart` are committed alongside the hand-written source — they're treated as source, not build output. A `freezed`/`build_runner` version bump regenerates **all** `.freezed.dart`/`.g.dart` (100+ files) on the first run — expect a large, mechanical diff and commit it on its own.

When `build_runner` regenerates other files via CRLF normalization (Windows quirk), commit them in a `chore: sync regenerated codegen output` cleanup commit if they accumulate.

## Tooling pins

- **Actual SDK: Flutter 3.41.9 / Dart 3.11.5.** The `environment.sdk` constraint is `>=3.4.3 <4.0.0`, but the project depends on `intl ^0.20.2`, which Flutter 3.22.2 (intl 0.19.0) cannot resolve — so it runs on the newer SDK. The install folder is named `flutter_windows_3.22.2-stable` but is a **git clone currently checked out to tag `3.41.9`**; the name is misleading. To change version: `git -C <flutterRoot> checkout <tag>` then `flutter --version` (re-downloads the matching Dart SDK).
- `build_runner: ^2.5.4`, `freezed: ^2.5.8`, `json_serializable: ^6.9.5`, `freezed_annotation: ^2.4.4`, `json_annotation: ^4.9.0`.
- Analyzer: `strict-casts: true` + `strict-raw-types: true` are ON. Don't reintroduce `dynamic` coercions.
- `flutter`/`dart` are not on bash PATH on Windows — use `C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat` and `dart.bat`.
- If `dart run build_runner` fails with `frontend_server.dart.snapshot not found`, the dart-sdk cache has drifted from the checked-out Flutter tag — re-run `flutter --version` to repopulate it (don't chase it as a code bug).

## API contract (FFSS, external, fixed)

- Base URL: `https://ffss.fr` (single env). `AppConfig.fromEnv()` is the seam. Path templates (with `:id` placeholders) and the `replacePath(path, params)` helper live in `core/const/api_const.dart` (`ApiConstants`).
- `HttpClient.get/post` returns the **full decoded body** as `Map<String, dynamic>`. Datasources extract `body['data']` themselves — `me` endpoint has fields at both top-level and nested under `data`, so unwrapping in HttpClient would lose info.
- **UTF-8 decoding:** HttpClient decodes `utf8.decode(response.bodyBytes)`, NOT `response.body`. FFSS omits the charset in the response `Content-Type`, so `http` would fall back to latin-1 and mangle accents (`é` → `Ã©`). Never switch back to `response.body`.
- Auth: `Authorization: Bearer <token>` from `TokenStorage`. NEVER pass token as a URL query parameter.
- Success envelope: `success: true` (or absent). HttpClient throws `ApiException` on `success: false`, `AuthException` on 401, `ApiException` with statusCode on 4xx/5xx, `NetworkException` on `SocketException`/`TimeoutException`, `UnknownException` for anything else. **`AppException` rethrows pass through unchanged** — don't catch and re-wrap.
- Single secure-storage key for the persisted user: `'user'` (JSON blob). Don't shred into per-field keys.

## Domain naming

- Enums for typed states: `UserType { licensee, organisme, unknown }`, `UserRole { admin, user, unknown }`, `Gender { male, female, mixed, unknown }`, `RunStatus { waiting, marshalling, inProgress, finished, unknown }`, `CompetitionStatus`, `EntryStatus`. Always include an `unknown` arm for forward-compat with API changes — that rule is for enums decoded from the API. Purely local UI enums don't need one: `HomeFilter { all, coastal, pool, mixed }` (in `home_controller.dart`) and `core/enum/enum.dart`'s `CompetitionVisibility`/`CompetitionType` have no `unknown` arm.
- Field names are camelCase domain English: `clubName`, `licenseeNumber`, `tokenExpiration`, `beginHour`, `specialityLabel`. NEVER carry the API's French names into the domain.
- `Gender` lives in `athlete.dart` and is reused by `Race`, `Referee`. The `parseGender(String) → Gender` helper is in `athlete_mapper.dart` (exported, no leading `_`).
- Computed UI helpers (`formattedBeginDate`, `phaseLabel`, `entryStatusColor`) go in **presentation extensions**, NOT on the domain model.

## DI registration order in `InitialBinding`

1. `AppConfig`
2. `FlutterSecureStorage` → `TokenStorage`
3. `HttpClient`
4. Per-domain DataSource → Repository (Auth, Competition, Club, Race, Meeting, Result, Ranking)
5. `UserService` (async — `Get.putAsync`, depends on `AuthRepository`; lives at `lib/app/data/services/`)
6. `LanguageService` (async; lives at `lib/app/core/services/`)
7. `UserPreferencesService` (async, depends on `FlutterSecureStorage`; lives at `lib/app/data/services/`)
8. `_wireSessionExpirationHandler()` — sets `HttpClient.onAuthFailure` to log out, redirect to `/login`, and snackbar. Must run after both `HttpClient` and `AuthRepository` are registered. It guards against duplicate handling when several in-flight requests 401 in the same microtask, and skips re-navigating when already on `/login` (a failed login itself returns 401).

All `permanent: true`. Per-route bindings (under `lib/app/module/<feature>/bindings/`) register **only controllers** — no datasource/repository registrations leak into route bindings. `AppPages` in `lib/app/routes/app_pages.dart` wires bindings to routes; `Routes.home` stacks four (`MainShellBinding`, `HomeBinding`, `FavoritesBinding`, `UserBinding`) because the shell mounts the home and favorites tabs plus the user avatar at once. Every other route takes a single binding.

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
- **Rankings feature:** `RankingRemoteDataSourceImpl` is a stub returning empty lists for club/individual/relay rankings — the FFSS endpoints aren't documented. The Points tab in competition detail is built around the `EmptyState` path, so when the backend lands, swap the stub for an HTTP-backed impl and the repository, controller, view, and tests stay as-is.
- **`slot_view.dart` is 634 LOC** — mechanical widget split deferred.
- **`Discipline` string-matching** in `SlotController.isBeachDiscipline`/`isSwimmingDiscipline` — typed enum on `RaceFormatDetail` deferred.

## Where to look first

- Plans: `docs/superpowers/plans/` — the original refactor batches (0, 1, 2, 3a, 3b, 4a, 5, 6) plus the feature plans that followed: home-page redesign, this-week server fetch, bottom-nav favorites, competition-detail redesign.
- Specs: `docs/superpowers/specs/` — `2026-04-25-architecture-refactor-design.md` is the original design; each later feature has its own `*-design.md` alongside it.
- Examples to follow: Auth (Batch 1), Competition (Batch 3a) — the cleanest end-to-end demonstrations of the pattern.
- Routing entry point: `lib/app/routes/app_pages.dart` — start here to map a feature to its module + bindings + controllers.
- DI entry point: `lib/app/core/di/initial_binding.dart` — wired in `main.dart` before `runApp`.
