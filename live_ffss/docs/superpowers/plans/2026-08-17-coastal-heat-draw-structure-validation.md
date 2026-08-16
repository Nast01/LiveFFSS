# Coastal Heat Draw — Structure Validation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stop the coastal heat draw from silently rewriting the authored structure, by making the operator validate a heat plan — proposed from the athletes actually present — before the draw runs.

**Architecture:** `drawHeats` stops deriving the heat count and takes a validated `raceCount` instead. A new pure function `proposeHeatPlan` computes the `(raceCount, spotsPerRace)` a present count calls for. `HeatDrawController` exposes both the declared and the proposed plan; the view puts them in a dialog, and `save()` writes the chosen plan into the structure while stripping the wiring that a shrunk round leaves dangling.

**Tech Stack:** Flutter 3.41.9 / Dart 3.11.5, GetX (state + DI + routing), freezed for domain models (not needed here — plans are Dart records), `flutter_test` + `mocktail`.

**Spec:** [docs/superpowers/specs/2026-08-17-coastal-heat-draw-structure-validation-design.md](../specs/2026-08-17-coastal-heat-draw-structure-validation-design.md)

## Global Constraints

- Controllers hold **no** `Get.dialog`, `Get.snackbar`, `.tr`, `Get.context!`, or `BuildContext` parameter. Controllers store translation keys; views translate. Dialogs are opened by views.
- Constructor injection only. Never `Get.find()` inside a controller body.
- Catch `AppException` (the sealed type from `core/errors/`), never raw `Exception`.
- **No widget tests, no integration tests.** Task 5 is verified by `flutter analyze` plus a manual run.
- `flutter` and `dart` are on the user PATH — call them bare (`flutter test`, `flutter analyze`). If a shell reports `flutter: command not found`, it started before the PATH edit; prefix the command with `PATH="$PATH:/c/Users/nast0/dev/flutter_windows_3.22.2-stable/flutter/bin"` rather than switching to full `.bat` paths.
- Run `dart format` on every file touched before committing.
- Comments explain **why**, never what the next line does.
- Domain-model tests live in `test/data/models/` in this repo (that is where `heat_draw_test.dart` already sits) — follow the sibling, not the layer name.

---

### Task 1: The heat plan

A pure function, no dependencies, no reactivity. Everything later builds on it.

**Files:**
- Create: `lib/app/domain/models/heat_plan.dart`
- Test: `test/data/models/heat_plan_test.dart`

**Interfaces:**
- Consumes: nothing.
- Produces: `typedef HeatPlan = ({int raceCount, int spotsPerRace});` and
  `HeatPlan proposeHeatPlan({required int presentCount, required int maxSpotsPerRace})`.

- [ ] **Step 1: Write the failing test**

Create `test/data/models/heat_plan_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/heat_plan.dart';

void main() {
  group('proposeHeatPlan', () {
    test('no athlete present proposes no race', () {
      expect(
        proposeHeatPlan(presentCount: 0, maxSpotsPerRace: 16),
        (raceCount: 0, spotsPerRace: 0),
      );
    });

    test('an exact multiple of the capacity keeps that capacity', () {
      expect(
        proposeHeatPlan(presentCount: 32, maxSpotsPerRace: 16),
        (raceCount: 2, spotsPerRace: 16),
      );
    });

    test('tightens the spots onto what the draw will really produce', () {
      // 20 over a capacity of 16 runs 2 heats of 10, never 2 of 16.
      expect(
        proposeHeatPlan(presentCount: 20, maxSpotsPerRace: 16),
        (raceCount: 2, spotsPerRace: 10),
      );
    });

    test('rounds the spots up so the last heat absorbs the remainder', () {
      // 17 over 8 runs 3 heats of 6, 6 and 5.
      expect(
        proposeHeatPlan(presentCount: 17, maxSpotsPerRace: 8),
        (raceCount: 3, spotsPerRace: 6),
      );
    });

    test('a field smaller than the capacity runs a single heat', () {
      expect(
        proposeHeatPlan(presentCount: 5, maxSpotsPerRace: 16),
        (raceCount: 1, spotsPerRace: 5),
      );
    });

    test('an unauthored capacity seats everyone in one heat', () {
      expect(
        proposeHeatPlan(presentCount: 5, maxSpotsPerRace: 0),
        (raceCount: 1, spotsPerRace: 5),
      );
    });
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/data/models/heat_plan_test.dart`

Expected: FAIL at compile — `Error: Couldn't resolve the package 'live_ffss/app/domain/models/heat_plan.dart'` or `proposeHeatPlan isn't defined`. If it fails for any other reason, fix that before continuing.

