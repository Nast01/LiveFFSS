# Batch 6 — Demolition Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Delete the legacy data layer that's been kept alive transitionally through Batches 0-5. Tighten the Dart analyzer to the level the design spec originally intended. Drop unused dependencies. Rewrite the README. End state: no `lib/app/data/services/api_service.dart`, no `lib/app/data/models/*_model.dart`, analyzer running with `strict-casts: true` clean, dependencies pruned.

**Architecture:** No new code. Pure deletion + lint tightening + dependency cleanup.

**Tech Stack:** No new deps. Some deps removed (`getwidget`, `google_fonts`).

---

## Notes & deviations from spec

1. **`club_ranking.dart` becomes a domain model.** It's the only legacy `data/models/` file with a non-trivial reference (used by `CompetitionDetailController.clubRankingsLimited` — a stubbed feature). Migrating it to `lib/app/domain/models/` as a freezed model preserves the type and lets us delete the rest of `data/models/` entirely.

2. **`strict-casts: true` re-enabled.** Originally deferred from Batch 0 because it would have surfaced 227 errors in legacy `fromJson` factories. Those factories are now all gone (replaced by freezed-generated `fromJson` methods that ARE properly typed). We'll find out if any remaining code has a sneaky `dynamic` coercion.

3. **`prefer_single_quotes` and `prefer_const_constructors` lints are NOT added.** Adding them now would surface ~hundreds of pre-existing legacy infos that aren't actual bugs, just style. Deferring further (or never) is a judgment call — they don't affect correctness.

4. **No view splits.** The `slot_view.dart` (742 LOC) split into widget files was mentioned in the original Batch 5 spec — deferred again. It's mechanical and doesn't change behavior; if the view grows further or becomes problematic to edit, a focused split-PR can do it then.

5. **No Discipline enum on `RaceFormatDetail`.** Spec mentioned replacing the `'côtier'`/`'eau-plate'` string-matching in `SlotController.isBeachDiscipline`. The string-matching works today; a typed enum would only be a refactor without behavioral benefit. Deferred.

6. **Unused dependencies pruned.** `getwidget` and `google_fonts` are both unused (verified via grep). They get removed from `pubspec.yaml`.

7. **README rewrite.** The legacy README is the default Flutter scaffold. Replace with a project-specific intro: what the app does, how to run it, where the architecture docs live.

---

## File map

**Move (1 file → new location, freezed-converted):**
- `lib/app/data/models/club_ranking.dart` → `lib/app/domain/models/club_ranking.dart`

**Delete (16 legacy model files):**
- `lib/app/data/models/athlete_model.dart`
- `lib/app/data/models/category_model.dart`
- `lib/app/data/models/club_model.dart`
- `lib/app/data/models/competition_model.dart`
- `lib/app/data/models/discipline_model.dart`
- `lib/app/data/models/entry_model.dart`
- `lib/app/data/models/heat_model.dart`
- `lib/app/data/models/live_result_model.dart`
- `lib/app/data/models/meeting_model.dart`
- `lib/app/data/models/race_format_configuration_model.dart`
- `lib/app/data/models/race_format_detail_model.dart`
- `lib/app/data/models/race_model.dart`
- `lib/app/data/models/referee_model.dart`
- `lib/app/data/models/result_model.dart`
- `lib/app/data/models/run_model.dart`
- `lib/app/data/models/slot_model.dart`

**Delete (1 service):**
- `lib/app/data/services/api_service.dart`

**Modify:**
- `lib/app/core/di/initial_binding.dart` — drop the `import` for `api_service.dart` and the transitional `Get.put<ApiService>(ApiService(), permanent: true)` registration block
- `lib/app/module/competitions/controllers/competition_detail_controller.dart` — update import for `ClubRanking`
- `lib/app/module/competitions/views/competition_detail_home_view.dart` — update import for `ClubRanking`
- `pubspec.yaml` — drop `getwidget`, drop `google_fonts`
- `analysis_options.yaml` — add `strict-casts: true` (and possibly `strict-raw-types: true`)
- `README.md` — full rewrite

