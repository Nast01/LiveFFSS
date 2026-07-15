// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/data/dtos/race_dto.dart';
import 'package:live_ffss/app/data/dtos/result_dto.dart';

part 'heat_dto.freezed.dart';
part 'heat_dto.g.dart';

@freezed
class HeatDto with _$HeatDto {
  const factory HeatDto({
    @JsonKey(name: 'Id') @Default(0) int id,
    @JsonKey(name: 'Nom') @Default('') String name,
    @JsonKey(name: 'Fini') @Default(false) bool done,
    @JsonKey(name: 'Numero', readValue: _readNumber) @Default(0) int number,
    @JsonKey(name: 'UpdatedAt') String? updatedAt,
    @JsonKey(name: 'Debut') String? startDate,
    @JsonKey(name: 'Fin') String? endDate,
    @JsonKey(name: 'epreuve') RaceDto? race,
    @JsonKey(name: 'resultats')
    @Default(<ResultDto>[]) List<ResultDto> results,
  }) = _HeatDto;

  factory HeatDto.fromJson(Map<String, dynamic> json) =>
      _$HeatDtoFromJson(json);
}

Object? _readNumber(Map<dynamic, dynamic> map, String key) {
  final raw = map[key];
  if (raw is String) return int.tryParse(raw) ?? 0;
  return raw;
}