- [ ] **Step 3: Write the minimal implementation**

Create `lib/app/domain/models/heat_plan.dart`:

```dart
/// How many races a round runs, and how many athletes each one seats.
typedef HeatPlan = ({int raceCount, int spotsPerRace});

/// The plan [presentCount] athletes call for, given the water's capacity.
///
/// Lane count is a physical constraint of the course, so [maxSpotsPerRace] is a
/// ceiling rather than a target: the proposal runs the fewest heats that keep
/// every heat within it, then tightens the seats onto what the draw will really
/// produce. 20 athletes over a capacity of 16 run 2 heats of 10 — a structure
/// claiming 2 of 16 would describe a draw that never happens, and the operator
/// is being asked to validate that structure.
HeatPlan proposeHeatPlan({
  required int presentCount,
  required int maxSpotsPerRace,
}) {
  if (presentCount <= 0) return (raceCount: 0, spotsPerRace: 0);
  // An unauthored round declares no capacity; seat everyone rather than
  // dividing by zero.
  if (maxSpotsPerRace <= 0) return (raceCount: 1, spotsPerRace: presentCount);
  final raceCount = (presentCount / maxSpotsPerRace).ceil();
  return (
    raceCount: raceCount,
    spotsPerRace: (presentCount / raceCount).ceil(),
  );
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/data/models/heat_plan_test.dart`

Expected: PASS, 6 tests, no warnings.

- [ ] **Step 5: Format, analyze and commit**

```bash
dart format lib/app/domain/models/heat_plan.dart test/data/models/heat_plan_test.dart
flutter analyze lib/app/domain/models/heat_plan.dart
git add lib/app/domain/models/heat_plan.dart test/data/models/heat_plan_test.dart
git commit -m "feat(draw): propose a heat plan from the athletes present"
```

---

### Task 2: The draw stops deciding the heat count

`drawHeats` currently computes `ceil(present / spotsPerRace)`. That is the line that lets the draw overrule the structure. It moves out; the caller passes a count.

**Files:**
- Modify: `lib/app/domain/models/heat_draw.dart:16-43`
- Modify: `lib/app/module/competitions/controllers/heat_draw_controller.dart:159-169` (call site, so the app still compiles)
- Test: `test/data/models/heat_draw_test.dart`

**Interfaces:**
- Consumes: `proposeHeatPlan` from Task 1.
- Produces: `List<List<Athlete>> drawHeats({required List<Athlete> present, required int raceCount, required Random random})`.

- [ ] **Step 1: Rewrite the failing tests**

In `test/data/models/heat_draw_test.dart`, replace the `draw` helper and the whole `drawHeats sizing` group. Leave the `club balancing` and `randomness` groups' bodies alone except for the argument rename shown in Step 2.

Replace lines 25-34 (the helper):

```dart
  List<List<Athlete>> draw(
    List<Athlete> present, {
    int raceCount = 1,
    int seed = 1,
  }) =>
      drawHeats(
        present: present,
        raceCount: raceCount,
        random: Random(seed),
      );
```

Replace the whole `group('drawHeats sizing', ...)` block:

```dart
  group('drawHeats sizing', () {
    test('draws exactly the number of heats it is given', () {
      expect(draw(athletes(20), raceCount: 3), hasLength(3));
      expect(draw(athletes(20), raceCount: 5), hasLength(5));
    });

    test('balances the heats rather than filling them to the brim', () {
      // 17 over 3 heats gives 6/6/5, not 8/8/1.
      final sizes = draw(athletes(17), raceCount: 3).map((h) => h.length).toList()
        ..sort();
      expect(sizes, [5, 6, 6]);
    });

    test('heat sizes never differ by more than one', () {
      for (var count = 1; count <= 40; count++) {
        final sizes = draw(athletes(count), raceCount: (count / 8).ceil())
            .map((h) => h.length)
            .toList();
        expect(sizes.reduce(max) - sizes.reduce(min), lessThanOrEqualTo(1),
            reason: 'unbalanced for $count athletes');
      }
    });

    test('places every athlete exactly once', () {
      final drawn =
          draw(athletes(23), raceCount: 3).expand((h) => h).map((a) => a.id);

      expect(drawn.toSet(), hasLength(23));
      expect(drawn, hasLength(23));
    });

    test('no athlete present yields no heat', () {
      expect(draw(const [], raceCount: 3), isEmpty);
    });

    test('a field smaller than one heat still fills a single heat', () {
      expect(draw(athletes(3), raceCount: 1).single, hasLength(3));
    });

    test('a non-positive race count yields no heat', () {
      expect(draw(athletes(5), raceCount: 0), isEmpty);
    });
  });
```

