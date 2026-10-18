// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/data/ffss/dtos/json_readers.dart';

part 'epreuve_dto.freezed.dart';
part 'epreuve_dto.g.dart';

@freezed
abstract class EpreuveDto with _$EpreuveDto {
  const factory EpreuveDto({
    @JsonKey(name: 'Id', readValue: readInt) int? id,
    @JsonKey(name: 'IdDiscipline', readValue: readInt) int? disciplineId,
    @JsonKey(name: 'Genre') String? gender,
    @JsonKey(name: 'discipline', readValue: readMap)
    EpreuveDisciplineDto? discipline,
    @JsonKey(name: 'categories')
    @Default(<EpreuveCategorieDto>[])
    List<EpreuveCategorieDto> categories,
  }) = _EpreuveDto;

  factory EpreuveDto.fromJson(Map<String, dynamic> json) =>
      _$EpreuveDtoFromJson(json);
}

@freezed
abstract class EpreuveDisciplineDto with _$EpreuveDisciplineDto {
  const factory EpreuveDisciplineDto({
    @JsonKey(name: 'label') String? label,
    @JsonKey(name: 'Nom') String? name,
    @JsonKey(name: 'NbAthleteParEquipe', readValue: readInt) int? teamSize,
    @JsonKey(name: 'Specialite', readValue: readInt) int? speciality,
  }) = _EpreuveDisciplineDto;

  factory EpreuveDisciplineDto.fromJson(Map<String, dynamic> json) =>
      _$EpreuveDisciplineDtoFromJson(json);
}

@freezed
abstract class EpreuveCategorieDto with _$EpreuveCategorieDto {
  const factory EpreuveCategorieDto({
    @JsonKey(name: 'Id', readValue: readInt) int? id,
    @JsonKey(name: 'Nom') String? name,
  }) = _EpreuveCategorieDto;

  factory EpreuveCategorieDto.fromJson(Map<String, dynamic> json) =>
      _$EpreuveCategorieDtoFromJson(json);
}
