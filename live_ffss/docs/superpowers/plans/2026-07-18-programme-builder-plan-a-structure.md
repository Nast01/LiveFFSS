# Programme Builder — Plan A (Structure) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** On-device authoring of a côtier competition's round structure — define série/quart/demi/finale per épreuve × category, review it as a bracket — stored locally, with the FFSS sync path stubbed.

**Architecture:** A lean freezed model (`CompetitionProgramme → EventStructure → RoundLevel → ProgrammeRace`) persisted per competition via `ProgrammeService` (secure storage). Pure arithmetic proposes a default structure from entry counts. A GetX two-tab module launched from competition detail hosts the structure overview, editor, and read-only bracket. FFSS write-sync is a typed `UnimplementedError` seam. Scheduling (placements, the FFSS mapper) is Plan B.

**Tech Stack:** Flutter, GetX, freezed + json_serializable, flutter_secure_storage, mocktail.

**Spec:** `docs/superpowers/specs/2026-07-18-competition-programme-builder-design.md`

## Global Constraints

- **Dart/Flutter binaries are not on PATH.** Use `C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat` and `dart.bat`.
- **Codegen:** after creating/editing a freezed file, run
  `C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\dart.bat run build_runner build --delete-conflicting-outputs`. Commit the generated `.freezed.dart`/`.g.dart` alongside the source (they are treated as source here).
- **Analyzer is strict:** `strict-casts: true`, `strict-raw-types: true`. No `dynamic` coercions.
- **Never hand-edit a generated `.freezed.dart`/`.g.dart`** — build_runner overwrites it. If a round-trip needs work, fix the model or the test, not the generated file.
- **`explicit_to_json` is false** (no `build.yaml`): `toJson()` leaves nested freezed objects as raw objects; `jsonEncode` serialises them recursively. A model round-trip test must go through the JSON string — `fromJson(jsonDecode(jsonEncode(x.toJson())))` — not a bare `fromJson(x.toJson())`, which fails on nested objects. This matches how `ProgrammeService` persists.
- **Freezed idiom:** file starts with imports, then `part '<name>.freezed.dart';` then `part '<name>.g.dart';`; `@freezed class X with _$X { const factory X({...}) = _X; factory X.fromJson(Map<String, dynamic> json) => _$XFromJson(json); }`. Enums are bare `enum X { ..., unknown }` at file top, `unknown` last.
- **Domain models carry no `@JsonKey`** (French keys live only on DTOs). These new models are pure domain.
- **Controller discipline (enforced by review):** no `Get.snackbar` / `Get.dialog` / `.tr` / `Get.context!` / `BuildContext` params in controllers; user feedback via `Rxn<UiMessage>`; constructor injection only, never `Get.find()` in a controller body; catch `AppException`, never raw `Exception`.
- **`TextEditingController`s live in views** (`StatefulWidget`), not controllers.
- **mocktail:** `class _MockX extends Mock implements X {}` (never `extends Fake`); register fallbacks in `setUpAll` for non-primitive `any()` matchers.
- **No widget tests, no integration tests.** Test logic layers (models/mappers/service/repo/controllers/pure functions) only.
- **Imports** use `package:live_ffss/...`; module-internal imports may use relative `../controllers/...` as existing bindings do.
- **Local ids** are ints allocated from `CompetitionProgramme.nextLocalId` (starts at 1, increments per allocation). They are NOT FFSS server ids.
- Use `git add <explicit paths>` only — the working tree may carry unrelated modified files; never `git add -A` / `git add .`.

---

### Task 1: Leaf models — enums, ProgrammeSite, RacePlacement

**Files:**
- Create: `lib/app/domain/models/programme_site.dart`
- Create: `lib/app/domain/models/race_placement.dart`
- Test: `test/data/models/programme_leaf_models_test.dart`

**Interfaces:**
- Produces:
  - `enum SiteType { cotier, sable, unknown }`
  - `ProgrammeSite({required int id, required String name, required SiteType type})`
  - `RacePlacement({required int siteId, required DateTime beginHour, @Default(10) int durationMinutes})`

- [ ] **Step 1: Write the failing test**

Create `test/data/models/programme_leaf_models_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/programme_site.dart';
import 'package:live_ffss/app/domain/models/race_placement.dart';

void main() {
  group('ProgrammeSite', () {
    test('round-trips through JSON with its enum', () {
      const site = ProgrammeSite(id: 3, name: 'Côtier 1', type: SiteType.cotier);
      final json = site.toJson();
      expect(ProgrammeSite.fromJson(json), site);
    });
  });

  group('RacePlacement', () {
    test('defaults durationMinutes to 10', () {
      final p = RacePlacement(siteId: 1, beginHour: DateTime(2026, 6, 13, 9));
      expect(p.durationMinutes, 10);
    });

    test('round-trips through JSON', () {
      final p = RacePlacement(
        siteId: 1,
        beginHour: DateTime(2026, 6, 13, 9, 10),
        durationMinutes: 15,
      );
      expect(RacePlacement.fromJson(p.toJson()), p);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/data/models/programme_leaf_models_test.dart
```

Expected: FAIL — the model files do not exist.

- [ ] **Step 3: Write the models**

Create `lib/app/domain/models/programme_site.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'programme_site.freezed.dart';
part 'programme_site.g.dart';

enum SiteType { cotier, sable, unknown }

@freezed
class ProgrammeSite with _$ProgrammeSite {
  const factory ProgrammeSite({
    required int id,
    required String name,
    required SiteType type,
  }) = _ProgrammeSite;

  factory ProgrammeSite.fromJson(Map<String, dynamic> json) =>
      _$ProgrammeSiteFromJson(json);
}
```

Create `lib/app/domain/models/race_placement.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'race_placement.freezed.dart';
part 'race_placement.g.dart';

@freezed
class RacePlacement with _$RacePlacement {
  const factory RacePlacement({
    required int siteId,
    required DateTime beginHour,
    @Default(10) int durationMinutes,
  }) = _RacePlacement;

  factory RacePlacement.fromJson(Map<String, dynamic> json) =>
      _$RacePlacementFromJson(json);
}
```

- [ ] **Step 4: Run codegen**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\dart.bat run build_runner build --delete-conflicting-outputs
```

Expected: generates `programme_site.freezed.dart`/`.g.dart` and `race_placement.freezed.dart`/`.g.dart`, "Succeeded".

- [ ] **Step 5: Run test to verify it passes**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/data/models/programme_leaf_models_test.dart
```

Expected: PASS — 3 tests.

- [ ] **Step 6: Commit**

```bash
git add lib/app/domain/models/programme_site.dart lib/app/domain/models/programme_site.freezed.dart lib/app/domain/models/programme_site.g.dart lib/app/domain/models/race_placement.dart lib/app/domain/models/race_placement.freezed.dart lib/app/domain/models/race_placement.g.dart test/data/models/programme_leaf_models_test.dart
git commit -m "feat(programme): add ProgrammeSite and RacePlacement models"
```

---

### Task 2: Structure tree — ProgrammeRace, RoundLevel, EventStructure, CompetitionProgramme

**Files:**
- Create: `lib/app/domain/models/programme_race.dart`
- Create: `lib/app/domain/models/round_level.dart`
- Create: `lib/app/domain/models/event_structure.dart`
- Create: `lib/app/domain/models/competition_programme.dart`
- Test: `test/data/models/competition_programme_test.dart`

**Interfaces:**
- Consumes: `RacePlacement`, `ProgrammeSite` (Task 1)
- Produces:
  - `enum RoundType { serie, quart, demi, finale, unknown }`
  - `ProgrammeRace({required int id, required int number, @Default(<int>[]) List<int> sourceRaceIds, RacePlacement? placement})`
  - `RoundLevel({required RoundType type, @Default(0) int qualifiersPerRace, @Default(<ProgrammeRace>[]) List<ProgrammeRace> races})`
  - `EventStructure({required int raceId, required int categoryId, required String raceLabel, required String categoryLabel, @Default(8) int spotsPerRace, @Default(<RoundLevel>[]) List<RoundLevel> levels})`
  - `CompetitionProgramme({required int competitionId, @Default(1) int nextLocalId, @Default(<ProgrammeSite>[]) List<ProgrammeSite> sites, @Default(<EventStructure>[]) List<EventStructure> structures})`

