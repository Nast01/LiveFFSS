# "This week" server-side fetch — design spec

Date: 2026-04-30
Author: brainstorming session with Stan
Builds on: `docs/superpowers/specs/2026-04-29-home-page-redesign-design.md`

## 1. Goal

Move the "Cette semaine" filter on the home page from a client-side `Competition.overlapsCurrentWeek` predicate to a server-side date-range fetch. The home controller computes Monday and Sunday of the current week, hits the FFSS competition list endpoint with `debut` and `fin` query parameters, and caches the result separately from the existing "all" cache.

## 2. Scope

### In scope
- Extend `CompetitionRemoteDataSource.getCompetitions` with an optional `String? endDate` parameter; inject `'fin': endDate` into the HTTP query map only when non-null.
- Add `CompetitionRepository.getCompetitionsForRange({required DateTime from, required DateTime to, ...})` that formats the dates as `yyyy-MM-dd`, auto-paginates, and returns domain models.
- In `HomeController`:
  - New state: `RxList<Competition> thisWeekCompetitions`, `RxBool isLoadingThisWeek`, `RxBool hasErrorThisWeek`.
  - New method `loadThisWeek()` that computes Monday/Sunday and calls the repository.
  - `setTemporal` triggers `loadThisWeek` lazily (idempotent: skips fetch if cache is non-empty OR if the previous attempt errored).
  - `filteredCompetitions` selects `thisWeekCompetitions` as the source list when `selectedTemporal == TemporalFilter.thisWeek`; falls back to `competitions` otherwise.
  - `refreshAfterLogout` clears both caches and resets both error/loading flags.
- In `HomeView`, route loading/error UI through the right pair of flags depending on the active temporal tab. Retry button calls `loadThisWeek()` when on the "Cette semaine" tab, `loadCompetitions()` otherwise.
- Remove the now-dead `Competition.overlapsCurrentWeek` getter from `lib/app/presentation/modules/home/competition_formatting.dart`.

### Out of scope
- `CompetitionRepository.getNext5` is not modified (no current consumer needs date-range slicing).
- No pull-to-refresh added — the existing `ErrorState` retry button is the only refresh affordance.
- No new UI; the visual layout of `HomeView` is unchanged.
- No backwards-compatibility shim for the deleted `overlapsCurrentWeek` getter — it is genuinely unused after this change.

## 3. Architecture

```
HomeView (Obx on the right pair of flags per tab)
  │
  ▼
HomeController
  ├── competitions             ← existing "all" cache
  ├── thisWeekCompetitions     ← NEW week-bounded cache
  └── loadThisWeek() ──────────────────────────────┐
                                                    ▼
                                CompetitionRepository.getCompetitionsForRange(from, to)
                                                    │
                                                    ▼
                                CompetitionRemoteDataSource.getCompetitions(
                                  ..., startDate=mondayStr, endDate=sundayStr, ...
                                )
                                                    │
                                                    ▼
                                HttpClient.get(competition/evenement, query={
                                  'saison': ..., 'debut': mondayStr, 'fin': sundayStr, ...
                                })
```

## 4. Data source change

`lib/app/data/datasources/competition_remote_datasource.dart`

```dart
abstract class CompetitionRemoteDataSource {
  Future<List<CompetitionDto>> getCompetitions({
    required String season,
    required String startDate,
    String? endDate,                                  // NEW
    required CompetitionType type,
    required CompetitionVisibility visibility,
    required int page,
    required int pageSize,
  });
}
```

In the impl, the query map gains a conditional entry:

```dart
{
  'saison': season,
  'debut': startDate,
  if (endDate != null) 'fin': endDate,
  'type': type.index,
  'visibility': visibility.name,
  'length': pageSize,
  'start': pageSize * (page - 1),
  'order': 'DebutEngagement',
  'orderDirection': 'ASC',
}
```

The conditional `if`-in-collection-literal is the idiomatic Dart way to omit absent params and matches the existing FFSS contract: `fin` is interpreted as inclusive end-of-day per the API convention used for `debut`.

## 5. Repository change

`lib/app/data/repositories/competition_repository.dart`

Existing `getCompetitions`, `getAllCompetitions`, `getNext5` are unchanged. New method:

```dart
abstract class CompetitionRepository {
  // ... existing ...

  Future<List<Competition>> getCompetitionsForRange({
    required DateTime from,
    required DateTime to,
    CompetitionType type = CompetitionType.mixte,
    CompetitionVisibility visibility = CompetitionVisibility.passed,
    int pageSize = 10,
  });
}
```

Impl:

