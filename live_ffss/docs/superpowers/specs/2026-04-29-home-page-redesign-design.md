# Home page redesign — design spec

Date: 2026-04-29
Author: brainstorming session with Stan
Source inspiration: Swimify Live timing app screenshot (2026-01-23)

## 1. Goal

Replace the current `HomeView` body and styling with a Swimify-inspired layout — hero block + curved wave separator, temporal filter pills, discipline filter strip, local search, persistent favorites and last-viewed history — while staying inside the existing 3-layer architecture and the application's existing theme tokens (no dark navy palette).

The application title remains **"Live FFSS"** (already wired through `'app_title'` translation).

## 2. Scope

### In scope
- Rebuild `lib/app/module/home/views/home_view.dart` around a new layout.
- Extend `HomeController` to compose temporal × discipline × search filters and to delegate favorites / last-viewed state to a new service.
- Add `UserPreferencesService` (long-lived, `GetxService`) backed by `FlutterSecureStorage` for favorites and last-viewed competition IDs.
- Add a hero header with the FFSS logo + "Live FFSS" wordmark + temporal pill row, separated from the body by a `CustomPainter` wave drawn in `AppColors.primary`.
- Add a discipline pill strip (All / Swimming / Beach) below the wave that finally wires `HomeFilter` (currently mutated but unused).
- Add a local search bar that filters the loaded competitions by name + location.
- Replace the current carousel + paginated list split with a single filtered list of hybrid cards (logo OR date-block fallback, name/date/location, status badge, favorite star, chevron).
- Drop the `carousel_slider` dependency from `pubspec.yaml`.
- Replace hardcoded `Color(0xFF0275FF)` references with `AppColors.primary`.

### Out of scope (called out so future work has a starting point)
- Bottom navigation shell (Start / Competition / Favorites / Scoreboard / More). The favorites star persists state but no Favorites screen exists yet.
- Country flag chips. FFSS is single-country; replaced by discipline pills.
- Backend search endpoint. Search is local-only over the already-loaded list.
- Migration of the discipline string-matching to a typed enum on `RaceFormatDetail` (already a known gap in `CLAUDE.md`).
- Widget tests. Per `CLAUDE.md`: "no widget tests".

## 3. Architecture

Stays inside the existing 3-layer pattern (`Controller → Repository → DataSource`) with `UserService`-style services for cross-cutting state. One new service is added; no datasource or repository changes.

```
View (HomeView, _HomeHero, _HomeWave, _HomeFiltersBar,
      _HomeSearchBar, _HomeList, _CompetitionCard)
  │
  ▼
HomeController
  ├── CompetitionRepository      (existing)
  ├── UserService                (existing)
  ├── LanguageService            (existing)
  └── UserPreferencesService     (NEW)
                                    │
                                    ▼
                                 FlutterSecureStorage  (existing singleton)
```

## 4. New service: `UserPreferencesService`

Path: `lib/app/data/services/user_preferences_service.dart`

```dart
class UserPreferencesService extends GetxService {
  UserPreferencesService(this._storage);
  final FlutterSecureStorage _storage;

  static const _favoritesKey = 'favorite_competitions';
  static const _lastViewedKey = 'last_viewed_competitions';
  static const _lastViewedCap = 20;

  final RxSet<int> favoriteIds = <int>{}.obs;
  final RxList<int> lastViewedIds = <int>[].obs; // newest first

  Future<UserPreferencesService> init();

  bool isFavorite(int id);
  Future<void> toggleFavorite(int id);
  Future<void> recordView(int id); // moves id to front, dedupes, caps at _lastViewedCap
}
```

Storage format: JSON-encoded `List<int>` per key. One key per concern (mirrors the existing `'user'` blob convention — small, distinct, not shredded per ID).

`init()` reads both keys, tolerates missing keys (empty defaults), populates the `Rx*` collections so views react instantly.

All mutations write through to storage **and** update the in-memory `Rx*` collections.

### DI registration order in `InitialBinding`

1. `AppConfig`
2. `FlutterSecureStorage` → `TokenStorage`
3. `HttpClient`
4. Per-domain DataSources + Repositories
5. `UserService` (`putAsync`)
6. `LanguageService` (`putAsync`)
7. **`UserPreferencesService` (`putAsync`, depends on `FlutterSecureStorage`)** — NEW