In the `club balancing` group, rename the arguments — same fields, same expectations:

- `draw(present, spotsPerRace: 8)` → `draw(present, raceCount: 3)` (24 athletes, 4 clubs of 6)
- `draw(present, spotsPerRace: 5)` → `draw(present, raceCount: 2)` (one club of 10)
- `draw(athletes(12), spotsPerRace: 4)` → `draw(athletes(12), raceCount: 3)`
- `draw(present, spotsPerRace: 4)` → `draw(present, raceCount: 3)` (11 mixed athletes)

In the `randomness` group, both `draw(present, seed: N)` calls become `draw(present, raceCount: 3, seed: N)` (20 athletes).

- [ ] **Step 2: Run the tests to verify they fail**

Run: `flutter test test/data/models/heat_draw_test.dart`

Expected: FAIL at compile — `No named parameter with the name 'raceCount'`.

- [ ] **Step 3: Change `drawHeats`**

In `lib/app/domain/models/heat_draw.dart`, replace the doc comment's second paragraph and the signature/prologue:

```dart
/// Draws the athletes marked present into [raceCount] heats, in lane order —
/// the index of an athlete within a heat IS their lane, coastal lanes being
/// sequential.
///
/// The heat count is given, not derived: it comes from a plan the operator has
/// validated (see `proposeHeatPlan`), so the draw can no longer overrule the
/// authored structure. Heats come out *balanced*, not filled to the brim: 17
/// athletes over 3 heats give 6/6/5 rather than 8/8/1, which is the coastal
/// practice. Clubmates are spread as evenly as the numbers allow, so a club of
/// 6 over 3 heats lands 2 per heat.
///
/// [random] is injected rather than created here so a draw can be reproduced in
/// tests. In the app it is seeded from the clock, and a redraw deliberately
/// yields a different result.
List<List<Athlete>> drawHeats({
  required List<Athlete> present,
  required int raceCount,
  required Random random,
}) {
  if (present.isEmpty || raceCount <= 0) return const [];

  final heats = List.generate(raceCount, (_) => <Athlete>[]);
  final clubTally = List.generate(raceCount, (_) => <int, int>{});
```

Delete the two now-dead lines that computed `spots` and `heatCount`. Everything from `for (final group in _clubGroups(...))` onward is unchanged.

- [ ] **Step 4: Fix the call site so the app compiles**

In `lib/app/module/competitions/controllers/heat_draw_controller.dart`, add the import:

```dart
import 'package:live_ffss/app/domain/models/heat_plan.dart';
```

and replace the body of `drawFromPresent`:

```dart
  void drawFromPresent() {
    if (presentAthletes.isEmpty) {
      message.value = const UiMessageError('heat_draw_no_present');
      return;
    }
    heats.value = drawHeats(
      present: presentAthletes.toList(),
      raceCount: proposeHeatPlan(
        presentCount: presentCount,
        maxSpotsPerRace: spotsPerRace,
      ).raceCount,
      random: _random,
    );
  }
```

This is behaviour-preserving: `proposeHeatPlan`'s `raceCount` is the same `ceil(present / spots)` the function used to compute internally. Task 3 replaces this method properly.

- [ ] **Step 5: Run the tests to verify they pass**

Run: `flutter test test/data/models/heat_draw_test.dart test/presentation/modules/competitions/controllers/heat_draw_controller_test.dart`

Expected: PASS. The controller suite must stay green untouched — that is the proof this step changed no behaviour.

- [ ] **Step 6: Format, analyze and commit**

```bash
dart format lib/app/domain/models/heat_draw.dart lib/app/module/competitions/controllers/heat_draw_controller.dart test/data/models/heat_draw_test.dart
flutter analyze lib/app/domain/models lib/app/module/competitions
git add lib/app/domain/models/heat_draw.dart lib/app/module/competitions/controllers/heat_draw_controller.dart test/data/models/heat_draw_test.dart
git commit -m "refactor(draw): take the heat count instead of deriving it"
```

---

### Task 3: The controller exposes both plans

**Files:**
- Modify: `lib/app/module/competitions/controllers/heat_draw_controller.dart`
- Test: `test/presentation/modules/competitions/controllers/heat_draw_controller_test.dart`

**Interfaces:**
- Consumes: `HeatPlan`, `proposeHeatPlan` (Task 1); `drawHeats(..., raceCount:, ...)` (Task 2).
- Produces, on `HeatDrawController`:
  - `bool get requiresStructureValidation`
  - `HeatPlan get declaredPlan`
  - `HeatPlan get proposedPlan`
  - `final Rxn<HeatPlan> pendingPlan`
  - `void drawWithPlan(HeatPlan plan)`

