// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/data/dtos/category_dto.dart';

part 'race_dto.freezed.dart';
part 'race_dto.g.dart';

@freezed
class RaceDto with _$RaceDto {
  const factory RaceDto({
    @JsonKey(name: 'Id') required int id,
    @JsonKey(name: 'IdDiscipline') required int disciplineId,
    @JsonKey(name: 'Genre') required String gender,
    @JsonKey(name: 'isEligibleToNationalRecord')
    @Default(false)
    bool isEligibleToNationalRecord,
    @JsonKey(name: 'discipline') required RaceDisciplineDto discipline,
    @JsonKey(name: 'categories') @Default(<CategoryDto>[]) List<CategoryDto> categories,
  }) = _RaceDto;

  factory RaceDto.fromJson(Map<String, dynamic> json) =>
      _$RaceDtoFromJson(json);
}

@freezed
class RaceDisciplineDto with _$RaceDisciplineDto {
  const factory RaceDisciplineDto({
    @JsonKey(name: 'Nom') required String name,
    @JsonKey(name: 'NomEn') required String nameEnglish,
    @JsonKey(name: 'Distance') @Default(0) int distance,
    @JsonKey(name: 'NbAthleteParEquipe') @Default(1) int athletesPerTeam,
    @JsonKey(name: 'Specialite') required int specialityId,
    @JsonKey(name: 'specialiteLabel') required String specialityLabel,
  }) = _RaceDisciplineDto;

  factory RaceDisciplineDto.fromJson(Map<String, dynamic> json) =>
      _$RaceDisciplineDtoFromJson(json);
}
