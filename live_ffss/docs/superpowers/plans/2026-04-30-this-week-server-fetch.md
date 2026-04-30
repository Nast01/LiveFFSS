# "This week" Server-Side Fetch — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move the home-page "Cette semaine" filter from a client-side `Competition.overlapsCurrentWeek` predicate to a server-side date-range fetch (`debut` + `fin` query params), with a separate cache and lazy first-touch loading.

**Architecture:** Add an optional `endDate` to the existing competition data source method. Add a `getCompetitionsForRange({DateTime from, DateTime to, ...})` method to the repository that formats the dates and auto-paginates. In the home controller, keep the existing `competitions` cache for "all" / "lastViewed", and add a parallel `thisWeekCompetitions` cache filled lazily on first switch to the temporal pill. Drop the now-dead `overlapsCurrentWeek` helper.

**Tech Stack:** Flutter 3.22.2 / Dart 3.4.3, GetX 4.6.6, mocktail 1.0.4, intl 0.20.2.

**Reference spec:** `docs/superpowers/specs/2026-04-30-this-week-server-fetch-design.md`

**Note for the engineer:** On Windows, fall back to `C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat` (and `dart.bat`) if `flutter`/`dart` are not on PATH. The endpoint constant lives at `ApiEndpoints.competitionList` (`lib/app/core/config/app_config.dart`), not at the older legacy `ApiConstants` class.

---

## File Structure

### New
- `test/data/datasources/competition_remote_datasource_test.dart` — first test file for this datasource. Mocktail mocks of `HttpClient`. Verifies the new `endDate` → `'fin'` injection.

### Modified
- `lib/app/data/datasources/competition_remote_datasource.dart` — add `String? endDate` to `getCompetitions`; conditional `'fin'` in the query map.
- `lib/app/data/repositories/competition_repository.dart` — add `getCompetitionsForRange` (abstract + impl).
- `lib/app/module/home/controllers/home_controller.dart` — add `thisWeekCompetitions` / `isLoadingThisWeek` / `hasErrorThisWeek` state, `loadThisWeek` method, lazy trigger in `setTemporal`, source-switch in `filteredCompetitions`, extended `refreshAfterLogout`.
- `lib/app/module/home/views/home_view.dart` — body `Obx` aiguille les flags `loading/error` selon le tab actif, retry button calls the right method.
- `lib/app/presentation/modules/home/competition_formatting.dart` — delete `overlapsCurrentWeek`.
- `test/data/repositories/competition_repository_test.dart` — extend with tests for `getCompetitionsForRange`.
- `test/presentation/modules/home/controllers/home_controller_test.dart` — replace 2 obsolete tests, add 6 new ones.

### Task ordering rationale