All `permanent: true`. Per-route bindings register controllers only; no service registration leaks into route bindings.

## 5. Controller changes: `HomeController`

Constructor gains a fourth dependency, `UserPreferencesService`. Existing constructor-injection pattern preserved.

### State

```dart
final Rx<HomeFilter> selectedDiscipline = HomeFilter.all.obs;       // existing field, finally wired
final Rx<TemporalFilter> selectedTemporal = TemporalFilter.thisWeek.obs; // NEW, default = thisWeek
final RxString searchQuery = ''.obs;                                // NEW
```

New enum, declared in the same controller file (mirrors `HomeFilter`):

```dart
enum TemporalFilter { lastViewed, thisWeek, all }
```

### Removed state and getters

The carousel + paginated list scheme is replaced by a single filtered list. Remove:

- `displayedItems`, `loadMore`, `hasMoreToLoad`
- `carouselCompetitions`, `listCompetitions`, `displayedListCompetitions`

### New composed getter

```dart
List<Competition> get filteredCompetitions {
  Iterable<Competition> result = competitions;

  switch (selectedTemporal.value) {
    case TemporalFilter.lastViewed:
      final ids = _prefs.lastViewedIds;
      result = ids
          .map((id) => competitions.firstWhereOrNull((c) => c.id == id))
          .whereNotNull(); // preserves last-viewed order
    case TemporalFilter.thisWeek:
      result = result.where((c) => c.overlapsCurrentWeek);
    case TemporalFilter.all:
      // no-op
  }

  switch (selectedDiscipline.value) {
    case HomeFilter.pool:    result = result.where((c) => c.isSwimming);
    case HomeFilter.coastal: result = result.where((c) => c.isBeach);
    case HomeFilter.all:
    case HomeFilter.mixed:   // no-op
  }

  final q = searchQuery.value.trim().toLowerCase();
  if (q.isNotEmpty) {
    result = result.where((c) =>
        c.name.toLowerCase().contains(q) ||
        (c.location?.toLowerCase().contains(q) ?? false));
  }

  return result.toList();
}
```

### New methods (delegating to the service)

```dart
bool isFavorite(int id) => _prefs.isFavorite(id);
Future<void> toggleFavorite(int id) => _prefs.toggleFavorite(id);
void setTemporal(TemporalFilter t) => selectedTemporal.value = t;
void setDiscipline(HomeFilter d) => selectedDiscipline.value = d;
void setSearchQuery(String q) => searchQuery.value = q;
```

Existing `navigateToCompetitionDetails` is extended:

```dart
Future<void> navigateToCompetitionDetails(Competition competition) async {
  await _prefs.recordView(competition.id);
  Get.toNamed(Routes.competitionDetail, arguments: competition);
}
```

### Controller discipline (per `CLAUDE.md`)

- No `Get.context!`, `Get.snackbar`, `Get.dialog`, `.tr` in the controller.
- No `BuildContext` parameters.
- No `TextEditingController` — the search field's controller lives in the view's local `StatefulWidget`.
- Continue catching `AppException` (the sealed type), not raw `Exception`.
- Constructor injection only; no `Get.find()` inside the controller body.

## 6. New helpers in `competition_formatting.dart`

Path: `lib/app/presentation/modules/home/competition_formatting.dart`

```dart
extension CompetitionFormatting on Competition {
  // ... existing members ...

  bool get overlapsCurrentWeek {
    if (beginDate == null || endDate == null) return false;
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1)); // Monday 00:00
    final weekEnd = weekStart.add(const Duration(days: 7)); // exclusive
    return beginDate!.isBefore(weekEnd) && endDate!.isAfter(weekStart);
  }

  bool get isSwimming; // string-match on typeWater/specialityLabel,
                       // mirroring SlotController.isSwimmingDiscipline
  bool get isBeach;    // mirroring SlotController.isBeachDiscipline
}
```

The string-matching mirrors the existing `SlotController` logic. The typed-enum migration on `RaceFormatDetail` remains a known gap in `CLAUDE.md` and is out of scope here.

## 7. View structure

Path: `lib/app/module/home/views/home_view.dart` (rewritten)