---

## Task 1: Migrate `ClubRanking` to domain

**Files:**
- Create: `lib/app/domain/models/club_ranking.dart`
- Update: `lib/app/module/competitions/controllers/competition_detail_controller.dart`
- Update: `lib/app/module/competitions/views/competition_detail_home_view.dart`

The existing `lib/app/data/models/club_ranking.dart` is simple (3 fields, hand-written `fromJson`). For consistency with the rest of the migration, convert it to a freezed model.

- [ ] **Step 1: Create the freezed domain model**

Create `lib/app/domain/models/club_ranking.dart` with EXACTLY this content:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'club_ranking.freezed.dart';
part 'club_ranking.g.dart';

@freezed
class ClubRanking with _$ClubRanking {
  const factory ClubRanking({
    @Default(0) int position,
    @Default('') String clubName,
    @Default(0) int points,
  }) = _ClubRanking;

  factory ClubRanking.fromJson(Map<String, dynamic> json) =>
      _$ClubRankingFromJson(json);
}
```

- [ ] **Step 2: Run codegen**

Run: `dart run build_runner build --delete-conflicting-outputs`

(`dart` may not be on bash PATH — fall back to `C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\dart.bat` if needed.)

- [ ] **Step 3: Update the two importers**

In `lib/app/module/competitions/controllers/competition_detail_controller.dart`, replace:
```dart
import 'package:live_ffss/app/data/models/club_ranking.dart';
```
with:
```dart
import 'package:live_ffss/app/domain/models/club_ranking.dart';
```

In `lib/app/module/competitions/views/competition_detail_home_view.dart`, do the same swap (if it imports ClubRanking explicitly).

- [ ] **Step 4: Verify**

Run: `flutter analyze`
Expected: zero errors. Pre-existing legacy warnings/infos may shift slightly (the legacy `data/models/club_ranking.dart` is now unused — analyzer might surface it as `unused_element` or similar since it's no longer imported).

(`flutter` may not be on bash PATH — fall back to `C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat` if needed.)

- [ ] **Step 5: Commit**

```bash
git add lib/app/domain/models/club_ranking.dart \
        lib/app/domain/models/club_ranking.freezed.dart \
        lib/app/domain/models/club_ranking.g.dart \
        lib/app/module/competitions/controllers/competition_detail_controller.dart \
        lib/app/module/competitions/views/competition_detail_home_view.dart
git commit -m "refactor(domain): migrate ClubRanking to domain/freezed

Last legacy data/models/ file with active references. Re-implemented
as freezed for consistency. The two importers (CompetitionDetailController
+ home view) now point at the new path. Legacy file gets deleted in
the next commit."
```

---

## Task 2: Delete the legacy data layer

**Files:**
- Delete: 16 files in `lib/app/data/models/` (everything except the now-moved `club_ranking.dart`)
- Delete: `lib/app/data/services/api_service.dart`
- Modify: `lib/app/core/di/initial_binding.dart` — drop ApiService import + registration

- [ ] **Step 1: Confirm no references remain**

Run grep checks:
```bash
grep -rn "data/models/\(athlete_model\|category_model\|club_model\|competition_model\|discipline_model\|entry_model\|heat_model\|live_result_model\|meeting_model\|race_format_configuration_model\|race_format_detail_model\|race_model\|referee_model\|result_model\|run_model\|slot_model\)" lib/ test/
grep -rn "data/services/api_service" lib/app/module/ test/
grep -rn "Get.find<ApiService>" lib/ test/
```

All three should return zero matches outside the files being deleted (api_service.dart and initial_binding.dart).

If anything matches in non-deleted files, STOP and report — that's a missed reference from prior batches.

- [ ] **Step 2: Delete the model files**

```bash
git rm lib/app/data/models/athlete_model.dart \
       lib/app/data/models/category_model.dart \
       lib/app/data/models/club_model.dart \
       lib/app/data/models/club_ranking.dart \
       lib/app/data/models/competition_model.dart \
       lib/app/data/models/discipline_model.dart \
       lib/app/data/models/entry_model.dart \
       lib/app/data/models/heat_model.dart \
       lib/app/data/models/live_result_model.dart \
       lib/app/data/models/meeting_model.dart \
       lib/app/data/models/race_format_configuration_model.dart \
       lib/app/data/models/race_format_detail_model.dart \
       lib/app/data/models/race_model.dart \
       lib/app/data/models/referee_model.dart \
       lib/app/data/models/result_model.dart \
       lib/app/data/models/run_model.dart \
       lib/app/data/models/slot_model.dart