- [ ] **Step 1: Write the failing tests**

First make the test's race helper able to build a pool race. Replace `makeRace()` in `test/presentation/modules/competitions/controllers/heat_draw_controller_test.dart` (currently lines 91-103) with:

```dart
  Race makeRace({String speciality = 'Côtier'}) => Race(
        id: raceId,
        name: 'Race',
        nameEnglish: 'Race',
        distance: 100,
        gender: Gender.female,
        athletesPerTeam: 1,
        specialityId: 1,
        specialityLabel: speciality,
        disciplineId: 1,
        isEligibleToNationalRecord: false,
        categories: const [],
      );
```

Then append this group at the end of `main()`:

```dart
  group('HeatDrawController structure validation', () {
    /// Loads a controller whose category has [present] athletes checked in.
    Future<HeatDrawController> withPresent(
      int present, {
      String speciality = 'Côtier',
      List<RoundLevel> levels = const [
        RoundLevel(type: RoundType.serie, spotsPerRace: 16),
        RoundLevel(type: RoundType.finale, spotsPerRace: 16),
      ],
    }) async {
      programme = _FakeProgrammeService(programmeWith(levels: levels));
      final all = [for (var i = 1; i <= present; i++) athlete(i)];
      when(() => raceRepo.getEntries(raceId))
          .thenAnswer((_) async => [entry(1, all)]);
      when(() => attendance.forRace(raceId)).thenReturn({
        for (final a in all) a.id: AttendanceStatus.present,
      });
      final controller = HeatDrawController(
        raceRepo,
        attendance,
        programme,
        random: Random(7),
      )
        ..race.value = makeRace(speciality: speciality)
        ..competition.value = makeCompetition()
        ..categoryId = categoryId
        ..categoryLabel = 'Senior';
      await controller.load();
      return controller;
    }

    test('a coastal série must be validated', () async {
      final controller = await withPresent(20);

      expect(controller.selectedLevel.value, RoundType.serie);
      expect(controller.requiresStructureValidation, isTrue);
    });

    test('a pool série is drawn without validation', () async {
      final controller = await withPresent(20, speciality: 'Eau-plate');

      expect(controller.requiresStructureValidation, isFalse);
    });

    test('a coastal finale is drawn without validation', () async {
      final controller = await withPresent(20);
      controller.selectLevel(RoundType.finale);

      expect(controller.requiresStructureValidation, isFalse);
    });

    test('declaredPlan reads the round as authored', () async {
      final controller = await withPresent(20, levels: const [
        RoundLevel(type: RoundType.serie, spotsPerRace: 16, races: [
          ProgrammeRace(id: 1, number: 1),
          ProgrammeRace(id: 2, number: 2),
          ProgrammeRace(id: 3, number: 3),
        ]),
      ]);

      expect(controller.declaredPlan, (raceCount: 3, spotsPerRace: 16));
    });

    test('proposedPlan tightens the round onto the athletes present', () async {
      final controller = await withPresent(20, levels: const [
        RoundLevel(type: RoundType.serie, spotsPerRace: 16, races: [
          ProgrammeRace(id: 1, number: 1),
          ProgrammeRace(id: 2, number: 2),
          ProgrammeRace(id: 3, number: 3),
        ]),
      ]);

      expect(controller.proposedPlan, (raceCount: 2, spotsPerRace: 10));
    });

    test('drawWithPlan draws exactly the plan it is given', () async {
      final controller = await withPresent(20);

      controller.drawWithPlan((raceCount: 4, spotsPerRace: 5));

      expect(controller.heats, hasLength(4));
      expect(controller.heats.expand((h) => h), hasLength(20));
      expect(controller.pendingPlan.value, (raceCount: 4, spotsPerRace: 5));
    });

    test('drawWithPlan reports when nobody is present', () async {
      final controller = await withPresent(0);

      controller.drawWithPlan((raceCount: 2, spotsPerRace: 8));

      expect(controller.heats, isEmpty);
      expect(controller.pendingPlan.value, isNull);
      expect(controller.message.value, isA<UiMessageError>());
    });

    test('changing round drops the plan the heats were drawn with', () async {
      final controller = await withPresent(20);
      controller.drawWithPlan((raceCount: 2, spotsPerRace: 10));

      controller.selectLevel(RoundType.finale);

      expect(controller.heats, isEmpty);
      expect(controller.pendingPlan.value, isNull);
    });
  });
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `flutter test test/presentation/modules/competitions/controllers/heat_draw_controller_test.dart`

Expected: FAIL at compile — `The getter 'requiresStructureValidation' isn't defined`, plus the same for `declaredPlan`, `proposedPlan`, `pendingPlan`, `drawWithPlan`.