- [ ] **Step 1: Write the failing test**

Create `test/data/models/competition_programme_test.dart`:

```dart
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/race_placement.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';

void main() {
  final programme = CompetitionProgramme(
    competitionId: 42,
    nextLocalId: 5,
    structures: [
      EventStructure(
        raceId: 100,
        categoryId: 7,
        raceLabel: '100m Nage côtière',
        categoryLabel: 'Cadets',
        spotsPerRace: 8,
        levels: [
          RoundLevel(
            type: RoundType.serie,
            qualifiersPerRace: 2,
            races: const [
              ProgrammeRace(id: 1, number: 1),
              ProgrammeRace(id: 2, number: 2),
            ],
          ),
          RoundLevel(
            type: RoundType.finale,
            races: [
              ProgrammeRace(
                id: 3,
                number: 1,
                sourceRaceIds: const [1, 2],
                placement: RacePlacement(
                  siteId: 9,
                  beginHour: DateTime(2026, 6, 13, 9, 30),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  test('round-trips the full tree through JSON', () {
    // This project has no build.yaml, so json_serializable runs with
    // explicit_to_json:false: toJson() leaves nested freezed objects as-is,
    // and jsonEncode recursively serialises them. This mirrors how
    // ProgrammeService actually persists (jsonEncode(toJson()) →
    // jsonDecode → fromJson) — round-tripping through the JSON string is the
    // real path, not a bare fromJson(toJson()).
    final restored = CompetitionProgramme.fromJson(
      jsonDecode(jsonEncode(programme.toJson())) as Map<String, dynamic>,
    );
    expect(restored, programme);
  });

  test('defaults: empty programme has nextLocalId 1 and no structures', () {
    const p = CompetitionProgramme(competitionId: 1);
    expect(p.nextLocalId, 1);
    expect(p.structures, isEmpty);
    expect(p.sites, isEmpty);
  });

  test('an unscheduled race has a null placement', () {
    const race = ProgrammeRace(id: 1, number: 1);
    expect(race.placement, isNull);
    expect(race.sourceRaceIds, isEmpty);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/data/models/competition_programme_test.dart
```

Expected: FAIL — the model files do not exist.

- [ ] **Step 3: Write the models**

Create `lib/app/domain/models/programme_race.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/race_placement.dart';

part 'programme_race.freezed.dart';
part 'programme_race.g.dart';

@freezed
class ProgrammeRace with _$ProgrammeRace {
  const factory ProgrammeRace({
    required int id,
    required int number,
    // opt1/opt2 wiring: ids of the feeding races at the previous level.
    // Empty at the séries level and for opt2-with-no-selection.
    @Default(<int>[]) List<int> sourceRaceIds,
    // null until the race is scheduled (Plan B fills this).
    RacePlacement? placement,
  }) = _ProgrammeRace;

  factory ProgrammeRace.fromJson(Map<String, dynamic> json) =>
      _$ProgrammeRaceFromJson(json);
}
```

Create `lib/app/domain/models/round_level.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';

part 'round_level.freezed.dart';
part 'round_level.g.dart';

enum RoundType { serie, quart, demi, finale, unknown }

@freezed
class RoundLevel with _$RoundLevel {
  const factory RoundLevel({
    required RoundType type,
    // Operator metadata; drives no computation in v1 (no seeding).
    @Default(0) int qualifiersPerRace,
    @Default(<ProgrammeRace>[]) List<ProgrammeRace> races,
  }) = _RoundLevel;

  factory RoundLevel.fromJson(Map<String, dynamic> json) =>
      _$RoundLevelFromJson(json);
}
```

Create `lib/app/domain/models/event_structure.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';

part 'event_structure.freezed.dart';
part 'event_structure.g.dart';

@freezed
class EventStructure with _$EventStructure {
  const factory EventStructure({
    required int raceId,
    required int categoryId,
    required String raceLabel,
    required String categoryLabel,
    // Race size; drives seriesCount = ceil(entries / spotsPerRace).
    @Default(8) int spotsPerRace,
    @Default(<RoundLevel>[]) List<RoundLevel> levels,
  }) = _EventStructure;

  factory EventStructure.fromJson(Map<String, dynamic> json) =>
      _$EventStructureFromJson(json);
}
```

Create `lib/app/domain/models/competition_programme.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/programme_site.dart';

part 'competition_programme.freezed.dart';
part 'competition_programme.g.dart';

@freezed
class CompetitionProgramme with _$CompetitionProgramme {
  const factory CompetitionProgramme({
    required int competitionId,
    // Monotonic counter for local entity ids (races, sites). Starts at 1.
    @Default(1) int nextLocalId,
    @Default(<ProgrammeSite>[]) List<ProgrammeSite> sites,
    @Default(<EventStructure>[]) List<EventStructure> structures,
  }) = _CompetitionProgramme;

  factory CompetitionProgramme.fromJson(Map<String, dynamic> json) =>
      _$CompetitionProgrammeFromJson(json);
}
```

- [ ] **Step 4: Run codegen**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\dart.bat run build_runner build --delete-conflicting-outputs
```

Expected: generates the four models' `.freezed.dart`/`.g.dart`, "Succeeded".

- [ ] **Step 5: Run test to verify it passes**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/data/models/competition_programme_test.dart
```

Expected: PASS — 3 tests.

- [ ] **Step 6: Commit**

```bash
git add lib/app/domain/models/programme_race.dart lib/app/domain/models/programme_race.freezed.dart lib/app/domain/models/programme_race.g.dart lib/app/domain/models/round_level.dart lib/app/domain/models/round_level.freezed.dart lib/app/domain/models/round_level.g.dart lib/app/domain/models/event_structure.dart lib/app/domain/models/event_structure.freezed.dart lib/app/domain/models/event_structure.g.dart lib/app/domain/models/competition_programme.dart lib/app/domain/models/competition_programme.freezed.dart lib/app/domain/models/competition_programme.g.dart test/data/models/competition_programme_test.dart
git commit -m "feat(programme): add the structure tree models"
```

---

### Task 3: Round arithmetic (pure)

The default-structure proposal and the séries count. Pure functions, no I/O — the operator adjusts the result afterwards.

**Files:**
- Create: `lib/app/domain/models/structure_generator.dart`
- Test: `test/data/models/structure_generator_test.dart`

**Interfaces:**
- Consumes: `RoundType` (Task 2)
- Produces:
  - `int seriesCount(int entryCount, int spotsPerRace)`
  - `typedef LevelPlan = ({RoundType type, int raceCount})`
  - `List<LevelPlan> proposeLevels({required int entryCount, required int spotsPerRace})`

- [ ] **Step 1: Write the failing test**

Create `test/data/models/structure_generator_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/domain/models/structure_generator.dart';

void main() {
  group('seriesCount', () {
    test('rounds up to fill the last série', () {
      expect(seriesCount(20, 8), 3); // 8 + 8 + 4
      expect(seriesCount(16, 8), 2);
      expect(seriesCount(17, 8), 3);
    });

    test('is zero for no entries', () {
      expect(seriesCount(0, 8), 0);
    });
  });

  group('proposeLevels', () {
    test('few enough entries → a single finale', () {
      expect(proposeLevels(entryCount: 6, spotsPerRace: 8),
          [(type: RoundType.finale, raceCount: 1)]);
    });

    test('exactly one race worth → a single finale', () {
      expect(proposeLevels(entryCount: 8, spotsPerRace: 8),
          [(type: RoundType.finale, raceCount: 1)]);
    });

    test('more than one race worth → séries then finale', () {
      expect(proposeLevels(entryCount: 20, spotsPerRace: 8), [
        (type: RoundType.serie, raceCount: 3),
        (type: RoundType.finale, raceCount: 1),
      ]);
    });

    test('no entries → an empty proposal', () {
      expect(proposeLevels(entryCount: 0, spotsPerRace: 8), isEmpty);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/data/models/structure_generator_test.dart
```

Expected: FAIL — `structure_generator.dart` does not exist.

- [ ] **Step 3: Write the implementation**

Create `lib/app/domain/models/structure_generator.dart`:

