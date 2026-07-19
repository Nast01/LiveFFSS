# Race "Séries" Structure View — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the race detail "Séries" tab show the locally-defined structure (rounds série/quart/demi/finale → courses, grouped by category) as interactive tiles; tapping a course opens a dedicated per-course scaffold screen (context header + "Résultats à venir") that future result view/entry will fill.

**Architecture:** A new `RaceStructureController` (reads `ProgrammeService` + `RaceRepository`) feeds a new `RaceStructureView` that replaces the Séries-tab body (index-1 `IndexedStack` child) — pills unchanged. A new `Routes.raceCourse` scaffold (controller + view + binding) is the tap target. `RaceDetailController` and the existing `race_detail_heats_view.dart` are NOT modified (the heats view is retained for future reuse).

**Tech Stack:** Flutter, GetX, freezed models (no new ones), mocktail.

**Spec:** `docs/superpowers/specs/2026-07-19-race-series-structure-design.md`

## Global Constraints

- **Dart/Flutter binaries are not on PATH.** Use `C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat` and `dart.bat`.
- **No codegen.** No new/changed `@freezed` models; do NOT run `build_runner`.
- **Analyzer is strict** (`strict-casts`, `strict-raw-types`); no `dynamic`; no analyzer ignores.
- **Controller discipline:** no `.tr` / `Get.snackbar` / `Get.dialog` / `Get.context!` / `BuildContext` in controllers; constructor injection only, never `Get.find()` in a controller body. The only `Get.*` allowed in a controller body is reading `Get.arguments` in `onInit`. Catch `AppException` (sealed type in `core/errors/`), let other throwables propagate. **Navigation (`Get.toNamed`) happens in the VIEW.**
- **Obx dependency rule:** read every reactive value the widget depends on in the `Obx`/builder body, never only inside an itemBuilder.
- **Arguments parsing** mirrors `RaceDetailController.onInit` verbatim: `Get.arguments` is either a `Map` with `'race'` (`Race`) / `'competition'` (`Competition`) keys, or a bare `Race`.
- **Git:** `git add <explicit paths>` only. Git root is the PARENT of the Flutter package (paths show as `live_ffss/...`). Branch: `feat/timed-programme-builder`.

---

### Task 1: RaceStructureController + binding + test

The Séries-tab logic: loads the structure(s) for this race from `ProgrammeService`, counts engaged per category from `RaceRepository.getEntries`.

**Files:**
- Create: `lib/app/module/competitions/controllers/race_structure_controller.dart`
- Modify: `lib/app/module/competitions/bindings/race_detail_binding.dart`
- Test: `test/presentation/modules/competitions/controllers/race_structure_controller_test.dart`

**Interfaces:**
- Consumes: `ProgrammeService` (`load(int)`, `current`), `RaceRepository` (`Future<List<Entry>> getEntries(int)`), `Race`, `Competition`, `EventStructure`, `AppException`.
- Produces: `RaceStructureController(ProgrammeService, RaceRepository)` with fields `Rxn<Race> race`, `Rxn<Competition> competition`, `RxBool isLoading`, `RxList<EventStructure> structures`; `Future<void> load(Race race, Competition competition)`; getters `bool hasStructure`, `int entryCountFor(int categoryId)`, `bool showCategoryHeaders`.

- [ ] **Step 1: Write the failing test**

Create `test/presentation/modules/competitions/controllers/race_structure_controller_test.dart`:

