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
}
