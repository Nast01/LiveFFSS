# Read-Only Programme Tab Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a read-only "Programme" tab between "Événements" and "Clubs" in the competition detail screen — it shows the timed schedule (echoing the builder's look, minus edit controls), an empty-state when nothing is scheduled, and opens the épreuve's race detail when a scheduled race is tapped.

**Architecture:** A self-contained `CompetitionDetailProgrammeController` + `CompetitionDetailProgrammeView` in the `competitions` module read `ProgrammeService` (the stored programme) and `RaceRepository` (the same domain `Race`s "Événements" uses). Two pure tree-walk helpers move into `schedule_planner.dart` so the editor's `ScheduleController` and the new controller share them. Navigation to race detail lives in the view (matching the existing "Événements" pattern).

**Tech Stack:** Flutter, GetX, freezed models (no new ones here), mocktail.

**Spec:** `docs/superpowers/specs/2026-07-19-competition-programme-readonly-design.md`

## Global Constraints

- **Dart/Flutter binaries are not on PATH.** Use `C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat` and `dart.bat`.
- **No codegen in this feature.** `schedule_planner.dart` is plain Dart (not `@freezed`); no new freezed models are added. Do NOT run `build_runner`.
- **Analyzer is strict** (`strict-casts`, `strict-raw-types`); no `dynamic`; no analyzer ignores.
- **Controller discipline:** no `.tr` / `Get.snackbar` / `Get.dialog` / `Get.context!` / `BuildContext` in controllers; constructor injection only, never `Get.find()` in a controller body; catch `AppException` (the sealed type in `core/errors/`), not raw `Exception`. **Navigation (`Get.toNamed`) happens in the VIEW**, exactly as `competition_detail_races_view.dart` does it — never in the controller.
- **Obx dependency rule:** read every reactive value the widget depends on in the `Obx`/builder body, never only inside a `ListView`/itemBuilder.
- **Git:** `git add <explicit paths>` only — never `git add -A`. The git root is the PARENT of the Flutter package: paths show as `live_ffss/...`. Branch: `feat/timed-programme-builder`.

---

### Task 1: Pure planner helpers + ScheduleController delegation

Extracts the structure-tree walk (currently duplicated in `ScheduleController.scheduleItemFor` and `roundOf`) into two pure functions in `schedule_planner.dart`, and makes the controller delegate to them. Behavior is unchanged; the new read-only controller (Task 2) reuses the pure functions.

**Files:**
- Modify: `lib/app/domain/models/schedule_planner.dart` (add two functions)
- Modify: `lib/app/module/programme/controllers/schedule_controller.dart` (delegate `scheduleItemFor` + `roundOf`)
- Test: `test/data/models/schedule_planner_race_lookup_test.dart` (new)

**Interfaces:**
- Consumes: `CompetitionProgramme`, `ScheduleItem`, `RoundType` (all existing in the file / imported)
- Produces:
  - `ScheduleItem? raceItemFor(CompetitionProgramme p, int raceId)` — the label/round/number for a scheduled race, or null if `raceId` is not a `ProgrammeRace` in any structure.
  - `int? structureRaceIdFor(CompetitionProgramme p, int blockRaceId)` — the owning `EventStructure.raceId` (the FFSS `Race.id`) for a `ProgrammeRace` id, or null if not found.

- [ ] **Step 1: Write the failing test**

Create `test/data/models/schedule_planner_race_lookup_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/domain/models/schedule_planner.dart';

void main() {
  const programme = CompetitionProgramme(
    competitionId: 42,
    structures: [
      EventStructure(
        raceId: 500,
        categoryId: 7,
        raceLabel: '100m',
        categoryLabel: 'Cadets',
        levels: [
          RoundLevel(type: RoundType.serie, races: [
            ProgrammeRace(id: 10, number: 1),
            ProgrammeRace(id: 11, number: 2),
          ]),
          RoundLevel(type: RoundType.finale, races: [
            ProgrammeRace(id: 12, number: 1),
          ]),
        ],
      ),
    ],
  );

  group('raceItemFor', () {
    test('returns label/round/number for a scheduled race id', () {
      final item = raceItemFor(programme, 11);
      expect(item, isNotNull);
      expect(item!.raceLabel, '100m');
      expect(item.categoryLabel, 'Cadets');
      expect(item.roundType, RoundType.serie);
      expect(item.number, 2);
    });

    test('resolves a race in a later level', () {
      expect(raceItemFor(programme, 12)!.roundType, RoundType.finale);
    });

    test('returns null for an unknown id', () {
      expect(raceItemFor(programme, 999), isNull);
    });
  });

  group('structureRaceIdFor', () {
    test('returns the owning EventStructure.raceId (FFSS race id)', () {
      expect(structureRaceIdFor(programme, 10), 500);
      expect(structureRaceIdFor(programme, 12), 500);
    });

    test('returns null when the block race id is unknown', () {
      expect(structureRaceIdFor(programme, 999), isNull);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/data/models/schedule_planner_race_lookup_test.dart
```

