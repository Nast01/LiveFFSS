import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';

/// A proposed level: its round type and how many races it holds. The caller
/// materialises `ProgrammeRace`s (with ids) from this.
typedef LevelPlan = ({RoundType type, int raceCount});

/// Number of séries needed to seat [entryCount] athletes at [spotsPerRace] per
/// race, rounding up so the last série absorbs the remainder.
int seriesCount(int entryCount, int spotsPerRace) {
  if (entryCount <= 0 || spotsPerRace <= 0) return 0;
  return (entryCount / spotsPerRace).ceil();
}

/// The generic default structure: one finale when everyone fits in a single
/// race, otherwise séries feeding a finale. No FFSS rulebook — a starting
/// point the operator adjusts.
List<LevelPlan> proposeLevels({
  required int entryCount,
  required int spotsPerRace,
}) {
  final series = seriesCount(entryCount, spotsPerRace);
  if (series == 0) return const [];
  if (series == 1) return const [(type: RoundType.finale, raceCount: 1)];
  return [
    (type: RoundType.serie, raceCount: series),
    (type: RoundType.finale, raceCount: 1),
  ];
}

/// Materialises [proposeLevels] into `RoundLevel`s with allocated
/// `ProgrammeRace`s. Each race is opt2-wired: fed by every race of the
/// previous level (empty `sourceRaceIds` for the first level).
List<RoundLevel> buildDefaultLevels({
  required int entryCount,
  required int spotsPerRace,
  required int Function() allocateId,
}) {
  final plans = proposeLevels(entryCount: entryCount, spotsPerRace: spotsPerRace);
  final levels = <RoundLevel>[];
  List<int> previousIds = const [];
  for (final plan in plans) {
    final races = <ProgrammeRace>[];
    for (var n = 1; n <= plan.raceCount; n++) {
      races.add(ProgrammeRace(
        id: allocateId(),
        number: n,
        sourceRaceIds: previousIds,
      ));
    }
    levels.add(RoundLevel(type: plan.type, races: races));
    previousIds = races.map((r) => r.id).toList();
  }
  return levels;
}
