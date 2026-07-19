import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/race_placement.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/domain/models/schedule_block.dart';
import 'package:live_ffss/app/domain/models/site_day_start.dart';

/// The hour a competition day's timeline starts when a site has no races yet.
const int scheduleDayStartHour = 9;

/// A race flattened for the scheduling UI: its labels, round stage, number,
/// and placement (null = unscheduled). A pure view model, not persisted.
class ScheduleItem {
  const ScheduleItem({
    required this.raceId,
    required this.raceLabel,
    required this.categoryLabel,
    required this.roundType,
    required this.number,
    this.placement,
  });

  final int raceId;
  final String raceLabel;
  final String categoryLabel;
  final RoundType roundType;
  final int number;
  final RacePlacement? placement;
}

/// Every competition day from [begin] to [end] inclusive, normalised to
/// midnight. Empty if either is null or [end] precedes [begin].
List<DateTime> competitionDays(DateTime? begin, DateTime? end) {
  if (begin == null || end == null) return const [];
  final first = DateTime(begin.year, begin.month, begin.day);
  final last = DateTime(end.year, end.month, end.day);
  if (last.isBefore(first)) return const [];
  final days = <DateTime>[];
  for (var d = first; !d.isAfter(last); d = d.add(const Duration(days: 1))) {
    days.add(d);
  }
  return days;
}

/// Flattens every race across all structures into [ScheduleItem]s.
List<ScheduleItem> allScheduleItems(CompetitionProgramme p) => [
      for (final s in p.structures)
        for (final l in s.levels)
          for (final r in l.races)
            ScheduleItem(
              raceId: r.id,
              raceLabel: s.raceLabel,
              categoryLabel: s.categoryLabel,
              roundType: l.type,
              number: r.number,
              placement: r.placement,
            ),
    ];

bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime placementEnd(RacePlacement p) =>
    p.beginHour.add(Duration(minutes: p.durationMinutes));

/// The earliest free start on a site for [day]: the day at [startHour] when
/// the site is empty, otherwise the latest existing end (append after the
/// last race).
DateTime nextFreeStart({
  required DateTime day,
  required List<RacePlacement> onSiteDay,
  int startHour = scheduleDayStartHour,
}) {
  if (onSiteDay.isEmpty) {
    return DateTime(day.year, day.month, day.day, startHour);
  }
  return onSiteDay
      .map(placementEnd)
      .reduce((a, b) => a.isAfter(b) ? a : b);
}

/// Whether [candidate]'s time range intersects any of [others]. Callers pass
/// only placements on the same site and day; touching ranges (one starts at
/// another's end) do not overlap.
bool overlaps({
  required RacePlacement candidate,
  required Iterable<RacePlacement> others,
}) {
  final cStart = candidate.beginHour;
  final cEnd = placementEnd(candidate);
  for (final o in others) {
    if (cStart.isBefore(placementEnd(o)) && o.beginHour.isBefore(cEnd)) {
      return true;
    }
  }
  return false;
}

/// Returns a copy of [p] with the placement of race [raceId] set (or cleared
/// when [placement] is null), rebuilding the structure tree immutably.
CompetitionProgramme setPlacement(
  CompetitionProgramme p,
  int raceId,
  RacePlacement? placement,
) {
  return p.copyWith(structures: [
    for (final s in p.structures)
      s.copyWith(levels: [
        for (final l in s.levels)
          l.copyWith(races: [
            for (final r in l.races)
              r.id == raceId ? r.copyWith(placement: placement) : r,
          ]),
      ]),
  ]);
}

/// Clears the placement of every race scheduled on [siteId] — used when a site
/// is deleted so no race points at a gone site.
CompetitionProgramme clearPlacementsForSite(
    CompetitionProgramme p, int siteId) {
  return p.copyWith(structures: [
    for (final s in p.structures)
      s.copyWith(levels: [
        for (final l in s.levels)
          l.copyWith(races: [
            for (final r in l.races)
              r.placement?.siteId == siteId
                  ? r.copyWith(placement: null)
                  : r,
          ]),
      ]),
  ]);
}

/// The default day-start when a site×day has no [SiteDayStart] override: 09:00.
const int defaultStartMinutes = 540;

/// A block placed on the timeline with its derived begin/end times.
class ScheduleRow {
  const ScheduleRow({required this.block, required this.begin, required this.end});

  final ScheduleBlock block;
  final DateTime begin;
  final DateTime end;
}

int dayStartMinutes(CompetitionProgramme p, int siteId, DateTime day) {
  for (final s in p.dayStarts) {
    if (s.siteId == siteId && sameDay(s.day, day)) return s.startMinutes;
  }
  return defaultStartMinutes;
}

/// The (site × day) sequence with derived back-to-back times: the day's blocks
/// sorted by `order`, first at the start time, each next right after the
/// previous end.
List<ScheduleRow> scheduleRows(CompetitionProgramme p, int siteId, DateTime day) {
  final blocks = p.blocks
      .where((b) => b.siteId == siteId && sameDay(b.day, day))
      .toList()
    ..sort((a, b) => a.order.compareTo(b.order));
  var cursor = DateTime(day.year, day.month, day.day)
      .add(Duration(minutes: dayStartMinutes(p, siteId, day)));
  final rows = <ScheduleRow>[];
  for (final b in blocks) {
    final end = cursor.add(Duration(minutes: b.durationMinutes));
    rows.add(ScheduleRow(block: b, begin: cursor, end: end));
    cursor = end;
  }
  return rows;
}

