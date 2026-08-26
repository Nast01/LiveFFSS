// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/course_penalty.dart';

part 'programme_race.freezed.dart';
part 'programme_race.g.dart';

@freezed
class ProgrammeRace with _$ProgrammeRace {
  @JsonSerializable(explicitToJson: true)
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
    // The order this race was crossed in — one entry per finishing group, a
    // group of several being a declared tie. Places are computed from this
    // and never stored: that is what makes a removal renumber for free.
    @Default(<List<int>>[]) List<List<int>> finishOrder,
    // Athletes out of the ranking. They take no place, so the athletes after
    // them number as though they had not started.
    @Default(<CoursePenalty>[]) List<CoursePenalty> penalties,
  }) = _ProgrammeRace;

  factory ProgrammeRace.fromJson(Map<String, dynamic> json) =>
      _$ProgrammeRaceFromJson(json);
}
