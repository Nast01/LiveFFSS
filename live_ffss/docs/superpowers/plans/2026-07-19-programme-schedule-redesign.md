# Programme Scheduling Redesign — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace Plan B's absolute-time placement with a per-site×day **ordered block sequence** (a block is a race or a manual free-text item), where begin times derive from an editable start + durations back-to-back, so reordering / duration edits / manual inserts recompute all following times — plus a Direction-B interactive view and a fix for the gear button.

**Architecture:** A migration done safely: **add** the new `ScheduleBlock`/`SiteDayStart` model and block-based `schedule_planner` functions **alongside** the old placement code, migrate each consumer (controller, view, mapper) to blocks, then **remove** `ProgrammeRace.placement` / `RacePlacement` / the old functions last. The tree compiles and the suite passes after every task.

**Tech Stack:** Flutter, GetX, freezed + json_serializable, flutter_secure_storage, mocktail, `ReorderableListView` (new to this codebase).

**Spec:** `docs/superpowers/specs/2026-07-19-programme-schedule-redesign-design.md`

## Global Constraints

- **Dart/Flutter binaries are not on PATH.** Use `C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat` and `dart.bat`.
- **Codegen:** after editing a freezed file, run `C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\dart.bat run build_runner build --delete-conflicting-outputs`. Commit the generated `.freezed.dart`/`.g.dart` (treated as source). **Never hand-edit generated files.**
- **`explicit_to_json` is false** (no `build.yaml`): model round-trip tests go through the JSON string — `fromJson(jsonDecode(jsonEncode(x.toJson())))`, not a bare `fromJson(x.toJson())`.
- **Analyzer is strict** (`strict-casts`, `strict-raw-types`); no `dynamic`. The one sanctioned cast is `jsonDecode(raw) as Map<String, dynamic>` in `ProgrammeService`.
- **Controller discipline:** no `Get.snackbar`/`Get.dialog`/`.tr`/`Get.context!`/`BuildContext` in controllers; constructor injection only, never `Get.find()` in a controller body; catch `AppException`. `Get.find`, dialogs, pickers, `TextEditingController`, and reorder gestures live in the VIEW.
- **Obx dependency rule (learned in Plan B):** read every reactive value the widget depends on **in the `Obx`/builder body**, never only inside a `ListView.builder` / `ReorderableListView` itemBuilder — values read only in itemBuilder are NOT registered as dependencies.
- **Worker lifecycle:** controllers/views that register an `ever` worker store it and dispose it (`onClose` for controllers, `dispose` for view State).
- **id allocation:** new blocks use `ProgrammeService.allocateId()` (returns pre-increment value, bumps `nextLocalId` in `current`); the caller re-reads `current.value` then `save`s — the `SitesController.addSite` pattern.
- Times are derived, never stored. Duration min is 5. Default day start is 09:00 (`defaultStartMinutes = 540`).
- Use `git add <explicit paths>` only — never `git add -A` / `git add .`; the tree carries unrelated modified files.

---

### Task 1: New models — ScheduleBlock, SiteDayStart, and the root gains them

Adds the two new freezed models and wires them into `CompetitionProgramme`. `ProgrammeRace.placement` stays for now (removed in Task 6) — the tree compiles.

**Files:**
- Create: `lib/app/domain/models/schedule_block.dart`
- Create: `lib/app/domain/models/site_day_start.dart`
- Modify: `lib/app/domain/models/competition_programme.dart`
- Test: `test/data/models/schedule_block_test.dart`

**Interfaces:**
- Produces:
  - `ScheduleBlock({required int id, required int siteId, required DateTime day, required int order, @Default(10) int durationMinutes, int? raceId, @Default('') String manualLabel})`
  - `SiteDayStart({required int siteId, required DateTime day, required int startMinutes})`
  - `CompetitionProgramme` gains `@Default(<ScheduleBlock>[]) List<ScheduleBlock> blocks` and `@Default(<SiteDayStart>[]) List<SiteDayStart> dayStarts`

- [ ] **Step 1: Write the failing test**

Create `test/data/models/schedule_block_test.dart`:

```dart
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/schedule_block.dart';
import 'package:live_ffss/app/domain/models/site_day_start.dart';

void main() {
  test('ScheduleBlock defaults: duration 10, no race, empty label', () {
    final b = ScheduleBlock(id: 1, siteId: 2, day: DateTime(2026, 6, 13), order: 0);
    expect(b.durationMinutes, 10);
    expect(b.raceId, isNull);
    expect(b.manualLabel, '');
  });

  test('a race block and a manual block round-trip through JSON', () {
    final race = ScheduleBlock(
        id: 1, siteId: 2, day: DateTime(2026, 6, 13), order: 0, raceId: 99);
    final manual = ScheduleBlock(
        id: 2,
        siteId: 2,
        day: DateTime(2026, 6, 13),
        order: 1,
        durationMinutes: 60,
        manualLabel: 'Pause');
    for (final b in [race, manual]) {
      expect(ScheduleBlock.fromJson(b.toJson()), b);
    }
  });

  test('SiteDayStart round-trips', () {
    final s = SiteDayStart(siteId: 2, day: DateTime(2026, 6, 13), startMinutes: 510);
    expect(SiteDayStart.fromJson(s.toJson()), s);
  });

  test('CompetitionProgramme carries blocks and dayStarts through JSON', () {
    final p = CompetitionProgramme(
      competitionId: 42,
      blocks: [
        ScheduleBlock(id: 1, siteId: 2, day: DateTime(2026, 6, 13), order: 0, raceId: 99),
      ],
      dayStarts: [
        SiteDayStart(siteId: 2, day: DateTime(2026, 6, 13), startMinutes: 540),
      ],
    );
    final restored = CompetitionProgramme.fromJson(
      jsonDecode(jsonEncode(p.toJson())) as Map<String, dynamic>,
    );
    expect(restored, p);
  });

  test('an empty programme has no blocks and no dayStarts', () {
    const p = CompetitionProgramme(competitionId: 1);
    expect(p.blocks, isEmpty);
    expect(p.dayStarts, isEmpty);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/data/models/schedule_block_test.dart
```

Expected: FAIL — the new model files do not exist.

- [ ] **Step 3: Write the models**

Create `lib/app/domain/models/schedule_block.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule_block.freezed.dart';
part 'schedule_block.g.dart';

/// One item in a site×day timeline: a race (`raceId` set) or a manual
/// free-text item (`manualLabel` non-empty). Begin/end times are derived from
/// the day's start plus each block's duration, in `order` — never stored.
@freezed
class ScheduleBlock with _$ScheduleBlock {
  const factory ScheduleBlock({
    required int id,
    required int siteId,
    required DateTime day,
    required int order,
    @Default(10) int durationMinutes,
    int? raceId,
    @Default('') String manualLabel,
  }) = _ScheduleBlock;

  factory ScheduleBlock.fromJson(Map<String, dynamic> json) =>
      _$ScheduleBlockFromJson(json);
}
```

Create `lib/app/domain/models/site_day_start.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'site_day_start.freezed.dart';
part 'site_day_start.g.dart';

/// The editable start time (minutes past midnight) of one site on one day.
/// Absent ⇒ the timeline starts at 09:00.
@freezed
class SiteDayStart with _$SiteDayStart {
  const factory SiteDayStart({
    required int siteId,
    required DateTime day,
    required int startMinutes,
  }) = _SiteDayStart;

  factory SiteDayStart.fromJson(Map<String, dynamic> json) =>
      _$SiteDayStartFromJson(json);
}
```

In `lib/app/domain/models/competition_programme.dart`, add the imports:

```dart
import 'package:live_ffss/app/domain/models/schedule_block.dart';
import 'package:live_ffss/app/domain/models/site_day_start.dart';
```

and add two fields to the factory (after `structures`):

```dart
    @Default(<ScheduleBlock>[]) List<ScheduleBlock> blocks,
    @Default(<SiteDayStart>[]) List<SiteDayStart> dayStarts,
```

