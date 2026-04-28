// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'heat_dto.freezed.dart';
part 'heat_dto.g.dart';

@freezed
class HeatDto with _$HeatDto {
  const factory HeatDto({
    @JsonKey(name: 'Id') required int id,
    @JsonKey(name: 'Nom') required String name,
    @JsonKey(name: 'Fini') required bool done,
    @JsonKey(name: 'Numero', readValue: _readNumber) required int number,
  }) = _HeatDto;

  factory HeatDto.fromJson(Map<String, dynamic> json) =>
      _$HeatDtoFromJson(json);
}

Object? _readNumber(Map<dynamic, dynamic> map, String key) {
  final raw = map[key];
  if (raw is String) return int.tryParse(raw) ?? 0;
  return raw;
}
