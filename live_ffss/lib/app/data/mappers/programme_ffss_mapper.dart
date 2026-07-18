import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/heat.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';
import 'package:live_ffss/app/domain/models/race_format_detail.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/domain/models/run.dart';
import 'package:live_ffss/app/domain/models/schedule_planner.dart';
import 'package:live_ffss/app/domain/models/slot.dart';

/// Materialises the lean authoring model into the FFSS `Meeting → Slot → Run`
/// tree — the shape FFSS expects on write. Pure and deterministic; the actual
/// network push waits on the FFSS créneau/course endpoints (see the stubbed
/// `ProgrammeRemoteDataSource`). Only scheduled races (with a placement)
/// appear: one Meeting per day, one Slot per (day × round-level), one Run per
/// race. Ids are the authoring local ids; the real sync will reconcile them.
List<Meeting> programmeToMeetings(
  CompetitionProgramme p, {
  required String competitionName,
}) {
  // Collect (structure, level, race, placement) for every scheduled race.
  final scheduled = <_Placed>[];
  for (final s in p.structures) {
    for (var li = 0; li < s.levels.length; li++) {
      final level = s.levels[li];
      for (final r in level.races) {
        final placement = r.placement;
        if (placement == null) continue;
        scheduled.add(_Placed(
          structureRaceId: s.raceId,
          structureLevelIndex: li,
          raceLabel: s.raceLabel,
          categoryLabel: s.categoryLabel,
          level: level,
          spotsPerRace: s.spotsPerRace,
          raceLocalId: r.id,
          raceNumber: r.number,
          begin: placement.beginHour,
          end: placementEnd(placement),
          site: placement.siteId,
        ));
      }
    }
  }
  if (scheduled.isEmpty) return const [];

  // Group by day.
  final days = <DateTime>[];
  for (final pl in scheduled) {
    final day = DateTime(pl.begin.year, pl.begin.month, pl.begin.day);
    if (!days.any((d) => sameDay(d, day))) days.add(day);
  }
  days.sort();

  final meetings = <Meeting>[];
  for (final day in days) {
    final ofDay = scheduled.where((pl) => sameDay(pl.begin, day)).toList();

    // Group the day's races by (structure raceId × level index) → one Slot.
    final slotKeys = <(int, int)>[];
    for (final pl in ofDay) {
      final key = (pl.structureRaceId, pl.structureLevelIndex);
      if (!slotKeys.contains(key)) slotKeys.add(key);
    }

    final slots = <Slot>[];
    for (final key in slotKeys) {
      final ofSlot = ofDay
          .where((pl) =>
              pl.structureRaceId == key.$1 &&
              pl.structureLevelIndex == key.$2)
          .toList()
        ..sort((a, b) => a.begin.compareTo(b.begin));
      final level = ofSlot.first.level;
      final runs = [
        for (final pl in ofSlot)
          Run(
            id: pl.raceLocalId,
            name: '${_roundName(level.type)} ${pl.raceNumber}',
            label: '${pl.raceLabel} · ${pl.categoryLabel}',
            fullLabel:
                '${pl.raceLabel} · ${pl.categoryLabel} · ${_roundName(level.type)} ${pl.raceNumber}',
            status: RunStatus.waiting,
            statusLabel: '',
            site: pl.site.toString(),
            beginTime: pl.begin,
            endTime: pl.end,
            heat: Heat(number: pl.raceNumber),
          ),
      ];
      slots.add(Slot(
        id: _slotId(key),
        name: '${ofSlot.first.raceLabel} · ${_roundName(level.type)}',
        beginHour: runs.first.beginTime,
        endHour: runs.map((r) => r.endTime).reduce((a, b) => a.isAfter(b) ? a : b),
        raceFormatDetail: RaceFormatDetail(
          id: _slotId(key),
          order: key.$2,
          label: _roundName(level.type),
          fullLabel: _roundName(level.type),
          levelLabel: '',
          // FFSS `level`/`niveau` carries the DISCIPLINE (côtier/eau-plate),
          // not the round stage — the lean model has no discipline field, so
          // leave it empty rather than pollute it with a round name (which the
          // beach/swimming string-matching would then misclassify). The round
          // stage lives in `label`/`fullLabel`/`order`.
          level: '',
          numberOfRun: ofSlot.length,
          qualificationMethod: '',
          qualificationMethodLabel: '',
          spotsPerRace: ofSlot.first.spotsPerRace,
          qualifyingSpots: level.qualifiersPerRace,
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

/// A non-localised round name for the FFSS labels (the FFSS side stores plain
/// strings; this is not shown in-app, so it is not translated).
String _roundName(RoundType type) => switch (type) {
      RoundType.serie => 'Series',
      RoundType.quart => 'Quarter',
      RoundType.demi => 'Semi',
      RoundType.finale => 'Final',
      RoundType.unknown => 'Round',
    };

// Throwaway slot id from (structure raceId, level index). Assumes < 100
// levels per structure (série/quart/demi/finale — always a handful); the real
// FFSS sync reconciles these ids anyway.
int _slotId((int, int) key) => key.$1 * 100 + key.$2;

class _Placed {
  _Placed({
    required this.structureRaceId,
    required this.structureLevelIndex,
    required this.raceLabel,
    required this.categoryLabel,
    required this.level,
    required this.spotsPerRace,
    required this.raceLocalId,
    required this.raceNumber,
    required this.begin,
    required this.end,
    required this.site,
  });

  final int structureRaceId;
  final int structureLevelIndex;
  final String raceLabel;
  final String categoryLabel;
  final RoundLevel level;
  final int spotsPerRace;
  final int raceLocalId;
  final int raceNumber;
  final DateTime begin;
  final DateTime end;
  final int site;
}
