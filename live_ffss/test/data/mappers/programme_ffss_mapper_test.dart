import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/mappers/programme_ffss_mapper.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/race_placement.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/domain/models/run.dart';

void main() {
  RacePlacement at(int h, int m, {int site = 1, int dur = 10}) => RacePlacement(
        siteId: site,
        beginHour: DateTime(2026, 6, 13, h, m),
        durationMinutes: dur,
      );

  CompetitionProgramme prog(List<ProgrammeRace> races) => CompetitionProgramme(
        competitionId: 42,
        structures: [
          EventStructure(
            raceId: 100,
            categoryId: 7,
            raceLabel: '100m',
            categoryLabel: 'Cadets',
            levels: [RoundLevel(type: RoundType.serie, races: races)],
          ),
        ],
      );

  test('unscheduled races produce no meetings', () {
    final meetings = programmeToMeetings(
      prog(const [ProgrammeRace(id: 1, number: 1)]),
      competitionName: 'Champ',
    );
    expect(meetings, isEmpty);
  });

  test('one placed race → one meeting, one slot, one run', () {
    final meetings = programmeToMeetings(
      prog([ProgrammeRace(id: 1, number: 1, placement: at(9, 0))]),
      competitionName: 'Champ',
    );
    expect(meetings.length, 1);
    expect(meetings.single.date, DateTime(2026, 6, 13));
    final slots = meetings.single.slots;
    expect(slots.length, 1);
    // The slot carries the event's real spots/race, and leaves the FFSS
    // discipline `level` empty (the lean model has no discipline).
    expect(slots.single.raceFormatDetail!.spotsPerRace, 8);
    expect(slots.single.raceFormatDetail!.level, '');
    final runs = slots.single.runs;
    expect(runs.length, 1);
    expect(runs.single.beginTime, DateTime(2026, 6, 13, 9, 0));
    expect(runs.single.endTime, DateTime(2026, 6, 13, 9, 10));
    expect(runs.single.status, RunStatus.waiting);
  });

  test('the slot spans its runs, out of source order', () {
    final meetings = programmeToMeetings(
      prog([
        ProgrammeRace(id: 2, number: 2, placement: at(9, 20)),
        ProgrammeRace(id: 1, number: 1, placement: at(9, 0)),
      ]),
      competitionName: 'Champ',
    );
    final slot = meetings.single.slots.single;
    expect(slot.beginHour, DateTime(2026, 6, 13, 9, 0));
    expect(slot.endHour, DateTime(2026, 6, 13, 9, 30));
  });

  test('races on different days produce one meeting each', () {
    final meetings = programmeToMeetings(
      prog([
        ProgrammeRace(
            id: 1,
            number: 1,
            placement: RacePlacement(
                siteId: 1, beginHour: DateTime(2026, 6, 14, 9))),
        ProgrammeRace(id: 2, number: 2, placement: at(9, 0)),
      ]),
      competitionName: 'Champ',
    );
    expect(meetings.length, 2);
    expect(meetings.map((m) => m.date),
        containsAll([DateTime(2026, 6, 13), DateTime(2026, 6, 14)]));
  });

  test('two races of the same level+day group under one slot', () {
    final meetings = programmeToMeetings(
      prog([
        ProgrammeRace(id: 1, number: 1, placement: at(9, 0)),
        ProgrammeRace(id: 2, number: 2, placement: at(9, 10)),
      ]),
      competitionName: 'Champ',
    );
    expect(meetings.single.slots.length, 1);
    expect(meetings.single.slots.single.runs.length, 2);
  });

  test("the meeting spans its races' earliest begin to latest end", () {
    // Source order is REVERSED (latest-ending race first) so a positional
    // first/last regression would fail — only a true min/max passes.
    final meetings = programmeToMeetings(
      prog([
        ProgrammeRace(id: 2, number: 2, placement: at(9, 30, dur: 20)),
        ProgrammeRace(id: 1, number: 1, placement: at(9, 0)),
      ]),
      competitionName: 'Champ',
    );
    expect(meetings.single.beginHour, DateTime(2026, 6, 13, 9, 0));
    expect(meetings.single.endHour, DateTime(2026, 6, 13, 9, 50));
  });
}
