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
    // Race size; drives seriesCount = ceil(entries / spotsPerRace).
    @Default(8) int spotsPerRace,
    @Default(<RoundLevel>[]) List<RoundLevel> levels,
  }) = _EventStructure;

  factory EventStructure.fromJson(Map<String, dynamic> json) =>
      _$EventStructureFromJson(json);
}
