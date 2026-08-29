// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';

part 'round_level.freezed.dart';
part 'round_level.g.dart';

enum RoundType { serie, quart, demi, finale, unknown }

/// The `LogiqueQualification` codes FFSS accepts, with the translation key that
/// names each. A code outside this list is still carried and shown as-is —
/// these are the ones the editor offers, not the ones it tolerates.
const String qualificationNone = 'none';
const Map<String, String> qualificationLabelKeys = {
  qualificationNone: 'qualification_none',
  'course': 'qualification_per_race',
  'partie': 'qualification_per_round',
};

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
    // FFSS `LogiqueQualification` code. Kept as the raw string rather than an
    // enum so a code this app does not know survives a round trip instead of
    // being flattened to a default and written back wrong.
    @Default(qualificationNone) String qualificationMethod,
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

/// Inverse of [roundTypeFromApi], for the `niveau` a `partie/submit` takes.
/// [RoundType.unknown] has no code to send, so it maps to the empty string and
/// the caller refuses to submit rather than inventing a round.
String roundTypeCode(RoundType type) => switch (type) {
      RoundType.serie => 'heat',
      RoundType.quart => 'quarter',
      RoundType.demi => 'semi',
      RoundType.finale => 'final',
      RoundType.unknown => '',
    };
