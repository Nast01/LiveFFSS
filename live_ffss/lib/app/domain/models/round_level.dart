// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';

part 'round_level.freezed.dart';
part 'round_level.g.dart';

enum RoundType { serie, quart, demi, finale, unknown }

@freezed
class RoundLevel with _$RoundLevel {
  const factory RoundLevel({
    @JsonKey(unknownEnumValue: RoundType.unknown) required RoundType type,
    // Operator metadata; drives no computation in v1 (no seeding).
    @Default(0) int qualifiersPerRace,
    // Race size for THIS round — the FFSS `parties` payload sets it per round
    // (a semi at 18 feeding a final at 16), not once for the whole event.
    // 0 means "not set": callers fall back to `EventStructure.spotsPerRace`,
    // which is what programmes authored before this field carry.
    @Default(0) int spotsPerRace,
    // Id of the FFSS `partie` this round came from, 0 for a round the operator
    // added by hand. Only a round with one can be deleted server-side.
    @Default(0) int serverId,
    @Default(<ProgrammeRace>[]) List<ProgrammeRace> races,
  }) = _RoundLevel;

  factory RoundLevel.fromJson(Map<String, dynamic> json) =>
      _$RoundLevelFromJson(json);
}

/// Decodes the `niveau` code carried by a FFSS `partie`. The API vocabulary is
/// English (`heat`, `quarter`, `semi`, `final`) while ours is French, so this
/// is a translation, not a rename. An unrecognised code lands on
/// [RoundType.unknown] rather than silently passing for a real round.
RoundType roundTypeFromApi(Object? raw) => switch (raw) {
      'heat' => RoundType.serie,
      'quarter' => RoundType.quart,
      'semi' => RoundType.demi,
      'final' => RoundType.finale,
      _ => RoundType.unknown,
    };
