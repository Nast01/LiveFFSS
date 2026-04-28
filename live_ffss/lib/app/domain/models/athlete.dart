import 'package:freezed_annotation/freezed_annotation.dart';

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
  }) = _Athlete;

  factory Athlete.fromJson(Map<String, dynamic> json) =>
      _$AthleteFromJson(json);
}
