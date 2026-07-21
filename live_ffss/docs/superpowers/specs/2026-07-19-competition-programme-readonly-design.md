# Read-Only Programme Tab (Competition Detail) — Design

**Date:** 2026-07-19
**Status:** Approved (pending spec review)

## Goal

Add a **read-only** "Programme" tab to the competition detail screen, so anyone
consulting a competition can see the timed schedule without opening the builder.

- The tab sits between "Événements" and "Clubs".
- If no programme is scheduled, it shows an empty-state message.
- Consultation only — no editing (no drag, no ±, no delete, no start editing).
- Tapping a scheduled **race** opens that épreuve's race detail — the exact
  screen and menus reached by tapping an item in "Événements" (Engagés /
  Séries / Résumé).
- Manual items (e.g. "Pause déjeuner") are shown but **not** tappable.

The programme builder (edit) screen and its data model are unchanged; this adds
a second, read-only consumer of the same `ProgrammeService` data.

## Decisions taken during brainstorming

| Question | Decision |
|---|---|
| Manual items in the read-only view | **Shown, not tappable.** They carry no épreuve; only race blocks navigate. |
| Visual direction | **A — Echo the editor (one site at a time).** Day chips + site chips + read-only accent-bar cards, identical to the builder's schedule view minus the edit controls. |
| Where the code lives | **Self-contained in the `competitions` module** — a new controller + view, reusing the pure planner functions. No coupling to the programme edit controllers. |

## The bridge — block → épreuve → race detail (verified feasible)

The race-detail screen (`Routes.raceDetail`) requires a domain `Race` (with a
real FFSS id) plus the `Competition`, passed as `{'race': Race, 'competition':
Competition}` — the same argument "Événements" passes. The programme only stores
`ProgrammeRace` (local ids) inside `EventStructure`s. Verified in
`programme_controller.dart:86-87`: structures are seeded from
`RaceRepository.getRaces(comp.id)` with `raceId: race.id` — so
**`EventStructure.raceId` is the domain `Race.id`.**

Resolution path for a tapped race block:
`ScheduleBlock.raceId` (a `ProgrammeRace.id`, local)
→ find the owning `EventStructure` (the one whose level contains that race)
→ `EventStructure.raceId` (the FFSS `Race.id`)
→ look it up in the races loaded via `RaceRepository.getRaces(comp.id)`
→ navigate to `Routes.raceDetail` with `{'race': Race, 'competition': Competition}`.

A block whose épreuve is not among the loaded races (or a manual block) is not
tappable.

## Architecture

### Component layout (Approach 1 — self-contained)

```
lib/app/module/competitions/
├─ controllers/competition_detail_programme_controller.dart   ← NEW
├─ views/competition_detail_programme_view.dart               ← NEW (4th IndexedStack child)
├─ bindings/competition_detail_binding.dart                   ← MODIFY (register the new controller)
└─ views/competition_detail_view.dart                         ← MODIFY (4th pill + 4th body)
```

Rejected alternatives: reusing the programme module's `ScheduleController`
(carries edit-only concerns — a `Worker` that mutates `selectedSiteId`, a
`setCompetition` wiring for the editor — and knows nothing about domain `Race`s,
so it would need the bridge bolted on anyway, coupling `competitions` to the
`programme` edit module); extracting a shared timeline widget (over-engineering
for a single read-only consumer — YAGNI).

### Pure-planner refactor (DRY)

Two pure helpers move into `lib/app/domain/models/schedule_planner.dart`, so both
the editor's `ScheduleController` and the new read-only controller share the
structure-tree walk instead of duplicating it:

- `ScheduleItem? raceItemFor(CompetitionProgramme p, int raceId)` — the label /
  round / number for a scheduled race block (returns null if the id isn't a race
  in any structure). `ScheduleController.scheduleItemFor` is refactored to
  delegate to this (behavior unchanged).
- `int? structureRaceIdFor(CompetitionProgramme p, int blockRaceId)` — the owning
  `EventStructure.raceId` (the FFSS `Race.id`) for a `ProgrammeRace` id, or null
  if not found. Used by the read-only controller's bridge.

`RoundType roundOf(...)` already exists on `ScheduleController`; the read-only
controller gets its own tiny equivalent or reuses `raceItemFor(...).roundType`.

### The controller

`CompetitionDetailProgrammeController(ProgrammeService, RaceRepository)`:

- Fields: `Rxn<Competition> competition`, `RxBool isLoading`, `RxBool hasError`,
  `RxList<DateTime> days`, `RxInt selectedDayIndex`, `Rxn<int> selectedSiteId`,
  and a private `Map<int, Race> _racesByFfssId`.
- `onInit`: reads the `Competition` from `Get.arguments`; sets
  `days = competitionDays(comp.beginDate, comp.endDate)`; then loads (guarded by
  `isLoading`/`hasError`, catching `AppException`):
  - `await _programme.load(comp.id)` — populates `ProgrammeService.current`.
  - `final races = await _raceRepo.getRaces(comp.id)` — indexed into
    `_racesByFfssId` by `Race.id`.
  - defaults `selectedSiteId` to the first site if any.
