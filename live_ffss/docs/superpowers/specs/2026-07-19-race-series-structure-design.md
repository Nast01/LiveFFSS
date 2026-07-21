# Race "Séries" Tab — Structure View + Per-Course Seam — Design

**Date:** 2026-07-19
**Status:** Approved (pending spec review)

## Goal

In the race detail "Séries" tab, replace the current live-heats display with the
**locally-defined structure** (the rounds série/quart/demi/finale and their
courses that the operator built in the programme builder), shown as interactive
tiles. Tapping a course opens a **dedicated per-course screen** — a scaffold that
future work will fill with result viewing/entry (mechanism deliberately deferred).

This is "Option A" from brainstorming: the structure IS the Séries tab; the
live-heats/lane content becomes the detail of a course (surfaced later, not in
this iteration).

## Decisions taken during brainstorming

| Question | Decision |
|---|---|
| Structure vs. live heats in the Séries tab | **Structure-first (Option A).** The tab shows the defined structure; the live-heats lane content becomes the per-course detail, surfaced in a later iteration. |
| What a course tap does now | **Dedicated per-course screen (new route).** A scaffold with a context header + a "Résultats à venir" empty state — the seam for future result view/entry. |
| Multiple categories per race | **Stacked sections per category.** One section per category (header when >1; none when a single category), each holding its rounds → courses. |

## Context (verified)

- The Séries tab today (`race_detail_heats_view.dart`) renders FFSS `Heat`s from
  `RaceRepository.getHeats(race.id)`, polled every 10s, as heat cards with
  `Result` lanes. Display-only, no round/structure awareness, no tap.
- The structure lives in `ProgrammeService` (secure storage
  `programme_<competitionId>`) as `EventStructure`s inside `CompetitionProgramme`,
  keyed by the composite `(raceId = FFSS Race.id, categoryId = Category.id)`. Each
  holds `RoundLevel`s (`serie/quart/demi/finale`), each holding `ProgrammeRace`s.
- **One FFSS `Race` → many `EventStructure`s** (one per `race.categories` entry) —
  confirmed in `programme_controller.dart:80-93`, deduped on `(raceId, categoryId)`.
- `RaceDetailController` already reads `Get.arguments` as `{'race': Race,
  'competition': Competition}` (or a bare `Race`). A second controller can parse
  the same arguments independently, as the competition-detail tab controllers do.

## Architecture

### Component layout

```
lib/app/module/competitions/
├─ controllers/race_structure_controller.dart      ← NEW (Séries tab logic)
├─ views/race_structure_view.dart                  ← NEW (Séries tab body)
├─ controllers/race_course_controller.dart         ← NEW (per-course scaffold)
├─ views/race_course_view.dart                     ← NEW (per-course scaffold)
├─ bindings/race_detail_binding.dart               ← MODIFY (register RaceStructureController)
├─ bindings/race_course_binding.dart               ← NEW (per-course route binding)
└─ views/race_detail_view.dart                     ← MODIFY (Séries child → RaceStructureView)
lib/app/routes/
├─ app_routes.dart                                 ← MODIFY (add Routes.raceCourse)
└─ app_pages.dart                                  ← MODIFY (register the raceCourse page)
```

`RaceDetailController` is **not modified**. Its heats loading/polling stays as-is
(it may feed the Résumé tab); the Séries tab simply renders structure instead of
heats. If the poll is later confirmed unused, relocating it to the per-course
screen is an out-of-scope follow-up. The existing `race_detail_heats_view.dart`
and its lane-rendering widgets are **retained** (unwired from the tab) as the
basis for the future per-course results view — not deleted.

### RaceStructureController

`RaceStructureController(ProgrammeService, RaceRepository)`:

- Fields: `Rxn<Race> race`, `Rxn<Competition> competition`, `RxBool isLoading`,
  `RxList<EventStructure> structures`, and a private
  `Map<int, int> _entryCountByCategory`.
- `onInit`: parses `Get.arguments` (the `{race, competition}` map or bare `Race`)
  exactly like `RaceDetailController`; if both a race AND a competition are
  present, calls `load()`. The `Race` model has no competition id, so a bare-race
  argument (no competition) cannot load the programme → the empty state renders.
- `load()` (guarded by `isLoading`, catching `AppException`):
  - `await _programme.load(competition.id)`.
  - `structures.value = _programme.current.value.structures
      .where((s) => s.raceId == race.id).toList()
      ..sort((a, b) => a.categoryLabel.compareTo(b.categoryLabel))`.
  - `final entries = await _raceRepo.getEntries(race.id)` (in a `try` catching
    `AppException` → leave counts empty on failure); build
    `_entryCountByCategory = { for each category: count of entries in it }`
    (grouped by `entry.category.id`).
- Getters:
  - `bool get hasStructure => structures.any((s) => s.levels.isNotEmpty)`.
  - `int entryCountFor(int categoryId) => _entryCountByCategory[categoryId] ?? 0`.
  - `bool get showCategoryHeaders => structures.length > 1`.

