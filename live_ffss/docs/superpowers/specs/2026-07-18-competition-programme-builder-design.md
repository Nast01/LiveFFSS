# Competition Programme Builder — Design

**Date:** 2026-07-18
**Status:** Approved (pending spec review)

## Goal

Let a competition organiser author a **timed programme** for a côtier
(coastal lifesaving) competition, entirely on-device and offline-capable:

1. **Define the round structure** of each épreuve × category — the selection
   rounds (série → quart → demi → finale), how many races per level, and how
   the rounds connect.
2. **See the structure** at a glance as a bracket per épreuve × category.
3. **Schedule** each individual race onto a site (Côtier 1, Sable 1…) at a
   time slot, per competition day.

Creation must stay **simple and fast**. The tool is an *authoring* surface —
unlike the rest of the app, which is a read-only viewer of FFSS data.

## Context and hard constraints

The codebase was mapped before this design (see the exploration on the
`feat/timed-programme-builder` branch). The findings that shape everything:

- **The app can read** a competition's épreuves (`Race`) with their
  categories, and its entries (`Entry`) per épreuve — so participant counts
  are available to drive round generation.
- **The app can write almost nothing to FFSS.** The *only* working mutation
  is meeting (réunion) create/delete (`MeetingRemoteDataSource`, real HTTP).
  Slots (créneaux), runs (courses) and parties have **no documented write
  endpoint**. Result/ranking mutations are `UnimplementedError` stubs.
- **No round/tour concept exists** in the domain today. `RaceFormatDetail`
  ("partie") is the closest — it carries `order`, `level`, `qualifyingSpots`,
  `spotsPerRace` — but it is read-only from the API.
- **côtier vs eau-plate is string-matched**, not typed: `SlotController`
  matches on `RaceFormatDetail.level` with an explicit `// TODO(batch-6):
  typed enum`.
- An existing `program` module does meeting CRUD but is **unreachable** (no
  navigation entry, `setCompetition` never called).

### Decisions taken during brainstorming

| Question | Decision |
|---|---|
| Where does the programme live? | **Local on device**, offline-first. |
| FFSS write endpoints for créneaux/courses/parties? | **Not yet, but planned.** Build offline-first now; push meetings today; stub the rest behind a typed seam, wire when documented. |
| Round-generation rules source? | **Operator provides + generic defaults.** The app does the arithmetic; no FFSS rulebook is encoded. |
| Schedulable unit? | **The individual race** (one série, one quart, the finale) — default 10 min, editable. |
| Athlete seeding / draw? | **Out of scope.** Structure + schedule only; races are empty containers. |
| Sites? | **Defined once per competition** (name + type côtier/sable), reused each day. |
| Data shape? | **Lean authoring model** stored locally; the FFSS tree (Meeting/Slot/Run/RaceFormatDetail) is materialised from it by a 1:1 mapper at sync time, so it stays saveable to FFSS. |

## Architecture

### Storage model = a lean authoring model

The on-device store is a small, purpose-built model — **not** the FFSS
classes. FFSS `Run`/`RaceFormatDetail` carry required fields (`Run.beginTime`,
`status`, labels…) meant for races already scheduled and fetched from FFSS;
authoring a race that has no time yet must not force sentinel values. So the
store is lean, and the FFSS tree is built from it only at sync time (next
section).

```
CompetitionProgramme                 ← local root, one per competition
├─ int competitionId
├─ int nextLocalId                   ← counter for local entity ids
├─ List<ProgrammeSite> sites         ← declared once; the site editor is Plan B
└─ List<EventStructure> structures

ProgrammeSite { int id; String name; SiteType type }

EventStructure                       ← rounds of one (épreuve × category)
├─ int raceId, int categoryId        ← FFSS ids, referenced
├─ String raceLabel, categoryLabel   ← denormalised for offline display
├─ int spotsPerRace                  ← race size (default 8); drives the arithmetic
└─ List<RoundLevel> levels           ← ordered: série → quart → demi → finale

RoundLevel
├─ RoundType type
├─ int qualifiersPerRace             ← 0 = unset; metadata, no computation in v1
└─ List<ProgrammeRace> races

ProgrammeRace
├─ int id                            ← local, from nextLocalId; stable
├─ int number                        ← série 1 → 1
├─ List<int> sourceRaceIds           ← opt1/opt2 wiring: ids of feeding races at level N-1
└─ RacePlacement? placement          ← null = unscheduled (Plan B fills this)

RacePlacement { int siteId; DateTime beginHour; int durationMinutes }
```

