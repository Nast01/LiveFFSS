import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/race_placement.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/domain/models/schedule_planner.dart';

void main() {
  CompetitionProgramme prog(List<ProgrammeRace> serieRaces) =>
      CompetitionProgramme(
        competitionId: 1,
        structures: [
          EventStructure(
            raceId: 100,
            categoryId: 7,
            raceLabel: '100m',
            categoryLabel: 'Cadets',
            levels: [RoundLevel(type: RoundType.serie, races: serieRaces)],
          ),
        ],
      );

  group('competitionDays', () {
    test('lists each day at midnight, inclusive', () {
      final days = competitionDays(DateTime(2026, 6, 13, 8), DateTime(2026, 6, 15, 20));
      expect(days, [DateTime(2026, 6, 13), DateTime(2026, 6, 14), DateTime(2026, 6, 15)]);
    });

    test('is empty when either bound is null', () {
      expect(competitionDays(null, DateTime(2026, 6, 15)), isEmpty);
      expect(competitionDays(DateTime(2026, 6, 13), null), isEmpty);
    });

    test('is empty when end precedes begin', () {
      expect(competitionDays(DateTime(2026, 6, 15), DateTime(2026, 6, 13)), isEmpty);
    });
  });

  group('allScheduleItems', () {
    test('flattens races with labels, round type and number', () {
      final items = allScheduleItems(prog(const [
        ProgrammeRace(id: 1, number: 1),
        ProgrammeRace(id: 2, number: 2),
      ]));
      expect(items.length, 2);
      expect(items.first.raceLabel, '100m');
      expect(items.first.categoryLabel, 'Cadets');
      expect(items.first.roundType, RoundType.serie);
      expect(items.first.number, 1);
      expect(items.first.placement, isNull);
    });
  });

  group('nextFreeStart', () {
    test('starts at the day start hour when the site is empty', () {
      final start = nextFreeStart(day: DateTime(2026, 6, 13), onSiteDay: const []);
      expect(start, DateTime(2026, 6, 13, 9));
    });

    test('starts at the latest end when the site has races', () {
      final start = nextFreeStart(day: DateTime(2026, 6, 13), onSiteDay: [
        RacePlacement(siteId: 1, beginHour: DateTime(2026, 6, 13, 9), durationMinutes: 10),
        RacePlacement(siteId: 1, beginHour: DateTime(2026, 6, 13, 9, 10), durationMinutes: 15),
      ]);
      expect(start, DateTime(2026, 6, 13, 9, 25));
    });
  });

  group('overlaps', () {
    final base = RacePlacement(siteId: 1, beginHour: DateTime(2026, 6, 13, 9), durationMinutes: 10);
    test('true when the candidate intersects another', () {
      final candidate = RacePlacement(siteId: 1, beginHour: DateTime(2026, 6, 13, 9, 5), durationMinutes: 10);
      expect(overlaps(candidate: candidate, others: [base]), isTrue);
    });
    test('false when the candidate starts exactly at another end (touching, not overlapping)', () {
      final candidate = RacePlacement(siteId: 1, beginHour: DateTime(2026, 6, 13, 9, 10), durationMinutes: 10);
      expect(overlaps(candidate: candidate, others: [base]), isFalse);
    });
  });

  group('setPlacement', () {
    test('sets the placement on the matching race only', () {
      final p = prog(const [ProgrammeRace(id: 1, number: 1), ProgrammeRace(id: 2, number: 2)]);
      final placement = RacePlacement(siteId: 9, beginHour: DateTime(2026, 6, 13, 9));
      final updated = setPlacement(p, 2, placement);
      final races = updated.structures.single.levels.single.races;
      expect(races[0].placement, isNull);
      expect(races[1].placement, placement);
    });

    test('null clears a placement', () {
      final placed = setPlacement(
        prog(const [ProgrammeRace(id: 1, number: 1)]),
        1,
        RacePlacement(siteId: 9, beginHour: DateTime(2026, 6, 13, 9)),
      );
      final cleared = setPlacement(placed, 1, null);
      expect(cleared.structures.single.levels.single.races.single.placement, isNull);
    });
  });

  group('clearPlacementsForSite', () {
    test('clears only races placed on the given site', () {
      var p = prog(const [ProgrammeRace(id: 1, number: 1), ProgrammeRace(id: 2, number: 2)]);
      p = setPlacement(p, 1, RacePlacement(siteId: 5, beginHour: DateTime(2026, 6, 13, 9)));
      p = setPlacement(p, 2, RacePlacement(siteId: 6, beginHour: DateTime(2026, 6, 13, 9)));
      final cleared = clearPlacementsForSite(p, 5);
      final races = cleared.structures.single.levels.single.races;
      expect(races[0].placement, isNull);
      expect(races[1].placement, isNotNull);
    });
  });
}
