import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/features/shell/active_competition.dart';
import 'package:live_ffss_v2/features/shell/current_competition.dart';

/// La compétition d'une page de Mon espace : celle des onglets si c'est
/// elle (lue sans être suivie : la liste de l'accueil, relue, ne doit rien
/// relancer), sinon relue par son id. Elle dit si les résultats se lisent
/// ([isCoastalOnly]).
final spaceCompetitionProvider = FutureProvider.autoDispose
    .family<CompetitionSummary, int>((ref, competitionId) async {
      final current = ref.read(currentCompetitionProvider);
      if (current != null && current.id == competitionId) return current;
      final competition = await ref.watch(
        competitionByIdProvider(competitionId).future,
      );
      if (competition == null) {
        throw NotFoundException('competition $competitionId');
      }
      return competition;
    });

/// Une compétition en échec est relue au rafraîchissement d'une page qui
/// en dépend.
void retryFailedSpaceCompetition(
  ProviderContainer container,
  int competitionId,
) {
  final competition = spaceCompetitionProvider(competitionId);
  if (container.exists(competition) && container.read(competition).hasError) {
    container.invalidate(competition);
  }
}