```dart
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/category.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/entry.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/race.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/module/competitions/controllers/race_structure_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockStorage extends Mock implements FlutterSecureStorage {}

class _MockRaceRepo extends Mock implements RaceRepository {}

void main() {
  late _MockStorage storage;
  late _MockRaceRepo raceRepo;
  late ProgrammeService service;
  late RaceStructureController controller;

  setUpAll(() => registerFallbackValue(''));

  const competition = Competition(
    id: 42,
    name: 'Championnat',
    statusCode: 0,
    statusLabel: '',
    speciality: 1,
    specialityLabel: '',
    typeWater: '',
    typePool: '',
    typeChrono: '',
    isEligibleToNationalRecord: false,
    numberOfLanes: 8,
    organizer: '',
    hasBegun: false,
    hasResult: false,
    hasPassed: false,
    level: 0,
    levelLabel: '',
    organizerClub: Club(id: 1, name: 'Club'),
  );

  Race race(int id) => Race(
        id: id,
        name: 'Race$id',
        nameEnglish: 'Race$id (en)',
        distance: 100,
        gender: Gender.male,
        athletesPerTeam: 1,
        specialityId: 1,
        specialityLabel: 'Eau-plate',
        disciplineId: 1,
        isEligibleToNationalRecord: false,
        categories: const [],
      );

  Entry entry(int id, int categoryId) => Entry(
        id: id,
        raceId: 500,
        category: Category(id: categoryId, name: 'Cat$categoryId'),
        status: 0,
        statusLabel: '',
      );

  // Race 500 has two category structures (Cadets=7, Juniors=8). Race 999 has one
  // (Cadets). Juniors is intentionally listed before Cadets to test sorting.
  const seed = CompetitionProgramme(
    competitionId: 42,
    structures: [
      EventStructure(
        raceId: 500,
        categoryId: 8,
        raceLabel: '100m',
        categoryLabel: 'Juniors',
        levels: [
          RoundLevel(type: RoundType.serie, races: [ProgrammeRace(id: 13, number: 1)]),
        ],
      ),
      EventStructure(
        raceId: 500,
        categoryId: 7,
        raceLabel: '100m',
        categoryLabel: 'Cadets',
        spotsPerRace: 8,
        levels: [
          RoundLevel(type: RoundType.serie, qualifiersPerRace: 4, races: [
            ProgrammeRace(id: 10, number: 1),
            ProgrammeRace(id: 11, number: 2),
          ]),
          RoundLevel(type: RoundType.finale, races: [ProgrammeRace(id: 12, number: 1)]),
        ],
      ),
      EventStructure(
        raceId: 999,
        categoryId: 7,
        raceLabel: 'Autre',
        categoryLabel: 'Cadets',
        levels: [
          RoundLevel(type: RoundType.serie, races: [ProgrammeRace(id: 20, number: 1)]),
        ],
      ),
    ],
  );

  setUp(() {
    storage = _MockStorage();
    raceRepo = _MockRaceRepo();
    when(() => storage.read(key: any(named: 'key')))
        .thenAnswer((_) async => jsonEncode(seed.toJson()));
    when(() => storage.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((_) async {});
    service = ProgrammeService(storage);
    controller = RaceStructureController(service, raceRepo);
  });

  test('load filters structures to the race and sorts by category label', () async {
    when(() => raceRepo.getEntries(500)).thenAnswer((_) async => const []);
    await controller.load(race(500), competition);

    expect(controller.isLoading.value, isFalse);
    expect(controller.structures.map((s) => s.categoryLabel), ['Cadets', 'Juniors']);
    expect(controller.hasStructure, isTrue);
    expect(controller.showCategoryHeaders, isTrue);
  });

  test('entryCountFor counts entries grouped by category', () async {
    when(() => raceRepo.getEntries(500)).thenAnswer(
        (_) async => [entry(1, 7), entry(2, 7), entry(3, 7), entry(4, 8), entry(5, 8)]);
    await controller.load(race(500), competition);

    expect(controller.entryCountFor(7), 3);
    expect(controller.entryCountFor(8), 2);
    expect(controller.entryCountFor(99), 0);
  });

  test('a single-structure race hides category headers', () async {
    when(() => raceRepo.getEntries(999)).thenAnswer((_) async => const []);
    await controller.load(race(999), competition);

    expect(controller.structures.length, 1);
    expect(controller.showCategoryHeaders, isFalse);
    expect(controller.hasStructure, isTrue);
  });

  test('a race with no structure has hasStructure false', () async {
    when(() => raceRepo.getEntries(12345)).thenAnswer((_) async => const []);
    await controller.load(race(12345), competition);

    expect(controller.structures, isEmpty);
    expect(controller.hasStructure, isFalse);
  });

  test('a getEntries failure degrades to zero counts; structure still loads', () async {
    when(() => raceRepo.getEntries(500)).thenThrow(const NetworkException('boom'));
    await controller.load(race(500), competition);

    expect(controller.isLoading.value, isFalse);
    expect(controller.hasStructure, isTrue);
    expect(controller.entryCountFor(7), 0);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/presentation/modules/competitions/controllers/race_structure_controller_test.dart
```