Controller discipline: no `.tr`/`Get.snackbar`/`Get.dialog`/`Get.context!`/
`BuildContext`; constructor injection; the only `Get.*` in the body is
`Get.arguments` in `onInit`. Navigation lives in the view.

### RaceStructureView (the Séries tab body)

A `GetView<RaceStructureController>` — the new index-1 child of the race-detail
`IndexedStack`:

- `isLoading` → `LoadingIndicator`.
- `!hasStructure` → `EmptyState(icon: Icons.account_tree_outlined, title:
  'no_structure_defined'.tr)` — a new key. (A missing/undefined programme is not
  an error; it is simply an absent structure, so there is no blocking error
  state — the programme loads from local storage and never throws, and a
  `getEntries` failure degrades to zero counts.)
- Otherwise, a `ListView` of category sections:
  - **Category header** (only when `showCategoryHeaders`): the `categoryLabel` +
    `'engaged'` count via `entryCountFor(categoryId)` (e.g. "Cadets · 15 engagés").
  - Per `EventStructure`, one group per `RoundLevel`:
    - **Round header**: an accent bar (série/quart/demi = `AppColors.primary`,
      finale = `AppColors.statusFinished`), the round label
      (`level.type.labelKey.tr` via `RoundTypeFormatting`), and round info —
      `spotsPerRace` ("N places/course", `spots_per_race`) and
      `qualifiersPerRace` ("N qualifiés/course", `qualifiers_per_race`) when
      `qualifiersPerRace > 0`.
    - **Course tiles**: one per `ProgrammeRace`, showing a number badge and the
      course label (round label + `race.number`, e.g. "Série 1"), a
      `chevron_right`, and an `onTap`:

      ```dart
      Get.toNamed<void>(Routes.raceCourse, arguments: {
        'race': controller.race.value,
        'competition': controller.competition.value,
        'categoryId': structure.categoryId,
        'categoryLabel': structure.categoryLabel,
        'roundType': level.type,
        'raceNumber': programmeRace.number,
        'programmeRaceId': programmeRace.id,
      });
      ```

Reactivity: the `Obx` reads `structures`/`isLoading` in the builder body; the
per-tile navigation reads the values it needs at tap time (not a reactive
concern). No itemBuilder-only reactive reads.

### The per-course scaffold (the seam)

- **Route:** `Routes.raceCourse = '/race-course'`, registered in `app_pages.dart`
  with `RaceCourseBinding`.
- **`RaceCourseController`** (no repository — pure context holder for now): parses
  `Get.arguments` into `race`, `competition`, `categoryId`, `categoryLabel`,
  `roundType` (a `RoundType`), `raceNumber`, `programmeRaceId`. Exposes a computed
  `String get roundLabelKey => roundType.labelKey` (the view translates).
- **`RaceCourseView`**: an app bar / header showing the épreuve name, the category,
  and the round + number (e.g. "100m Nage · Cadets · Série 1"), and a body =
  `EmptyState(icon: Icons.timer_outlined, title: 'results_coming_soon'.tr)`. No
  result logic — this is the scaffold future work fills.
- **`RaceCourseBinding`**: `Get.lazyPut<RaceCourseController>(() =>
  RaceCourseController())`.

### Data / information shown

Only data that genuinely exists:
- Round chain and per-round `spotsPerRace` / `qualifiersPerRace` (from
  `EventStructure`/`RoundLevel`).
- Course number/label (from `ProgrammeRace.number` + round label).
- Total engaged **per category** (from `getEntries`, grouped by category id).

Explicitly NOT shown: per-course ("per-série") engaged counts — the model does
not assign athletes to individual series, so any per-série count would be
fabricated.

## Error / empty handling

- No competition in the arguments, or programme not defined → empty state
  (structure absent). No blocking error state.
- `getEntries` fails (`AppException`) → structure still renders; category counts
  show 0 (degrade gracefully, mirroring the read-only programme tab).
- Race with no `EventStructure` (never built in the programme) → the
  `no_structure_defined` empty state.

## Testing (per CLAUDE.md — logic layers, mocktail, no widget tests)

- **`RaceStructureController`** (mock `ProgrammeService` via mocked storage + mock
  `RaceRepository`): filters `structures` to the race's `raceId`; sorts/groups by
  category; `showCategoryHeaders` true only with >1 structure; `entryCountFor`
  counts entries by category; `hasStructure` false when no levels; a `getEntries`
  failure degrades to zero counts while the structure still loads.
- **`RaceCourseController`**: parses every context field from `Get.arguments`
  correctly (race, competition, categoryId, categoryLabel, roundType, raceNumber,
  programmeRaceId); `roundLabelKey` maps the round type.
- No widget tests for the views / navigation — verify on device.

## Out of scope

- Real result viewing/entry and the heat↔course binding (deferred — "on définira
  plus tard comment faire").
- Touching `RaceDetailController`'s heats loading/polling.
- Relocating or deleting the existing `race_detail_heats_view.dart` (retained for
  reuse by the future per-course results view).
- The network push (still the stubbed seam).
- Per-série engaged counts / athlete-to-series assignment.
