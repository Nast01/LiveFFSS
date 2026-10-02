/// The ranking of one course, as a grid of places.
///
/// A `finishOrder` is a list of places, in order: case `i` holds the
/// competitors of place `i + 1`. Usually one, several when the operator
/// declared them tied, **none** when nobody claims that place yet — the manual
/// entry types a number into a case, and the cases around it stay where the
/// operator left them. Empty cases at the end are trimmed: nothing behind them
/// holds them open.
///
/// A place is still derived rather than stored per competitor, which is what
/// makes a tie an ordinary group. Two readings of the same grid coexist, and
/// they only differ while cases are missing: [placesOf] is the operator's —
/// the number typed, gaps included — and [rankingOf] is the federation's — the
/// places closed up, which is what gets published.
///
/// Un ordre écrit avant cette grille n'a aucune case vide, et les deux lectures
/// lui rendent alors exactement le classement dense d'avant.
///
/// Every function below returns a list the caller owns, even on a no-op path.
/// Handing back the argument unchanged would let a caller that assigns the
/// result straight into the RxList it read it from alias that RxList's value
/// against itself, and a later read would recurse forever.
library;

/// Place of every competitor who finished, keyed by competitor id — ce que
/// l'écran de saisie montre.
///
/// Deux règles, et la plus tardive l'emporte. Un ex æquo consomme les places
/// qu'il occupe : deux premiers ne laissent personne second, et le groupe
/// suivant est troisième — c'est le classement fédéral, et la raison pour
/// laquelle une place compte les concurrents devant elle et non les groupes.
/// Un numéro tapé, lui, reste celui qu'on a tapé : la case 5 est la place 5,
/// même si les cases 3 et 4 n'ont encore personne.
Map<int, int> placesOf(List<List<int>> finishOrder) {
  final places = <int, int>{};
  var placed = 0;
  for (var slot = 0; slot < finishOrder.length; slot++) {
    final group = finishOrder[slot];
    if (group.isEmpty) continue;
    final place = _later(slot, placed);
    for (final competitorId in group) {
      places[competitorId] = place;
    }
    placed += group.length;
  }
  return places;
}

/// Le classement à publier : les places tassées sur les seuls concurrents
/// classés, ex æquo compris.
///
/// Les cases vides d'une saisie en cours ne partent pas à la fédération — un
/// cinquième sans troisième ni quatrième n'est pas un classement. Sur une
/// course entièrement saisie, sans trou, c'est mot pour mot [placesOf].
Map<int, int> rankingOf(List<List<int>> finishOrder) {
  final ranks = <int, int>{};
  var placed = 0;
  for (final group in finishOrder) {
    if (group.isEmpty) continue;
    for (final competitorId in group) {
      ranks[competitorId] = placed + 1;
    }
    placed += group.length;
  }
  return ranks;
}

/// The place the next competitor entered will take: the first case still free,
/// never earlier than the competitors already placed allow.
int nextPlace(List<List<int>> finishOrder) {
  var placed = 0;
  for (var slot = 0; slot < finishOrder.length; slot++) {
    if (finishOrder[slot].isEmpty) return _later(slot, placed);
    placed += finishOrder[slot].length;
  }
  return _later(finishOrder.length, placed);
}

/// La place que prend la case [slot] (0-indexée) quand [placed] concurrents
/// sont déjà classés devant elle.
int _later(int slot, int placed) =>
    slot + 1 > placed + 1 ? slot + 1 : placed + 1;

/// [finishOrder] with [competitorId] added at the first free place — tied to
/// the last place taken when [tied], so that the automatic entry keeps filling
/// the holes a manual correction may have left.
///
/// A competitor already placed is returned untouched: a bracelet read twice must
/// not rank them in two places.
List<List<int>> withFinisher(
  List<List<int>> finishOrder,
  int competitorId, {
  required bool tied,
}) {
  final groups = [
    for (final group in finishOrder) [...group],
  ];
  if (placesOf(finishOrder).containsKey(competitorId)) return groups;
  // Tying to nothing is not a tie; the lock must not swallow the first competitor.
  final last = groups.lastIndexWhere((group) => group.isNotEmpty);
  if (tied && last >= 0) {
    groups[last].add(competitorId);
    return groups;
  }
  final free = groups.indexWhere((group) => group.isEmpty);
  if (free >= 0) {
    groups[free].add(competitorId);
  } else {
    groups.add([competitorId]);
  }
  return groups;
}

/// [finishOrder] without [competitorId], la place qu'il occupait refermée
/// derrière lui — ce qu'un retrait du classement veut dire.
///
/// Les cases laissées vides ailleurs, elles, restent vides : personne n'a
/// demandé à les combler, et les combler renumérorerait ce que l'opérateur a
/// tapé.
List<List<int>> withoutCompetitor(
  List<List<int>> finishOrder,
  int competitorId,
) {
  final groups = [
    for (final group in finishOrder) [...group],
  ];
  final at = groups.indexWhere((group) => group.contains(competitorId));
  if (at < 0) return groups;
  groups[at].remove(competitorId);
  if (groups[at].isEmpty) groups.removeAt(at);
  return _trimmed(groups);
}

/// [finishOrder] où [competitorId] lâche sa place sans que personne ne remonte :
/// la case est vidée, pas refermée.
///
/// C'est l'inverse exact de [withPlace] — effacer un numéro tapé ne doit pas
/// renuméroter la suite, sans quoi corriger une erreur en créerait d'autres.
List<List<int>> withoutPlace(
  List<List<int>> finishOrder,
  int competitorId,
) =>
    _trimmed([
      for (final group in finishOrder)
        [
          for (final id in group)
            if (id != competitorId) id,
        ],
    ]);

/// [finishOrder] without the competitor entered last — the undo of a single
/// entry, whether it opened a place or joined one.
List<List<int>> withoutLastFinisher(List<List<int>> finishOrder) {
  final groups = [
    for (final group in finishOrder) [...group],
  ];
  final last = groups.lastIndexWhere((group) => group.isNotEmpty);
  if (last < 0) return [];
  groups[last].removeLast();
  if (groups[last].isEmpty) groups.removeAt(last);
  return _trimmed(groups);
}

/// [finishOrder] with [competitorId] claiming [place], leaving whatever rank it
/// held before.
///
/// This is what manual entry writes. Sharing a number with someone else is a
/// declared tie — the same rule the automatic lock produces — so the places
/// after it renumber: two firsts leave nobody second.
///
/// Personne d'autre ne bouge : taper 5 pose 5, et les cases 3 et 4 restent
/// libres pour ceux qui n'ont pas encore été saisis. Une place inférieure à 1
/// n'est pas une place et ne change rien — vider une case, c'est
/// [withoutPlace].
List<List<int>> withPlace(
  List<List<int>> finishOrder,
  int competitorId,
  int place,
) {
  final groups = [
    for (final group in finishOrder) [...group],
  ];
  if (place < 1) return groups;
  for (final group in groups) {
    group.remove(competitorId);
  }
  while (groups.length < place) {
    groups.add([]);
  }
  groups[place - 1].add(competitorId);
  return _trimmed(groups);
}

/// Les cases vides de la fin, retirées : rien derrière elles ne les tient
/// ouvertes, et les garder ferait grandir l'ordre à chaque correction.
List<List<int>> _trimmed(List<List<int>> groups) {
  final last = groups.lastIndexWhere((group) => group.isNotEmpty);
  return groups.sublist(0, last + 1);
}
