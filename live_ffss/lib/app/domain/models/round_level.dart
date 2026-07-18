import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';

part 'round_level.freezed.dart';
part 'round_level.g.dart';

enum RoundType { serie, quart, demi, finale, unknown }

@freezed
class RoundLevel with _$RoundLevel {
  const factory RoundLevel({
    required RoundType type,
    // Operator metadata; drives no computation in v1 (no seeding).
    @Default(0) int qualifiersPerRace,
    @Default(<ProgrammeRace>[]) List<ProgrammeRace> races,
  }) = _RoundLevel;

  factory RoundLevel.fromJson(Map<String, dynamic> json) =>
      _$RoundLevelFromJson(json);
}
