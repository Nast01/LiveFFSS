// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/data/ffss/dtos/epreuve_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/json_readers.dart';

part 'participant_dto.freezed.dart';
part 'participant_dto.g.dart';

/// Un participant de `competition/evenement/:id/participants`. Ni `categories`
/// ni numéro de licence : seuls l'identité sportive, les liens vers le licencié
/// et le club, et les engagements sont lus.
@freezed
abstract class ParticipantDto with _$ParticipantDto {
  const factory ParticipantDto({
    @JsonKey(name: 'Id', readValue: readInt) int? id,
    @JsonKey(name: 'Prenom') String? firstName,
    @JsonKey(name: 'Nom') String? lastName,
    @JsonKey(name: 'Sexe') String? gender,
    @JsonKey(name: 'clubLabel') String? club,
    @JsonKey(name: 'idClub', readValue: readInt) int? clubId,
    @JsonKey(name: 'idLicencie', readValue: readInt) int? licenseeId,
    @JsonKey(name: 'isInvite') bool? isGuest,
    // Lignes brutes : une ligne mal typée est écartée seule par le mapper.
    @JsonKey(name: 'engagements') @Default(<Object?>[]) List<Object?> entries,
  }) = _ParticipantDto;

  factory ParticipantDto.fromJson(Map<String, dynamic> json) =>
      _$ParticipantDtoFromJson(json);
}

@freezed
abstract class ParticipantEngagementDto with _$ParticipantEngagementDto {
  const factory ParticipantEngagementDto({
    @JsonKey(name: 'id', readValue: readInt) int? id,
    @JsonKey(name: 'categorie', readValue: readMap)
    ParticipantCategorieDto? category,
    @JsonKey(name: 'epreuve', readValue: readMap) EpreuveDto? event,
  }) = _ParticipantEngagementDto;

  factory ParticipantEngagementDto.fromJson(Map<String, dynamic> json) =>
      _$ParticipantEngagementDtoFromJson(json);
}

@freezed
abstract class ParticipantCategorieDto with _$ParticipantCategorieDto {
  const factory ParticipantCategorieDto({
    @JsonKey(name: 'label') String? label,
  }) = _ParticipantCategorieDto;

  factory ParticipantCategorieDto.fromJson(Map<String, dynamic> json) =>
      _$ParticipantCategorieDtoFromJson(json);
}
