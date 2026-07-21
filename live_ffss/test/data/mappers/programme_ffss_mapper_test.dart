import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/mappers/programme_ffss_mapper.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/domain/models/run.dart';
import 'package:live_ffss/app/domain/models/schedule_block.dart';

void main() {
  final day = DateTime(2026, 6, 13);

  CompetitionProgramme prog(List<ScheduleBlock> blocks, {List<int> raceIds = const [1, 2]}) =>
      CompetitionProgramme(
        competitionId: 42,
        structures: [
          EventStructure(
            raceId: 500,
            categoryId: 7,
            raceLabel: '100m',
            categoryLabel: 'Cadets',
            spotsPerRace: 8,
            levels: [
              RoundLevel(
                type: RoundType.serie,
                qualifiersPerRace: 2,
                races: [for (final id in raceIds) ProgrammeRace(id: id, number: id)],
              ),
            ],
          ),
        ],
        blocks: blocks,
      );

  test('no blocks → no meetings', () {
    expect(programmeToMeetings(prog(const []), competitionName: 'C'), isEmpty);
  });

  test('one race block → one meeting/slot/run at the derived time', () {
    final meetings = programmeToMeetings(
      prog([ScheduleBlock(id: 9, siteId: 3, day: day, order: 0, raceId: 1)]),
      competitionName: 'C',
    );
    expect(meetings.length, 1);
    expect(meetings.single.date, DateTime(2026, 6, 13));
    final slot = meetings.single.slots.single;
    expect(slot.raceFormatDetail!.spotsPerRace, 8);
    expect(slot.raceFormatDetail!.level, '');
    final run = slot.runs.single;
    expect(run.beginTime, DateTime(2026, 6, 13, 9)); // default start
    expect(run.endTime, DateTime(2026, 6, 13, 9, 10));
    expect(run.status, RunStatus.waiting);
    expect(run.site, '3');
  });

  test('a manual block is omitted from the mapper output', () {
    final meetings = programmeToMeetings(
      prog([
        ScheduleBlock(id: 9, siteId: 3, day: day, order: 0, raceId: 1),
        ScheduleBlock(id: 10, siteId: 3, day: day, order: 1, manualLabel: 'Pause', durationMinutes: 30),
      ]),
      competitionName: 'C',
    );
    expect(meetings.single.slots.single.runs.length, 1); // only the race
  });

  test('two race blocks of the same level+day group under one slot with derived times', () {
    final meetings = programmeToMeetings(
      prog([
        ScheduleBlock(id: 9, siteId: 3, day: day, order: 0, raceId: 1),
        ScheduleBlock(id: 10, siteId: 3, day: day, order: 1, raceId: 2),
      ]),
      competitionName: 'C',
    );
    final runs = meetings.single.slots.single.runs;
    expect(runs.length, 2);
    expect(runs.map((r) => r.beginTime),
        [DateTime(2026, 6, 13, 9), DateTime(2026, 6, 13, 9, 10)]);
  });
}
