# Live FFSS Home Page Redesign — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the existing `HomeView` with a Swimify-inspired hero + wave + filter/search/list layout, themed with the existing `AppColors` palette, and add persistent favorites + last-viewed history.

**Architecture:** 3-layer (`Controller → Repository → DataSource`) with GetX state and DI. One new long-lived service (`UserPreferencesService`, `GetxService`) backed by `FlutterSecureStorage` for favorites and last-viewed competition IDs. View rewrite stays inside `home_view.dart` with private widget classes; no datasource or repository changes.

**Tech Stack:** Flutter 3.22.2 / Dart 3.4.3, GetX 4.6.6, freezed 2.5.2, mocktail 1.0.4, flutter_secure_storage 9.2.4, intl 0.20.2.

**Reference spec:** `docs/superpowers/specs/2026-04-29-home-page-redesign-design.md`

**Note for the engineer:** On Windows, if `flutter` / `dart` are not on `PATH`, fall back to `C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat` (and `dart.bat`). All sample commands assume `flutter` resolves; substitute the absolute path otherwise.

---

## File Structure

### New
- `lib/app/data/services/user_preferences_service.dart` — `GetxService` wrapping `FlutterSecureStorage`. One responsibility: persist + expose reactive sets/lists for favorites and last-viewed competition IDs.
- `test/data/services/user_preferences_service_test.dart` — unit tests for the service (mocktail mocks of `FlutterSecureStorage`).

### Modified
- `lib/app/core/translations/en_us.dart`, `lib/app/core/translations/fr_fr.dart` — add 6 new keys.
- `lib/app/presentation/modules/home/competition_formatting.dart` — add `overlapsCurrentWeek`, `isSwimming`, `isBeach` getters on `Competition`.
- `lib/app/data/services/user_preferences_service.dart` (new — listed above).
- `lib/app/core/di/initial_binding.dart` — register `UserPreferencesService` as step 7 in the `permanent` graph.
- `lib/app/module/home/controllers/home_controller.dart` — add `TemporalFilter` enum, new state, composed `filteredCompetitions` getter, favorites/last-viewed delegation, drop pagination + carousel getters.
- `test/presentation/modules/home/controllers/home_controller_test.dart` — replace tests for the deleted shape with tests for the new shape.
- `lib/app/module/home/bindings/home_binding.dart` — inject the new service into `HomeController`.
- `lib/app/module/home/views/home_view.dart` — full rewrite around hero + wave + filter/search/list layout (private widget classes inside the file).
- `pubspec.yaml` — drop unused `carousel_slider` dependency.

---

## Task 1: Add translation keys

**Files:**
- Modify: `lib/app/core/translations/en_us.dart` (insert new block after the existing `'no_other_competitions'` entry)
- Modify: `lib/app/core/translations/fr_fr.dart` (same location)

- [ ] **Step 1: Add EN keys**

In `lib/app/core/translations/en_us.dart`, insert this block immediately after the line `'no_other_competitions': 'No other competitions',` (currently around line 69):

```dart
  // Home page (redesign 2026-04)
  'last_viewed': 'Last viewed',
  'this_week': 'This week',
  'search_competitions': 'Search competition',
  'live': 'LIVE',
  'no_competitions_found': 'No competitions found',
  'no_last_viewed': 'No competitions viewed yet',

```

- [ ] **Step 2: Add FR keys**

In `lib/app/core/translations/fr_fr.dart`, insert this block immediately after the line `'no_other_competitions': 'Pas d\'autres compétitions',` (currently around line 68):

```dart
  // Home page (redesign 2026-04)
  'last_viewed': 'Vus récemment',
  'this_week': 'Cette semaine',
  'search_competitions': 'Rechercher une compétition',
  'live': 'LIVE',
  'no_competitions_found': 'Aucune compétition trouvée',
  'no_last_viewed': 'Aucune compétition consultée',

```

- [ ] **Step 3: Verify with the analyzer**