Expected: FAIL — the controller class does not exist.

- [ ] **Step 3: Write the controller**

Create `lib/app/module/competitions/controllers/race_structure_controller.dart`:

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/race.dart';

/// Feeds the race-detail "Séries" tab with the locally-defined structure(s) for
/// this race (one per category), plus per-category engaged counts. Read-only.
class RaceStructureController extends GetxController {
  RaceStructureController(this._programme, this._raceRepo);

  final ProgrammeService _programme;
  final RaceRepository _raceRepo;

  final Rxn<Race> race = Rxn<Race>();
  final Rxn<Competition> competition = Rxn<Competition>();
  final RxBool isLoading = true.obs;
  final RxList<EventStructure> structures = <EventStructure>[].obs;

  Map<int, int> _entryCountByCategory = const {};

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    Race? r;
    Competition? c;
    if (arg is Map) {
      final ar = arg['race'];
      final ac = arg['competition'];
      if (ar is Race) r = ar;
      if (ac is Competition) c = ac;
    } else if (arg is Race) {
      r = arg;
    }
    if (r != null && c != null) {
      load(r, c);
    } else {
      if (r != null) race.value = r;
      if (c != null) competition.value = c;
      isLoading.value = false;
    }
  }

  Future<void> load(Race race, Competition competition) async {
    this.race.value = race;
    this.competition.value = competition;
    isLoading.value = true;
    try {
      await _programme.load(competition.id);
      final all =
          _programme.current.value?.structures ?? const <EventStructure>[];
      structures.value = all.where((s) => s.raceId == race.id).toList()
        ..sort((a, b) => a.categoryLabel.compareTo(b.categoryLabel));
      try {
        final entries = await _raceRepo.getEntries(race.id);
        final counts = <int, int>{};
        for (final e in entries) {
          counts[e.category.id] = (counts[e.category.id] ?? 0) + 1;
        }
        _entryCountByCategory = counts;
      } on AppException {
        // Entries unavailable (offline / API error): the structure still
        // renders; category counts fall back to zero.
        _entryCountByCategory = const {};
      }
    } finally {
      isLoading.value = false;
    }
  }

  bool get hasStructure => structures.any((s) => s.levels.isNotEmpty);

  int entryCountFor(int categoryId) => _entryCountByCategory[categoryId] ?? 0;

  bool get showCategoryHeaders => structures.length > 1;
}
```

- [ ] **Step 4: Register the controller in the binding**

In `lib/app/module/competitions/bindings/race_detail_binding.dart`, add the imports and the registration. The full new file:

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import '../controllers/race_detail_controller.dart';
import '../controllers/race_structure_controller.dart';

class RaceDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RaceDetailController>(
      () => RaceDetailController(
        Get.find<RaceRepository>(),
        Get.find<ClubRepository>(),
      ),
    );
    Get.lazyPut<RaceStructureController>(
      () => RaceStructureController(
        Get.find<ProgrammeService>(),
        Get.find<RaceRepository>(),
      ),
    );
  }
}
```

- [ ] **Step 5: Run the test to verify it passes**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/presentation/modules/competitions/controllers/race_structure_controller_test.dart
```

Expected: PASS — 5 tests.

- [ ] **Step 6: Analyze the changed files**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat analyze lib/app/module/competitions/controllers/race_structure_controller.dart lib/app/module/competitions/bindings/race_detail_binding.dart
```

Expected: `No issues found!`

- [ ] **Step 7: Commit**

```bash
git add live_ffss/lib/app/module/competitions/controllers/race_structure_controller.dart live_ffss/lib/app/module/competitions/bindings/race_detail_binding.dart live_ffss/test/presentation/modules/competitions/controllers/race_structure_controller_test.dart
git commit -m "feat(competitions): add race structure controller for the Séries tab"
```

---