- [ ] **Step 4: Run codegen**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\dart.bat run build_runner build --delete-conflicting-outputs
```

Expected: generates `schedule_block.freezed/g.dart`, `site_day_start.freezed/g.dart`, regenerates `competition_programme.freezed/g.dart`. "Succeeded".

- [ ] **Step 5: Run test to verify it passes**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/data/models/schedule_block_test.dart
```

Expected: PASS — 5 tests.

- [ ] **Step 6: Commit**

```bash
git add lib/app/domain/models/schedule_block.dart lib/app/domain/models/schedule_block.freezed.dart lib/app/domain/models/schedule_block.g.dart lib/app/domain/models/site_day_start.dart lib/app/domain/models/site_day_start.freezed.dart lib/app/domain/models/site_day_start.g.dart lib/app/domain/models/competition_programme.dart lib/app/domain/models/competition_programme.freezed.dart lib/app/domain/models/competition_programme.g.dart test/data/models/schedule_block_test.dart
git commit -m "feat(programme): add ScheduleBlock and SiteDayStart models"
```

---

### Task 2: Block-based planner functions

Adds the block-oriented functions to `schedule_planner.dart` **alongside** the existing placement functions, and makes `ScheduleItem.placement` optional so the new `unscheduledRaces` can omit it. The old functions stay (removed in Task 6).

**Files:**
- Modify: `lib/app/domain/models/schedule_planner.dart`
- Test: `test/data/models/schedule_blocks_planner_test.dart`

**Interfaces:**
- Consumes: `CompetitionProgramme`, `ScheduleBlock`, `SiteDayStart`, `sameDay` (existing in the file), `ScheduleItem` (existing)
- Produces:
  - `const int defaultStartMinutes = 540;`
  - `class ScheduleRow { final ScheduleBlock block; final DateTime begin; final DateTime end; }`
  - `int dayStartMinutes(CompetitionProgramme p, int siteId, DateTime day)`
  - `List<ScheduleRow> scheduleRows(CompetitionProgramme p, int siteId, DateTime day)`
  - `List<ScheduleItem> unscheduledRaces(CompetitionProgramme p)`
  - `CompetitionProgramme addRaceBlock(CompetitionProgramme p, int blockId, int raceId, int siteId, DateTime day)`
  - `CompetitionProgramme addManualBlock(CompetitionProgramme p, int blockId, String label, int minutes, int siteId, DateTime day)`
  - `CompetitionProgramme setBlockDuration(CompetitionProgramme p, int blockId, int minutes)`
  - `CompetitionProgramme setManualLabel(CompetitionProgramme p, int blockId, String label)`
  - `CompetitionProgramme removeBlock(CompetitionProgramme p, int blockId)`
  - `CompetitionProgramme reorderBlocks(CompetitionProgramme p, int siteId, DateTime day, int oldIndex, int newIndex)`
  - `CompetitionProgramme setDayStart(CompetitionProgramme p, int siteId, DateTime day, int startMinutes)`
  - `CompetitionProgramme clearBlocksForSite(CompetitionProgramme p, int siteId)`

- [ ] **Step 1: Write the failing test**

Create `test/data/models/schedule_blocks_planner_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/domain/models/schedule_block.dart';
import 'package:live_ffss/app/domain/models/schedule_planner.dart';
import 'package:live_ffss/app/domain/models/site_day_start.dart';

void main() {
  final day = DateTime(2026, 6, 13);

  CompetitionProgramme withRaces(List<int> raceIds) => CompetitionProgramme(
        competitionId: 1,
        nextLocalId: 100,
        structures: [
          EventStructure(
            raceId: 500,
            categoryId: 7,
            raceLabel: '100m',
            categoryLabel: 'Cadets',
            levels: [
              RoundLevel(
                type: RoundType.serie,
                races: [for (final id in raceIds) ProgrammeRace(id: id, number: id)],
              ),
            ],
          ),
        ],
      );

  group('dayStartMinutes', () {
    test('defaults to 09:00 when no override', () {
      expect(dayStartMinutes(withRaces([1]), 2, day), 540);
    });
    test('uses the override for the matching site+day', () {
      final p = withRaces([1]).copyWith(dayStarts: [
        SiteDayStart(siteId: 2, day: day, startMinutes: 510),
      ]);
      expect(dayStartMinutes(p, 2, day), 510);
    });
  });

  group('scheduleRows', () {
    test('derives back-to-back times from the day start', () {
      final p = withRaces([1, 2]).copyWith(blocks: [
        ScheduleBlock(id: 10, siteId: 2, day: day, order: 0, raceId: 1),
        ScheduleBlock(id: 11, siteId: 2, day: day, order: 1, raceId: 2, durationMinutes: 15),
      ]);
      final rows = scheduleRows(p, 2, day);
      expect(rows.map((r) => r.begin), [DateTime(2026, 6, 13, 9), DateTime(2026, 6, 13, 9, 10)]);
      expect(rows.last.end, DateTime(2026, 6, 13, 9, 25));
    });

    test('a duration change reflows the following blocks', () {
      var p = withRaces([1, 2]).copyWith(blocks: [
        ScheduleBlock(id: 10, siteId: 2, day: day, order: 0, raceId: 1),
        ScheduleBlock(id: 11, siteId: 2, day: day, order: 1, raceId: 2),
      ]);
      p = setBlockDuration(p, 10, 20);
      final rows = scheduleRows(p, 2, day);
      expect(rows[1].begin, DateTime(2026, 6, 13, 9, 20));
    });

    test('honours the site-day start override', () {
      final p = withRaces([1]).copyWith(
        blocks: [ScheduleBlock(id: 10, siteId: 2, day: day, order: 0, raceId: 1)],
        dayStarts: [SiteDayStart(siteId: 2, day: day, startMinutes: 8 * 60 + 30)],
      );
      expect(scheduleRows(p, 2, day).single.begin, DateTime(2026, 6, 13, 8, 30));
    });
  });

  group('unscheduledRaces', () {
    test('lists races no block references', () {
      final p = withRaces([1, 2, 3]).copyWith(
        blocks: [ScheduleBlock(id: 10, siteId: 2, day: day, order: 0, raceId: 2)],
      );
      expect(unscheduledRaces(p).map((i) => i.raceId), [1, 3]);
    });
  });

  group('addRaceBlock / addManualBlock', () {
    test('append with the next order', () {
      var p = withRaces([1, 2]);
      p = addRaceBlock(p, 50, 1, 2, day);
      p = addManualBlock(p, 51, 'Pause', 30, 2, day);
      final rows = scheduleRows(p, 2, day);
      expect(rows.map((r) => r.block.order), [0, 1]);
      expect(rows[0].block.raceId, 1);
      expect(rows[1].block.manualLabel, 'Pause');
    });
  });

  group('reorderBlocks', () {
    test('moving the last before the first renumbers and reflows', () {
      var p = withRaces([1, 2]).copyWith(blocks: [
        ScheduleBlock(id: 10, siteId: 2, day: day, order: 0, raceId: 1),
        ScheduleBlock(id: 11, siteId: 2, day: day, order: 1, raceId: 2),
      ]);
      // ReorderableListView convention: move index 1 to index 0
      p = reorderBlocks(p, 2, day, 1, 0);
      final rows = scheduleRows(p, 2, day);
      expect(rows.map((r) => r.block.raceId), [2, 1]);
      expect(rows.map((r) => r.block.order), [0, 1]);
    });
  });

  group('removeBlock', () {
    test('drops the block and renumbers the rest contiguously', () {
      var p = withRaces([1, 2, 3]).copyWith(blocks: [
        ScheduleBlock(id: 10, siteId: 2, day: day, order: 0, raceId: 1),
        ScheduleBlock(id: 11, siteId: 2, day: day, order: 1, raceId: 2),
        ScheduleBlock(id: 12, siteId: 2, day: day, order: 2, raceId: 3),
      ]);
      p = removeBlock(p, 11);
      final rows = scheduleRows(p, 2, day);
      expect(rows.map((r) => r.block.raceId), [1, 3]);
      expect(rows.map((r) => r.block.order), [0, 1]);
    });
  });

  group('clearBlocksForSite', () {
    test('drops blocks and dayStarts of the site only', () {
      final p = withRaces([1, 2]).copyWith(
        blocks: [
          ScheduleBlock(id: 10, siteId: 5, day: day, order: 0, raceId: 1),
          ScheduleBlock(id: 11, siteId: 6, day: day, order: 0, raceId: 2),
        ],
        dayStarts: [
          SiteDayStart(siteId: 5, day: day, startMinutes: 540),
          SiteDayStart(siteId: 6, day: day, startMinutes: 540),
        ],
      );
      final cleared = clearBlocksForSite(p, 5);
      expect(cleared.blocks.map((b) => b.siteId), [6]);
      expect(cleared.dayStarts.map((s) => s.siteId), [6]);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/data/models/schedule_blocks_planner_test.dart
```

