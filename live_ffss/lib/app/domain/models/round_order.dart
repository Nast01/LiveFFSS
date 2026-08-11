import 'package:live_ffss/app/domain/models/round_level.dart';

/// Position of [type] in the FFSS round hierarchy: série < quart < demi <
/// finale. A level may be skipped (série → finale), but a higher round may
/// never precede a lower one.
///
/// Null for [RoundType.unknown]: a round whose `niveau` code we do not
/// recognise carries no position, so it constrains nothing rather than being
/// refused on a guess.
int? roundRank(RoundType type) => switch (type) {
      RoundType.serie => 0,
      RoundType.quart => 1,
      RoundType.demi => 2,
      RoundType.finale => 3,
      RoundType.unknown => null,
    };

/// Adjacent pairs that break the hierarchy. A pair involving an unranked round
/// is never counted.
int _inversions(List<RoundLevel> levels) {
  var count = 0;
  for (var i = 0; i + 1 < levels.length; i++) {
    final a = roundRank(levels[i].type);
    final b = roundRank(levels[i + 1].type);
    if (a != null && b != null && a > b) count++;
  }
  return count;
}

List<RoundLevel> _swap(List<RoundLevel> levels, int a, int b) {
  final out = [...levels];
  final held = out[a];
  out[a] = out[b];
  out[b] = held;
  return out;
}

/// Whether the round at [index] may move by [delta] (-1 up, +1 down).
///
/// The move is allowed when it **adds no inversion**. On a well-ordered list
/// that is exactly "the result stays valid". The weaker wording is what lets a
/// list that is already out of order be repaired: structures stored before the
/// hierarchy was enforced, and imports that follow the FFSS `ordre` field,
/// can both arrive invalid — a strict "must be valid" test would grey out
/// every arrow at once and leave them unfixable.
bool canMoveLevel(List<RoundLevel> levels, int index, int delta) {
  final target = index + delta;
  if (index < 0 || index >= levels.length) return false;
  if (target < 0 || target >= levels.length) return false;
  return _inversions(_swap(levels, index, target)) <= _inversions(levels);
}

/// Swaps the round at [index] with its neighbour at [index] + [delta] and
/// re-wires the rounds whose feeder changed. Returns [levels] unchanged when
/// either index is out of range.
///
/// Does not re-check [canMoveLevel] — the view disables the arrow and the
/// controller checks before calling.
List<RoundLevel> moveLevel(List<RoundLevel> levels, int index, int delta) {
  final target = index + delta;
  if (index < 0 || index >= levels.length) return levels;
  if (target < 0 || target >= levels.length) return levels;
  final first = index < target ? index : target;
  return rewireRange(_swap(levels, index, target), first - 1, first + 2);
}

/// Re-wires opt2 the rounds in `[first, last]` (inclusive, clamped to the
/// list): every race of a round is fed by all races of the round before it,
/// and a round at index 0 is fed by none.
///
/// Deliberately bounded: [setWiring]-style opt1 wiring authored elsewhere in
/// the structure would be erased by re-wiring the whole list. Drawn athletes
/// are untouched.
List<RoundLevel> rewireRange(List<RoundLevel> levels, int first, int last) {
  final out = [...levels];
  final from = first < 0 ? 0 : first;
  final to = last >= out.length ? out.length - 1 : last;
  for (var i = from; i <= to; i++) {
    final sources =
        i == 0 ? const <int>[] : out[i - 1].races.map((r) => r.id).toList();
    out[i] = out[i].copyWith(
      races:
          out[i].races.map((r) => r.copyWith(sourceRaceIds: sources)).toList(),
    );
  }
  return out;
}

/// Where a new round of [type] belongs: right after the last round of lower or
/// equal rank. Unranked rounds are scanned past rather than stopping the scan;
/// a round of unranked type is appended.
int insertionIndexFor(List<RoundLevel> levels, RoundType type) {
  final rank = roundRank(type);
  if (rank == null) return levels.length;
  var index = 0;
  for (var i = 0; i < levels.length; i++) {
    final other = roundRank(levels[i].type);
    if (other != null && other <= rank) index = i + 1;
  }
  return index;
}