### Task 2: The per-course scaffold — route, controller, view, binding

The tap target: a new `Routes.raceCourse` screen showing the course context + a "Résultats à venir" empty state. No result logic (deferred).

**Files:**
- Modify: `lib/app/routes/app_routes.dart` (add the constant)
- Create: `lib/app/module/competitions/controllers/race_course_controller.dart`
- Create: `lib/app/module/competitions/views/race_course_view.dart`
- Create: `lib/app/module/competitions/bindings/race_course_binding.dart`
- Modify: `lib/app/routes/app_pages.dart` (imports + GetPage)
- Modify: `lib/app/core/translations/fr_fr.dart`, `lib/app/core/translations/en_us.dart` (add `results_coming_soon`)
- Test: `test/presentation/modules/competitions/controllers/race_course_controller_test.dart`

**Interfaces:**
- Consumes: `Race`, `Competition`, `RoundType`.
- Produces:
  - `Routes.raceCourse = '/race-course'`
  - `RaceCourseController` with fields `Rxn<Race> race`, `Rxn<Competition> competition`, `int? categoryId`, `String categoryLabel`, `RoundType roundType`, `int raceNumber`, `int? programmeRaceId`; `void applyArguments(Object? arg)`.
  - `RaceCourseView`, `RaceCourseBinding`.

- [ ] **Step 1: Write the failing test**

Create `test/presentation/modules/competitions/controllers/race_course_controller_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/race.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/module/competitions/controllers/race_course_controller.dart';

void main() {
  const competition = Competition(
    id: 42,
    name: 'Championnat',
    statusCode: 0,
    statusLabel: '',
    speciality: 1,
    specialityLabel: '',
    typeWater: '',
    typePool: '',
    typeChrono: '',
    isEligibleToNationalRecord: false,
    numberOfLanes: 8,
    organizer: '',
    hasBegun: false,
    hasResult: false,
    hasPassed: false,
    level: 0,
    levelLabel: '',
    organizerClub: Club(id: 1, name: 'Club'),
  );

  const race = Race(
    id: 500,
    name: '100m Nage',
    nameEnglish: '100m Swim',
    distance: 100,
    gender: Gender.male,
    athletesPerTeam: 1,
    specialityId: 1,
    specialityLabel: 'Eau-plate',
    disciplineId: 1,
    isEligibleToNationalRecord: false,
    categories: [],
  );

  test('applyArguments parses every context field from the map', () {
    final controller = RaceCourseController();
    controller.applyArguments({
      'race': race,
      'competition': competition,
      'categoryId': 7,
      'categoryLabel': 'Cadets',
      'roundType': RoundType.serie,
      'raceNumber': 2,
      'programmeRaceId': 11,
    });

    expect(controller.race.value?.id, 500);
    expect(controller.competition.value?.id, 42);
    expect(controller.categoryId, 7);
    expect(controller.categoryLabel, 'Cadets');
    expect(controller.roundType, RoundType.serie);
    expect(controller.raceNumber, 2);
    expect(controller.programmeRaceId, 11);
  });

  test('applyArguments leaves defaults on a non-map argument', () {
    final controller = RaceCourseController();
    controller.applyArguments(null);

    expect(controller.race.value, isNull);
    expect(controller.categoryLabel, '');
    expect(controller.roundType, RoundType.unknown);
    expect(controller.raceNumber, 0);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/presentation/modules/competitions/controllers/race_course_controller_test.dart
```

Expected: FAIL — the controller class does not exist.

- [ ] **Step 3: Add the route constant**

In `lib/app/routes/app_routes.dart`, add after the `structureEditor` line (before the `// Add other routes here` comment):

```dart
  static const raceCourse = '/race-course';
```

- [ ] **Step 4: Write the controller**

Create `lib/app/module/competitions/controllers/race_course_controller.dart`:

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/race.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';

/// Scaffold controller for one scheduled course (série/quart/demi/finale) of a
/// race×category. Holds the context passed from the Séries tab; result
/// viewing/entry is deferred (future work fills this screen).
class RaceCourseController extends GetxController {
  final Rxn<Race> race = Rxn<Race>();
  final Rxn<Competition> competition = Rxn<Competition>();
  int? categoryId;
  String categoryLabel = '';
  RoundType roundType = RoundType.unknown;
  int raceNumber = 0;
  int? programmeRaceId;

