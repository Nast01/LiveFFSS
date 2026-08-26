# Course result entry

Date: 2026-08-18
Status: approved, not implemented

## Problem

Tapping a drawn race opens `RaceCourseView`, which is a scaffold: it shows the
race name and an `EmptyState`, and its controller only carries the arguments it
was opened with. Nothing records who finished where.

A marshal on the beach needs to record a finishing order as the athletes cross
the line, by reading their bracelet or by tapping their name, and to record the
ones who did not finish — forfeits and disqualifications, the latter with a
code.

Nothing about results exists yet anywhere in the app: `ResultRepository`
methods throw `UnimplementedError`, and the drawn race carries only
`athleteIds`. The Séries tab already renders a place badge and a mention slot
per athlete, both showing a dash, waiting for exactly this.

## Scope

One drawn race — a `ProgrammeRace` of one round of one `EventStructure`.

Results are device-local, persisted into the authored programme through
`ProgrammeService`, like the draw they belong to. FFSS documents no write
endpoint for them, so two phones scoring the same race do not see each other.
`ResultRepository` stays the seam for the day that endpoint exists.

Out of scope: times, the FFSS `parties` payload, cross-device sync, and
propagating qualifiers into the next round.

## Ranking rules

Decided with the operator, and the reason each matters here:

1. **Ties skip the places they consume.** Two firsts, no second, the next
   athlete is third — the standard federation ranking.
2. **A forfeit or a disqualification takes no place.** They leave the ranking
   entirely, and the athletes after them number as though they had not started.
   The highest place a race can hand out is therefore its athlete count minus
   its withdrawals.
3. **A tie is declared by locking the place**, not by a gesture on an already
   ranked athlete. A bracelet cannot be long-pressed, and one procedure must
   serve both entry methods.
4. **A mistake is undone**, not started over: the last entry can be taken back,
   and any ranked athlete can be pulled out of the ranking.

## Design

### The model stores an order, never a place

The pressure point is renumbering. Storing a place per athlete means every
removal rewrites the places after it, and that is where inconsistencies get in.

So the race stores the order it was crossed in, and the places are computed:

```dart
/// Athletes who finished, in finishing order. Each entry is a group: one id
/// normally, several when they were declared tied.
List<List<int>> finishOrder;

/// Those who did not finish. Never part of the ranking.
List<CoursePenalty> penalties;  // {athleteId, kind, code}
```

`place(group i) = 1 + (number of athletes in groups before i)`. Two firsts make
the next group third with no special case. Removing an athlete renumbers
everyone after them by construction. Undoing is dropping the last id of the
last group. A tie is a group of two.

This is pure Dart — no Flutter, no GetX — and is tested the way `heat_plan` and
`heat_draw` are.

`CoursePenaltyKind` is `forfeit` or `disqualified`. `code` is free text, filled
only for a disqualification, and shown beside the mention.

Both fields hang off `ProgrammeRace`, beside the `athleteIds` the draw wrote,
and persist through `ProgrammeService`. The Séries tab's dash placeholders then
fill themselves.

### The screen

```
┌──────────────────────────────────────────────┐
│ ‹   Saisie des résultats                     │
├──────────────────────────────────────────────┤
│ 100m · Dames · Cadets · Série 1              │
│                                              │
│  Place suivante  3     [ ◻ ex-aequo ]   [ ↶ ]│
│  ┌────────────────────────────────────────┐  │
│  │  ⬤  Scanner les bracelets              │  │
│  └────────────────────────────────────────┘  │
├──────────────────────────────────────────────┤
│   1   🔵  DUPONT Jean       Nice         ⋮   │
│   2   🔴  MARTIN Paul       Antibes      ⋮   │
│  ──────────────────────────────────────────  │
│   —   🟡  DURAND Luc        Cannes       ⋮   │
│   —   🟢  PETIT Marc        Toulon       ⋮   │
│  DQ   🟣  ROUX Paul   4.7   Marseille    ⋮   │
│  FF   ⚫  NOËL Rémy         Nice         ⋮   │
└──────────────────────────────────────────────┘
```

One list, not two. Ranked athletes rise into place order, the unranked stay
below, withdrawals sink to the bottom. The pool of remaining athletes shrinks
in view, and the finished screen IS the result — no separate recap to build or
to keep in step.

Rows read like the draw screen and the Séries tab: place badge, club avatar,
name with club under it, mention on the right.

| Gesture | Effect |
|---|---|
| Tap an unranked athlete | gives them the next place |
| Tap a ranked athlete | pulls them out; those after renumber |
| `↶` | undoes the last entry, whether scanned or tapped |
| `⋮` | Forfait · Disqualifier… · Retirer du classement |
| `◻ ex-aequo` | locks the place: everything entered next shares it |

The **"Place suivante"** banner is the one place the operator checks that the
screen agrees with them. With the tie lock on it reads `3 · verrouillée`.

Disqualifying opens a dialog with a free-text field for the code, which then
shows beside the `DQ` on the row.

### Scanning

`RfidWriter.readBracelets()` already emits `<licence>;<lastName>` continuously,
and `parseBraceletLicence` matches `Athlete.licenseeNumber` — the same seam the
attendance scanner uses. Nothing new is needed to read a bracelet.

Unlike attendance, the session is a toggle on the page rather than a modal
sheet: the operator has to watch the list fill while scanning. A bracelet that
belongs to no athlete of this race, or to one already ranked, reports and
changes nothing. When every athlete is accounted for, the session stops on its
own.

The entry point is hidden when `RfidWriter.isSupported` is false, as everywhere
else.

### Persisting

Every gesture persists immediately. There is no Save button: a marshal does not
save, and losing fifteen scans to a killed app is not a trade worth making.
This is what attendance already does.

## Testing

- Ranking model: places from an order, ties skipping places, removal
  renumbering, undo, withdrawals taking no place, the maximum place falling as
  withdrawals rise.
- `RaceCourseController`: assigning by tap, assigning by scan, the tie lock,
  undo, removal, forfeit and disqualification with a code, an unknown bracelet,
  a bracelet already ranked, the race being complete.
- No widget test, per the project's rules. The screen is verified by hand.

## Deliberately not done

- Times. The FFSS payload for them is not documented and the beach ranks on
  order, not on a clock.
- Any FFSS write, and any cross-device sync.
- Feeding the qualifiers of a round into the next one. That is the next design.
