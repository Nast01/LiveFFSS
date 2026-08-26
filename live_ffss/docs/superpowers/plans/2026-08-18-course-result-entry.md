# Course Result Entry Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the scaffold that opens on a drawn race into a screen that records a finishing order — by bracelet or by tap — with ties, forfeits and disqualifications.

**Architecture:** The race stores the order it was crossed in, never a place. Places are computed from that order, so ties skipping places, removals renumbering and undo all fall out of the model. Forfeits and disqualifications live beside the order and take no place. Everything persists into the authored programme through `ProgrammeService`, device-local, on every gesture.

**Tech Stack:** Flutter 3.41.9 / Dart 3.11.5, GetX (state + DI + routing), freezed + json_serializable for persisted models, `flutter_test` + `mocktail`.

**Spec:** [docs/superpowers/specs/2026-08-18-course-result-entry-design.md](../specs/2026-08-18-course-result-entry-design.md)

## Global Constraints

- **Controllers hold no `Get.dialog`, `Get.snackbar`, `.tr`, `Get.context!`, and take no `BuildContext` parameter.** Controllers store translation keys; views translate. Dialogs are opened by views.
- Constructor injection only. Never `Get.find()` inside a controller body.
- Catch `AppException` (the sealed type from `core/errors/`), never raw `Exception`.
- **No widget tests, no integration tests.** Task 5 ships with none; it is verified by `flutter analyze`, the suite staying green, and a manual checklist.
- Analyzer: `strict-casts: true`, `strict-raw-types: true`. No `dynamic`.
- Comments explain the **why**, never what the next line does.
- Persisted models are freezed + json_serializable. After editing one, run `dart run build_runner build --delete-conflicting-outputs` and commit the generated `.freezed.dart` / `.g.dart` alongside the source — they are treated as source in this repo.
- Domain-model tests live in `test/data/models/`; controller tests in `test/presentation/modules/competitions/controllers/`.
- Design tokens (`AppColors`, `AppSpacing`, `AppTypography`, `AppRadius`) rather than hard-coded values.
- Run `dart format` on every file touched before committing.
- `flutter` and `dart` are on the user PATH — call them bare. If a shell reports `flutter: command not found`, it started before a PATH edit: prefix with `PATH="$PATH:/c/Users/nast0/dev/flutter_windows_3.22.2-stable/flutter/bin"` rather than switching to full `.bat` paths.

## Ranking rules (from the spec, binding on every task)

1. A tie consumes the places it occupies: two firsts, no second, next is third.
2. A forfeit or disqualification takes **no** place and leaves the ranking; the highest place a race hands out is its athlete count minus its withdrawals.
3. A tie is declared by locking the place, never by a gesture on a ranked athlete.
4. A mistake is undone, never started over.

---

### Task 1: Where a result is stored

**Files:**
- Create: `lib/app/domain/models/course_penalty.dart`
- Modify: `lib/app/domain/models/programme_race.dart`
- Test: `test/data/models/programme_race_result_test.dart`

**Interfaces:**
- Consumes: nothing.
- Produces:
  - `enum CoursePenaltyKind { forfeit, disqualified, unknown }`
  - `class CoursePenalty` (freezed) with `int athleteId`, `CoursePenaltyKind kind`, `String code`
  - `ProgrammeRace.finishOrder` — `List<List<int>>`, default `const []`
  - `ProgrammeRace.penalties` — `List<CoursePenalty>`, default `const []`

- [ ] **Step 1: Write the failing test**

Create `test/data/models/programme_race_result_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/course_penalty.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';

void main() {
  group('ProgrammeRace results', () {
    test('a race authored before results carries none', () {
      const race = ProgrammeRace(id: 1, number: 1);

      expect(race.finishOrder, isEmpty);
      expect(race.penalties, isEmpty);
    });

    test('a stored race round-trips its order and its penalties', () {
      const race = ProgrammeRace(
        id: 1,
        number: 1,
        athleteIds: [10, 11, 12],
        finishOrder: [
          [10],
          [11, 12],
        ],
        penalties: [
          CoursePenalty(
            athleteId: 12,
            kind: CoursePenaltyKind.disqualified,
            code: '4.7',
          ),
        ],
      );

      final restored = ProgrammeRace.fromJson(race.toJson());

      expect(restored.finishOrder, [
        [10],
        [11, 12],
      ]);
      expect(restored.penalties.single.athleteId, 12);
      expect(restored.penalties.single.kind, CoursePenaltyKind.disqualified);
      expect(restored.penalties.single.code, '4.7');
    });

    test('an unrecognised penalty kind degrades rather than throwing', () {
      // Forward compatibility with a kind a later build writes.
      final restored = CoursePenalty.fromJson(const {
        'athleteId': 12,
        'kind': 'something_else',
        'code': '',
      });

      expect(restored.kind, CoursePenaltyKind.unknown);
    });
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/data/models/programme_race_result_test.dart`

Expected: FAIL at compile — `Couldn't resolve the package 'live_ffss/app/domain/models/course_penalty.dart'`, and `No named parameter with the name 'finishOrder'`.

- [ ] **Step 3: Create the penalty model**

Create `lib/app/domain/models/course_penalty.dart`:

```dart
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'course_penalty.freezed.dart';
part 'course_penalty.g.dart';

/// Why an athlete is out of the ranking. `unknown` is the forward-compatible
/// arm: a kind written by a later build must not fail the whole programme's
/// decode.
enum CoursePenaltyKind { forfeit, disqualified, unknown }

/// One athlete taken out of a race's ranking. [code] is the free-text
/// disqualification code the referee gives; it stays empty for a forfeit.
@freezed
class CoursePenalty with _$CoursePenalty {
  const factory CoursePenalty({
    required int athleteId,
    @JsonKey(unknownEnumValue: CoursePenaltyKind.unknown)
    required CoursePenaltyKind kind,
    @Default('') String code,
  }) = _CoursePenalty;

  factory CoursePenalty.fromJson(Map<String, dynamic> json) =>
      _$CoursePenaltyFromJson(json);
}
```

- [ ] **Step 4: Add the two fields to the drawn race**

In `lib/app/domain/models/programme_race.dart`, add the import and the fields inside the factory, after `athleteIds`:

```dart
import 'package:live_ffss/app/domain/models/course_penalty.dart';
```

```dart
    // The order this race was crossed in — one entry per finishing group, a
    // group of several being a declared tie. Places are computed from this
    // and never stored: that is what makes a removal renumber for free.
    @Default(<List<int>>[]) List<List<int>> finishOrder,
    // Athletes out of the ranking. They take no place, so the athletes after
    // them number as though they had not started.
    @Default(<CoursePenalty>[]) List<CoursePenalty> penalties,
```

- [ ] **Step 5: Run codegen**

Run: `dart run build_runner build --delete-conflicting-outputs`

Expected: `course_penalty.freezed.dart`, `course_penalty.g.dart` created, and `programme_race.freezed.dart` / `programme_race.g.dart` regenerated. If it fails with `frontend_server.dart.snapshot not found`, the dart-sdk cache has drifted from the checked-out Flutter tag — run `flutter --version` to repopulate it and retry. That is not a code bug; do not chase it as one.

- [ ] **Step 6: Run the tests to verify they pass**

Run: `flutter test test/data/models/programme_race_result_test.dart` then the whole suite: `flutter test`

Expected: PASS, 3 new tests, whole suite green. A programme stored before this change still decodes — that is what the first test guards.

- [ ] **Step 7: Format, analyze and commit**

```bash
dart format lib/app/domain/models/course_penalty.dart lib/app/domain/models/programme_race.dart test/data/models/programme_race_result_test.dart
flutter analyze lib/app/domain/models
git add lib/app/domain/models/course_penalty.dart lib/app/domain/models/course_penalty.freezed.dart lib/app/domain/models/course_penalty.g.dart lib/app/domain/models/programme_race.dart lib/app/domain/models/programme_race.freezed.dart lib/app/domain/models/programme_race.g.dart test/data/models/programme_race_result_test.dart
git commit -m "feat(results): give a drawn race somewhere to keep its order"
```

