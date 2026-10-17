import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/lane_assignment.dart';
import 'package:live_ffss_v2/domain/run_status.dart';

/// V3 ne publie le complément de qualification (`QFA`, `QFB`) qu'une fois
/// toutes les séries du tour validées : une course terminée peut encore
/// changer, mais bien moins vite qu'une course en cours.
const Duration finishedHeatRefresh = Duration(minutes: 2);

/// Les courses dont les places sont à relire à ce tour. [finishedReadAt] dit,
/// par course, quand ses places ont été lues pour la dernière fois alors
/// qu'elle était terminée.
Set<int> heatsToRefresh(
  List<Heat> heats,
  Map<int, DateTime> finishedReadAt,
  DateTime now,
) => {
  for (final heat in heats)
    if (_isDue(heat, finishedReadAt[heat.id], now)) heat.id,
};

bool _isDue(Heat heat, DateTime? finishedReadAt, DateTime now) =>
    heat.status != RunStatus.finished ||
    finishedReadAt == null ||
    now.difference(finishedReadAt) >= finishedHeatRefresh;

/// Une place en échec garde sa dernière valeur connue : des nageurs qui
/// disparaissent toutes les 30 s seraient pires qu'une valeur un peu vieille.
Map<int, LaneAssignment?> mergeLanes(
  Map<int, LaneAssignment?> previous,
  Map<int, LaneAssignment?> fetched,
  Iterable<int> requested,
) => {
  ...previous,
  for (final id in requested)
    if (fetched.containsKey(id)) id: fetched[id],
};