/// Races in [p.structures] that no block references, for the unscheduled
/// palette. Sorted by race label then number.
List<ScheduleItem> unscheduledRaces(CompetitionProgramme p) {
  final scheduled = p.blocks
      .where((b) => b.raceId != null)
      .map((b) => b.raceId!)
      .toSet();
  final items = <ScheduleItem>[];
  for (final s in p.structures) {
    for (final l in s.levels) {
      for (final r in l.races) {
        if (scheduled.contains(r.id)) continue;
        items.add(ScheduleItem(
          raceId: r.id,
          raceLabel: s.raceLabel,
          categoryLabel: s.categoryLabel,
          roundType: l.type,
          number: r.number,
        ));
      }
    }
  }
  items.sort((a, b) {
    final byLabel = a.raceLabel.compareTo(b.raceLabel);
    if (byLabel != 0) return byLabel;
    return a.number.compareTo(b.number);
  });
  return items;
}

int _nextOrder(CompetitionProgramme p, int siteId, DateTime day) {
  var max = -1;
  for (final b in p.blocks) {
    if (b.siteId == siteId && sameDay(b.day, day) && b.order > max) {
      max = b.order;
    }
  }
  return max + 1;
}

CompetitionProgramme addRaceBlock(
        CompetitionProgramme p, int blockId, int raceId, int siteId, DateTime day) =>
    p.copyWith(blocks: [
      ...p.blocks,
      ScheduleBlock(
          id: blockId,
          siteId: siteId,
          day: day,
          order: _nextOrder(p, siteId, day),
          raceId: raceId),
    ]);

CompetitionProgramme addManualBlock(CompetitionProgramme p, int blockId,
        String label, int minutes, int siteId, DateTime day) =>
    p.copyWith(blocks: [
      ...p.blocks,
      ScheduleBlock(
          id: blockId,
          siteId: siteId,
          day: day,
          order: _nextOrder(p, siteId, day),
          durationMinutes: minutes,
          manualLabel: label),
    ]);

CompetitionProgramme setBlockDuration(
        CompetitionProgramme p, int blockId, int minutes) =>
    p.copyWith(blocks: [
      for (final b in p.blocks)
        b.id == blockId ? b.copyWith(durationMinutes: minutes) : b,
    ]);

CompetitionProgramme setManualLabel(
        CompetitionProgramme p, int blockId, String label) =>
    p.copyWith(blocks: [
      for (final b in p.blocks)
        b.id == blockId ? b.copyWith(manualLabel: label) : b,
    ]);

CompetitionProgramme _renumber(CompetitionProgramme p, int siteId, DateTime day) {
  final ofDay = p.blocks
      .where((b) => b.siteId == siteId && sameDay(b.day, day))
      .toList()
    ..sort((a, b) => a.order.compareTo(b.order));
  final others = p.blocks
      .where((b) => !(b.siteId == siteId && sameDay(b.day, day)))
      .toList();
  return p.copyWith(blocks: [
    ...others,
    for (var i = 0; i < ofDay.length; i++) ofDay[i].copyWith(order: i),
  ]);
}

CompetitionProgramme removeBlock(CompetitionProgramme p, int blockId) {
  ScheduleBlock? target;
  for (final b in p.blocks) {
    if (b.id == blockId) {
      target = b;
      break;
    }
  }
  if (target == null) return p;
  final remaining = p.copyWith(
      blocks: p.blocks.where((b) => b.id != blockId).toList());
  return _renumber(remaining, target.siteId, target.day);
}

/// Reorders the (site × day) blocks. [oldIndex]/[newIndex] follow the
/// `ReorderableListView.onReorder` convention (newIndex is the pre-removal
/// insert position, so it is decremented when moving downward).
CompetitionProgramme reorderBlocks(
    CompetitionProgramme p, int siteId, DateTime day, int oldIndex, int newIndex) {
  final ofDay = p.blocks
      .where((b) => b.siteId == siteId && sameDay(b.day, day))
      .toList()
    ..sort((a, b) => a.order.compareTo(b.order));
  if (oldIndex < 0 || oldIndex >= ofDay.length) return p;
  var target = newIndex;
  if (target > oldIndex) target -= 1;
  final moved = ofDay.removeAt(oldIndex);
  ofDay.insert(target.clamp(0, ofDay.length), moved);
  final others = p.blocks
      .where((b) => !(b.siteId == siteId && sameDay(b.day, day)))
      .toList();
  return p.copyWith(blocks: [
    ...others,
    for (var i = 0; i < ofDay.length; i++) ofDay[i].copyWith(order: i),
  ]);
}

CompetitionProgramme setDayStart(
    CompetitionProgramme p, int siteId, DateTime day, int startMinutes) {
  final others = p.dayStarts
      .where((s) => !(s.siteId == siteId && sameDay(s.day, day)))
      .toList();
  return p.copyWith(dayStarts: [
    ...others,
    SiteDayStart(siteId: siteId, day: day, startMinutes: startMinutes),
  ]);
}

/// Drops every block and day-start of [siteId] — used when a site is deleted.
CompetitionProgramme clearBlocksForSite(CompetitionProgramme p, int siteId) =>
    p.copyWith(
      blocks: p.blocks.where((b) => b.siteId != siteId).toList(),
      dayStarts: p.dayStarts.where((s) => s.siteId != siteId).toList(),
    );
