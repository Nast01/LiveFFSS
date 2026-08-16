/// How many races a round runs, and how many athletes each one seats.
typedef HeatPlan = ({int raceCount, int spotsPerRace});

/// The plan [presentCount] athletes call for, given the water's capacity.
///
/// Lane count is a physical constraint of the course, so [maxSpotsPerRace] is a
/// ceiling rather than a target: the proposal runs the fewest heats that keep
/// every heat within it, then tightens the seats onto what the draw will really
/// produce. 20 athletes over a capacity of 16 run 2 heats of 10 — a structure
/// claiming 2 of 16 would describe a draw that never happens, and the operator
/// is being asked to validate that structure.
HeatPlan proposeHeatPlan({
  required int presentCount,
  required int maxSpotsPerRace,
}) {
  if (presentCount <= 0) return (raceCount: 0, spotsPerRace: 0);
  // An unauthored round declares no capacity; seat everyone rather than
  // dividing by zero.
  if (maxSpotsPerRace <= 0) return (raceCount: 1, spotsPerRace: presentCount);
  final raceCount = (presentCount / maxSpotsPerRace).ceil();
  return (
    raceCount: raceCount,
    spotsPerRace: (presentCount / raceCount).ceil(),
  );
}
