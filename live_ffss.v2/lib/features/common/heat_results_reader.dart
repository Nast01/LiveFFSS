import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/data/repositories/result_repository.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/race_result.dart';

/// Comme pour les places : sans borne, une page de séries ouvrirait autant de
/// connexions en parallèle.
const int maxConcurrentHeatResults = 6;

/// Les résultats des séries de [heats] (id de course → résultats par
/// engagement), lus sur `serie/:id` pour tout le monde : chronos, statut et
/// temps du juge des saisies faites depuis l'app. Une course sans série n'a
/// rien à lire. Une série en échec manque à la réponse : l'affichage garde
/// ce qu'il en avait, et ne fait jamais échouer la page. [alive] faux arrête
/// la lecture (page fermée).
Future<Map<int, Map<int, RaceResult>>> readHeatResults(
  ResultRepository repository,
  Iterable<Heat> heats, {
  required bool Function() alive,
}) async {
  final results = <int, Map<int, RaceResult>>{};
  final pending = [
    for (final heat in heats)
      if (heat.seriesId case final seriesId?) (heat: heat.id, series: seriesId),
  ].iterator;
  // Les travailleurs tirent dans le même itérateur : `moveNext` + `current`
  // sans `await` entre les deux est sûr, le code n'est pas préemptif.
  Future<void> worker() async {
    while (alive() && pending.moveNext()) {
      final next = pending.current;
      try {
        results[next.heat] = await repository.getHeatResults(next.series);
      } on AppException {
        // Rien de neuf pour cette série.
      }
    }
  }

  await Future.wait([
    for (var i = 0; i < maxConcurrentHeatResults; i++) worker(),
  ]);
  return results;
}
