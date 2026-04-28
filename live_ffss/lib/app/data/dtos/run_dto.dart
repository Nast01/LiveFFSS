// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/data/dtos/heat_dto.dart';
import 'package:live_ffss/app/data/dtos/live_result_dto.dart';

part 'run_dto.freezed.dart';
part 'run_dto.g.dart';

@freezed
class RunDto with _$RunDto {
  const factory RunDto({
    @JsonKey(name: 'id') required int id,
    @JsonKey(name: 'Nom') required String name,
    @JsonKey(name: 'label') required String label,
    @JsonKey(name: 'fullLabel') required String fullLabel,
    @JsonKey(name: 'statut') required int status,
    @JsonKey(name: 'statutLabel') required String statusLabel,
    @JsonKey(name: 'site') required String site,
    @JsonKey(name: 'debut') required String beginTime,
    @JsonKey(name: 'fin') required String endTime,
    @JsonKey(name: 'serie') HeatDto? heat,
    @JsonKey(name: 'liveResults') @Default(<LiveResultDto>[]) List<LiveResultDto> liveResults,
  }) = _RunDto;

  factory RunDto.fromJson(Map<String, dynamic> json) => _$RunDtoFromJson(json);
}