  @override
  void onInit() {
    super.onInit();
    applyArguments(Get.arguments);
  }

  void applyArguments(Object? arg) {
    if (arg is! Map) return;
    final r = arg['race'];
    if (r is Race) race.value = r;
    final c = arg['competition'];
    if (c is Competition) competition.value = c;
    final cid = arg['categoryId'];
    if (cid is int) categoryId = cid;
    final cl = arg['categoryLabel'];
    if (cl is String) categoryLabel = cl;
    final rt = arg['roundType'];
    if (rt is RoundType) roundType = rt;
    final rn = arg['raceNumber'];
    if (rn is int) raceNumber = rn;
    final pid = arg['programmeRaceId'];
    if (pid is int) programmeRaceId = pid;
  }
}
```

- [ ] **Step 5: Write the view**

Create `lib/app/module/competitions/views/race_course_view.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/module/competitions/controllers/race_course_controller.dart';
import 'package:live_ffss/app/presentation/modules/programme/programme_formatting.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';

class RaceCourseView extends GetView<RaceCourseController> {
  const RaceCourseView({super.key});

  @override
  Widget build(BuildContext context) {
    final raceName = controller.race.value?.name ?? '';
    final round = '${controller.roundType.labelKey.tr} ${controller.raceNumber}';
    final subtitle = controller.categoryLabel.isEmpty
        ? round
        : '${controller.categoryLabel} · $round';
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(raceName,
                style: AppTypography.title
                    .copyWith(color: Colors.white, fontSize: 16)),
            Text(subtitle,
                style: AppTypography.caption.copyWith(color: Colors.white70)),
          ],
        ),
      ),
      body: EmptyState(
          icon: Icons.timer_outlined, title: 'results_coming_soon'.tr),
    );
  }
}
```

- [ ] **Step 6: Write the binding**

Create `lib/app/module/competitions/bindings/race_course_binding.dart`:

```dart
import 'package:get/get.dart';
import '../controllers/race_course_controller.dart';

class RaceCourseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RaceCourseController>(() => RaceCourseController());
  }
}
```

- [ ] **Step 7: Register the route**

In `lib/app/routes/app_pages.dart`, add these two imports to the import block (with the other competitions imports):

```dart
import 'package:live_ffss/app/module/competitions/bindings/race_course_binding.dart';
import 'package:live_ffss/app/module/competitions/views/race_course_view.dart';
```

and add this `GetPage` to the `routes` list (after the `raceDetail` entry):

```dart
    GetPage(
      name: Routes.raceCourse,
      page: () => const RaceCourseView(),
      binding: RaceCourseBinding(),
    ),
```

- [ ] **Step 8: Add the translation key**

In `lib/app/core/translations/fr_fr.dart`, add before the final `};`:

```dart
  'results_coming_soon': 'Résultats à venir',
```

In `lib/app/core/translations/en_us.dart`, add before the final `};`:

```dart
  'results_coming_soon': 'Results coming soon',
```

- [ ] **Step 9: Run the test + analyze**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/presentation/modules/competitions/controllers/race_course_controller_test.dart
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat analyze lib/app/module/competitions/controllers/race_course_controller.dart lib/app/module/competitions/views/race_course_view.dart lib/app/module/competitions/bindings/race_course_binding.dart lib/app/routes/app_pages.dart
```

Expected: 2 tests PASS; `No issues found!`

- [ ] **Step 10: Commit**

```bash
git add live_ffss/lib/app/routes/app_routes.dart live_ffss/lib/app/routes/app_pages.dart live_ffss/lib/app/module/competitions/controllers/race_course_controller.dart live_ffss/lib/app/module/competitions/views/race_course_view.dart live_ffss/lib/app/module/competitions/bindings/race_course_binding.dart live_ffss/lib/app/core/translations/fr_fr.dart live_ffss/lib/app/core/translations/en_us.dart live_ffss/test/presentation/modules/competitions/controllers/race_course_controller_test.dart
git commit -m "feat(competitions): add per-course scaffold route and screen"
```

