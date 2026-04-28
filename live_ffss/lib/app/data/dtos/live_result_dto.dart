// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/data/dtos/entry_dto.dart';
import 'package:live_ffss/app/data/dtos/result_dto.dart';

part 'live_result_dto.freezed.dart';
part 'live_result_dto.g.dart';

@freezed
class LiveResultDto with _$LiveResultDto {
  const factory LiveResultDto({
    @JsonKey(name: 'Id') required int id,
    @JsonKey(name: 'Numero') @Default('') String number,
    @JsonKey(name: 'Engagement') EntryDto? entry,
    @JsonKey(name: 'Resultat') ResultDto? result,
  }) = _LiveResultDto;

  factory LiveResultDto.fromJson(Map<String, dynamic> json) =>
      _$LiveResultDtoFromJson(json);
}