`endHour` is a computed getter (`beginHour + durationMinutes`) in a
presentation extension — never stored, so it cannot drift from the duration.

Two new enums, both with an `unknown` arm per the project convention:
`enum RoundType { serie, quart, demi, finale, unknown }` — the authoring round
stage, **ours**, not read from any FFSS field — and
`enum SiteType { cotier, sable, unknown }`.

All of these are **pure freezed domain models** with generated
`toJson`/`fromJson`. Local persistence writes the root's own JSON — no DTO
mapping on the storage path.

### FFSS is the sync target, built by a mapper

The FFSS tree is what the app **syncs to**, materialised from the lean model
when pushing — never stored:

| Lean model | → FFSS class at sync |
|---|---|
| a scheduled `ProgrammeRace` + its `RacePlacement` | `Run` (`site`, `beginTime`, `endTime`) |
| a `RoundLevel` (type + qualifiers/spots) | `RaceFormatDetail` (the "partie") |
| the day of a placement | `Meeting` (réunion) |
| a (day × round-level) group | `Slot` (créneau) |
| `EventStructure.raceId/categoryId` | `Race` / `Category` (referenced) |

The mapping is 1:1 by construction, so "saveable to FFSS" holds. The mapper,
and the id reconciliation it needs, live behind the sync seam (below) and are
**deferred** until FFSS documents the write endpoints — designing them
precisely against undocumented endpoints would be speculative. Plan A builds
the seam interface and its stub; not the mapper.

### Persistence and sync seam

- **`ProgrammeService`** (a `GetxService`, registered in `InitialBinding`
  like `UserPreferencesService`): loads/saves the `CompetitionProgramme` for a
  competition, exposes it reactively, allocates local ids from `nextLocalId`,
  and is the single source of truth on-device. Backing store:
  `flutter_secure_storage`, key `programme_<competitionId>`, the root's own
  JSON (zero new deps, matches favorites/user). Swap to a file via
  `path_provider` if a programme ever grows beyond a few tens of KB; the
  service interface does not change.
- **Sync** — `ProgrammeRepository → ProgrammeRemoteDataSource`, following the
  `ResultRepository` seam: meetings push through the existing
  `MeetingRepository`; slots/runs/parties push through
  `ProgrammeRemoteDataSource` methods that **throw `UnimplementedError`** until
  FFSS documents the endpoints. The local store is the source of truth until
  then; the feature is fully functional offline.

### Two projections over one store

The lean store is primary and authored first. Both user-facing trees are
projections of it:

- **The structure / bracket view** reads the store directly: `EventStructure →
  RoundLevel → ProgrammeRace`.
- **The schedule view and FFSS sync** take every `ProgrammeRace` with a
  `placement`, group by day and by (day × round-level), and (for sync)
  materialise the `Meeting → Slot → Run` tree. A race with `placement == null`
  is simply absent — it is the "unscheduled" set the scheduling palette draws
  from (Plan B).

### Module and entry point

- A **new `programme` feature module** (`lib/app/module/programme/`),
  distinct from the legacy unreachable `program` (meeting-CRUD) module — to
  keep local authoring separate from FFSS read-only viewing. The legacy
  module is left as-is; its `MeetingRepository.createMeeting` is reused by the
  sync layer.
- **Entry point:** from the competition detail screen (a "Programme" action),
  since the feature is competition-scoped.
- **Two-tab shell:** `Structure` and `Programme` (scheduling).

## Sub-project 1 — Structure definition (UI)

### Screen 2A — Structure overview

The global view **and** the navigation hub. Every épreuve × category of the
competition, with its structure summarised:

```
┌─────────────────────────────────────────────┐
│  ←  Programme · Championnat 2026              │
│     [ Structure ]   Programme                 │
├───────────────────────────────────────────────┤
│  ⚡ Générer une structure par défaut (tout)    │
│                                               │
│  ▸ 100m Nage côtière                          │
│     Cadets     20 engagés   3 séries → finale   ✎│
│     Juniors    14 engagés   2 séries → finale   ✎│
│     Seniors     6 engagés   finale directe      ✎│
│  ▸ Planche de sauvetage                       │
│     Cadets     —            non défini          ✎│
└───────────────────────────────────────────────┘
```

