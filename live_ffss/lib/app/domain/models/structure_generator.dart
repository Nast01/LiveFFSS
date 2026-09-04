import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/race_format_detail.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';

/// A proposed level: its round type and how many races it holds. The caller
/// materialises `ProgrammeRace`s (with ids) from this.
typedef LevelPlan = ({RoundType type, int raceCount});

/// What a round the operator adds by hand starts with. The counts come from
/// how the FFSS runs a bracket: 4 quarts and 2 demies each qualifying 8, a
/// single finale qualifying nobody. A série has none — its count follows the
/// entry count, which only [proposeLevels] knows.
typedef RoundDefaults = ({int raceCount, int qualifiersPerRace});

RoundDefaults defaultsForRound(RoundType type) => switch (type) {
      RoundType.quart => (raceCount: 4, qualifiersPerRace: 8),
      RoundType.demi => (raceCount: 2, qualifiersPerRace: 8),
      RoundType.finale => (raceCount: 1, qualifiersPerRace: 0),
      RoundType.serie || RoundType.unknown => (
          raceCount: 0,
          qualifiersPerRace: 0
        ),
    };

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

/// Builds the rounds from the `parties` FFSS already holds for a déroulement,
/// which beats guessing from an entry count: the server states how many races
/// each round runs, how many athletes they seat, and how many qualify.
///
/// Rounds are taken in the server's own `order`. A round whose `niveau` code we
/// do not recognise is kept as [RoundType.unknown] rather than dropped —
/// silently losing a round would misrepresent the competition, and the operator
/// can see and fix it.
List<RoundLevel> buildLevelsFromDetails({
  required List<RaceFormatDetail> details,
  required int Function() allocateId,
}) {
  final ordered = [...details]..sort((a, b) => a.order.compareTo(b.order));
  final levels = <RoundLevel>[];
  List<int> previousIds = const [];
  for (final detail in ordered) {
    final races = <ProgrammeRace>[];
    for (var n = 1; n <= detail.numberOfRun; n++) {
      races.add(ProgrammeRace(
        id: allocateId(),
        number: n,
        sourceRaceIds: previousIds,
      ));
    }
    levels.add(RoundLevel(
      type: roundTypeFromApi(detail.level),
      races: races,
      qualifiersPerRace: detail.qualifyingSpots,
      spotsPerRace: detail.spotsPerRace,
      serverId: detail.id,
      qualificationMethod: detail.qualificationMethod,
    ));
    previousIds = races.map((r) => r.id).toList();
  }
  return levels;
}

/// Materialises [proposeLevels] into `RoundLevel`s with allocated
/// `ProgrammeRace`s. Each race is opt2-wired: fed by every race of the
/// previous level (empty `sourceRaceIds` for the first level).
List<RoundLevel> buildDefaultLevels({
  required int entryCount,
  required int spotsPerRace,
  required int Function() allocateId,
}) {
  final plans =
      proposeLevels(entryCount: entryCount, spotsPerRace: spotsPerRace);
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
    levels.add(RoundLevel(
      type: plan.type,
      races: races,
      spotsPerRace: spotsPerRace,
    ));
    previousIds = races.map((r) => r.id).toList();
  }
  return levels;
}

/// [levels] with each round pointing at the `partie` FFSS actually holds for
/// its level, or null when nothing needed changing.
///
/// The `serverId` is the only join between a local round and everything the
/// federation holds — its créneau, its courses, its places, its results. A
/// déroulement deleted and recreated on the federal side leaves every stored
/// id dangling, and the failure is silent: no créneau matches, so the screen
/// simply shows nothing rather than reporting anything.
///
/// Rounds are matched by level, in order, so two rounds of the same level take
/// distinct parties. A round the server declares no equivalent for loses its
/// link rather than borrowing another level's — pointing a semi-final at a
/// final's partie would corrupt far more than it repairs.
List<RoundLevel>? realignServerIds({
  required List<RoundLevel> levels,
  required List<RaceFormatDetail> details,
}) {
  if (details.isEmpty) return null;
  final available = <RoundType, List<int>>{};
  for (final detail in [...details]
    ..sort((a, b) => a.order.compareTo(b.order))) {
    (available[roundTypeFromApi(detail.level)] ??= []).add(detail.id);
  }

  var changed = false;
  final realigned = <RoundLevel>[];
  for (final level in levels) {
    final queue = available[level.type];
    final id = (queue == null || queue.isEmpty) ? 0 : queue.removeAt(0);
    if (id == level.serverId) {
      realigned.add(level);
      continue;
    }
    realigned.add(level.copyWith(serverId: id));
    changed = true;
  }
  return changed ? realigned : null;
}