- [ ] **Step 3: Implement on the controller**

Add the import (this presentation extension is already imported by `StructureEditorController`, so the precedent for reading `isBeach` from a controller is established):

```dart
import 'package:live_ffss/app/presentation/modules/competitions/race_formatting.dart';
```

Add the field next to the other `Rx` members:

```dart
  /// The plan the heats on screen were drawn with. Null until a draw has run;
  /// [save] writes it back into the structure.
  final Rxn<HeatPlan> pendingPlan = Rxn<HeatPlan>();
```

Add the three getters after `hasExistingComposition`:

```dart
  /// Whether the operator must validate the structure before this draw runs.
  /// Coastal séries only: a pool draw keeps the direct path, and a bracket
  /// round is seated by its qualifiers rather than by who is on the beach.
  bool get requiresStructureValidation =>
      (race.value?.isBeach ?? false) && selectedLevel.value == RoundType.serie;

  /// The selected round exactly as authored.
  HeatPlan get declaredPlan => (
        raceCount: _levelOf(selectedLevel.value)?.races.length ?? 0,
        spotsPerRace: spotsPerRace,
      );

  /// What the athletes actually present call for, capped by the authored
  /// race size — the water's capacity does not change because people are late.
  HeatPlan get proposedPlan => proposeHeatPlan(
        presentCount: presentCount,
        maxSpotsPerRace: declaredPlan.spotsPerRace,
      );
```

Replace `drawFromPresent` (the temporary version from Task 2) with:

```dart
  /// Draws without validation, for the rounds that need none. Honours the
  /// authored race count when there is one, and falls back to the proposal for
  /// a round that declares no race yet.
  void drawFromPresent() =>
      drawWithPlan(declaredPlan.raceCount > 0 ? declaredPlan : proposedPlan);

  void drawWithPlan(HeatPlan plan) {
    if (presentAthletes.isEmpty) {
      message.value = const UiMessageError('heat_draw_no_present');
      return;
    }
    pendingPlan.value = plan;
    heats.value = drawHeats(
      present: presentAthletes.toList(),
      raceCount: plan.raceCount,
      random: _random,
    );
  }
```

In `selectLevel`, clear the plan alongside the heats:

```dart
  void selectLevel(RoundType type) {
    if (selectedLevel.value == type) return;
    selectedLevel.value = type;
    // The heat count depends on the level's own composition, so a previous
    // draw — and the plan it was drawn with — mean nothing here.
    heats.clear();
    pendingPlan.value = null;
  }
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `flutter test test/presentation/modules/competitions/controllers/heat_draw_controller_test.dart`

Expected: PASS, including the pre-existing groups.

- [ ] **Step 5: Format, analyze and commit**

```bash
dart format lib/app/module/competitions/controllers/heat_draw_controller.dart test/presentation/modules/competitions/controllers/heat_draw_controller_test.dart
flutter analyze lib/app/module/competitions
git add lib/app/module/competitions/controllers/heat_draw_controller.dart test/presentation/modules/competitions/controllers/heat_draw_controller_test.dart
git commit -m "feat(draw): expose the declared and proposed heat plans"
```

---

### Task 4: Saving writes the plan and repairs the wiring

**Files:**
- Modify: `lib/app/module/competitions/controllers/heat_draw_controller.dart:209-233` (`_levelsWithDraw`, `_racesForDraw`)
- Test: `test/presentation/modules/competitions/controllers/heat_draw_controller_test.dart`

**Interfaces:**
- Consumes: `pendingPlan` (Task 3).
- Produces: no new public API — `save()` keeps its signature and gains the two behaviours.

- [ ] **Step 1: Write the failing tests**

Append to the `HeatDrawController structure validation` group created in Task 3 (the `withPresent` helper is in scope):

```dart
    test('save writes the validated race size onto the round', () async {
      final controller = await withPresent(20, levels: const [
        RoundLevel(type: RoundType.serie, spotsPerRace: 16, races: [
          ProgrammeRace(id: 1, number: 1),
          ProgrammeRace(id: 2, number: 2),
          ProgrammeRace(id: 3, number: 3),
        ]),
      ]);
      controller.drawWithPlan(controller.proposedPlan);

      await controller.save();

      final level = programme.current.value!.structures.single.levels.single;
      expect(level.races, hasLength(2));
      expect(level.spotsPerRace, 10);
    });

    test('save strips the wiring of a race the shrink removed', () async {
      final controller = await withPresent(20, levels: const [
        RoundLevel(type: RoundType.serie, spotsPerRace: 16, races: [
          ProgrammeRace(id: 1, number: 1),
          ProgrammeRace(id: 2, number: 2),
          ProgrammeRace(id: 3, number: 3),
        ]),
        RoundLevel(type: RoundType.finale, spotsPerRace: 16, races: [
          ProgrammeRace(id: 4, number: 1, sourceRaceIds: [1, 2, 3]),
        ]),
      ]);
      controller.drawWithPlan(controller.proposedPlan);

      await controller.save();

      final levels = programme.current.value!.structures.single.levels;
      // Série 3 is gone, so the finale may no longer claim it as a source.
      expect(levels.first.races, hasLength(2));
      expect(levels.last.races.single.sourceRaceIds, [1, 2]);
    });

    test('save leaves the wiring alone when no race is removed', () async {
      final controller = await withPresent(32, levels: const [
        RoundLevel(type: RoundType.serie, spotsPerRace: 16, races: [
          ProgrammeRace(id: 1, number: 1),
          ProgrammeRace(id: 2, number: 2),
        ]),
        RoundLevel(type: RoundType.finale, spotsPerRace: 16, races: [
          ProgrammeRace(id: 4, number: 1, sourceRaceIds: [1, 2]),
        ]),
      ]);
      controller.drawWithPlan(controller.proposedPlan);

      await controller.save();

      final levels = programme.current.value!.structures.single.levels;
      expect(levels.first.races, hasLength(2));
      expect(levels.last.races.single.sourceRaceIds, [1, 2]);
    });
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `flutter test test/presentation/modules/competitions/controllers/heat_draw_controller_test.dart --plain-name "save"`

