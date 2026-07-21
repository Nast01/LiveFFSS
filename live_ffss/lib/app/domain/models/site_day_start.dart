import 'package:freezed_annotation/freezed_annotation.dart';

part 'site_day_start.freezed.dart';
part 'site_day_start.g.dart';

/// The editable start time (minutes past midnight) of one site on one day.
/// Absent ⇒ the timeline starts at 09:00.
@freezed
class SiteDayStart with _$SiteDayStart {
  const factory SiteDayStart({
    required int siteId,
    required DateTime day,
    required int startMinutes,
  }) = _SiteDayStart;

  factory SiteDayStart.fromJson(Map<String, dynamic> json) =>
      _$SiteDayStartFromJson(json);
}
