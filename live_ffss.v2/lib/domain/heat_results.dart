import 'package:live_ffss_v2/domain/lane_assignment.dart';
import 'package:live_ffss_v2/domain/race_result.dart';

/// Vrai si la place dit déjà son issue : un temps publié, une DQ, un statut
/// autre que OK ou un forfait.
bool hasLaneOutcome(LaneAssignment lane) {
  final performance = lane.performance;
  return lane.forfeit == true ||
      (performance != null &&
          (performance.isDisqualified ||
              !performance.isOk ||
              performance.timeHundredths != null ||
              (performance.time?.trim().isNotEmpty ?? false)));
}

/// Les places de [lanes] complétées par les résultats de leur série
/// ([results], par engagement, lus sur `serie/:id`). La place ne porte un
/// résultat que s'il lui a été rattaché à sa création : une DQ, un forfait ou
/// un temps du juge posés sur un résultat non rattaché ne se lisent que sur
/// la série. Ce que la place dit déjà l'emporte. Le statut 3 n'est que la
/// valeur de repli du site pour un `statut` omis, pas une décision.
List<LaneAssignment> withHeatResults(
  List<LaneAssignment> lanes,
  Map<int, RaceResult> results,
) => [
  for (final lane in lanes)
    if (results[lane.entryId] case final result? when !hasLaneOutcome(lane))
      _withResult(lane, result)
    else
      lane,
];

LaneAssignment _withResult(LaneAssignment lane, RaceResult result) {
  final performance = lane.performance ?? const Performance();
  final time = result.time;
  if (result.status == statusDisqualified) {
    final code = result.complement.trim();
    return lane.copyWith(
      performance: performance.copyWith(
        statusLabel: 'DQ',
        isDisqualified: true,
        disqualificationCode: code.isEmpty ? null : code,
      ),
    );
  }
  // Sans performance, la place s'affiche « Forfait » comme un forfait lu sur
  // l'engagement.
  if (result.status == statusForfeit) {
    return lane.copyWith(forfeit: true, performance: null);
  }
  if (result.status == statusOk && time != null && time > unreadableJudgeTime) {
    return lane.copyWith(
      performance: performance.copyWith(
        time: ffssTimeLabel(time),
        timeHundredths: time,
      ),
    );
  }
  return lane;
}

/// `00'44"86` : un temps comme FFSS le publie sur une place.
String ffssTimeLabel(int hundredths) {
  String two(int value) => value.toString().padLeft(2, '0');
  return "${two(hundredths ~/ 6000)}'${two(hundredths % 6000 ~/ 100)}"
      '"${two(hundredths % 100)}';
}

/// Les chronos de chaque engagement, pour `manualTimesOfLanes`.
Map<int, List<int?>> chronosOf(Map<int, RaceResult> results) => {
  for (final MapEntry(:key, :value) in results.entries) key: value.chronos,
};
