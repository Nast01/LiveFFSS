import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';

part 'event_structure.freezed.dart';
part 'event_structure.g.dart';

@freezed
class EventStructure with _$EventStructure {
  const factory EventStructure({
    required int raceId,
    required int categoryId,
    required String raceLabel,
    required String categoryLabel,
    // Default race size, used to seed new rounds and as the fallback for any
    // round that does not set its own. The authoritative value for a given
    // round is `RoundLevel.spotsPerRace` — see [EventStructureX.spotsForLevel].
    @Default(8) int spotsPerRace,
    @Default(<RoundLevel>[]) List<RoundLevel> levels,
  }) = _EventStructure;

  factory EventStructure.fromJson(Map<String, dynamic> json) =>
      _$EventStructureFromJson(json);
}

extension EventStructureX on EventStructure {
  /// Race size for [level]: its own value when set, otherwise the structure's
  /// default. The fallback is what keeps programmes authored before rounds
  /// carried their own size readable.
  int spotsForLevel(RoundLevel level) =>
      level.spotsPerRace > 0 ? level.spotsPerRace : spotsPerRace;
}
