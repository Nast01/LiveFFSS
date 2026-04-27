// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'competition_dto.freezed.dart';
part 'competition_dto.g.dart';

@freezed
class CompetitionDto with _$CompetitionDto {
  const factory CompetitionDto({
    @JsonKey(name: 'Id') required int id,
    @JsonKey(name: 'Nom') required String name,
    @JsonKey(name: 'Debut') String? beginDate,
    @JsonKey(name: 'Fin') String? endDate,
    @JsonKey(name: 'DebutEngagement') String? beginEntryLimitDate,
    @JsonKey(name: 'FinEngagement') String? endEntryLimitDate,
    @JsonKey(name: 'Lieu') String? location,
    @JsonKey(name: 'Statut') required int statusCode,
    @JsonKey(name: 'statutLabel') required String statusLabel,
    @JsonKey(name: 'Description') String? description,
    @JsonKey(name: 'Specialite') required int speciality,
    @JsonKey(name: 'specialiteLabel') required String specialityLabel,
    @JsonKey(name: 'water') required String typeWater,
    @JsonKey(name: 'bassin') required String typePool,
    @JsonKey(name: 'chronoLabel') required String typeChrono,
    required bool isEligibleToNationalRecord,
    @JsonKey(name: 'numberOfLanes') int? numberOfLanes,
    @JsonKey(name: 'Organisme') required CompetitionOrganismeDto organisme,
    required bool hasBegun,
    @JsonKey(name: 'hasResultat') required bool hasResult,
    required bool hasPassed,
    @JsonKey(name: 'Niveau') required int level,
    @JsonKey(name: 'niveauLabel') required String levelLabel,
    @JsonKey(name: 'JugePrincipal') String? refereePrincipal,
  }) = _CompetitionDto;

  factory CompetitionDto.fromJson(Map<String, dynamic> json) =>
      _$CompetitionDtoFromJson(json);
}

@freezed
class CompetitionOrganismeDto with _$CompetitionOrganismeDto {
  const factory CompetitionOrganismeDto({
    @JsonKey(name: 'Id') required int id,
    @JsonKey(name: 'NomOrga') required String organizerName,
    @JsonKey(name: 'NomCompletOrga') String? clubFullName,
    @JsonKey(name: 'NomCourt') String? shortName,
    @JsonKey(name: 'logo') String? logoUrl,
    @JsonKey(name: 'bonnet') String? capUrl,
  }) = _CompetitionOrganismeDto;

  factory CompetitionOrganismeDto.fromJson(Map<String, dynamic> json) =>
      _$CompetitionOrganismeDtoFromJson(json);
}
