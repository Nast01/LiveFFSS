# Coastal heat draw — structure validation

Date: 2026-08-17
Status: implemented and merged into `generate_heats`. See Amendments at the end
— the Design section below was corrected after implementation, and one design
question is left open there.

## Problem

Drawing the heats of a coastal race silently rewrites the structure the
operator authored.

`drawHeats` derives the heat count from the athletes present:
`ceil(present / spotsPerRace)`. The authored structure is never consulted. When
a category declares three séries of 16 and only 20 athletes check in, the draw
produces two heats, and `HeatDrawController.save` rebuilds the round to match —
dropping the third race along with the `sourceRaceIds` that wired it into the
next round. Nothing on screen says a race was removed.

Three things are missing:

1. the draw ignores the number of races the structure declares;
2. nothing asks the operator to validate the structure before the draw;
3. no structure is ever proposed from the number of athletes actually present.

What already works and is deliberately left alone: only athletes marked
`AttendanceStatus.present` are eligible (`HeatDrawController.load`), and the
draw is random with clubmates spread across heats and heat sizes balanced
within one of each other (`drawHeats`, `_clubGroups`, `_bestHeatFor`).

## Scope

Coastal races only — the gate is `Race.isBeach` — and only when the round being
drawn is `RoundType.serie`. A pool race, or a draw on a quart/demi/finale,
keeps today's behaviour exactly.

The trigger is the draw action inside `HeatDrawView`. The "Générer les séries"
button of the Séries tab only navigates and is not touched.

The validation dialog opens even when the declared structure and the proposal
agree. This is a validation step, not a warning: when the numbers match it is a
single tap on Confirmer.

## Design

### The draw no longer decides the heat count

```dart
List<List<Athlete>> drawHeats({
  required List<Athlete> present,
  required int raceCount,     // was: spotsPerRace
  required Random random,
})
```

The caller passes a validated heat count; the function only distributes. The
club spreading and size balancing are unchanged. `raceCount <= 0` yields no
heat, which is the empty-field case.

Moving the `ceil` out of `drawHeats` is what makes the structure authoritative:
there is no longer a place where the heat count can be recomputed behind the
operator's back.

### Proposing a plan — `lib/app/domain/models/heat_plan.dart`

```dart
typedef HeatPlan = ({int raceCount, int spotsPerRace});

HeatPlan proposeHeatPlan({
  required int presentCount,
  required int maxSpotsPerRace,
});
```

Both numbers move:

- `raceCount = ceil(presentCount / maxSpotsPerRace)` — the fewest heats that
  keep every heat within the water's capacity. Lane count is a physical
  constraint of the course, so it is a ceiling, never a target.
- `spotsPerRace = ceil(presentCount / raceCount)` — tightened onto what the
  draw will actually produce.

| Declared | Present | Proposed | Draw |
|---|---|---|---|
| 3 × 16 | 20 | 2 × 10 | 10 + 10 |
| 3 × 16 | 28 | 2 × 14 | 14 + 14 |
| 3 × 8 | 17 | 3 × 6 | 6 + 6 + 5 |

Showing `2 × 10` rather than `2 × 16` matters: the operator is validating a
structure, and a structure that claims 16 spots describes a draw that will not
happen.

Edge cases: `presentCount <= 0` returns `(raceCount: 0, spotsPerRace: 0)`; a
`maxSpotsPerRace <= 0` (an unauthored round) returns
`(raceCount: 1, spotsPerRace: presentCount)` — one heat holding everyone, which
is the fallback `drawHeats` applies today.

### Controller

`HeatDrawController` gains:

- `bool get requiresStructureValidation` — `race.isBeach` and the selected
  level is `RoundType.serie`.
- `HeatPlan get declaredPlan` — `(level.races.length, spotsForLevel(level))`.
- `HeatPlan get proposedPlan` — `proposeHeatPlan` from `presentCount` and
  `declaredPlan.spotsPerRace`.
- `Rxn<HeatPlan> pendingPlan` — the plan the draw on screen was made with; null
  until a draw has run.
- `void drawWithPlan(HeatPlan plan)` — stores `pendingPlan` and draws
  `plan.raceCount` heats.

`drawFromPresent` stays for the paths that need no validation, and delegates to
`drawWithPlan` with the proposal, unconditionally. That is today's behaviour to
the letter: `proposeHeatPlan`'s `raceCount` is the same `ceil(present / spots)`
`drawHeats` used to compute for itself, fallback included.