Private widget classes (`_HomeHero`, `_HomeWave`, `_HomeFiltersBar`, `_HomeSearchBar`, `_HomeList`, `_CompetitionCard`) live in the same file. If the file passes ~400 LOC, split per the `CLAUDE.md` "split mechanically" guidance.

```
Scaffold (no AppBar)
└── SafeArea
    └── Column
        ├── _HomeHero            ← AppColors.primary background
        │   ├── top action row: LanguageSelector + UserAvatar (white tint)
        │   ├── center: Image.asset(logo) + Text('Live FFSS', AppTypography.title scaled, white)
        │   └── temporal pill row: 'last_viewed'.tr / 'this_week'.tr / 'all'.tr
        ├── _HomeWave            ← CustomPaint, ~24px tall, fill = AppColors.primary
        ├── Padding(AppSpacing.pageHorizontal)
        │   └── _HomeFiltersBar  ← discipline pills
        ├── _HomeSearchBar       ← TextField in rounded surfaceMuted container
        └── Expanded
            └── Obx(_HomeList)   ← ListView.separated of _CompetitionCard
                                    + ErrorState / EmptyState / LoadingIndicator
                                      from presentation/shared
```

### Visual rules

- **Hero background:** `AppColors.primary`. All hero text and pill borders are `Colors.white`.
- **Hero pills (temporal):** active = filled white background with `AppColors.primary` text; inactive = transparent fill with white border + white text. `AppRadius.pillRadius`.
- **Wave:** `CustomPainter` drawing a quadratic-bezier curve, fill = `AppColors.primary` so the wave visually extends the hero. 24 px tall. No SVG asset.
- **Discipline pills:** sit on the white body. Active = `AppColors.primary` fill + white text; inactive = white fill with `AppColors.primary` border + `AppColors.primary` text. Same pill radius.
- **Search bar:** `TextField` in a `Container` with `AppColors.surfaceMuted` background, `AppRadius.pillRadius`, magnifier prefix icon, placeholder `'search_competitions'.tr`. `onChanged` writes to `controller.setSearchQuery`.
- **`_CompetitionCard` (hybrid layout):**
  - Logo: 56×56 square, `AppRadius.smRadius`. `Image.network(competition.organizerClub.logoUrl)` with `errorBuilder` and `loadingBuilder` falling back to a date block (MMM / dd in `AppColors.surfaceMuted`).
  - Middle column: name (`AppTypography.title`, `maxLines: 2`, ellipsis), date range (`AppTypography.body`), location (`AppTypography.caption`).
  - Right column: a `LIVE` pill (`AppColors.statusError` fill, white text) **only** when `competition.phase == CompetitionStatus.onGoing`; otherwise the existing `entryStatusLabel` badge using `entryStatusColor`. Below it: a star `IconButton` (filled = `AppColors.statusWaiting`, outline = `AppColors.textMuted`) calling `controller.toggleFavorite(id)`. Trailing `Icons.chevron_right` in `AppColors.textMuted`.
- **Zero / loading / error states:** `EmptyState`, `ErrorState`, `LoadingIndicator` from `lib/app/presentation/shared/`.
- **No `UiMessage` flow:** toggling a favorite is a silent, reversible local action; no snackbars. The existing `Rxn<UiMessage>` pattern stays available for future error reporting.

### Search bar widget shape

`_HomeSearchBar` is a small `StatefulWidget` (per `CLAUDE.md`: `TextEditingController` belongs in the view, not the controller). Its `dispose()` releases the `TextEditingController`. `onChanged` calls `controller.setSearchQuery`.

## 8. Translations

Added to both `lib/app/core/translations/en_us.dart` and `fr_fr.dart`:

| Key | EN | FR |
|---|---|---|
| `last_viewed` | Last viewed | Vus récemment |
| `this_week` | This week | Cette semaine |
| `search_competitions` | Search competition | Rechercher une compétition |
| `live` | LIVE | LIVE |
| `no_competitions_found` | No competitions found | Aucune compétition trouvée |
| `no_last_viewed` | No competitions viewed yet | Aucune compétition consultée |