```dart
import 'package:live_ffss/app/domain/models/round_level.dart';

/// A proposed level: its round type and how many races it holds. The caller
/// materialises `ProgrammeRace`s (with ids) from this.
typedef LevelPlan = ({RoundType type, int raceCount});

/// Number of séries needed to seat [entryCount] athletes at [spotsPerRace] per
/// race, rounding up so the last série absorbs the remainder.
int seriesCount(int entryCount, int spotsPerRace) {
  if (entryCount <= 0 || spotsPerRace <= 0) return 0;
  return (entryCount / spotsPerRace).ceil();
}

/// The generic default structure: one finale when everyone fits in a single
/// race, otherwise séries feeding a finale. No FFSS rulebook — a starting
/// point the operator adjusts.
List<LevelPlan> proposeLevels({
  required int entryCount,
  required int spotsPerRace,
}) {
  final series = seriesCount(entryCount, spotsPerRace);
  if (series == 0) return const [];
  if (series == 1) return const [(type: RoundType.finale, raceCount: 1)];
  return [
    (type: RoundType.serie, raceCount: series),
    (type: RoundType.finale, raceCount: 1),
  ];
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/data/models/structure_generator_test.dart
```

Expected: PASS — 6 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/app/domain/models/structure_generator.dart test/data/models/structure_generator_test.dart
git commit -m "feat(programme): add round-structure arithmetic"
```

---

### Task 4: Presentation formatting extensions

Computed/display helpers kept out of the domain models per project convention.

**Files:**
- Create: `lib/app/presentation/modules/programme/programme_formatting.dart`
- Test: `test/presentation/modules/programme/programme_formatting_test.dart`

**Interfaces:**
- Consumes: `RacePlacement`, `RoundType`, `EventStructure`, `RoundLevel` (Tasks 1–2)
- Produces:
  - `extension RacePlacementFormatting on RacePlacement { DateTime get endHour }`
  - `extension RoundTypeFormatting on RoundType { String get labelKey }`
  - `extension EventStructureFormatting on EventStructure { String get summaryChainKeyList }` → returns a `List<String>` of translation keys/labels? Use a plain summary: `List<RoundType> get chain` (the ordered level types) and `bool get isDefined`.

- [ ] **Step 1: Write the failing test**

Create `test/presentation/modules/programme/programme_formatting_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/race_placement.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/presentation/modules/programme/programme_formatting.dart';

