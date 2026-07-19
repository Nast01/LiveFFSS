# Programme Scheduling Redesign — Design

**Date:** 2026-07-19
**Status:** Approved (pending spec review)

## Goal

Rework the programme scheduling view (Plan B) into a more interactive, modern
screen, and add two capabilities the current view lacks:

1. **Move / reorder** a placed item, with all following times recalculated.
2. **Add a manual free-text item** (e.g. "Pause déjeuner", "Cérémonie") into
   the same timeline.

It also fixes a bug: the settings (gear) button does nothing once sites are
defined.

This supersedes Plan B's scheduling layer (the `RacePlacement`-on-`ProgrammeRace`
model). The rest of the programme builder (Plan A structure, `ProgrammeService`,
sites data, the sync seam) is unchanged.

## Decisions taken during brainstorming

| Question | Decision |
|---|---|
| How do times behave when an item moves? | **Sequence reflow.** Each (site × day) is an ordered list; begin times derive from a start time + each item's duration, back-to-back. Reorder / duration change / inserting a manual item reflows all following times. |
| Fixed clock times (e.g. lunch at 12:00)? | **Pure reflow + editable start.** Each (site × day) has one editable start time (default 09:00). Everything flows from there; a manual "Pause" block's real time is derived. No per-item time pinning. |
| Move interaction | **Drag-to-reorder** (a drag handle per card). |
| Visual direction | **Accent-bar agenda cards** (Direction B): full-width cards with a coloured left bar by kind (race / finale / manual), the time in the card, day + site as chips. |

## Architecture

### Data model — a block sequence replaces per-race placement

Scheduling stops being an absolute time stored on each race and becomes an
ordered list of blocks. A block is **either** a race **or** a manual item —
one list, one order space.

```
CompetitionProgramme                       ← Plan A fields unchanged
├─ int competitionId
├─ int nextLocalId
├─ List<ProgrammeSite> sites
├─ List<EventStructure> structures         ← ProgrammeRace no longer has `placement`
├─ List<ScheduleBlock> blocks              ← NEW: the schedule
└─ List<SiteDayStart> dayStarts            ← NEW: per (site × day) start time

ScheduleBlock
├─ int id                    ← local, from nextLocalId
├─ int siteId
├─ DateTime day              ← midnight of the competition day
├─ int order                 ← position within (siteId, day); 0-based, contiguous
├─ int durationMinutes       ← default 10
├─ int? raceId               ← non-null → this block schedules a race
└─ String manualLabel        ← non-empty → a manual item; ignored when raceId is set

SiteDayStart
├─ int siteId
├─ DateTime day
└─ int startMinutes          ← minutes past midnight; absent ⇒ default 09:00 (540)
```

Changes to Plan A/B models:
- **`ProgrammeRace.placement` and the `RacePlacement` type are removed.** A race
  is "scheduled" iff a block references its id. The unscheduled palette lists
  races in `structures` that no block references.
- The Plan B `ScheduleItem` view model (used for the unscheduled palette) loses
  its `placement` field — it now carries only `{raceId, raceLabel,
  categoryLabel, roundType, number}`. Placed rows use the new `ScheduleRow`.
- Nothing is in production yet (the feature has never shipped), so this is a
  clean model migration, not a data migration.

### Derived times — a pure function

`scheduleRows(programme, siteId, day)` returns the ordered blocks of that
(site × day) with their computed times:

- start = `SiteDayStart` for (siteId, day), else 09:00
- blocks sorted by `order`
- each block begins at the running cursor, ends at `begin + durationMinutes`,
  cursor advances to the end

A `ScheduleRow` view model carries `{ block, begin, end, displayLabel }`.
`displayLabel` is the race label (from its `EventStructure` + round + number)
for a race block, or `manualLabel` for a manual block — built in a presentation
extension (translation happens in the view).

### Rewritten scheduling layer

The Plan B `schedule_planner` (which was built around `RacePlacement`,
`nextFreeStart`, `overlaps`, `setPlacement`) is replaced by a block-oriented
`schedule_planner`:

- `int dayStartMinutes(programme, siteId, day)` (with the 09:00 default)
- `List<ScheduleRow> scheduleRows(programme, siteId, day)` (the derived sequence)
- `List<ScheduleItem> unscheduledRaces(programme)` (races referenced by no block)
- immutable mutators returning a new `CompetitionProgramme`:
  - `addRaceBlock`, `addManualBlock` (append at the end of the (site,day)
    sequence with the next `order`)
  - `reorderBlocks(siteId, day, oldIndex, newIndex)` (renumber `order`
    contiguously)
  - `setBlockDuration`, `setManualLabel`
  - `removeBlock` (renumber the remaining blocks of that site×day)
  - `setDayStart`
  - `clearBlocksForSite` (used by site deletion, replacing
    `clearPlacementsForSite`)

Overlaps can no longer occur (back-to-back by construction), so the overlap
guard and its `UiMessageError('schedule_overlap')` disappear.

