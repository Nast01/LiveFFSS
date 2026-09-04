import 'package:live_ffss/app/domain/models/round_level.dart';

/// The entries that go through to the next round, given how the déroulement
/// says to pick them.
///
/// [rankedByRace] holds one ranking per course of the round — entry ids, best
/// first, competitors out of the ranking already dropped. [spots] is the
/// round's `nbPlaceQualificative`, [method] its `LogiqueQualification`.
///
/// Two codes qualify anybody:
///
/// - `course` — each course sends its own best [spots] through, whatever the
///   other courses did. This is how semi-finals feeding one final work.
/// - `partie` — the best [spots] of the whole round. With no comparable times
///   to sort on, the only honest cross-course order is the rank itself: every
///   winner first, then every runner-up, and so on until the quota is full.
///
/// Anything else — `none`, a code a later FFSS build invents — qualifies
/// nobody. A round declaring no qualifying spot is a terminal round, and
/// promoting anyone out of it would invent a sequel no one asked for.
List<int> qualifiedEntries({
  required List<List<int>> rankedByRace,
  required String method,
  required int spots,
}) {
  if (spots <= 0 || rankedByRace.isEmpty) return const [];

  if (method == 'course') {
    return [
      for (final ranking in rankedByRace) ...ranking.take(spots),
    ];
  }

  if (method == 'partie') {
    final qualified = <int>[];
    final deepest =
        rankedByRace.fold<int>(0, (max, r) => r.length > max ? r.length : max);
    for (var position = 0; position < deepest; position++) {
      for (final ranking in rankedByRace) {
        if (position >= ranking.length) continue;
        qualified.add(ranking[position]);
        if (qualified.length == spots) return qualified;
      }
    }
    return qualified;
  }

  assert(method == qualificationNone || method.isNotEmpty);
  return const [];
}
