// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/data/dtos/slot_dto.dart';

part 'meeting_dto.freezed.dart';
part 'meeting_dto.g.dart';

@freezed
class MeetingDto with _$MeetingDto {
  const factory MeetingDto({
    @JsonKey(name: 'Id') required int id,
    @JsonKey(name: 'Nom') required String name,
    @JsonKey(name: 'Description') required String description,
    @JsonKey(name: 'Jour') required String date,
    @JsonKey(name: 'Debut') required String beginHour,
    @JsonKey(name: 'Fin') required String endHour,
    @JsonKey(name: 'creneaus') @Default(<SlotDto>[]) List<SlotDto> slots,
  }) = _MeetingDto;

  factory MeetingDto.fromJson(Map<String, dynamic> json) =>
      _$MeetingDtoFromJson(json);
}