```

(Note: `club_ranking.dart` IS in this list — it's the legacy `data/models/` version that's being removed. The new domain version was created in Task 1.)

- [ ] **Step 3: Delete ApiService**

```bash
git rm lib/app/data/services/api_service.dart
```

- [ ] **Step 4: Update InitialBinding**

In `lib/app/core/di/initial_binding.dart`:

REMOVE the import:
```dart
import 'package:live_ffss/app/data/services/api_service.dart';
```

REMOVE the transitional registration block (search for `// Transitional: legacy ApiService` and the `Get.put<ApiService>(ApiService(), permanent: true);` line that follows). Delete the comment AND the registration line.

The other registrations in InitialBinding stay — they don't depend on ApiService anymore (Batch 5 finished migrating them).

- [ ] **Step 5: Run analyzer + tests**

Run: `flutter analyze`
Expected: zero errors. Several pre-existing legacy warnings (e.g., `unused_field _apiService` in slot_controller.dart, `unused_import` for legacy models in slot_controller, `dead_code`) should now be GONE since those files are deleted.

Run: `flutter test`
Expected: all 127 tests still pass.

- [ ] **Step 6: Commit**

```bash
git add lib/app/core/di/initial_binding.dart
# git rm staged the deletes already
git commit -m "chore(data): delete legacy api_service + 17 *_model.dart files

ApiService is no longer registered in InitialBinding. The 17 legacy
model files (athlete_model, category_model, ..., slot_model) are
gone — their replacements are in domain/models/ (freezed).

Net delete: ~2400 LOC of legacy data layer."
```

---

## Task 3: Tighten analysis_options.yaml

**Files:**
- Modify: `analysis_options.yaml`

- [ ] **Step 1: Try `strict-casts: true`**

REPLACE `analysis_options.yaml` with:

```yaml
analyzer:
  language:
    strict-casts: true
include: package:flutter_lints/flutter.yaml

linter:
  rules:
```

- [ ] **Step 2: Verify**

Run: `flutter analyze`

If zero errors: great, the freezed-generated `fromJson` factories (which are properly typed) handle everything. Proceed to Step 3.

If errors appear: they'll be `argument_type_not_assignable` from `dynamic` → typed coercions. Inspect them. Most likely candidates:
- View files using `Get.arguments` (returns `dynamic`) and casting to a specific type. Fix by using `is X` type checks (which Dart 3 promotes).
- Any remaining hand-written `fromJson` (unlikely but possible).

If a real error surfaces, fix it inline. If too many surface (more than ~5), STOP and report — we'll back out the strict-casts change with a TODO and proceed without it.

- [ ] **Step 3: Try adding `strict-raw-types: true`**

If Step 2 passed cleanly, also try:
```yaml
analyzer:
  language:
    strict-casts: true
    strict-raw-types: true
```

