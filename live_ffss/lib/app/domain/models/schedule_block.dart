import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule_block.freezed.dart';
part 'schedule_block.g.dart';

/// One item in a site×day timeline: a race (`raceId` set) or a manual
/// free-text item (`manualLabel` non-empty). Begin/end times are derived from
/// the day's start plus each block's duration, in `order` — never stored.
@freezed
class ScheduleBlock with _$ScheduleBlock {
  const factory ScheduleBlock({
    required int id,
    required int siteId,
    required DateTime day,
    required int order,
    @Default(10) int durationMinutes,
    int? raceId,
    @Default('') String manualLabel,
  }) = _ScheduleBlock;

  factory ScheduleBlock.fromJson(Map<String, dynamic> json) =>
      _$ScheduleBlockFromJson(json);
}