Each row: épreuve × category, **entry count** (read from FFSS entries, as
guidance), the structure as a compact chain (`3 séries → finale`), and state
(defined / not defined). **"Générer par défaut (tout)"** applies the default
rule to every épreuve × category at once; the operator adjusts exceptions.

### Screen 2B — Structure editor (one épreuve × category)

```
┌─────────────────────────────────────────────┐
│  ←  100m Nage côtière · Cadets                │
│     20 engagés · 8 places/course              │
├───────────────────────────────────────────────┤
│  ⚡ Proposer une structure     ▦ voir le bracket│
│                                               │
│  ┌ SÉRIES ──────────────────────────┐         │
│  │ 3 courses · 2 qualifiés/course    │   ✎     │
│  │ série 1  ·  série 2  ·  série 3   │         │
│  └───────────────────────────────────┘         │
│         ↓  toutes → toutes   (personnaliser)   │
│  ┌ FINALE ──────────────────────────┐         │
│  │ 1 course                          │   ✎     │
│  └───────────────────────────────────┘         │
│  +  Ajouter un niveau (quart · demi)          │
└───────────────────────────────────────────────┘
```

- **Levels stacked in order** série → quart → demi → finale. The operator
  enables the levels that exist and edits, inline, the race count and
  qualifiers per race.
- **Spots per race** (competition-level default, e.g. 8, editable here) →
  the app computes `séries = ceil(entries / spotsPerRace)`. That is the whole
  arithmetic. Maps to `RaceFormatDetail.spotsPerRace` / `qualifyingSpots`.
- **Wiring between two levels:** default `toutes → toutes` (opt2). The
  "personnaliser" link opens a per-target checkbox picker (opt1): for each
  quart, tick which séries feed it. Stored in the sidecar `raceSources`.
- **"Proposer une structure"** pre-fills from the entry count:
  `entries ≤ spotsPerRace → single finale`; else `séries → finale`. Generic,
  no FFSS rulebook. The operator starts there and adjusts.

Fast input lives in this form. The bracket (below) is for review.

### Bracket view — the visual overview

Per épreuve × category, reached via "voir le bracket". Levels as columns
(séries left → finale right), each race a node, the opt1/opt2 wiring drawn as
links. Horizontal-scroll on mobile. **Read-only** — a verification surface,
not an editor; editing happens in the 2B form.

```
opt2 (toutes → toutes):            opt1 (personnalisé):

 SÉRIES        FINALE               SÉRIES      QUARTS      FINALE
 ┌────┐                             ┌────┐     ┌────┐
 │ S1 │──┐                          │ S1 │────►│ Q1 │──┐
 └────┘  │                          └────┘ ┌──►└────┘  │
 ┌────┐  ├──►┌────────┐             ┌────┐─┘           ├──►┌──────┐
 │ S2 │──┤   │ FINALE │             │ S2 │             │   │FINALE│
 └────┘  │   └────────┘             └────┘─┐           │   └──────┘
 ┌────┐  │                          ┌────┐ └──►┌────┐  │
 │ S3 │──┘                          │ S3 │────►│ Q2 │──┘
 └────┘                             └────┘     └────┘
```

## Sub-project 2 — Scheduling (UI)

### Screen 3A — Sites (once per competition)

Behind the Programme tab's gear, a simple list editor:

```
┌─────────────────────────────────────┐
│  ←  Sites · Championnat 2026          │
├───────────────────────────────────────┤
│  Côtier 1        🌊 côtier      ✎  🗑 │
│  Côtier 2        🌊 côtier      ✎  🗑 │
│  Sable 1         🏖 sable       ✎  🗑 │
│  +  Ajouter un site                   │
└───────────────────────────────────────┘
```

### Screen 3B — The day's programme

