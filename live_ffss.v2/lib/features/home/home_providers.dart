import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/repositories/competition_repository.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/domain/home_partition.dart';
import 'package:live_ffss_v2/features/home/favorites.dart';
import 'package:live_ffss_v2/features/home/home_view.dart';
import 'package:live_ffss_v2/features/shell/active_competition.dart';

/// Une compétition de plusieurs jours qui a commencé avant la fenêtre de 14
/// jours mais s'est terminée dedans, ou qui court encore, doit revenir :
/// `partitionHome` garde la vraie fenêtre de 14 jours.
const int fetchMarginDays = 31;

/// Les compétitions de l'accueil. On part d'aujourd'hui − 45 jours et non du
/// début de saison : sinon, au 1er octobre, les compétitions terminées la
/// semaine d'avant disparaîtraient de « Terminées récemment ».
final homeCompetitionsProvider = FutureProvider<List<CompetitionSummary>>((
  ref,
) {
  final today = dayOf(ref.watch(clockProvider)());
  return ref
      .watch(competitionRepositoryProvider)
      .getCompetitionsFrom(
        DateTime(
          today.year,
          today.month,
          today.day - (recentWindowDays + fetchMarginDays),
        ),
      );
});

/// Toutes les compétitions favorites, par date de début. Celles de la liste de
/// l'accueil en viennent ; les autres, plus anciennes que sa fenêtre de 45
/// jours, sont relues par leur id. Un favori illisible est écarté seul.
final favoriteCompetitionsProvider =
    FutureProvider.autoDispose<List<CompetitionSummary>>((ref) async {
      final ids = await ref.watch(favoritesProvider.future);
      if (ids.isEmpty) return const [];
      List<CompetitionSummary> home;
      try {
        home = await ref.watch(homeCompetitionsProvider.future);
      } on AppException {
        home = const [];
      }
      final known = {
        for (final c in home)
          if (ids.contains(c.id)) c.id: c,
      };
      final repository = ref.read(competitionRepositoryProvider);
      Future<CompetitionSummary?> fetch(int id) async {
        try {
          return await repository.getCompetition(id);
        } on AppException {
          return null;
        }
      }

      final fetched = await Future.wait([
        for (final id in ids)
          if (!known.containsKey(id)) fetch(id),
      ]);
      return [...known.values, ...fetched.nonNulls]..sort((a, b) {
        final byDate = a.startDate.compareTo(b.startDate);
        return byDate != 0 ? byDate : a.name.compareTo(b.name);
      });
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