Expected: FAIL — `raceItemFor` / `structureRaceIdFor` are not defined.

- [ ] **Step 3: Add the two pure functions**

Append to `lib/app/domain/models/schedule_planner.dart` (after `unscheduledRaces`, before the mutators — anywhere at top level is fine):

```dart
/// The [ScheduleItem] (label / round / number) for a scheduled race, found by
/// its [ProgrammeRace] id. Null if [raceId] is not a race in any structure.
ScheduleItem? raceItemFor(CompetitionProgramme p, int raceId) {
  for (final s in p.structures) {
    for (final l in s.levels) {
      for (final r in l.races) {
        if (r.id == raceId) {
          return ScheduleItem(
            raceId: r.id,
            raceLabel: s.raceLabel,
            categoryLabel: s.categoryLabel,
            roundType: l.type,
            number: r.number,
          );
        }
      }
    }
  }
  return null;
}

/// The owning [EventStructure.raceId] — the FFSS `Race.id` — for a
/// [ProgrammeRace] id, so a scheduled block can be bridged to a domain race.
/// Null if [blockRaceId] is not found.
int? structureRaceIdFor(CompetitionProgramme p, int blockRaceId) {
  for (final s in p.structures) {
    for (final l in s.levels) {
      for (final r in l.races) {
        if (r.id == blockRaceId) return s.raceId;
      }
    }
  }
  return null;
}
```

- [ ] **Step 4: Delegate the controller methods**

In `lib/app/module/programme/controllers/schedule_controller.dart`, replace the whole body of `scheduleItemFor` (currently lines ~118-137) and `roundOf` (currently lines ~139-150) with delegations:

```dart
  planner.ScheduleItem? scheduleItemFor(int raceId) {
    final p = _p;
    return p == null ? null : planner.raceItemFor(p, raceId);
  }

  RoundType roundOf(int raceId) {
    final p = _p;
    return p == null
        ? RoundType.unknown
        : (planner.raceItemFor(p, raceId)?.roundType ?? RoundType.unknown);
  }
```

(Keep the existing imports; `planner` is the `as planner` prefix already in the file, and `RoundType` is already imported from `round_level.dart`.)