Expected: FAIL — `Expected: <10> Actual: <16>` on the first (the round keeps its authored size), and `Expected: [1, 2] Actual: [1, 2, 3]` on the second (the dangling id survives).

- [ ] **Step 3: Rewrite `_levelsWithDraw`**

Replace the whole `_levelsWithDraw` method in `lib/app/module/competitions/controllers/heat_draw_controller.dart`:

```dart
  List<RoundLevel> _levelsWithDraw(List<RoundLevel> levels, RoundType type) {
    final drawnAt = levels.indexWhere((l) => l.type == type);
    if (drawnAt < 0) return levels;

    final updated = [...levels];
    final drawn = updated[drawnAt];
    updated[drawnAt] = drawn.copyWith(
      races: _racesForDraw(drawn.races),
      spotsPerRace: pendingPlan.value?.spotsPerRace ?? drawn.spotsPerRace,
    );

    final removed = {for (final r in drawn.races) r.id}
        .difference({for (final r in updated[drawnAt].races) r.id});
    if (removed.isEmpty) return updated;

    // A shrunk round deletes races the later ones may still list as their
    // source. Leaving those ids behind would have the operator validate a
    // structure whose bracket is quietly broken.
    for (var i = drawnAt + 1; i < updated.length; i++) {
      updated[i] = updated[i].copyWith(
        races: [
          for (final race in updated[i].races)
            race.copyWith(
              sourceRaceIds: [
                for (final id in race.sourceRaceIds)
                  if (!removed.contains(id)) id,
              ],
            ),
        ],
      );
    }
    return updated;
  }
```

`_racesForDraw` is unchanged — it already reuses existing races in order, which is what preserves the wiring of the ones that survive.

- [ ] **Step 4: Run the tests to verify they pass**

Run: `flutter test test/presentation/modules/competitions/controllers/heat_draw_controller_test.dart`

Expected: PASS, whole file.

- [ ] **Step 5: Format, analyze and commit**

```bash
dart format lib/app/module/competitions/controllers/heat_draw_controller.dart test/presentation/modules/competitions/controllers/heat_draw_controller_test.dart
flutter analyze lib/app/module/competitions
git add lib/app/module/competitions/controllers/heat_draw_controller.dart test/presentation/modules/competitions/controllers/heat_draw_controller_test.dart
git commit -m "fix(draw): repair the wiring a shrunk round leaves dangling"
```

---

### Task 5: The validation dialog

No automated test — this repo does not widget-test. Verification is `flutter analyze`, the full suite staying green, and a manual run.

**Files:**
- Create: `lib/app/module/competitions/views/heat_structure_dialog.dart`
- Modify: `lib/app/module/competitions/views/heat_draw_view.dart`
- Modify: `lib/app/core/translations/fr_FR.dart`, `lib/app/core/translations/en_US.dart`

