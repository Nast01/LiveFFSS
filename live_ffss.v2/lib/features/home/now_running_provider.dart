import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/domain/now_running.dart';
import 'package:live_ffss_v2/features/programme/programme_providers.dart';

/// La série à afficher pour une compétition en direct. Tirée du programme,
/// sans requête ni minuterie propres : la carte et l'onglet Programme d'une
/// même compétition partagent ainsi une seule lecture toutes les 30 s. Libéré
/// dès que sa carte n'est plus affichée (`autoDispose`), ce qui libère aussi
/// le programme si rien d'autre ne l'écoute.
final nowRunningProvider = FutureProvider.autoDispose.family<NowRunning?, int>((
  ref,
  competitionId,
) async {
  final programme = await ref.watch(programmeProvider(competitionId).future);
  return nowRunning(programme.meetings);
});
