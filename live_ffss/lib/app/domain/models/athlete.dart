// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/club.dart';

part 'athlete.freezed.dart';
part 'athlete.g.dart';

enum Gender { male, female, mixed, unknown }

@freezed
class Athlete with _$Athlete {
  const factory Athlete({
    required int id,
    required String licenseeNumber,
    required String firstName,
    required String lastName,
    required Gender gender,
    required int year,
    required String nationalityCode,
    required String nationality,
    required bool isValid,
    @Default(false) bool isLicensee,
    @Default(false) bool isGuest,
    // Engagement-scoped: seed performance + club label + substitute flag.
    // Populated only when the athlete comes from the engagement endpoint.
    @Default(0) int performanceTime,
    @Default('') String performanceLabel,
    @Default(0) int clubId,
    @Default('') String clubLabel,
    @Default(false) bool isSubstitute,
    // Back-reference, populated by ClubMapper or by join logic.
    // Excluded from JSON to avoid Club <-> Athlete recursion.
    @JsonKey(includeFromJson: false, includeToJson: false) Club? club,
  }) = _Athlete;

  factory Athlete.fromJson(Map<String, dynamic> json) =>
      _$AthleteFromJson(json);
}