Day selector (days derived from the competition's `beginDate`..`endDate`),
then a **vertical timeline per site** — the fastest input path on mobile:

```
┌─────────────────────────────────────────────┐
│  ←  Programme · Championnat 2026              │
│     Structure   [ Programme ]                 │
│  ◀  Sam 13 juin   Dim 14 juin  ▶     ⚙ sites  │
├───────────────────────────────────────────────┤
│  Site : [ Côtier 1 ▾ ]         vue journée ▦  │
│                                               │
│  09:00 ┌───────────────────────────────┐ ✎   │
│        │ 100m Côtière · Cadets · série 1│10min│
│  09:10 ├───────────────────────────────┤ ✎   │
│        │ 100m Côtière · Cadets · série 2│10min│
│  09:20 │ +  ajouter une course          │     │
│        └───────────────────────────────┘     │
├───────────────────────────────────────────────┤
│  Non planifiées (48)           rechercher 🔍  │
│  100m Côtière · Cadets · série 3              │
│  Planche · Juniors · série 1                  │
└───────────────────────────────────────────────┘
```

**Fast flow:** day + site → `ajouter une course` → the palette of
unscheduled races (grouped by épreuve, searchable) → pick one → it is
appended at the **next free 10-min slot** on that site. Repeat. Time and
duration are editable inline per block. **Tap-to-append**, not drag-drop —
more reliable on touch.

### Day overview — parallel sites

The `vue journée ▦` toggle switches to a grid with **sites as columns**
(horizontal scroll), to see the whole day at once — the scheduling analogue
of the bracket:

```
         Côtier 1        Côtier 2        Sable 1
 09:00   Côt.Cad.S1      Planche.Jun.S1  Sprint.Cad.C1
 09:10   Côt.Cad.S2      Planche.Jun.S2  Sprint.Cad.C2
 09:20   …               …               …
```

### Duration, conflicts, data

- **Duration:** default 10 min (competition-level, editable), overridable per
  race.
- **Conflicts:** appending to the next free slot avoids them by
  construction; a manual time edit that overlaps another race **on the same
  site** raises a warning.
- **Data:** placing a race = setting its `ProgrammeRace.placement` (`siteId`,
  `beginHour`, `durationMinutes`). At sync, races of the same round-level on
  the same day materialise as one `Slot` (créneau) inside the day's `Meeting`
  — grouping done by the sync mapper, invisible in the UI. Everything stays
  local, ready to push to FFSS when the endpoints land.

## Controller discipline

Per this project's rules (enforced by review): controllers hold no
`Get.snackbar` / `Get.dialog` / `.tr` / `Get.context!` / `BuildContext`
params; user feedback via `Rxn<UiMessage>`; constructor injection only; catch
`AppException`. Search fields' `TextEditingController`s live in the views
(`StatefulWidget`). The bracket, site editor, and course palette are view
concerns; the controllers expose state and mutations only.

## Testing

Per CLAUDE.md — logic layers only, mocktail, no widget tests:

- **Round arithmetic** (the pure default-generation and `ceil(entries /
  spotsPerRace)` logic): unit-tested directly.
- **`ProgrammeService`** (load/save round-trip, local-id allocation, wiring
  persistence): mock the storage, verify serialization and reactive state.
- **Controllers** (structure editor, scheduler): mock `ProgrammeService` /
  repositories, verify state transitions — add/remove level, compute counts,
  set wiring, place race at next free slot, overlap warning.
- No widget tests for the bracket / timeline; verify visually with
  `flutter run`.

## Implementation staging

Two implementation plans, each independently shippable and testable:

1. **Plan A — Structure:** the lean data model + `ProgrammeService` + sync
   seam, the `RoundType`/`SiteType` enums, the two-tab shell + entry point,
   the structure overview (2A), the structure editor (2B) with default
   generation and opt1/opt2 wiring, and the read-only bracket.
2. **Plan B — Scheduling:** the sites editor (3A), the per-day per-site
   timeline + unscheduled palette with tap-to-append (3B), the day overview
   grid, duration/override, overlap warnings, filling each
   `ProgrammeRace.placement`, and the FFSS `Meeting → Slot → Run` sync mapper.

## Out of scope

- **Athlete seeding / draw** — no assignment of engagés to séries, no
  qualifier computation. Races are empty containers. A later sub-project.
- **eau-plate épreuves** — structure generation is designed for côtier;
  eau-plate specifics are deferred. The model stays generic.
- **Full FFSS sync of slots/runs/parties** — stubbed behind the typed seam
  until FFSS documents the write endpoints; only meetings push today.
- **Sync conflict resolution / multi-device merge** — the local store is the
  single source of truth; no central sharing (matches the "local on device"
  decision).
- **Editing the structure directly on the bracket** — the bracket is
  read-only; editing is in the 2B form.