Expected: FAIL — the new functions do not exist.

- [ ] **Step 3: Make `ScheduleItem.placement` optional**

In `lib/app/domain/models/schedule_planner.dart`, change the `ScheduleItem` constructor so `placement` is no longer required (existing callers still pass it; new callers omit it). Replace:

```dart
  const ScheduleItem({
    required this.raceId,
    required this.raceLabel,
    required this.categoryLabel,
    required this.roundType,
    required this.number,
    required this.placement,
  });
```

with:

```dart
  const ScheduleItem({
    required this.raceId,
    required this.raceLabel,
    required this.categoryLabel,
    required this.roundType,
    required this.number,
    this.placement,
  });
```

- [ ] **Step 4: Add the block functions**

Add the imports at the top of `schedule_planner.dart` (next to the existing ones):

```dart
import 'package:live_ffss/app/domain/models/schedule_block.dart';
import 'package:live_ffss/app/domain/models/site_day_start.dart';
```

Append to `lib/app/domain/models/schedule_planner.dart`:

```dart
/// The default day-start when a site×day has no [SiteDayStart] override: 09:00.
const int defaultStartMinutes = 540;

/// A block placed on the timeline with its derived begin/end times.
class ScheduleRow {
  const ScheduleRow({required this.block, required this.begin, required this.end});

  final ScheduleBlock block;
  final DateTime begin;
  final DateTime end;
}

int dayStartMinutes(CompetitionProgramme p, int siteId, DateTime day) {
  for (final s in p.dayStarts) {
    if (s.siteId == siteId && sameDay(s.day, day)) return s.startMinutes;
  }
  return defaultStartMinutes;
}

/// The (site × day) sequence with derived back-to-back times: the day's blocks
/// sorted by `order`, first at the start time, each next right after the
/// previous end.
List<ScheduleRow> scheduleRows(CompetitionProgramme p, int siteId, DateTime day) {
  final blocks = p.blocks
      .where((b) => b.siteId == siteId && sameDay(b.day, day))
      .toList()
    ..sort((a, b) => a.order.compareTo(b.order));
  var cursor = DateTime(day.year, day.month, day.day)
      .add(Duration(minutes: dayStartMinutes(p, siteId, day)));
  final rows = <ScheduleRow>[];
  for (final b in blocks) {
    final end = cursor.add(Duration(minutes: b.durationMinutes));
    rows.add(ScheduleRow(block: b, begin: cursor, end: end));
    cursor = end;
  }
  return rows;
}

/// Races in [p.structures] that no block references, for the unscheduled
/// palette. Sorted by race label then number.
List<ScheduleItem> unscheduledRaces(CompetitionProgramme p) {
  final scheduled = p.blocks
      .where((b) => b.raceId != null)
      .map((b) => b.raceId!)
      .toSet();
  final items = <ScheduleItem>[];
  for (final s in p.structures) {
    for (final l in s.levels) {
      for (final r in l.races) {
        if (scheduled.contains(r.id)) continue;
        items.add(ScheduleItem(
          raceId: r.id,
          raceLabel: s.raceLabel,
          categoryLabel: s.categoryLabel,
          roundType: l.type,
          number: r.number,
        ));
      }
    }
  }
  items.sort((a, b) {
    final byLabel = a.raceLabel.compareTo(b.raceLabel);
    if (byLabel != 0) return byLabel;
    return a.number.compareTo(b.number);
  });
  return items;
}

int _nextOrder(CompetitionProgramme p, int siteId, DateTime day) {
  var max = -1;
  for (final b in p.blocks) {
    if (b.siteId == siteId && sameDay(b.day, day) && b.order > max) {
      max = b.order;
    }
  }
  return max + 1;
}

CompetitionProgramme addRaceBlock(
        CompetitionProgramme p, int blockId, int raceId, int siteId, DateTime day) =>
    p.copyWith(blocks: [
      ...p.blocks,
      ScheduleBlock(
          id: blockId,
          siteId: siteId,
          day: day,
          order: _nextOrder(p, siteId, day),
          raceId: raceId),
    ]);

CompetitionProgramme addManualBlock(CompetitionProgramme p, int blockId,
        String label, int minutes, int siteId, DateTime day) =>
    p.copyWith(blocks: [
      ...p.blocks,
      ScheduleBlock(
          id: blockId,
          siteId: siteId,
          day: day,
          order: _nextOrder(p, siteId, day),
          durationMinutes: minutes,
          manualLabel: label),
    ]);

CompetitionProgramme setBlockDuration(
        CompetitionProgramme p, int blockId, int minutes) =>
    p.copyWith(blocks: [
      for (final b in p.blocks)
        b.id == blockId ? b.copyWith(durationMinutes: minutes) : b,
    ]);

CompetitionProgramme setManualLabel(
        CompetitionProgramme p, int blockId, String label) =>
    p.copyWith(blocks: [
      for (final b in p.blocks)
        b.id == blockId ? b.copyWith(manualLabel: label) : b,
    ]);

CompetitionProgramme _renumber(CompetitionProgramme p, int siteId, DateTime day) {
  final ofDay = p.blocks
      .where((b) => b.siteId == siteId && sameDay(b.day, day))
      .toList()
    ..sort((a, b) => a.order.compareTo(b.order));
  final others = p.blocks
      .where((b) => !(b.siteId == siteId && sameDay(b.day, day)))
      .toList();
  return p.copyWith(blocks: [
    ...others,
    for (var i = 0; i < ofDay.length; i++) ofDay[i].copyWith(order: i),
  ]);
}

CompetitionProgramme removeBlock(CompetitionProgramme p, int blockId) {
  ScheduleBlock? target;
  for (final b in p.blocks) {
    if (b.id == blockId) {
      target = b;
      break;
    }
  }
  if (target == null) return p;
  final remaining = p.copyWith(
      blocks: p.blocks.where((b) => b.id != blockId).toList());
  return _renumber(remaining, target.siteId, target.day);
}

/// Reorders the (site × day) blocks. [oldIndex]/[newIndex] follow the
/// `ReorderableListView.onReorder` convention (newIndex is the pre-removal
/// insert position, so it is decremented when moving downward).
CompetitionProgramme reorderBlocks(
    CompetitionProgramme p, int siteId, DateTime day, int oldIndex, int newIndex) {
  final ofDay = p.blocks
      .where((b) => b.siteId == siteId && sameDay(b.day, day))
      .toList()
    ..sort((a, b) => a.order.compareTo(b.order));
  if (oldIndex < 0 || oldIndex >= ofDay.length) return p;
  var target = newIndex;
  if (target > oldIndex) target -= 1;
  final moved = ofDay.removeAt(oldIndex);
  ofDay.insert(target.clamp(0, ofDay.length), moved);
  final others = p.blocks
      .where((b) => !(b.siteId == siteId && sameDay(b.day, day)))
      .toList();
  return p.copyWith(blocks: [
    ...others,
    for (var i = 0; i < ofDay.length; i++) ofDay[i].copyWith(order: i),
  ]);
}

CompetitionProgramme setDayStart(
    CompetitionProgramme p, int siteId, DateTime day, int startMinutes) {
  final others = p.dayStarts
      .where((s) => !(s.siteId == siteId && sameDay(s.day, day)))
      .toList();
  return p.copyWith(dayStarts: [
    ...others,
    SiteDayStart(siteId: siteId, day: day, startMinutes: startMinutes),
  ]);
}

/// Drops every block and day-start of [siteId] — used when a site is deleted.
CompetitionProgramme clearBlocksForSite(CompetitionProgramme p, int siteId) =>
    p.copyWith(
      blocks: p.blocks.where((b) => b.siteId != siteId).toList(),
      dayStarts: p.dayStarts.where((s) => s.siteId != siteId).toList(),
    );
```

