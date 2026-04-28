// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'athlete_dto.freezed.dart';
part 'athlete_dto.g.dart';

@freezed
class AthleteDto with _$AthleteDto {
  const factory AthleteDto({
    @JsonKey(name: 'Id') @Default(0) int id,
    @JsonKey(name: 'NumeroLicence') required String licenseeNumber,
    @JsonKey(name: 'Prenom') required String firstName,
    @JsonKey(name: 'Nom') required String lastName,
    @JsonKey(name: 'Sexe') required String gender,
    @JsonKey(name: 'Annee', readValue: _readYear) required int year,
    @JsonKey(name: 'nationaliteCode') required String nationalityCode,
    @JsonKey(name: 'nationaliteLabel') required String nationality,
    @JsonKey(name: 'isValid') required bool isValid,
    @JsonKey(name: 'isLicencie') @Default(false) bool isLicensee,
    @JsonKey(name: 'isInvite') @Default(false) bool isGuest,
  }) = _AthleteDto;

  factory AthleteDto.fromJson(Map<String, dynamic> json) =>
      _$AthleteDtoFromJson(json);
}

Object? _readYear(Map<dynamic, dynamic> map, String key) {
  final raw = map[key];
  if (raw is String) return int.tryParse(raw) ?? 0;
  return raw;
}
