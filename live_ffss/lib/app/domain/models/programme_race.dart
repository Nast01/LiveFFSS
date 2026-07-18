import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/race_placement.dart';

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
    // null until the race is scheduled (Plan B fills this).
    RacePlacement? placement,
  }) = _ProgrammeRace;

  factory ProgrammeRace.fromJson(Map<String, dynamic> json) =>
      _$ProgrammeRaceFromJson(json);
}
