// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/data/dtos/athlete_dto.dart';
import 'package:live_ffss/app/data/dtos/entry_dto.dart';
import 'package:live_ffss/app/data/dtos/heat_dto.dart';

part 'result_dto.freezed.dart';
part 'result_dto.g.dart';

@freezed
class ResultDto with _$ResultDto {
  const factory ResultDto({
    @JsonKey(name: 'Id') required String id,
    @JsonKey(name: 'isValid') required bool isValid,
    @JsonKey(name: 'Statut') required int status,
    @JsonKey(name: 'statutLabel') required String statusLabel,
    @JsonKey(name: 'isDisqualifie') @Default(false) bool isDisqualified,
    @JsonKey(name: 'Rang') required int rank,
    @JsonKey(name: 'Temps') required int time,
    @JsonKey(name: 'tempsLabel') required String timeLabel,
    @JsonKey(name: 'complement') String? complement,
    @JsonKey(name: 'complementLabel') String? complementLabel,
    @JsonKey(name: 'CodeDisqualification') @Default('') String disqualificationCode,
    @JsonKey(name: 'CommentaireDisqualification') @Default('') String disqualificationComment,
    @JsonKey(name: 'serie') required HeatDto heat,
    @JsonKey(name: 'engagement') required EntryDto entry,
    @JsonKey(name: 'athletes') @Default(<AthleteDto>[]) List<AthleteDto> athletes,
    @JsonKey(name: 'isRecord') @Default(false) bool isRecord,
    @JsonKey(name: 'isMeilleurPerformance') @Default(false) bool isBestPerformance,
    @JsonKey(name: 'isRecordDeFrance') @Default(false) bool isFranceRecord,
    @JsonKey(name: 'points') @Default(0) int points,
    @JsonKey(name: 'TempsLive1') @Default(0) int liveTime1,
    @JsonKey(name: 'TempsLive2') @Default(0) int liveTime2,
    @JsonKey(name: 'TempsLive3') @Default(0) int liveTime3,
  }) = _ResultDto;

  factory ResultDto.fromJson(Map<String, dynamic> json) =>
      _$ResultDtoFromJson(json);
}