- [ ] **Step 5: Run test to verify it passes**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/data/models/schedule_blocks_planner_test.dart
```

Expected: PASS — 11 tests.

- [ ] **Step 6: Commit**

```bash
git add lib/app/domain/models/schedule_planner.dart test/data/models/schedule_blocks_planner_test.dart
git commit -m "feat(programme): add block-based scheduling planner functions"
```

---

### Task 3: Rewrite ScheduleController on blocks

Replaces the placement-based controller with the block API. The old planner functions still exist (removed in Task 6) but this controller no longer uses them.

**Files:**
- Modify (replace body): `lib/app/module/programme/controllers/schedule_controller.dart`
- Test (replace): `test/presentation/modules/programme/controllers/schedule_controller_test.dart`

**Interfaces:**
- Consumes: `ProgrammeService`, `Competition`, `CompetitionProgramme`, `ProgrammeSite`, the block planner (`scheduleRows`, `ScheduleRow`, `unscheduledRaces`, `dayStartMinutes`, `defaultStartMinutes`, `competitionDays`, `sameDay`, `addRaceBlock`, `addManualBlock`, `setBlockDuration`, `setManualLabel`, `removeBlock`, `reorderBlocks`, `setDayStart`, `ScheduleItem`)
- Produces: `ScheduleController(ProgrammeService)` with `competition`, `days`, `selectedDayIndex`, `selectedSiteId`; getters `sites`, `selectedDay`, `unscheduled`; `List<ScheduleRow> rowsFor(int siteId, DateTime day)`; `int startMinutesFor(int siteId, DateTime day)`; `void setCompetition(Competition?)`; `Future<void> addRace(int raceId, int siteId, DateTime day)`; `Future<void> addManual(String label, int minutes, int siteId, DateTime day)`; `Future<void> reorder(int siteId, DateTime day, int oldIndex, int newIndex)`; `Future<void> setDuration(int blockId, int minutes)`; `Future<void> setManualLabel(int blockId, String label)`; `Future<void> removeBlock(int blockId)`; `Future<void> setDayStart(int siteId, DateTime day, int minutes)`

- [ ] **Step 1: Write the failing test** (replace the file's contents)

Overwrite `test/presentation/modules/programme/controllers/schedule_controller_test.dart`:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/programme_site.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/module/programme/controllers/schedule_controller.dart';
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

  CompetitionProgramme seed() => const CompetitionProgramme(
        competitionId: 42,
        nextLocalId: 100,
        sites: [ProgrammeSite(id: 1, name: 'Côtier 1', type: SiteType.cotier)],
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
            ],
          ),
        ],
      );

  setUp(() async {
    storage = _MockStorage();
    when(() => storage.read(key: any(named: 'key'))).thenAnswer((_) async => null);
    when(() => storage.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((_) async {});
    service = ProgrammeService(storage);
    await service.save(seed());
    controller = ScheduleController(service);
    controller.setCompetition(withDates);
  });

  test('setCompetition derives days and defaults the site', () {
    expect(controller.days, [DateTime(2026, 6, 13), DateTime(2026, 6, 14)]);
    expect(controller.selectedSiteId.value, 1);
  });

  test('unscheduled lists races with no block', () {
    expect(controller.unscheduled.map((i) => i.raceId), [10, 11]);
  });

  test('addRace appends a race block; the next appends after it', () async {
    await controller.addRace(10, 1, day);
    await controller.addRace(11, 1, day);
    final rows = controller.rowsFor(1, day);
    expect(rows.map((r) => r.block.raceId), [10, 11]);
    expect(rows[0].begin, DateTime(2026, 6, 13, 9));
    expect(rows[1].begin, DateTime(2026, 6, 13, 9, 10));
    expect(controller.unscheduled, isEmpty);
  });

  test('addManual inserts a manual block into the sequence', () async {
    await controller.addRace(10, 1, day);
    await controller.addManual('Pause', 30, 1, day);
    final rows = controller.rowsFor(1, day);
    expect(rows[1].block.manualLabel, 'Pause');
    expect(rows[1].begin, DateTime(2026, 6, 13, 9, 10));
  });

  test('reorder moves a block and reflows times', () async {
    await controller.addRace(10, 1, day);
    await controller.addRace(11, 1, day);
    await controller.reorder(1, day, 1, 0);
    final rows = controller.rowsFor(1, day);
    expect(rows.map((r) => r.block.raceId), [11, 10]);
    expect(rows[0].begin, DateTime(2026, 6, 13, 9));
  });

  test('setDuration reflows following blocks', () async {
    await controller.addRace(10, 1, day);
    await controller.addRace(11, 1, day);
    final firstBlockId = controller.rowsFor(1, day).first.block.id;
    await controller.setDuration(firstBlockId, 20);
    expect(controller.rowsFor(1, day)[1].begin, DateTime(2026, 6, 13, 9, 20));
  });

  test('removeBlock on a race returns it to the palette', () async {
    await controller.addRace(10, 1, day);
    final blockId = controller.rowsFor(1, day).single.block.id;
    await controller.removeBlock(blockId);
    expect(controller.rowsFor(1, day), isEmpty);
    expect(controller.unscheduled.map((i) => i.raceId), contains(10));
  });

  test('setDayStart shifts all derived times', () async {
    await controller.addRace(10, 1, day);
    await controller.setDayStart(1, day, 8 * 60 + 30);
    expect(controller.rowsFor(1, day).single.begin, DateTime(2026, 6, 13, 8, 30));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/presentation/modules/programme/controllers/schedule_controller_test.dart
```

Expected: FAIL — the controller still has the old placement API.

- [ ] **Step 3: Rewrite the controller** (replace the whole file)

Overwrite `lib/app/module/programme/controllers/schedule_controller.dart`:

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/programme_site.dart';
import 'package:live_ffss/app/domain/models/schedule_planner.dart';

class ScheduleController extends GetxController {
  ScheduleController(this._programme);

  final ProgrammeService _programme;

  final Rxn<Competition> competition = Rxn<Competition>();
  final RxList<DateTime> days = <DateTime>[].obs;
  final RxInt selectedDayIndex = 0.obs;
  final Rxn<int> selectedSiteId = Rxn<int>();

  Worker? _worker;