**Interfaces:**
- Consumes: `HeatPlan` (Task 1); `requiresStructureValidation`, `declaredPlan`, `proposedPlan`, `drawWithPlan` (Task 3).
- Produces: `typedef HeatStructureResult = ({HeatPlan? plan, bool editStructure});` and `class HeatStructureDialog extends StatefulWidget`.

- [ ] **Step 1: Add the translations**

In `lib/app/core/translations/fr_FR.dart`, after `'heat_draw_overwrite_body'`:

```dart
  'heat_draw_structure_title': 'Vérifier la structure',
  'heat_draw_structure_proposed': 'Recalculée sur les présents',
  'heat_draw_structure_declared': 'Structure déclarée',
  'heat_draw_structure_plan': '@races série(s) × @spots places',
  'heat_draw_structure_edit': 'Modifier la structure',
```

In `lib/app/core/translations/en_US.dart`, at the matching place:

```dart
  'heat_draw_structure_title': 'Check the structure',
  'heat_draw_structure_proposed': 'Recomputed from those present',
  'heat_draw_structure_declared': 'Structure as declared',
  'heat_draw_structure_plan': '@races heat(s) × @spots spots',
  'heat_draw_structure_edit': 'Edit the structure',
```

- [ ] **Step 2: Write the dialog**

Create `lib/app/module/competitions/views/heat_structure_dialog.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/heat_plan.dart';

/// What the operator decided. [plan] is the structure to draw with; when
/// [editStructure] is true they asked for the editor instead and the caller
/// reopens this dialog on the way back. A null result means cancelled.
typedef HeatStructureResult = ({HeatPlan? plan, bool editStructure});

/// Confirms the structure before a coastal série is drawn. Presented even when
/// the two plans agree: the operator is validating the structure, not being
/// warned about a mismatch.
class HeatStructureDialog extends StatefulWidget {
  const HeatStructureDialog({
    super.key,
    required this.presentCount,
    required this.engagedCount,
    required this.declared,
    required this.proposed,
  });

  final int presentCount;
  final int engagedCount;
  final HeatPlan declared;
  final HeatPlan proposed;

  @override
  State<HeatStructureDialog> createState() => _HeatStructureDialogState();
}

class _HeatStructureDialogState extends State<HeatStructureDialog> {
  // The recomputed plan is preselected: athletes failing to show up is the
  // ordinary case, and it leaves the declared structure one tap away.
  late HeatPlan _selected = widget.proposed;

  String _label(HeatPlan plan) => 'heat_draw_structure_plan'.trParams({
        'races': '${plan.raceCount}',
        'spots': '${plan.spotsPerRace}',
      });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('heat_draw_structure_title'.tr),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'heat_draw_presence'.trParams({
              'present': '${widget.presentCount}',
              'engaged': '${widget.engagedCount}',
            }),
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.sm),
          RadioListTile<int>(
            value: 0,
            groupValue: _selected == widget.proposed ? 0 : 1,
            contentPadding: EdgeInsets.zero,
            title: Text('heat_draw_structure_proposed'.tr),
            subtitle: Text(_label(widget.proposed)),
            onChanged: (_) => setState(() => _selected = widget.proposed),
          ),
          RadioListTile<int>(
            value: 1,
            groupValue: _selected == widget.proposed ? 0 : 1,
            contentPadding: EdgeInsets.zero,
            title: Text('heat_draw_structure_declared'.tr),
            subtitle: Text(_label(widget.declared)),
            onChanged: (_) => setState(() => _selected = widget.declared),
          ),
          TextButton.icon(
            icon: const Icon(Icons.open_in_new, size: 18),
            label: Text('heat_draw_structure_edit'.tr),
            onPressed: () => Navigator.of(context).pop<HeatStructureResult>(
              (plan: null, editStructure: true),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('cancel'.tr),
        ),
        TextButton(
          onPressed: _selected.raceCount <= 0
              ? null
              : () => Navigator.of(context).pop<HeatStructureResult>(
                    (plan: _selected, editStructure: false),
                  ),
          child: Text('confirm'.tr),
        ),
      ],
    );
  }
}
```

- [ ] **Step 3: Wire it into the draw action**

In `lib/app/module/competitions/views/heat_draw_view.dart`, add the imports:

```dart
import 'package:live_ffss/app/module/competitions/views/heat_structure_dialog.dart';
import 'package:live_ffss/app/module/programme/controllers/structure_editor_controller.dart';
import 'package:live_ffss/app/presentation/modules/competitions/race_formatting.dart';
import 'package:live_ffss/app/routes/app_pages.dart';
```

Add to `_HeatDrawViewState`, next to `_save`:

