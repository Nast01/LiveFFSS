// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/data/dtos/category_dto.dart';
import 'package:live_ffss/app/data/dtos/discipline_dto.dart';

part 'race_format_configuration_dto.freezed.dart';
part 'race_format_configuration_dto.g.dart';

@freezed
class RaceFormatConfigurationDto with _$RaceFormatConfigurationDto {
  const factory RaceFormatConfigurationDto({
    @JsonKey(name: 'Id') required int id,
    @JsonKey(name: 'label') required String label,
    @JsonKey(name: 'fullLabel') required String fullLabel,
    @JsonKey(name: 'Genre') required String gender,
    @JsonKey(name: 'genreLabel') required String genderLabel,
    @JsonKey(name: 'Discipline') required DisciplineDto discipline,
    @JsonKey(name: 'categories', readValue: _readCategories)
    @Default(<CategoryDto>[]) List<CategoryDto> categories,
  }) = _RaceFormatConfigurationDto;

  factory RaceFormatConfigurationDto.fromJson(Map<String, dynamic> json) =>
      _$RaceFormatConfigurationDtoFromJson(json);
}

// FFSS quirk: categories arrive as [{categorie: {...}}, ...] not [{...}, ...]
Object? _readCategories(Map<dynamic, dynamic> map, String key) {
  final raw = map[key];
  if (raw is! List) return const <Map<String, dynamic>>[];
  return raw
      .whereType<Map<String, dynamic>>()
      .map((e) => e['categorie'])
      .whereType<Map<String, dynamic>>()
      .toList();
}
