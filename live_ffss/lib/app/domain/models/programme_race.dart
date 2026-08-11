import 'package:freezed_annotation/freezed_annotation.dart';

part 'programme_race.freezed.dart';
part 'programme_race.g.dart';

@freezed
class ProgrammeRace with _$ProgrammeRace {
  const factory ProgrammeRace({
    required int id,
    required int number,
    // opt1/opt2 wiring: ids of the feeding races at the previous level.
    // Empty at the séries level and for opt2-with-no-selection.
    @Default(<int>[]) List<int> sourceRaceIds,
    // Athletes drawn into this race, in lane order — the position in the list
    // IS the lane, since coastal lanes are sequential. Empty until the heats
    // are drawn from the athletes marked present.
    @Default(<int>[]) List<int> athleteIds,
  }) = _ProgrammeRace;

  factory ProgrammeRace.fromJson(Map<String, dynamic> json) =>
      _$ProgrammeRaceFromJson(json);
}