---

### Task 3: RaceStructureView + wire it into the Séries tab

Builds the structure view (category sections → round groups → course tiles, tapping to `Routes.raceCourse`) and swaps it into the Séries-tab slot. No unit tests (view) — verified via analyze + full suite + device.

**Files:**
- Create: `lib/app/module/competitions/views/race_structure_view.dart`
- Modify: `lib/app/module/competitions/views/race_detail_view.dart` (index-1 child + imports)
- Modify: `lib/app/core/translations/fr_fr.dart`, `lib/app/core/translations/en_us.dart` (add `no_structure_defined`)

**Interfaces:**
- Consumes: `RaceStructureController` (Task 1) — `isLoading`, `hasStructure`, `structures`, `showCategoryHeaders`, `entryCountFor`, `race`, `competition`; `EventStructure`, `RoundLevel`, `ProgrammeRace`, `RoundType`, `RoundTypeFormatting.labelKey`, `Routes.raceCourse` (Task 2), theme, `LoadingIndicator`, `EmptyState`.

- [ ] **Step 1: Add the translation key**

In `lib/app/core/translations/fr_fr.dart`, add before the final `};`:

```dart
  'no_structure_defined': 'Structure non définie',
```

In `lib/app/core/translations/en_us.dart`, add before the final `};`:

```dart
  'no_structure_defined': 'No structure defined',
```

- [ ] **Step 2: Write the structure view**

Create `lib/app/module/competitions/views/race_structure_view.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/module/competitions/controllers/race_structure_controller.dart';
import 'package:live_ffss/app/presentation/modules/programme/programme_formatting.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';
import 'package:live_ffss/app/presentation/shared/loading_indicator.dart';
import 'package:live_ffss/app/routes/app_pages.dart';

class RaceStructureView extends GetView<RaceStructureController> {
  const RaceStructureView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const LoadingIndicator();
      }
      if (!controller.hasStructure) {
        return EmptyState(
            icon: Icons.account_tree_outlined,
            title: 'no_structure_defined'.tr);
      }
      final showHeaders = controller.showCategoryHeaders;
      final children = <Widget>[];
      for (final s in controller.structures) {
        if (s.levels.isEmpty) continue;
        if (showHeaders) {
          children.add(_CategoryHeader(
              label: s.categoryLabel,
              engaged: controller.entryCountFor(s.categoryId)));
        }
        for (final level in s.levels) {
          children.add(_RoundHeader(structure: s, level: level));
          for (final r in level.races) {
            children.add(_CourseTile(structure: s, level: level, race: r));
          }
        }
      }
      return ListView(padding: AppSpacing.pageAll, children: children);
    });
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.label, required this.engaged});
  final String label;
  final int engaged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, AppSpacing.sm, 0, AppSpacing.xs),
      child: Row(
        children: [
          Text(label, style: AppTypography.subtitle),
          const SizedBox(width: AppSpacing.sm),
          Text('· $engaged ${'engaged'.tr}', style: AppTypography.caption),
        ],
      ),
    );
  }
}

class _RoundHeader extends StatelessWidget {
  const _RoundHeader({required this.structure, required this.level});
  final EventStructure structure;
  final RoundLevel level;

  @override
  Widget build(BuildContext context) {
    final accent = level.type == RoundType.finale
        ? AppColors.statusFinished
        : AppColors.primary;
    final info = <String>[
      '${structure.spotsPerRace} ${'spots_per_race'.tr}',
      if (level.qualifiersPerRace > 0)
        '${level.qualifiersPerRace} ${'qualifiers_per_race'.tr}',
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, AppSpacing.sm, 0, AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(AppRadius.sm)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(level.type.labelKey.tr,
              style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const Spacer(),
          Flexible(
            child: Text(info.join(' · '),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption),
          ),
        ],
      ),
    );
  }
}

class _CourseTile extends StatelessWidget {
  const _CourseTile({
    required this.structure,
    required this.level,
    required this.race,
  });
  final EventStructure structure;
  final RoundLevel level;
  final ProgrammeRace race;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RaceStructureController>();
    final accent = level.type == RoundType.finale
        ? AppColors.statusFinished
        : AppColors.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadius.mdRadius,
        elevation: 1,
        child: InkWell(
          borderRadius: AppRadius.mdRadius,
          onTap: () => Get.toNamed<void>(Routes.raceCourse, arguments: {
            'race': controller.race.value,
            'competition': controller.competition.value,
            'categoryId': structure.categoryId,
            'categoryLabel': structure.categoryLabel,
            'roundType': level.type,
            'raceNumber': race.number,
            'programmeRaceId': race.id,
          }),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: AppRadius.smRadius,
                  ),
                  child: Text('${race.number}',
                      style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w800, color: accent)),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text('${level.type.labelKey.tr} ${race.number}',
                      style: AppTypography.body
                          .copyWith(color: AppColors.textPrimary)),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

(The `spots_per_race`, `qualifiers_per_race`, `races_count`, and `engaged` translation keys already exist.)

- [ ] **Step 3: Swap the structure view into the Séries tab**

In `lib/app/module/competitions/views/race_detail_view.dart`:

Replace the heats-view import:

```dart
import 'package:live_ffss/app/module/competitions/views/race_detail_heats_view.dart';
```

with:

```dart
import 'package:live_ffss/app/module/competitions/views/race_structure_view.dart';
```

and in the `IndexedStack` children, replace `RaceDetailHeatsView()` (the index-1 child) with `RaceStructureView()`:

```dart
                      children: const [
                        RaceDetailEntriesView(),
                        RaceStructureView(),
                        RaceDetailSummaryView(),
                      ],
