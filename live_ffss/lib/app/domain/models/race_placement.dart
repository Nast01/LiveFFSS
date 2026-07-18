import 'package:freezed_annotation/freezed_annotation.dart';

part 'race_placement.freezed.dart';
part 'race_placement.g.dart';

@freezed
class RacePlacement with _$RacePlacement {
  const factory RacePlacement({
    required int siteId,
    required DateTime beginHour,
    @Default(10) int durationMinutes,
  }) = _RacePlacement;

  factory RacePlacement.fromJson(Map<String, dynamic> json) =>
      _$RacePlacementFromJson(json);
}
