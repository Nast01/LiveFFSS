/// The ranking of one course, computed from the order it was crossed in.
///
/// A `finishOrder` is a list of finishing groups, in order: one competitor id
/// normally, several when the operator declared them tied. Nothing here stores
/// a place — every place is derived, which is what makes removing a competitor
/// renumber the rest for free and makes a tie an ordinary group.
///
/// Every function below returns a list the caller owns, even on a no-op path.
/// Handing back the argument unchanged would let a caller that assigns the
/// result straight into the RxList it read it from alias that RxList's value
/// against itself, and a later read would recurse forever.
library;

/// Place of every competitor who finished, keyed by competitor id.
///
/// A tie consumes the places it occupies: two firsts leave nobody second, and
/// the next group is third. That is the federation's ranking, and it is the
/// reason a group's place counts the competitors before it rather than the groups.
Map<int, int> placesOf(List<List<int>> finishOrder) {
  final places = <int, int>{};
  var placed = 0;
  for (final group in finishOrder) {
    final place = placed + 1;
    for (final competitorId in group) {
      places[competitorId] = place;
    }
    placed += group.length;
  }
  return places;
}

/// The place the next competitor entered will take.
int nextPlace(List<List<int>> finishOrder) =>
    1 + finishOrder.fold<int>(0, (total, group) => total + group.length);

/// [finishOrder] with [competitorId] added at the end — tied to the last group
/// when [tied], in a group of their own otherwise.
///
/// Un compétiteur déjà placé revient inchangé : une lecture de bracelet deux
/// fois ne doit pas le classer à deux endroits.
List<List<int>> withFinisher(
  List<List<int>> finishOrder,
  int competitorId, {
  required bool tied,
}) {
  if (placesOf(finishOrder).containsKey(competitorId)) {
    return [
      for (final group in finishOrder) [...group],
    ];
  }
  final groups = [
    for (final group in finishOrder) [...group],
  ];
  // Tying to nothing is not a tie; the lock must not swallow the first competitor.
  if (tied && groups.isNotEmpty) {
    groups.last.add(competitorId);
  } else {
    groups.add([competitorId]);
  }
  return groups;
}

/// [finishOrder] without [competitorId]. A group left empty is dropped, so the
/// competitors after them close the gap.
List<List<int>> withoutCompetitor(
  List<List<int>> finishOrder,
  int competitorId,
) =>
    [
      for (final group in finishOrder)
        if (group.any((id) => id != competitorId))
          [
            for (final id in group)
              if (id != competitorId) id,
          ],
    ];

/// [finishOrder] without the competitor entered last — the undo of a single
/// entry, whether it opened a group or joined one.
List<List<int>> withoutLastFinisher(List<List<int>> finishOrder) {
  if (finishOrder.isEmpty) return [];
  final groups = [
    for (final group in finishOrder) [...group],
  ];
  groups.last.removeLast();
  if (groups.last.isEmpty) groups.removeLast();
  return groups;
}

/// [finishOrder] with [competitorId] claiming [place], leaving whatever rank it
/// held before.
///
/// This is what manual entry writes. Sharing a number with someone else is a
/// declared tie — the same rule the automatic lock produces — so the places
/// after it renumber: two firsts leave nobody second.
///
/// The ranking stays dense from 1: you cannot be second with no first, so a
/// number beyond the field simply lands at the end. A place below 1 is not a
/// place and changes nothing.
List<List<int>> withPlace(
  List<List<int>> finishOrder,
  int competitorId,
  int place,
) {
  if (place < 1) {
    return [
      for (final group in finishOrder) [...group],
    ];
  }
  final places = placesOf(finishOrder);
  // Grouped on the places they hold now, so competitors already tied stay tied
  // while the competitor being moved is pulled out of wherever they were.
  final byPlace = <int, List<int>>{};
  for (final group in finishOrder) {
    for (final id in group) {
      if (id == competitorId) continue;
      (byPlace[places[id]!] ??= []).add(id);
    }
  }
  (byPlace[place] ??= []).add(competitorId);
  final ranks = byPlace.keys.toList()..sort();
  return [for (final rank in ranks) byPlace[rank]!];
}
