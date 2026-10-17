import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/data/repositories/meeting_repository.dart';
import 'package:live_ffss_v2/domain/now_running.dart';

/// L'API ne pousse rien : la carte en direct se relit à ce rythme.
const Duration nowRunningRefresh = Duration(seconds: 30);

/// La série à afficher pour une compétition en direct. Libéré dès que sa
/// carte n'est plus affichée (`autoDispose`), ce qui annule la minuterie :
/// aucun appel ne part pour une carte que personne ne regarde.
final nowRunningProvider = FutureProvider.autoDispose.family<NowRunning?, int>((
  ref,
  competitionId,
) async {
  final timer = Timer(nowRunningRefresh, ref.invalidateSelf);
  ref.onDispose(timer.cancel);
  final programme = await ref
      .watch(meetingRepositoryProvider)
      .getProgramme(competitionId);
  return nowRunning(programme.meetings);
});
