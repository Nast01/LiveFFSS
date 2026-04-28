// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/data/dtos/athlete_dto.dart';
import 'package:live_ffss/app/data/dtos/category_dto.dart';

part 'entry_dto.freezed.dart';
part 'entry_dto.g.dart';

@freezed
class EntryDto with _$EntryDto {
  const factory EntryDto({
    @JsonKey(name: 'Id') required int id,
    @JsonKey(name: 'categorie') required CategoryDto category,
    @JsonKey(name: 'Statut') required int status,
    @JsonKey(name: 'statutLabel') required String statusLabel,
    @JsonKey(name: 'performance') required int entryTime,
    @JsonKey(name: 'performanceLabel') required String entryTimeLabel,
    @JsonKey(name: 'athletes') @Default(<AthleteDto>[]) List<AthleteDto> athletes,
  }) = _EntryDto;

  factory EntryDto.fromJson(Map<String, dynamic> json) =>
      _$EntryDtoFromJson(json);
}
