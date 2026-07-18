import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/race_placement.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';

void main() {
  final programme = CompetitionProgramme(
    competitionId: 42,
    nextLocalId: 5,
    structures: [
      EventStructure(
        raceId: 100,
        categoryId: 7,
        raceLabel: '100m Nage côtière',
        categoryLabel: 'Cadets',
        spotsPerRace: 8,
        levels: [
          RoundLevel(
            type: RoundType.serie,
            qualifiersPerRace: 2,
            races: const [
              ProgrammeRace(id: 1, number: 1),
              ProgrammeRace(id: 2, number: 2),
            ],
          ),
          RoundLevel(
            type: RoundType.finale,
            races: [
              ProgrammeRace(
                id: 3,
                number: 1,
                sourceRaceIds: const [1, 2],
                placement: RacePlacement(
                  siteId: 9,
                  beginHour: DateTime(2026, 6, 13, 9, 30),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  test('round-trips the full tree through JSON', () {
    expect(CompetitionProgramme.fromJson(programme.toJson()), programme);
  });

  test('defaults: empty programme has nextLocalId 1 and no structures', () {
    const p = CompetitionProgramme(competitionId: 1);
    expect(p.nextLocalId, 1);
    expect(p.structures, isEmpty);
    expect(p.sites, isEmpty);
  });

  test('an unscheduled race has a null placement', () {
    const race = ProgrammeRace(id: 1, number: 1);
    expect(race.placement, isNull);
    expect(race.sourceRaceIds, isEmpty);
  });
}