Run: `flutter analyze lib/app/core/translations/en_us.dart lib/app/core/translations/fr_fr.dart`

Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/app/core/translations/en_us.dart lib/app/core/translations/fr_fr.dart
git commit -m "feat(translations): add home redesign keys (last_viewed, this_week, search, live, empty states)"
```

---

## Task 2: Add `CompetitionFormatting` helpers

**Files:**
- Modify: `lib/app/presentation/modules/home/competition_formatting.dart` (append three new getters at the end of the extension)

These pure helpers are exercised through the controller tests in Task 5. Per `CLAUDE.md`: no widget tests, and these are view-side helpers that don't warrant a dedicated test file.

- [ ] **Step 1: Add the three getters**

Open `lib/app/presentation/modules/home/competition_formatting.dart` and insert the following before the closing `}` of the extension (i.e., after the existing `phaseColor` getter, currently around line 77):

```dart

  bool get overlapsCurrentWeek {
    if (beginDate == null || endDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    return beginDate!.isBefore(weekEnd) && endDate!.isAfter(weekStart);
  }

  bool get isSwimming {
    final t = typeWater.toLowerCase();
    return t.contains('eau-plate') ||
        t.contains('eau plate') ||
        t.contains('swimming') ||
        t.contains('piscine');
  }

  bool get isBeach {
    final t = typeWater.toLowerCase();
    return t.contains('côtier') ||
        t.contains('cotier') ||
        t.contains('beach') ||
        t.contains('coastal');
  }
```

The string-matching mirrors `SlotController.isSwimmingDiscipline` / `isBeachDiscipline` (lib/app/module/slot/controllers/slot_controller.dart:104-118), with `cotier` (no diacritic) and `eau plate` (with space) added defensively. The typed-enum migration on `RaceFormatDetail` remains a known gap in `CLAUDE.md`.

- [ ] **Step 2: Verify with the analyzer**

Run: `flutter analyze lib/app/presentation/modules/home/competition_formatting.dart`

Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/app/presentation/modules/home/competition_formatting.dart
git commit -m "feat(competition): add overlapsCurrentWeek, isSwimming, isBeach helpers"
```

---

## Task 3: Add `UserPreferencesService` (TDD)

**Files:**
- Create: `lib/app/data/services/user_preferences_service.dart`
- Test: `test/data/services/user_preferences_service_test.dart`

- [ ] **Step 1: Write the failing test file**

Create `test/data/services/user_preferences_service_test.dart` with this content:

```dart
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/services/user_preferences_service.dart';
import 'package:mocktail/mocktail.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  setUpAll(() {
    registerFallbackValue('');
  });

  late _MockSecureStorage storage;
  late UserPreferencesService prefs;

  setUp(() {
    storage = _MockSecureStorage();
    prefs = UserPreferencesService(storage);
  });

  group('UserPreferencesService.init', () {
    test('reads existing JSON for both keys and populates Rx collections',
        () async {
      when(() => storage.read(key: 'favorite_competitions'))
          .thenAnswer((_) async => '[1,2,3]');
      when(() => storage.read(key: 'last_viewed_competitions'))
          .thenAnswer((_) async => '[10,20,30]');

      await prefs.init();

      expect(prefs.favoriteIds, {1, 2, 3});
      expect(prefs.lastViewedIds, [10, 20, 30]);
    });

    test('tolerates missing keys (empty defaults)', () async {
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);

      await prefs.init();

      expect(prefs.favoriteIds, isEmpty);
      expect(prefs.lastViewedIds, isEmpty);
    });
  });

  group('UserPreferencesService.toggleFavorite', () {
    test('adds id when absent, removes when present, persists JSON',
        () async {
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);
      when(() => storage.write(
              key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async {});
      await prefs.init();

      await prefs.toggleFavorite(7);
      expect(prefs.favoriteIds, {7});
      verify(() => storage.write(
          key: 'favorite_competitions', value: jsonEncode([7]))).called(1);

      await prefs.toggleFavorite(7);
      expect(prefs.favoriteIds, isEmpty);
      verify(() => storage.write(
          key: 'favorite_competitions',
          value: jsonEncode(<int>[]))).called(1);
    });

    test('isFavorite reflects in-memory state', () async {
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => '[42]');
      await prefs.init();

      expect(prefs.isFavorite(42), isTrue);
      expect(prefs.isFavorite(99), isFalse);
    });
  });

  group('UserPreferencesService.recordView', () {
    test('moves id to front and dedupes', () async {
      when(() => storage.read(key: 'favorite_competitions'))
          .thenAnswer((_) async => null);
      when(() => storage.read(key: 'last_viewed_competitions'))
          .thenAnswer((_) async => '[3,1,2]');
      when(() => storage.write(
              key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async {});
      await prefs.init();

      await prefs.recordView(2);

      expect(prefs.lastViewedIds, [2, 3, 1]);
      verify(() => storage.write(
          key: 'last_viewed_competitions',
          value: jsonEncode([2, 3, 1]))).called(1);
    });

    test('caps the list at 20 entries', () async {
      when(() => storage.read(key: 'favorite_competitions'))
          .thenAnswer((_) async => null);
      // Initial list = [20, 19, ..., 1] (newest first, 20 items).
      final initial = List.generate(20, (i) => 20 - i);
      when(() => storage.read(key: 'last_viewed_competitions'))
          .thenAnswer((_) async => jsonEncode(initial));
      when(() => storage.write(
              key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async {});
      await prefs.init();

      await prefs.recordView(99);

      expect(prefs.lastViewedIds.length, 20);
      expect(prefs.lastViewedIds.first, 99);
      expect(prefs.lastViewedIds.last, 2); // 1 dropped from the tail
    });
  });
}
```

- [ ] **Step 2: Run the tests, expect failures**

Run: `flutter test test/data/services/user_preferences_service_test.dart`

Expected: FAIL — `Target of URI doesn't exist: 'package:live_ffss/app/data/services/user_preferences_service.dart'`.

- [ ] **Step 3: Create the service**

Create `lib/app/data/services/user_preferences_service.dart` with this content:

```dart
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class UserPreferencesService extends GetxService {
  UserPreferencesService(this._storage);

  static const _favoritesKey = 'favorite_competitions';
  static const _lastViewedKey = 'last_viewed_competitions';
  static const _lastViewedCap = 20;

  final FlutterSecureStorage _storage;
  final RxSet<int> favoriteIds = <int>{}.obs;
  final RxList<int> lastViewedIds = <int>[].obs; // newest first

  Future<UserPreferencesService> init() async {
    favoriteIds.value = (await _readIds(_favoritesKey)).toSet();
    lastViewedIds.value = await _readIds(_lastViewedKey);
    return this;
  }

  bool isFavorite(int id) => favoriteIds.contains(id);

  Future<void> toggleFavorite(int id) async {
    if (favoriteIds.contains(id)) {
      favoriteIds.remove(id);
    } else {
      favoriteIds.add(id);
    }
    await _storage.write(
      key: _favoritesKey,
      value: jsonEncode(favoriteIds.toList()),
    );
  }

  Future<void> recordView(int id) async {
    final updated = [id, ...lastViewedIds.where((existing) => existing != id)];
    if (updated.length > _lastViewedCap) {
      updated.removeRange(_lastViewedCap, updated.length);
    }
    lastViewedIds.value = updated;
    await _storage.write(
      key: _lastViewedKey,
      value: jsonEncode(updated),
    );
  }

  Future<List<int>> _readIds(String key) async {
    final raw = await _storage.read(key: key);
    if (raw == null || raw.isEmpty) return <int>[];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.cast<int>();
  }
}
```

- [ ] **Step 4: Run the tests, expect pass**

Run: `flutter test test/data/services/user_preferences_service_test.dart`

Expected: `+7: All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/app/data/services/user_preferences_service.dart test/data/services/user_preferences_service_test.dart
git commit -m "feat(prefs): add UserPreferencesService for favorites and last-viewed history"
```

---

## Task 4: Register `UserPreferencesService` in `InitialBinding`

**Files:**
- Modify: `lib/app/core/di/initial_binding.dart`

No dedicated test (matches existing `LanguageService` / `UserService` registration convention).

- [ ] **Step 1: Add the import**

Open `lib/app/core/di/initial_binding.dart`. Add this import in the existing import block (alphabetical after `user_service.dart`, currently the last data-services import on line 19):

```dart
import 'package:live_ffss/app/data/services/user_preferences_service.dart';
```

- [ ] **Step 2: Add the `putAsync` registration**

In the same file, after the existing `LanguageService` registration block (currently lines 115-117), append:

```dart
    await Get.putAsync<UserPreferencesService>(
      () async => UserPreferencesService(
        Get.find<FlutterSecureStorage>(),
      ).init(),
    );
```

The block now ends with three sequential `putAsync` calls: `UserService`, `LanguageService`, `UserPreferencesService`. All three are `GetxService` instances depending on already-registered singletons.

- [ ] **Step 3: Verify with the analyzer**

Run: `flutter analyze lib/app/core/di/initial_binding.dart`

Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/app/core/di/initial_binding.dart
git commit -m "feat(di): register UserPreferencesService in InitialBinding"
```

---

## Task 5: Extend `HomeController` (TDD)

**Files:**
- Test: `test/presentation/modules/home/controllers/home_controller_test.dart` (full rewrite — old tests target the deleted shape)
- Modify: `lib/app/module/home/controllers/home_controller.dart` (full rewrite)

- [ ] **Step 1: Replace the test file with the new shape**

Overwrite `test/presentation/modules/home/controllers/home_controller_test.dart` with:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/enum/enum.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/core/services/language_service.dart';
import 'package:live_ffss/app/data/repositories/competition_repository.dart';
import 'package:live_ffss/app/data/services/user_preferences_service.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/module/home/controllers/home_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements CompetitionRepository {}

class _MockUserService extends Mock implements UserService {}

class _MockLanguageService extends Mock implements LanguageService {}

class _MockPrefs extends Mock implements UserPreferencesService {}

void main() {
  setUpAll(() {
    registerFallbackValue(CompetitionType.mixte);
    registerFallbackValue(CompetitionVisibility.incoming);
    Get.testMode = true;
  });

  late _MockRepo repo;
  late _MockUserService users;
  late _MockLanguageService lang;
  late _MockPrefs prefs;
  late HomeController controller;

  Competition c(
    int id, {
    DateTime? begin,
    DateTime? end,
    String typeWater = '',
    String? location,
  }) =>
      Competition(
        id: id,
        name: 'C$id',
        beginDate: begin,
        endDate: end,
        location: location,
        statusCode: 0,
        statusLabel: '',
        speciality: 0,
        specialityLabel: '',
        typeWater: typeWater,
        typePool: '',
        typeChrono: '',
        isEligibleToNationalRecord: false,
        numberOfLanes: 0,
        organizer: 'X',
        hasBegun: false,
        hasResult: false,
        hasPassed: false,
        level: 0,
        levelLabel: '',
        organizerClub: const Club(id: 1, name: 'X'),
      );

  setUp(() {
    repo = _MockRepo();
    users = _MockUserService();
    lang = _MockLanguageService();
    prefs = _MockPrefs();
    when(() => lang.currentLanguage).thenReturn('fr_FR'.obs);
    when(() => prefs.lastViewedIds).thenReturn(<int>[].obs);
    when(() => prefs.favoriteIds).thenReturn(<int>{}.obs);
    when(() => prefs.isFavorite(any())).thenReturn(false);
    controller = HomeController(repo, users, lang, prefs);
  });

  group('HomeController.loadCompetitions', () {
    test('loads, sorts by beginDate then name, clears error', () async {
      when(() => repo.getAllCompetitions(
            type: any(named: 'type'),
            visibility: any(named: 'visibility'),
          )).thenAnswer((_) async => [
            c(2, begin: DateTime.utc(2026, 5, 2)),
            c(1, begin: DateTime.utc(2026, 5, 1)),
          ]);

      await controller.loadCompetitions();

      expect(controller.competitions.length, 2);
      expect(controller.competitions.first.id, 1);
      expect(controller.isLoading.value, false);
      expect(controller.hasError.value, false);
    });

    test('on AppException sets hasError and clears loading', () async {
      when(() => repo.getAllCompetitions(
            type: any(named: 'type'),
            visibility: any(named: 'visibility'),
          )).thenThrow(const NetworkException('offline'));

      await controller.loadCompetitions();

      expect(controller.competitions, isEmpty);
      expect(controller.hasError.value, true);
      expect(controller.isLoading.value, false);
    });
  });

  group('HomeController.filteredCompetitions', () {
    test('temporal=all returns everything', () {
      controller.competitions.value = [c(1), c(2), c(3)];
      controller.setTemporal(TemporalFilter.all);
      controller.setDiscipline(HomeFilter.all);
      controller.setSearchQuery('');

      expect(controller.filteredCompetitions.length, 3);
    });

    test('temporal=thisWeek keeps only competitions overlapping current week',
        () {
      final now = DateTime.now();
      final inWeek = c(1, begin: now, end: now.add(const Duration(days: 1)));
      final farFuture = c(
        2,
        begin: now.add(const Duration(days: 60)),
        end: now.add(const Duration(days: 61)),
      );
      controller.competitions.value = [inWeek, farFuture];
      controller.setTemporal(TemporalFilter.thisWeek);

      expect(controller.filteredCompetitions, [inWeek]);
    });

    test(
        'temporal=lastViewed returns competitions in last-viewed order, '
        'skipping ids not loaded', () {
      when(() => prefs.lastViewedIds).thenReturn(<int>[3, 99, 1].obs);
      controller.competitions.value = [c(1), c(2), c(3)];
      controller.setTemporal(TemporalFilter.lastViewed);

      final result = controller.filteredCompetitions.map((x) => x.id).toList();
      expect(result, [3, 1]);
    });

    test('discipline=pool keeps only swimming competitions', () {
      controller.competitions.value = [
        c(1, typeWater: 'Eau-plate'),
        c(2, typeWater: 'Côtier'),
      ];
      controller.setTemporal(TemporalFilter.all);
      controller.setDiscipline(HomeFilter.pool);

      expect(controller.filteredCompetitions.map((x) => x.id), [1]);
    });

    test('discipline=coastal keeps only beach competitions', () {
      controller.competitions.value = [
        c(1, typeWater: 'Eau-plate'),
        c(2, typeWater: 'Côtier'),
      ];
      controller.setTemporal(TemporalFilter.all);
      controller.setDiscipline(HomeFilter.coastal);

      expect(controller.filteredCompetitions.map((x) => x.id), [2]);
    });

    test('search filters by name and location, case-insensitive', () {
      controller.competitions.value = [
        c(1, location: 'Paris'),
        c(2, location: 'Lyon'),
      ];
      controller.setTemporal(TemporalFilter.all);

      controller.setSearchQuery('PARIS');
      expect(controller.filteredCompetitions.map((x) => x.id), [1]);

      controller.setSearchQuery('c2');
      expect(controller.filteredCompetitions.map((x) => x.id), [2]);
    });

    test('combines temporal, discipline, and search', () {
      final now = DateTime.now();
      controller.competitions.value = [
        c(1,
            begin: now,
            end: now.add(const Duration(days: 1)),
            typeWater: 'Eau-plate'),
        c(2,
            begin: now,
            end: now.add(const Duration(days: 1)),
            typeWater: 'Côtier'),
        c(3,
            begin: now.add(const Duration(days: 60)),
            end: now.add(const Duration(days: 61)),
            typeWater: 'Eau-plate'),
      ];
      controller.setTemporal(TemporalFilter.thisWeek);
      controller.setDiscipline(HomeFilter.pool);
      controller.setSearchQuery('C1');

      expect(controller.filteredCompetitions.map((x) => x.id), [1]);
    });
  });

  group('HomeController favorites', () {
    test('toggleFavorite delegates to UserPreferencesService', () async {
      when(() => prefs.toggleFavorite(any())).thenAnswer((_) async {});
      await controller.toggleFavorite(42);
      verify(() => prefs.toggleFavorite(42)).called(1);
    });

    test('isFavorite delegates to UserPreferencesService', () {
      when(() => prefs.isFavorite(7)).thenReturn(true);
      expect(controller.isFavorite(7), isTrue);
    });

    test('favoriteIds exposes the service-backed RxSet', () {
      final set = <int>{1, 2}.obs;
      when(() => prefs.favoriteIds).thenReturn(set);
      expect(controller.favoriteIds, set);
    });
  });

  group('HomeController.navigateToCompetitionDetails', () {
    test('records the view before navigation', () async {
      when(() => prefs.recordView(any())).thenAnswer((_) async {});

      await controller.navigateToCompetitionDetails(c(55));

      verify(() => prefs.recordView(55)).called(1);
    });
  });
}
```

- [ ] **Step 2: Run the tests, expect failures**

Run: `flutter test test/presentation/modules/home/controllers/home_controller_test.dart`

Expected: FAIL — many compile errors against the old controller signature (e.g., `The constructor 'HomeController' isn't defined for the type ...`, `The getter 'filteredCompetitions' isn't defined`, etc.).

- [ ] **Step 3: Rewrite the controller**

Overwrite `lib/app/module/home/controllers/home_controller.dart` with:

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/core/enum/enum.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/core/services/language_service.dart';
import 'package:live_ffss/app/data/repositories/competition_repository.dart';
import 'package:live_ffss/app/data/services/user_preferences_service.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/presentation/modules/home/competition_formatting.dart';
import 'package:live_ffss/app/routes/app_pages.dart';

enum HomeFilter { all, coastal, pool, mixed }

enum TemporalFilter { lastViewed, thisWeek, all }

class HomeController extends GetxController {
  HomeController(
    this._competitionRepo,
    this._userService,
    this._languageService,
    this._prefs,
  );

  final CompetitionRepository _competitionRepo;
  final UserService _userService;
  final LanguageService _languageService;
  final UserPreferencesService _prefs;

  final RxList<Competition> competitions = <Competition>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final Rx<HomeFilter> selectedDiscipline = HomeFilter.all.obs;
  final Rx<TemporalFilter> selectedTemporal = TemporalFilter.thisWeek.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCompetitions();
  }

  Future<void> loadCompetitions() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      final loaded = await _competitionRepo.getAllCompetitions(
        type: CompetitionType.mixte,
        visibility: CompetitionVisibility.passed,
      );
      loaded.sort((a, b) {
        final dateComparison = (a.beginDate ?? DateTime(0))
            .compareTo(b.beginDate ?? DateTime(0));
        if (dateComparison != 0) return dateComparison;
        return a.name.compareTo(b.name);
      });
      competitions.value = loaded;
    } on AppException {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void setTemporal(TemporalFilter t) => selectedTemporal.value = t;
  void setDiscipline(HomeFilter d) => selectedDiscipline.value = d;
  void setSearchQuery(String q) => searchQuery.value = q;

  RxSet<int> get favoriteIds => _prefs.favoriteIds;
  bool isFavorite(int id) => _prefs.isFavorite(id);
  Future<void> toggleFavorite(int id) => _prefs.toggleFavorite(id);

  List<Competition> get filteredCompetitions {
    Iterable<Competition> result = competitions;

    switch (selectedTemporal.value) {
      case TemporalFilter.lastViewed:
        final byId = {for (final c in competitions) c.id: c};
        result = _prefs.lastViewedIds
            .map((id) => byId[id])
            .where((c) => c != null)
            .cast<Competition>();
      case TemporalFilter.thisWeek:
        result = result.where((c) => c.overlapsCurrentWeek);
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

  bool get isLoggedIn => _userService.isLoggedIn;

  Future<void> navigateToCompetitionDetails(Competition competition) async {
    await _prefs.recordView(competition.id);
    Get.toNamed(Routes.competitionDetail, arguments: competition);
  }

  RxString get appTitle => 'app_title'.tr.obs;

  RxString get currentLanguage => _languageService.currentLanguage;

  void changeLanguage(String languageCode) {
    _languageService.changeLanguage(languageCode);
  }

  void refreshAfterLogout() {
    selectedDiscipline.value = HomeFilter.all;
    selectedTemporal.value = TemporalFilter.thisWeek;
    searchQuery.value = '';
    loadCompetitions();
    update();
  }
}
```

- [ ] **Step 4: Run the tests, expect pass**

Run: `flutter test test/presentation/modules/home/controllers/home_controller_test.dart`

Expected: `+11: All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/app/module/home/controllers/home_controller.dart test/presentation/modules/home/controllers/home_controller_test.dart
git commit -m "feat(home): rewrite HomeController for temporal/discipline/search composition"
```

---

## Task 6: Update `HomeBinding` to inject the new service

**Files:**
- Modify: `lib/app/module/home/bindings/home_binding.dart`

- [ ] **Step 1: Replace the file**

Overwrite `lib/app/module/home/bindings/home_binding.dart` with:

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/core/services/language_service.dart';
import 'package:live_ffss/app/data/repositories/competition_repository.dart';
import 'package:live_ffss/app/data/services/user_preferences_service.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(
        Get.find<CompetitionRepository>(),
        Get.find<UserService>(),
        Get.find<LanguageService>(),
        Get.find<UserPreferencesService>(),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify with the analyzer**

Run: `flutter analyze lib/app/module/home/bindings/home_binding.dart`

Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/app/module/home/bindings/home_binding.dart
git commit -m "feat(home): inject UserPreferencesService into HomeBinding"
```

---

## Task 7: Rewrite `HomeView`

**Files:**
- Modify: `lib/app/module/home/views/home_view.dart` (full rewrite)

No widget tests per `CLAUDE.md`. Verify visually with `flutter run` after implementation. Incidentally fixes the long-standing typo'd lookup `'error_occurred'.tr` (translation key is `error_occured`) by routing the error through `ErrorState` with the existing key.

- [ ] **Step 1: Overwrite the file**

Overwrite `lib/app/module/home/views/home_view.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/module/auth/views/user_avatar.dart';
import 'package:live_ffss/app/module/home/controllers/home_controller.dart';
import 'package:live_ffss/app/presentation/modules/home/competition_formatting.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';
import 'package:live_ffss/app/presentation/shared/error_state.dart';
import 'package:live_ffss/app/presentation/shared/language_selector.dart';
import 'package:live_ffss/app/presentation/shared/loading_indicator.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _HomeHero(),
            const _HomeWave(),
            const SizedBox(height: AppSpacing.md),
            const _HomeFiltersBar(),
            const SizedBox(height: AppSpacing.sm),
            const _HomeSearchBar(),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const LoadingIndicator();
                }
                if (controller.hasError.value) {
                  return ErrorState(
                    message: 'error_occured'.tr,
                    onRetry: controller.loadCompetitions,
                  );
                }
                return const _HomeList();
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHero extends GetView<HomeController> {
  const _HomeHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Spacer(),
              const LanguageSelector(),
              const SizedBox(width: AppSpacing.sm),
              UserAvatar(
                size: 36,
                backgroundColor: Colors.white.withOpacity(0.2),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo_ffss.png',
                height: 56,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.app_shortcut,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Obx(() => Text(
                    controller.appTitle.value,
                    style: AppTypography.title.copyWith(
                      color: Colors.white,
                      fontSize: 24,
                      letterSpacing: 1.2,
                    ),
                  )),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _HeroPill(
                label: 'last_viewed'.tr,
                temporal: TemporalFilter.lastViewed,
              ),
              const SizedBox(width: AppSpacing.sm),
              _HeroPill(
                label: 'this_week'.tr,
                temporal: TemporalFilter.thisWeek,
              ),
              const SizedBox(width: AppSpacing.sm),
              _HeroPill(
                label: 'all'.tr,
                temporal: TemporalFilter.all,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends GetView<HomeController> {
  const _HeroPill({required this.label, required this.temporal});

  final String label;
  final TemporalFilter temporal;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final active = controller.selectedTemporal.value == temporal;
      return GestureDetector(
        onTap: () => controller.setTemporal(temporal),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: AppRadius.pillRadius,
            border: Border.all(color: Colors.white),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? AppColors.primary : Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      );
    });
  }
}

class _HomeWave extends StatelessWidget {
  const _HomeWave();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 24,
      child: CustomPaint(painter: _WavePainter()),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.primary;
    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 2,
        size.width,
        0,
      )
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HomeFiltersBar extends GetView<HomeController> {
  const _HomeFiltersBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.pageHorizontal,
      child: Row(
        children: [
          _DisciplinePill(label: 'all'.tr, filter: HomeFilter.all),
          const SizedBox(width: AppSpacing.sm),
          _DisciplinePill(label: 'swimming'.tr, filter: HomeFilter.pool),
          const SizedBox(width: AppSpacing.sm),
          _DisciplinePill(label: 'beach'.tr, filter: HomeFilter.coastal),
        ],
      ),
    );
  }
}

class _DisciplinePill extends GetView<HomeController> {
  const _DisciplinePill({required this.label, required this.filter});

  final String label;
  final HomeFilter filter;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final active = controller.selectedDiscipline.value == filter;
      return GestureDetector(
        onTap: () => controller.setDiscipline(filter),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.white,
            borderRadius: AppRadius.pillRadius,
            border: Border.all(color: AppColors.primary),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : AppColors.primary,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      );
    });
  }
}

class _HomeSearchBar extends StatefulWidget {
  const _HomeSearchBar();

  @override
  State<_HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<_HomeSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();
    return Padding(
      padding: AppSpacing.pageHorizontal,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: AppRadius.pillRadius,
        ),
        child: TextField(
          controller: _controller,
          onChanged: home.setSearchQuery,
          decoration: InputDecoration(
            hintText: 'search_competitions'.tr,
            hintStyle: AppTypography.body.copyWith(color: AppColors.textMuted),
            prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          ),
        ),
      ),
    );
  }
}

class _HomeList extends GetView<HomeController> {
  const _HomeList();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.filteredCompetitions;
      if (items.isEmpty) {
        final isLastViewed =
            controller.selectedTemporal.value == TemporalFilter.lastViewed;
        return EmptyState(
          icon: Icons.event_busy,
          title:
              isLastViewed ? 'no_last_viewed'.tr : 'no_competitions_found'.tr,
        );
      }
      return ListView.separated(
        padding: AppSpacing.pageHorizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, i) => _CompetitionCard(competition: items[i]),
      );
    });
  }
}

class _CompetitionCard extends GetView<HomeController> {
  const _CompetitionCard({required this.competition});

  final Competition competition;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.smRadius,
      child: InkWell(
        onTap: () => controller.navigateToCompetitionDetails(competition),
        borderRadius: AppRadius.smRadius,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: AppRadius.smRadius,
          ),
          child: Row(
            children: [
              _CardThumbnail(competition: competition),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _CardBody(competition: competition)),
              const SizedBox(width: AppSpacing.sm),
              _CardTrailing(competition: competition),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardThumbnail extends StatelessWidget {
  const _CardThumbnail({required this.competition});

  final Competition competition;

  @override
  Widget build(BuildContext context) {
    final logoUrl = competition.organizerClub.logoUrl;
    if (logoUrl == null || logoUrl.isEmpty) {
      return _DateBlock(competition: competition);
    }
    return ClipRRect(
      borderRadius: AppRadius.smRadius,
      child: Image.network(
        logoUrl,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _DateBlock(competition: competition),
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : _DateBlock(competition: competition),
      ),
    );
  }
}

class _DateBlock extends StatelessWidget {
  const _DateBlock({required this.competition});

  final Competition competition;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadius.smRadius,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            competition.formattedBeginDateMonth,
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            competition.formattedDayBeginDate,
            style: AppTypography.subtitle.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({required this.competition});

  final Competition competition;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          competition.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.title.copyWith(fontSize: 14),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          _dateRange(competition),
          style: AppTypography.body.copyWith(fontSize: 12),
        ),
        Text(
          competition.location ?? 'no_location'.tr,
          style: AppTypography.caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _dateRange(Competition c) {
    final fmt = DateFormat('yyyy MMM dd');
    if (c.beginDate == null) return '';
    if (c.endDate == null || c.endDate!.isAtSameMomentAs(c.beginDate!)) {
      return fmt.format(c.beginDate!);
    }
    return '${fmt.format(c.beginDate!)} - ${DateFormat('dd').format(c.endDate!)}';
  }
}

class _CardTrailing extends GetView<HomeController> {
  const _CardTrailing({required this.competition});

  final Competition competition;

  @override
  Widget build(BuildContext context) {
    final isLive = competition.phase == CompetitionStatus.onGoing;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isLive ? AppColors.statusError : competition.entryStatusColor,
            borderRadius: AppRadius.pillRadius,
          ),
          child: Text(
            isLive ? 'live'.tr : competition.entryStatusLabel,
            style: AppTypography.badge.copyWith(fontSize: 10),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              final favored =
                  controller.favoriteIds.contains(competition.id);
              return IconButton(
                onPressed: () => controller.toggleFavorite(competition.id),
                icon: Icon(
                  favored ? Icons.star : Icons.star_border,
                  color: favored
                      ? AppColors.statusWaiting
                      : AppColors.textMuted,
                  size: 22,
                ),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              );
            }),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
              size: 22,
            ),
          ],
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Verify with the analyzer**

Run: `flutter analyze lib/app/module/home/views/home_view.dart`

Expected: `No issues found!`

- [ ] **Step 3: Run the app and verify visually**

Run: `flutter run`

Visual checks (golden path):
- Hero block in `AppColors.primary` blue, FFSS logo + "Live FFSS" wordmark centered, three white-bordered temporal pills below; "This week" pill is filled white by default.
- Wave curve visible directly below the hero, same blue, ~24 px tall.
- Discipline pills below the wave (All / Swimming / Beach), "All" is filled blue by default.
- Search bar in muted-grey rounded surface, magnifier icon on the left.
- Competition list shows hybrid cards: thumbnail (logo or date block fallback), name + date range + location, status badge + favorite star + chevron on the right.

Edge cases:
- Tap "Last viewed" with no history → `EmptyState` with `'no_last_viewed'.tr`.
- Tap a card → opens competition detail; coming back, "Last viewed" now contains it at the top.
- Tap the favorite star → fills yellow, persists across app restarts (kill + restart the app).
- Type in the search bar → list filters as you type.

Regression checks (golden paths still working):
- Language selector still toggles FR/EN.
- User avatar still shows the logged-in user's initial when authenticated.
- Tapping a card still navigates to competition detail.

If any check fails, fix in place and repeat. Do **not** mark this step complete until the visual checks pass — `CLAUDE.md` requires visual verification for UI work.

- [ ] **Step 4: Commit**

```bash
git add lib/app/module/home/views/home_view.dart
git commit -m "feat(home): rewrite HomeView with hero, wave, discipline filters, search, favorites"
```

---

## Task 8: Drop unused `carousel_slider` dependency

**Files:**
- Modify: `pubspec.yaml`

The carousel was the only consumer of `carousel_slider`; removed in Task 7.

- [ ] **Step 1: Remove the line**

In `pubspec.yaml`, delete line 13: `  carousel_slider: ^5.0.0`. Save.

- [ ] **Step 2: Refresh the dependency lockfile**

Run: `flutter pub get`

Expected: completes without errors; `pubspec.lock` updates to remove `carousel_slider`.

- [ ] **Step 3: Verify with the analyzer (full project)**

Run: `flutter analyze`

Expected: `No issues found!` (no leftover `import 'package:carousel_slider/...'` anywhere).

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore(deps): drop carousel_slider after home redesign"
```

---

## Task 9: Final sweep — run the full test suite

**Files:** none (verification only).

- [ ] **Step 1: Run all tests**

Run: `flutter test`

Expected: every test passes. The previously edited `home_controller_test.dart` and the new `user_preferences_service_test.dart` are part of the suite; everything else is unchanged.

- [ ] **Step 2: If anything fails, fix in place**

If a test fails because it indirectly depended on the old `HomeController` shape (e.g., another module's binding test), inspect, fix the binding/import, re-run. Do not mark complete until all tests pass.

- [ ] **Step 3: Commit any incidental fixes (only if needed)**

```bash
git add <fixed files>
git commit -m "fix: <one-sentence description of incidental fix>"
```

If no fixes were needed, skip the commit.

---

## Self-Review

**Spec coverage check (against `docs/superpowers/specs/2026-04-29-home-page-redesign-design.md`):**

| Spec section | Plan task |
|---|---|
| §2 In scope: HomeView body rewrite | Task 7 |
| §2 In scope: HomeController extensions | Task 5 |
| §2 In scope: UserPreferencesService | Task 3 |
| §2 In scope: Hero + wave header in `AppColors.primary` | Task 7 (`_HomeHero`, `_HomeWave`) |
| §2 In scope: Discipline strip wired into filter | Tasks 5 + 7 |
| §2 In scope: Local search bar | Tasks 5 + 7 |
| §2 In scope: Hybrid cards with favorites | Task 7 (`_CompetitionCard`, `_CardTrailing`) |
| §2 In scope: Drop `carousel_slider` | Task 8 |
| §2 In scope: Replace `0xFF0275FF` with `AppColors.primary` | Task 7 (the rewrite uses `AppColors.primary` exclusively) |
| §4 `UserPreferencesService` shape | Task 3 |
| §4 DI registration order (step 7) | Task 4 |
| §5 New state, removed state, `filteredCompetitions` getter, delegated favorites | Task 5 |
| §6 `overlapsCurrentWeek`, `isSwimming`, `isBeach` | Task 2 |
| §7 View structure with private widget classes | Task 7 |
| §8 Translation keys | Task 1 |
| §9 Tests for service + controller | Tasks 3 + 5 |
| §10 Files touched | All tasks |

**Type-consistency spot-check:**
- `HomeController(repo, users, lang, prefs)` — same 4-arg order in controller (Task 5), binding (Task 6), and tests (Task 5).
- `setTemporal(TemporalFilter)` / `setDiscipline(HomeFilter)` / `setSearchQuery(String)` — names match between controller and view.
- `favoriteIds` (RxSet&lt;int&gt;), `isFavorite(int)` (bool), `toggleFavorite(int)` (Future&lt;void&gt;), `recordView(int)` (Future&lt;void&gt;) — same shapes in service, controller, view, tests.
- Storage keys `'favorite_competitions'` and `'last_viewed_competitions'` — identical literal strings in service and tests.

**Placeholder scan:** no TBDs, TODOs, "implement later", or "similar to Task N" abbreviations in this plan.

**Missing-from-spec check:** no spec section is unrepresented; no orphan tasks reference types that aren't defined.
