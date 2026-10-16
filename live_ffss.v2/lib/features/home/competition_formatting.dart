import 'package:intl/intl.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/domain/discipline.dart';
import 'package:live_ffss_v2/domain/gender.dart';
import 'package:live_ffss_v2/domain/home_partition.dart';
import 'package:live_ffss_v2/domain/now_running.dart';

extension CompetitionFormatting on CompetitionSummary {
  /// « 27 mars 2026 », « 27 – 29 mars 2026 », « 30 mars – 2 avr. 2026 »,
  /// « 30 déc. 2026 – 2 janv. 2027 ».
  String dateRangeLabel(String locale) {
    final full = DateFormat('d MMMM y', locale);
    final short = DateFormat('d MMM', locale);
    final shortYear = DateFormat('d MMM y', locale);
    if (startDate == endDate) return full.format(startDate);
    if (startDate.year == endDate.year && startDate.month == endDate.month) {
      return '${startDate.day} – ${full.format(endDate)}';
    }
    if (startDate.year == endDate.year) {
      return '${short.format(startDate)} – ${shortYear.format(endDate)}';
    }
    return '${shortYear.format(startDate)} – ${shortYear.format(endDate)}';
  }

  /// « Jour 1/3 » : nul hors de la compétition, et pour une compétition d'un
  /// seul jour, où il n'apprendrait rien.
  ({int current, int total})? dayOfCompetition(DateTime today) {
    final day = dayOf(today);
    if (day.isBefore(startDate) || day.isAfter(endDate)) return null;
    final total = _daysBetween(startDate, endDate) + 1;
    if (total <= 1) return null;
    return (current: _daysBetween(startDate, day) + 1, total: total);
  }

  String disciplineLabel(AppLocalizations l10n) {
    final flat = disciplines.contains(Discipline.flatWater);
    final coastal = disciplines.contains(Discipline.coastal);
    if (flat && coastal) return l10n.disciplineMixed;
    return coastal ? l10n.disciplineCoastal : l10n.disciplineFlatWater;
  }
}

/// En jours civils : un écart en heures se trompe d'un jour au changement
/// d'heure.
int _daysBetween(DateTime from, DateTime to) => DateTime.utc(
  to.year,
  to.month,
  to.day,
).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

String shortDayLabel(DateTime day) => '${day.day}';

String monthLabel(DateTime day, String locale) =>
    DateFormat('MMM', locale).format(day).toUpperCase();

String genderLabel(Gender gender, AppLocalizations l10n) => switch (gender) {
  Gender.female => l10n.genderFemale,
  Gender.male => l10n.genderMale,
  Gender.mixed => l10n.genderMixed,
};

/// « 200 m Obstacles · Dames · Série 4/10 », sans les morceaux inconnus.
String heatLine(NowRunning now, AppLocalizations l10n) => [
  if (now.heat.raceName.isNotEmpty) now.heat.raceName,
  if (now.heat.gender case final gender?) genderLabel(gender, l10n),
  if (now.total > 1)
    l10n.heatOfTotal(now.position, now.total)
  else if (now.heat.name.isNotEmpty)
    now.heat.name,
].join(' · ');