  @override
  void onInit() {
    super.onInit();
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

  DateTime? get selectedDay => days.isEmpty
      ? null
      : days[selectedDayIndex.value.clamp(0, days.length - 1)];

  void setCompetition(Competition? comp) {
    if (comp == competition.value) return;
    competition.value = comp;
    days.value = competitionDays(comp?.beginDate, comp?.endDate);
    selectedDayIndex.value = 0;
    if (selectedSiteId.value == null && sites.isNotEmpty) {
      selectedSiteId.value = sites.first.id;
    }
  }

  List<ScheduleRow> rowsFor(int siteId, DateTime day) {
    final p = _p;
    return p == null ? const [] : scheduleRows(p, siteId, day);
  }

  List<ScheduleItem> get unscheduled {
    final p = _p;
    return p == null ? const [] : unscheduledRaces(p);
  }

  int startMinutesFor(int siteId, DateTime day) {
    final p = _p;
    return p == null ? defaultStartMinutes : dayStartMinutes(p, siteId, day);
  }

  Future<void> addRace(int raceId, int siteId, DateTime day) async {
    if (_p == null) return;
    final id = _programme.allocateId();
    await _programme.save(addRaceBlock(_programme.current.value!, id, raceId, siteId, day));
  }

  Future<void> addManual(String label, int minutes, int siteId, DateTime day) async {
    final trimmed = label.trim();
    if (trimmed.isEmpty || minutes < 1 || _p == null) return;
    final id = _programme.allocateId();
    await _programme.save(
        addManualBlock(_programme.current.value!, id, trimmed, minutes, siteId, day));
  }

  Future<void> reorder(int siteId, DateTime day, int oldIndex, int newIndex) async {
    final p = _p;
    if (p == null) return;
    await _programme.save(reorderBlocks(p, siteId, day, oldIndex, newIndex));
  }

  Future<void> setDuration(int blockId, int minutes) async {
    if (minutes < 1) return;
    final p = _p;
    if (p == null) return;
    await _programme.save(setBlockDuration(p, blockId, minutes));
  }

  Future<void> setManualLabel(int blockId, String label) async {
    final trimmed = label.trim();
    if (trimmed.isEmpty) return;
    final p = _p;
    if (p == null) return;
    await _programme.save(setManualLabel(p, blockId, trimmed));
  }

  Future<void> removeBlock(int blockId) async {
    final p = _p;
    if (p == null) return;
    await _programme.save(removeBlock(p, blockId));
  }

  Future<void> setDayStart(int siteId, DateTime day, int minutes) async {
    final p = _p;
    if (p == null) return;
    await _programme.save(setDayStart(p, siteId, day, minutes));
  }
}
```

Note: the controller method `removeBlock`/`setManualLabel`/`setDayStart`/`setDuration` share names with the planner top-level functions; inside the controller they call the planner functions (top-level), which resolve because the controller methods are instance methods — Dart disambiguates the bare call to the imported top-level function. If the analyzer flags a self-reference, prefix the planner call, e.g. `setBlockDuration` is already distinct; for `removeBlock`/`setManualLabel`/`setDayStart` the planner names differ enough (`removeBlock` collides). To avoid ambiguity, the planner's `removeBlock`/`setManualLabel`/`setDayStart` are top-level and the controller's are instance methods — a bare call inside the instance method resolves to the instance method (recursion!). **Rename the controller methods' internal calls** by importing the planner and calling its functions explicitly is impossible without a prefix. Therefore: in the controller, call the planner via a library prefix. Change the planner import to:

```dart
import 'package:live_ffss/app/domain/models/schedule_planner.dart' as planner;
```

and inside the controller use `planner.scheduleRows`, `planner.unscheduledRaces`, `planner.dayStartMinutes`, `planner.defaultStartMinutes`, `planner.competitionDays`, `planner.addRaceBlock`, `planner.addManualBlock`, `planner.reorderBlocks`, `planner.setBlockDuration`, `planner.setManualLabel`, `planner.removeBlock`, `planner.setDayStart`, and the types `planner.ScheduleRow` / `planner.ScheduleItem`. This removes all name collisions. (Apply the prefix throughout the controller body shown above.)

- [ ] **Step 4: Run test to verify it passes**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/presentation/modules/programme/controllers/schedule_controller_test.dart
```

Expected: PASS — 8 tests.

- [ ] **Step 5: Verify the controller/binding analyze (view not yet updated)**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat analyze lib/app/module/programme/controllers/schedule_controller.dart
```

Expected: `No issues found!` (the view still references old members — its analyze comes in Task 4; scope to the controller file here).

- [ ] **Step 6: Commit**

```bash
git add lib/app/module/programme/controllers/schedule_controller.dart test/presentation/modules/programme/controllers/schedule_controller_test.dart
git commit -m "feat(programme): rewrite ScheduleController on blocks"
```

---

### Task 4: The Direction-B interactive view + translations

Replaces `ScheduleView` with the accent-bar agenda: day chips, site chips, an editable start chip, a `ReorderableListView` of accent cards (drag to reorder, ± duration, remove), a "+ item" FAB (manual dialog), and the unscheduled palette. Also adds the manual/start translation keys and removes the now-dead `schedule_overlap`.

**Files:**
- Modify (replace): `lib/app/module/programme/views/schedule_view.dart`
- Modify: `lib/app/core/translations/fr_fr.dart`, `lib/app/core/translations/en_us.dart`

No unit tests (views). Verified via `flutter run`.

**Interfaces:**
- Consumes: the Task-3 `ScheduleController` (`rowsFor`, `unscheduled`, `startMinutesFor`, `addRace`, `addManual`, `reorder`, `setDuration`, `setManualLabel`, `removeBlock`, `setDayStart`, `days`, `selectedDayIndex`, `selectedSiteId`, `selectedDay`, `sites`, `setCompetition`, `competition`), `ProgrammeController.competition`, `ScheduleRow`, `ScheduleItem`, `SitesView`, `ScheduleItemFormatting.label`, `RoundTypeFormatting`, `FormatConst`, theme, `EmptyState`.

- [ ] **Step 1: Add the translation keys**

In `lib/app/core/translations/fr_fr.dart`, remove the `'schedule_overlap': ...` line (overlaps no longer exist) and add, before the final `};`:

```dart
  'add_manual_item': 'Ajouter un item',
  'manual_label': 'Libellé',
  'duration_min': 'Durée (min)',
  'starts_at': 'Départ',
  'edit_item': 'Modifier',
```

In `lib/app/core/translations/en_us.dart`, remove `'schedule_overlap': ...` and add:

```dart
  'add_manual_item': 'Add an item',
  'manual_label': 'Label',
  'duration_min': 'Duration (min)',
  'starts_at': 'Starts',
  'edit_item': 'Edit',
