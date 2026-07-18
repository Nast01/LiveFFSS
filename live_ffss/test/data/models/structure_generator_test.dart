import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/domain/models/structure_generator.dart';

void main() {
  group('seriesCount', () {
    test('rounds up to fill the last série', () {
      expect(seriesCount(20, 8), 3); // 8 + 8 + 4
      expect(seriesCount(16, 8), 2);
      expect(seriesCount(17, 8), 3);
    });

    test('is zero for no entries', () {
      expect(seriesCount(0, 8), 0);
    });
  });

  group('proposeLevels', () {
    test('few enough entries → a single finale', () {
      expect(proposeLevels(entryCount: 6, spotsPerRace: 8),
          [(type: RoundType.finale, raceCount: 1)]);
    });

    test('exactly one race worth → a single finale', () {
      expect(proposeLevels(entryCount: 8, spotsPerRace: 8),
          [(type: RoundType.finale, raceCount: 1)]);
    });

    test('more than one race worth → séries then finale', () {
      expect(proposeLevels(entryCount: 20, spotsPerRace: 8), [
        (type: RoundType.serie, raceCount: 3),
        (type: RoundType.finale, raceCount: 1),
      ]);
    });

    test('no entries → an empty proposal', () {
      expect(proposeLevels(entryCount: 0, spotsPerRace: 8), isEmpty);
    });
  });

  group('buildDefaultLevels', () {
    test('allocates a unique id per race across all levels', () {
      var counter = 0;
      final levels = buildDefaultLevels(
        entryCount: 20,
        spotsPerRace: 8,
        allocateId: () => ++counter,
      );
      final ids = levels.expand((l) => l.races).map((r) => r.id).toList();
      expect(ids.toSet().length, ids.length);
      expect(ids, [1, 2, 3, 4]); // 3 séries + 1 finale
    });

    test('opt2 wires every race to all races of the previous level', () {
      var counter = 0;
      final levels = buildDefaultLevels(
        entryCount: 20,
        spotsPerRace: 8,
        allocateId: () => ++counter,
      );
      final serieIds = levels[0].races.map((r) => r.id).toList();
      final finale = levels[1].races.single;
      expect(finale.sourceRaceIds, serieIds);
    });

    test('the first level has no source races', () {
      var counter = 0;
      final levels = buildDefaultLevels(
        entryCount: 20,
        spotsPerRace: 8,
        allocateId: () => ++counter,
      );
      for (final race in levels.first.races) {
        expect(race.sourceRaceIds, isEmpty);
      }
    });

    test('no entries → no levels, allocateId never called', () {
      var calls = 0;
      final levels = buildDefaultLevels(
        entryCount: 0,
        spotsPerRace: 8,
        allocateId: () => ++calls,
      );
      expect(levels, isEmpty);
      expect(calls, 0);
    });
  });
}
