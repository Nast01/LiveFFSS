import 'dart:convert';

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
          const RoundLevel(
            type: RoundType.serie,
            qualifiersPerRace: 2,
            races: [
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
    // explicit_to_json is false (no build.yaml): toJson() leaves nested
    // freezed objects as-is; jsonEncode serialises them recursively. This
    // mirrors how ProgrammeService persists (jsonEncode(toJson()) →
    // jsonDecode → fromJson), which is the real round-trip path.
    final restored = CompetitionProgramme.fromJson(
      jsonDecode(jsonEncode(programme.toJson())) as Map<String, dynamic>,
    );
    expect(restored, programme);
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