```dart
@override
Future<List<Competition>> getCompetitionsForRange({
  required DateTime from,
  required DateTime to,
  CompetitionType type = CompetitionType.mixte,
  CompetitionVisibility visibility = CompetitionVisibility.passed,
  int pageSize = _defaultPageSize,
}) async {
  final fmt = DateFormat('yyyy-MM-dd');
  final fromStr = fmt.format(from);
  final toStr = fmt.format(to);
  final all = <Competition>[];
  var page = 1;
  while (true) {
    final dtos = await _dataSource.getCompetitions(
      season: _defaultSeason,
      startDate: fromStr,
      endDate: toStr,
      type: type,
      visibility: visibility,
      page: page,
      pageSize: pageSize,
    );
    final batch = dtos.map((d) => d.toDomain()).toList();
    if (batch.isEmpty) break;
    all.addAll(batch);
    if (batch.length < pageSize) break;
    page++;
  }
  return all;
}
```

`visibility: passed` matches the default of the existing `loadCompetitions` flow on the home (the FFSS `visibility=passed` enum value is what the "show me everything from the season so far" call uses today).

`DateFormat` from `package:intl/intl.dart` — already a project dependency.

## 6. Controller change

`lib/app/module/home/controllers/home_controller.dart`

### New state

```dart
final RxList<Competition> thisWeekCompetitions = <Competition>[].obs;
final RxBool isLoadingThisWeek = false.obs;
final RxBool hasErrorThisWeek = false.obs;
```

### `setTemporal` becomes lazy-fetching

```dart
void setTemporal(TemporalFilter t) {
  selectedTemporal.value = t;
  if (t == TemporalFilter.thisWeek &&
      thisWeekCompetitions.isEmpty &&
      !hasErrorThisWeek.value) {
    loadThisWeek(); // fire-and-forget; future is not awaited
  }
}
```

The `!hasErrorThisWeek.value` guard prevents an infinite re-fetch loop if the previous attempt errored. The user explicitly retries via the `ErrorState` button.

### `loadThisWeek`

```dart
Future<void> loadThisWeek() async {
  try {
    isLoadingThisWeek.value = true;
    hasErrorThisWeek.value = false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    final loaded = await _competitionRepo.getCompetitionsForRange(
      from: monday,
      to: sunday,
    );
    loaded.sort((a, b) {
      final dateComparison = (a.beginDate ?? DateTime(0))
          .compareTo(b.beginDate ?? DateTime(0));
      if (dateComparison != 0) return dateComparison;
      return a.name.compareTo(b.name);
    });
    thisWeekCompetitions.value = loaded;
  } on AppException {
    hasErrorThisWeek.value = true;
  } finally {
    isLoadingThisWeek.value = false;
  }
}
```

The Monday/Sunday computation matches the (now-deleted) `overlapsCurrentWeek` semantics: ISO Monday-start week, Sunday-end inclusive.

### `filteredCompetitions` source switch

```dart
List<Competition> get filteredCompetitions {
  final source = selectedTemporal.value == TemporalFilter.thisWeek
      ? thisWeekCompetitions
      : competitions;
  Iterable<Competition> result = source;

  switch (selectedTemporal.value) {
    case TemporalFilter.lastViewed:
      final byId = {for (final c in competitions) c.id: c};
      result = _prefs.lastViewedIds
          .map((id) => byId[id])
          .where((c) => c != null)
          .cast<Competition>();
    case TemporalFilter.thisWeek:
      // already filtered server-side
    case TemporalFilter.all:
      // no-op
  }

  // discipline + search blocks unchanged.
  // ...
}
```

`lastViewed` continues to look up by id against the `competitions` cache (the "all" set) — its semantics are unchanged. `thisWeek` simply uses the new cache as its source and applies no extra date filter.

### `refreshAfterLogout` extended

```dart
void refreshAfterLogout() {
  selectedDiscipline.value = HomeFilter.all;
  selectedTemporal.value = TemporalFilter.thisWeek;
  searchQuery.value = '';
  thisWeekCompetitions.clear();
  hasErrorThisWeek.value = false;
  loadCompetitions();
}
```

The clear on `thisWeekCompetitions` invalidates the cache so a freshly logged-in user re-fetches when they touch the "Cette semaine" tab; `loadCompetitions()` reloads the "all" cache as before.

## 7. View change

`lib/app/module/home/views/home_view.dart`

The body `Obx` switches between the two pairs of flags based on the active temporal tab:

```dart
Expanded(
  child: Obx(() {
    final isWeek = controller.selectedTemporal.value == TemporalFilter.thisWeek;
    final loading = isWeek ? controller.isLoadingThisWeek.value : controller.isLoading.value;
    final hasErr  = isWeek ? controller.hasErrorThisWeek.value : controller.hasError.value;
    if (loading) return const LoadingIndicator();
    if (hasErr) {
      return ErrorState(
        message: 'error_occured'.tr,
        onRetry: isWeek ? controller.loadThisWeek : controller.loadCompetitions,
      );
    }
    return const _HomeList();
  }),
),
```

