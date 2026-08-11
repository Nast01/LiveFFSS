import 'dart:math';

import 'package:live_ffss/app/domain/models/athlete.dart';

/// Draws the athletes marked present into heats, in lane order — the index of
/// an athlete within a heat IS their lane, coastal lanes being sequential.
///
/// Heats come out *balanced*, not filled to the brim: 17 athletes over heats of
/// 8 give 6/6/5 rather than 8/8/1, which is the coastal practice. Clubmates are
/// spread as evenly as the numbers allow, so a club of 6 over 3 heats lands 2
/// per heat.
///
/// [random] is injected rather than created here so a draw can be reproduced in
/// tests. In the app it is seeded from the clock, and a redraw deliberately
/// yields a different result.
List<List<Athlete>> drawHeats({
  required List<Athlete> present,
  required int spotsPerRace,
  required Random random,
}) {
  if (present.isEmpty) return const [];
  final spots = spotsPerRace > 0 ? spotsPerRace : present.length;
  final heatCount = (present.length / spots).ceil();

  final heats = List.generate(heatCount, (_) => <Athlete>[]);
  final clubTally = List.generate(heatCount, (_) => <int, int>{});

  for (final group in _clubGroups(present, random)) {
    for (final athlete in group) {
      final heat = _bestHeatFor(athlete, heats, clubTally);
      heats[heat].add(athlete);
      if (athlete.clubId > 0) {
        clubTally[heat][athlete.clubId] =
            (clubTally[heat][athlete.clubId] ?? 0) + 1;
      }
    }
  }

  for (final heat in heats) {
    heat.shuffle(random);
  }
  return heats;
}

/// Athletes bundled by club, largest club first — the biggest ones constrain
/// the spread the most, so they get to pick their heats before the others.
///
/// An unaffiliated athlete (`clubId <= 0`) becomes their own group: they share
/// no club with the other unaffiliated ones, and balancing them together would
/// scatter them as if they did.
List<List<Athlete>> _clubGroups(List<Athlete> present, Random random) {
  final groups = <List<Athlete>>[];
  final byClub = <int, List<Athlete>>{};
  for (final athlete in present) {
    if (athlete.clubId <= 0) {
      groups.add([athlete]);
    } else {
      byClub.putIfAbsent(athlete.clubId, () => []).add(athlete);
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

/// The heat where this athlete's club is least represented; ties go to the
/// emptiest heat, which is what keeps the sizes within one of each other.
int _bestHeatFor(
  Athlete athlete,
  List<List<Athlete>> heats,
  List<Map<int, int>> clubTally,
) {
  var best = 0;
  for (var i = 1; i < heats.length; i++) {
    final here = clubTally[i][athlete.clubId] ?? 0;
    final bestSoFar = clubTally[best][athlete.clubId] ?? 0;
    if (here < bestSoFar ||
        (here == bestSoFar && heats[i].length < heats[best].length)) {
      best = i;
    }
  }
  return best;
}
