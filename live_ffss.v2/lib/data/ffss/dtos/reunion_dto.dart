// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/data/ffss/dtos/json_readers.dart';

part 'reunion_dto.freezed.dart';
part 'reunion_dto.g.dart';

// Clés vérifiées par la v1 sur de vraies réponses : la casse change d'un
// niveau à l'autre (`Id` pour la réunion, `id` pour le créneau et la course,
// `debut`/`fin`/`statut` en minuscules pour la course).

@freezed
abstract class ReunionDto with _$ReunionDto {
  const factory ReunionDto({
    @JsonKey(name: 'Id', readValue: readInt) int? id,
    @JsonKey(name: 'Nom') String? name,
    @JsonKey(name: 'Jour') String? day,
    @JsonKey(name: 'Debut') String? start,
    @JsonKey(name: 'Fin') String? end,
    @JsonKey(name: 'creneaus')
    @Default(<CreneauDto>[])
    List<CreneauDto> creneaus,
  }) = _ReunionDto;

  factory ReunionDto.fromJson(Map<String, dynamic> json) =>
      _$ReunionDtoFromJson(json);
}

@freezed
abstract class CreneauDto with _$CreneauDto {
  const factory CreneauDto({
    @JsonKey(name: 'id', readValue: readInt) int? id,
    @JsonKey(name: 'Nom') String? name,
    @JsonKey(name: 'partie', readValue: readMap) PartieRefDto? partie,
    @JsonKey(name: 'courses') @Default(<CourseDto>[]) List<CourseDto> courses,
  }) = _CreneauDto;

  factory CreneauDto.fromJson(Map<String, dynamic> json) =>
      _$CreneauDtoFromJson(json);
}

@freezed
abstract class PartieRefDto with _$PartieRefDto {
  const factory PartieRefDto({
    @JsonKey(name: 'id', readValue: readInt) int? id,
  }) = _PartieRefDto;

  factory PartieRefDto.fromJson(Map<String, dynamic> json) =>
      _$PartieRefDtoFromJson(json);
}

@freezed
abstract class CourseDto with _$CourseDto {
  const factory CourseDto({
    @JsonKey(name: 'id', readValue: readInt) int? id,
    @JsonKey(name: 'Nom') String? name,
    @JsonKey(name: 'statut', readValue: readInt) int? status,
    @JsonKey(name: 'debut') String? start,
    @JsonKey(name: 'fin') String? end,
    @JsonKey(name: 'serie', readValue: readMap) SerieDto? serie,
  }) = _CourseDto;

  factory CourseDto.fromJson(Map<String, dynamic> json) =>
      _$CourseDtoFromJson(json);
}

@freezed
abstract class SerieDto with _$SerieDto {
  const factory SerieDto({
    @JsonKey(name: 'Id', readValue: readInt) int? id,
    @JsonKey(name: 'Nom') String? name,
    @JsonKey(name: 'Numero', readValue: readInt) int? number,
    @JsonKey(name: 'epreuve', readValue: readMap) EpreuveRefDto? epreuve,
  }) = _SerieDto;

  factory SerieDto.fromJson(Map<String, dynamic> json) =>
      _$SerieDtoFromJson(json);
}

@freezed
abstract class EpreuveRefDto with _$EpreuveRefDto {
  const factory EpreuveRefDto({
    @JsonKey(name: 'Id', readValue: readInt) int? id,
    @JsonKey(name: 'Genre') String? gender,
    @JsonKey(name: 'discipline', readValue: readMap)
    DisciplineRefDto? discipline,
  }) = _EpreuveRefDto;

  factory EpreuveRefDto.fromJson(Map<String, dynamic> json) =>
      _$EpreuveRefDtoFromJson(json);
}

@freezed
abstract class DisciplineRefDto with _$DisciplineRefDto {
  const factory DisciplineRefDto({@JsonKey(name: 'Nom') String? name}) =
      _DisciplineRefDto;

  factory DisciplineRefDto.fromJson(Map<String, dynamic> json) =>
      _$DisciplineRefDtoFromJson(json);
}