`ScheduleController` is rewritten around these: it keeps `competition`, `days`,
`selectedDayIndex`, `selectedSiteId`, and the `ever(_programme.current)` worker
(disposed in `onClose`), and exposes `rowsFor(siteId, day)`, `unscheduledRaces`,
`addRace`, `addManual`, `reorder`, `setDuration`, `setManualLabel`,
`removeBlock`, `setDayStart` — each mutating via `ProgrammeService.save`.

### The FFSS sync mapper

`programmeToMeetings` is updated to read blocks instead of `RacePlacement`:
race blocks → `Run`s (times derived by `scheduleRows`), grouped into
`Slot`/`Meeting` as before. **Manual blocks have no FFSS course equivalent**, so
they are omitted from the mapper output (they stay a local-only planning aid);
this is noted as a known limitation until FFSS defines how to represent them.
The network push stays the stubbed `UnimplementedError` seam.

## The view (Direction B)

A `StatefulWidget` replacing the current `ScheduleView`, keeping the
initState/dispose worker pattern (feed `ProgrammeController.competition` into
`ScheduleController.setCompetition`; dispose the worker).

Layout, top to bottom:

- **Header row:** the competition/site title on `AppColors.primary`, and a
  **gear action that reliably opens `SitesView`** (`Get.to(() => const
  SitesView())`) — a plain `IconButton` in the header, no longer wedged beside a
  `DropdownButton` (the layout that broke it).
- **Day chips:** horizontal, `selectedDayIndex` drives them (reads the reactive
  value in the `Obx` builder body — the Plan B reactivity fix pattern).
- **Site chips:** horizontal, replacing the `DropdownButton`. Selecting a chip
  sets `selectedSiteId`. To the right, an **editable start chip** ("09:00 ▾") →
  a time picker → `setDayStart`.
- **The timeline:** a `ReorderableListView` of **accent-bar cards** for the
  selected (site × day):
  - a coloured left bar — blue for a race (or green for a finale round), orange
    for a manual item
  - a drag handle (`ReorderableDragStartListener`) — drag reorders and reflows
    (`reorder`)
  - the derived begin time (bold), the label, `→ endTime`, and the duration with
    − / + steppers (`setDuration`, ±5, min 5)
  - a manual card also lets you tap the label to edit it (`setManualLabel`) and
    shows a distinct style
  - a trailing action removes the block (`removeBlock`): a race returns to the
    palette, a manual item is deleted
  - empty state when the site×day has no blocks
- **FAB "+ item":** opens a dialog (free-text label + duration) → `addManual`
  appends a manual block to the current (site × day).
- **Unscheduled palette (bottom):** a bounded section listing races no block
  references; each has an "Ajouter ›" that calls `addRace(raceId, siteId, day)`
  (append). Its `Obx` reads `selectedSiteId.value`/`selectedDay` in the builder
  body so switching site/day rebuilds it (the Plan B fix).

Colours use the existing `AppColors` (`primary`, `statusFinished` green,
`statusWaiting` orange). No new theme tokens.

## Controller discipline

Unchanged rules: no `Get.snackbar` / `Get.dialog` / `.tr` / `Get.context!` /
`BuildContext` in the controller; feedback via `Rxn<UiMessage>` (still used for
any error path, though overlap is gone); constructor injection; the view owns
dialogs, the reorder gestures, the time picker, and `TextEditingController`s.
`Get.find` in the view State is allowed.

## The gear bug

Root cause is not provable from the code (it reads as correct); it is a runtime
/ layout interaction, like the Plan B reactivity bug. The redesign removes the
`Expanded(DropdownButton) + IconButton` header entirely — sites become chips and
the gear moves to the header as a standalone action — so the bug is designed
out. Implementation verifies on a device (or a widget test driving the tap) that
the gear opens `SitesView` with sites defined.

## Testing

Per CLAUDE.md — logic layers only, mocktail, no widget tests:

- **`schedule_planner`** (pure): `dayStartMinutes` default and override;
  `scheduleRows` derives back-to-back times and reflows after a duration change;
  `unscheduledRaces` excludes referenced races; `reorderBlocks` renumbers
  contiguously and reflows; `removeBlock` renumbers; `addManualBlock`/
  `addRaceBlock` append with the next order; `clearBlocksForSite`.
- **`ScheduleController`**: add race → appears at the site×day sequence tail with
  derived time; add manual → block with the label; reorder → times recompute;
  setDuration reflows following times; removeBlock (race → back to unscheduled,
  manual → gone); setDayStart shifts all derived times; persistence writes.
- **`programmeToMeetings`**: race blocks map to runs with derived times; manual
  blocks are omitted; grouping/spanning unchanged from Plan B (keep those tests,
  adapted to blocks).
- No widget tests for the timeline / drag / dialog — verify on device.

## Out of scope

- **Per-item fixed clock times / anchoring** — pure reflow only (decided).
- **FFSS representation of manual blocks** — omitted from the mapper; revisit
  when the FFSS write endpoints and their handling of non-course items are known.
- **The network push** — remains the stubbed seam.
- **Day-overview grid (sites as columns)** — already a documented Plan B
  deferral; not revived here.
- **Cross-site move** (dragging a race from one site's timeline to another) —
  out; use remove + re-add on the target site.
