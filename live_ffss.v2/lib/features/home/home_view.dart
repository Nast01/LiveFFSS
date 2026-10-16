import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/domain/discipline.dart';
import 'package:live_ffss_v2/domain/home_partition.dart';

enum HomeFilter { all, flatWater, coastal, favorites }

/// Une compétition mixte contient les deux disciplines : elle passe donc les
/// filtres Eau plate et Côtier.
bool matchesFilter(
  CompetitionSummary competition,
  HomeFilter filter,
  Set<int> favorites,
) => switch (filter) {
  HomeFilter.all => true,
  HomeFilter.flatWater => competition.disciplines.contains(
    Discipline.flatWater,
  ),
  HomeFilter.coastal => competition.disciplines.contains(Discipline.coastal),
  HomeFilter.favorites => favorites.contains(competition.id),
};

/// L'ordre du carrousel « EN DIRECT » : les favoris, puis la compétition
/// active, puis les autres par date de début et par nom.
List<CompetitionSummary> orderLive(
  List<CompetitionSummary> live, {
  required Set<int> favorites,
  int? activeId,
}) {
  int rank(CompetitionSummary c) =>
      favorites.contains(c.id) ? 0 : (c.id == activeId ? 1 : 2);
  return [...live]..sort((a, b) {
    final byRank = rank(a).compareTo(rank(b));
    if (byRank != 0) return byRank;
    final byStart = a.startDate.compareTo(b.startDate);
    return byStart != 0 ? byStart : a.name.compareTo(b.name);
  });
}

const int upcomingPreviewCount = 5;

/// Ce que l'accueil affiche.
class HomeView {
  const HomeView({
    required this.live,
    required this.upcoming,
    required this.upcomingCount,
    required this.recent,
  });

  final List<CompetitionSummary> live;

  /// Les [upcomingPreviewCount] premières ; « Tout voir » montre le reste.
  final List<CompetitionSummary> upcoming;
  final int upcomingCount;
  final List<CompetitionSummary> recent;

  bool get isEmpty => live.isEmpty && upcomingCount == 0 && recent.isEmpty;
}

HomeView buildHomeView({
  required List<CompetitionSummary> competitions,
  required DateTime today,
  required HomeFilter filter,
  required Set<int> favorites,
  int? activeId,
}) {
  final partition = partitionHome([
    for (final c in competitions)
      if (matchesFilter(c, filter, favorites)) c,
  ], today);
  return HomeView(
    live: orderLive(partition.live, favorites: favorites, activeId: activeId),
    upcoming: partition.upcoming.take(upcomingPreviewCount).toList(),
    upcomingCount: partition.upcoming.length,
    recent: partition.recent,
  );
}
