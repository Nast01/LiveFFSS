import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/repositories/competition_repository.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/domain/home_partition.dart';
import 'package:live_ffss_v2/features/home/favorites.dart';
import 'package:live_ffss_v2/features/home/home_view.dart';
import 'package:live_ffss_v2/features/shell/active_competition.dart';

/// Les compétitions de l'accueil. On part d'aujourd'hui − 14 jours et non du
/// début de saison : sinon, au 1er octobre, les compétitions terminées la
/// semaine d'avant disparaîtraient de « Terminées récemment ».
final homeCompetitionsProvider = FutureProvider<List<CompetitionSummary>>((
  ref,
) {
  final today = dayOf(ref.watch(clockProvider)());
  return ref
      .watch(competitionRepositoryProvider)
      .getCompetitionsFrom(
        DateTime(today.year, today.month, today.day - recentWindowDays),
      );
});

class HomeFilterNotifier extends Notifier<HomeFilter> {
  @override
  HomeFilter build() => HomeFilter.all;

  void select(HomeFilter filter) => state = filter;
}

final homeFilterProvider = NotifierProvider<HomeFilterNotifier, HomeFilter>(
  HomeFilterNotifier.new,
);

/// Nulle tant qu'aucune liste n'a été chargée. Après un rafraîchissement en
/// échec, elle garde la dernière liste : au bord d'un bassin, un écran qui se
/// vide à chaque coupure serait pire que des données vieilles de 30 s.
final homeViewProvider = Provider<HomeView?>((ref) {
  final competitions = ref.watch(homeCompetitionsProvider).value;
  if (competitions == null) return null;
  return buildHomeView(
    competitions: competitions,
    today: ref.watch(clockProvider)(),
    filter: ref.watch(homeFilterProvider),
    favorites: ref.watch(favoritesProvider).value ?? const {},
    activeId: ref.watch(activeCompetitionProvider).value?.id,
  );
});
