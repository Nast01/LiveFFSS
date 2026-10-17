// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/data/ffss/dtos/json_readers.dart';

part 'deroulement_dto.freezed.dart';
part 'deroulement_dto.g.dart';

// La liste `deroulement` sert `Id` et `Discipline`, mais le déroulement
// imbriqué dans un créneau sert `id` et `discipline` en minuscules, sans
// `Genre`.
Object? _readId(Map<dynamic, dynamic> json, String key) =>
    readInt(json, 'Id') ?? readInt(json, 'id');

Object? _readDiscipline(Map<dynamic, dynamic> json, String key) =>
    readMap(json, 'Discipline') ?? readMap(json, 'discipline');

@freezed
abstract class DeroulementDto with _$DeroulementDto {
  const factory DeroulementDto({
    @JsonKey(name: 'Id', readValue: _readId) int? id,
    @JsonKey(name: 'label') String? label,
    @JsonKey(name: 'Genre') String? gender,
    @JsonKey(name: 'genreLabel') String? genderLabel,
    @JsonKey(name: 'Discipline', readValue: _readDiscipline)
    DeroulementDisciplineDto? discipline,
    @JsonKey(name: 'parties') @Default(<PartieDto>[]) List<PartieDto> parties,
  }) = _DeroulementDto;

  factory DeroulementDto.fromJson(Map<String, dynamic> json) =>
      _$DeroulementDtoFromJson(json);
}

@freezed
abstract class DeroulementDisciplineDto with _$DeroulementDisciplineDto {
  const factory DeroulementDisciplineDto({@JsonKey(name: 'Nom') String? name}) =
      _DeroulementDisciplineDto;

  factory DeroulementDisciplineDto.fromJson(Map<String, dynamic> json) =>
      _$DeroulementDisciplineDtoFromJson(json);
}

@freezed
abstract class PartieDto with _$PartieDto {
  const factory PartieDto({
    @JsonKey(name: 'id', readValue: readInt) int? id,
    @JsonKey(name: 'ordre', readValue: readInt) int? order,
    @JsonKey(name: 'niveau') String? level,
    @JsonKey(name: 'label') String? label,
    @JsonKey(name: 'nbCourses', readValue: readInt) int? heatCount,
    @JsonKey(name: 'nbPlaceParCourse', readValue: readInt) int? placesPerHeat,
    @JsonKey(name: 'nbPlaceQualificative', readValue: readInt)
    int? qualifyingPlaces,
    @JsonKey(name: 'logiqueQualification') String? qualificationLogic,
    @JsonKey(name: 'deroulement', readValue: readMap)
    DeroulementDto? deroulement,
  }) = _PartieDto;

  factory PartieDto.fromJson(Map<String, dynamic> json) =>
      _$PartieDtoFromJson(json);
}