---

### Task 2: The ranking, as pure functions

Everything the screen does to a result is one of these. No Flutter, no GetX.

**Files:**
- Create: `lib/app/domain/models/course_ranking.dart`
- Test: `test/data/models/course_ranking_test.dart`

**Interfaces:**
- Consumes: nothing (operates on plain `List<List<int>>`).
- Produces:
  - `Map<int, int> placesOf(List<List<int>> finishOrder)`
  - `int nextPlace(List<List<int>> finishOrder)`
  - `List<List<int>> withFinisher(List<List<int>> finishOrder, int athleteId, {required bool tied})`
  - `List<List<int>> withoutAthlete(List<List<int>> finishOrder, int athleteId)`
  - `List<List<int>> withoutLastFinisher(List<List<int>> finishOrder)`

- [ ] **Step 1: Write the failing test**

Create `test/data/models/course_ranking_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/course_ranking.dart';

void main() {
  group('placesOf', () {
    test('nobody has finished, nobody has a place', () {
      expect(placesOf(const []), isEmpty);
    });

    test('numbers a plain order one by one', () {
      expect(
          placesOf(const [
            [10],
            [11],
            [12],
          ]),
          {10: 1, 11: 2, 12: 3});
    });

    test('a tie consumes the places it occupies', () {
      // Two firsts, no second: the next athlete is third.
      expect(
          placesOf(const [
            [10, 11],
            [12],
          ]),
          {10: 1, 11: 1, 12: 3});
    });

    test('a tie of three pushes the next to fourth', () {
      expect(
          placesOf(const [
            [10, 11, 12],
            [13],
          ]),
          {10: 1, 11: 1, 12: 1, 13: 4});
    });
  });

  group('nextPlace', () {
    test('an untouched race starts at one', () {
      expect(nextPlace(const []), 1);
    });

    test('follows the athletes already placed, not the groups', () {
      expect(
          nextPlace(const [
            [10, 11],
          ]),
          3);
    });
  });

  group('withFinisher', () {
    test('appends a new group by default', () {
      expect(
          withFinisher(const [
            [10],
          ], 11, tied: false),
          [
            [10],
            [11],
          ]);
    });

    test('a tie joins the last group instead of opening one', () {
      expect(
          withFinisher(const [
            [10],
          ], 11, tied: true),
          [
            [10, 11],
          ]);
    });

    test('the first finisher opens a group even when tied is set', () {
      // There is nothing to tie to; the lock must not lose the athlete.
      expect(withFinisher(const [], 10, tied: true), [
        [10],
      ]);
    });

    test('an athlete already placed is not placed twice', () {
      expect(
          withFinisher(const [
            [10],
          ], 10, tied: false),
          [
            [10],
          ]);
    });
  });

  group('withoutAthlete', () {
    test('removing renumbers everyone after', () {
      final after = withoutAthlete(const [
        [10],
        [11],
        [12],
      ], 11);

      expect(after, [
        [10],
        [12],
      ]);
      expect(placesOf(after), {10: 1, 12: 2});
    });

    test('removing one of a tie leaves the other in place', () {
      final after = withoutAthlete(const [
        [10, 11],
        [12],
      ], 11);

      expect(after, [
        [10],
        [12],
      ]);
      expect(placesOf(after), {10: 1, 12: 2});
    });

    test('an athlete who never finished changes nothing', () {
      expect(
          withoutAthlete(const [
            [10],
          ], 99),
          [
            [10],
          ]);
    });
  });

  group('withoutLastFinisher', () {
    test('takes back the last athlete entered', () {
      expect(
          withoutLastFinisher(const [
            [10],
            [11],
          ]),
          [
            [10],
          ]);
    });

    test('takes back only the last of a tie, keeping the group', () {
      expect(
          withoutLastFinisher(const [
            [10, 11],
          ]),
          [
            [10],
          ]);
    });

    test('an untouched race has nothing to take back', () {
      expect(withoutLastFinisher(const []), isEmpty);
    });
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/data/models/course_ranking_test.dart`

Expected: FAIL at compile — `Couldn't resolve the package '.../course_ranking.dart'`.

- [ ] **Step 3: Write the implementation**

Create `lib/app/domain/models/course_ranking.dart`:

```dart
/// The ranking of one course, computed from the order it was crossed in.
///
/// A `finishOrder` is a list of finishing groups, in order: one athlete id
/// normally, several when the operator declared them tied. Nothing here stores
/// a place — every place is derived, which is what makes removing an athlete
/// renumber the rest for free and makes a tie an ordinary group.
library;

/// Place of every athlete who finished, keyed by athlete id.
///
/// A tie consumes the places it occupies: two firsts leave nobody second, and
/// the next group is third. That is the federation's ranking, and it is the
/// reason a group's place counts the athletes before it rather than the groups.
Map<int, int> placesOf(List<List<int>> finishOrder) {
  final places = <int, int>{};
  var placed = 0;
  for (final group in finishOrder) {
    final place = placed + 1;
    for (final athleteId in group) {
      places[athleteId] = place;
    }
    placed += group.length;
  }
  return places;
}

/// The place the next athlete entered will take.
int nextPlace(List<List<int>> finishOrder) =>
    1 + finishOrder.fold<int>(0, (total, group) => total + group.length);

/// [finishOrder] with [athleteId] added at the end — tied to the last group
/// when [tied], in a group of their own otherwise.
///
/// An athlete already placed is returned untouched: a bracelet read twice must
/// not rank the same person in two places.
List<List<int>> withFinisher(
  List<List<int>> finishOrder,
  int athleteId, {
  required bool tied,
}) {
  if (placesOf(finishOrder).containsKey(athleteId)) return finishOrder;
  final groups = [
    for (final group in finishOrder) [...group],
  ];
  // Tying to nothing is not a tie; the lock must not swallow the first athlete.
  if (tied && groups.isNotEmpty) {
    groups.last.add(athleteId);
  } else {
    groups.add([athleteId]);
  }
  return groups;
}

/// [finishOrder] without [athleteId]. A group left empty is dropped, so the
/// athletes after them close the gap.
List<List<int>> withoutAthlete(List<List<int>> finishOrder, int athleteId) => [
      for (final group in finishOrder)
        if (group.any((id) => id != athleteId))
          [
            for (final id in group)
              if (id != athleteId) id,
          ],
    ];

/// [finishOrder] without the athlete entered last — the undo of a single entry,
/// whether it opened a group or joined one.
List<List<int>> withoutLastFinisher(List<List<int>> finishOrder) {
  if (finishOrder.isEmpty) return finishOrder;
  final groups = [
    for (final group in finishOrder) [...group],
  ];
  groups.last.removeLast();
  if (groups.last.isEmpty) groups.removeLast();
  return groups;
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/data/models/course_ranking_test.dart`

Expected: PASS, 16 tests, output pristine.

- [ ] **Step 5: Format, analyze and commit**

```bash
dart format lib/app/domain/models/course_ranking.dart test/data/models/course_ranking_test.dart
flutter analyze lib/app/domain/models
git add lib/app/domain/models/course_ranking.dart test/data/models/course_ranking_test.dart
git commit -m "feat(results): compute places from the order, never store them"
```

---

### Task 3: The controller reads the race and takes entries

**Files:**
- Modify: `lib/app/module/competitions/controllers/race_course_controller.dart` (replace wholesale)
- Modify: `lib/app/module/competitions/bindings/race_course_binding.dart` (replace wholesale)
- Create: `test/presentation/modules/competitions/controllers/race_course_controller_test.dart`

