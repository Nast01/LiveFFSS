// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'race_format_detail_dto.freezed.dart';
part 'race_format_detail_dto.g.dart';

@freezed
class RaceFormatDetailDto with _$RaceFormatDetailDto {
  const factory RaceFormatDetailDto({
    @JsonKey(name: 'id') required int id,
    @JsonKey(name: 'ordre') required int order,
    @JsonKey(name: 'label') required String label,
    @JsonKey(name: 'fullLabel') required String fullLabel,
    @JsonKey(name: 'niveauLabel') required String levelLabel,
    @JsonKey(name: 'niveau') required String level,
    @JsonKey(name: 'nbCourses') required int numberOfRun,
    @JsonKey(name: 'logiqueQualification') required String qualificationMethod,
    @JsonKey(name: 'logiqueQualificationLabel')
    required String qualificationMethodLabel,
    @JsonKey(name: 'nbPlaceParCourse') required int spotsPerRace,
    @JsonKey(name: 'nbPlaceQualificative') required int qualifyingSpots,
  }) = _RaceFormatDetailDto;

  factory RaceFormatDetailDto.fromJson(Map<String, dynamic> json) =>
      _$RaceFormatDetailDtoFromJson(json);
}
