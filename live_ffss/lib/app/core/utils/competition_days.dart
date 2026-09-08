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

/// Same calendar date, whatever the time of day carried alongside.
bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