The dialog itself lives in the view. Controllers hold no `Get.dialog` — the
view reads both plans, presents the choice, and calls back into
`drawWithPlan`.

### Persisting: on save, not on validation

Validating a plan writes nothing. `save()` — which already rebuilds the round's
races — is the single write, and changes in two ways:

- the race count comes from the drawn heats, which now equal
  `pendingPlan.raceCount`; existing races are still reused in order so the
  wiring of the ones that survive is preserved;
- `RoundLevel.spotsPerRace` is set to `pendingPlan.spotsPerRace`, **only on the
  validated path**. A pool race or a bracket round leaves the authored race size
  exactly as it found it: those paths get no dialog, so writing there would be
  the silent structure rewrite this whole design exists to remove.

Cancelling the dialog, redrawing, or leaving the screen leaves the stored
programme untouched.

### Dangling wiring

Shrinking three séries to two deletes the third race while the finale that
listed it in `sourceRaceIds` keeps pointing at an id that no longer exists.
This already happens today, silently.

`save()` will strip ids that no longer resolve to a race from the
`sourceRaceIds` of every later round of the same structure. Validating a
structure change while leaving the wiring corrupt would make the confirmation
worse than useless — it would ratify the corruption.

### Manual modification

The dialog offers "Modifier la structure", which opens `Routes.structureEditor`
with a `StructureEditorArgs` built from the controller: competition id, race id,
category id and labels, `entryCount: engagedCount`, the race gender and its
`defaultSpotsPerRace`.

`serverDetails` is passed empty. The editor uses it only to seed a structure
that has no rounds and to offer re-importing from FFSS; here the structure
exists by construction, so seeding cannot fire, and re-import is simply not
offered from this entry point. Fetching the FFSS `parties` again just to enable
that button is not worth a network call on the beach.

The editor commits straight into `ProgrammeService`. On return the controller
reloads, both plans recompute, and the dialog reopens with fresh numbers.

## Testing

- `heat_plan`: no athlete, exact multiple, remainder, single athlete,
  non-positive capacity.
- `heat_draw`: the existing suite moves from `spotsPerRace` to `raceCount`; the
  `ceil` assertions move to the `heat_plan` tests. Balancing, club spreading and
  seed reproducibility are unchanged and must stay green.
- `HeatDrawController`: the gate (coastal vs pool, série vs finale), both plans,
  `drawWithPlan` producing exactly `raceCount` heats, `save()` writing
  `spotsPerRace` on the validated path and leaving it alone on a pool draw,
  preserving the wiring of reused races, and stripping dangling `sourceRaceIds`
  downstream.

No widget test for the dialog, per the project's testing rules.

## Deliberately not done

- Proposing a change to the rounds *after* the séries (a finale that no longer
  matches the qualifier count). Out of scope; the operator opens the editor.
- Any FFSS write. Heats stay device-local — the API has no write endpoint for
  them.
- Applying the validation to pool races.

## Amendments (2026-08-18, after implementation)

Two passages of the Design section above have been corrected. Both said the
same wrong thing in different words, and both contradicted this document's own
Scope section — "A pool race, or a draw on a quart/demi/finale, keeps today's
behaviour exactly". Scope is what the shipped code implements; Design was
written assuming a single path and never took the carve-out into account.

- **`drawFromPresent`** was specified to prefer the declared plan when the round
  declares races. Two pre-existing tests encoded the old derivation and went red
  when that was implemented; the escalation was upheld in Scope's favour.
- **The `spotsPerRace` write** was specified as unconditional. That let the pool
  and bracket paths — the ones with no dialog — rewrite the round's authored
  race size in silence, which is the defect this design removes. The final
  review classed it merge-blocking.

Read Scope first when the two sections disagree.

**Known consequence, unresolved.** On the validated path, writing the approved
`spotsPerRace` back onto the round makes it that round's capacity, and the value
only ever moves down: a round tightened to 10 proposes from 10 next time, so a
redraw after late arrivals runs more, smaller heats rather than returning to 16.
It is safe by direction — never over the water's capacity — and the operator can
reset it in the structure editor. The reviewer argued for persisting only the
race count and leaving `spotsPerRace` as the untouched capacity, which the
Proposal section itself calls "a ceiling, never a target". That call has not
been made.
