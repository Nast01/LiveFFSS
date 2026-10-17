import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/domain/home_partition.dart';
import 'package:live_ffss_v2/features/home/favorites.dart';
import 'package:live_ffss_v2/features/home/home_providers.dart';
import 'package:live_ffss_v2/features/home/home_view.dart';
import 'package:live_ffss_v2/features/shell/active_competition.dart';

/// La compétition que suivent les onglets : celle qu'on a choisie, sinon la
/// première du carrousel « EN DIRECT » (un favori s'il y en a un en direct),
/// sinon aucune. `fetched` sert quand la compétition choisie n'est ni dans la
/// liste ni gardée en mémoire : c'est celle qu'on a relue par son id.
CompetitionSummary? currentCompetition({
  required List<CompetitionSummary> competitions,
  required ActiveSelection? selection,
  CompetitionSummary? fetched,
  required Set<int> favorites,
  required DateTime today,
}) {
  if (selection != null) {
    for (final c in competitions) {
      if (c.id == selection.id) return c;
    }
    if (selection.summary case final summary?) return summary;
    if (fetched != null && fetched.id == selection.id) return fetched;
  }
  final live = orderLive(
    partitionHome(competitions, today).live,
    favorites: favorites,
  );
  return live.isEmpty ? null : live.first;
}

final currentCompetitionProvider = Provider<CompetitionSummary?>((ref) {
  final home = ref.watch(homeCompetitionsProvider);
  final competitions = home.value;
  final selection = ref.watch(activeCompetitionProvider).value;
  // On attend la fin du chargement de l'accueil : sinon toute compétition de
  // la liste déclencherait une requête. Si l'accueil échoue, la relecture par
  // id reste possible. Un échec ou une attente de la relecture laisse le choix
  // par défaut.
  final needsFetch =
      selection != null &&
      selection.summary == null &&
      !home.isLoading &&
      !(competitions?.any((c) => c.id == selection.id) ?? false);
  return currentCompetition(
    competitions: competitions ?? const [],
    selection: selection,
    fetched: needsFetch
        ? ref.watch(competitionByIdProvider(selection.id)).value
        : null,
    favorites: ref.watch(favoritesProvider).value ?? const {},
    today: ref.watch(clockProvider)(),
  );
});
