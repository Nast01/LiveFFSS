import 'dart:math';

import 'package:live_ffss/app/domain/models/entry.dart';

/// The club an entry competes under, 0 when it has none.
///
/// The entry's own organisme wins; failing that, its athletes' clubId — the
/// entries flattened out of the club list carry only the latter. Exposed
/// because the draw and its tests must agree on this rule, and so must
/// whatever displays the spread.
int entryClubId(Entry entry) {
  final organisme = entry.organisme;
  if (organisme != null && organisme.id > 0) return organisme.id;
  for (final athlete in entry.athletes) {
    if (athlete.clubId > 0) return athlete.clubId;
  }
  return 0;
}

/// Draws the entries marked present into [raceCount] heats, in lane order —
/// the index of an entry within a heat IS its lane, coastal lanes being
/// sequential.
///
/// Entries, not athletes: a lane seats one engagement whatever its size, so a
/// relay team of four takes one lane exactly as it does on the federal site.
/// For individual épreuves the two readings coincide.
///
/// The heat count is given, not derived: it comes from a plan the operator has
/// validated (see `proposeHeatPlan`), so the draw can no longer overrule the
/// authored structure. Heats come out *balanced*, not filled to the brim: 17
/// entries over 3 heats give 6/6/5 rather than 8/8/1, which is the coastal
/// practice. Clubmates are spread as evenly as the numbers allow, so a club of
/// 6 over 3 heats lands 2 per heat.
///
/// [random] is injected rather than created here so a draw can be reproduced in
/// tests. In the app it is seeded from the clock, and a redraw deliberately
/// yields a different result.
List<List<Entry>> drawHeats({
  required List<Entry> present,
  required int raceCount,
  required Random random,
}) {
  if (present.isEmpty || raceCount <= 0) return const [];

  final heats = List.generate(raceCount, (_) => <Entry>[]);
  final clubTally = List.generate(raceCount, (_) => <int, int>{});

  for (final group in _clubGroups(present, random)) {
    for (final entry in group) {
      final club = entryClubId(entry);
      final heat = _bestHeatFor(club, heats, clubTally);
      heats[heat].add(entry);
      if (club > 0) {
        clubTally[heat][club] = (clubTally[heat][club] ?? 0) + 1;
      }
    }
  }

  for (final heat in heats) {
    heat.shuffle(random);
  }
  return heats;
}

/// Entries bundled by club, largest club first — the biggest ones constrain
/// the spread the most, so they get to pick their heats before the others.
///
/// An unaffiliated entry (club 0) becomes its own group: it shares no club
/// with the other unaffiliated ones, and balancing them together would
/// scatter them as if it did.
List<List<Entry>> _clubGroups(List<Entry> present, Random random) {
  final groups = <List<Entry>>[];
  final byClub = <int, List<Entry>>{};
  for (final entry in present) {
    final club = entryClubId(entry);
    if (club <= 0) {
      groups.add([entry]);
    } else {
      byClub.putIfAbsent(club, () => []).add(entry);
    }
  }
  groups.addAll(byClub.values);

  for (final group in groups) {
    group.shuffle(random);
  }
  groups.shuffle(random);
  groups.sort((a, b) => b.length.compareTo(a.length));
  return groups;
}

/// The heat where this club is least represented; ties go to the emptiest
/// heat, which is what keeps the sizes within one of each other.
int _bestHeatFor(
  int club,
  List<List<Entry>> heats,
  List<Map<int, int>> clubTally,
) {
  var best = 0;
  for (var i = 1; i < heats.length; i++) {
    final here = clubTally[i][club] ?? 0;
    final bestSoFar = clubTally[best][club] ?? 0;
    if (here < bestSoFar ||
        (here == bestSoFar && heats[i].length < heats[best].length)) {
      best = i;
    }
  }
  return best;
}
