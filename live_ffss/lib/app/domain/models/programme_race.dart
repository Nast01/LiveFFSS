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
    // Entries drawn into this race, one per lane, in lane order — the FFSS
    // « place » model: a lane seats one engagement, a relay team included.
    // Empty for a draw made before this field existed; `athleteIds` then
    // remains the only record.
    @Default(<int>[]) List<int> entryIds,
    // The drawn athletes, flattened in lane order — a relay team contributes
    // all its members here while holding a single slot in `entryIds`. What
    // the result and display code reads.
    @Default(<int>[]) List<int> athleteIds,
    // The order this race was crossed in — one entry per finishing group, a
    // group of several being a declared tie. Places are computed from this
    // and never stored: that is what makes a removal renumber for free.
    @Default(<List<int>>[]) List<List<int>> finishOrder,
    // Athletes out of the ranking. They take no place, so the athletes after
    // them number as though they had not started.
    @Default(<CoursePenalty>[]) List<CoursePenalty> penalties,
    // The FFSS course this heat runs as, 0 while it has none. The draw lives
    // on the device and the timetable on the server: without this id nothing
    // says that heat 2 is the 08:10 start on OCEAN 1.
    //
    // Recorded rather than matched by position: deleting a course would shift
    // every later heat onto a start that is not its own, silently.
    @Default(0) int runId,
  }) = _ProgrammeRace;

  factory ProgrammeRace.fromJson(Map<String, dynamic> json) =>
      _$ProgrammeRaceFromJson(json);
}
