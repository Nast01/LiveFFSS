// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/data/ffss/dtos/json_readers.dart';

part 'evenement_dto.freezed.dart';
part 'evenement_dto.g.dart';

/// Une ligne de `GET competition/evenement`. Tout est nullable : le mapper
/// écarte ou corrige une ligne incomplète, pour qu'elle ne fasse pas échouer
/// la liste entière.
@freezed
abstract class EvenementDto with _$EvenementDto {
  const factory EvenementDto({
    @JsonKey(name: 'Id', readValue: readInt) int? id,
    @JsonKey(name: 'Nom') String? name,
    @JsonKey(name: 'Debut') String? startDate,
    @JsonKey(name: 'Fin') String? endDate,
    @JsonKey(name: 'Specialite', readValue: readInt) int? speciality,
    @JsonKey(name: 'specialiteLabel') String? specialityLabel,
    // Absent de docs/FFSS_API.md, présent dans les vraies réponses : V3 le lit.
    @JsonKey(name: 'Lieu') String? location,
    @JsonKey(name: 'Organisme', readValue: readMap) OrganismeRefDto? organisme,
  }) = _EvenementDto;

  factory EvenementDto.fromJson(Map<String, dynamic> json) =>
      _$EvenementDtoFromJson(json);
}

@freezed
abstract class OrganismeRefDto with _$OrganismeRefDto {
  const factory OrganismeRefDto({
    @JsonKey(name: 'NomOrga') String? name,
    @JsonKey(name: 'label') String? label,
  }) = _OrganismeRefDto;

  factory OrganismeRefDto.fromJson(Map<String, dynamic> json) =>
      _$OrganismeRefDtoFromJson(json);
}