No other widget changes. The card list, hero, wave, search bar, discipline pills, and translation keys are untouched.

## 8. Helper deletion

`lib/app/presentation/modules/home/competition_formatting.dart`

Delete the `overlapsCurrentWeek` getter and its surrounding blank line. `isSwimming`, `isBeach`, `formattedDateRange`, and the existing date/status helpers stay.

No imports need cleanup (the getter doesn't reference any import that's used only by it).

## 9. Tests

Per `CLAUDE.md`: mappers / repositories / controllers / data sources are tested with `mocktail`; no widget tests.

### `test/data/datasources/competition_remote_datasource_test.dart` (NEW)

First test file for this datasource.

- `getCompetitions without endDate omits 'fin' from the query map`.
- `getCompetitions with endDate sends 'fin' in the query map`.

Mock `HttpClient`. Use `verify(() => http.get(any(), query: any(named: 'query')))` with a captor (or pass an inline `Map` matcher) to assert the query content.

### `test/data/repositories/competition_repository_test.dart` (extension)

- `getCompetitionsForRange formats from/to as yyyy-MM-dd and forwards endDate`.
- `getCompetitionsForRange auto-paginates until a partial page is returned` — parallel to the existing `getAllCompetitions` test.

### `test/presentation/modules/home/controllers/home_controller_test.dart` (extension + fixes)

- New: `setTemporal(thisWeek) triggers loadThisWeek when cache is empty`.
- New: `setTemporal(thisWeek) does not re-fetch when cache is non-empty`.
- New: `setTemporal(thisWeek) does not re-fetch when hasErrorThisWeek is true`.
- New: `loadThisWeek computes Monday and Sunday of current week and calls repo` — verify `from`/`to` arguments. Use a date-only comparison matcher (compare `from.weekday == DateTime.monday`, `to.weekday == DateTime.sunday`, `to.difference(from).inDays == 6`).
- New: `loadThisWeek on AppException sets hasErrorThisWeek`.
- New: `filteredCompetitions reads thisWeekCompetitions when temporal=thisWeek` — populate both caches with disjoint sets and assert which is read.
- New: `refreshAfterLogout clears thisWeekCompetitions and resets hasErrorThisWeek`.
- **Fix existing tests** that exercise `temporal=thisWeek` (the test "temporal=thisWeek keeps only competitions overlapping current week" and the combined-filter test): now they must populate `thisWeekCompetitions` directly rather than `competitions`, because the controller no longer applies a client-side week filter.

## 10. Files touched (summary)

### New
- `test/data/datasources/competition_remote_datasource_test.dart`

### Modified
- `lib/app/data/datasources/competition_remote_datasource.dart`
- `lib/app/data/repositories/competition_repository.dart`
- `lib/app/module/home/controllers/home_controller.dart`
- `lib/app/module/home/views/home_view.dart`
- `lib/app/presentation/modules/home/competition_formatting.dart`
- `test/data/repositories/competition_repository_test.dart`
- `test/presentation/modules/home/controllers/home_controller_test.dart`

## 11. Risks and decisions

- **Chosen: lazy fetch on first tab switch, cache thereafter.** Alternative was parallel fetch at boot. Lazy is more polite to the network and the FFSS API; the cost is a one-shot loading spinner the first time the user clicks "Cette semaine" — acceptable.
- **Chosen: error state stops the auto-refetch loop.** If `loadThisWeek` errors, `setTemporal(thisWeek)` no longer auto-fires. The user retries explicitly via the `ErrorState` button. Avoids hammering a failing endpoint.
- **Chosen: drop `overlapsCurrentWeek` outright.** Two filters (server + client) on the same axis would be a maintenance liability and confuse future readers about which is authoritative.
- **`fin` semantics assumed inclusive day boundary** — matches `debut`'s known convention. If the FFSS API treats it as exclusive, competitions on Sunday would be missed; this would surface in manual testing and be a one-line tweak (`sunday + 1.day`). No way to confirm without backend doc or a test call.
- **Date-only comparator in tests:** `DateTime.now()` is non-deterministic, so tests can't assert exact `from`/`to` instants. They assert weekday + duration relationships instead. This matches the existing test pattern for `temporal=thisWeek` which also uses `DateTime.now()`.
- **`refreshAfterLogout` uses `loadCompetitions()` only**, not also `loadThisWeek()`. The week cache is only repopulated on next user click. Trade-off: avoids burning a network call for a tab the user may not visit immediately after logout. The clear ensures correctness if they do.