- [ ] **Step 5: Run the new test + the existing controller/planner tests**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/data/models/schedule_planner_race_lookup_test.dart test/presentation/modules/programme/controllers/schedule_controller_test.dart test/data/models/schedule_blocks_planner_test.dart
```

Expected: PASS — the 5 new tests plus the existing controller (10) and planner (10) tests unchanged (`scheduleItemFor`/`roundOf` behavior identical after delegation).

- [ ] **Step 6: Commit**

```bash
git add live_ffss/lib/app/domain/models/schedule_planner.dart live_ffss/lib/app/module/programme/controllers/schedule_controller.dart live_ffss/test/data/models/schedule_planner_race_lookup_test.dart
git commit -m "refactor(programme): extract raceItemFor/structureRaceIdFor pure helpers"
```

---

### Task 2: The read-only controller + binding

Adds `CompetitionDetailProgrammeController` (loads the programme + domain races, exposes read getters and the block→race bridge) and registers it in the competition-detail binding.

**Files:**
- Create: `lib/app/module/competitions/controllers/competition_detail_programme_controller.dart`
- Modify: `lib/app/module/competitions/bindings/competition_detail_binding.dart`
- Test: `test/presentation/modules/competitions/controllers/competition_detail_programme_controller_test.dart` (new)

**Interfaces:**
- Consumes: `ProgrammeService` (`load(int)`, `current`), `RaceRepository` (`Future<List<Race>> getRaces(int)`), the Task-1 planner helpers (`raceItemFor`, `structureRaceIdFor`), `scheduleRows`, `dayStartMinutes`, `defaultStartMinutes`, `competitionDays`.
- Produces: `CompetitionDetailProgrammeController(ProgrammeService, RaceRepository)` with:
  - `Rxn<Competition> competition`, `RxBool isLoading`, `RxList<DateTime> days`, `RxInt selectedDayIndex`, `Rxn<int> selectedSiteId`
  - `Future<void> load(Competition comp)`
  - getters `List<ProgrammeSite> sites`, `bool hasProgramme`, `DateTime? selectedDay`
  - `List<ScheduleRow> rowsFor(int siteId, DateTime day)`, `int startMinutesFor(int siteId, DateTime day)`
  - `ScheduleItem? itemFor(int blockRaceId)`, `RoundType roundOf(int blockRaceId)`
  - `Race? raceForBlock(int blockRaceId)`

- [ ] **Step 1: Write the failing test**

Create `test/presentation/modules/competitions/controllers/competition_detail_programme_controller_test.dart`:

```dart
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/programme_site.dart';
import 'package:live_ffss/app/domain/models/race.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/domain/models/schedule_block.dart';
import 'package:live_ffss/app/module/competitions/controllers/competition_detail_programme_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockStorage extends Mock implements FlutterSecureStorage {}

class _MockRaceRepo extends Mock implements RaceRepository {}