Existing keys reused as-is: `all`, `swimming`, `beach`, `app_title` (already "Live FFSS"), `error_occurred`, `retry`, `open`, `closed`, `soon`, `coming`, `on_going`, `done`, `unknown`.

Existing `this_week_end`, `see_more`, `other_competitions`, `no_other_competitions`, `see` — kept, may become unreferenced after the rewrite. Cleanup of dead translation keys is left to a separate housekeeping pass.

## 9. Tests

Per `CLAUDE.md`: mappers / repositories / controllers / `HttpClient` are tested with `mocktail`; no widget tests, no integration tests.

### `test/data/services/user_preferences_service_test.dart` (new)

- `init` reads existing JSON from secure storage and populates `Rx*` collections.
- `init` tolerates missing keys (empty defaults).
- `toggleFavorite` flips set membership and writes the updated JSON back.
- `recordView` deduplicates, places the viewed ID at front, caps at `_lastViewedCap`.
- Mock `FlutterSecureStorage` (`class _MockStorage extends Mock implements FlutterSecureStorage {}`); register `String` fallback in `setUpAll` for `any()` matchers.

### `test/presentation/modules/home/controllers/home_controller_test.dart` (extended)

- `loadCompetitions` populates state on success; sets `hasError` on `AppException`.
- `filteredCompetitions` honors temporal × discipline × search composition (one test per dimension + one combined).
- `TemporalFilter.lastViewed` returns competitions in last-viewed order, skipping IDs no longer present in the loaded list.
- `navigateToCompetitionDetails` calls `_prefs.recordView` before routing.
- Mocks: `CompetitionRepository`, `UserService`, `LanguageService`, `UserPreferencesService`.

### Not tested

- `_HomeWave` painter, `_CompetitionCard`, `_HomeSearchBar` — view-side, per `CLAUDE.md`.
- `competition_formatting.dart` extension members already in the view layer; pure helpers like `overlapsCurrentWeek` are exercised indirectly through `HomeController` filter tests.

## 10. Files touched (summary)

### New

- `lib/app/data/services/user_preferences_service.dart`
- `test/data/services/user_preferences_service_test.dart`

### Modified

- `lib/app/core/di/initial_binding.dart` — register `UserPreferencesService` after `LanguageService`.
- `lib/app/module/home/bindings/home_binding.dart` — inject `UserPreferencesService` into `HomeController`.
- `lib/app/module/home/controllers/home_controller.dart` — new state, filter composition, favorites/last-viewed delegation; remove pagination + carousel getters; add `TemporalFilter` enum.
- `lib/app/module/home/views/home_view.dart` — full rewrite around the new layout (private widget classes inside the file).
- `lib/app/presentation/modules/home/competition_formatting.dart` — `overlapsCurrentWeek`, `isSwimming`, `isBeach`.
- `lib/app/core/translations/en_us.dart`, `lib/app/core/translations/fr_fr.dart` — new keys.
- `test/presentation/modules/home/controllers/home_controller_test.dart` — extend for filter / favorites / last-viewed coverage.
- `pubspec.yaml` — remove `carousel_slider` (no remaining importer after the rewrite; verified).

## 11. Known gaps acknowledged

- Discipline classification reuses the `SlotController`-style string matching. The typed-enum migration on `RaceFormatDetail` remains a known gap in `CLAUDE.md`.
- No bottom navigation shell. Favorites can be toggled and persisted but there is no Favorites screen yet.
- Last-viewed is purely local. If the user signs in on another device, the list does not roam.
- The wave painter is a single static curve; no animation. Adequate for the redesign brief.

## 12. Risks and decisions

- **Hero color choice (theme primary, not Swimify navy):** explicitly requested by the user. The Material blue (`AppColors.primary`) gives a brighter, more "live timing" feel and aligns with every other surface in the app, at the cost of less visual contrast versus the body.
- **Dropping `carousel_slider`:** confirmed only one importer (`home_view.dart`) and one mention in old plan docs. Removal keeps the dependency surface lean per `CLAUDE.md`'s "no unjustified deps" rule.
- **No new search endpoint:** search is local-only. If competition counts grow well past the auto-paginated total, a server-side filter would be the natural next step.
- **`TemporalFilter` default = `thisWeek`:** matches the screenshot's emphasis. Users can still see everything via "All".
