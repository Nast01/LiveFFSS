# Programme Builder — Plan B (Scheduling) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let the operator schedule each authored race onto a site and a time slot per competition day — declare sites once, tap-to-place races on a per-day per-site timeline (default 10 min, editable, overlap-guarded), see the whole day across sites — all on-device, with a pure FFSS `Meeting → Slot → Run` mapper ready for when the write endpoints land.

**Architecture:** Placement is a field on the existing `ProgrammeRace` (`RacePlacement?`), so scheduling is `copyWith` + `ProgrammeService.save` over the same local blob Plan A persists. A pure `schedule_planner` computes days, flattens races into view models, finds the next free slot, and detects overlaps. A `ScheduleController` and a `SitesController` (both in the existing `programme` module) drive the UI; the schedule view replaces Plan A's placeholder tab. A pure `programmeToMeetings` mapper materialises the FFSS tree (push stays behind the stubbed seam until FFSS documents créneau/course endpoints).

**Tech Stack:** Flutter, GetX, freezed (models already exist — no new freezed classes), flutter_secure_storage (via ProgrammeService), mocktail.

**Spec:** `docs/superpowers/specs/2026-07-18-competition-programme-builder-design.md` (Sub-project 2 — Scheduling)

## Global Constraints

- **Dart/Flutter binaries are not on PATH.** Use `C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat` and `dart.bat`.
- **No new freezed models** — Plan B reuses `RacePlacement`, `ProgrammeSite`/`SiteType`, `CompetitionProgramme`, `ProgrammeRace`, `RoundLevel`/`RoundType`, `EventStructure` (all built in Plan A). No `build_runner` runs are needed unless a task explicitly says so.
- **`explicit_to_json` is false** (no `build.yaml`): a model round-trip test must go through the JSON string. Persistence is already `jsonEncode(toJson())`/`jsonDecode→fromJson` inside `ProgrammeService`.
- **Analyzer is strict:** `strict-casts: true`, `strict-raw-types: true`. No `dynamic`.
- **Controller discipline (enforced by review):** no `Get.snackbar` / `Get.dialog` / `.tr` / `Get.context!` / `BuildContext` params in controllers; user feedback via `Rxn<UiMessage>`; constructor injection only, never `Get.find()` in a controller body; catch `AppException`, never raw `Exception`. `Get.find` IS allowed in a view (`StatefulWidget` State / `GetView`). Views own their `Worker`s and dispose them.
- **id allocation** for new sites uses `ProgrammeService.allocateId()` (returns the pre-increment value, bumps `nextLocalId` in `current`; caller persists with a later `save`). Placements need no ids.
- **Persistence pattern:** read `_programme.current.value`, `copyWith(...)`, `await _programme.save(updated)`. Never mutate a freezed object in place.
- **Reactive refresh:** controllers that must react to programme changes register `ever(_programme.current, ...)` in `onInit` and dispose the `Worker` in `onClose` (Plan A's `ProgrammeController` is the reference).
- **Time format:** reuse `FormatConst.timeFormat` (`DateFormat('HH:mm')`) and `FormatConst.dateFormat` (`DateFormat('yyyy-MM-dd')`) from `lib/app/core/const/format_const.dart` for display and for the FFSS `jour`/`debut`/`fin` strings.
- **Default race duration is 10 minutes; the day starts at 09:00** (`scheduleDayStartHour = 9`).
- Use `git add <explicit paths>` only — the working tree may carry unrelated modified files; never `git add -A` / `git add .`.

---

### Task 1: Scheduling translation keys

**Files:**
- Modify: `lib/app/core/translations/fr_fr.dart`
- Modify: `lib/app/core/translations/en_us.dart`

**Interfaces:**
- Produces the keys used by the Plan B views: `sites`, `add_site`, `site_name`, `site_cotier`, `site_sable`, `no_sites`, `no_days`, `unscheduled`, `add_race`, `schedule_overlap`, `min_short`, `day_overview`, `duration`, `no_placement_here`, `pick_time`.

- [ ] **Step 1: Add the French keys**

Append to the map in `lib/app/core/translations/fr_fr.dart`, before the final `};`:

```dart
  // Programme scheduling
  'sites': 'Sites',
  'add_site': 'Ajouter un site',
  'site_name': 'Nom du site',
  'site_cotier': 'côtier',
  'site_sable': 'sable',
  'no_sites': 'Aucun site — ajoutez-en un',
  'no_days': 'Dates de compétition inconnues',
  'unscheduled': 'Non planifiées',
  'add_race': 'Ajouter une course',
  'schedule_overlap': 'Chevauche une autre course sur ce site',
  'min_short': 'min',
  'day_overview': 'Vue journée',
  'duration': 'Durée',
  'no_placement_here': 'Aucune course ici',
  'pick_time': "Choisir l'heure",
```

- [ ] **Step 2: Add the English keys**

Append to the map in `lib/app/core/translations/en_us.dart`, before the final `};`:

```dart
  // Programme scheduling
  'sites': 'Sites',
  'add_site': 'Add a site',
  'site_name': 'Site name',
  'site_cotier': 'coastal',
  'site_sable': 'sand',
  'no_sites': 'No site yet — add one',
  'no_days': 'Competition dates unknown',
  'unscheduled': 'Unscheduled',
  'add_race': 'Add a race',
  'schedule_overlap': 'Overlaps another race on this site',
  'min_short': 'min',
  'day_overview': 'Day overview',
  'duration': 'Duration',
  'no_placement_here': 'No race here',
  'pick_time': 'Pick time',
```

- [ ] **Step 3: Verify no duplicate keys**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat analyze lib/app/core/translations/
```

Expected: `No issues found!` (a duplicate map key is an analyzer error).

- [ ] **Step 4: Commit**

```bash
git add lib/app/core/translations/fr_fr.dart lib/app/core/translations/en_us.dart
git commit -m "feat(programme): add scheduling translation keys"
```

---

### Task 2: Schedule planner (pure)

All the pure scheduling logic: the day list, flattening races into view models, the next-free-slot, overlap detection, and the placement mutations on `CompetitionProgramme`. No I/O.

**Files:**
- Create: `lib/app/domain/models/schedule_planner.dart`
- Test: `test/data/models/schedule_planner_test.dart`

**Interfaces:**
- Consumes: `CompetitionProgramme`, `EventStructure`, `RoundLevel`, `ProgrammeRace`, `RacePlacement`, `RoundType`
- Produces:
  - `const int scheduleDayStartHour = 9;`
  - `class ScheduleItem { final int raceId; final String raceLabel; final String categoryLabel; final RoundType roundType; final int number; final RacePlacement? placement; }`
  - `List<DateTime> competitionDays(DateTime? begin, DateTime? end)`
  - `List<ScheduleItem> allScheduleItems(CompetitionProgramme p)`
  - `bool sameDay(DateTime a, DateTime b)`
  - `DateTime placementEnd(RacePlacement p)`
  - `DateTime nextFreeStart({required DateTime day, required List<RacePlacement> onSiteDay, int startHour = scheduleDayStartHour})`
  - `bool overlaps({required RacePlacement candidate, required Iterable<RacePlacement> others})`
  - `CompetitionProgramme setPlacement(CompetitionProgramme p, int raceId, RacePlacement? placement)`
  - `CompetitionProgramme clearPlacementsForSite(CompetitionProgramme p, int siteId)`

- [ ] **Step 1: Write the failing test**

Create `test/data/models/schedule_planner_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/race_placement.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/domain/models/schedule_planner.dart';

void main() {
  CompetitionProgramme prog(List<ProgrammeRace> serieRaces) =>
      CompetitionProgramme(
        competitionId: 1,
        structures: [
          EventStructure(
            raceId: 100,
            categoryId: 7,
            raceLabel: '100m',
            categoryLabel: 'Cadets',
            levels: [RoundLevel(type: RoundType.serie, races: serieRaces)],
          ),
        ],
      );

  group('competitionDays', () {
    test('lists each day at midnight, inclusive', () {
      final days = competitionDays(DateTime(2026, 6, 13, 8), DateTime(2026, 6, 15, 20));
      expect(days, [DateTime(2026, 6, 13), DateTime(2026, 6, 14), DateTime(2026, 6, 15)]);
    });

    test('is empty when either bound is null', () {
      expect(competitionDays(null, DateTime(2026, 6, 15)), isEmpty);
      expect(competitionDays(DateTime(2026, 6, 13), null), isEmpty);
    });

    test('is empty when end precedes begin', () {
      expect(competitionDays(DateTime(2026, 6, 15), DateTime(2026, 6, 13)), isEmpty);
    });
  });

  group('allScheduleItems', () {
    test('flattens races with labels, round type and number', () {
      final items = allScheduleItems(prog(const [
        ProgrammeRace(id: 1, number: 1),
        ProgrammeRace(id: 2, number: 2),
      ]));
      expect(items.length, 2);
      expect(items.first.raceLabel, '100m');
      expect(items.first.categoryLabel, 'Cadets');
      expect(items.first.roundType, RoundType.serie);
      expect(items.first.number, 1);
      expect(items.first.placement, isNull);
    });
  });

  group('nextFreeStart', () {
    test('starts at the day start hour when the site is empty', () {
      final start = nextFreeStart(day: DateTime(2026, 6, 13), onSiteDay: const []);
      expect(start, DateTime(2026, 6, 13, 9));
    });

    test('starts at the latest end when the site has races', () {
      final start = nextFreeStart(day: DateTime(2026, 6, 13), onSiteDay: [
        RacePlacement(siteId: 1, beginHour: DateTime(2026, 6, 13, 9), durationMinutes: 10),
        RacePlacement(siteId: 1, beginHour: DateTime(2026, 6, 13, 9, 10), durationMinutes: 15),
      ]);
      expect(start, DateTime(2026, 6, 13, 9, 25));
    });
  });

  group('overlaps', () {
    final base = RacePlacement(siteId: 1, beginHour: DateTime(2026, 6, 13, 9), durationMinutes: 10);
    test('true when the candidate intersects another', () {
      final candidate = RacePlacement(siteId: 1, beginHour: DateTime(2026, 6, 13, 9, 5), durationMinutes: 10);
      expect(overlaps(candidate: candidate, others: [base]), isTrue);
    });
    test('false when the candidate starts exactly at another end (touching, not overlapping)', () {
      final candidate = RacePlacement(siteId: 1, beginHour: DateTime(2026, 6, 13, 9, 10), durationMinutes: 10);
      expect(overlaps(candidate: candidate, others: [base]), isFalse);
    });
  });

  group('setPlacement', () {
    test('sets the placement on the matching race only', () {
      final p = prog(const [ProgrammeRace(id: 1, number: 1), ProgrammeRace(id: 2, number: 2)]);
      final placement = RacePlacement(siteId: 9, beginHour: DateTime(2026, 6, 13, 9));
      final updated = setPlacement(p, 2, placement);
      final races = updated.structures.single.levels.single.races;
      expect(races[0].placement, isNull);
      expect(races[1].placement, placement);
    });

    test('null clears a placement', () {
      final placed = setPlacement(
        prog(const [ProgrammeRace(id: 1, number: 1)]),
        1,
        RacePlacement(siteId: 9, beginHour: DateTime(2026, 6, 13, 9)),
      );
      final cleared = setPlacement(placed, 1, null);
      expect(cleared.structures.single.levels.single.races.single.placement, isNull);
    });
  });

  group('clearPlacementsForSite', () {
    test('clears only races placed on the given site', () {
      var p = prog(const [ProgrammeRace(id: 1, number: 1), ProgrammeRace(id: 2, number: 2)]);
      p = setPlacement(p, 1, RacePlacement(siteId: 5, beginHour: DateTime(2026, 6, 13, 9)));
      p = setPlacement(p, 2, RacePlacement(siteId: 6, beginHour: DateTime(2026, 6, 13, 9)));
      final cleared = clearPlacementsForSite(p, 5);
      final races = cleared.structures.single.levels.single.races;
      expect(races[0].placement, isNull);
      expect(races[1].placement, isNotNull);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/data/models/schedule_planner_test.dart
```

Expected: FAIL — `schedule_planner.dart` does not exist.

- [ ] **Step 3: Write the planner**

Create `lib/app/domain/models/schedule_planner.dart`:

```dart
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/race_placement.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';

/// The hour a competition day's timeline starts when a site has no races yet.
const int scheduleDayStartHour = 9;

/// A race flattened for the scheduling UI: its labels, round stage, number,
/// and placement (null = unscheduled). A pure view model, not persisted.
class ScheduleItem {
  const ScheduleItem({
    required this.raceId,
    required this.raceLabel,
    required this.categoryLabel,
    required this.roundType,
    required this.number,
    required this.placement,
  });

  final int raceId;
  final String raceLabel;
  final String categoryLabel;
  final RoundType roundType;
  final int number;
  final RacePlacement? placement;
}

/// Every competition day from [begin] to [end] inclusive, normalised to
/// midnight. Empty if either is null or [end] precedes [begin].
List<DateTime> competitionDays(DateTime? begin, DateTime? end) {
  if (begin == null || end == null) return const [];
  final first = DateTime(begin.year, begin.month, begin.day);
  final last = DateTime(end.year, end.month, end.day);
  if (last.isBefore(first)) return const [];
  final days = <DateTime>[];
  for (var d = first; !d.isAfter(last); d = d.add(const Duration(days: 1))) {
    days.add(d);
  }
  return days;
}

/// Flattens every race across all structures into [ScheduleItem]s.
List<ScheduleItem> allScheduleItems(CompetitionProgramme p) => [
      for (final s in p.structures)
        for (final l in s.levels)
          for (final r in l.races)
            ScheduleItem(
              raceId: r.id,
              raceLabel: s.raceLabel,
              categoryLabel: s.categoryLabel,
              roundType: l.type,
              number: r.number,
              placement: r.placement,
            ),
    ];

bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime placementEnd(RacePlacement p) =>
    p.beginHour.add(Duration(minutes: p.durationMinutes));

/// The earliest free start on a site for [day]: the day at [startHour] when
/// the site is empty, otherwise the latest existing end (append after the
/// last race).
DateTime nextFreeStart({
  required DateTime day,
  required List<RacePlacement> onSiteDay,
  int startHour = scheduleDayStartHour,
}) {
  if (onSiteDay.isEmpty) {
    return DateTime(day.year, day.month, day.day, startHour);
  }
  return onSiteDay
      .map(placementEnd)
      .reduce((a, b) => a.isAfter(b) ? a : b);
}

/// Whether [candidate]'s time range intersects any of [others]. Callers pass
/// only placements on the same site and day; touching ranges (one starts at
/// another's end) do not overlap.
bool overlaps({
  required RacePlacement candidate,
  required Iterable<RacePlacement> others,
}) {
  final cStart = candidate.beginHour;
  final cEnd = placementEnd(candidate);
  for (final o in others) {
    if (cStart.isBefore(placementEnd(o)) && o.beginHour.isBefore(cEnd)) {
      return true;
    }
  }
  return false;
}

/// Returns a copy of [p] with the placement of race [raceId] set (or cleared
/// when [placement] is null), rebuilding the structure tree immutably.
CompetitionProgramme setPlacement(
  CompetitionProgramme p,
  int raceId,
  RacePlacement? placement,
) {
  return p.copyWith(structures: [
    for (final s in p.structures)
      s.copyWith(levels: [
        for (final l in s.levels)
          l.copyWith(races: [
            for (final r in l.races)
              r.id == raceId ? r.copyWith(placement: placement) : r,
          ]),
      ]),
  ]);
}

/// Clears the placement of every race scheduled on [siteId] — used when a site
/// is deleted so no race points at a gone site.
CompetitionProgramme clearPlacementsForSite(
    CompetitionProgramme p, int siteId) {
  return p.copyWith(structures: [
    for (final s in p.structures)
      s.copyWith(levels: [
        for (final l in s.levels)
          l.copyWith(races: [
            for (final r in l.races)
              r.placement?.siteId == siteId
                  ? r.copyWith(placement: null)
                  : r,
          ]),
      ]),
  ]);
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/data/models/schedule_planner_test.dart
```

Expected: PASS — 11 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/app/domain/models/schedule_planner.dart test/data/models/schedule_planner_test.dart
git commit -m "feat(programme): add the pure scheduling planner"
```

---

### Task 3: SitesController + sites editor view (3A)

**Files:**
- Create: `lib/app/module/programme/controllers/sites_controller.dart`
- Create: `lib/app/module/programme/views/sites_view.dart`
- Modify: `lib/app/module/programme/bindings/programme_binding.dart`
- Test: `test/presentation/modules/programme/controllers/sites_controller_test.dart`

**Interfaces:**
- Consumes: `ProgrammeService` (`current`, `save`, `allocateId`), `CompetitionProgramme`, `ProgrammeSite`, `SiteType`, `clearPlacementsForSite`
- Produces:
  - `SitesController(ProgrammeService)` with `List<ProgrammeSite> get sites`, `Future<void> addSite(String name, SiteType type)`, `Future<void> renameSite(int id, String name, SiteType type)`, `Future<void> deleteSite(int id)`

- [ ] **Step 1: Write the failing test**

Create `test/presentation/modules/programme/controllers/sites_controller_test.dart`:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/programme_site.dart';
import 'package:live_ffss/app/module/programme/controllers/sites_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockStorage storage;
  late ProgrammeService service;
  late SitesController controller;

  setUpAll(() => registerFallbackValue(''));

  setUp(() async {
    storage = _MockStorage();
    when(() => storage.read(key: any(named: 'key')))
        .thenAnswer((_) async => null);
    when(() => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'))).thenAnswer((_) async {});
    service = ProgrammeService(storage);
    await service.load(42);
    controller = SitesController(service);
  });

  test('addSite appends a site with an allocated id and persists', () async {
    await controller.addSite('Côtier 1', SiteType.cotier);

    expect(controller.sites.length, 1);
    expect(controller.sites.single.name, 'Côtier 1');
    expect(controller.sites.single.type, SiteType.cotier);
    expect(controller.sites.single.id, 1); // first allocated id
    verify(() => storage.write(
        key: 'programme_42', value: any(named: 'value'))).called(1);
  });

  test('addSite gives distinct ids', () async {
    await controller.addSite('Côtier 1', SiteType.cotier);
    await controller.addSite('Sable 1', SiteType.sable);
    final ids = controller.sites.map((s) => s.id).toSet();
    expect(ids.length, 2);
  });

  test('renameSite updates name and type in place', () async {
    await controller.addSite('Côtier 1', SiteType.cotier);
    final id = controller.sites.single.id;

    await controller.renameSite(id, 'Côtier A', SiteType.sable);

    expect(controller.sites.single.name, 'Côtier A');
    expect(controller.sites.single.type, SiteType.sable);
  });

  test('deleteSite removes it', () async {
    await controller.addSite('Côtier 1', SiteType.cotier);
    final id = controller.sites.single.id;

    await controller.deleteSite(id);

    expect(controller.sites, isEmpty);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/presentation/modules/programme/controllers/sites_controller_test.dart
```

Expected: FAIL — `sites_controller.dart` does not exist.

- [ ] **Step 3: Write the controller**

Create `lib/app/module/programme/controllers/sites_controller.dart`:

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/programme_site.dart';
import 'package:live_ffss/app/domain/models/schedule_planner.dart';

class SitesController extends GetxController {
  SitesController(this._programme);

  final ProgrammeService _programme;

  List<ProgrammeSite> get sites =>
      _programme.current.value?.sites ?? const [];

  Future<void> addSite(String name, SiteType type) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final p = _programme.current.value;
    if (p == null) return;
    final id = _programme.allocateId();
    // Re-read current: allocateId bumped nextLocalId in it.
    final withBump = _programme.current.value!;
    await _programme.save(withBump.copyWith(
      sites: [...withBump.sites, ProgrammeSite(id: id, name: trimmed, type: type)],
    ));
  }

  Future<void> renameSite(int id, String name, SiteType type) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final p = _programme.current.value;
    if (p == null) return;
    await _programme.save(p.copyWith(sites: [
      for (final s in p.sites)
        s.id == id ? s.copyWith(name: trimmed, type: type) : s,
    ]));
  }

  Future<void> deleteSite(int id) async {
    final p = _programme.current.value;
    if (p == null) return;
    // Drop the site AND clear any race placed on it, so nothing dangles.
    final withoutSite =
        p.copyWith(sites: p.sites.where((s) => s.id != id).toList());
    await _programme.save(clearPlacementsForSite(withoutSite, id));
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/presentation/modules/programme/controllers/sites_controller_test.dart
```

Expected: PASS — 4 tests.

- [ ] **Step 5: Register in the binding and write the view**

In `lib/app/module/programme/bindings/programme_binding.dart`, add the import and registration (keep the existing `ProgrammeController` registration):

```dart
import '../controllers/sites_controller.dart';
```

and inside `dependencies()`:

```dart
    Get.lazyPut<SitesController>(
      () => SitesController(Get.find<ProgrammeService>()),
    );
```

Create `lib/app/module/programme/views/sites_view.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/programme_site.dart';
import 'package:live_ffss/app/module/programme/controllers/sites_controller.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';

class SitesView extends StatelessWidget {
  const SitesView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SitesController>();
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text('sites'.tr,
            style: AppTypography.title.copyWith(color: Colors.white, fontSize: 16)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSiteDialog(context, controller),
        icon: const Icon(Icons.add),
        label: Text('add_site'.tr),
      ),
      body: Obx(() {
        final sites = controller.sites;
        if (sites.isEmpty) {
          return EmptyState(icon: Icons.place_outlined, title: 'no_sites'.tr);
        }
        return ListView.separated(
          padding: AppSpacing.pageAll,
          itemCount: sites.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (_, i) {
            final site = sites[i];
            return Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: Icon(site.type == SiteType.sable
                    ? Icons.beach_access
                    : Icons.waves),
                title: Text(site.name),
                subtitle: Text(_typeLabel(site.type)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => controller.deleteSite(site.id),
                ),
                onTap: () => _openSiteDialog(context, controller, site: site),
              ),
            );
          },
        );
      }),
    );
  }

  static String _typeLabel(SiteType type) =>
      (type == SiteType.sable ? 'site_sable' : 'site_cotier').tr;

  Future<void> _openSiteDialog(BuildContext context, SitesController controller,
      {ProgrammeSite? site}) async {
    final nameController = TextEditingController(text: site?.name ?? '');
    var type = site?.type ?? SiteType.cotier;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text('add_site'.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'site_name'.tr),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  for (final t in const [SiteType.cotier, SiteType.sable])
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: ChoiceChip(
                        label: Text(_typeLabel(t)),
                        selected: type == t,
                        onSelected: (_) => setState(() => type = t),
                      ),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('cancel'.tr),
            ),
            TextButton(
              onPressed: () {
                if (site == null) {
                  controller.addSite(nameController.text, type);
                } else {
                  controller.renameSite(site.id, nameController.text, type);
                }
                Navigator.of(ctx).pop();
              },
              child: Text('add_site'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 6: Verify analyze**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat analyze lib/app/module/programme/
```

Expected: `No issues found!`

- [ ] **Step 7: Commit**

```bash
git add lib/app/module/programme/controllers/sites_controller.dart lib/app/module/programme/views/sites_view.dart lib/app/module/programme/bindings/programme_binding.dart test/presentation/modules/programme/controllers/sites_controller_test.dart
git commit -m "feat(programme): add the sites editor"
```

---

### Task 4: ScheduleController

**Files:**
- Create: `lib/app/module/programme/controllers/schedule_controller.dart`
- Modify: `lib/app/module/programme/bindings/programme_binding.dart`
- Test: `test/presentation/modules/programme/controllers/schedule_controller_test.dart`

**Interfaces:**
- Consumes: `ProgrammeService`, `Competition`, `CompetitionProgramme`, `ProgrammeSite`, `RacePlacement`, `UiMessage`/`UiMessageError`, the planner (`competitionDays`, `allScheduleItems`, `nextFreeStart`, `overlaps`, `setPlacement`, `sameDay`, `ScheduleItem`)
- Produces:
  - `ScheduleController(ProgrammeService)` with: `Rxn<Competition> competition`, `RxList<DateTime> days`, `RxInt selectedDayIndex`, `Rxn<int> selectedSiteId`, `Rxn<UiMessage> message`; getters `List<ProgrammeSite> sites`, `DateTime? selectedDay`, `List<ScheduleItem> unscheduled`; `List<ScheduleItem> placedOn(int siteId, DateTime day)`; `void setCompetition(Competition? comp)`; `Future<void> place(int raceId, int siteId, DateTime day)`; `Future<void> setDuration(int raceId, int minutes)`; `Future<void> unschedule(int raceId)`

- [ ] **Step 1: Write the failing test**

Create `test/presentation/modules/programme/controllers/schedule_controller_test.dart`:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/programme_site.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/module/programme/controllers/schedule_controller.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';
import 'package:mocktail/mocktail.dart';

class _MockStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockStorage storage;
  late ProgrammeService service;
  late ScheduleController controller;

  setUpAll(() => registerFallbackValue(''));

  const competition = Competition(
    id: 42,
    name: 'Championnat',
    beginDate: null,
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

  CompetitionProgramme seed() => const CompetitionProgramme(
        competitionId: 42,
        sites: [ProgrammeSite(id: 1, name: 'Côtier 1', type: SiteType.cotier)],
        structures: [
          EventStructure(
            raceId: 100,
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
      );

  setUp(() async {
    storage = _MockStorage();
    when(() => storage.read(key: any(named: 'key')))
        .thenAnswer((_) async => null);
    when(() => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'))).thenAnswer((_) async {});
    service = ProgrammeService(storage);
    await service.save(seed());
    controller = ScheduleController(service);
  });

  test('setCompetition derives the day list and defaults the site', () {
    controller.setCompetition(withDates);
    expect(controller.days, [DateTime(2026, 6, 13), DateTime(2026, 6, 14)]);
    expect(controller.selectedSiteId.value, 1);
  });

  test('unscheduled lists races with no placement', () {
    controller.setCompetition(withDates);
    expect(controller.unscheduled.map((i) => i.raceId), [10, 11]);
  });

  test('place puts a race at the day start, then the next appends after it',
      () async {
    controller.setCompetition(withDates);
    final day = DateTime(2026, 6, 13);

    await controller.place(10, 1, day);
    await controller.place(11, 1, day);

    final placed = controller.placedOn(1, day);
    expect(placed.map((i) => i.raceId), [10, 11]);
    expect(placed[0].placement!.beginHour, DateTime(2026, 6, 13, 9));
    expect(placed[1].placement!.beginHour, DateTime(2026, 6, 13, 9, 10));
    expect(controller.unscheduled, isEmpty);
  });

  test('unschedule returns a race to the palette', () async {
    controller.setCompetition(withDates);
    final day = DateTime(2026, 6, 13);
    await controller.place(10, 1, day);

    await controller.unschedule(10);

    expect(controller.placedOn(1, day), isEmpty);
    expect(controller.unscheduled.map((i) => i.raceId), contains(10));
  });

  test('setDuration extending into the next race is rejected with a message',
      () async {
    controller.setCompetition(withDates);
    final day = DateTime(2026, 6, 13);
    await controller.place(10, 1, day); // 09:00-09:10
    await controller.place(11, 1, day); // 09:10-09:20

    await controller.setDuration(10, 20); // would run 09:00-09:20, overlapping 11

    // rejected: duration unchanged, error message set
    final r10 = controller.placedOn(1, day).firstWhere((i) => i.raceId == 10);
    expect(r10.placement!.durationMinutes, 10);
    expect(controller.message.value, isA<UiMessageError>());
  });

  test('setDuration with no conflict applies', () async {
    controller.setCompetition(withDates);
    final day = DateTime(2026, 6, 13);
    await controller.place(10, 1, day);

    await controller.setDuration(10, 15);

    final r10 = controller.placedOn(1, day).single;
    expect(r10.placement!.durationMinutes, 15);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/presentation/modules/programme/controllers/schedule_controller_test.dart
```

Expected: FAIL — `schedule_controller.dart` does not exist.

- [ ] **Step 3: Write the controller**

Create `lib/app/module/programme/controllers/schedule_controller.dart`:

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/programme_site.dart';
import 'package:live_ffss/app/domain/models/race_placement.dart';
import 'package:live_ffss/app/domain/models/schedule_planner.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';

class ScheduleController extends GetxController {
  ScheduleController(this._programme);

  final ProgrammeService _programme;

  final Rxn<Competition> competition = Rxn<Competition>();
  final RxList<DateTime> days = <DateTime>[].obs;
  final RxInt selectedDayIndex = 0.obs;
  final Rxn<int> selectedSiteId = Rxn<int>();
  final Rxn<UiMessage> message = Rxn<UiMessage>();

  Worker? _worker;

  @override
  void onInit() {
    super.onInit();
    // Default the selected site once sites exist / change.
    _worker = ever<CompetitionProgramme?>(_programme.current, (_) {
      if (selectedSiteId.value == null && sites.isNotEmpty) {
        selectedSiteId.value = sites.first.id;
      }
    });
  }

  @override
  void onClose() {
    _worker?.dispose();
    super.onClose();
  }

  CompetitionProgramme? get _p => _programme.current.value;

  List<ProgrammeSite> get sites => _p?.sites ?? const [];

  DateTime? get selectedDay =>
      days.isEmpty ? null : days[selectedDayIndex.value.clamp(0, days.length - 1)];

  /// Idempotent: recomputes the day list from the competition's dates and
  /// defaults the selected site. Safe to call on every rebuild.
  void setCompetition(Competition? comp) {
    if (comp == competition.value) return;
    competition.value = comp;
    days.value = competitionDays(comp?.beginDate, comp?.endDate);
    selectedDayIndex.value = 0;
    if (selectedSiteId.value == null && sites.isNotEmpty) {
      selectedSiteId.value = sites.first.id;
    }
  }

  List<ScheduleItem> get unscheduled {
    final p = _p;
    if (p == null) return const [];
    final items = allScheduleItems(p).where((i) => i.placement == null).toList()
      ..sort((a, b) {
        final byLabel = a.raceLabel.compareTo(b.raceLabel);
        if (byLabel != 0) return byLabel;
        return a.number.compareTo(b.number);
      });
    return items;
  }

  List<ScheduleItem> placedOn(int siteId, DateTime day) {
    final p = _p;
    if (p == null) return const [];
    final items = allScheduleItems(p)
        .where((i) =>
            i.placement != null &&
            i.placement!.siteId == siteId &&
            sameDay(i.placement!.beginHour, day))
        .toList()
      ..sort((a, b) => a.placement!.beginHour.compareTo(b.placement!.beginHour));
    return items;
  }

  Future<void> place(int raceId, int siteId, DateTime day) async {
    final p = _p;
    if (p == null) return;
    final existing = placedOn(siteId, day).map((i) => i.placement!).toList();
    final start = nextFreeStart(day: day, onSiteDay: existing);
    await _programme.save(setPlacement(
      p,
      raceId,
      RacePlacement(siteId: siteId, beginHour: start),
    ));
  }

  Future<void> setDuration(int raceId, int minutes) async {
    if (minutes < 1) return;
    final p = _p;
    if (p == null) return;
    RacePlacement? current;
    for (final i in allScheduleItems(p)) {
      if (i.raceId == raceId) {
        current = i.placement;
        break;
      }
    }
    if (current == null) return;
    final candidate = current.copyWith(durationMinutes: minutes);
    final others = placedOn(current.siteId, current.beginHour)
        .where((i) => i.raceId != raceId)
        .map((i) => i.placement!);
    if (overlaps(candidate: candidate, others: others)) {
      message.value = const UiMessageError('schedule_overlap');
      return;
    }
    await _programme.save(setPlacement(p, raceId, candidate));
  }

  Future<void> unschedule(int raceId) async {
    final p = _p;
    if (p == null) return;
    await _programme.save(setPlacement(p, raceId, null));
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/presentation/modules/programme/controllers/schedule_controller_test.dart
```

Expected: PASS — 6 tests.

- [ ] **Step 5: Register in the binding**

In `lib/app/module/programme/bindings/programme_binding.dart`, add:

```dart
import '../controllers/schedule_controller.dart';
```

and inside `dependencies()`:

```dart
    Get.lazyPut<ScheduleController>(
      () => ScheduleController(Get.find<ProgrammeService>()),
    );
```

- [ ] **Step 6: Verify analyze**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat analyze lib/app/module/programme/
```

Expected: `No issues found!`

- [ ] **Step 7: Commit**

```bash
git add lib/app/module/programme/controllers/schedule_controller.dart lib/app/module/programme/bindings/programme_binding.dart test/presentation/modules/programme/controllers/schedule_controller_test.dart
git commit -m "feat(programme): add the schedule controller"
```

---

### Task 5: Schedule view (3B) — replace the placeholder tab

**Files:**
- Create: `lib/app/module/programme/views/schedule_view.dart`
- Modify: `lib/app/module/programme/views/programme_view.dart`

No unit tests (views). Verified via `flutter run`.

**Interfaces:**
- Consumes: `ScheduleController` (Task 4), `ProgrammeController` (Plan A, for the competition), `SitesView` (Task 3), `RoundTypeFormatting.labelKey`, `RacePlacementFormatting.endHour`, `FormatConst`, shared widgets, theme.

- [ ] **Step 1: Write the schedule view**

Create `lib/app/module/programme/views/schedule_view.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/const/format_const.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/schedule_planner.dart';
import 'package:live_ffss/app/module/programme/controllers/programme_controller.dart';
import 'package:live_ffss/app/module/programme/controllers/schedule_controller.dart';
import 'package:live_ffss/app/module/programme/views/sites_view.dart';
import 'package:live_ffss/app/presentation/modules/programme/programme_formatting.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';

class ScheduleView extends StatefulWidget {
  const ScheduleView({super.key});

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  final _controller = Get.find<ScheduleController>();
  final _programme = Get.find<ProgrammeController>();
  Worker? _compWorker;
  Worker? _messageWorker;

  @override
  void initState() {
    super.initState();
    // Feed the loaded competition (and its dates) into the schedule controller,
    // now and whenever it changes.
    _compWorker = ever(_programme.competition, _controller.setCompetition);
    _controller.setCompetition(_programme.competition.value);
    _messageWorker = ever<UiMessage?>(_controller.message, (m) {
      if (m is UiMessageError && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(m.translationKey.tr)));
      }
    });
  }

  @override
  void dispose() {
    _compWorker?.dispose();
    _messageWorker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_controller.days.isEmpty) {
        return EmptyState(icon: Icons.event_busy, title: 'no_days'.tr);
      }
      return Column(
        children: [
          _DayBar(controller: _controller),
          Padding(
            padding: AppSpacing.pageHorizontal,
            child: Row(
              children: [
                Expanded(child: _SitePicker(controller: _controller)),
                IconButton(
                  icon: const Icon(Icons.settings),
                  tooltip: 'sites'.tr,
                  onPressed: () => Get.to<void>(() => const SitesView()),
                ),
              ],
            ),
          ),
          Expanded(child: _SiteTimeline(controller: _controller)),
          const Divider(height: 1),
          _UnscheduledPalette(controller: _controller),
        ],
      );
    });
  }
}

class _DayBar extends StatelessWidget {
  const _DayBar({required this.controller});
  final ScheduleController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Obx(() => ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: AppSpacing.pageHorizontal,
            itemCount: controller.days.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (_, i) {
              final active = controller.selectedDayIndex.value == i;
              final day = controller.days[i];
              return GestureDetector(
                onTap: () => controller.selectedDayIndex.value = i,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.surface,
                    borderRadius: AppRadius.pillRadius,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    FormatConst.dateFormat.format(day),
                    style: AppTypography.caption.copyWith(
                      color: active ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            },
          )),
    );
  }
}

class _SitePicker extends StatelessWidget {
  const _SitePicker({required this.controller});
  final ScheduleController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final sites = controller.sites;
      if (sites.isEmpty) {
        return Text('no_sites'.tr, style: AppTypography.caption);
      }
      return DropdownButton<int>(
        isExpanded: true,
        value: controller.selectedSiteId.value,
        items: [
          for (final s in sites)
            DropdownMenuItem(value: s.id, child: Text(s.name)),
        ],
        onChanged: (v) => controller.selectedSiteId.value = v,
      );
    });
  }
}

class _SiteTimeline extends StatelessWidget {
  const _SiteTimeline({required this.controller});
  final ScheduleController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final siteId = controller.selectedSiteId.value;
      final day = controller.selectedDay;
      if (siteId == null || day == null) {
        return EmptyState(icon: Icons.place_outlined, title: 'no_sites'.tr);
      }
      final placed = controller.placedOn(siteId, day);
      if (placed.isEmpty) {
        return EmptyState(
            icon: Icons.schedule, title: 'no_placement_here'.tr);
      }
      return ListView.separated(
        padding: AppSpacing.pageAll,
        itemCount: placed.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
        itemBuilder: (_, i) =>
            _PlacedCard(item: placed[i], controller: controller),
      );
    });
  }
}

class _PlacedCard extends StatelessWidget {
  const _PlacedCard({required this.item, required this.controller});
  final ScheduleItem item;
  final ScheduleController controller;

  @override
  Widget build(BuildContext context) {
    final p = item.placement!;
    final label =
        '${item.raceLabel} · ${item.categoryLabel} · ${item.roundType.labelKey.tr} ${item.number}';
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Text(FormatConst.timeFormat.format(p.beginHour),
            style: AppTypography.body),
        title: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
            '${FormatConst.timeFormat.format(p.beginHour)}–${FormatConst.timeFormat.format(p.endHour)} · ${p.durationMinutes} ${'min_short'.tr}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () =>
                  controller.setDuration(item.raceId, p.durationMinutes - 5),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () =>
                  controller.setDuration(item.raceId, p.durationMinutes + 5),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'unscheduled'.tr,
              onPressed: () => controller.unschedule(item.raceId),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnscheduledPalette extends StatelessWidget {
  const _UnscheduledPalette({required this.controller});
  final ScheduleController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.unscheduled;
      return Container(
        constraints: const BoxConstraints(maxHeight: 160),
        color: AppColors.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Text('${'unscheduled'.tr} (${items.length})',
                  style: AppTypography.caption),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final item = items[i];
                  final siteId = controller.selectedSiteId.value;
                  final day = controller.selectedDay;
                  return ListTile(
                    dense: true,
                    title: Text(
                      '${item.raceLabel} · ${item.categoryLabel} · ${item.roundType.labelKey.tr} ${item.number}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: TextButton(
                      onPressed: (siteId == null || day == null)
                          ? null
                          : () => controller.place(item.raceId, siteId, day),
                      child: Text('add_race'.tr),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
```

- [ ] **Step 2: Replace the placeholder in the shell**

In `lib/app/module/programme/views/programme_view.dart`:
- Add the import:
```dart
import 'package:live_ffss/app/module/programme/views/schedule_view.dart';
```
- In the `IndexedStack` children list, replace `_SchedulePlaceholder()` with `ScheduleView()` (the list is currently `const [StructureOverviewView(), _SchedulePlaceholder()]` — it becomes `const [StructureOverviewView(), ScheduleView()]`).
- Delete the now-unused `_SchedulePlaceholder` class at the bottom of the file.

- [ ] **Step 3: Verify analyze + full suite**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat analyze
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test
```

Expected: analyze fully clean; full suite passes.

- [ ] **Step 4: Verify on a device/emulator**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat run
```

Open a competition with dates → Programme → gear → add "Côtier 1" (côtier) and "Sable 1" (sable) → back to Programme tab → pick a day + Côtier 1 → tap "Ajouter une course" on an unscheduled race → it appears at 09:00; add another → 09:10 → +/- adjusts duration; extending one into the next shows the overlap snackbar → the × returns a race to the palette.

- [ ] **Step 5: Commit**

```bash
git add lib/app/module/programme/views/schedule_view.dart lib/app/module/programme/views/programme_view.dart
git commit -m "feat(programme): add the day/site scheduling view"
```

---

### Task 6: FFSS sync mapper (pure) — push deferred

The `CompetitionProgramme → List<Meeting>` materialiser that proves the lean model is 1:1 convertible to the FFSS tree. Pure and fully tested. The actual network push stays behind the stubbed seam until FFSS documents the créneau/course endpoints — this task does NOT make a network call.

**Files:**
- Create: `lib/app/data/mappers/programme_ffss_mapper.dart`
- Test: `test/data/mappers/programme_ffss_mapper_test.dart`

**Interfaces:**
- Consumes: `CompetitionProgramme`, `EventStructure`, `RoundLevel`, `ProgrammeRace`, `RacePlacement`, `RoundType`, `Meeting`, `Slot`, `Run`, `RunStatus`, `Heat`, `RaceFormatDetail`, the planner (`sameDay`, `placementEnd`)
- Produces: `List<Meeting> programmeToMeetings(CompetitionProgramme p, {required String competitionName})`

- [ ] **Step 1: Write the failing test**

Create `test/data/mappers/programme_ffss_mapper_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/mappers/programme_ffss_mapper.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/race_placement.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/domain/models/run.dart';

void main() {
  RacePlacement at(int h, int m, {int site = 1, int dur = 10}) => RacePlacement(
        siteId: site,
        beginHour: DateTime(2026, 6, 13, h, m),
        durationMinutes: dur,
      );

  CompetitionProgramme prog(List<ProgrammeRace> races) => CompetitionProgramme(
        competitionId: 42,
        structures: [
          EventStructure(
            raceId: 100,
            categoryId: 7,
            raceLabel: '100m',
            categoryLabel: 'Cadets',
            levels: [RoundLevel(type: RoundType.serie, races: races)],
          ),
        ],
      );

  test('unscheduled races produce no meetings', () {
    final meetings = programmeToMeetings(
      prog(const [ProgrammeRace(id: 1, number: 1)]),
      competitionName: 'Champ',
    );
    expect(meetings, isEmpty);
  });

  test('one placed race → one meeting, one slot, one run', () {
    final meetings = programmeToMeetings(
      prog([ProgrammeRace(id: 1, number: 1, placement: at(9, 0))]),
      competitionName: 'Champ',
    );
    expect(meetings.length, 1);
    expect(meetings.single.date, DateTime(2026, 6, 13));
    final slots = meetings.single.slots;
    expect(slots.length, 1);
    final runs = slots.single.runs;
    expect(runs.length, 1);
    expect(runs.single.beginTime, DateTime(2026, 6, 13, 9, 0));
    expect(runs.single.endTime, DateTime(2026, 6, 13, 9, 10));
    expect(runs.single.status, RunStatus.waiting);
  });

  test('two races of the same level+day group under one slot', () {
    final meetings = programmeToMeetings(
      prog([
        ProgrammeRace(id: 1, number: 1, placement: at(9, 0)),
        ProgrammeRace(id: 2, number: 2, placement: at(9, 10)),
      ]),
      competitionName: 'Champ',
    );
    expect(meetings.single.slots.length, 1);
    expect(meetings.single.slots.single.runs.length, 2);
  });

  test("the meeting spans its races' earliest begin to latest end", () {
    final meetings = programmeToMeetings(
      prog([
        ProgrammeRace(id: 1, number: 1, placement: at(9, 0)),
        ProgrammeRace(id: 2, number: 2, placement: at(9, 30, dur: 20)),
      ]),
      competitionName: 'Champ',
    );
    expect(meetings.single.beginHour, DateTime(2026, 6, 13, 9, 0));
    expect(meetings.single.endHour, DateTime(2026, 6, 13, 9, 50));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/data/mappers/programme_ffss_mapper_test.dart
```

Expected: FAIL — `programme_ffss_mapper.dart` does not exist.

- [ ] **Step 3: Write the mapper**

Create `lib/app/data/mappers/programme_ffss_mapper.dart`:

```dart
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/heat.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';
import 'package:live_ffss/app/domain/models/race_format_detail.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/domain/models/run.dart';
import 'package:live_ffss/app/domain/models/schedule_planner.dart';
import 'package:live_ffss/app/domain/models/slot.dart';

/// Materialises the lean authoring model into the FFSS `Meeting → Slot → Run`
/// tree — the shape FFSS expects on write. Pure and deterministic; the actual
/// network push waits on the FFSS créneau/course endpoints (see the stubbed
/// `ProgrammeRemoteDataSource`). Only scheduled races (with a placement)
/// appear: one Meeting per day, one Slot per (day × round-level), one Run per
/// race. Ids are the authoring local ids; the real sync will reconcile them.
List<Meeting> programmeToMeetings(
  CompetitionProgramme p, {
  required String competitionName,
}) {
  // Collect (structure, level, race, placement) for every scheduled race.
  final scheduled = <_Placed>[];
  for (final s in p.structures) {
    for (var li = 0; li < s.levels.length; li++) {
      final level = s.levels[li];
      for (final r in level.races) {
        final placement = r.placement;
        if (placement == null) continue;
        scheduled.add(_Placed(
          structureRaceId: s.raceId,
          structureLevelIndex: li,
          raceLabel: s.raceLabel,
          categoryLabel: s.categoryLabel,
          level: level,
          raceLocalId: r.id,
          raceNumber: r.number,
          begin: placement.beginHour,
          end: placementEnd(placement),
          site: placement.siteId,
        ));
      }
    }
  }
  if (scheduled.isEmpty) return const [];

  // Group by day.
  final days = <DateTime>[];
  for (final pl in scheduled) {
    final day = DateTime(pl.begin.year, pl.begin.month, pl.begin.day);
    if (!days.any((d) => sameDay(d, day))) days.add(day);
  }
  days.sort();

  final meetings = <Meeting>[];
  for (final day in days) {
    final ofDay = scheduled.where((pl) => sameDay(pl.begin, day)).toList();

    // Group the day's races by (structure raceId × level index) → one Slot.
    final slotKeys = <(int, int)>[];
    for (final pl in ofDay) {
      final key = (pl.structureRaceId, pl.structureLevelIndex);
      if (!slotKeys.contains(key)) slotKeys.add(key);
    }

    final slots = <Slot>[];
    for (final key in slotKeys) {
      final ofSlot = ofDay
          .where((pl) =>
              pl.structureRaceId == key.$1 &&
              pl.structureLevelIndex == key.$2)
          .toList()
        ..sort((a, b) => a.begin.compareTo(b.begin));
      final level = ofSlot.first.level;
      final runs = [
        for (final pl in ofSlot)
          Run(
            id: pl.raceLocalId,
            name: '${_roundName(level.type)} ${pl.raceNumber}',
            label: '${pl.raceLabel} · ${pl.categoryLabel}',
            fullLabel:
                '${pl.raceLabel} · ${pl.categoryLabel} · ${_roundName(level.type)} ${pl.raceNumber}',
            status: RunStatus.waiting,
            statusLabel: '',
            site: pl.site.toString(),
            beginTime: pl.begin,
            endTime: pl.end,
            heat: Heat(number: pl.raceNumber),
          ),
      ];
      slots.add(Slot(
        id: _slotId(key),
        name: '${ofSlot.first.raceLabel} · ${_roundName(level.type)}',
        beginHour: runs.first.beginTime,
        endHour: runs.map((r) => r.endTime).reduce((a, b) => a.isAfter(b) ? a : b),
        raceFormatDetail: RaceFormatDetail(
          id: _slotId(key),
          order: key.$2,
          label: _roundName(level.type),
          fullLabel: _roundName(level.type),
          levelLabel: '',
          level: _roundName(level.type),
          numberOfRun: ofSlot.length,
          qualificationMethod: '',
          qualificationMethodLabel: '',
          spotsPerRace: 0,
          qualifyingSpots: level.qualifiersPerRace,
        ),
        runs: runs,
      ));
    }

    final begin =
        ofDay.map((pl) => pl.begin).reduce((a, b) => a.isBefore(b) ? a : b);
    final end =
        ofDay.map((pl) => pl.end).reduce((a, b) => a.isAfter(b) ? a : b);
    meetings.add(Meeting(
      id: day.millisecondsSinceEpoch ~/ 1000,
      name: competitionName,
      description: '',
      date: day,
      beginHour: begin,
      endHour: end,
      slots: slots,
    ));
  }
  return meetings;
}

/// A non-localised round name for the FFSS labels (the FFSS side stores plain
/// strings; this is not shown in-app, so it is not translated).
String _roundName(RoundType type) => switch (type) {
      RoundType.serie => 'Series',
      RoundType.quart => 'Quarter',
      RoundType.demi => 'Semi',
      RoundType.finale => 'Final',
      RoundType.unknown => 'Round',
    };

int _slotId((int, int) key) => key.$1 * 100 + key.$2;

class _Placed {
  _Placed({
    required this.structureRaceId,
    required this.structureLevelIndex,
    required this.raceLabel,
    required this.categoryLabel,
    required this.level,
    required this.raceLocalId,
    required this.raceNumber,
    required this.begin,
    required this.end,
    required this.site,
  });

  final int structureRaceId;
  final int structureLevelIndex;
  final String raceLabel;
  final String categoryLabel;
  final RoundLevel level;
  final int raceLocalId;
  final int raceNumber;
  final DateTime begin;
  final DateTime end;
  final int site;
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/data/mappers/programme_ffss_mapper_test.dart
```

Expected: PASS — 4 tests.

- [ ] **Step 5: Verify analyze**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat analyze lib/app/data/mappers/programme_ffss_mapper.dart
```

Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add lib/app/data/mappers/programme_ffss_mapper.dart test/data/mappers/programme_ffss_mapper_test.dart
git commit -m "feat(programme): add the FFSS Meeting/Slot/Run sync mapper"
```

---

## Notes for the reviewer

- **Push stays deferred.** Task 6 builds the pure mapper only. `ProgrammeRemoteDataSourceImpl.pushProgramme` still throws `UnimplementedError` — wiring it to `programmeToMeetings` + `MeetingRepository.createMeeting` waits until FFSS documents the créneau/course write endpoints, because pushing meetings without their slots/runs would create orphan réunions on FFSS. The mapper is the ready artifact; the network wiring is the missing piece.
- **`nextFreeStart` appends after the last race**, it does not fill gaps. That is the "simple and fast" behaviour the spec asks for; a race unscheduled from the middle leaves a gap that the next append does not reclaim. Acceptable per spec.
- **Overlap is only enforced on `setDuration`** (and would be on any future manual time edit). `place` cannot overlap because it appends after the last end. There is no manual begin-time editing surface in this plan (deferred); if added later, route it through the same `overlaps` guard.
- **Site deletion clears placements** (`clearPlacementsForSite`) so no race points at a gone site — those races return to the unscheduled palette.
- **The schedule controller reads the competition via the view**, not `Get.find` in its own body: `ScheduleView.initState` wires `ProgrammeController.competition` into `ScheduleController.setCompetition` and disposes the worker. This keeps the controller-discipline rule intact.
- **Day overview grid (sites-as-columns):** the spec shows a `vue journée` toggle to a multi-site grid. This plan ships the per-site timeline (the fast input path) and the palette; the read-only multi-site grid is a presentation-only addition over the same `placedOn` data and is deferred to a fast-follow if the per-site view proves insufficient on a device. Flagged so it is a conscious omission, not an oversight.