**Interfaces:**
- Consumes: `placesOf`, `nextPlace`, `withFinisher`, `withoutAthlete`, `withoutLastFinisher` (Task 2); `ProgrammeRace.finishOrder` (Task 1); `ClubRepository.getAthleteClubs(int competitionId, Iterable<Athlete> athletes)`.
- Produces, on `RaceCourseController`:
  - constructor `RaceCourseController(ProgrammeService, RaceRepository, ClubRepository)`
  - `final RxList<Athlete> athletes` — the line-up, draw order
  - `final RxList<List<int>> finishOrder`
  - `final RxBool tieLock`
  - `final RxBool isLoading`
  - `Future<void> load()`
  - `int get nextPlaceValue`
  - `int? placeOf(Athlete athlete)`
  - `List<Athlete> get orderedAthletes`
  - `void assign(Athlete athlete)`
  - `void remove(Athlete athlete)`
  - `void undo()`
  - `void toggleTieLock()`

- [ ] **Step 1: Write the failing test**

Create `test/presentation/modules/competitions/controllers/race_course_controller_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
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
import 'package:live_ffss/app/module/competitions/controllers/race_course_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockRaceRepo extends Mock implements RaceRepository {}

class _MockClubRepo extends Mock implements ClubRepository {}

/// Keeps the programme in memory so the controller's read-modify-write can be
/// asserted end to end, without secure storage.
class _FakeProgrammeService implements ProgrammeService {
  _FakeProgrammeService(CompetitionProgramme initial) {
    current.value = initial;
  }

  @override
  final Rxn<CompetitionProgramme> current = Rxn<CompetitionProgramme>();

  @override
  Future<void> load(int competitionId) async {}

  @override
  Future<void> save(CompetitionProgramme programme) async {
    current.value = programme;
  }

  @override
  int allocateId() {
    final p = current.value!;
    current.value = p.copyWith(nextLocalId: p.nextLocalId + 1);
    return p.nextLocalId;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const raceId = 10;
  const competitionId = 99;
  const categoryId = 5;
  const programmeRaceId = 77;

  late _MockRaceRepo raceRepo;
  late _MockClubRepo clubRepo;
  late _FakeProgrammeService programme;

  setUpAll(() => registerFallbackValue(const <Athlete>[]));

  Athlete athlete(int id) => Athlete(
        id: id,
        licenseeNumber: 'L$id',
        firstName: 'A$id',
        lastName: 'B$id',
        gender: Gender.female,
        year: 2000,
        nationalityCode: '',
        nationality: '',
        isValid: true,
      );

  Race makeRace() => const Race(
        id: raceId,
        name: 'Race',
        nameEnglish: 'Race',
        distance: 100,
        gender: Gender.female,
        athletesPerTeam: 1,
        specialityId: 1,
        specialityLabel: 'Côtier',
        disciplineId: 1,
        isEligibleToNationalRecord: false,
        categories: [],
      );

  Competition makeCompetition() => const Competition(
        id: competitionId,
        name: 'Comp',
        statusCode: 1,
        statusLabel: 'OPEN',
        speciality: 1,
        specialityLabel: 'Côtier',
        typeWater: '',
        typePool: '',
        typeChrono: '',
        isEligibleToNationalRecord: false,
        numberOfLanes: 8,
        organizer: '',
        hasBegun: false,
        hasResult: false,
        hasPassed: false,
        level: 1,
        levelLabel: 'N',
        organizerClub: Club(id: 0, name: ''),
      );

  CompetitionProgramme programmeWith(ProgrammeRace race) =>
      CompetitionProgramme(
        competitionId: competitionId,
        nextLocalId: 100,
        structures: [
          EventStructure(
            raceId: raceId,
            categoryId: categoryId,
            raceLabel: 'Race',
            categoryLabel: 'Senior',
            levels: [RoundLevel(type: RoundType.serie, races: [race])],
          ),
        ],
      );

  /// The stored race, read back out of the fake programme.
  ProgrammeRace saved() =>
      programme.current.value!.structures.single.levels.single.races.single;

  Map<String, Object?> arguments() => {
        'race': makeRace(),
        'competition': makeCompetition(),
        'categoryId': categoryId,
        'categoryLabel': 'Senior',
        'roundType': RoundType.serie,
        'raceNumber': 1,
        'programmeRaceId': programmeRaceId,
      };

  Future<RaceCourseController> loadWith(List<int> athleteIds) async {
    programme = _FakeProgrammeService(programmeWith(
      ProgrammeRace(id: programmeRaceId, number: 1, athleteIds: athleteIds),
    ));
    when(() => raceRepo.getEntries(raceId)).thenAnswer((_) async => [
          Entry(
            id: 1,
            category: const Category(id: categoryId, name: 'Senior'),
            status: 1,
            statusLabel: 'Engagé',
            athletes: [for (final id in athleteIds) athlete(id)],
          ),
        ]);
    final controller = RaceCourseController(programme, raceRepo, clubRepo)
      ..applyArguments(arguments());
    await controller.load();
    return controller;
  }

  setUp(() {
    raceRepo = _MockRaceRepo();
    clubRepo = _MockClubRepo();
    when(() => clubRepo.getAthleteClubs(any(), any()))
        .thenAnswer((_) async => const <int, Club>{});
  });

  tearDown(Get.reset);

  group('RaceCourseController.load', () {
    test('lists the athletes the draw put in this race', () async {
      final c = await loadWith([10, 11, 12]);

      expect(c.athletes.map((a) => a.id), [10, 11, 12]);
      expect(c.isLoading.value, isFalse);
    });

    test('reopens on the order already recorded', () async {
      final c = await loadWith([10, 11]);
      c.assign(c.athletes.first);

      // A second controller on the same programme sees the stored order.
      final again = RaceCourseController(programme, raceRepo, clubRepo)
        ..applyArguments(arguments());
      await again.load();

      expect(again.placeOf(again.athletes.first), 1);
    });
  });

  group('RaceCourseController entry', () {
    test('the first athlete entered takes the first place', () async {
      final c = await loadWith([10, 11]);

      c.assign(c.athletes.first);

      expect(c.placeOf(c.athletes.first), 1);
      expect(c.nextPlaceValue, 2);
    });

    test('the tie lock gives the same place until it is released', () async {
      final c = await loadWith([10, 11, 12]);

      c.assign(c.athletes[0]);
      c.toggleTieLock();
      c.assign(c.athletes[1]);
      c.toggleTieLock();
      c.assign(c.athletes[2]);

      expect(c.placeOf(c.athletes[0]), 1);
      expect(c.placeOf(c.athletes[1]), 1);
      // Two firsts consume two places; the third athlete is third.
      expect(c.placeOf(c.athletes[2]), 3);
    });

    test('undo takes back the last entry', () async {
      final c = await loadWith([10, 11]);
      c.assign(c.athletes[0]);
      c.assign(c.athletes[1]);

      c.undo();

      expect(c.placeOf(c.athletes[1]), isNull);
      expect(c.placeOf(c.athletes[0]), 1);
    });

    test('removing an athlete renumbers the ones after', () async {
      final c = await loadWith([10, 11, 12]);
      c.assign(c.athletes[0]);
      c.assign(c.athletes[1]);
      c.assign(c.athletes[2]);

      c.remove(c.athletes[1]);

      expect(c.placeOf(c.athletes[0]), 1);
      expect(c.placeOf(c.athletes[1]), isNull);
      expect(c.placeOf(c.athletes[2]), 2);
    });

    test('every entry is persisted as it happens', () async {
      final c = await loadWith([10, 11]);

      c.assign(c.athletes.first);

      expect(saved().finishOrder, [
        [10],
      ]);
    });

    test('the ranked rise in place order, the rest keep the draw order',
        () async {
      final c = await loadWith([10, 11, 12]);

      c.assign(c.athletes[2]);

      expect(c.orderedAthletes.map((a) => a.id), [12, 10, 11]);
    });
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/presentation/modules/competitions/controllers/race_course_controller_test.dart`

