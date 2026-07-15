import 'package:live_ffss/app/data/dtos/result_dto.dart';
import 'package:live_ffss/app/data/mappers/athlete_mapper.dart';
import 'package:live_ffss/app/data/mappers/entry_mapper.dart';
import 'package:live_ffss/app/data/mappers/heat_mapper.dart';
import 'package:live_ffss/app/domain/models/result.dart';

extension ResultMapper on ResultDto {
  /// Maps a result to its domain form.
  ///
  /// When [includeParents] is false, `heat` and `entry` are dropped — used
  /// when the result is being mapped as a child of a Serie/Heat (avoids
  /// circular Heat ↔ Result references). The view layer can rely on the
  /// parent heat being available via its own reference.
  Result toDomain({bool includeParents = true}) => Result(
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
        disqualificationReason: disqualificationReason,
        heat: includeParents ? heat?.toDomain() : null,
        entry: entry?.toDomain(),
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
