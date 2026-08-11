# Reorder Rounds in the Structure Editor — Design

**Date:** 2026-08-11
**Status:** Approved (pending spec review)
**Branch:** `generate_heats`

## Goal

In the structure detail view (`StructureEditorView`), each round card gets **up
/ down arrows** that move the round in the list, changing the real order of
`EventStructure.levels`. Moves that would break the round hierarchy are
refused by disabling the arrow.

The hierarchy is **série < quart < demi < finale**. A level may be skipped
(`série, demi, finale` / `quart, finale` / `série, finale` are all valid), but a
higher round may never precede a lower one (`demi` before `série` is invalid).

## Decisions taken during brainstorming

| Question | Decision |
|---|---|
| Illegal move | **Arrow disabled.** No error snackbar, no new error copy to translate — the greyed arrow states the rule. |
| Wiring after a move | **Re-wire automatically**, opt2 style, but **only the levels whose predecessor changed**. Drawn athletes (`athleteIds`) are never touched. |
| Interaction | **Up / down arrows** in the card header, next to the delete button. No drag & drop: the cards already hold `+`/`-` steppers that fight the drag gesture. |
| `addLevel` | **Insert at the right rank** instead of appending, so a disordered list can no longer be created by adding rounds. |
| `RoundType.unknown` | **Never blocks a move.** Its rank is unknown, so refusing a move around it would be a guess. |
| Server sync | **Local only.** The FFSS API exposes `submitRaceFormat` and `deleteRaceFormatDetail` — no update of a `partie`'s `ordre`. Like the rest of the editor, the move lives in `ProgrammeService`. |

## Context (verified)

- `StructureEditorView` lists `s.levels[i]` into `_LevelCard(index: i, ...)`;
  the header row holds the round label, a `Spacer`, and the delete `IconButton`.
- `StructureEditorController.addLevel` appends to the end of `levels`
  regardless of type — this is how an invalid order gets created today.
- `RoundLevel.type` is a `RoundType { serie, quart, demi, finale, unknown }`
  (`lib/app/domain/models/round_level.dart`).
- `ProgrammeRace.sourceRaceIds` holds the ids of the feeding races at the
  previous level (empty at the first level). `buildDefaultLevels` and
  `buildLevelsFromDetails` wire it opt2: every race of level *n* is fed by
  **all** races of level *n-1*. `StructureEditorController.setWiring` lets the
  operator override it per race (opt1).
- `buildLevelsFromDetails` orders rounds by the server's `ordre` field — a value
  we do not control, so an imported structure can arrive out of hierarchy order.
- Structures already persisted in secure storage on operator devices can hold
  any order, since nothing has enforced one so far.
- Readers of `levels` order — `programmeToMeetings` (one Slot per level index)
  and `schedule_planner` — read the list as-is. Fixing the order is the point;
  nothing there needs to change.

## Architecture

### New: `lib/app/domain/models/round_order.dart` (pure)

```dart
int? roundRank(RoundType type)          // serie 0, quart 1, demi 2, finale 3, unknown null
bool canMoveLevel(List<RoundLevel> levels, int index, int delta)
List<RoundLevel> moveLevel(List<RoundLevel> levels, int index, int delta)
int insertionIndexFor(List<RoundLevel> levels, RoundType type)
List<RoundLevel> rewireRange(List<RoundLevel> levels, int first, int last)
```

**Validity.** A list is valid when every adjacent pair is non-decreasing in
rank. A pair where either side is `unknown` (rank `null`) is never counted as an
inversion.

**`canMoveLevel`.** `delta` is `-1` (up) or `+1` (down). False when the target
index is out of range. Otherwise the move is allowed when it **does not add an
inversion**: `inversions(after) <= inversions(before)`.

On a valid list this is exactly "the result must stay valid" — moving `finale`
above `demi` creates an inversion and is refused. The weaker formulation exists
for the lists that can already be invalid (persisted programmes, server import):
a strict "result must be valid" test would grey out every arrow at once and
leave the order unrepairable, whereas this rule lets the operator fix it one
swap at a time.

**`moveLevel`.** Swaps `index` with `index + delta` and returns the new list
already re-wired. Returns the list unchanged when the target index is out of
range. It does not re-check `canMoveLevel` — the view disables the arrow and
the controller checks before calling.

