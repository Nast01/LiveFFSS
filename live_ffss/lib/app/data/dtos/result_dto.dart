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
    @JsonKey(name: 'Id', readValue: _readId) @Default('') String id,
    @JsonKey(name: 'isValid') @Default(false) bool isValid,
    @JsonKey(name: 'Statut') @Default(0) int status,
    @JsonKey(name: 'statutLabel') @Default('') String statusLabel,
    @JsonKey(name: 'isDisqualifie') @Default(false) bool isDisqualified,
    @JsonKey(name: 'Rang') @Default(0) int rank,
    @JsonKey(name: 'Temps') @Default(0) int time,
    @JsonKey(name: 'tempsLabel') @Default('') String timeLabel,
    @JsonKey(name: 'complement') String? complement,
    @JsonKey(name: 'complementLabel') String? complementLabel,
    @JsonKey(name: 'CodeDisqualification') @Default('') String disqualificationCode,
    @JsonKey(name: 'disqualificationReason', readValue: _readDisqualificationReason)
    @Default('')
    String disqualificationReason,
    @JsonKey(name: 'serie') HeatDto? heat,
    @JsonKey(name: 'engagement') EntryDto? entry,
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

// API doc says Resultat.Id is a Number, but legacy clients typed it as
// String. Accept both shapes.
Object? _readId(Map<dynamic, dynamic> map, String key) {
  final raw = map[key];
  if (raw == null) return '';
  if (raw is String) return raw;
  return raw.toString();
}

// New API exposes the field as `disqualificationReason`, but legacy clients
// returned it as `CommentaireDisqualification`. Try both for compatibility.
Object? _readDisqualificationReason(Map<dynamic, dynamic> map, String key) {
  final fresh = map[key];
  if (fresh is String && fresh.isNotEmpty) return fresh;
  final legacy = map['CommentaireDisqualification'];
  if (legacy is String) return legacy;
  return '';
}
