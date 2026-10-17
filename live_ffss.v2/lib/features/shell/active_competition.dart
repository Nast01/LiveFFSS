import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/repositories/competition_repository.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';

/// La compétition que suivent les onglets Programme, Live et Résultats.
///
/// Seul l'id est enregistré. Le résumé n'est gardé qu'en mémoire, pour une
/// compétition ouverte depuis la recherche et absente de la liste de
/// l'accueil. Après un redémarrage, une telle compétition est relue par son id
/// (`competitionByIdProvider`).
typedef ActiveSelection = ({int id, CompetitionSummary? summary});

class ActiveCompetitionNotifier extends AsyncNotifier<ActiveSelection?> {
  static const storageKey = 'active_competition';

  @override
  Future<ActiveSelection?> build() async {
    final id = int.tryParse(
      await ref.watch(localStoreProvider).read(storageKey) ?? '',
    );
    return id == null ? null : (id: id, summary: null);
  }

  Future<void> select(CompetitionSummary competition) async {
    state = AsyncData((id: competition.id, summary: competition));
    await ref
        .read(localStoreProvider)
        .write(storageKey, competition.id.toString());
  }

  /// Pour une page ouverte par son id (lien profond) : sans effet si cette
  /// compétition est déjà la compétition active, pour ne pas perdre son résumé.
  Future<void> ensure(int id) async {
    if (state.value?.id == id) return;
    state = AsyncData((id: id, summary: null));
    await ref.read(localStoreProvider).write(storageKey, id.toString());
  }
}

final activeCompetitionProvider =
    AsyncNotifierProvider<ActiveCompetitionNotifier, ActiveSelection?>(
      ActiveCompetitionNotifier.new,
    );

/// Relit une compétition par son id : le résumé n'est pas enregistré, donc une
/// compétition absente de l'accueil doit être redemandée après un redémarrage.
final competitionByIdProvider = FutureProvider.family<CompetitionSummary?, int>(
  (ref, id) => ref.watch(competitionRepositoryProvider).getCompetition(id),
);