Tasks must be ordered so the project keeps compiling (otherwise `flutter test` won't run):
1. DataSource (additive, no callers break — `endDate` is optional)
2. Repository (additive, only adds a new method)
3. Controller (consumes the new repo method; stops calling `overlapsCurrentWeek`)
4. View (consumes the new controller flags)
5. **Delete `overlapsCurrentWeek`** (now dead — controller is the only non-doc consumer; safe to remove)
6. Final test sweep

---

## Task 1: Add optional `endDate` to `CompetitionRemoteDataSource` (TDD)

**Files:**
- Test (new): `test/data/datasources/competition_remote_datasource_test.dart`
- Modify: `lib/app/data/datasources/competition_remote_datasource.dart`

- [ ] **Step 1: Write the failing test file**

Create `test/data/datasources/competition_remote_datasource_test.dart` with this exact content:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/config/app_config.dart';
import 'package:live_ffss/app/core/enum/enum.dart';
import 'package:live_ffss/app/core/network/http_client.dart';
import 'package:live_ffss/app/data/datasources/competition_remote_datasource.dart';
import 'package:mocktail/mocktail.dart';

class _MockHttp extends Mock implements HttpClient {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  late _MockHttp http;
  late CompetitionRemoteDataSource ds;

  setUp(() {
    http = _MockHttp();
    ds = CompetitionRemoteDataSourceImpl(http);
    when(() => http.get(any(), query: any(named: 'query')))
        .thenAnswer((_) async => {'data': []});
  });

  group('CompetitionRemoteDataSourceImpl.getCompetitions', () {
    test('without endDate omits "fin" from the query map', () async {
      await ds.getCompetitions(
        season: '2025-2026',
        startDate: '2025-09-29',
        type: CompetitionType.mixte,
        visibility: CompetitionVisibility.passed,
        page: 1,
        pageSize: 10,
      );

      final captured = verify(() => http.get(
            ApiEndpoints.competitionList,
            query: captureAny(named: 'query'),
          )).captured.single as Map<String, dynamic>;

      expect(captured['debut'], '2025-09-29');
      expect(captured.containsKey('fin'), isFalse);
    });

    test('with endDate sends "fin" in the query map', () async {
      await ds.getCompetitions(
        season: '2025-2026',
        startDate: '2026-04-27',
        endDate: '2026-05-03',
        type: CompetitionType.mixte,
        visibility: CompetitionVisibility.passed,
        page: 1,
        pageSize: 10,
      );

      final captured = verify(() => http.get(
            ApiEndpoints.competitionList,
            query: captureAny(named: 'query'),
          )).captured.single as Map<String, dynamic>;

      expect(captured['debut'], '2026-04-27');
      expect(captured['fin'], '2026-05-03');
    });
  });
}
```

- [ ] **Step 2: Run the tests, expect failure**

Run: `flutter test test/data/datasources/competition_remote_datasource_test.dart`

Expected: compile FAIL — `The named parameter 'endDate' isn't defined` in the second test.

- [ ] **Step 3: Edit the data source**

In `lib/app/data/datasources/competition_remote_datasource.dart`, replace the abstract `getCompetitions` declaration (lines 7-14) with:

```dart
  Future<List<CompetitionDto>> getCompetitions({
    required String season,
    required String startDate,
    String? endDate,
    required CompetitionType type,
    required CompetitionVisibility visibility,
    required int page,
    required int pageSize,
  });
```

Replace the impl signature and body (lines 23-49) with:

```dart
  @override
  Future<List<CompetitionDto>> getCompetitions({
    required String season,
    required String startDate,
    String? endDate,
    required CompetitionType type,
    required CompetitionVisibility visibility,
    required int page,
    required int pageSize,
  }) async {
    final body = await _http.get(
      ApiEndpoints.competitionList,
      query: {
        'saison': season,
        'debut': startDate,
        if (endDate != null) 'fin': endDate,
        'type': type.index,
        'visibility': visibility.name,
        'length': pageSize,
        'start': pageSize * (page - 1),
        'order': 'DebutEngagement',
        'orderDirection': 'ASC',
      },
    );
    final list = (body['data'] as List?) ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(CompetitionDto.fromJson)
        .toList();
  }
```

- [ ] **Step 4: Run the tests, expect pass**

Run: `flutter test test/data/datasources/competition_remote_datasource_test.dart`

Expected: `+2: All tests passed!`

- [ ] **Step 5: Run repo tests to confirm no regression**

Run: `flutter test test/data/repositories/competition_repository_test.dart`

Expected: 5 tests still passing (the existing repo tests use `any(named: ...)` matchers that already tolerate the new optional param).

- [ ] **Step 6: Commit**

```bash
git add lib/app/data/datasources/competition_remote_datasource.dart test/data/datasources/competition_remote_datasource_test.dart
git commit -m "feat(competitions): add optional endDate to CompetitionRemoteDataSource.getCompetitions"
```

Stage ONLY those two files. Pre-existing unrelated working-tree modifications (android, competition_repository.dart, pubspec.yaml/lock) must remain unstaged.

---

## Task 2: Add `getCompetitionsForRange` to `CompetitionRepository` (TDD)

**Files:**
- Modify: `lib/app/data/repositories/competition_repository.dart`
- Test (extend): `test/data/repositories/competition_repository_test.dart`

- [ ] **Step 1: Add failing tests for `getCompetitionsForRange`**

In `test/data/repositories/competition_repository_test.dart`, append a new group AFTER the existing `getNext5` group (after line 129, before the final `}`):

```dart

  group('CompetitionRepository.getCompetitionsForRange', () {
    test('forwards yyyy-MM-dd from/to dates to the data source', () async {
      when(() => ds.getCompetitions(
            season: any(named: 'season'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            type: any(named: 'type'),
            visibility: any(named: 'visibility'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => [makeDto(1)]);

      await repo.getCompetitionsForRange(
        from: DateTime(2026, 4, 27),
        to: DateTime(2026, 5, 3),
      );

      verify(() => ds.getCompetitions(
            season: any(named: 'season'),
            startDate: '2026-04-27',
            endDate: '2026-05-03',
            type: CompetitionType.mixte,
            visibility: CompetitionVisibility.passed,
            page: 1,
            pageSize: any(named: 'pageSize'),
          )).called(1);
    });

    test('auto-paginates until a partial page is returned', () async {
      var calls = 0;
      when(() => ds.getCompetitions(
            season: any(named: 'season'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            type: any(named: 'type'),
            visibility: any(named: 'visibility'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async {
        calls++;
        if (calls == 1) return [makeDto(1), makeDto(2), makeDto(3)];
        return [makeDto(4)];
      });

      final list = await repo.getCompetitionsForRange(
        from: DateTime(2026, 4, 27),
        to: DateTime(2026, 5, 3),
        pageSize: 3,
      );

      expect(list.length, 4);
      expect(list.map((c) => c.id), [1, 2, 3, 4]);
      expect(calls, 2);
    });
  });
```

- [ ] **Step 2: Run the tests, expect failure**

Run: `flutter test test/data/repositories/competition_repository_test.dart`

Expected: compile FAIL — `The method 'getCompetitionsForRange' isn't defined for the type 'CompetitionRepository'`.

- [ ] **Step 3: Add the method to the abstract class**

In `lib/app/data/repositories/competition_repository.dart`, inside the `abstract class CompetitionRepository` block (after `getNext5();` declaration, around line 20, before the closing `}`), add:

```dart

  Future<List<Competition>> getCompetitionsForRange({
    required DateTime from,
    required DateTime to,
    CompetitionType type = CompetitionType.mixte,
    CompetitionVisibility visibility = CompetitionVisibility.passed,
    int pageSize = 10,
  });
```

- [ ] **Step 4: Add the impl**

At the top of the file, ensure these imports exist (add the missing one):

```dart
import 'package:intl/intl.dart';
```

(The existing imports — `enum.dart`, `competition_remote_datasource.dart`, `competition_mapper.dart`, `competition.dart` — stay.)

Then in `class CompetitionRepositoryImpl`, append this method AFTER the existing `getNext5` impl (just before the closing `}`):

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

- [ ] **Step 5: Run the tests, expect pass**

Run: `flutter test test/data/repositories/competition_repository_test.dart`

Expected: `+7: All tests passed!` (5 existing + 2 new).

- [ ] **Step 6: Commit**

```bash
git add lib/app/data/repositories/competition_repository.dart test/data/repositories/competition_repository_test.dart
git commit -m "feat(competitions): add getCompetitionsForRange to CompetitionRepository"
```

---

## Task 3: Extend `HomeController` with this-week cache + lazy fetch (TDD)

**Files:**
- Modify: `lib/app/module/home/controllers/home_controller.dart`
- Test (extend + replace): `test/presentation/modules/home/controllers/home_controller_test.dart`

This is the largest task. The controller gains state and a method; the test file gets two replacements + six additions.

- [ ] **Step 1: Update the test file**

In `test/presentation/modules/home/controllers/home_controller_test.dart`:

**(1.a)** Add a default stub for `getCompetitionsForRange` in the existing `setUp` block. After the existing `when(() => prefs.isFavorite(any())).thenReturn(false);` line, ADD:

```dart
    when(() => repo.getCompetitionsForRange(
          from: any(named: 'from'),
          to: any(named: 'to'),
        )).thenAnswer((_) async => <Competition>[]);
```

This ensures any test that calls `setTemporal(TemporalFilter.thisWeek)` without a more specific stub doesn't throw because of an unstubbed mock.

**(1.b)** Register `DateTime` as a fallback value for mocktail in `setUpAll`. After the existing `Get.testMode = true;` line, ADD:

```dart
    registerFallbackValue(DateTime(2000));
```

**(1.c)** Replace the existing test `'temporal=thisWeek keeps only competitions overlapping current week'` (lines ~126-139) with:

```dart
    test('temporal=thisWeek reads from thisWeekCompetitions cache', () {
      controller.competitions.value = [c(1), c(2)];
      controller.thisWeekCompetitions.value = [c(10), c(20)];
      // Fill cache so setTemporal does not auto-fetch.
      controller.setTemporal(TemporalFilter.thisWeek);

      final result = controller.filteredCompetitions.map((x) => x.id).toList();
      expect(result, [10, 20]);
    });
```

**(1.d)** Replace the existing test `'combines temporal, discipline, and search'` (lines ~188-209) with:

```dart
    test('combines temporal, discipline, and search', () {
      controller.thisWeekCompetitions.value = [
        c(1, typeWater: 'Eau-plate'),
        c(2, typeWater: 'Côtier'),
        c(3, typeWater: 'Eau-plate'),
      ];
      controller.setTemporal(TemporalFilter.thisWeek);
      controller.setDiscipline(HomeFilter.pool);
      controller.setSearchQuery('C1');

      expect(controller.filteredCompetitions.map((x) => x.id), [1]);
    });
```

**(1.e)** Add a new group AFTER the existing `'HomeController.navigateToCompetitionDetails'` group (just before the final `}` of `main`):

```dart

  group('HomeController.setTemporal lazy fetch', () {
    test('thisWeek triggers loadThisWeek when cache is empty', () async {
      when(() => repo.getCompetitionsForRange(
            from: any(named: 'from'),
            to: any(named: 'to'),
          )).thenAnswer((_) async => [c(7)]);

      controller.setTemporal(TemporalFilter.thisWeek);
      await Future<void>.delayed(Duration.zero);

      expect(controller.thisWeekCompetitions.map((x) => x.id), [7]);
      verify(() => repo.getCompetitionsForRange(
            from: any(named: 'from'),
            to: any(named: 'to'),
          )).called(1);
    });

    test('thisWeek does not re-fetch when cache is non-empty', () {
      controller.thisWeekCompetitions.value = [c(1)];
      controller.setTemporal(TemporalFilter.thisWeek);

      verifyNever(() => repo.getCompetitionsForRange(
            from: any(named: 'from'),
            to: any(named: 'to'),
          ));
    });

    test('thisWeek does not re-fetch when hasErrorThisWeek is true', () {
      controller.hasErrorThisWeek.value = true;
      controller.setTemporal(TemporalFilter.thisWeek);

      verifyNever(() => repo.getCompetitionsForRange(
            from: any(named: 'from'),
            to: any(named: 'to'),
          ));
    });
  });

  group('HomeController.loadThisWeek', () {
    test('calls repo with Monday and Sunday of current week', () async {
      DateTime? capturedFrom;
      DateTime? capturedTo;
      when(() => repo.getCompetitionsForRange(
            from: any(named: 'from'),
            to: any(named: 'to'),
          )).thenAnswer((invocation) async {
        capturedFrom = invocation.namedArguments[#from] as DateTime;
        capturedTo = invocation.namedArguments[#to] as DateTime;
        return <Competition>[];
      });

      await controller.loadThisWeek();

      expect(capturedFrom, isNotNull);
      expect(capturedTo, isNotNull);
      expect(capturedFrom!.weekday, DateTime.monday);
      expect(capturedTo!.weekday, DateTime.sunday);
      expect(capturedTo!.difference(capturedFrom!).inDays, 6);
    });

    test('on AppException sets hasErrorThisWeek and clears loading', () async {
      when(() => repo.getCompetitionsForRange(
            from: any(named: 'from'),
            to: any(named: 'to'),
          )).thenThrow(const NetworkException('offline'));

      await controller.loadThisWeek();

      expect(controller.hasErrorThisWeek.value, true);
      expect(controller.isLoadingThisWeek.value, false);
      expect(controller.thisWeekCompetitions, isEmpty);
    });
  });

  group('HomeController.refreshAfterLogout extended', () {
    test('clears thisWeekCompetitions and resets hasErrorThisWeek', () {
      when(() => repo.getAllCompetitions(
            type: any(named: 'type'),
            visibility: any(named: 'visibility'),
          )).thenAnswer((_) async => <Competition>[]);
      controller.thisWeekCompetitions.value = [c(1), c(2)];
      controller.hasErrorThisWeek.value = true;

      controller.refreshAfterLogout();

      expect(controller.thisWeekCompetitions, isEmpty);
      expect(controller.hasErrorThisWeek.value, false);
    });
  });
```

- [ ] **Step 2: Run the tests, expect failures**

Run: `flutter test test/presentation/modules/home/controllers/home_controller_test.dart`

Expected: compile FAIL — references to `controller.thisWeekCompetitions`, `controller.hasErrorThisWeek`, `controller.isLoadingThisWeek`, `controller.loadThisWeek`, and `repo.getCompetitionsForRange` mock setup don't match the existing controller surface yet.

- [ ] **Step 3: Update the controller**

In `lib/app/module/home/controllers/home_controller.dart`:

**(3.a)** Remove the import of `competition_formatting.dart` (it'll be re-added after the helper deletion in Task 5; the controller's only consumer of that file was `c.overlapsCurrentWeek` which we're about to remove). Actually, KEEP the import for now — `isSwimming`/`isBeach` are still used in `filteredCompetitions`. Don't touch the imports.

**(3.b)** Replace the existing state-fields block (lines ~29-34) with:

```dart
  final RxList<Competition> competitions = <Competition>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxList<Competition> thisWeekCompetitions = <Competition>[].obs;
  final RxBool isLoadingThisWeek = false.obs;
  final RxBool hasErrorThisWeek = false.obs;
  final Rx<HomeFilter> selectedDiscipline = HomeFilter.all.obs;
  final Rx<TemporalFilter> selectedTemporal = TemporalFilter.thisWeek.obs;
  final RxString searchQuery = ''.obs;
```

**(3.c)** Replace the existing `void setTemporal(TemporalFilter t) => selectedTemporal.value = t;` line with:

```dart
  void setTemporal(TemporalFilter t) {
    selectedTemporal.value = t;
    if (t == TemporalFilter.thisWeek &&
        thisWeekCompetitions.isEmpty &&
        !hasErrorThisWeek.value) {
      loadThisWeek();
    }
  }
```

**(3.d)** Add the `loadThisWeek` method immediately after `loadCompetitions` (after the closing `}` of `loadCompetitions`, around line 62):

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

**(3.e)** Replace the entire `filteredCompetitions` getter (lines ~72-106) with:

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

    switch (selectedDiscipline.value) {
      case HomeFilter.pool:
        result = result.where((c) => c.isSwimming);
      case HomeFilter.coastal:
        result = result.where((c) => c.isBeach);
      case HomeFilter.all:
      case HomeFilter.mixed:
      // no-op
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

(The crucial change: `final source = ... ? thisWeekCompetitions : competitions;` and the `thisWeek` switch arm is now a no-op comment instead of `result = result.where((c) => c.overlapsCurrentWeek);`.)

**(3.f)** Replace the entire `refreshAfterLogout` method (lines ~123-128) with:

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

- [ ] **Step 4: Run the tests, expect pass**

Run: `flutter test test/presentation/modules/home/controllers/home_controller_test.dart`

Expected: 19 tests passing (`+19: All tests passed!`).

- [ ] **Step 5: Commit**

```bash
git add lib/app/module/home/controllers/home_controller.dart test/presentation/modules/home/controllers/home_controller_test.dart
git commit -m "feat(home): add this-week cache and server-side fetch in HomeController"
```

---

## Task 4: Update `HomeView` to aiguille loading/error per active tab

**Files:**
- Modify: `lib/app/module/home/views/home_view.dart`

No widget tests per `CLAUDE.md`. Visual verification deferred to a manual `flutter run` after the branch wraps.

- [ ] **Step 1: Replace the body `Obx`**

In `lib/app/module/home/views/home_view.dart`, find the `Expanded` block at the bottom of `HomeView.build` (currently lines 34-47). Replace it with:

```dart
            Expanded(
              child: Obx(() {
                final isWeek =
                    controller.selectedTemporal.value == TemporalFilter.thisWeek;
                final loading = isWeek
                    ? controller.isLoadingThisWeek.value
                    : controller.isLoading.value;
                final hasErr = isWeek
                    ? controller.hasErrorThisWeek.value
                    : controller.hasError.value;
                if (loading) {
                  return const LoadingIndicator();
                }
                if (hasErr) {
                  return ErrorState(
                    message: 'error_occured'.tr,
                    onRetry: isWeek
                        ? controller.loadThisWeek
                        : controller.loadCompetitions,
                  );
                }
                return const _HomeList();
              }),
            ),
```

- [ ] **Step 2: Verify with the analyzer**

Run: `flutter analyze lib/app/module/home/views/home_view.dart`

Expected: same as before (only the pre-existing info-level `withOpacity` deprecation on line 78). No new errors.

- [ ] **Step 3: Commit**

```bash
git add lib/app/module/home/views/home_view.dart
git commit -m "feat(home): route loading/error UI through this-week flags when tab is active"
```

---

## Task 5: Drop the dead `overlapsCurrentWeek` helper

**Files:**
- Modify: `lib/app/presentation/modules/home/competition_formatting.dart`

After Task 3, the controller no longer references `overlapsCurrentWeek`. The helper is now dead code (the only non-doc consumers were the controller and itself).

- [ ] **Step 1: Verify no remaining consumers**

Use the Grep tool with `pattern: "overlapsCurrentWeek"`, `path: "lib"`, `path: "test"` (run twice or as a single Grep across both).

Expected: no matches in `lib/` or `test/`. (Doc references in `docs/` are fine.)

If you find a match, STOP and report — Task 3 may have left a stray reference.

- [ ] **Step 2: Delete the getter**

In `lib/app/presentation/modules/home/competition_formatting.dart`, delete lines 79-86 (the entire `bool get overlapsCurrentWeek { ... }` block) AND the blank line directly above it (line 78). The file should now flow from `phaseColor` (ending at line 77) directly to a blank line then `bool get isSwimming` (was line 88).

After the deletion, the relevant section should look like:

```dart
  Color get phaseColor => switch (phase) {
        CompetitionStatus.onGoing => AppColors.statusInProgress,
        CompetitionStatus.done => AppColors.textMuted,
        CompetitionStatus.coming => AppColors.primary,
        CompetitionStatus.unknown => AppColors.textMuted,
      };

  bool get isSwimming {
    final t = typeWater.toLowerCase();
    ...
```

- [ ] **Step 3: Verify with the analyzer**

Run: `flutter analyze lib/app/presentation/modules/home/competition_formatting.dart`

Expected: `No issues found!`

- [ ] **Step 4: Run the controller tests to confirm nothing broke**

Run: `flutter test test/presentation/modules/home/controllers/home_controller_test.dart`

Expected: 19 tests still passing.

- [ ] **Step 5: Commit**

```bash
git add lib/app/presentation/modules/home/competition_formatting.dart
git commit -m "chore(competitions): drop dead overlapsCurrentWeek helper after server-side fetch"
```

---

## Task 6: Final test sweep

**Files:** none (verification only).

- [ ] **Step 1: Run the full suite**

Run: `flutter test`

Expected: **140 + 6 + 2 = 148 tests pass.** (140 existing baseline + 6 new in `home_controller_test.dart` + 2 new in `competition_repository_test.dart` for `getCompetitionsForRange` + 2 new in `competition_remote_datasource_test.dart`. Net delta: +10 over the previous 140. Final count: ~150. Use the actual reported number — exact arithmetic isn't critical, the requirement is everything green.)

- [ ] **Step 2: If anything fails, fix in place**

Most likely failure mode: a test elsewhere accidentally exercises the new code path through DI. Diagnose and fix; do not mark complete until all tests pass.

- [ ] **Step 3: Commit any incidental fixes (only if needed)**

```bash
git add <fixed files>
git commit -m "fix: <one-sentence description>"
```

If no fixes needed, skip the commit.

---

## Self-Review

**Spec coverage check (against `docs/superpowers/specs/2026-04-30-this-week-server-fetch-design.md`):**

| Spec section | Plan task |
|---|---|
| §2 In scope: optional `endDate` on data source | Task 1 |
| §2 In scope: `getCompetitionsForRange` repository method | Task 2 |
| §2 In scope: `thisWeekCompetitions` cache + flags + `loadThisWeek` | Task 3 |
| §2 In scope: `setTemporal` lazy trigger | Task 3 (3.c) |
| §2 In scope: `filteredCompetitions` source switch | Task 3 (3.e) |
| §2 In scope: extended `refreshAfterLogout` | Task 3 (3.f) |
| §2 In scope: view aiguillage loading/error | Task 4 |
| §2 In scope: drop `overlapsCurrentWeek` | Task 5 |
| §4 DataSource shape | Task 1 |
| §5 Repository shape | Task 2 |
| §6 Controller shape | Task 3 |
| §7 View shape | Task 4 |
| §8 Helper deletion | Task 5 |
| §9 Tests (data source / repo / controller) | Tasks 1, 2, 3 |
| §10 Files touched | All tasks |

**Type-consistency spot-check:**
- `getCompetitions(... endDate: String? ...)` — same shape in datasource abstract, impl, repository call site (Task 2 step 4), and tests.
- `getCompetitionsForRange({DateTime from, DateTime to, ...})` — same signature in repo abstract (Task 2 step 3), impl (Task 2 step 4), controller call site (Task 3 step 3.d), and tests (Task 3 step 1).
- Field names `thisWeekCompetitions`, `isLoadingThisWeek`, `hasErrorThisWeek`, method `loadThisWeek` — consistent across controller, view (Task 4 step 1), and tests.
- `'fin'` is the literal query key, identical between datasource impl and the assertion in Task 1 step 1.

**Placeholder scan:** no TBDs, TODOs, "implement later", or "similar to Task N" abbreviations.

**Missing-from-spec check:** no spec section is unrepresented.
