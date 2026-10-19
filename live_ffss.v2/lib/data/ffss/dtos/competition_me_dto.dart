// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/data/ffss/dtos/json_readers.dart';

part 'competition_me_dto.freezed.dart';
part 'competition_me_dto.g.dart';

/// La réponse de `competition/evenement/:id/me`. `licencie`, `officiel` et
/// `referent_sportif` restent bruts : chacun se décode seul, pour qu'un objet
/// mal typé ne coûte pas les autres rôles.
@freezed
abstract class CompetitionMeDto with _$CompetitionMeDto {
  const factory CompetitionMeDto({
    // Hors liste, des rôles lus vides, donc `public` : le reste de la réponse
    // reste lu.
    @JsonKey(readValue: readList) @Default(<Object?>[]) List<Object?> roles,
    @JsonKey(name: 'licencie', readValue: readMap) Object? licensee,
    @JsonKey(name: 'officiel', readValue: readMap) Object? official,
    @JsonKey(name: 'referent_sportif', readValue: readList)
    @Default(<Object?>[])
    List<Object?> refereeClubs,
  }) = _CompetitionMeDto;

  factory CompetitionMeDto.fromJson(Map<String, dynamic> json) =>
      _$CompetitionMeDtoFromJson(json);
}

@freezed
abstract class LicencieDto with _$LicencieDto {
  const factory LicencieDto({
    @JsonKey(name: 'id', readValue: readInt) int? id,
  }) = _LicencieDto;

  factory LicencieDto.fromJson(Map<String, dynamic> json) =>
      _$LicencieDtoFromJson(json);
}

@freezed
abstract class OfficialRoleDto with _$OfficialRoleDto {
  const factory OfficialRoleDto({
    @JsonKey(name: 'niveau') String? level,
    @JsonKey(name: 'niveauLabel') String? levelLabel,
    @JsonKey(name: 'principal') bool? principal,
  }) = _OfficialRoleDto;

  factory OfficialRoleDto.fromJson(Map<String, dynamic> json) =>
      _$OfficialRoleDtoFromJson(json);
}

@freezed
abstract class ClubRefDto with _$ClubRefDto {
  const factory ClubRefDto({
    @JsonKey(name: 'id', readValue: readInt) int? id,
    @JsonKey(name: 'label') String? label,
  }) = _ClubRefDto;

  factory ClubRefDto.fromJson(Map<String, dynamic> json) =>
      _$ClubRefDtoFromJson(json);
}
