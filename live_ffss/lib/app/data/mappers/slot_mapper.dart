import 'package:intl/intl.dart';
import 'package:live_ffss/app/data/dtos/slot_dto.dart';
import 'package:live_ffss/app/data/mappers/race_format_detail_mapper.dart';
import 'package:live_ffss/app/data/mappers/run_mapper.dart';
import 'package:live_ffss/app/domain/models/slot.dart';

final _timeFormat = DateFormat('HH:mm');

DateTime _parseTime(String hhmm) => _timeFormat.parse(hhmm);

extension SlotMapper on SlotDto {
  Slot toDomain() => Slot(
        id: id,
        name: name,
        beginHour: _parseTime(beginHour),
        endHour: _parseTime(endHour),
        raceFormatDetail: raceFormatDetail?.toDomain(),
        runs: runs.map((r) => r.toDomain()).toList(),
      );
}
