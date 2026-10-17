import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/live.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/run_status.dart';

part 'now_running.freezed.dart';

enum NowRunningKind { now, next }

/// La série à afficher sur la carte en direct, avec son rang parmi les séries
/// de la même épreuve et du même tour (« Série 4/10 »).
@freezed
abstract class NowRunning with _$NowRunning {
  const factory NowRunning({
    required Heat heat,
    required NowRunningKind kind,
    required int position,
    required int total,
  }) = _NowRunning;
}

/// La série à afficher sur la carte en direct :
/// 1. la dernière série « En cours », d'après son heure de début prévue
///    (« MAINTENANT ») ;
/// 2. sinon la prochaine qui n'a pas commencé, « En attente » ou en
///    chambre d'appel (« À SUIVRE ») ;
/// 3. sinon rien.
///
/// Le rang (« Série 4/10 ») vient de [heatPosition].
NowRunning? nowRunning(List<Meeting> meetings) {
  final entries = <LiveEntry>[
    for (final meeting in meetings)
      for (final item in meeting.items)
        for (final heat in item.heats)
          LiveEntry(meeting: meeting, item: item, heat: heat),
  ];

  final early = DateTime(0);
  final late = DateTime(9999);

  LiveEntry? current;
  for (final entry in entries) {
    if (entry.heat.status != RunStatus.inProgress) continue;
    final start = entry.heat.plannedStart ?? early;
    if (current == null ||
        !start.isBefore(current.heat.plannedStart ?? early)) {
      current = entry;
    }
  }

  var kind = NowRunningKind.now;
  if (current == null) {
    kind = NowRunningKind.next;
    for (final entry in entries) {
      final status = entry.heat.status;
      if (status != RunStatus.waiting && status != RunStatus.marshalling) {
        continue;
      }
      final start = entry.heat.plannedStart ?? late;
      if (current == null ||
          start.isBefore(current.heat.plannedStart ?? late)) {
        current = entry;
      }
    }
  }
  if (current == null) return null;

  final (:position, :total) = heatPosition(meetings, current);
  return NowRunning(
    heat: current.heat,
    kind: kind,
    position: position,
    total: total,
  );
}