```

- [ ] **Step 2: Rewrite the view** (replace the whole file)

Overwrite `lib/app/module/programme/views/schedule_view.dart`:

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
import 'package:live_ffss/app/module/programme/controllers/programme_controller.dart';
import 'package:live_ffss/app/module/programme/controllers/schedule_controller.dart';
import 'package:live_ffss/app/module/programme/views/sites_view.dart';
import 'package:live_ffss/app/presentation/modules/programme/programme_formatting.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';

class ScheduleView extends StatefulWidget {
  const ScheduleView({super.key});

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  final _controller = Get.find<ScheduleController>();
  final _programme = Get.find<ProgrammeController>();
  Worker? _compWorker;

  @override
  void initState() {
    super.initState();
    _compWorker = ever(_programme.competition, _controller.setCompetition);
    _controller.setCompetition(_programme.competition.value);
  }

  @override
  void dispose() {
    _compWorker?.dispose();
    super.dispose();
  }

  String _hhmm(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';

  Future<void> _pickStart(int siteId, DateTime day) async {
    final current = _controller.startMinutesFor(siteId, day);
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
    );
    if (picked != null) {
      _controller.setDayStart(siteId, day, picked.hour * 60 + picked.minute);
    }
  }

  Future<void> _addManual(int siteId, DateTime day) async {
    final labelController = TextEditingController();
    var minutes = 15;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text('add_manual_item'.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelController,
                decoration: InputDecoration(labelText: 'manual_label'.tr),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('duration_min'.tr, style: AppTypography.caption),
                  Row(children: [
                    IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: minutes > 5
                            ? () => setState(() => minutes -= 5)
                            : null),
                    Text('$minutes', style: AppTypography.body),
                    IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => setState(() => minutes += 5)),
                  ]),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text('cancel'.tr)),
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text('save'.tr)),
          ],
        ),
      ),
    );
    if (ok == true) {
      _controller.addManual(labelController.text, minutes, siteId, day);
    }
  }

  Future<void> _editLabel(int blockId, String current) async {
    final labelController = TextEditingController(text: current);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('edit_item'.tr),
        content: TextField(
          controller: labelController,
          decoration: InputDecoration(labelText: 'manual_label'.tr),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('cancel'.tr)),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text('save'.tr)),
        ],
      ),
    );
    if (ok == true) {
      _controller.setManualLabel(blockId, labelController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_controller.days.isEmpty) {
        return EmptyState(icon: Icons.event_busy, title: 'no_days'.tr);
      }
      final siteId = _controller.selectedSiteId.value;
      final day = _controller.selectedDay;
      return Stack(
        children: [
          Column(
            children: [
              _DayChips(controller: _controller),
              _SiteChips(controller: _controller, onEditStart: _pickStart, hhmm: _hhmm),
              const SizedBox(height: AppSpacing.xs),
              Expanded(
                child: (siteId == null || day == null)
                    ? EmptyState(icon: Icons.place_outlined, title: 'no_sites'.tr)
                    : _Timeline(
                        controller: _controller,
                        siteId: siteId,
                        day: day,
                        onEditLabel: _editLabel,
                      ),
              ),
              const Divider(height: 1),
              _Palette(controller: _controller),
            ],
          ),
          if (siteId != null && day != null)
            Positioned(
              right: AppSpacing.md,
              bottom: 180,
              child: FloatingActionButton.extended(
                heroTag: 'addManual',
                onPressed: () => _addManual(siteId, day),
                icon: const Icon(Icons.add),
                label: Text('add_manual_item'.tr),
              ),
            ),
        ],
      );
    });
  }
}

class _DayChips extends StatelessWidget {
  const _DayChips({required this.controller});
  final ScheduleController controller;

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
  const _SiteChips({
    required this.controller,
    required this.onEditStart,
    required this.hhmm,
  });
  final ScheduleController controller;
  final Future<void> Function(int siteId, DateTime day) onEditStart;
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
              child: sites.isEmpty
                  ? Text('no_sites'.tr, style: AppTypography.caption)
                  : SizedBox(
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
                                color: active
                                    ? AppColors.primary
                                    : AppColors.surface,
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
              GestureDetector(
                onTap: () => onEditStart(selectedId, day),
                child: Container(
                  margin: const EdgeInsets.only(left: AppSpacing.sm),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: AppRadius.pillRadius,
                  ),
                  child: Text(
                    '${'starts_at'.tr} ${hhmm(controller.startMinutesFor(selectedId, day))} ▾',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.primaryDark),
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'sites'.tr,
              onPressed: () => Get.to<void>(() => const SitesView()),
            ),
          ],
        );
      }),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({
    required this.controller,
    required this.siteId,
    required this.day,
    required this.onEditLabel,
  });
  final ScheduleController controller;
  final int siteId;
  final DateTime day;
  final Future<void> Function(int blockId, String current) onEditLabel;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Depend on the programme so reflows rebuild; rowsFor reads current.
      controller.selectedSiteId.value;
      final rows = controller.rowsFor(siteId, day);
      if (rows.isEmpty) {
        return EmptyState(icon: Icons.schedule, title: 'no_placement_here'.tr);
      }
      return ReorderableListView.builder(
        padding: AppSpacing.pageAll,
        itemCount: rows.length,
        onReorder: (oldIndex, newIndex) =>
            controller.reorder(siteId, day, oldIndex, newIndex),
        itemBuilder: (context, i) {
          final row = rows[i];
          final b = row.block;
          final isManual = b.raceId == null;
          return Padding(
            key: ValueKey(b.id),
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: _AccentCard(
              index: i,
              begin: FormatConst.timeFormat.format(row.begin),
              end: FormatConst.timeFormat.format(row.end),
              duration: b.durationMinutes,
              label: isManual
                  ? b.manualLabel
                  : (controller.scheduleItemFor(b.raceId!)?.label ?? ''),
              accent: isManual
                  ? AppColors.statusWaiting
                  : (controller.roundOf(b.raceId!) == RoundType.finale
                      ? AppColors.statusFinished
                      : AppColors.primary),
              onMinus: () => controller.setDuration(b.id, b.durationMinutes - 5),
              onPlus: () => controller.setDuration(b.id, b.durationMinutes + 5),
              onRemove: () => controller.removeBlock(b.id),
              onEditLabel:
                  isManual ? () => onEditLabel(b.id, b.manualLabel) : null,
            ),
          );
        },
      );
    });
  }
}

class _AccentCard extends StatelessWidget {
  const _AccentCard({
    required this.index,
    required this.begin,
    required this.end,
    required this.duration,
    required this.label,
    required this.accent,
    required this.onMinus,
    required this.onPlus,
    required this.onRemove,
    required this.onEditLabel,
  });
  final int index;
  final String begin;
  final String end;
  final int duration;
  final String label;
  final Color accent;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onRemove;
  final VoidCallback? onEditLabel;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.mdRadius,
      elevation: 1,
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
          ReorderableDragStartListener(
            index: index,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Icon(Icons.drag_indicator, color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onEditLabel,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(children: [
                      Text(begin,
                          style: AppTypography.body.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark)),
                      const SizedBox(width: 6),
                      Text('→ $end · $duration ${'min_short'.tr}',
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
          ),
          IconButton(
              icon: const Icon(Icons.remove, size: 20), onPressed: onMinus),
          IconButton(icon: const Icon(Icons.add, size: 20), onPressed: onPlus),
          IconButton(
              icon: const Icon(Icons.close, size: 20), onPressed: onRemove),
        ],
      ),
    );
  }
}

class _Palette extends StatelessWidget {
  const _Palette({required this.controller});
  final ScheduleController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.unscheduled;
      final siteId = controller.selectedSiteId.value;
      final day = controller.selectedDay;
      return Container(
        constraints: const BoxConstraints(maxHeight: 150),
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
                  return ListTile(
                    dense: true,
                    title: Text(item.label,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: TextButton(
                      onPressed: (siteId == null || day == null)
                          ? null
                          : () => controller.addRace(item.raceId, siteId, day),
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

This view needs a race block's `ScheduleItem` (to render its label via the `ScheduleItemFormatting.label` extension the view already imports) and its round type (to colour the accent bar). Both are looked up from the structure tree — done in the controller so the view need not re-walk it. **`.tr` stays out of the controller:** `scheduleItemFor` returns a plain `planner.ScheduleItem` (no translation); the view calls `.label` on it. Append these two methods to `ScheduleController` (the Task-3 file):

```dart
  planner.ScheduleItem? scheduleItemFor(int raceId) {
    final p = _p;
    if (p == null) return null;
    for (final s in p.structures) {
      for (final l in s.levels) {
        for (final r in l.races) {
          if (r.id == raceId) {
            return planner.ScheduleItem(
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

  RoundType roundOf(int raceId) {
    final p = _p;
    if (p == null) return RoundType.unknown;
    for (final s in p.structures) {
      for (final l in s.levels) {
        for (final r in l.races) {
          if (r.id == raceId) return l.type;
        }
      }
    }
    return RoundType.unknown;
  }
```

Add `import 'package:live_ffss/app/domain/models/round_level.dart';` to the controller for `RoundType`. `ScheduleItem` is the prefixed planner type (`planner.ScheduleItem`) — no formatting import in the controller. The view already imports `programme_formatting.dart`, so `controller.scheduleItemFor(b.raceId!)?.label` resolves there.

- [ ] **Step 3: Verify analyze + full suite**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat analyze
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test
```

Expected: analyze clean; full suite passes (the old placement code still compiles — it's removed in Task 6).

- [ ] **Step 4: Verify on a device/emulator**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat run
```

Open a competition with dates → Programme tab → gear opens Sites (works with sites defined) → add "Côtier 1"/"Sable 1" → back → pick a day + a site chip → tap "Ajouter une course" on a palette race → it appears at 09:00; add another → 09:10 → drag the second above the first → times swap and reflow → tap "+ item", enter "Pause" 30 min → it appears (orange bar) → drag it, times reflow → tap the start chip → pick 08:30 → everything shifts → the × removes a block (race returns to palette).

- [ ] **Step 5: Commit**

```bash
git add lib/app/module/programme/views/schedule_view.dart lib/app/module/programme/controllers/schedule_controller.dart lib/app/core/translations/fr_fr.dart lib/app/core/translations/en_us.dart
git commit -m "feat(programme): add the Direction-B interactive scheduling view"
```

---

### Task 5: Rewrite the FFSS sync mapper on blocks

`programmeToMeetings` reads race blocks (with derived times) instead of `RacePlacement`. Manual blocks are omitted. Grouping into Meeting/Slot is unchanged.

**Files:**
- Modify (replace): `lib/app/data/mappers/programme_ffss_mapper.dart`
- Test (replace): `test/data/mappers/programme_ffss_mapper_test.dart`

**Interfaces:**
- Consumes: `CompetitionProgramme`, `ScheduleBlock`, `EventStructure`, `RoundLevel`, `RoundType`, the block planner (`scheduleRows`, `sameDay`, `ScheduleRow`), FFSS classes (`Meeting`, `Slot`, `Run`, `RunStatus`, `Heat`, `RaceFormatDetail`)
- Produces: `List<Meeting> programmeToMeetings(CompetitionProgramme p, {required String competitionName})` (unchanged signature; blocks-based body)

- [ ] **Step 1: Write the failing test** (replace the file)

Overwrite `test/data/mappers/programme_ffss_mapper_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/mappers/programme_ffss_mapper.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/domain/models/run.dart';
import 'package:live_ffss/app/domain/models/schedule_block.dart';

void main() {
  final day = DateTime(2026, 6, 13);

  CompetitionProgramme prog(List<ScheduleBlock> blocks, {List<int> raceIds = const [1, 2]}) =>
      CompetitionProgramme(
        competitionId: 42,
        structures: [
          EventStructure(
            raceId: 500,
            categoryId: 7,
            raceLabel: '100m',
            categoryLabel: 'Cadets',
            spotsPerRace: 8,
            levels: [
              RoundLevel(
                type: RoundType.serie,
                qualifiersPerRace: 2,
                races: [for (final id in raceIds) ProgrammeRace(id: id, number: id)],
              ),
            ],
          ),
        ],
        blocks: blocks,
      );

  test('no blocks → no meetings', () {
    expect(programmeToMeetings(prog(const []), competitionName: 'C'), isEmpty);
  });

  test('one race block → one meeting/slot/run at the derived time', () {
    final meetings = programmeToMeetings(
      prog([ScheduleBlock(id: 9, siteId: 3, day: day, order: 0, raceId: 1)]),
      competitionName: 'C',
    );
    expect(meetings.length, 1);
    expect(meetings.single.date, DateTime(2026, 6, 13));
    final slot = meetings.single.slots.single;
    expect(slot.raceFormatDetail!.spotsPerRace, 8);
    expect(slot.raceFormatDetail!.level, '');
    final run = slot.runs.single;
    expect(run.beginTime, DateTime(2026, 6, 13, 9)); // default start
    expect(run.endTime, DateTime(2026, 6, 13, 9, 10));
    expect(run.status, RunStatus.waiting);
    expect(run.site, '3');
  });

  test('a manual block is omitted from the mapper output', () {
    final meetings = programmeToMeetings(
      prog([
        ScheduleBlock(id: 9, siteId: 3, day: day, order: 0, raceId: 1),
        ScheduleBlock(id: 10, siteId: 3, day: day, order: 1, manualLabel: 'Pause', durationMinutes: 30),
      ]),
      competitionName: 'C',
    );
    expect(meetings.single.slots.single.runs.length, 1); // only the race
  });

  test('two race blocks of the same level+day group under one slot with derived times', () {
    final meetings = programmeToMeetings(
      prog([
        ScheduleBlock(id: 9, siteId: 3, day: day, order: 0, raceId: 1),
        ScheduleBlock(id: 10, siteId: 3, day: day, order: 1, raceId: 2),
      ]),
      competitionName: 'C',
    );
    final runs = meetings.single.slots.single.runs;
    expect(runs.length, 2);
    expect(runs.map((r) => r.beginTime),
        [DateTime(2026, 6, 13, 9), DateTime(2026, 6, 13, 9, 10)]);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/data/mappers/programme_ffss_mapper_test.dart
```

Expected: FAIL — the mapper still reads `placement`.

- [ ] **Step 3: Rewrite the mapper** (replace the whole file)

Overwrite `lib/app/data/mappers/programme_ffss_mapper.dart`:

```dart
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/heat.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';
import 'package:live_ffss/app/domain/models/race_format_detail.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/domain/models/run.dart';
import 'package:live_ffss/app/domain/models/schedule_planner.dart';
import 'package:live_ffss/app/domain/models/slot.dart';

/// Materialises the block schedule into the FFSS `Meeting → Slot → Run` tree.
/// Pure and deterministic; the network push waits on the FFSS créneau/course
/// endpoints (see the stubbed `ProgrammeRemoteDataSource`). Only **race**
/// blocks appear — manual items have no FFSS course equivalent and are
/// omitted. One Meeting per day, one Slot per (structure raceId × level index),
/// one Run per race block, times derived from the block sequence.
List<Meeting> programmeToMeetings(
  CompetitionProgramme p, {
  required String competitionName,
}) {
  // Index every race → (structure, level, level index) for label/format lookup.
  final index = <int, _RaceRef>{};
  for (final s in p.structures) {
    for (var li = 0; li < s.levels.length; li++) {
      final level = s.levels[li];
      for (final r in level.races) {
        index[r.id] = _RaceRef(
          structureRaceId: s.raceId,
          levelIndex: li,
          level: level,
          raceLabel: s.raceLabel,
          categoryLabel: s.categoryLabel,
          spotsPerRace: s.spotsPerRace,
          raceNumber: r.number,
        );
      }
    }
  }

  // Derive begin/end for every race block, grouped by day.
  final siteDays = <(int, DateTime)>[];
  for (final b in p.blocks) {
    final key = (b.siteId, DateTime(b.day.year, b.day.month, b.day.day));
    if (!siteDays.contains(key)) siteDays.add(key);
  }

  final placed = <_Placed>[];
  for (final key in siteDays) {
    for (final row in scheduleRows(p, key.$1, key.$2)) {
      final raceId = row.block.raceId;
      if (raceId == null) continue; // skip manual blocks
      final ref = index[raceId];
      if (ref == null) continue;
      placed.add(_Placed(
        ref: ref,
        raceLocalId: raceId,
        site: key.$1,
        begin: row.begin,
        end: row.end,
      ));
    }
  }
  if (placed.isEmpty) return const [];

  final days = <DateTime>[];
  for (final pl in placed) {
    final day = DateTime(pl.begin.year, pl.begin.month, pl.begin.day);
    if (!days.any((d) => sameDay(d, day))) days.add(day);
  }
  days.sort();

  final meetings = <Meeting>[];
  for (final day in days) {
    final ofDay = placed.where((pl) => sameDay(pl.begin, day)).toList();

    final slotKeys = <(int, int)>[];
    for (final pl in ofDay) {
      final key = (pl.ref.structureRaceId, pl.ref.levelIndex);
      if (!slotKeys.contains(key)) slotKeys.add(key);
    }

    final slots = <Slot>[];
    for (final key in slotKeys) {
      final ofSlot = ofDay
          .where((pl) =>
              pl.ref.structureRaceId == key.$1 && pl.ref.levelIndex == key.$2)
          .toList()
        ..sort((a, b) => a.begin.compareTo(b.begin));
      final ref = ofSlot.first.ref;
      final runs = [
        for (final pl in ofSlot)
          Run(
            id: pl.raceLocalId,
            name: '${_roundName(pl.ref.level.type)} ${pl.ref.raceNumber}',
            label: '${pl.ref.raceLabel} · ${pl.ref.categoryLabel}',
            fullLabel:
                '${pl.ref.raceLabel} · ${pl.ref.categoryLabel} · ${_roundName(pl.ref.level.type)} ${pl.ref.raceNumber}',
            status: RunStatus.waiting,
            statusLabel: '',
            site: pl.site.toString(),
            beginTime: pl.begin,
            endTime: pl.end,
            heat: Heat(number: pl.ref.raceNumber),
          ),
      ];
      slots.add(Slot(
        id: _slotId(key),
        name: '${ref.raceLabel} · ${_roundName(ref.level.type)}',
        beginHour: runs.first.beginTime,
        endHour:
            runs.map((r) => r.endTime).reduce((a, b) => a.isAfter(b) ? a : b),
        raceFormatDetail: RaceFormatDetail(
          id: _slotId(key),
          order: key.$2,
          label: _roundName(ref.level.type),
          fullLabel: _roundName(ref.level.type),
          levelLabel: '',
          level: '',
          numberOfRun: ofSlot.length,
          qualificationMethod: '',
          qualificationMethodLabel: '',
          spotsPerRace: ref.spotsPerRace,
          qualifyingSpots: ref.level.qualifiersPerRace,
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

String _roundName(RoundType type) => switch (type) {
      RoundType.serie => 'Series',
      RoundType.quart => 'Quarter',
      RoundType.demi => 'Semi',
      RoundType.finale => 'Final',
      RoundType.unknown => 'Round',
    };

// Throwaway slot id from (structure raceId, level index). Assumes < 100 levels
// per structure; the real FFSS sync reconciles these ids anyway.
int _slotId((int, int) key) => key.$1 * 100 + key.$2;

class _RaceRef {
  _RaceRef({
    required this.structureRaceId,
    required this.levelIndex,
    required this.level,
    required this.raceLabel,
    required this.categoryLabel,
    required this.spotsPerRace,
    required this.raceNumber,
  });
  final int structureRaceId;
  final int levelIndex;
  final RoundLevel level;
  final String raceLabel;
  final String categoryLabel;
  final int spotsPerRace;
  final int raceNumber;
}

class _Placed {
  _Placed({
    required this.ref,
    required this.raceLocalId,
    required this.site,
    required this.begin,
    required this.end,
  });
  final _RaceRef ref;
  final int raceLocalId;
  final int site;
  final DateTime begin;
  final DateTime end;
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/data/mappers/programme_ffss_mapper_test.dart
```

Expected: PASS — 4 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/app/data/mappers/programme_ffss_mapper.dart test/data/mappers/programme_ffss_mapper_test.dart
git commit -m "feat(programme): rewrite the FFSS mapper on blocks"
```

---

### Task 6: Remove the placement layer (cleanup)

Removes `ProgrammeRace.placement`, `RacePlacement`, the old placement planner functions and `ScheduleItem.placement`, `RacePlacementFormatting`; points `SitesController` at `clearBlocksForSite`; fixes the last placement-referencing tests. After this the whole suite compiles and passes with no placement code left.

**Files:**
- Modify: `lib/app/domain/models/programme_race.dart` (remove `placement` + the import)
- Delete: `lib/app/domain/models/race_placement.dart` (+ `.freezed.dart` + `.g.dart`)
- Modify: `lib/app/domain/models/schedule_planner.dart` (remove old functions + `ScheduleItem.placement`)
- Modify: `lib/app/presentation/modules/programme/programme_formatting.dart` (remove `RacePlacementFormatting` + import)
- Modify: `lib/app/module/programme/controllers/sites_controller.dart` (`clearPlacementsForSite` → `clearBlocksForSite`)
- Delete: `test/data/models/schedule_planner_test.dart` (its placement-based cases are superseded by `schedule_blocks_planner_test.dart`)
- Modify: `test/data/models/competition_programme_test.dart`, `test/data/models/programme_leaf_models_test.dart`, `test/presentation/modules/programme/programme_formatting_test.dart` (drop RacePlacement usages)

- [ ] **Step 1: Remove `placement` from `ProgrammeRace`**

In `lib/app/domain/models/programme_race.dart`: delete the `import '...race_placement.dart';` line and the `RacePlacement? placement,` field (with its comment). The factory becomes `id`, `number`, `sourceRaceIds` only.

- [ ] **Step 2: Delete `race_placement.dart` and its generated files**

```bash
rm lib/app/domain/models/race_placement.dart lib/app/domain/models/race_placement.freezed.dart lib/app/domain/models/race_placement.g.dart
```

- [ ] **Step 3: Remove the old planner functions and `ScheduleItem.placement`**

In `lib/app/domain/models/schedule_planner.dart`:
- delete the `import '...race_placement.dart';` line;
- delete `const int scheduleDayStartHour = 9;`;
- delete the `RacePlacement? placement;` field and the `this.placement,` constructor param from `ScheduleItem` (it is now `{raceId, raceLabel, categoryLabel, roundType, number}`);
- delete `allScheduleItems`, `placementEnd`, `nextFreeStart`, `overlaps`, `setPlacement`, `clearPlacementsForSite` (the block functions from Task 2 remain).

- [ ] **Step 4: Remove `RacePlacementFormatting`**

In `lib/app/presentation/modules/programme/programme_formatting.dart`: delete the `import '...race_placement.dart';` line and the entire `extension RacePlacementFormatting on RacePlacement { ... }`. Keep `ScheduleItemFormatting`, `RoundTypeFormatting`, `EventStructureFormatting`.

- [ ] **Step 5: Point `SitesController` at `clearBlocksForSite`**

In `lib/app/module/programme/controllers/sites_controller.dart`, in `deleteSite`, replace `clearPlacementsForSite(withoutSite, id)` with `clearBlocksForSite(withoutSite, id)` (same import, `schedule_planner.dart`).

- [ ] **Step 6: Fix the remaining tests**

Delete the superseded placement planner test:

```bash
rm test/data/models/schedule_planner_test.dart
```

In `test/data/models/competition_programme_test.dart`: remove the `import '...race_placement.dart';`, and in the sample tree replace the finale race's `placement: RacePlacement(...)` with no placement (`ProgrammeRace(id: 3, number: 1, sourceRaceIds: const [1, 2])`); remove the `expect(race.placement, isNull);` line from the "unscheduled race" test (keep the `sourceRaceIds` assertion).

In `test/data/models/programme_leaf_models_test.dart`: delete the `import '...race_placement.dart';` and the entire `group('RacePlacement', ...)` block (keep the `ProgrammeSite` group).

In `test/presentation/modules/programme/programme_formatting_test.dart`: delete the `import '...race_placement.dart';` and the `endHour` test that builds a `RacePlacement` (keep the `labelKey`, `chain`, `isDefined` tests).

- [ ] **Step 7: Run codegen (ProgrammeRace changed)**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\dart.bat run build_runner build --delete-conflicting-outputs
```

Expected: regenerates `programme_race.freezed/g.dart` without `placement`; the `race_placement` generated files stay deleted. "Succeeded".

- [ ] **Step 8: Verify the whole suite + analyze**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat analyze
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test
```

Expected: analyze fully clean (no reference to `RacePlacement`/`placement` anywhere); the full suite passes.

- [ ] **Step 9: Commit**

```bash
git add lib/app/domain/models/programme_race.dart lib/app/domain/models/programme_race.freezed.dart lib/app/domain/models/programme_race.g.dart lib/app/domain/models/schedule_planner.dart lib/app/presentation/modules/programme/programme_formatting.dart lib/app/module/programme/controllers/sites_controller.dart test/data/models/competition_programme_test.dart test/data/models/programme_leaf_models_test.dart test/presentation/modules/programme/programme_formatting_test.dart
git rm lib/app/domain/models/race_placement.dart lib/app/domain/models/race_placement.freezed.dart lib/app/domain/models/race_placement.g.dart test/data/models/schedule_planner_test.dart
git commit -m "refactor(programme): remove the placement layer, replaced by blocks"
```

---

## Notes for the reviewer

- **The migration compiles at every task.** Placement stays live through Tasks 1–5 (unused after Task 3) and is removed only in Task 6. If a task leaves the tree non-compiling, that is a defect.
- **`ScheduleController` uses a prefixed planner import** (`as planner`) because several controller methods share names with planner top-level functions (`removeBlock`, `setManualLabel`, `setDayStart`) — a bare call would recurse into the instance method. Every planner call in the controller must be `planner.<fn>`.
- **`.tr` stays out of the controller:** the controller exposes `scheduleItemFor(raceId)` (a `ScheduleItem`, no `.tr`) and `roundOf(raceId)`; the view builds the display label via the `ScheduleItemFormatting.label` extension it already imports.
- **Obx dependency:** `_Timeline`'s `Obx` reads `controller.selectedSiteId.value` in the builder body before `rowsFor` so a site switch rebuilds it; `_Palette` reads `selectedSiteId.value`/`selectedDay` in its builder body (the Plan B fix). The `ReorderableListView` needs a stable `ValueKey(block.id)` per row.
- **Manual blocks are omitted from the FFSS mapper** (no course equivalent) — a documented limitation, not a bug.
- **Device smoke test (Task 4 Step 4)** needs a human — the gear-with-sites-defined fix and the drag-reflow are only verifiable on a device.
- **Deferred, unchanged:** the network push (stubbed seam), the day-overview grid, per-item fixed clock times.
