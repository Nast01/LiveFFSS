import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/entry.dart';
import 'package:live_ffss/app/domain/models/heat.dart';

part 'result.freezed.dart';
part 'result.g.dart';

@freezed
class Result with _$Result {
  const factory Result({
    required String id,
    required bool isValid,
    required int status,
    required String statusLabel,
    @Default(false) bool isDisqualified,
    required int rank,
    required int time,
    required String timeLabel,
    String? complement,
    String? complementLabel,
    @Default('') String disqualificationCode,
    @Default('') String disqualificationComment,
    required Heat heat,
    required Entry entry,
    @Default(<Athlete>[]) List<Athlete> athletes,
    @Default(false) bool isRecord,
    @Default(false) bool isBestPerformance,
    @Default(false) bool isFranceRecord,
    @Default(0) int points,
    @Default(0) int liveTime1,
    @Default(0) int liveTime2,
    @Default(0) int liveTime3,
  }) = _Result;

  factory Result.fromJson(Map<String, dynamic> json) =>
      _$ResultFromJson(json);
}
