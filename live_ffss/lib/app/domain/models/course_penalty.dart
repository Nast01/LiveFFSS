// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'course_penalty.freezed.dart';
part 'course_penalty.g.dart';

/// Why a competitor is out of the ranking. `unknown` is the forward-compatible
/// arm: a kind written by a later build must not fail the whole programme's
/// decode.
enum CoursePenaltyKind { forfeit, disqualified, unknown }

/// A competitor out of the ranking. [code] is the disqualification code the
/// referee gives; it stays empty for a forfeit.
@freezed
class CoursePenalty with _$CoursePenalty {
  const factory CoursePenalty({
    // An entry (see `competitor.dart`). Inherited JSON key.
    @JsonKey(name: 'athleteId') required int competitorId,
    @JsonKey(unknownEnumValue: CoursePenaltyKind.unknown)
    required CoursePenaltyKind kind,
    @Default('') String code,
  }) = _CoursePenalty;

  factory CoursePenalty.fromJson(Map<String, dynamic> json) =>
      _$CoursePenaltyFromJson(json);
}