void main() {
  test('endHour is beginHour plus the duration', () {
    final p = RacePlacement(
      siteId: 1,
      beginHour: DateTime(2026, 6, 13, 9),
      durationMinutes: 10,
    );
    expect(p.endHour, DateTime(2026, 6, 13, 9, 10));
  });

  test('RoundType.labelKey maps each arm to a translation key', () {
    expect(RoundType.serie.labelKey, 'round_serie');
    expect(RoundType.quart.labelKey, 'round_quart');
    expect(RoundType.demi.labelKey, 'round_demi');
    expect(RoundType.finale.labelKey, 'round_finale');
    expect(RoundType.unknown.labelKey, 'round_unknown');
  });

  test('EventStructure.chain lists the level types in order', () {
    const s = EventStructure(
      raceId: 1,
      categoryId: 1,
      raceLabel: 'x',
      categoryLabel: 'y',
      levels: [
        RoundLevel(type: RoundType.serie),
        RoundLevel(type: RoundType.finale),
      ],
    );
    expect(s.chain, [RoundType.serie, RoundType.finale]);
    expect(s.isDefined, isTrue);
  });

  test('an EventStructure with no levels is not defined', () {
    const s = EventStructure(
      raceId: 1,
      categoryId: 1,
      raceLabel: 'x',
      categoryLabel: 'y',
    );
    expect(s.isDefined, isFalse);
    expect(s.chain, isEmpty);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/presentation/modules/programme/programme_formatting_test.dart
```

Expected: FAIL — the extension file does not exist.

- [ ] **Step 3: Write the extensions**

Create `lib/app/presentation/modules/programme/programme_formatting.dart`:

```dart
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/race_placement.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';

extension RacePlacementFormatting on RacePlacement {
  DateTime get endHour => beginHour.add(Duration(minutes: durationMinutes));
}

extension RoundTypeFormatting on RoundType {
  String get labelKey => switch (this) {
        RoundType.serie => 'round_serie',
        RoundType.quart => 'round_quart',
        RoundType.demi => 'round_demi',
        RoundType.finale => 'round_finale',
        RoundType.unknown => 'round_unknown',
      };
}

extension EventStructureFormatting on EventStructure {
  List<RoundType> get chain => levels.map((l) => l.type).toList();
  bool get isDefined => levels.isNotEmpty;
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/presentation/modules/programme/programme_formatting_test.dart
```

Expected: PASS — 4 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/app/presentation/modules/programme/programme_formatting.dart test/presentation/modules/programme/programme_formatting_test.dart
git commit -m "feat(programme): add presentation formatting for the structure"
```

---

### Task 5: ProgrammeService (local persistence)

**Files:**
- Create: `lib/app/data/services/programme_service.dart`
- Test: `test/data/services/programme_service_test.dart`

**Interfaces:**
- Consumes: `CompetitionProgramme` (Task 2), `FlutterSecureStorage`
- Produces: `ProgrammeService(FlutterSecureStorage)` — `GetxService` with:
  - `Rxn<CompetitionProgramme> current`
  - `Future<void> load(int competitionId)` — reads `programme_<id>`, decodes or creates an empty programme, sets `current`.
  - `Future<void> save(CompetitionProgramme programme)` — sets `current` and writes JSON.
  - `int allocateId()` — returns `current.value!.nextLocalId` and bumps it in `current` (caller persists via a later `save`).

- [ ] **Step 1: Write the failing test**

Create `test/data/services/programme_service_test.dart`:

```dart
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:mocktail/mocktail.dart';

class _MockStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockStorage storage;
  late ProgrammeService service;

  setUpAll(() => registerFallbackValue(''));

  setUp(() {
    storage = _MockStorage();
    service = ProgrammeService(storage);
  });

  group('load', () {
    test('creates an empty programme when storage is empty', () async {
      when(() => storage.read(key: 'programme_42'))
          .thenAnswer((_) async => null);

      await service.load(42);

      expect(service.current.value,
          const CompetitionProgramme(competitionId: 42));
    });

    test('decodes an existing programme', () async {
      const stored = CompetitionProgramme(competitionId: 42, nextLocalId: 9);
      when(() => storage.read(key: 'programme_42'))
          .thenAnswer((_) async => jsonEncode(stored.toJson()));

      await service.load(42);

      expect(service.current.value, stored);
    });

    test('falls back to an empty programme on a corrupt payload', () async {
      when(() => storage.read(key: 'programme_42'))
          .thenAnswer((_) async => 'not json');

      await service.load(42);

      expect(service.current.value,
          const CompetitionProgramme(competitionId: 42));
    });
  });

  group('save', () {
    test('writes the JSON and updates current', () async {
      when(() => storage.write(
          key: any(named: 'key'),
          value: any(named: 'value'))).thenAnswer((_) async {});
      const p = CompetitionProgramme(competitionId: 42, nextLocalId: 3);

      await service.save(p);

      expect(service.current.value, p);
      verify(() => storage.write(
          key: 'programme_42', value: jsonEncode(p.toJson()))).called(1);
    });
  });

  group('allocateId', () {
    test('returns the current id and bumps the counter', () async {
      when(() => storage.read(key: 'programme_42'))
          .thenAnswer((_) async => null);
      await service.load(42);

      final first = service.allocateId();
      final second = service.allocateId();

      expect(first, 1);
      expect(second, 2);
      expect(service.current.value!.nextLocalId, 3);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/data/services/programme_service_test.dart
```

Expected: FAIL — `programme_service.dart` does not exist.

- [ ] **Step 3: Write the service**

Create `lib/app/data/services/programme_service.dart`:

```dart
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';

/// On-device store for a competition's authored programme. One JSON blob per
/// competition, keyed `programme_<competitionId>`. The single source of truth
/// while FFSS write endpoints are undocumented.
class ProgrammeService extends GetxService {
  ProgrammeService(this._storage);

  final FlutterSecureStorage _storage;
  final Rxn<CompetitionProgramme> current = Rxn<CompetitionProgramme>();

  static String _key(int competitionId) => 'programme_$competitionId';

  Future<void> load(int competitionId) async {
    final raw = await _storage.read(key: _key(competitionId));
    current.value = _decode(raw, competitionId);
  }

  Future<void> save(CompetitionProgramme programme) async {
    current.value = programme;
    await _storage.write(
      key: _key(programme.competitionId),
      value: jsonEncode(programme.toJson()),
    );
  }

  /// Returns the next local id and advances the counter in [current]. The
  /// caller persists the bump with a subsequent [save].
  int allocateId() {
    final p = current.value!;
    current.value = p.copyWith(nextLocalId: p.nextLocalId + 1);
    return p.nextLocalId;
  }

  CompetitionProgramme _decode(String? raw, int competitionId) {
    if (raw == null || raw.isEmpty) {
      return CompetitionProgramme(competitionId: competitionId);
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return CompetitionProgramme.fromJson(json);
    } catch (_) {
      // Corrupt payload — treat as absent; the next save self-heals.
      return CompetitionProgramme(competitionId: competitionId);
    }
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/data/services/programme_service_test.dart
```

Expected: PASS — 6 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/app/data/services/programme_service.dart test/data/services/programme_service_test.dart
git commit -m "feat(programme): add ProgrammeService local persistence"
```

---

### Task 6: Sync seam + DI registration

The typed `UnimplementedError` seam for future FFSS write-sync, plus wiring `ProgrammeService` and the seam into `InitialBinding`.

**Files:**
- Create: `lib/app/data/datasources/programme_remote_datasource.dart`
- Create: `lib/app/data/repositories/programme_repository.dart`
- Modify: `lib/app/core/di/initial_binding.dart`
- Test: `test/data/repositories/programme_repository_test.dart`

**Interfaces:**
- Consumes: `CompetitionProgramme` (Task 2), `ProgrammeService` (Task 5)
- Produces:
  - `abstract class ProgrammeRemoteDataSource { Future<void> pushProgramme(CompetitionProgramme programme); }` + `ProgrammeRemoteDataSourceImpl` (stub)
  - `abstract class ProgrammeRepository { Future<void> push(CompetitionProgramme programme); }` + `ProgrammeRepositoryImpl(ProgrammeRemoteDataSource)`
  - `Get.find<ProgrammeService>()`, `Get.find<ProgrammeRepository>()` available app-wide

- [ ] **Step 1: Write the failing test**

Create `test/data/repositories/programme_repository_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/datasources/programme_remote_datasource.dart';
import 'package:live_ffss/app/data/repositories/programme_repository.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';

void main() {
  test('push is not implemented until FFSS documents the endpoints', () {
    final repo = ProgrammeRepositoryImpl(ProgrammeRemoteDataSourceImpl());
    expect(
      () => repo.push(const CompetitionProgramme(competitionId: 1)),
      throwsA(isA<UnimplementedError>()),
    );
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/data/repositories/programme_repository_test.dart
```

Expected: FAIL — the seam files do not exist.

- [ ] **Step 3: Write the seam**

Create `lib/app/data/datasources/programme_remote_datasource.dart`:

```dart
import 'package:live_ffss/app/domain/models/competition_programme.dart';

abstract class ProgrammeRemoteDataSource {
  Future<void> pushProgramme(CompetitionProgramme programme);
}

/// Stub: FFSS has no documented write endpoints for créneaux/courses/parties
/// yet (only réunions). The local `ProgrammeService` is the source of truth;
/// wire this — plus the lean-model → Meeting/Slot/Run mapper — when the FFSS
/// endpoints land. Mirrors `ResultRemoteDataSourceImpl`.
class ProgrammeRemoteDataSourceImpl implements ProgrammeRemoteDataSource {
  ProgrammeRemoteDataSourceImpl();

  @override
  Future<void> pushProgramme(CompetitionProgramme programme) {
    throw UnimplementedError(
      'pushProgramme: FFSS write endpoints for créneaux/courses/parties are '
      'not documented. Local storage is the source of truth until then.',
    );
  }
}
```

Create `lib/app/data/repositories/programme_repository.dart`:

```dart
import 'package:live_ffss/app/data/datasources/programme_remote_datasource.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';

abstract class ProgrammeRepository {
  Future<void> push(CompetitionProgramme programme);
}

class ProgrammeRepositoryImpl implements ProgrammeRepository {
  ProgrammeRepositoryImpl(this._dataSource);

  final ProgrammeRemoteDataSource _dataSource;

  @override
  Future<void> push(CompetitionProgramme programme) =>
      _dataSource.pushProgramme(programme);
}
```

- [ ] **Step 4: Register in InitialBinding**

In `lib/app/core/di/initial_binding.dart`, add the imports:

```dart
import 'package:live_ffss/app/data/datasources/programme_remote_datasource.dart';
import 'package:live_ffss/app/data/repositories/programme_repository.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
```

Add the seam registration after the ranking data layer block (the section registering `RankingRepository`), before section "8. Long-lived state holders":

```dart
    // 5g. Programme sync seam (stub — FFSS write endpoints TBD; see datasource)
    Get.put<ProgrammeRemoteDataSource>(
      ProgrammeRemoteDataSourceImpl(),
      permanent: true,
    );
    Get.put<ProgrammeRepository>(
      ProgrammeRepositoryImpl(Get.find<ProgrammeRemoteDataSource>()),
      permanent: true,
    );
```

Add the service registration in section "8. Long-lived state holders", after the `UserPreferencesService` block:

```dart
    await Get.putAsync<ProgrammeService>(
      () async => ProgrammeService(Get.find<FlutterSecureStorage>()),
    );
```

- [ ] **Step 5: Run test + analyze to verify**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/data/repositories/programme_repository_test.dart
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat analyze lib/app/core/di/ lib/app/data/
```

Expected: test PASS (1 test); analyze `No issues found!`.

- [ ] **Step 6: Commit**

```bash
git add lib/app/data/datasources/programme_remote_datasource.dart lib/app/data/repositories/programme_repository.dart lib/app/core/di/initial_binding.dart test/data/repositories/programme_repository_test.dart
git commit -m "feat(programme): add sync seam and register DI"
```

---

### Task 7: Translations

**Files:**
- Modify: `lib/app/core/translations/fr_fr.dart`
- Modify: `lib/app/core/translations/en_us.dart`

**Interfaces:**
- Produces the keys used by later view tasks: `programme`, `structure`, `not_defined`, `direct_final`, `engaged`, `spots_per_race`, `qualifiers_per_race`, `races_count`, `add_level`, `propose_structure`, `generate_default_all`, `view_bracket`, `all_to_all`, `customize`, `round_serie`, `round_quart`, `round_demi`, `round_finale`, `round_unknown`, `no_structures`.

- [ ] **Step 1: Add the French keys**

Append to the map in `lib/app/core/translations/fr_fr.dart`, before the final `};`:

```dart
  // Programme builder
  'programme': 'Programme',
  'structure': 'Structure',
  'not_defined': 'non défini',
  'direct_final': 'finale directe',
  'engaged': 'engagés',
  'spots_per_race': 'places/course',
  'qualifiers_per_race': 'qualifiés/course',
  'races_count': 'courses',
  'add_level': 'Ajouter un niveau',
  'propose_structure': 'Proposer une structure',
  'generate_default_all': 'Générer une structure par défaut (tout)',
  'view_bracket': 'Voir le bracket',
  'all_to_all': 'toutes → toutes',
  'customize': 'personnaliser',
  'round_serie': 'Séries',
  'round_quart': 'Quarts',
  'round_demi': 'Demies',
  'round_finale': 'Finale',
  'round_unknown': 'Tour',
  'no_structures': 'Aucune épreuve à structurer',
```

- [ ] **Step 2: Add the English keys**

Append to the map in `lib/app/core/translations/en_us.dart`, before the final `};`:

```dart
  // Programme builder
  'programme': 'Programme',
  'structure': 'Structure',
  'not_defined': 'not defined',
  'direct_final': 'straight to final',
  'engaged': 'entries',
  'spots_per_race': 'spots/race',
  'qualifiers_per_race': 'qualifiers/race',
  'races_count': 'races',
  'add_level': 'Add a level',
  'propose_structure': 'Propose a structure',
  'generate_default_all': 'Generate a default structure (all)',
  'view_bracket': 'View bracket',
  'all_to_all': 'all → all',
  'customize': 'customize',
  'round_serie': 'Heats',
  'round_quart': 'Quarters',
  'round_demi': 'Semis',
  'round_finale': 'Final',
  'round_unknown': 'Round',
  'no_structures': 'No event to structure',
```

- [ ] **Step 3: Verify no duplicate keys**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat analyze lib/app/core/translations/
```

Expected: `No issues found!` apart from the two pre-existing `en_US.dart`/`fr_FR.dart` file-name `info`s (a duplicate map key would be an error, so this catches accidental redefinitions).

- [ ] **Step 4: Commit**

```bash
git add lib/app/core/translations/fr_fr.dart lib/app/core/translations/en_us.dart
git commit -m "feat(programme): add programme builder translation keys"
```

---

### Task 8: ProgrammeController + route + binding + entry point

The shell controller: loads the competition's épreuves × categories with entry counts, merges with the stored programme, exposes the overview rows and the two-tab index.

**Files:**
- Create: `lib/app/module/programme/controllers/programme_controller.dart`
- Create: `lib/app/module/programme/bindings/programme_binding.dart`
- Modify: `lib/app/routes/app_routes.dart`
- Modify: `lib/app/routes/app_pages.dart`
- Modify: `lib/app/module/competitions/views/competition_detail_view.dart`
- Test: `test/presentation/modules/programme/controllers/programme_controller_test.dart`

**Interfaces:**
- Consumes: `RaceRepository` (`getRaces(int)`, `getEntries(int)`), `ProgrammeService` (Task 5), `Race`, `Category`, `Entry`, `Competition`, `EventStructure`
- Produces:
  - `Routes.programme = '/programme'`
  - `class OverviewRow { final int raceId, categoryId; final String raceLabel, categoryLabel; final int entryCount; final EventStructure? structure; }` (see code — a plain immutable class)
  - `ProgrammeController(RaceRepository, ProgrammeService)` with:
    - `RxInt currentTabIndex`, `void changeTab(int)`
    - `RxBool isLoading`, `RxBool hasError`
    - `RxList<OverviewRow> rows`
    - `Future<void> load(Competition competition)` (called in `onInit` from `Get.arguments`)

- [ ] **Step 1: Write the failing test**

Create `test/presentation/modules/programme/controllers/programme_controller_test.dart`:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/category.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/entry.dart';
import 'package:live_ffss/app/domain/models/race.dart';
import 'package:live_ffss/app/module/programme/controllers/programme_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockRaceRepo extends Mock implements RaceRepository {}

class _MockStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockRaceRepo raceRepo;
  late ProgrammeService service;
  late ProgrammeController controller;

  setUpAll(() => registerFallbackValue(''));

  const cadets = Category(id: 7, name: 'Cadets');
  const juniors = Category(id: 8, name: 'Juniors');

  Race race(int id, String name, List<Category> cats) => Race(
        id: id,
        name: name,
        nameEnglish: name,
        distance: 100,
        gender: Gender.mixed,
        athletesPerTeam: 1,
        specialityId: 1,
        specialityLabel: '',
        disciplineId: 1,
        isEligibleToNationalRecord: false,
        categories: cats,
      );

  Entry entry(int id, int raceId, Category cat) => Entry(
        id: id,
        raceId: raceId,
        category: cat,
        status: 0,
        statusLabel: '',
      );

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

  setUp(() {
    raceRepo = _MockRaceRepo();
    final storage = _MockStorage();
    when(() => storage.read(key: any(named: 'key')))
        .thenAnswer((_) async => null);
    service = ProgrammeService(storage);
    controller = ProgrammeController(raceRepo, service);
  });

  test('builds one row per épreuve × category with its entry count', () async {
    when(() => raceRepo.getRaces(42))
        .thenAnswer((_) async => [race(100, '100m', [cadets, juniors])]);
    when(() => raceRepo.getEntries(100)).thenAnswer((_) async => [
          entry(1, 100, cadets),
          entry(2, 100, cadets),
          entry(3, 100, juniors),
        ]);

    await controller.load(competition);

    expect(controller.rows.length, 2);
    final cadetsRow = controller.rows.firstWhere((r) => r.categoryId == 7);
    expect(cadetsRow.entryCount, 2);
    expect(cadetsRow.raceLabel, '100m');
    expect(cadetsRow.structure, isNull);
    expect(controller.isLoading.value, isFalse);
  });

  test('sets hasError when the repository throws AppException', () async {
    when(() => raceRepo.getRaces(42))
        .thenThrow(const NetworkException('offline'));

    await controller.load(competition);

    expect(controller.hasError.value, isTrue);
    expect(controller.rows, isEmpty);
    expect(controller.isLoading.value, isFalse);
  });

  test('changeTab updates the tab index', () {
    controller.changeTab(1);
    expect(controller.currentTabIndex.value, 1);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/presentation/modules/programme/controllers/programme_controller_test.dart
```

Expected: FAIL — `programme_controller.dart` does not exist.

- [ ] **Step 3: Write the controller**

Create `lib/app/module/programme/controllers/programme_controller.dart`:

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';

/// One line of the structure overview: an épreuve × category, its entry count,
/// and the structure defined for it (null if none yet).
class OverviewRow {
  const OverviewRow({
    required this.raceId,
    required this.categoryId,
    required this.raceLabel,
    required this.categoryLabel,
    required this.entryCount,
    required this.structure,
  });

  final int raceId;
  final int categoryId;
  final String raceLabel;
  final String categoryLabel;
  final int entryCount;
  final EventStructure? structure;
}

class ProgrammeController extends GetxController {
  ProgrammeController(this._raceRepo, this._programme);

  final RaceRepository _raceRepo;
  final ProgrammeService _programme;

  final Rxn<Competition> competition = Rxn<Competition>();
  final RxInt currentTabIndex = 0.obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxList<OverviewRow> rows = <OverviewRow>[].obs;

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

  void changeTab(int index) => currentTabIndex.value = index;

  Future<void> load(Competition comp) async {
    competition.value = comp;
    try {
      isLoading.value = true;
      hasError.value = false;

      await _programme.load(comp.id);
      final races = await _raceRepo.getRaces(comp.id);

      final built = <OverviewRow>[];
      for (final race in races) {
        final entries = await _raceRepo.getEntries(race.id);
        for (final category in race.categories) {
          final count = entries
              .where((e) => e.category.id == category.id)
              .length;
          built.add(OverviewRow(
            raceId: race.id,
            categoryId: category.id,
            raceLabel: race.name,
            categoryLabel: category.name,
            entryCount: count,
            structure: _structureFor(race.id, category.id),
          ));
        }
      }
      rows.value = built;
    } on AppException {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  EventStructure? _structureFor(int raceId, int categoryId) {
    final structures = _programme.current.value?.structures ?? const [];
    for (final s in structures) {
      if (s.raceId == raceId && s.categoryId == categoryId) return s;
    }
    return null;
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/presentation/modules/programme/controllers/programme_controller_test.dart
```

Expected: PASS — 3 tests.

- [ ] **Step 5: Write the binding, route, and entry point**

Create `lib/app/module/programme/bindings/programme_binding.dart`:

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import '../controllers/programme_controller.dart';

class ProgrammeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProgrammeController>(
      () => ProgrammeController(
        Get.find<RaceRepository>(),
        Get.find<ProgrammeService>(),
      ),
    );
  }
}
```

In `lib/app/routes/app_routes.dart`, add before the `// Add other routes here` comment:

```dart
  static const programme = '/programme';
```

In `lib/app/routes/app_pages.dart`, add the imports (near the other competitions-module imports):

```dart
import 'package:live_ffss/app/module/programme/bindings/programme_binding.dart';
import 'package:live_ffss/app/module/programme/views/programme_view.dart';
```

and add to `AppPages.routes`, after the `competitionDetail` page:

```dart
    GetPage(
      name: Routes.programme,
      page: () => const ProgrammeView(),
      binding: ProgrammeBinding(),
    ),
```

(`ProgrammeView` is created in Task 9; the import will not resolve until then. Do Task 9 before running the app, but the analyzer step below is scoped to the controller/binding only.)

In `lib/app/module/competitions/views/competition_detail_view.dart`, add the routes import:

```dart
import 'package:live_ffss/app/routes/app_pages.dart';
```

and in `_CompetitionDetailHeader`'s first `Row` (currently `IconButton(back)` → `Spacer()` → `Obx(favorites star)`), insert between the `Spacer()` and the star's `Obx`:

```dart
              IconButton(
                icon: const Icon(Icons.event_note, color: Colors.white),
                tooltip: 'programme'.tr,
                onPressed: () => Get.toNamed<void>(
                  Routes.programme,
                  arguments: competition,
                ),
              ),
```

- [ ] **Step 6: Verify controller/binding analyze**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat analyze lib/app/module/programme/controllers/ lib/app/module/programme/bindings/
```

Expected: `No issues found!`

- [ ] **Step 7: Commit**

```bash
git add lib/app/module/programme/controllers/programme_controller.dart lib/app/module/programme/bindings/programme_binding.dart lib/app/routes/app_routes.dart lib/app/routes/app_pages.dart lib/app/module/competitions/views/competition_detail_view.dart test/presentation/modules/programme/controllers/programme_controller_test.dart
git commit -m "feat(programme): add ProgrammeController, route, and entry point"
```

---

### Task 9: Shell view + structure overview (2A)

**Files:**
- Create: `lib/app/module/programme/views/programme_view.dart`
- Create: `lib/app/module/programme/views/structure_overview_view.dart`

No unit tests (views — project convention). Verified via `flutter run`.

**Interfaces:**
- Consumes: `ProgrammeController` (Task 8), `OverviewRow`, shared widgets, theme tokens, `EventStructureFormatting` (Task 4)

- [ ] **Step 1: Write the shell view**

Create `lib/app/module/programme/views/programme_view.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/module/programme/controllers/programme_controller.dart';
import 'package:live_ffss/app/module/programme/views/structure_overview_view.dart';
import 'package:live_ffss/app/presentation/shared/home_wave.dart';

class ProgrammeView extends GetView<ProgrammeController> {
  const ProgrammeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _ProgrammeHeader(),
            const HomeWave(),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: Obx(() => IndexedStack(
                    index: controller.currentTabIndex.value,
                    children: const [
                      StructureOverviewView(),
                      _SchedulePlaceholder(),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgrammeHeader extends GetView<ProgrammeController> {
  const _ProgrammeHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xs,
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.md,
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: Get.back,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Obx(() => Text(
                      controller.competition.value?.name ?? '',
                      style: AppTypography.title
                          .copyWith(color: Colors.white, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: AppSpacing.pageHorizontal,
            child: Row(
              children: [
                _Pill(label: 'structure'.tr, index: 0),
                const SizedBox(width: AppSpacing.sm),
                _Pill(label: 'programme'.tr, index: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends GetView<ProgrammeController> {
  const _Pill({required this.label, required this.index});

  final String label;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final active = controller.currentTabIndex.value == index;
      return GestureDetector(
        onTap: () => controller.changeTab(index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.statusWaiting : Colors.transparent,
            borderRadius: AppRadius.pillRadius,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? AppColors.textPrimary : Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      );
    });
  }
}

// Plan B replaces this with the scheduling view.
class _SchedulePlaceholder extends StatelessWidget {
  const _SchedulePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('programme'.tr, style: AppTypography.subtitle),
    );
  }
}
```

- [ ] **Step 2: Write the overview view**

Create `lib/app/module/programme/views/structure_overview_view.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/module/programme/controllers/programme_controller.dart';
import 'package:live_ffss/app/presentation/modules/programme/programme_formatting.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';
import 'package:live_ffss/app/presentation/shared/error_state.dart';
import 'package:live_ffss/app/presentation/shared/loading_indicator.dart';

class StructureOverviewView extends GetView<ProgrammeController> {
  const StructureOverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) return const LoadingIndicator();
      if (controller.hasError.value) {
        return ErrorState(
          message: 'error_occured'.tr,
          onRetry: () {
            final comp = controller.competition.value;
            if (comp != null) controller.load(comp);
          },
        );
      }
      if (controller.rows.isEmpty) {
        return EmptyState(
          icon: Icons.rule_folder_outlined,
          title: 'no_structures'.tr,
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm,
          AppSpacing.xs,
          AppSpacing.sm,
          AppSpacing.lg,
        ),
        itemCount: controller.rows.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, i) => _OverviewCard(row: controller.rows[i]),
      );
    });
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.row});

  final OverviewRow row;

  @override
  Widget build(BuildContext context) {
    final structure = row.structure;
    final summary = structure == null || !structure.isDefined
        ? 'not_defined'.tr
        : structure.chain.map((t) => t.labelKey.tr).join(' → ');
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        // Task 10 wires onTap to open the structure editor.
        onTap: () {},
        title: Text(
          '${row.raceLabel} · ${row.categoryLabel}',
          style: AppTypography.body,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${row.entryCount} ${'engaged'.tr} · $summary',
          style: AppTypography.caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.textMuted),
      ),
    );
  }
}
```

- [ ] **Step 3: Verify analyze + full suite**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat analyze
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test
```

Expected: analyze reports only the two pre-existing `en_US`/`fr_FR` file-name `info`s; the full suite passes.

- [ ] **Step 4: Verify on a device/emulator**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat run
```

Open a competition → tap the programme icon (event_note) in the header → the Structure tab lists its épreuves × categories with entry counts and "non défini". Confirm the Structure/Programme pills switch tabs.

- [ ] **Step 5: Commit**

```bash
git add lib/app/module/programme/views/programme_view.dart lib/app/module/programme/views/structure_overview_view.dart
git commit -m "feat(programme): add the two-tab shell and structure overview"
```

---

### Task 10: StructureEditorController + binding + route (2B logic)

The editor for one épreuve × category: add/remove levels, set race counts and qualifiers, edit spots-per-race, propose a default, and set opt1/opt2 wiring. Persists through `ProgrammeService`.

**Files:**
- Create: `lib/app/module/programme/controllers/structure_editor_controller.dart`
- Create: `lib/app/module/programme/bindings/structure_editor_binding.dart`
- Modify: `lib/app/routes/app_routes.dart`
- Modify: `lib/app/routes/app_pages.dart`
- Modify: `lib/app/module/programme/views/structure_overview_view.dart` (wire the row `onTap`)
- Test: `test/presentation/modules/programme/controllers/structure_editor_controller_test.dart`

**Interfaces:**
- Consumes: `ProgrammeService` (Task 5), `structure_generator.dart` (Task 3), `EventStructure`, `RoundLevel`, `ProgrammeRace`, `RoundType`
- Produces:
  - `class StructureEditorArgs { final int competitionId, raceId, categoryId, entryCount; final String raceLabel, categoryLabel; }`
  - `Routes.structureEditor = '/structure-editor'`
  - `StructureEditorController(ProgrammeService)` with:
    - `Rxn<EventStructure> structure`
    - `void proposeDefault()`, `void addLevel(RoundType type)`, `void removeLevel(int levelIndex)`
    - `void setRaceCount(int levelIndex, int count)`, `void setQualifiers(int levelIndex, int qualifiers)`, `void setSpotsPerRace(int spots)`
    - `void setWiring(int levelIndex, int raceId, List<int> sourceRaceIds)`
    - each mutation persists via `ProgrammeService.save`

- [ ] **Step 1: Write the failing test**

Create `test/presentation/modules/programme/controllers/structure_editor_controller_test.dart`:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/module/programme/controllers/structure_editor_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockStorage storage;
  late ProgrammeService service;
  late StructureEditorController controller;

  setUpAll(() => registerFallbackValue(''));

  const args = StructureEditorArgs(
    competitionId: 42,
    raceId: 100,
    categoryId: 7,
    raceLabel: '100m',
    categoryLabel: 'Cadets',
    entryCount: 20,
  );

  setUp(() async {
    storage = _MockStorage();
    when(() => storage.read(key: any(named: 'key')))
        .thenAnswer((_) async => null);
    when(() => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'))).thenAnswer((_) async {});
    service = ProgrammeService(storage);
    await service.load(42);
    controller = StructureEditorController(service);
    controller.start(args);
  });

  test('start creates an empty structure with the event defaults', () {
    final s = controller.structure.value!;
    expect(s.raceId, 100);
    expect(s.categoryId, 7);
    expect(s.spotsPerRace, 8);
    expect(s.levels, isEmpty);
  });

  test('proposeDefault builds séries + finale for 20 entries at 8 spots', () {
    controller.proposeDefault();

    final levels = controller.structure.value!.levels;
    expect(levels.map((l) => l.type),
        [RoundType.serie, RoundType.finale]);
    expect(levels[0].races.length, 3); // ceil(20 / 8)
    expect(levels[1].races.length, 1);
  });

  test('races get unique ids from the service counter', () {
    controller.proposeDefault();

    final ids = controller.structure.value!.levels
        .expand((l) => l.races)
        .map((r) => r.id)
        .toList();
    expect(ids.toSet().length, ids.length); // all unique
  });

  test('proposeDefault wires quarts/finale to all previous races by default',
      () {
    controller.proposeDefault();

    final levels = controller.structure.value!.levels;
    final serieIds = levels[0].races.map((r) => r.id).toList();
    final finale = levels[1].races.single;
    expect(finale.sourceRaceIds, serieIds); // opt2: all → all
  });

  test('setRaceCount adds/removes races on a level', () {
    controller.proposeDefault();
    controller.setRaceCount(0, 5);
    expect(controller.structure.value!.levels[0].races.length, 5);
    controller.setRaceCount(0, 2);
    expect(controller.structure.value!.levels[0].races.length, 2);
  });

  test('setWiring overrides the sources of one race (opt1)', () {
    controller.proposeDefault();
    final serieIds =
        controller.structure.value!.levels[0].races.map((r) => r.id).toList();
    final finaleId = controller.structure.value!.levels[1].races.single.id;

    controller.setWiring(1, finaleId, [serieIds.first]);

    expect(controller.structure.value!.levels[1].races.single.sourceRaceIds,
        [serieIds.first]);
  });

  test('every mutation persists the whole programme', () async {
    controller.proposeDefault();
    // proposeDefault writes once; the structure is now in the stored programme.
    final stored = service.current.value!;
    expect(stored.structures.any((s) => s.raceId == 100), isTrue);
    verify(() => storage.write(
        key: 'programme_42', value: any(named: 'value'))).called(greaterThan(0));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/presentation/modules/programme/controllers/structure_editor_controller_test.dart
```

Expected: FAIL — `structure_editor_controller.dart` does not exist.

- [ ] **Step 3: Write the controller**

Create `lib/app/module/programme/controllers/structure_editor_controller.dart`:

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/domain/models/structure_generator.dart';

class StructureEditorArgs {
  const StructureEditorArgs({
    required this.competitionId,
    required this.raceId,
    required this.categoryId,
    required this.raceLabel,
    required this.categoryLabel,
    required this.entryCount,
  });

  final int competitionId;
  final int raceId;
  final int categoryId;
  final String raceLabel;
  final String categoryLabel;
  final int entryCount;
}

class StructureEditorController extends GetxController {
  StructureEditorController(this._programme);

  final ProgrammeService _programme;

  final Rxn<EventStructure> structure = Rxn<EventStructure>();
  late StructureEditorArgs _args;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is StructureEditorArgs) start(arg);
  }

  /// Loads the stored structure for this épreuve × category, or seeds an empty
  /// one carrying the event labels and the default spots-per-race.
  void start(StructureEditorArgs args) {
    _args = args;
    structure.value = _stored() ??
        EventStructure(
          raceId: args.raceId,
          categoryId: args.categoryId,
          raceLabel: args.raceLabel,
          categoryLabel: args.categoryLabel,
        );
  }

  void proposeDefault() {
    final s = structure.value!;
    final plans =
        proposeLevels(entryCount: _args.entryCount, spotsPerRace: s.spotsPerRace);
    final levels = <RoundLevel>[];
    List<int> previousIds = const [];
    for (final plan in plans) {
      final races = <ProgrammeRace>[];
      for (var n = 1; n <= plan.raceCount; n++) {
        races.add(ProgrammeRace(
          id: _programme.allocateId(),
          number: n,
          // opt2 default: every race is fed by all races of the previous level.
          sourceRaceIds: previousIds,
        ));
      }
      levels.add(RoundLevel(type: plan.type, races: races));
      previousIds = races.map((r) => r.id).toList();
    }
    _commit(s.copyWith(levels: levels));
  }

  void setSpotsPerRace(int spots) {
    if (spots < 1) return;
    _commit(structure.value!.copyWith(spotsPerRace: spots));
  }

  void addLevel(RoundType type) {
    final s = structure.value!;
    _commit(s.copyWith(levels: [...s.levels, RoundLevel(type: type)]));
  }

  void removeLevel(int levelIndex) {
    final levels = [...structure.value!.levels]..removeAt(levelIndex);
    _commit(structure.value!.copyWith(levels: levels));
  }

  void setRaceCount(int levelIndex, int count) {
    if (count < 0) return;
    final levels = [...structure.value!.levels];
    final level = levels[levelIndex];
    final races = [...level.races];
    while (races.length < count) {
      races.add(ProgrammeRace(
        id: _programme.allocateId(),
        number: races.length + 1,
      ));
    }
    if (races.length > count) races.removeRange(count, races.length);
    levels[levelIndex] = level.copyWith(races: races);
    _commit(structure.value!.copyWith(levels: levels));
  }

  void setQualifiers(int levelIndex, int qualifiers) {
    if (qualifiers < 0) return;
    final levels = [...structure.value!.levels];
    levels[levelIndex] =
        levels[levelIndex].copyWith(qualifiersPerRace: qualifiers);
    _commit(structure.value!.copyWith(levels: levels));
  }

  void setWiring(int levelIndex, int raceId, List<int> sourceRaceIds) {
    final levels = [...structure.value!.levels];
    final races = levels[levelIndex]
        .races
        .map((r) =>
            r.id == raceId ? r.copyWith(sourceRaceIds: sourceRaceIds) : r)
        .toList();
    levels[levelIndex] = levels[levelIndex].copyWith(races: races);
    _commit(structure.value!.copyWith(levels: levels));
  }

  EventStructure? _stored() {
    final structures = _programme.current.value?.structures ?? const [];
    for (final s in structures) {
      if (s.raceId == _args.raceId && s.categoryId == _args.categoryId) {
        return s;
      }
    }
    return null;
  }

  /// Sets the reactive structure and persists it into the programme, replacing
  /// any prior structure for this épreuve × category.
  void _commit(EventStructure updated) {
    structure.value = updated;
    final p = _programme.current.value ??
        CompetitionProgramme(competitionId: _args.competitionId);
    final others = p.structures
        .where((s) => !(s.raceId == updated.raceId &&
            s.categoryId == updated.categoryId))
        .toList();
    _programme.save(p.copyWith(structures: [...others, updated]));
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/presentation/modules/programme/controllers/structure_editor_controller_test.dart
```

Expected: PASS — 8 tests.

- [ ] **Step 5: Write the binding, route, and wire the overview row**

Create `lib/app/module/programme/bindings/structure_editor_binding.dart`:

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import '../controllers/structure_editor_controller.dart';

class StructureEditorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StructureEditorController>(
      () => StructureEditorController(Get.find<ProgrammeService>()),
    );
  }
}
```

In `lib/app/routes/app_routes.dart`, add:

```dart
  static const structureEditor = '/structure-editor';
```

In `lib/app/routes/app_pages.dart`, add the imports:

```dart
import 'package:live_ffss/app/module/programme/bindings/structure_editor_binding.dart';
import 'package:live_ffss/app/module/programme/views/structure_editor_view.dart';
```

and add to `AppPages.routes`, after the `programme` page:

```dart
    GetPage(
      name: Routes.structureEditor,
      page: () => const StructureEditorView(),
      binding: StructureEditorBinding(),
    ),
```

(`StructureEditorView` is Task 11.)

In `lib/app/module/programme/views/structure_overview_view.dart`, add the imports:

```dart
import 'package:live_ffss/app/module/programme/controllers/structure_editor_controller.dart';
import 'package:live_ffss/app/routes/app_pages.dart';
```

and replace the `_OverviewCard` `ListTile`'s `onTap: () {},` with:

```dart
        onTap: () => Get.toNamed<void>(
          Routes.structureEditor,
          arguments: StructureEditorArgs(
            competitionId: Get.find<ProgrammeController>()
                .competition
                .value!
                .id,
            raceId: row.raceId,
            categoryId: row.categoryId,
            raceLabel: row.raceLabel,
            categoryLabel: row.categoryLabel,
            entryCount: row.entryCount,
          ),
        ),
```

(Reading the active competition id via `Get.find<ProgrammeController>()` here is a view-layer call, allowed — the rule against `Get.find` in a body applies to controllers, not views.)

- [ ] **Step 6: Verify analyze**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat analyze lib/app/module/programme/controllers/ lib/app/module/programme/bindings/
```

Expected: `No issues found!`

- [ ] **Step 7: Commit**

```bash
git add lib/app/module/programme/controllers/structure_editor_controller.dart lib/app/module/programme/bindings/structure_editor_binding.dart lib/app/routes/app_routes.dart lib/app/routes/app_pages.dart lib/app/module/programme/views/structure_overview_view.dart test/presentation/modules/programme/controllers/structure_editor_controller_test.dart
git commit -m "feat(programme): add structure editor controller and wiring"
```

---

### Task 11: Structure editor view (2B form) + bracket toggle

**Files:**
- Create: `lib/app/module/programme/views/structure_editor_view.dart`
- Create: `lib/app/module/programme/views/structure_bracket.dart`

No unit tests (views). Verified via `flutter run`.

**Interfaces:**
- Consumes: `StructureEditorController` (Task 10), `RoundTypeFormatting` (Task 4), theme tokens, shared widgets.

- [ ] **Step 1: Write the bracket widget**

Create `lib/app/module/programme/views/structure_bracket.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/presentation/modules/programme/programme_formatting.dart';

/// Read-only visual overview: levels as columns, races as nodes. Horizontal
/// scroll on mobile. Editing happens in the form, not here.
class StructureBracket extends StatelessWidget {
  const StructureBracket({required this.levels, super.key});

  final List<RoundLevel> levels;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: AppSpacing.pageAll,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < levels.length; i++) ...[
            _LevelColumn(level: levels[i]),
            if (i < levels.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Icon(Icons.arrow_forward, color: AppColors.textMuted),
              ),
          ],
        ],
      ),
    );
  }
}

class _LevelColumn extends StatelessWidget {
  const _LevelColumn({required this.level});

  final RoundLevel level;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(level.type.labelKey.tr.toUpperCase(),
            style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.xs),
        for (final race in level.races)
          Container(
            width: 120,
            margin: const EdgeInsets.only(bottom: AppSpacing.xs),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.smRadius,
              border: Border.all(color: AppColors.border),
            ),
            child: Text('${level.type.labelKey.tr} ${race.number}',
                style: AppTypography.caption),
          ),
      ],
    );
  }
}
```

- [ ] **Step 2: Write the editor view**

Create `lib/app/module/programme/views/structure_editor_view.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/module/programme/controllers/structure_editor_controller.dart';
import 'package:live_ffss/app/module/programme/views/structure_bracket.dart';
import 'package:live_ffss/app/presentation/modules/programme/programme_formatting.dart';

class StructureEditorView extends StatefulWidget {
  const StructureEditorView({super.key});

  @override
  State<StructureEditorView> createState() => _StructureEditorViewState();
}

class _StructureEditorViewState extends State<StructureEditorView> {
  final _controller = Get.find<StructureEditorController>();
  bool _showBracket = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Obx(() {
          final s = _controller.structure.value;
          return Text(
            s == null ? '' : '${s.raceLabel} · ${s.categoryLabel}',
            style: AppTypography.title.copyWith(color: Colors.white, fontSize: 16),
          );
        }),
        actions: [
          TextButton(
            onPressed: () => setState(() => _showBracket = !_showBracket),
            child: Text('view_bracket'.tr,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Obx(() {
        final s = _controller.structure.value;
        if (s == null) return const SizedBox.shrink();
        if (_showBracket) return StructureBracket(levels: s.levels);
        return ListView(
          padding: AppSpacing.pageAll,
          children: [
            Row(
              children: [
                Text('${s.spotsPerRace} ${'spots_per_race'.tr}',
                    style: AppTypography.caption),
                const Spacer(),
                TextButton(
                  onPressed: _controller.proposeDefault,
                  child: Text('propose_structure'.tr),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            for (var i = 0; i < s.levels.length; i++)
              _LevelCard(index: i, level: s.levels[i]),
            const SizedBox(height: AppSpacing.sm),
            _AddLevelButton(controller: _controller),
          ],
        );
      }),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.index, required this.level});

  final int index;
  final RoundLevel level;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StructureEditorController>();
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(level.type.labelKey.tr.toUpperCase(),
                    style: AppTypography.body
                        .copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => controller.removeLevel(index),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _Stepper(
                    label: 'races_count'.tr,
                    value: level.races.length,
                    onChanged: (v) => controller.setRaceCount(index, v),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _Stepper(
                    label: 'qualifiers_per_race'.tr,
                    value: level.qualifiersPerRace,
                    onChanged: (v) => controller.setQualifiers(index, v),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.caption),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: value > 0 ? () => onChanged(value - 1) : null,
            ),
            Text('$value', style: AppTypography.body),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => onChanged(value + 1),
            ),
          ],
        ),
      ],
    );
  }
}