Run analyzer again. If zero errors, keep both. If new errors surface, drop `strict-raw-types: true` (don't fight it).

- [ ] **Step 4: Commit**

```bash
git add analysis_options.yaml
# Plus any inline fixes for strict-casts errors
git commit -m "chore(analyzer): re-enable strict-casts (+raw-types if clean)

Originally deferred from Batch 0 because it broke 227 legacy fromJson
factories. Those factories are gone — freezed/json_serializable
generated fromJson methods are properly typed. Brought back per the
original design spec."
```

If you had to drop `strict-raw-types: true`, mention that in the commit body.

---

## Task 4: Drop unused dependencies

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Remove `getwidget` and `google_fonts`**

In `pubspec.yaml`, REMOVE these two lines from the `dependencies` block:
```yaml
  getwidget: ^4.0.0
  google_fonts: ^4.0.4
```

- [ ] **Step 2: Run pub get**

Run: `flutter pub get`
Expected: `Got dependencies!` — fewer transitive deps in the lock file.

(`flutter` may not be on bash PATH — fall back to the .bat path if needed.)

- [ ] **Step 3: Verify**

Run: `flutter analyze`
Expected: zero errors. (Both packages were already unused, so removal can't break anything. If something fails, that's a surprise — investigate.)

Run: `flutter test`
Expected: all 127 tests pass.

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore(deps): drop unused getwidget and google_fonts

Both were never imported anywhere in lib/ (verified by grep).
Reduces transitive dep graph and lock-file size."
```

---

## Task 5: Update README

**Files:**
- Modify (rewrite): `README.md`

- [ ] **Step 1: Replace README**

REPLACE `README.md` with EXACTLY this content:

````markdown
# live_ffss

Flutter app for live tracking of FFSS (Fédération Française de Sauvetage et de Secourisme) competitions.

## Architecture

The app uses a 3-layer pragmatic split: `Controller → Repository → DataSource`. State management and DI go through GetX. Data types are immutable (`freezed`), JSON shapes from the FFSS API live in `lib/app/data/dtos/` and map to clean domain types in `lib/app/domain/models/` via mappers.

Design spec: [`docs/superpowers/specs/2026-04-25-architecture-refactor-design.md`](docs/superpowers/specs/2026-04-25-architecture-refactor-design.md)
Implementation plans: [`docs/superpowers/plans/`](docs/superpowers/plans/)

```
lib/
├── main.dart
├── app/
│   ├── core/
│   │   ├── config/             AppConfig (env-driven)
│   │   ├── di/                 InitialBinding (single GetX registration point)
│   │   ├── enums/
│   │   ├── errors/             AppException sealed hierarchy
│   │   ├── network/            HttpClient (auth header, error mapping), TokenStorage
│   │   ├── theme/              AppColors, AppSpacing, AppRadius, AppTypography
│   │   ├── translations/       fr_FR / en_US arb-style
│   │   └── utils/
│   ├── data/
│   │   ├── dtos/               1:1 with API JSON (freezed + json_serializable)
│   │   ├── datasources/        Per-domain abstract + Impl (HttpClient-backed)
│   │   ├── mappers/            DTO -> domain extensions
│   │   └── repositories/       Per-domain abstract + Impl
│   ├── domain/
│   │   └── models/             Pure domain types (freezed, no JSON keys)
│   ├── presentation/
│   │   ├── shared/             EmptyState, ErrorState, LoadingIndicator, etc.
│   │   └── modules/            Per-feature view-side helpers (formatters, extensions)
│   ├── module/                 GetX modules: auth, home, competitions, program, slot
│   └── routes/
└── ...
```

## Tooling

- **Flutter:** 3.22.2 / Dart 3.4.3
- **Code generation:** `freezed`, `json_serializable`, `build_runner`
- **Testing:** `mocktail` for unit tests on mappers / repositories / controllers (~127 tests)
- **HTTP:** `package:http` wrapped in `lib/app/core/network/http_client.dart`
- **Secure storage:** `flutter_secure_storage` (single `'user'` key for the persisted session)

## Running locally

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

The dev/prod environment is currently single (`https://ffss.fr`) but the seam exists in `AppConfig.fromEnv()` — pass `--dart-define=ENV=...` to switch when more environments are added.

## Tests

```bash
flutter test
```

Test coverage focuses on the logic layers:
- Mappers (`test/data/mappers/`) — DTO → domain transformations.
- Repositories (`test/data/repositories/`) — orchestration with mocked data sources.
- Controllers (`test/presentation/modules/...`) — state transitions with mocked repositories.

UI is not covered (no widget/integration tests).

## Known gaps

- **Live results / mutations:** the four FFSS endpoints used by the slot module (`getRunResults`, `updateBeachRankings`, `updateSwimmingTimes`, `withdrawAthlete`) are not documented. `ResultRepository` throws `UnimplementedError` for these — same as the legacy stubbed state, but behind a clean typed seam ready to wire when the backend story is clarified.
- **Rankings feature:** `CompetitionDetailController.clubRankingsLimited` returns an empty list. The "Rankings" tab in the competition detail view shows no data.

## Localization

`lib/app/core/translations/` holds the French and English string tables. Translation keys are referenced via `'key'.tr` (GetX). The `LanguageService` exposes the current locale and a `changeLanguage()` setter.
````

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs: replace scaffold README with project-specific intro

Brief overview of the app, the 3-layer architecture, key tooling,
how to run, where the design + plans live, known gaps."
```

---

## Task 6: Final verification

- [ ] **Step 1: Run full test suite**

Run: `flutter test`
Expected: 127 tests, all green.

- [ ] **Step 2: Run analyzer**

Run: `flutter analyze`
Expected: zero errors. Issue count should be substantially LOWER than the 12 baseline going into Batch 6 — the slot_controller's pre-existing warnings are gone (file was rewritten in Batch 5), and the api_service.dart is gone too.

- [ ] **Step 3: Confirm git state**

Run:
```bash
git log --oneline main..HEAD | head -20
git status
git diff main..HEAD --stat | tail -25
```

Expected: ~6 commits, working tree clean (only `.claude/` untracked), big LOC delete.

- [ ] **Step 4: Confirm legacy is gone**

```bash
ls lib/app/data/models/ 2>/dev/null
# Expected: directory exists or doesn't, but no files
ls lib/app/data/services/ 2>/dev/null
# Expected: only user_service.dart
```

If `lib/app/data/models/` is empty, that's fine — Dart doesn't track empty dirs. Git just leaves the directory empty on disk.

- [ ] **Step 5: Final smoke verification (optional, manual)**

`flutter run`. Click through:
- Home → competitions list
- Tap a competition → detail
- Tabs: Home (rankings stubbed), Races, Program, Clubs — all load without errors
- Program: open a meeting → expand to see slots
- Tap a slot → slot view loads with empty results
- Login / logout still work

Anything broken: file as a follow-up. Refactor is over either way.

---

## Self-review

**Spec coverage** (against §14 "Batch 6 — Demolition"):
- Delete `api_service.dart` → Task 2 ✓
- Delete `auth_provider.dart` (already gone since Batch 1) ✓ (already done)
- Delete dead `CompetitionRepository` (already replaced in Batch 3a) ✓ (already done)
- Drop unused `getwidget`, bump `google_fonts` → Task 4 (drop both — `google_fonts` is also unused, no need to bump) ✓
- Rewrite `README.md` → Task 5 ✓
- Final `flutter analyze` + run all tests → Task 6 ✓
- Tighten lints (was Batch 0 deferral) → Task 3 ✓

**Placeholder scan:** None.

**Type consistency:** N/A (deletion-focused).

---

## Done criteria for Batch 6

- ~5-6 commits on a feature branch (or directly on main since it's mostly deletion).
- Net deletion: ~2400 LOC of legacy data layer.
- `lib/app/data/models/` directory empty (or gone).
- `lib/app/data/services/api_service.dart` gone.
- `flutter analyze` clean with `strict-casts: true` (and possibly `strict-raw-types: true`).
- `flutter test`: 127 tests, all green.
- README rewritten.
- `pubspec.yaml`: 2 fewer dependencies.
- App still launches and behaves identically to before.

This is the END of the architecture refactor. After Batch 6 lands, the codebase is fully on the new architecture: zero legacy `*Model` types in `lib/`, zero `Get.find<ApiService>()` calls, every controller constructor-injected with proper repositories, every repository returning typed domain models.
