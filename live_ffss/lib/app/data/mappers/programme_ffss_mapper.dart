import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/heat.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';
import 'package:live_ffss/app/domain/models/race_format_detail.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/domain/models/run.dart';
import 'package:live_ffss/app/domain/models/schedule_planner.dart';
import 'package:live_ffss/app/domain/models/slot.dart';

/// Materialises the block schedule into the FFSS `Meeting → Slot → Run` tree.
/// Pure and deterministic; the network push waits on the FFSS créneau/course
/// endpoints (see the stubbed `ProgrammeRemoteDataSource`). Only **race**
/// blocks appear — manual items have no FFSS course equivalent and are
/// omitted. One Meeting per day, one Slot per (structure raceId × level index),
/// one Run per race block, times derived from the block sequence.
List<Meeting> programmeToMeetings(
  CompetitionProgramme p, {
  required String competitionName,
}) {
  // Index every race → (structure, level, level index) for label/format lookup.
  final index = <int, _RaceRef>{};
  for (final s in p.structures) {
    for (var li = 0; li < s.levels.length; li++) {
      final level = s.levels[li];
      for (final r in level.races) {
        index[r.id] = _RaceRef(
          structureRaceId: s.raceId,
          levelIndex: li,
          level: level,
          raceLabel: s.raceLabel,
          categoryLabel: s.categoryLabel,
          spotsPerRace: s.spotsPerRace,
          raceNumber: r.number,
        );
      }
    }
  }

  // Derive begin/end for every race block, grouped by day.
  final siteDays = <(int, DateTime)>[];
  for (final b in p.blocks) {
    final key = (b.siteId, DateTime(b.day.year, b.day.month, b.day.day));
    if (!siteDays.contains(key)) siteDays.add(key);
  }

  final placed = <_Placed>[];
  for (final key in siteDays) {
    for (final row in scheduleRows(p, key.$1, key.$2)) {
      final raceId = row.block.raceId;
      if (raceId == null) continue; // skip manual blocks
      final ref = index[raceId];
      if (ref == null) continue;
      placed.add(_Placed(
        ref: ref,
        raceLocalId: raceId,
        site: key.$1,
        begin: row.begin,
        end: row.end,
      ));
    }
  }
  if (placed.isEmpty) return const [];

  final days = <DateTime>[];
  for (final pl in placed) {
    final day = DateTime(pl.begin.year, pl.begin.month, pl.begin.day);
    if (!days.any((d) => sameDay(d, day))) days.add(day);
  }
  days.sort();

  final meetings = <Meeting>[];
  for (final day in days) {
    final ofDay = placed.where((pl) => sameDay(pl.begin, day)).toList();

    final slotKeys = <(int, int)>[];
    for (final pl in ofDay) {
      final key = (pl.ref.structureRaceId, pl.ref.levelIndex);
      if (!slotKeys.contains(key)) slotKeys.add(key);
    }

    final slots = <Slot>[];
    for (final key in slotKeys) {
      final ofSlot = ofDay
          .where((pl) =>
              pl.ref.structureRaceId == key.$1 && pl.ref.levelIndex == key.$2)
          .toList()
        ..sort((a, b) => a.begin.compareTo(b.begin));
      final ref = ofSlot.first.ref;
      final runs = [
        for (final pl in ofSlot)
          Run(
            id: pl.raceLocalId,
            name: '${_roundName(pl.ref.level.type)} ${pl.ref.raceNumber}',
            label: '${pl.ref.raceLabel} · ${pl.ref.categoryLabel}',
            fullLabel:
                '${pl.ref.raceLabel} · ${pl.ref.categoryLabel} · ${_roundName(pl.ref.level.type)} ${pl.ref.raceNumber}',
            status: RunStatus.waiting,
            statusLabel: '',
            site: pl.site.toString(),
            beginTime: pl.begin,
            endTime: pl.end,
            heat: Heat(number: pl.ref.raceNumber),
          ),
      ];
      slots.add(Slot(
        id: _slotId(key),
        name: '${ref.raceLabel} · ${_roundName(ref.level.type)}',
        beginHour: runs.first.beginTime,
        endHour:
            runs.map((r) => r.endTime).reduce((a, b) => a.isAfter(b) ? a : b),
        raceFormatDetail: RaceFormatDetail(
          id: _slotId(key),
          order: key.$2,
          label: _roundName(ref.level.type),
          fullLabel: _roundName(ref.level.type),
          levelLabel: '',
          level: '',
          numberOfRun: ofSlot.length,
          qualificationMethod: '',
          qualificationMethodLabel: '',
          spotsPerRace: ref.spotsPerRace,
          qualifyingSpots: ref.level.qualifiersPerRace,
        ),
        runs: runs,
      ));
    }

    final begin =
        ofDay.map((pl) => pl.begin).reduce((a, b) => a.isBefore(b) ? a : b);
    final end =
        ofDay.map((pl) => pl.end).reduce((a, b) => a.isAfter(b) ? a : b);
    meetings.add(Meeting(
      id: day.millisecondsSinceEpoch ~/ 1000,
      name: competitionName,
      description: '',
      date: day,
      beginHour: begin,
      endHour: end,
      slots: slots,
    ));
  }
  return meetings;
}

String _roundName(RoundType type) => switch (type) {
      RoundType.serie => 'Series',
      RoundType.quart => 'Quarter',
      RoundType.demi => 'Semi',
      RoundType.finale => 'Final',
      RoundType.unknown => 'Round',
    };

// Throwaway slot id from (structure raceId, level index). Assumes < 100 levels
// per structure; the real FFSS sync reconciles these ids anyway.
int _slotId((int, int) key) => key.$1 * 100 + key.$2;

class _RaceRef {
  _RaceRef({
    required this.structureRaceId,
    required this.levelIndex,
    required this.level,
    required this.raceLabel,
    required this.categoryLabel,
    required this.spotsPerRace,
    required this.raceNumber,
  });
  final int structureRaceId;
  final int levelIndex;
  final RoundLevel level;
  final String raceLabel;
  final String categoryLabel;
  final int spotsPerRace;
  final int raceNumber;
}

class _Placed {
  _Placed({
    required this.ref,
    required this.raceLocalId,
    required this.site,
    required this.begin,
    required this.end,
  });
  final _RaceRef ref;
  final int raceLocalId;
  final int site;
  final DateTime begin;
  final DateTime end;
}