Expected: FAIL at compile — `Too many positional arguments: 0 expected, but 3 found` on the constructor, and `The method 'load' isn't defined for the type 'RaceCourseController'`.

- [ ] **Step 3: Write the controller**

Replace `lib/app/module/competitions/controllers/race_course_controller.dart` with:

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/course_ranking.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/race.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';

/// Records the finishing order of one drawn course. The order is the state;
/// places are computed from it (see `course_ranking.dart`), which is what makes
/// a removal renumber and a tie an ordinary group.
///
/// Device-local: FFSS documents no write endpoint for a result, so everything
/// here persists into the authored programme through [ProgrammeService].
class RaceCourseController extends GetxController {
  RaceCourseController(this._programme, this._raceRepo, this._clubRepo);

  final ProgrammeService _programme;
  final RaceRepository _raceRepo;
  final ClubRepository _clubRepo;

  final Rxn<Race> race = Rxn<Race>();
  final Rxn<Competition> competition = Rxn<Competition>();
  int? categoryId;
  String categoryLabel = '';
  RoundType roundType = RoundType.unknown;
  int raceNumber = 0;
  int? programmeRaceId;

  final RxBool isLoading = true.obs;

  /// The line-up, in the order the draw left it.
  final RxList<Athlete> athletes = <Athlete>[].obs;

  /// Finishing groups, in order. A group of several is a declared tie.
  final RxList<List<int>> finishOrder = <List<int>>[].obs;

  /// While set, the next athlete entered joins the last group rather than
  /// opening one. A lock rather than a gesture on a ranked athlete, because a
  /// bracelet cannot be long-pressed and one procedure has to serve both.
  final RxBool tieLock = false.obs;

