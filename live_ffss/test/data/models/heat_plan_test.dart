import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/heat_plan.dart';

void main() {
  group('proposeHeatPlan', () {
    test('no athlete present proposes no race', () {
      expect(
        proposeHeatPlan(presentCount: 0, maxSpotsPerRace: 16),
        (raceCount: 0, spotsPerRace: 0),
      );
    });

    test('an exact multiple of the capacity keeps that capacity', () {
      expect(
        proposeHeatPlan(presentCount: 32, maxSpotsPerRace: 16),
        (raceCount: 2, spotsPerRace: 16),
      );
    });

    test('tightens the spots onto what the draw will really produce', () {
      // 20 over a capacity of 16 runs 2 heats of 10, never 2 of 16.
      expect(
        proposeHeatPlan(presentCount: 20, maxSpotsPerRace: 16),
        (raceCount: 2, spotsPerRace: 10),
      );
    });

    test('rounds the spots up so the last heat absorbs the remainder', () {
      // 17 over 8 runs 3 heats of 6, 6 and 5.
      expect(
        proposeHeatPlan(presentCount: 17, maxSpotsPerRace: 8),
        (raceCount: 3, spotsPerRace: 6),
      );
    });

    test('a field smaller than the capacity runs a single heat', () {
      expect(
        proposeHeatPlan(presentCount: 5, maxSpotsPerRace: 16),
        (raceCount: 1, spotsPerRace: 5),
      );
    });

    test('an unauthored capacity seats everyone in one heat', () {
      expect(
        proposeHeatPlan(presentCount: 5, maxSpotsPerRace: 0),
        (raceCount: 1, spotsPerRace: 5),
      );
    });
  });
}
