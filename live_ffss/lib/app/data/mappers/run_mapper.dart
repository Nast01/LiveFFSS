import 'package:intl/intl.dart';
import 'package:live_ffss/app/data/dtos/run_dto.dart';
import 'package:live_ffss/app/data/mappers/heat_mapper.dart';
import 'package:live_ffss/app/data/mappers/live_result_mapper.dart';
import 'package:live_ffss/app/domain/models/run.dart';

final _timeFormat = DateFormat('HH:mm');

DateTime _parseTime(String hhmm) => _timeFormat.parse(hhmm);

extension RunMapper on RunDto {
  Run toDomain() => Run(
        id: id,
        name: name,
        label: label,
        fullLabel: fullLabel,
        status: status.asRunStatus,
        statusLabel: statusLabel,
        site: site,
        beginTime: _parseTime(beginTime),
        endTime: _parseTime(endTime),
        heat: heat?.toDomain(),
        liveResults: liveResults.map((lr) => lr.toDomain()).toList(),
      );
}