  @override
  void onInit() {
    super.onInit();
    applyArguments(Get.arguments);
    load();
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

  Future<void> load() async {
    final raceIdValue = race.value?.id;
    final competitionIdValue = competition.value?.id;
    if (raceIdValue == null || competitionIdValue == null) {
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    try {
      await _programme.load(competitionIdValue);
      final stored = _storedRace();
      finishOrder.value = [
        for (final group in stored?.finishOrder ?? const <List<int>>[])
          [...group],
      ];

      final entries = await _raceRepo.getEntries(raceIdValue);
      final byId = <int, Athlete>{
        for (final entry in entries)
          for (final athlete in entry.athletes) athlete.id: athlete,
      };
      // The draw's order is the line-up's order; an id no entry accounts for is
      // an athlete withdrawn since, and is dropped rather than shown blank.
      final lineUp = [
        for (final id in stored?.athleteIds ?? const <int>[])
          if (byId[id] case final Athlete athlete) athlete,
      ];

      Map<int, Club> clubs;
      try {
        clubs = await _clubRepo.getAthleteClubs(competitionIdValue, lineUp);
      } on AppException {
        clubs = const {};
      }
      athletes.value = [
        for (final athlete in lineUp)
          athlete.copyWith(club: clubs[athlete.id] ?? athlete.club),
      ];
    } on AppException {
      // The line-up is unavailable; the screen shows an empty course rather
      // than failing outright, and reopening it retries.
      athletes.clear();
    } finally {
      isLoading.value = false;
    }
  }

  int get nextPlaceValue => nextPlace(finishOrder);

  int? placeOf(Athlete athlete) => placesOf(finishOrder)[athlete.id];

  /// Ranked athletes first in place order, then those still to come in the
  /// order the draw left them. The finished screen is the result itself, which
  /// is why there is no separate recap to build or to keep in step.
  List<Athlete> get orderedAthletes {
    final places = placesOf(finishOrder);
    final ranked = [
      for (final athlete in athletes)
        if (places.containsKey(athlete.id)) athlete,
    ]..sort((a, b) => places[a.id]!.compareTo(places[b.id]!));
    return [
      ...ranked,
      for (final athlete in athletes)
        if (!places.containsKey(athlete.id)) athlete,
    ];
  }

  void assign(Athlete athlete) {
    finishOrder.value =
        withFinisher(finishOrder, athlete.id, tied: tieLock.value);
    _persist();
  }

  void remove(Athlete athlete) {
    finishOrder.value = withoutAthlete(finishOrder, athlete.id);
    _persist();
  }

  void undo() {
    finishOrder.value = withoutLastFinisher(finishOrder);
    _persist();
  }

  void toggleTieLock() => tieLock.value = !tieLock.value;

  ProgrammeRace? _storedRace() {
    for (final structure
        in _programme.current.value?.structures ?? const <EventStructure>[]) {
      if (structure.raceId != race.value?.id) continue;
      for (final level in structure.levels) {
        for (final stored in level.races) {
          if (stored.id == programmeRaceId) return stored;
        }
      }
    }
    return null;
  }

  /// Writes the order back into the programme. Not awaited: entering a result
  /// must feel instant, and there is no Save button to fall back on — a marshal
  /// does not save, and losing a session's entries is not a trade worth making.
  void _persist() {
    final current = _programme.current.value;
    if (current == null || programmeRaceId == null) return;
    _programme.save(current.copyWith(
      structures: [
        for (final structure in current.structures)
          if (structure.raceId != race.value?.id)
            structure
          else
            structure.copyWith(
              levels: [
                for (final level in structure.levels)
                  level.copyWith(
                    races: [
                      for (final stored in level.races)
                        if (stored.id == programmeRaceId)
                          stored.copyWith(
                            finishOrder: [
                              for (final group in finishOrder) [...group],
                            ],
                          )
                        else
                          stored,
                    ],
                  ),
              ],
            ),
      ],
    ));
  }
}
```

- [ ] **Step 4: Register the dependencies**

Replace `lib/app/module/competitions/bindings/race_course_binding.dart` with:

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import '../controllers/race_course_controller.dart';

class RaceCourseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RaceCourseController>(
      () => RaceCourseController(
        Get.find<ProgrammeService>(),
        Get.find<RaceRepository>(),
        Get.find<ClubRepository>(),
      ),
    );
  }
}
```

- [ ] **Step 5: Run the tests to verify they pass**

Run: `flutter test test/presentation/modules/competitions/controllers/race_course_controller_test.dart` then `flutter test`

Expected: PASS, 8 new tests, whole suite green.

- [ ] **Step 6: Format, analyze and commit**

```bash
dart format lib/app/module/competitions/controllers/race_course_controller.dart lib/app/module/competitions/bindings/race_course_binding.dart test/presentation/modules/competitions/controllers/race_course_controller_test.dart
flutter analyze lib/app/module/competitions
git add lib/app/module/competitions/controllers/race_course_controller.dart lib/app/module/competitions/bindings/race_course_binding.dart test/presentation/modules/competitions/controllers/race_course_controller_test.dart
git commit -m "feat(results): record a finishing order on the course controller"
```

---

### Task 4: Withdrawals and the bracelet

**Files:**
- Modify: `lib/app/module/competitions/controllers/race_course_controller.dart`
- Modify: `lib/app/module/competitions/bindings/race_course_binding.dart`
- Modify: `lib/app/core/translations/fr_FR.dart`, `lib/app/core/translations/en_US.dart`
- Test: `test/presentation/modules/competitions/controllers/race_course_controller_test.dart`

**Interfaces:**
- Consumes: everything Task 3 produced; `CoursePenalty`, `CoursePenaltyKind` (Task 1); `RfidWriter.isSupported`, `RfidWriter.readBracelets()`, `parseBraceletLicence(String)`.
- Produces, added to `RaceCourseController`:
  - constructor becomes `RaceCourseController(ProgrammeService, RaceRepository, ClubRepository, RfidWriter)`
  - `final RxList<CoursePenalty> penalties`
  - `final RxBool isScanning`
  - `final Rxn<UiMessage> message`
  - `CoursePenalty? penaltyOf(Athlete athlete)`
  - `void setPenalty(Athlete athlete, CoursePenaltyKind kind, {String code = ''})`
  - `void clearPenalty(Athlete athlete)`
  - `bool get canScan`
  - `bool get isComplete`
  - `void startScan()` / `void stopScan()`

- [ ] **Step 1: Extend the test file's scaffolding**

In `test/presentation/modules/competitions/controllers/race_course_controller_test.dart`:

Add these imports at the top:

```dart
import 'dart:async';

import 'package:live_ffss/app/core/rfid/rfid_writer.dart';
import 'package:live_ffss/app/domain/models/course_penalty.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';
```

Add the mock beside the others:

```dart
class _MockRfidWriter extends Mock implements RfidWriter {}
```

Add `late _MockRfidWriter rfid;` beside the other `late` declarations, and
`rfid = _MockRfidWriter();` as the first line of `setUp`.

Change both controller constructions to pass it as the fourth argument:

```dart
    final controller = RaceCourseController(programme, raceRepo, clubRepo, rfid)
      ..applyArguments(arguments());
```

```dart
      final again = RaceCourseController(programme, raceRepo, clubRepo, rfid)
        ..applyArguments(arguments());
```

- [ ] **Step 2: Write the failing tests**

Append these two groups before the closing brace of `main()`:

```dart
  group('RaceCourseController withdrawals', () {
    test('a forfeit takes no place and the others close the gap', () async {
      final c = await loadWith([10, 11, 12]);

      c.assign(c.athletes[0]);
      c.setPenalty(c.athletes[1], CoursePenaltyKind.forfeit);
      c.assign(c.athletes[2]);

      expect(c.placeOf(c.athletes[2]), 2);
      expect(c.penaltyOf(c.athletes[1])?.kind, CoursePenaltyKind.forfeit);
    });

    test('a disqualification carries its code', () async {
      final c = await loadWith([10, 11]);

      c.setPenalty(c.athletes[0], CoursePenaltyKind.disqualified, code: '4.7');

      expect(c.penaltyOf(c.athletes[0])?.code, '4.7');
      expect(saved().penalties.single.code, '4.7');
    });

    test('penalising a ranked athlete pulls them out of the ranking', () async {
      final c = await loadWith([10, 11]);
      c.assign(c.athletes[0]);
      c.assign(c.athletes[1]);

      c.setPenalty(c.athletes[0], CoursePenaltyKind.disqualified, code: 'x');

      expect(c.placeOf(c.athletes[0]), isNull);
      expect(c.placeOf(c.athletes[1]), 1);
    });

    test('clearing a penalty puts the athlete back among those to come',
        () async {
      final c = await loadWith([10]);
      c.setPenalty(c.athletes[0], CoursePenaltyKind.forfeit);

      c.clearPenalty(c.athletes[0]);

      expect(c.penaltyOf(c.athletes[0]), isNull);
      expect(c.isComplete, isFalse);
    });

    test('the course is complete when nobody is left to place', () async {
      final c = await loadWith([10, 11]);
      c.assign(c.athletes[0]);
      expect(c.isComplete, isFalse);

      c.setPenalty(c.athletes[1], CoursePenaltyKind.forfeit);

      expect(c.isComplete, isTrue);
    });

    test('a withdrawn athlete sinks below those still to come', () async {
      final c = await loadWith([10, 11]);

      c.setPenalty(c.athletes[0], CoursePenaltyKind.forfeit);

      expect(c.orderedAthletes.map((a) => a.id), [11, 10]);
    });
  });

  group('RaceCourseController scanning', () {
    late StreamController<String> stream;

    setUp(() {
      stream = StreamController<String>();
      when(() => rfid.readBracelets()).thenAnswer((_) => stream.stream);
      when(() => rfid.isSupported).thenReturn(true);
    });

    tearDown(() {
      // Not awaited: an unlistened single-subscription controller's close()
      // never completes, which would hang this tearDown.
      if (!stream.isClosed) stream.close();
    });

    test('a scanned bracelet takes the next place', () async {
      final c = await loadWith([10, 11]);
      c.startScan();

      stream.add('L10;B10');
      await pumpEventQueue();

      expect(c.placeOf(c.athletes[0]), 1);
      c.stopScan();
    });

    test('the tie lock applies to a scan exactly as to a tap', () async {
      final c = await loadWith([10, 11, 12]);
      c.startScan();
      stream.add('L10;B10');
      await pumpEventQueue();

      c.toggleTieLock();
      stream.add('L11;B11');
      await pumpEventQueue();

      expect(c.placeOf(c.athletes[1]), 1);
      c.stopScan();
    });

    test('a bracelet of nobody in this course reports and changes nothing',
        () async {
      final c = await loadWith([10]);
      c.startScan();

      stream.add('L999;NOBODY');
      await pumpEventQueue();

      expect(c.finishOrder, isEmpty);
      expect(c.message.value, isA<UiMessageError>());
      c.stopScan();
    });

    test('a bracelet already ranked is not ranked twice', () async {
      final c = await loadWith([10, 11]);
      c.startScan();
      stream.add('L10;B10');
      await pumpEventQueue();
      stream.add('L10;B10');
      await pumpEventQueue();

      expect(c.finishOrder, [
        [10],
      ]);
      c.stopScan();
    });

    test('the session stops itself once the course is complete', () async {
      final c = await loadWith([10]);
      c.startScan();

      stream.add('L10;B10');
      await pumpEventQueue();

      expect(c.isComplete, isTrue);
      expect(c.isScanning.value, isFalse);
    });

    test('canScan follows the hardware', () async {
      when(() => rfid.isSupported).thenReturn(false);
      final c = await loadWith([10]);

      expect(c.canScan, isFalse);
    });
  });
```

- [ ] **Step 3: Run the tests to verify they fail**

Run: `flutter test test/presentation/modules/competitions/controllers/race_course_controller_test.dart`

Expected: FAIL at compile — `Too many positional arguments: 3 expected, but 4 found`, then once that is fixed, `The method 'setPenalty' isn't defined` and the same for `penaltyOf`, `clearPenalty`, `isComplete`, `startScan`, `stopScan`, `canScan`, `message`.

- [ ] **Step 4: Add withdrawals to the controller**

Add the imports to `race_course_controller.dart`:

```dart
import 'dart:async';

import 'package:live_ffss/app/core/rfid/bracelet_payload.dart';
import 'package:live_ffss/app/core/rfid/rfid_writer.dart';
import 'package:live_ffss/app/domain/models/course_penalty.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';
```

Take the writer in the constructor:

```dart
  RaceCourseController(
    this._programme,
    this._raceRepo,
    this._clubRepo,
    this._rfid,
  );

  final RfidWriter _rfid;
```

Add the state beside `finishOrder`:

```dart
  /// Athletes out of the ranking. Kept apart from [finishOrder] precisely so
  /// they take no place — the athletes after them number as though they had
  /// not started.
  final RxList<CoursePenalty> penalties = <CoursePenalty>[].obs;

  final RxBool isScanning = false.obs;
  final Rxn<UiMessage> message = Rxn<UiMessage>();
  StreamSubscription<String>? _scanSub;
```

In `load()`, restore them beside the order — directly after the `finishOrder.value = ...` assignment:

```dart
      penalties.value = [...?stored?.penalties];
```

Add the gestures after `toggleTieLock`:

```dart
  CoursePenalty? penaltyOf(Athlete athlete) {
    for (final penalty in penalties) {
      if (penalty.athleteId == athlete.id) return penalty;
    }
    return null;
  }

  /// Marks an athlete out of the ranking, pulling them out of the order first:
  /// a disqualified swimmer who had already been placed must not keep a place.
  void setPenalty(
    Athlete athlete,
    CoursePenaltyKind kind, {
    String code = '',
  }) {
    finishOrder.value = withoutAthlete(finishOrder, athlete.id);
    penalties.value = [
      for (final penalty in penalties)
        if (penalty.athleteId != athlete.id) penalty,
      CoursePenalty(athleteId: athlete.id, kind: kind, code: code),
    ];
    _persist();
  }

  void clearPenalty(Athlete athlete) {
    penalties.value = [
      for (final penalty in penalties)
        if (penalty.athleteId != athlete.id) penalty,
    ];
    _persist();
  }

  /// Whether every athlete is accounted for — placed or withdrawn. This is what
  /// ends a scanning session, and why the highest place a course hands out is
  /// its line-up minus its withdrawals.
  bool get isComplete {
    final places = placesOf(finishOrder);
    return athletes.every(
      (a) => places.containsKey(a.id) || penaltyOf(a) != null,
    );
  }
```

Extend `orderedAthletes` so withdrawals sink to the bottom — replace its
`return` statement with:

```dart
    return [
      ...ranked,
      for (final athlete in athletes)
        if (!places.containsKey(athlete.id) && penaltyOf(athlete) == null)
          athlete,
      for (final athlete in athletes)
        if (penaltyOf(athlete) != null) athlete,
    ];
```

And carry the penalties in `_persist()` — change the `copyWith` on the stored
race to:

```dart
                          stored.copyWith(
                            finishOrder: [
                              for (final group in finishOrder) [...group],
                            ],
                            penalties: [...penalties],
                          )
```

- [ ] **Step 5: Add scanning to the controller**

```dart
  bool get canScan => _rfid.isSupported;

  /// Opens a continuous read session. Each bracelet whose licence matches an
  /// athlete of this course takes the next place, tie lock included — the same
  /// procedure as a tap, which is the whole reason the lock is a mode rather
  /// than a gesture.
  void startScan() {
    if (isScanning.value || isComplete) return;
    isScanning.value = true;
    _scanSub = _rfid.readBracelets().listen(
      _onBracelet,
      onError: (Object e) {
        message.value = UiMessageError(
          e is RfidException ? e.message : 'bracelet_unreadable',
        );
      },
    );
  }

  void stopScan() {
    _scanSub?.cancel();
    _scanSub = null;
    isScanning.value = false;
  }

  void _onBracelet(String payload) {
    final licence = parseBraceletLicence(payload);
    Athlete? match;
    for (final athlete in athletes) {
      if (athlete.licenseeNumber == licence) {
        match = athlete;
        break;
      }
    }
    if (match == null) {
      message.value = const UiMessageError('course_bracelet_not_in_race');
      return;
    }
    assign(match);
    // Nothing left to place: holding the hardware open would only invite a
    // stray read.
    if (isComplete) stopScan();
  }

  @override
  void onClose() {
    _scanSub?.cancel();
    super.onClose();
  }
```

- [ ] **Step 6: Pass the writer in the binding**

In `lib/app/module/competitions/bindings/race_course_binding.dart`, add
`import 'package:live_ffss/app/core/rfid/rfid_writer.dart';` and
`Get.find<RfidWriter>(),` as the fourth constructor argument.

- [ ] **Step 7: Add the translation**

In `lib/app/core/translations/fr_FR.dart`, after `'heat_draw_no_club'`:

```dart
  'course_bracelet_not_in_race': 'Ce bracelet n\'est pas de cette série',
```

In `lib/app/core/translations/en_US.dart`, at the matching place:

```dart
  'course_bracelet_not_in_race': 'That bracelet is not in this heat',
```

- [ ] **Step 8: Run the tests to verify they pass**

Run: `flutter test test/presentation/modules/competitions/controllers/race_course_controller_test.dart` then `flutter test`

Expected: PASS, 12 further tests, whole suite green.

- [ ] **Step 9: Format, analyze and commit**

```bash
dart format lib/app/module/competitions/controllers/race_course_controller.dart lib/app/module/competitions/bindings/race_course_binding.dart lib/app/core/translations/fr_FR.dart lib/app/core/translations/en_US.dart test/presentation/modules/competitions/controllers/race_course_controller_test.dart
flutter analyze lib/app/module/competitions lib/app/core/translations
git add lib/app/module/competitions lib/app/core/translations test/presentation/modules/competitions/controllers/race_course_controller_test.dart
git commit -m "feat(results): take withdrawals, and entries from a bracelet"
```

---

### Task 5: The screen

No automated test — this repo does not widget-test. Verified by `flutter analyze`, the suite staying green, and the manual checklist in Step 5.

**Files:**
- Modify: `lib/app/module/competitions/views/race_course_view.dart` (replace wholesale)
- Modify: `lib/app/core/translations/fr_FR.dart`, `lib/app/core/translations/en_US.dart`

**Interfaces:**
- Consumes: every member Tasks 3 and 4 produced.
- Produces: no new API.

- [ ] **Step 1: Add the translations**

In `lib/app/core/translations/fr_FR.dart`, after `'course_bracelet_not_in_race'`:

```dart
  'course_title': 'Saisie des résultats',
  'course_next_place': 'Place suivante',
  'course_tie': 'ex-aequo',
  'course_tie_locked': 'verrouillée',
  'course_scan': 'Scanner les bracelets',
  'course_scan_stop': 'Arrêter le scan',
  'course_undo': 'Annuler',
  'course_complete': 'Tous les athlètes sont classés',
  'course_forfeit': 'Forfait',
  'course_disqualify': 'Disqualifier…',
  'course_unrank': 'Retirer du classement',
  'course_reinstate': 'Annuler le forfait / la disqualification',
  'course_dq_title': 'Disqualification',
  'course_dq_code': 'Code',
  'forfeit_short': 'FF',
  'disqualified_short': 'DQ',
```

In `lib/app/core/translations/en_US.dart`, at the matching place:

```dart
  'course_title': 'Result entry',
  'course_next_place': 'Next place',
  'course_tie': 'tie',
  'course_tie_locked': 'locked',
  'course_scan': 'Scan bracelets',
  'course_scan_stop': 'Stop scanning',
  'course_undo': 'Undo',
  'course_complete': 'Every athlete is ranked',
  'course_forfeit': 'Forfeit',
  'course_disqualify': 'Disqualify…',
  'course_unrank': 'Remove from ranking',
  'course_reinstate': 'Undo the forfeit / disqualification',
  'course_dq_title': 'Disqualification',
  'course_dq_code': 'Code',
  'forfeit_short': 'FF',
  'disqualified_short': 'DQ',
```

- [ ] **Step 2: Write the view**

Replace `lib/app/module/competitions/views/race_course_view.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/course_penalty.dart';
import 'package:live_ffss/app/module/competitions/controllers/race_course_controller.dart';
import 'package:live_ffss/app/presentation/modules/competitions/race_formatting.dart';
import 'package:live_ffss/app/presentation/modules/programme/programme_formatting.dart';
import 'package:live_ffss/app/presentation/shared/club_avatar.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';
import 'package:live_ffss/app/presentation/shared/loading_indicator.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';

class RaceCourseView extends StatefulWidget {
  const RaceCourseView({super.key});

  @override
  State<RaceCourseView> createState() => _RaceCourseViewState();
}

class _RaceCourseViewState extends State<RaceCourseView> {
  late final RaceCourseController _ctrl;
  late final Worker _messageWorker;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<RaceCourseController>();
    _messageWorker = ever<UiMessage?>(_ctrl.message, (m) {
      if (m == null || !mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(m.translationKey.tr),
        backgroundColor:
            m is UiMessageError ? AppColors.statusError : AppColors.primary,
      ));
    });
  }

  @override
  void dispose() {
    _messageWorker.dispose();
    super.dispose();
  }

  /// The row menu. Tapping a row is the fast path; this is where the cases that
  /// are not "they finished" live.
  Future<void> _openRowMenu(Athlete athlete, Offset at) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final ranked = _ctrl.placeOf(athlete) != null;
    final withdrawn = _ctrl.penaltyOf(athlete) != null;
    final action = await showMenu<String>(
      context: context,
      position:
          RelativeRect.fromRect(at & Size.zero, Offset.zero & overlay.size),
      items: [
        if (!withdrawn) ...[
          PopupMenuItem(value: 'forfeit', child: Text('course_forfeit'.tr)),
          PopupMenuItem(value: 'dq', child: Text('course_disqualify'.tr)),
        ],
        if (ranked)
          PopupMenuItem(value: 'unrank', child: Text('course_unrank'.tr)),
        if (withdrawn)
          PopupMenuItem(
              value: 'reinstate', child: Text('course_reinstate'.tr)),
      ],
    );
    if (!mounted || action == null) return;
    switch (action) {
      case 'forfeit':
        _ctrl.setPenalty(athlete, CoursePenaltyKind.forfeit);
      case 'dq':
        await _askDisqualification(athlete);
      case 'unrank':
        _ctrl.remove(athlete);
      case 'reinstate':
        _ctrl.clearPenalty(athlete);
    }
  }

  Future<void> _askDisqualification(Athlete athlete) async {
    final field = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('course_dq_title'.tr),
        content: TextField(
          controller: field,
          autofocus: true,
          decoration: InputDecoration(labelText: 'course_dq_code'.tr),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(field.text.trim()),
            child: Text('confirm'.tr),
          ),
        ],
      ),
    );
    field.dispose();
    if (code == null) return;
    _ctrl.setPenalty(athlete, CoursePenaltyKind.disqualified, code: code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text('course_title'.tr,
            style: AppTypography.title
                .copyWith(color: Colors.white, fontSize: 16)),
      ),
      body: Obx(() {
        if (_ctrl.isLoading.value) return const LoadingIndicator();
        if (_ctrl.athletes.isEmpty) {
          return EmptyState(
              icon: Icons.timer_outlined, title: 'no_athletes_found'.tr);
        }
        final rows = _ctrl.orderedAthletes;
        return Column(
          children: [
            const _CourseContext(),
            const _EntryBar(),
            Expanded(
              child: ListView.builder(
                padding: AppSpacing.pageAll,
                itemCount: rows.length,
                itemBuilder: (_, i) => _CompetitorRow(
                  athlete: rows[i],
                  onTap: () => _ctrl.placeOf(rows[i]) == null
                      ? _ctrl.assign(rows[i])
                      : _ctrl.remove(rows[i]),
                  onMenu: (at) => _openRowMenu(rows[i], at),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

/// What is being scored: épreuve, gender, category, round.
class _CourseContext extends GetView<RaceCourseController> {
  const _CourseContext();

  @override
  Widget build(BuildContext context) {
    final race = controller.race.value;
    final parts = <String>[
      if (race != null) ...[race.name, race.gender.label],
      if (controller.categoryLabel.isNotEmpty) controller.categoryLabel,
      '${controller.roundType.labelKey.tr} ${controller.raceNumber}',
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          parts.join(' · '),
          style: AppTypography.body
              .copyWith(fontSize: 13, fontWeight: FontWeight.w600),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

/// The next place, the tie lock, undo and the scan toggle — the one place the
/// operator checks that the screen agrees with them.
class _EntryBar extends GetView<RaceCourseController> {
  const _EntryBar();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final complete = controller.isComplete;
      final locked = controller.tieLock.value;
      return Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
        child: Column(
          children: [
            Row(
              children: [
                Text('course_next_place'.tr, style: AppTypography.caption),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  complete
                      ? 'course_complete'.tr
                      : '${controller.nextPlaceValue}'
                          '${locked ? ' · ${'course_tie_locked'.tr}' : ''}',
                  style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w800,
                      color: complete
                          ? AppColors.statusFinished
                          : AppColors.textPrimary),
                ),
                const Spacer(),
                FilterChip(
                  label: Text('course_tie'.tr),
                  selected: locked,
                  onSelected: (_) => controller.toggleTieLock(),
                ),
                IconButton(
                  onPressed:
                      controller.finishOrder.isEmpty ? null : controller.undo,
                  icon: const Icon(Icons.undo),
                  tooltip: 'course_undo'.tr,
                ),
              ],
            ),
            if (controller.canScan && !complete)
              SizedBox(
                width: double.infinity,
                child: controller.isScanning.value
                    ? ElevatedButton.icon(
                        onPressed: controller.stopScan,
                        icon: const Icon(Icons.stop),
                        label: Text('course_scan_stop'.tr),
                      )
                    : OutlinedButton.icon(
                        onPressed: controller.startScan,
                        icon: const Icon(Icons.nfc),
                        label: Text('course_scan'.tr),
                      ),
              ),
          ],
        ),
      );
    });
  }
}

class _CompetitorRow extends GetView<RaceCourseController> {
  const _CompetitorRow({
    required this.athlete,
    required this.onTap,
    required this.onMenu,
  });

  final Athlete athlete;
  final VoidCallback onTap;
  final ValueChanged<Offset> onMenu;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final place = controller.placeOf(athlete);
      final penalty = controller.penaltyOf(athlete);
      final club = athlete.club?.name.isNotEmpty == true
          ? athlete.club!.name
          : athlete.clubLabel;
      final badge = switch (penalty?.kind) {
        CoursePenaltyKind.forfeit => 'forfeit_short'.tr,
        CoursePenaltyKind.disqualified => 'disqualified_short'.tr,
        _ => place?.toString() ?? '—',
      };
      final badgeColor = penalty != null
          ? AppColors.statusError
          : place != null
              ? AppColors.primary
              : AppColors.textMuted;

      return Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.mdRadius,
          border: Border.all(color: AppColors.border),
        ),
        child: InkWell(
          borderRadius: AppRadius.mdRadius,
          // A withdrawn athlete has no place to take; the menu reinstates them.
          onTap: penalty == null ? onTap : null,
          onLongPressStart: (d) => onMenu(d.globalPosition),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            child: Row(
              children: [
                SizedBox(
                  width: 34,
                  child: Text(badge,
                      textAlign: TextAlign.center,
                      style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w800, color: badgeColor)),
                ),
                const SizedBox(width: AppSpacing.sm),
                ClubAvatar(
                  club: athlete.club,
                  size: 28,
                  shape: ClubAvatarShape.circle,
                  fallbackLabel: club,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${athlete.lastName.toUpperCase()} ${athlete.firstName}'
                            .trim(),
                        style: AppTypography.body.copyWith(fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (club.isNotEmpty)
                        Text(club,
                            style: AppTypography.caption.copyWith(fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                if (penalty?.code.isNotEmpty == true) ...[
                  Text(penalty!.code,
                      style: AppTypography.caption
                          .copyWith(color: AppColors.statusError)),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Builder(
                  builder: (btnContext) => IconButton(
                    onPressed: () {
                      final box = btnContext.findRenderObject() as RenderBox;
                      onMenu(box.localToGlobal(Offset.zero));
                    },
                    icon: const Icon(Icons.more_vert),
                    color: AppColors.textMuted,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
```

- [ ] **Step 3: Verify it compiles and nothing regressed**

```bash
dart format lib/app/module/competitions/views/race_course_view.dart lib/app/core/translations/fr_FR.dart lib/app/core/translations/en_US.dart
flutter analyze lib/app/module/competitions lib/app/core/translations
flutter test
```

Expected: analyze clean apart from the pre-existing `file_names` infos on the two translation files and the `RadioListTile` deprecation infos in `heat_structure_dialog.dart`; the whole suite green.

- [ ] **Step 4: Commit**

```bash
git add lib/app/module/competitions/views/race_course_view.dart lib/app/core/translations/fr_FR.dart lib/app/core/translations/en_US.dart
git commit -m "feat(results): the screen that records a finishing order"
```

- [ ] **Step 5: Verify manually**

You cannot run this checklist from a shell — state in your report that it is outstanding and list it for the human. On a coastal race with a drawn série:

1. tapping athletes ranks them 1, 2, 3 and the banner keeps step;
2. the tie lock gives two athletes the same place and the next one skips;
3. undo takes back the last entry, scanned or tapped;
4. tapping a ranked athlete removes them and the rest renumber;
5. the row menu offers Forfait and Disqualifier, and a DQ code shows on the row;
6. a withdrawn athlete sinks to the bottom and takes no place, and the menu reinstates them;
7. scanning ranks by bracelet, refuses a bracelet from another heat, and stops itself when everyone is accounted for;
8. leaving and reopening the course shows the same ranking.

---

### Task 6: The Séries tab stops showing dashes

**Files:**
- Modify: `lib/app/module/competitions/controllers/race_structure_controller.dart`
- Modify: `lib/app/module/competitions/views/race_structure_view.dart`
- Test: `test/presentation/modules/competitions/controllers/race_structure_controller_test.dart`

**Interfaces:**
- Consumes: `placesOf` (Task 2); `ProgrammeRace.finishOrder` / `.penalties`, `CoursePenalty`, `CoursePenaltyKind` (Task 1).
- Produces, on `RaceStructureController`:
  - `int? placeIn(ProgrammeRace race, Athlete athlete)`
  - `CoursePenalty? penaltyIn(ProgrammeRace race, Athlete athlete)`

- [ ] **Step 1: Write the failing test**

Add this import at the top of `test/presentation/modules/competitions/controllers/race_structure_controller_test.dart`:

```dart
import 'package:live_ffss/app/domain/models/course_penalty.dart';
```

Append this group before the closing brace of `main()`:

```dart
  group('RaceStructureController results', () {
    test('reads a place out of the stored order', () async {
      when(() => raceRepo.getEntries(500)).thenAnswer((_) async => [
            entry(1, 7, athletes: [makeAthlete(31), makeAthlete(32)]),
          ]);
      await controller.load(race(500), competition);

      const drawn = ProgrammeRace(
        id: 1,
        number: 1,
        athleteIds: [31, 32],
        finishOrder: [
          [32],
          [31],
        ],
      );

      expect(controller.placeIn(drawn, makeAthlete(32)), 1);
      expect(controller.placeIn(drawn, makeAthlete(31)), 2);
    });

    test('an unscored race gives no place', () async {
      when(() => raceRepo.getEntries(500)).thenAnswer((_) async => const []);
      await controller.load(race(500), competition);

      const drawn = ProgrammeRace(id: 1, number: 1, athleteIds: [31]);

      expect(controller.placeIn(drawn, makeAthlete(31)), isNull);
      expect(controller.penaltyIn(drawn, makeAthlete(31)), isNull);
    });

    test('reads a withdrawal and its code', () async {
      when(() => raceRepo.getEntries(500)).thenAnswer((_) async => const []);
      await controller.load(race(500), competition);

      const drawn = ProgrammeRace(
        id: 1,
        number: 1,
        athleteIds: [31],
        penalties: [
          CoursePenalty(
            athleteId: 31,
            kind: CoursePenaltyKind.disqualified,
            code: '4.7',
          ),
        ],
      );

      final penalty = controller.penaltyIn(drawn, makeAthlete(31));

      expect(penalty?.kind, CoursePenaltyKind.disqualified);
      expect(penalty?.code, '4.7');
    });
  });
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `flutter test test/presentation/modules/competitions/controllers/race_structure_controller_test.dart`

Expected: FAIL at compile — `The method 'placeIn' isn't defined for the type 'RaceStructureController'`.

- [ ] **Step 3: Add the two readers to the controller**

Add the imports to `race_structure_controller.dart`:

```dart
import 'package:live_ffss/app/domain/models/course_penalty.dart';
import 'package:live_ffss/app/domain/models/course_ranking.dart';
```

Add them beside `athletesOf`:

```dart
  /// The place this athlete took in a scored race, or null while it has no
  /// result. Computed from the stored order by the same function the entry
  /// screen uses — the two therefore cannot disagree about a ranking.
  int? placeIn(ProgrammeRace race, Athlete athlete) =>
      placesOf(race.finishOrder)[athlete.id];

  /// The withdrawal this athlete carries in a scored race, if any.
  CoursePenalty? penaltyIn(ProgrammeRace race, Athlete athlete) {
    for (final penalty in race.penalties) {
      if (penalty.athleteId == athlete.id) return penalty;
    }
    return null;
  }
```

- [ ] **Step 4: Show them in the row**

In `lib/app/module/competitions/views/race_structure_view.dart`, add the import:

```dart
import 'package:live_ffss/app/domain/models/course_penalty.dart';
```

`_CourseTile` builds `_CompetitorRow` — replace that call with:

```dart
                _CompetitorRow(
                  athlete: athletes[i],
                  last: i == athletes.length - 1,
                  highlighted: controller.filter.value.isNotEmpty &&
                      controller.matchesFilter(athletes[i]),
                  place: controller.placeIn(race, athletes[i]),
                  penalty: controller.penaltyIn(race, athletes[i]),
                ),
```

In `_CompetitorRow`, add the two fields:

```dart
  const _CompetitorRow({
    required this.athlete,
    required this.last,
    required this.highlighted,
    required this.place,
    required this.penalty,
  });

  /// The place this athlete took, null while the race has no result.
  final int? place;

  /// The withdrawal they carry, if any.
  final CoursePenalty? penalty;
```

Replace the left badge's `Text('—', ...)` with:

```dart
            child: Text(
              switch (penalty?.kind) {
                CoursePenaltyKind.forfeit => 'forfeit_short'.tr,
                CoursePenaltyKind.disqualified => 'disqualified_short'.tr,
                _ => place?.toString() ?? '—',
              },
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                fontWeight: FontWeight.w800,
                color: penalty != null
                    ? AppColors.statusError
                    : place != null
                        ? AppColors.primary
                        : AppColors.textMuted,
              ),
            ),
```

Replace the trailing `Text('—', ...)` with:

```dart
          Text(
            penalty?.code.isNotEmpty == true ? penalty!.code : '—',
            style: AppTypography.caption.copyWith(
                color: penalty?.code.isNotEmpty == true
                    ? AppColors.statusError
                    : AppColors.textMuted),
          ),
```

- [ ] **Step 5: Run the tests to verify they pass**

Run: `flutter test`

Expected: PASS, 3 further tests, whole suite green.

- [ ] **Step 6: Format, analyze and commit**

```bash
dart format lib/app/module/competitions/controllers/race_structure_controller.dart lib/app/module/competitions/views/race_structure_view.dart test/presentation/modules/competitions/controllers/race_structure_controller_test.dart
flutter analyze lib/app/module/competitions
git add lib/app/module/competitions test/presentation/modules/competitions/controllers/race_structure_controller_test.dart
git commit -m "feat(structure): show the result a scored race recorded"
```

---

## Notes for the executor

- `placesOf` is the single source of a place. Neither the entry screen nor the Séries tab may compute one another way — that is how two screens start disagreeing about a ranking.
- The tie lock is deliberately a mode, not a gesture on a ranked athlete: a bracelet cannot be long-pressed, and one procedure has to serve both entry methods. Do not "improve" it into a long-press.
- There is no Save button anywhere in this plan, and that is deliberate. See the spec's "Persisting".
- `RaceCourseController` grows across Tasks 3 and 4. If it feels large by the end of Task 4, report it as a concern rather than splitting files on your own.
- Task 5's `_askDisqualification` accepts an empty code — a referee may disqualify before knowing the article. That is intended; do not add a validator.
