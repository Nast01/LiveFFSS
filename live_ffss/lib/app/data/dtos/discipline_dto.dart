// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'discipline_dto.freezed.dart';
part 'discipline_dto.g.dart';

@freezed
class DisciplineDto with _$DisciplineDto {
  const factory DisciplineDto({
    @JsonKey(name: 'Id') required String id,
    @JsonKey(name: 'Nom') required String name,
    @JsonKey(name: 'specialite') required int speciality,
    @JsonKey(name: 'specialiteLabel') @Default('') String specialityLabel,
    @JsonKey(name: 'distance') @Default(0) int distance,
    @JsonKey(name: 'nbAthleteParEquipe') @Default(0) int numberOfAthletes,
    @JsonKey(name: 'isRelais') @Default(false) bool isRelay,
    @JsonKey(name: 'hasTemps') @Default(false) bool hasTime,
  }) = _DisciplineDto;

  factory DisciplineDto.fromJson(Map<String, dynamic> json) =>
      _$DisciplineDtoFromJson(json);
}