- Read getters (all pure, off `ProgrammeService.current.value`):
  - `List<ProgrammeSite> get sites`
  - `DateTime? get selectedDay` (clamped)
  - `List<ScheduleRow> rowsFor(int siteId, DateTime day)` → `scheduleRows(...)`
  - `int startMinutesFor(int siteId, DateTime day)` → `dayStartMinutes(...)`
  - `ScheduleItem? itemFor(int blockRaceId)` → `raceItemFor(current, blockRaceId)`
    (for a race card's label).
- The bridge (no navigation — navigation lives in the view):
  - `Race? raceForBlock(int blockRaceId)`: `final ffssId =
    structureRaceIdFor(current, blockRaceId); return ffssId == null ? null :
    _racesByFfssId[ffssId];`
- `bool get hasProgramme` — true when `current` has at least one `ScheduleBlock`.

Controller discipline respected: no `.tr`, no `Get.snackbar`/`Get.dialog`/
`Get.context!`/`BuildContext`; constructor injection; catches `AppException`.
Navigation (`Get.toNamed`) is done by the view, matching the existing
"Événements" pattern (`competition_detail_races_view.dart` calls `Get.toNamed`
inside the row `onTap`).

### The view

`CompetitionDetailProgrammeView` — a `GetView<CompetitionDetailProgrammeController>`
(no lifecycle worker is needed, unlike the editor's `ScheduleView`, because this
controller reads its `Competition` from `Get.arguments` itself), the 4th
`IndexedStack` child:

- While `isLoading`: `LoadingIndicator`. On `hasError`: `ErrorState` (existing
  shared widgets).
- If `days` is empty OR `!hasProgramme`: `EmptyState(icon: Icons.event_busy,
  title: 'no_programme'.tr)` — a new translation key.
- Otherwise, echoing the editor's schedule view minus edit affordances:
  - `_DayChips` — horizontal day pills (active `AppColors.statusWaiting`),
    reads `selectedDayIndex.value` in the `Obx` body.
  - `_SiteChips` — horizontal site pills (active `AppColors.primary`) plus a
    **display-only** "Départ HH:mm" chip (`AppColors.primarySurface` /
    `AppColors.primaryDark`); no start editor, no settings `IconButton`. Reads
    `selectedSiteId.value`/`selectedDay` in the `Obx` body (the Plan-B
    reactivity rule).
  - `_ReadonlyTimeline` — a `ListView` over `controller.rowsFor(siteId, day)`;
    empty ⇒ `EmptyState(icon: Icons.schedule, title: 'no_placement_here'.tr)`.
    Each row is a `_ReadonlyCard`.
  - `_ReadonlyCard` — echoes the editor's accent-bar card: a 5px left accent
    (manual ⇒ `statusWaiting`, finale ⇒ `statusFinished`, else `primary`),
    the `begin` time (bold, `primaryDark`), `→ end · duration min`, and the
    label. For a race block: a trailing `Icons.chevron_right` and an `onTap`:

    ```dart
    final race = controller.raceForBlock(block.raceId!);
    if (race != null) {
      Get.toNamed<void>(Routes.raceDetail, arguments: {
        'race': race,
        'competition': controller.competition.value,
      });
    }
    ```
    For a manual block: no chevron, no `onTap`.

The card label comes from `controller.itemFor(block.raceId!)?.label` via the
`ScheduleItemFormatting.label` extension the view imports (keeping `.tr` out of
the controller).

### Reactivity

`ProgrammeService.current` is an `Rxn`, so the timeline is Obx-reactive; the
read-only tab never mutates it. Reads of `selectedSiteId`/`selectedDay` happen in
the `Obx`/builder body (never only inside an itemBuilder) — the same rule that
bit the editor twice.

## Error / empty handling

- No competition dates → `days` empty → empty state.
- No blocks scheduled → empty state (`no_programme`).
- Blocks exist but the selected site×day has none → per-timeline
  `no_placement_here` empty state.
- `getRaces` fails → `hasError` → `ErrorState`; the programme still renders but
  taps that can't resolve a `Race` are inert (no crash).
- A race block whose épreuve isn't in `_racesByFfssId` → inert (no chevron
  action); does not throw.

## Testing (per CLAUDE.md — logic layers, mocktail, no widget tests)

- **`schedule_planner`**: `raceItemFor` returns the right label/round/number and
  null for a non-race id; `structureRaceIdFor` returns the owning
  `EventStructure.raceId` and null when not found.
- **`CompetitionDetailProgrammeController`** (mock `ProgrammeService` via mocked
  storage + mock `RaceRepository`): `days` derived from the competition dates;
  `sites`/`rowsFor` restitute the derived sequence; `hasProgramme` true only with
  blocks; `raceForBlock` returns the correct `Race` (matched via
  `structureRaceIdFor` → `_racesByFfssId`), and null for a manual block or an
  unmatched épreuve; `isLoading`/`hasError` transitions on success/failure.
- **`ScheduleController.scheduleItemFor`**: unchanged behavior after delegating
  to `raceItemFor` (existing tests keep passing).
- No widget tests for the tab / navigation — verify on device.

## Out of scope

- Editing from this tab (consultation only).
- FFSS representation of manual blocks (still omitted from the sync mapper).
- The network push (still the stubbed `UnimplementedError` seam).
- All-sites "day agenda" layout (Direction B, rejected in favor of A).
- Cross-linking a scheduled round to a specific heat inside race detail — tapping
  opens the épreuve; the round context is already visible via the Séries tab.