```dart
  /// Coastal séries go through a structure check first; everything else draws
  /// straight away. The loop is what lets "Modifier la structure" come back to
  /// the dialog with the numbers the editor just changed.
  Future<void> _draw() async {
    if (!_ctrl.requiresStructureValidation) {
      _ctrl.drawFromPresent();
      return;
    }
    while (mounted) {
      final result = await showDialog<HeatStructureResult>(
        context: context,
        builder: (_) => HeatStructureDialog(
          presentCount: _ctrl.presentCount,
          engagedCount: _ctrl.engagedCount.value,
          declared: _ctrl.declaredPlan,
          proposed: _ctrl.proposedPlan,
        ),
      );
      if (result == null) return;
      if (result.plan != null) {
        _ctrl.drawWithPlan(result.plan!);
        return;
      }
      await _openStructureEditor();
      await _ctrl.load();
    }
  }

  Future<void> _openStructureEditor() async {
    final race = _ctrl.race.value;
    final competition = _ctrl.competition.value;
    if (race == null || competition == null) return;
    await Get.toNamed<void>(
      Routes.structureEditor,
      // serverDetails stays empty on purpose: the structure exists by the time
      // this dialog opens, so seeding cannot fire, and re-importing the FFSS
      // parties is not worth a network call from the beach.
      arguments: StructureEditorArgs(
        competitionId: competition.id,
        raceId: race.id,
        categoryId: _ctrl.categoryId,
        raceLabel: race.name,
        categoryLabel: _ctrl.categoryLabel,
        entryCount: _ctrl.engagedCount.value,
        gender: race.gender,
        defaultSpotsPerRace: race.defaultSpotsPerRace,
      ),
    );
  }
```

In `_Actions`, the draw button must call the new handler. Change the widget to take it:

```dart
class _Actions extends GetView<HeatDrawController> {
  const _Actions({required this.onDraw, required this.onSave});

  final Future<void> Function() onDraw;
  final Future<void> Function() onSave;
```

and its first button's `onPressed: controller.drawFromPresent` becomes `onPressed: onDraw`. At the call site in `build`, `_Actions(onSave: _save)` becomes `_Actions(onDraw: _draw, onSave: _save)`.

- [ ] **Step 4: Verify it compiles and nothing regressed**

```bash
dart format lib/app/module/competitions/views/heat_structure_dialog.dart lib/app/module/competitions/views/heat_draw_view.dart lib/app/core/translations/fr_FR.dart lib/app/core/translations/en_US.dart
flutter analyze lib/app/module/competitions lib/app/core/translations
flutter test
```

Expected: analyze clean apart from the two pre-existing `file_names` infos on `fr_FR.dart` / `en_US.dart`; the whole suite green.

- [ ] **Step 5: Verify manually**

Run `flutter run`, open a **coastal** race → Engagés, mark some athletes present, then Séries → Générer les séries → the draw button. Check that:

1. the dialog opens and shows présents/engagés and both plans;
2. the recomputed plan is preselected;
3. Confirmer draws exactly that many heats;
4. "Modifier la structure" opens the editor and returns to a dialog showing the edited numbers;
5. Annuler leaves the screen untouched;
6. Enregistrer then reopening the round shows the new race count and race size;
7. a **pool** race still draws with no dialog at all.

- [ ] **Step 6: Commit**

```bash
git add lib/app/module/competitions/views/heat_structure_dialog.dart lib/app/module/competitions/views/heat_draw_view.dart lib/app/core/translations/fr_FR.dart lib/app/core/translations/en_US.dart
git commit -m "feat(draw): validate the structure before a coastal série is drawn"
```

---

## Notes for the executor

- `_racesForDraw` still numbers races `1..n` and reuses the existing ones in order. Do not "improve" it to match races by id — reusing by position is what keeps the surviving wiring attached to the right race.
- `HeatPlan` is a Dart record, not a freezed class. No `build_runner` run is needed anywhere in this plan.
- If `flutter analyze` complains about importing `race_formatting.dart` from a controller, do not add an ignore: `StructureEditorController` already does exactly this (line 15), so it is an accepted pattern here.
- `HeatPlan` is a record, so two plans with the same numbers are `==`. When the declared and proposed structures agree, both radio rows describe the same thing and the first stays selected. That is correct — there is nothing to choose between — so do not add a tie-breaker.
- `RadioListTile.groupValue` / `onChanged` are deprecated on recent Flutter in favour of a `RadioGroup` ancestor. If `flutter analyze` reports deprecation *infos* (not errors), leave the code as written — the rest of this codebase has not migrated. If it reports errors, wrap the two tiles in a `RadioGroup<int>` with `groupValue` and `onChanged` hoisted onto it, keeping each tile's `value` at 0 and 1.
