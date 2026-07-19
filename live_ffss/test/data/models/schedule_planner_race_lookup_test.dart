import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/domain/models/schedule_planner.dart';

void main() {
  const programme = CompetitionProgramme(
    competitionId: 42,
    structures: [
      EventStructure(
        raceId: 500,
        categoryId: 7,
        raceLabel: '100m',
        categoryLabel: 'Cadets',
        levels: [
          RoundLevel(type: RoundType.serie, races: [
            ProgrammeRace(id: 10, number: 1),
            ProgrammeRace(id: 11, number: 2),
          ]),
          RoundLevel(type: RoundType.finale, races: [
            ProgrammeRace(id: 12, number: 1),
          ]),
        ],
      ),
    ],
  );

  group('raceItemFor', () {
    test('returns label/round/number for a scheduled race id', () {
      final item = raceItemFor(programme, 11);
      expect(item, isNotNull);
      expect(item!.raceLabel, '100m');
      expect(item.categoryLabel, 'Cadets');
      expect(item.roundType, RoundType.serie);
      expect(item.number, 2);
    });

    test('resolves a race in a later level', () {
      expect(raceItemFor(programme, 12)!.roundType, RoundType.finale);
    });

    test('returns null for an unknown id', () {
      expect(raceItemFor(programme, 999), isNull);
    });
  });

  group('structureRaceIdFor', () {
    test('returns the owning EventStructure.raceId (FFSS race id)', () {
      expect(structureRaceIdFor(programme, 10), 500);
      expect(structureRaceIdFor(programme, 12), 500);
    });

    test('returns null when the block race id is unknown', () {
      expect(structureRaceIdFor(programme, 999), isNull);
    });
  });
}
