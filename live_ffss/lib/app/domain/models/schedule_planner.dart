import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/race_placement.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';

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
    required this.placement,
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