**`rewireRange`.** Re-wires opt2 the levels whose predecessor changed, and only
those. `first`/`last` are inclusive and clamped to the list bounds. For a swap
of the pair `(a, a + 1)` the caller passes `first = a - 1`, `last = a + 2`:
the two swapped levels, plus the one after them (its feeder changed), plus the
one before them (harmless, and it keeps the caller from having to special-case
index 0). Every race of a re-wired level takes `sourceRaceIds` = ids of all
races of the level before it; a re-wired level at index 0 gets an empty list.
Levels outside that range keep whatever `setWiring` put there — re-wiring the
whole structure would silently erase a hand-made opt1 wiring in a part that did
not move. `athleteIds` are copied through untouched.

**`insertionIndexFor`.** Returns the index just after the last level of rank
lower than or equal to `type`'s. A level of rank `unknown` is skipped when
scanning (it carries no position information). An `unknown` type being inserted
goes to the end.

### Changed: `StructureEditorController`

```dart
bool canMoveLevel(int index, int delta)   // delegates, false when structure is null
void moveLevel(int index, int delta)      // guard on canMoveLevel, then _commit
```

`addLevel` inserts the new `RoundLevel` at `insertionIndexFor(levels, type)`
instead of appending, then `rewireRange(levels, insertIndex, insertIndex + 1)`
so the inserted round and the one after it get a coherent wiring. The new round keeps inheriting
`s.spotsPerRace`.

### Changed: `StructureEditorView`

In `_LevelCard`'s header row, between the label and the delete button:

```text
[ SÉRIE ]                    ↑   ↓   🗑
```

Two `IconButton`s (`Icons.arrow_upward` / `Icons.arrow_downward`), `iconSize`
matched to the delete button, `onPressed: null` when
`!controller.canMoveLevel(index, delta)`. They are **not** gated on
`isDeletingLevel`: a move is local and synchronous, an in-flight round deletion
is a network call, and the two do not conflict.

New translation keys in `core/translations/en_us.dart` + `fr_fr.dart`, used as
tooltips: `move_up` ("Move up" / "Monter"), `move_down` ("Move down" /
"Descendre").

## Data flow

1. Operator taps ↑ on the card at index `i`.
2. View calls `controller.moveLevel(i, -1)`.
3. Controller re-checks `canMoveLevel`, calls `moveLevel(levels, i, -1)`.
4. `moveLevel` swaps the pair `(i - 1, i)`, then
   `rewireRange(levels, i - 2, i + 1)` rebuilds `sourceRaceIds` over the
   affected range.
5. Controller `_commit`s the new `EventStructure` → `structure.value` updates →
   `Obx` rebuilds the list and the bracket view; `ProgrammeService.save`
   persists it.

## Error handling

There is no failure path. The move is pure, local, synchronous, and gated by
the disabled arrow. Nothing is sent to the server, so no `AppException`, no
`UiMessage`. A `moveLevel` call with an out-of-range or illegal index is a
no-op.

## Testing

`test/data/models/round_order_test.dart` (new):

- `roundRank` ordering; `unknown` has no rank.
- Valid lists: `série, demi, finale`; `quart, finale`; `série, finale`.
- Down-move of `série` past `demi` refused; up-move of `finale` past `demi`
  refused; up-move at index 0 and down-move at the last index refused.
- Two rounds of the same type may be swapped in both directions.
- A round of type `unknown` may be moved anywhere, and any round may be moved
  past it.
- An invalid imported list (`finale, série`) can be repaired: the swap that
  removes the inversion is allowed.
- After a move, `sourceRaceIds` of the affected levels is opt2-consistent, the
  first level has an empty wiring, a hand-wired level outside the window keeps
  its `sourceRaceIds`, and `athleteIds` are preserved.
- `insertionIndexFor`: a `demi` added to `série, finale` lands at index 1; a
  `série` added to `demi, finale` lands at index 0; an equal type lands after
  the existing one.

`test/presentation/modules/programme/controllers/structure_editor_controller_test.dart`
(extended):

- `moveLevel` reorders and persists through `ProgrammeService`.
- An illegal `moveLevel` leaves the structure untouched.
- `canMoveLevel` returns false at the list bounds and when the structure is null.
- `addLevel` inserts at the hierarchy position, not at the end.

No widget tests, per project convention.

## Out of scope

- Drag & drop reordering.
- Pushing the new order to FFSS (no endpoint).
- Re-numbering `ProgrammeRace.number` across levels.
- Validating the structure elsewhere (heat draw, schedule) — they read the list
  as given.
