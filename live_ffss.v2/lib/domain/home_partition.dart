import 'package:live_ffss_v2/domain/competition_summary.dart';

/// Les compétitions terminées depuis au plus ce nombre de jours restent sur
/// l'accueil.
const int recentWindowDays = 14;

/// Minuit local du jour de [moment].
DateTime dayOf(DateTime moment) =>
    DateTime(moment.year, moment.month, moment.day);

/// Les trois groupes de l'accueil.
class HomePartition {
  const HomePartition({
    required this.live,
    required this.upcoming,
    required this.recent,
  });

  final List<CompetitionSummary> live;
  final List<CompetitionSummary> upcoming;
  final List<CompetitionSummary> recent;
}

/// Découpe [competitions] par rapport au jour de [today] :
/// - en direct : début ≤ aujourd'hui ≤ fin, par date de début puis par nom ;
/// - à venir : début > aujourd'hui, même tri ;
/// - terminées récemment : fin dans les [recentWindowDays] jours précédents,
///   de la plus récente à la plus ancienne.
///
/// Les jours sont reconstruits avec `DateTime(y, m, d - n)` plutôt qu'en
/// soustrayant une durée : au changement d'heure, 14 × 24 h depuis minuit ne
/// retombent pas sur minuit.
HomePartition partitionHome(
  List<CompetitionSummary> competitions,
  DateTime today,
) {
  final day = dayOf(today);
  final recentFrom = DateTime(day.year, day.month, day.day - recentWindowDays);

  final live = <CompetitionSummary>[];
  final upcoming = <CompetitionSummary>[];
  final recent = <CompetitionSummary>[];
  for (final c in competitions) {
    if (c.startDate.isAfter(day)) {
      upcoming.add(c);
    } else if (!c.endDate.isBefore(day)) {
      live.add(c);
    } else if (!c.endDate.isBefore(recentFrom)) {
      recent.add(c);
    }
  }

  int byStart(CompetitionSummary a, CompetitionSummary b) {
    final order = a.startDate.compareTo(b.startDate);
    return order != 0 ? order : a.name.compareTo(b.name);
  }

  live.sort(byStart);
  upcoming.sort(byStart);
  recent.sort((a, b) {
    final order = b.endDate.compareTo(a.endDate);
    return order != 0 ? order : a.name.compareTo(b.name);
  });
  return HomePartition(live: live, upcoming: upcoming, recent: recent);
}