void main() {
  late _MockStorage storage;
  late _MockRaceRepo raceRepo;
  late ProgrammeService service;
  late CompetitionDetailProgrammeController controller;

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

  final withDates = competition.copyWith(
    beginDate: DateTime(2026, 6, 13),
    endDate: DateTime(2026, 6, 14),
  );
  final day = DateTime(2026, 6, 13);

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

  // A programme whose structure race 500 owns ProgrammeRace ids 10/11, with a
  // scheduled block for race 10 on site 1, day 13.
  CompetitionProgramme seed() => CompetitionProgramme(
        competitionId: 42,
        nextLocalId: 100,
        sites: const [
          ProgrammeSite(id: 1, name: 'Côtier 1', type: SiteType.cotier),
        ],
        structures: const [
          EventStructure(
            raceId: 500,
            categoryId: 7,
            raceLabel: '100m',
            categoryLabel: 'Cadets',
            levels: [
              RoundLevel(type: RoundType.serie, races: [
                ProgrammeRace(id: 10, number: 1),
                ProgrammeRace(id: 11, number: 2),
              ]),
            ],
          ),
        ],
        blocks: [
          ScheduleBlock(id: 20, siteId: 1, day: day, order: 0, raceId: 10),
        ],
      );

  setUp(() {
    storage = _MockStorage();
    raceRepo = _MockRaceRepo();
    when(() => storage.read(key: any(named: 'key')))
        .thenAnswer((_) async => jsonEncode(seed().toJson()));
    when(() => storage.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((_) async {});
    service = ProgrammeService(storage);
    controller = CompetitionDetailProgrammeController(service, raceRepo);
  });

  test('load derives days, defaults the site, and exposes the schedule', () async {
    when(() => raceRepo.getRaces(42)).thenAnswer((_) async => [race(500)]);
    await controller.load(withDates);

    expect(controller.isLoading.value, isFalse);
    expect(controller.days, [DateTime(2026, 6, 13), DateTime(2026, 6, 14)]);
    expect(controller.selectedSiteId.value, 1);
    expect(controller.hasProgramme, isTrue);

    final rows = controller.rowsFor(1, day);
    expect(rows.single.block.raceId, 10);
    expect(rows.single.begin, DateTime(2026, 6, 13, 9));
    expect(controller.startMinutesFor(1, day), 540);
    expect(controller.itemFor(10)?.number, 1);
  });

  test('raceForBlock bridges a scheduled race to its domain Race', () async {
    when(() => raceRepo.getRaces(42)).thenAnswer((_) async => [race(500)]);
    await controller.load(withDates);
    expect(controller.raceForBlock(10)?.id, 500);
  });

  test('raceForBlock returns null for an unmatched race id', () async {
    when(() => raceRepo.getRaces(42)).thenAnswer((_) async => [race(500)]);
    await controller.load(withDates);
    expect(controller.raceForBlock(9999), isNull);
  });

  test('hasProgramme is false when no block is scheduled', () async {
    when(() => storage.read(key: any(named: 'key'))).thenAnswer(
        (_) async => jsonEncode(const CompetitionProgramme(competitionId: 42).toJson()));
    when(() => raceRepo.getRaces(42)).thenAnswer((_) async => const []);
    await controller.load(withDates);
    expect(controller.hasProgramme, isFalse);
  });

  test('a getRaces failure degrades gracefully — schedule renders, taps inert',
      () async {
    when(() => raceRepo.getRaces(42)).thenThrow(const NetworkException('boom'));
    await controller.load(withDates);

    expect(controller.isLoading.value, isFalse);
    expect(controller.hasProgramme, isTrue); // programme is local, still shown
    expect(controller.raceForBlock(10), isNull); // no races → inert tap
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/presentation/modules/competitions/controllers/competition_detail_programme_controller_test.dart
```

Expected: FAIL — the controller class does not exist.

- [ ] **Step 3: Write the controller**

Create `lib/app/module/competitions/controllers/competition_detail_programme_controller.dart`:

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/programme_site.dart';
import 'package:live_ffss/app/domain/models/race.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/domain/models/schedule_planner.dart' as planner;

/// Read-only view of a competition's stored programme for the "Programme" tab.
/// Loads the programme (from [ProgrammeService]) and the domain races (from
/// [RaceRepository]) so a scheduled race block can be bridged to its race
/// detail. No mutation.
class CompetitionDetailProgrammeController extends GetxController {
  CompetitionDetailProgrammeController(this._programme, this._raceRepo);

  final ProgrammeService _programme;
  final RaceRepository _raceRepo;

  final Rxn<Competition> competition = Rxn<Competition>();
  final RxBool isLoading = true.obs;
  final RxList<DateTime> days = <DateTime>[].obs;
  final RxInt selectedDayIndex = 0.obs;
  final Rxn<int> selectedSiteId = Rxn<int>();

  Map<int, Race> _racesByFfssId = const {};

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is Competition) {
      load(arg);
    } else {
      isLoading.value = false;
    }
  }

  CompetitionProgramme? get _p => _programme.current.value;

  List<ProgrammeSite> get sites => _p?.sites ?? const [];

  bool get hasProgramme => (_p?.blocks ?? const []).isNotEmpty;

  DateTime? get selectedDay => days.isEmpty
      ? null
      : days[selectedDayIndex.value.clamp(0, days.length - 1)];

  Future<void> load(Competition comp) async {
    competition.value = comp;
    days.value = planner.competitionDays(comp.beginDate, comp.endDate);
    try {
      isLoading.value = true;
      await _programme.load(comp.id);
      final races = await _raceRepo.getRaces(comp.id);
      _racesByFfssId = {for (final r in races) r.id: r};
    } on AppException {
      // Races unavailable (offline / API error): the programme is local and
      // still renders; taps that need a domain race are inert.
      _racesByFfssId = const {};
    } finally {
      final s = sites;
      if (s.isNotEmpty) selectedSiteId.value = s.first.id;
      isLoading.value = false;
    }
  }

  List<planner.ScheduleRow> rowsFor(int siteId, DateTime day) {
    final p = _p;
    return p == null ? const [] : planner.scheduleRows(p, siteId, day);
  }

  int startMinutesFor(int siteId, DateTime day) {
    final p = _p;
    return p == null
        ? planner.defaultStartMinutes
        : planner.dayStartMinutes(p, siteId, day);
  }

  planner.ScheduleItem? itemFor(int blockRaceId) {
    final p = _p;
    return p == null ? null : planner.raceItemFor(p, blockRaceId);
  }

  RoundType roundOf(int blockRaceId) {
    final p = _p;
    return p == null
        ? RoundType.unknown
        : (planner.raceItemFor(p, blockRaceId)?.roundType ?? RoundType.unknown);
  }

  /// The domain [Race] for a scheduled race block, bridged via the owning
  /// structure's FFSS race id. Null for a manual block or when the race isn't
  /// among the loaded races.
  Race? raceForBlock(int blockRaceId) {
    final p = _p;
    if (p == null) return null;
    final ffssId = planner.structureRaceIdFor(p, blockRaceId);
    return ffssId == null ? null : _racesByFfssId[ffssId];
  }
}
```

- [ ] **Step 4: Register the controller in the binding**

In `lib/app/module/competitions/bindings/competition_detail_binding.dart`, add the import and the registration. Add to the imports:

```dart
import 'package:live_ffss/app/data/services/programme_service.dart';
import '../controllers/competition_detail_programme_controller.dart';
```

and add inside `dependencies()` (after the races controller registration):

```dart
    Get.lazyPut<CompetitionDetailProgrammeController>(
      () => CompetitionDetailProgrammeController(
        Get.find<ProgrammeService>(),
        Get.find<RaceRepository>(),
      ),
    );
```

- [ ] **Step 5: Run the test to verify it passes**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/presentation/modules/competitions/controllers/competition_detail_programme_controller_test.dart
```

Expected: PASS — 5 tests.

- [ ] **Step 6: Analyze the changed files**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat analyze lib/app/module/competitions/controllers/competition_detail_programme_controller.dart lib/app/module/competitions/bindings/competition_detail_binding.dart
```

Expected: `No issues found!`

- [ ] **Step 7: Commit**

```bash
git add live_ffss/lib/app/module/competitions/controllers/competition_detail_programme_controller.dart live_ffss/lib/app/module/competitions/bindings/competition_detail_binding.dart live_ffss/test/presentation/modules/competitions/controllers/competition_detail_programme_controller_test.dart
git commit -m "feat(competitions): add read-only programme controller"
```

---

### Task 3: The read-only view + the 4th pill + translations

Adds `CompetitionDetailProgrammeView` (Direction-A read-only look), inserts the "Programme" pill between "Événements" and "Clubs" (reindexing the `IndexedStack`), and adds the `no_programme` translation key. No unit tests (view); verified via `flutter analyze` + the full suite, and a device smoke test.

**Files:**
- Create: `lib/app/module/competitions/views/competition_detail_programme_view.dart`
- Modify: `lib/app/module/competitions/views/competition_detail_view.dart` (4th pill + 4th `IndexedStack` child + import)
- Modify: `lib/app/core/translations/fr_fr.dart`, `lib/app/core/translations/en_us.dart`

**Interfaces:**
- Consumes: `CompetitionDetailProgrammeController` (`isLoading`, `days`, `selectedDayIndex`, `selectedSiteId`, `sites`, `selectedDay`, `hasProgramme`, `rowsFor`, `startMinutesFor`, `itemFor`, `roundOf`, `raceForBlock`, `competition`), `ScheduleRow`, `RoundType`, `ScheduleItemFormatting.label`, `Routes.raceDetail`, `FormatConst`, theme tokens, `LoadingIndicator`, `EmptyState`.

- [ ] **Step 1: Add the translation key**

In `lib/app/core/translations/fr_fr.dart`, add before the final `};`:

```dart
  'no_programme': 'Programme non défini',
```

In `lib/app/core/translations/en_us.dart`, add before the final `};`:

```dart
  'no_programme': 'No programme defined',
```

- [ ] **Step 2: Write the view**

Create `lib/app/module/competitions/views/competition_detail_programme_view.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/const/format_const.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/domain/models/schedule_planner.dart';
import 'package:live_ffss/app/module/competitions/controllers/competition_detail_programme_controller.dart';
import 'package:live_ffss/app/presentation/modules/programme/programme_formatting.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';
import 'package:live_ffss/app/presentation/shared/loading_indicator.dart';
import 'package:live_ffss/app/routes/app_pages.dart';

class CompetitionDetailProgrammeView
    extends GetView<CompetitionDetailProgrammeController> {
  const CompetitionDetailProgrammeView({super.key});

  String _hhmm(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const LoadingIndicator();
      }
      if (controller.days.isEmpty || !controller.hasProgramme) {
        return EmptyState(icon: Icons.event_busy, title: 'no_programme'.tr);
      }
      return Column(
        children: [
          _DayChips(controller: controller),
          _SiteChips(controller: controller, hhmm: _hhmm),
          const SizedBox(height: AppSpacing.xs),
          Expanded(child: _ReadonlyTimeline(controller: controller)),
        ],
      );
    });
  }
}

class _DayChips extends StatelessWidget {
  const _DayChips({required this.controller});
  final CompetitionDetailProgrammeController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Obx(() {
        final selected = controller.selectedDayIndex.value;
        final days = controller.days;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: AppSpacing.pageHorizontal,
          itemCount: days.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (_, i) {
            final active = selected == i;
            return GestureDetector(
              onTap: () => controller.selectedDayIndex.value = i,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: active ? AppColors.statusWaiting : AppColors.surface,
                  borderRadius: AppRadius.pillRadius,
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  FormatConst.dateFormat.format(days[i]),
                  style: AppTypography.caption.copyWith(
                      color: active ? Colors.white : AppColors.textPrimary),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _SiteChips extends StatelessWidget {
  const _SiteChips({required this.controller, required this.hhmm});
  final CompetitionDetailProgrammeController controller;
  final String Function(int minutes) hhmm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.xs, AppSpacing.md, 0),
      child: Obx(() {
        final sites = controller.sites;
        final selectedId = controller.selectedSiteId.value;
        final day = controller.selectedDay;
        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: sites.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (_, i) {
                    final s = sites[i];
                    final active = selectedId == s.id;
                    return GestureDetector(
                      onTap: () => controller.selectedSiteId.value = s.id,
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: active ? AppColors.primary : AppColors.surface,
                          borderRadius: AppRadius.pillRadius,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          s.name,
                          style: AppTypography.caption.copyWith(
                              color: active
                                  ? Colors.white
                                  : AppColors.textPrimary),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (selectedId != null && day != null)
              Container(
                margin: const EdgeInsets.only(left: AppSpacing.sm),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: AppRadius.pillRadius,
                ),
                child: Text(
                  '${'starts_at'.tr} ${hhmm(controller.startMinutesFor(selectedId, day))}',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.primaryDark),
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _ReadonlyTimeline extends StatelessWidget {
  const _ReadonlyTimeline({required this.controller});
  final CompetitionDetailProgrammeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final siteId = controller.selectedSiteId.value;
      final day = controller.selectedDay;
      if (siteId == null || day == null) {
        return EmptyState(icon: Icons.schedule, title: 'no_placement_here'.tr);
      }
      final rows = controller.rowsFor(siteId, day);
      if (rows.isEmpty) {
        return EmptyState(icon: Icons.schedule, title: 'no_placement_here'.tr);
      }
      return ListView.separated(
        padding: AppSpacing.pageAll,
        itemCount: rows.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
        itemBuilder: (_, i) =>
            _ReadonlyCard(row: rows[i], controller: controller),
      );
    });
  }
}

class _ReadonlyCard extends StatelessWidget {
  const _ReadonlyCard({required this.row, required this.controller});
  final ScheduleRow row;
  final CompetitionDetailProgrammeController controller;

  @override
  Widget build(BuildContext context) {
    final b = row.block;
    final isManual = b.raceId == null;
    final accent = isManual
        ? AppColors.statusWaiting
        : (controller.roundOf(b.raceId!) == RoundType.finale
            ? AppColors.statusFinished
            : AppColors.primary);
    final label =
        isManual ? b.manualLabel : (controller.itemFor(b.raceId!)?.label ?? '');
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.mdRadius,
      elevation: 1,
      child: InkWell(
        borderRadius: AppRadius.mdRadius,
        onTap: isManual
            ? null
            : () {
                final race = controller.raceForBlock(b.raceId!);
                if (race != null) {
                  Get.toNamed<void>(Routes.raceDetail, arguments: {
                    'race': race,
                    'competition': controller.competition.value,
                  });
                }
              },
        child: Row(
          children: [
            Container(
              width: 5,
              height: 56,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(AppRadius.md)),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(children: [
                      Text(FormatConst.timeFormat.format(row.begin),
                          style: AppTypography.body.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark)),
                      const SizedBox(width: 6),
                      Text(
                          '→ ${FormatConst.timeFormat.format(row.end)} · ${b.durationMinutes} ${'min_short'.tr}',
                          style: AppTypography.caption),
                    ]),
                    Text(label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body),
                  ],
                ),
              ),
            ),
            if (!isManual)
              const Padding(
                padding: EdgeInsets.only(right: AppSpacing.sm),
                child: Icon(Icons.chevron_right, color: AppColors.textMuted),
              ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Wire the 4th tab into the competition detail view**

In `lib/app/module/competitions/views/competition_detail_view.dart`:

Add the import (next to the other tab-view imports):

```dart
import 'package:live_ffss/app/module/competitions/views/competition_detail_programme_view.dart';
```

Replace the `IndexedStack` children list (currently 3 entries) with 4:

```dart
                      children: const [
                        CompetitionDetailRacesView(),
                        CompetitionDetailProgrammeView(),
                        CompetitionDetailClubsView(),
                        CompetitionDetailPointsView(),
                      ],
```

Replace the pill row (currently `events`/`clubs`/`points` at indices 0/1/2) with the reindexed 4-pill row:

```dart
            child: Row(
              children: [
                _DetailPill(label: 'events'.tr, index: 0),
                const SizedBox(width: AppSpacing.sm),
                _DetailPill(label: 'programme'.tr, index: 1),
                const SizedBox(width: AppSpacing.sm),
                _DetailPill(label: 'clubs'.tr, index: 2),
                const SizedBox(width: AppSpacing.sm),
                _DetailPill(label: 'points'.tr, index: 3),
              ],
            ),
```

- [ ] **Step 4: Analyze + run the full suite**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat analyze
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test
```

Expected: analyze clean; full suite passes (309 prior + 5 planner + 5 controller = 319 tests).

- [ ] **Step 5: Device smoke test (needs a human + device)**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat run
```

Open a competition → the header shows Événements / **Programme** / Clubs / Points. On Programme:
- With no scheduled programme → "Programme non défini".
- With a scheduled programme → day chips + site chips + the read-only timeline (no drag handles, no ±, no ×, start chip shown without the ▾ editor).
- Tapping a race card opens that épreuve's race detail (Engagés / Séries / Résumé) — the same screen as tapping it in Événements.
- A manual item ("Pause") shows but does not react to taps.

- [ ] **Step 6: Commit**

```bash
git add live_ffss/lib/app/module/competitions/views/competition_detail_programme_view.dart live_ffss/lib/app/module/competitions/views/competition_detail_view.dart live_ffss/lib/app/core/translations/fr_fr.dart live_ffss/lib/app/core/translations/en_us.dart
git commit -m "feat(competitions): read-only programme tab between events and clubs"
```

---

## Notes for the reviewer

- **Graceful degradation over a blocking error state.** The spec sketched a `hasError` → `ErrorState`, but the programme is loaded from local storage (`ProgrammeService._decode` never throws) and only `getRaces` can fail. Blocking the whole tab on a races-load failure would hide a perfectly good local schedule, so the controller instead catches `AppException`, leaves `_racesByFfssId` empty (taps inert), and the schedule still renders. This is the intended refinement, covered by the "degrades gracefully" test.
- **The bridge is the load-bearing part.** `raceForBlock` = `structureRaceIdFor(programme, blockRaceId)` (→ `EventStructure.raceId`, the FFSS `Race.id`) → the races map. Verified: structures are seeded with `raceId: race.id` (`programme_controller.dart:86`). A race whose épreuve isn't among the loaded races, or a manual block, is inert — never a crash.
- **Obx dependency rule.** `_ReadonlyTimeline` and `_SiteChips` read `selectedSiteId.value`/`selectedDay` in the `Obx` body (before the itemBuilder); `_DayChips` reads `selectedDayIndex`/`days` in the body. Same rule that bit the editor twice.
- **No new freezed models, no codegen.** Only hand-written Dart and one translation key.
- **Read-only.** No `ProgrammeService.save`, no mutators — the tab only reads `current`.
- **Device-only checks:** the tap→detail navigation and the empty/loaded rendering need a real run (Task 3 Step 5).
