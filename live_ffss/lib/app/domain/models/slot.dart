import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/race_format_detail.dart';
import 'package:live_ffss/app/domain/models/run.dart';

part 'slot.freezed.dart';
part 'slot.g.dart';

@freezed
class Slot with _$Slot {
  const factory Slot({
    required int id,
    required String name,
    required DateTime beginHour,
    required DateTime endHour,
    RaceFormatDetail? raceFormatDetail,
    @Default(<Run>[]) List<Run> runs,
  }) = _Slot;

  factory Slot.fromJson(Map<String, dynamic> json) => _$SlotFromJson(json);
}
