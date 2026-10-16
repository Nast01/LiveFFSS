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
/// sinon aucune.
CompetitionSummary? currentCompetition({
  required List<CompetitionSummary> competitions,
  required ActiveSelection? selection,
  required Set<int> favorites,
  required DateTime today,
}) {
  if (selection != null) {
    for (final c in competitions) {
      if (c.id == selection.id) return c;
    }
    if (selection.summary case final summary?) return summary;
  }
  final live = orderLive(
    partitionHome(competitions, today).live,
    favorites: favorites,
  );
  return live.isEmpty ? null : live.first;
}

final currentCompetitionProvider = Provider<CompetitionSummary?>((ref) {
  return currentCompetition(
    competitions: ref.watch(homeCompetitionsProvider).value ?? const [],
    selection: ref.watch(activeCompetitionProvider).value,
    favorites: ref.watch(favoritesProvider).value ?? const {},
    today: ref.watch(clockProvider)(),
  );
});
