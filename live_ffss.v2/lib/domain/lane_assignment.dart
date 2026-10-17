import 'package:freezed_annotation/freezed_annotation.dart';

part 'lane_assignment.freezed.dart';

/// Résultat d'une place, comme `Performance` dans FFSSCompetition V3. Les
/// libellés sont ceux que FFSS publie : l'app ne calcule aucun rang.
@freezed
abstract class Performance with _$Performance {
  const Performance._();

  const factory Performance({
    String? time,
    String? statusLabel,
    String? rankLabel,
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