```

(The `heats` pill label stays — the Séries tab now renders the structure. `race_detail_heats_view.dart` is retained in the repo, unimported, for the future per-course results view.)

- [ ] **Step 4: Analyze + full suite**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat analyze
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test
```

Expected: analyze clean; full suite passes (prior 319 + 5 structure-controller + 2 course-controller = 326).

- [ ] **Step 5: Device smoke test (needs a human + device)**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat run
```

Open a competition → tap a race (from Événements) → the Séries tab shows:
- With a defined structure: category sections (if >1 category) → round groups (Séries/Quarts/Demies blue, Finale green) with "N places/course · M qualifiés/course" → numbered course tiles; tapping a tile opens the per-course screen ("100m Nage · Cadets · Série 1" header + "Résultats à venir").
- With no structure defined for the race → "Structure non définie".

- [ ] **Step 6: Commit**

```bash
git add live_ffss/lib/app/module/competitions/views/race_structure_view.dart live_ffss/lib/app/module/competitions/views/race_detail_view.dart live_ffss/lib/app/core/translations/fr_fr.dart live_ffss/lib/app/core/translations/en_us.dart
git commit -m "feat(competitions): render the defined structure in the Séries tab"
```

---

## Notes for the reviewer

- **The Séries tab is a REPLACE, not an insert.** The `IndexedStack` keeps 3 children; index-1 (`heats` pill) now renders `RaceStructureView` instead of `RaceDetailHeatsView`. Pill indices stay aligned (0/1/2). `RaceDetailController` and `race_detail_heats_view.dart` are untouched — the heats view is retained (now unimported) for the future per-course results screen.
- **Testable load.** `RaceStructureController.load(Race, Competition)` and `RaceCourseController.applyArguments(Object?)` take their inputs as parameters so the tests drive them directly without needing `Get.arguments` — mirroring the read-only programme controller's testable `load`.
- **Graceful degradation.** `getEntries` failure → category counts fall back to zero; the structure still renders (mirrors the read-only programme tab). The programme load never throws (local decode self-heals), so there is no blocking error state.
- **Only real data shown.** Round chain + `spotsPerRace`/`qualifiersPerRace` + course number + per-category engaged count. No per-série engaged counts (not modeled).
- **`.tr` stays out of the controllers.** `RaceCourseController` exposes `roundType` (a `RoundType`); the view maps it via `RoundTypeFormatting.labelKey.tr`.
- **Device-only checks:** the tap→scaffold navigation and the rendering need a real run (Task 3 Step 5).
