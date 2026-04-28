import 'package:live_ffss/app/data/dtos/result_dto.dart';
import 'package:live_ffss/app/data/mappers/athlete_mapper.dart';
import 'package:live_ffss/app/data/mappers/entry_mapper.dart';
import 'package:live_ffss/app/data/mappers/heat_mapper.dart';
import 'package:live_ffss/app/domain/models/result.dart';

extension ResultMapper on ResultDto {
  Result toDomain() => Result(
        id: id,
        isValid: isValid,
        status: status,
        statusLabel: statusLabel,
        isDisqualified: isDisqualified,
        rank: rank,
        time: time,
        timeLabel: timeLabel,
        complement: complement,
        complementLabel: complementLabel,
        disqualificationCode: disqualificationCode,
        disqualificationComment: disqualificationComment,
        heat: heat.toDomain(),
        entry: entry.toDomain(),
        athletes: athletes.map((a) => a.toDomain()).toList(),
        isRecord: isRecord,
        isBestPerformance: isBestPerformance,
        isFranceRecord: isFranceRecord,
        points: points,
        liveTime1: liveTime1,
        liveTime2: liveTime2,
        liveTime3: liveTime3,
      );
}