class _AddLevelButton extends StatelessWidget {
  const _AddLevelButton({required this.controller});

  final StructureEditorController controller;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<RoundType>(
      onSelected: controller.addLevel,
      itemBuilder: (_) => [
        for (final type in const [
          RoundType.serie,
          RoundType.quart,
          RoundType.demi,
          RoundType.finale,
        ])
          PopupMenuItem(value: type, child: Text(type.labelKey.tr)),
      ],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add, color: AppColors.primary),
          const SizedBox(width: AppSpacing.xs),
          Text('add_level'.tr,
              style: AppTypography.body.copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }
}
```

Note: the opt1/opt2 wiring editor (a per-target checkbox picker calling
`controller.setWiring`) is deferred to a follow-up within Plan B's review, as
the wiring drives no computation in v1; `proposeDefault` already sets the opt2
default. If the reviewer wants it in Plan A, add a "customize" affordance on
`_LevelCard` for levels after the first that opens a checkbox list of the
previous level's races and calls `controller.setWiring(index, raceId, picked)`.

- [ ] **Step 3: Verify analyze + full suite**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat analyze
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test
```

Expected: analyze reports only the two pre-existing file-name `info`s; full suite passes.

- [ ] **Step 4: Verify on a device/emulator**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat run
```

Open a competition → programme → tap an épreuve × category → "Proposer une structure" builds séries + finale → adjust race counts with the steppers → "Voir le bracket" shows the columns → go back and reopen: the structure persisted.

- [ ] **Step 5: Commit**

```bash
git add lib/app/module/programme/views/structure_editor_view.dart lib/app/module/programme/views/structure_bracket.dart
git commit -m "feat(programme): add the structure editor form and bracket"
```

---

## Notes for the reviewer

- **`ProgrammeController.load` is N+1** (one `getEntries` per race). That is the existing `RaceRepository` shape (no bulk entries endpoint). Acceptable for a competition's race count; if it bites, batch later.
- **Enum JSON:** `RoundType`/`SiteType` serialise by name via json_serializable. The `unknown` arm is forward-compat; our own data only ever writes valid arms, so no `unknownEnumValue` handling is needed on read.
- **Wiring UI deferral** is called out in Task 11 — `proposeDefault` sets opt2; the opt1 picker is optional in Plan A since it drives nothing yet. Decide during review whether to pull it into Plan A or leave for when seeding is built.
- **`ProgrammeService.allocateId`** mutates `current` without an immediate `save`; the controller's `_commit` persists the bump together with the structure change, so a crash between allocate and commit at worst wastes an id (harmless).
- Plan B consumes: `ProgrammeService`, `CompetitionProgramme`/`ProgrammeRace.placement`, `ProgrammeSite`/`SiteType`, and adds the FFSS `Meeting → Slot → Run` sync mapper behind the `ProgrammeRemoteDataSource` seam.
