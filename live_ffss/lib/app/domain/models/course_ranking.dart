/// The ranking of one course, computed from the order it was crossed in.
///
/// A `finishOrder` is a list of finishing groups, in order: one athlete id
/// normally, several when the operator declared them tied. Nothing here stores
/// a place — every place is derived, which is what makes removing an athlete
/// renumber the rest for free and makes a tie an ordinary group.
///
/// Every function below returns a list the caller owns, even on a no-op path.
/// Handing back the argument unchanged would let a caller that assigns the
/// result straight into the RxList it read it from alias that RxList's value
/// against itself, and a later read would recurse forever.
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
  if (placesOf(finishOrder).containsKey(athleteId)) {
    return [
      for (final group in finishOrder) [...group],
    ];
  }
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
  if (finishOrder.isEmpty) return [];
  final groups = [
    for (final group in finishOrder) [...group],
  ];
  groups.last.removeLast();
  if (groups.last.isEmpty) groups.removeLast();
  return groups;
}
