import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';

/// La compétition que suivent les onglets Programme, Live et Résultats.
///
/// Seul l'id est enregistré. Le résumé n'est gardé qu'en mémoire, pour une
/// compétition ouverte depuis la recherche et absente de la liste de
/// l'accueil. Après un redémarrage, une telle compétition retombe sur le choix
/// par défaut : le lot 2 la relira par son id.
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
}

final activeCompetitionProvider =
    AsyncNotifierProvider<ActiveCompetitionNotifier, ActiveSelection?>(
      ActiveCompetitionNotifier.new,
    );
