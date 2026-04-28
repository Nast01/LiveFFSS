// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/data/dtos/race_format_detail_dto.dart';
import 'package:live_ffss/app/data/dtos/run_dto.dart';

part 'slot_dto.freezed.dart';
part 'slot_dto.g.dart';

@freezed
class SlotDto with _$SlotDto {
  const factory SlotDto({
    @JsonKey(name: 'id') required int id,
    @JsonKey(name: 'Nom') required String name,
    @JsonKey(name: 'Debut') required String beginHour,
    @JsonKey(name: 'Fin') required String endHour,
    @JsonKey(name: 'partie') RaceFormatDetailDto? raceFormatDetail,
    @JsonKey(name: 'courses') @Default(<RunDto>[]) List<RunDto> runs,
  }) = _SlotDto;

  factory SlotDto.fromJson(Map<String, dynamic> json) =>
      _$SlotDtoFromJson(json);
}
