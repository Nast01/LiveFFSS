import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/domain/models/schedule_block.dart';
import 'package:live_ffss/app/domain/models/schedule_planner.dart';
import 'package:live_ffss/app/domain/models/site_day_start.dart';

void main() {
  final day = DateTime(2026, 6, 13);

  CompetitionProgramme withRaces(List<int> raceIds) => CompetitionProgramme(
        competitionId: 1,
        nextLocalId: 100,
        structures: [
          EventStructure(
            raceId: 500,
            categoryId: 7,
            raceLabel: '100m',
            categoryLabel: 'Cadets',
            levels: [
              RoundLevel(
                type: RoundType.serie,
                races: [for (final id in raceIds) ProgrammeRace(id: id, number: id)],
              ),
            ],
          ),
        ],
      );

  group('dayStartMinutes', () {
    test('defaults to 09:00 when no override', () {
      expect(dayStartMinutes(withRaces([1]), 2, day), 540);
    });
    test('uses the override for the matching site+day', () {
      final p = withRaces([1]).copyWith(dayStarts: [
        SiteDayStart(siteId: 2, day: day, startMinutes: 510),
      ]);
      expect(dayStartMinutes(p, 2, day), 510);
    });
  });

  group('scheduleRows', () {
    test('derives back-to-back times from the day start', () {
      final p = withRaces([1, 2]).copyWith(blocks: [
        ScheduleBlock(id: 10, siteId: 2, day: day, order: 0, raceId: 1),
        ScheduleBlock(id: 11, siteId: 2, day: day, order: 1, raceId: 2, durationMinutes: 15),
      ]);
      final rows = scheduleRows(p, 2, day);
      expect(rows.map((r) => r.begin), [DateTime(2026, 6, 13, 9), DateTime(2026, 6, 13, 9, 10)]);
      expect(rows.last.end, DateTime(2026, 6, 13, 9, 25));
    });

    test('a duration change reflows the following blocks', () {
      var p = withRaces([1, 2]).copyWith(blocks: [
        ScheduleBlock(id: 10, siteId: 2, day: day, order: 0, raceId: 1),
        ScheduleBlock(id: 11, siteId: 2, day: day, order: 1, raceId: 2),
      ]);
      p = setBlockDuration(p, 10, 20);
      final rows = scheduleRows(p, 2, day);
      expect(rows[1].begin, DateTime(2026, 6, 13, 9, 20));
    });

    test('honours the site-day start override', () {
      final p = withRaces([1]).copyWith(
        blocks: [ScheduleBlock(id: 10, siteId: 2, day: day, order: 0, raceId: 1)],
        dayStarts: [SiteDayStart(siteId: 2, day: day, startMinutes: 8 * 60 + 30)],
      );
      expect(scheduleRows(p, 2, day).single.begin, DateTime(2026, 6, 13, 8, 30));
    });
  });

  group('unscheduledRaces', () {
    test('lists races no block references', () {
      final p = withRaces([1, 2, 3]).copyWith(
        blocks: [ScheduleBlock(id: 10, siteId: 2, day: day, order: 0, raceId: 2)],
      );
      expect(unscheduledRaces(p).map((i) => i.raceId), [1, 3]);
    });
  });

  group('addRaceBlock / addManualBlock', () {
    test('append with the next order', () {
      var p = withRaces([1, 2]);
      p = addRaceBlock(p, 50, 1, 2, day);
      p = addManualBlock(p, 51, 'Pause', 30, 2, day);
      final rows = scheduleRows(p, 2, day);
      expect(rows.map((r) => r.block.order), [0, 1]);
      expect(rows[0].block.raceId, 1);
      expect(rows[1].block.manualLabel, 'Pause');
    });
  });

  group('reorderBlocks', () {
    test('moving the last before the first renumbers and reflows', () {
      var p = withRaces([1, 2]).copyWith(blocks: [
        ScheduleBlock(id: 10, siteId: 2, day: day, order: 0, raceId: 1),
        ScheduleBlock(id: 11, siteId: 2, day: day, order: 1, raceId: 2),
      ]);
      // ReorderableListView convention: move index 1 to index 0
      p = reorderBlocks(p, 2, day, 1, 0);
      final rows = scheduleRows(p, 2, day);
      expect(rows.map((r) => r.block.raceId), [2, 1]);
      expect(rows.map((r) => r.block.order), [0, 1]);
    });
  });

  group('removeBlock', () {
    test('drops the block and renumbers the rest contiguously', () {
      var p = withRaces([1, 2, 3]).copyWith(blocks: [
        ScheduleBlock(id: 10, siteId: 2, day: day, order: 0, raceId: 1),
        ScheduleBlock(id: 11, siteId: 2, day: day, order: 1, raceId: 2),
        ScheduleBlock(id: 12, siteId: 2, day: day, order: 2, raceId: 3),
      ]);
      p = removeBlock(p, 11);
      final rows = scheduleRows(p, 2, day);
      expect(rows.map((r) => r.block.raceId), [1, 3]);
      expect(rows.map((r) => r.block.order), [0, 1]);
    });
  });

  group('clearBlocksForSite', () {
    test('drops blocks and dayStarts of the site only', () {
      final p = withRaces([1, 2]).copyWith(
        blocks: [
          ScheduleBlock(id: 10, siteId: 5, day: day, order: 0, raceId: 1),
          ScheduleBlock(id: 11, siteId: 6, day: day, order: 0, raceId: 2),
        ],
        dayStarts: [
          SiteDayStart(siteId: 5, day: day, startMinutes: 540),
          SiteDayStart(siteId: 6, day: day, startMinutes: 540),
        ],
      );
      final cleared = clearBlocksForSite(p, 5);
      expect(cleared.blocks.map((b) => b.siteId), [6]);
      expect(cleared.dayStarts.map((s) => s.siteId), [6]);
    });
  });
}
