import 'package:freezed_annotation/freezed_annotation.dart';

part 'lane_assignment.freezed.dart';

/// Résultat d'une place, comme `Performance` dans FFSSCompetition V3. [time]
/// est le libellé publié par FFSS, [timeHundredths] sa valeur, qui sert à
/// calculer la place dans la série ([heatPlaces]).
@freezed
abstract class Performance with _$Performance {
  const Performance._();

  const factory Performance({
    String? time,
    String? statusLabel,
    int? timeHundredths,

    /// Le code de disqualification, affiché à côté de « DQ ».
    String? disqualificationCode,
    @Default(false) bool isDisqualified,
    @Default(false) bool isRecord,
    @Default(false) bool isNationalRecord,
  }) = _Performance;

  /// Un statut absent vaut `OK` : FFSS ne le sert qu'en cas d'anomalie.
  bool get isOk {
    final status = statusLabel?.trim();
    return status == null || status.isEmpty || status.toUpperCase() == 'OK';
  }
}

/// Une place (un couloir) d'une course.
@freezed
abstract class LaneAssignment with _$LaneAssignment {
  const LaneAssignment._();

  const factory LaneAssignment({
    /// Id FFSS de la place.
    required int id,
    required int lane,
    @Default(<String>[]) List<String> athletes,
    @Default('') String club,
    String? category,
    @Default(false) bool forfeit,
    @Default(false) bool isRelay,
    Performance? performance,
  }) = _LaneAssignment;

  bool get isEmpty => athletes.isEmpty;
}

/// La place de chaque nageur dans sa série (id de la place → place), calculée
/// sur les temps de la série : FFSS publie un rang par catégorie, alors qu'une
/// série mêle souvent plusieurs catégories. Un ex aequo partage la place et
/// saute la suivante (1, 2, 2, 4). Sans temps, disqualifié ou avec un statut
/// autre que OK : pas de place.
Map<int, int> heatPlaces(Iterable<LaneAssignment> lanes) {
  final timed = [
    for (final lane in lanes)
      if (lane.performance case Performance(
        :final timeHundredths?,
        isOk: true,
        isDisqualified: false,
      ))
        (id: lane.id, time: timeHundredths),
  ]..sort((a, b) => a.time.compareTo(b.time));
  final places = <int, int>{};
  for (var i = 0; i < timed.length; i++) {
    final tie = i > 0 && timed[i].time == timed[i - 1].time;
    places[timed[i].id] = tie ? places[timed[i - 1].id]! : i + 1;
  }
  return places;
}
