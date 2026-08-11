import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/domain/models/round_order.dart';

RoundLevel _level(
  RoundType type,
  List<int> raceIds, {
  List<int> sources = const [],
  List<int> athletes = const [],
}) =>
    RoundLevel(
      type: type,
      races: [
        for (var i = 0; i < raceIds.length; i++)
          ProgrammeRace(
            id: raceIds[i],
            number: i + 1,
            sourceRaceIds: sources,
            athleteIds: athletes,
          ),
      ],
    );

List<RoundType> _types(List<RoundLevel> levels) =>
    levels.map((l) => l.type).toList();

List<int> _sourcesOf(RoundLevel level) =>
    level.races.first.sourceRaceIds.toList();

void main() {
  group('roundRank', () {
    test('ranks the rounds série < quart < demi < finale', () {
      expect(roundRank(RoundType.serie)! < roundRank(RoundType.quart)!, isTrue);
      expect(roundRank(RoundType.quart)! < roundRank(RoundType.demi)!, isTrue);
      expect(roundRank(RoundType.demi)! < roundRank(RoundType.finale)!, isTrue);
    });

    test('an unrecognised round has no rank', () {
      expect(roundRank(RoundType.unknown), isNull);
    });
  });

  group('canMoveLevel', () {
    test('a finale cannot move above a demi', () {
      final levels = [
        _level(RoundType.demi, [1]),
        _level(RoundType.finale, [2])
      ];
      expect(canMoveLevel(levels, 1, -1), isFalse);
    });

    test('a série cannot move below a demi', () {
      final levels = [
        _level(RoundType.serie, [1]),
        _level(RoundType.demi, [2])
      ];
      expect(canMoveLevel(levels, 0, 1), isFalse);
    });

    test('a skipped level is still a legal neighbour', () {
      // série, finale is valid, so the pair may not be swapped either way.
      final levels = [
        _level(RoundType.serie, [1]),
        _level(RoundType.finale, [2]),
      ];
      expect(canMoveLevel(levels, 0, 1), isFalse);
      expect(canMoveLevel(levels, 1, -1), isFalse);
    });

    test('refuses to move past the ends of the list', () {
      final levels = [
        _level(RoundType.serie, [1]),
        _level(RoundType.demi, [2])
      ];
      expect(canMoveLevel(levels, 0, -1), isFalse);
      expect(canMoveLevel(levels, 1, 1), isFalse);
    });

    test('two rounds of the same level swap freely', () {
      final levels = [
        _level(RoundType.serie, [1]),
        _level(RoundType.serie, [2]),
      ];
      expect(canMoveLevel(levels, 0, 1), isTrue);
      expect(canMoveLevel(levels, 1, -1), isTrue);
    });

    test('an unrecognised round never blocks a move', () {
      final levels = [
        _level(RoundType.serie, [1]),
        _level(RoundType.unknown, [2]),
        _level(RoundType.finale, [3]),
      ];
      expect(canMoveLevel(levels, 1, -1), isTrue);
      expect(canMoveLevel(levels, 1, 1), isTrue);
      expect(canMoveLevel(levels, 0, 1), isTrue);
      expect(canMoveLevel(levels, 2, -1), isTrue);
    });

    test('a list stored out of order can be repaired', () {
      final levels = [
        _level(RoundType.finale, [1]),
        _level(RoundType.serie, [2]),
      ];
      expect(canMoveLevel(levels, 0, 1), isTrue);
      expect(canMoveLevel(levels, 1, -1), isTrue);
    });
  });

  group('moveLevel', () {
    test('swaps the round with its neighbour', () {
      final levels = [
        _level(RoundType.finale, [1]),
        _level(RoundType.serie, [2]),
      ];
      expect(
          _types(moveLevel(levels, 0, 1)), [RoundType.serie, RoundType.finale]);
      expect(_types(moveLevel(levels, 1, -1)),
          [RoundType.serie, RoundType.finale]);
    });

    test('leaves the list untouched when the target is out of range', () {
      final levels = [
        _level(RoundType.serie, [1])
      ];
      expect(moveLevel(levels, 0, -1), levels);
      expect(moveLevel(levels, 0, 1), levels);
    });

    test('re-wires the moved rounds opt2 and empties the first one', () {
      final levels = [
        _level(RoundType.finale, [3], sources: [1, 2]),
        _level(RoundType.serie, [1, 2]),
      ];
      final moved = moveLevel(levels, 0, 1);
      expect(_sourcesOf(moved[0]), isEmpty);
      expect(_sourcesOf(moved[1]), [1, 2]);
    });

    test('keeps the athletes already drawn into the moved races', () {
      final levels = [
        _level(RoundType.finale, [3]),
        _level(RoundType.serie, [1, 2], athletes: [10, 11]),
      ];
      final moved = moveLevel(levels, 0, 1);
      expect(moved[0].races.first.athleteIds, [10, 11]);
    });

    test('leaves the wiring of rounds outside the moved window alone', () {
      final levels = [
        _level(RoundType.serie, [1, 2]),
        _level(RoundType.serie, [3, 4]),
        _level(RoundType.demi, [5, 6]),
        // Hand-wired opt1: this finale is fed by one demi only.
        _level(RoundType.finale, [7], sources: [5]),
      ];
      final moved = moveLevel(levels, 0, 1);
      expect(_sourcesOf(moved[0]), isEmpty);
      expect(_sourcesOf(moved[1]), [3, 4]);
      expect(_sourcesOf(moved[2]), [1, 2]);
      expect(_sourcesOf(moved[3]), [5]);
    });
  });

  group('rewireRange', () {
    test('clamps the range to the list bounds', () {
      final levels = [
        _level(RoundType.serie, [1, 2], sources: [99]),
        _level(RoundType.finale, [3]),
      ];
      final rewired = rewireRange(levels, -5, 12);
      expect(_sourcesOf(rewired[0]), isEmpty);
      expect(_sourcesOf(rewired[1]), [1, 2]);
    });
  });

  group('insertionIndexFor', () {
    test('inserts into an empty structure at the start', () {
      expect(insertionIndexFor(const [], RoundType.finale), 0);
    });

    test('inserts a demi between the séries and the finale', () {
      final levels = [
        _level(RoundType.serie, [1]),
        _level(RoundType.finale, [2]),
      ];
      expect(insertionIndexFor(levels, RoundType.demi), 1);
    });

    test('inserts a série ahead of every higher round', () {
      final levels = [
        _level(RoundType.demi, [1]),
        _level(RoundType.finale, [2]),
      ];
      expect(insertionIndexFor(levels, RoundType.serie), 0);
    });

    test('inserts a round after one of the same level', () {
      final levels = [
        _level(RoundType.serie, [1]),
        _level(RoundType.finale, [2]),
      ];
      expect(insertionIndexFor(levels, RoundType.serie), 1);
    });

    test('scans past an unrecognised round rather than stopping on it', () {
      final levels = [
        _level(RoundType.unknown, [1]),
        _level(RoundType.serie, [2]),
      ];
      expect(insertionIndexFor(levels, RoundType.demi), 2);
    });

    test('appends a round whose level is unrecognised', () {
      final levels = [
        _level(RoundType.serie, [1]),
        _level(RoundType.finale, [2]),
      ];
      expect(insertionIndexFor(levels, RoundType.unknown), 2);
    });
  });
}
