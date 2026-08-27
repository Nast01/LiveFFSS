import 'dart:math';

import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/data/services/attendance_service.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/attendance_status.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/heat_draw.dart';
import 'package:live_ffss/app/domain/models/heat_plan.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/race.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/presentation/modules/competitions/race_formatting.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';

/// Draws the athletes marked present into the heats of one round level, for a
/// single (race, category) — the scope of an [EventStructure].
///
/// The draw lives only on the device: FFSS has no write endpoint for heats, so
/// it is persisted into the authored programme through [ProgrammeService].
class HeatDrawController extends GetxController {
  HeatDrawController(
    this._raceRepo,
    this._clubRepo,
    this._attendance,
    this._programme, {
    Random? random,
  }) : _random = random ?? Random();

  final RaceRepository _raceRepo;
  final ClubRepository _clubRepo;
  final AttendanceService _attendance;
  final ProgrammeService _programme;
  final Random _random;

  final Rxn<Race> race = Rxn<Race>();
  final Rxn<Competition> competition = Rxn<Competition>();
  int categoryId = 0;
  String categoryLabel = '';

  final RxBool isLoading = true.obs;
  final Rxn<AppException> error = Rxn<AppException>();
  final Rxn<UiMessage> message = Rxn<UiMessage>();

  /// Levels the authored structure declares for this (race, category).
  final RxList<RoundType> availableLevels = <RoundType>[].obs;
  final Rxn<RoundType> selectedLevel = Rxn<RoundType>();

  /// The current draw: one list of athletes per heat, in lane order.
  final RxList<List<Athlete>> heats = <List<Athlete>>[].obs;

  /// The plan the heats on screen were drawn with. Null until a draw has run;
  /// [save] writes it back into the structure.
  final Rxn<HeatPlan> pendingPlan = Rxn<HeatPlan>();

  final RxInt engagedCount = 0.obs;

  /// Athletes eligible for the draw — those marked present in Engagés.
  final RxList<Athlete> presentAthletes = <Athlete>[].obs;

  /// True once the draw has been written into the programme, so the view can
  /// leave the screen.
  final RxBool saved = false.obs;

  int get presentCount => presentAthletes.length;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is! Map) {
      isLoading.value = false;
      return;
    }
    final r = arg['race'];
    final c = arg['competition'];
    if (r is Race) race.value = r;
    if (c is Competition) competition.value = c;
    final id = arg['categoryId'];
    if (id is int) categoryId = id;
    // Optional: the caller may open the draw on a given round (the Séries tab
    // does, on the one it is showing). Absent, load() falls back to the first
    // round of the structure.
    final round = arg['roundType'];
    if (round is RoundType) selectedLevel.value = round;
    final label = arg['categoryLabel'];
    if (label is String) categoryLabel = label;
    load();
  }

  EventStructure? get structure {
    final raceId = race.value?.id;
    if (raceId == null) return null;
    for (final s
        in _programme.current.value?.structures ?? const <EventStructure>[]) {
      if (s.raceId == raceId && s.categoryId == categoryId) return s;
    }
    return null;
  }

  /// Race size of the selected round. Falls back to the structure default for
  /// rounds authored before the size became per-round.
  int get spotsPerRace {
    final s = structure;
    if (s == null) return 0;
    final level = _levelOf(selectedLevel.value);
    return level == null ? s.spotsPerRace : s.spotsForLevel(level);
  }

  /// Whether the selected level already carries a drawn composition, which the
  /// view confirms before overwriting.
  bool get hasExistingComposition {
    final level = _levelOf(selectedLevel.value);
    return level != null && level.races.any((r) => r.athleteIds.isNotEmpty);
  }

  /// Whether the operator must validate the structure before this draw runs.
  /// Coastal séries only: a pool draw keeps the direct path, and a bracket
  /// round is seated by its qualifiers rather than by who is on the beach.
  bool get requiresStructureValidation =>
      (race.value?.isBeach ?? false) && selectedLevel.value == RoundType.serie;

  /// The selected round exactly as authored.
  HeatPlan get declaredPlan => (
        raceCount: _levelOf(selectedLevel.value)?.races.length ?? 0,
        spotsPerRace: spotsPerRace,
      );

  /// What the athletes actually present call for, capped by the authored
  /// race size — the water's capacity does not change because people are late.
  HeatPlan get proposedPlan => proposeHeatPlan(
        presentCount: presentCount,
        maxSpotsPerRace: declaredPlan.spotsPerRace,
      );

  Future<void> load() async {
    final raceId = race.value?.id;
    final competitionId = competition.value?.id;
    if (raceId == null || competitionId == null) {
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    error.value = null;
    try {
      await _programme.load(competitionId);
      availableLevels.value = (structure?.levels ?? const <RoundLevel>[])
          .map((l) => l.type)
          .toList();
      selectedLevel.value ??=
          availableLevels.isNotEmpty ? availableLevels.first : null;

      final entries = await _raceRepo.getEntries(raceId);
      // A race can span several categories; only this structure's own athletes
      // may be drawn into its heats.
      final ofCategory = [
        for (final entry in entries)
          if (entry.category.id == categoryId) ...entry.athletes,
      ];
      engagedCount.value = ofCategory.length;

      final attendance = _attendance.forRace(raceId);
      final present = [
        for (final athlete in ofCategory)
          if (attendance[athlete.id] == AttendanceStatus.present) athlete,
      ];

      final clubs = await _clubIndex(competitionId, present);
      presentAthletes.value = clubs.isEmpty
          ? present
          : [
              for (final athlete in present)
                athlete.copyWith(club: clubs[athlete.id] ?? athlete.club),
            ];
    } on AppException catch (e) {
      error.value = e;
    } finally {
      isLoading.value = false;
    }
  }

  /// Athlete id → club, so a drawn lane can show its club's logo or cap.
  /// `Athlete.club` is never deserialised — a controller has to resolve it.
  ///
  /// Best-effort: a failure leaves an empty index and every lane falls back to
  /// the club initial rather than taking the draw screen down.
  Future<Map<int, Club>> _clubIndex(
    int competitionId,
    List<Athlete> athletes,
  ) async {
    try {
      return await _clubRepo.getAthleteClubs(competitionId, athletes);
    } on AppException {
      return const {};
    }
  }

  /// How each club is spread across the drawn heats — one row per club, one
  /// cell per heat, biggest club first so the ones the draw had to work hardest
  /// to spread are read first. Ties break on the label so the order does not
  /// wobble between redraws.
  ///
  /// Unaffiliated athletes are pooled into a single trailing row (`clubId` 0).
  /// They share no club, so that row records a headcount, never a clustering.
  List<ClubSpread> get clubDistribution {
    if (heats.isEmpty) return const [];
    final labels = <int, String>{};
    final counts = <int, List<int>>{};
    for (var heat = 0; heat < heats.length; heat++) {
      for (final athlete in heats[heat]) {
        // The resolved club wins over the raw id: the FFSS bucket organisme is
        // split into real clubs on the way in, so an athlete's own clubId can
        // name the bucket while their club names the club.
        final resolved = athlete.club?.id ?? athlete.clubId;
        final id = resolved > 0 ? resolved : 0;
        final name = athlete.club?.name ?? '';
        labels[id] ??= name.isNotEmpty ? name : athlete.clubLabel;
        (counts[id] ??= List.filled(heats.length, 0))[heat]++;
      }
    }
    final rows = [
      for (final entry in counts.entries)
        (
          clubId: entry.key,
          label: labels[entry.key] ?? '',
          perHeat: entry.value,
          total: entry.value.fold(0, (a, b) => a + b),
        ),
    ];
    rows.sort((a, b) {
      // The unaffiliated pool is not a club; it never competes for the top.
      if ((a.clubId == 0) != (b.clubId == 0)) return a.clubId == 0 ? 1 : -1;
      final byTotal = b.total.compareTo(a.total);
      return byTotal != 0 ? byTotal : a.label.compareTo(b.label);
    });
    return rows;
  }

  void selectLevel(RoundType type) {
    if (selectedLevel.value == type) return;
    selectedLevel.value = type;
    // The heat count depends on the level's own composition, so a previous
    // draw — and the plan it was drawn with — mean nothing here.
    discardDraw();
  }

  /// Clears a draw that no longer matches what's on screen: the round
  /// changed, or the operator edited the structure the heats were drawn
  /// against and backed out of the dialog instead of confirming a new draw.
  /// Leaving stale heats visible — or worse, savable — would reproduce the
  /// silent-rewrite bug this feature exists to fix, through its own escape
  /// hatch.
  void discardDraw() {
    heats.clear();
    pendingPlan.value = null;
  }

  /// Draws without validation, for the rounds that need none — a pool race, or
  /// a bracket round. The count follows the athletes present, which is what
  /// this path has always done.
  void drawFromPresent() => drawWithPlan(proposedPlan);

  void drawWithPlan(HeatPlan plan) {
    if (presentAthletes.isEmpty) {
      message.value = const UiMessageError('heat_draw_no_present');
      return;
    }
    pendingPlan.value = plan;
    heats.value = drawHeats(
      present: presentAthletes.toList(),
      raceCount: plan.raceCount,
      random: _random,
    );
  }

  /// Moves [athlete] to the end of [targetHeat], removing them from wherever
  /// they currently sit. A no-op when the athlete is already in that heat.
  void moveAthlete(Athlete athlete, int targetHeat) {
    if (targetHeat < 0 || targetHeat >= heats.length) return;
    final updated = [
      for (final heat in heats)
        [
          for (final a in heat)
            if (a.id != athlete.id) a,
        ],
    ];
    if (updated[targetHeat].any((a) => a.id == athlete.id)) return;
    updated[targetHeat].add(athlete);
    heats.value = updated;
  }

  int heatIndexOf(Athlete athlete) =>
      heats.indexWhere((heat) => heat.any((a) => a.id == athlete.id));

  Future<void> save() async {
    final level = selectedLevel.value;
    final programme = _programme.current.value;
    if (level == null || programme == null || heats.isEmpty) return;

    final structures = [
      for (final s in programme.structures)
        if (s.raceId == race.value?.id && s.categoryId == categoryId)
          s.copyWith(levels: _levelsWithDraw(s.levels, level))
        else
          s,
    ];
    await _programme.save(
      (_programme.current.value ?? programme).copyWith(structures: structures),
    );
    message.value = const UiMessageSuccess('heat_draw_saved');
    saved.value = true;
  }

  List<RoundLevel> _levelsWithDraw(List<RoundLevel> levels, RoundType type) {
    final drawnAt = levels.indexWhere((l) => l.type == type);
    if (drawnAt < 0) return levels;

    final updated = [...levels];
    final drawn = updated[drawnAt];
    updated[drawnAt] = drawn.copyWith(
      races: _racesForDraw(drawn.races),
      // Only the validated coastal série path may change the round's
      // declared capacity — that's the whole point of asking the operator to
      // confirm it first. Every other path (pool, or a coastal bracket round)
      // draws however many are present but must never let that count ratchet
      // the round's authored size; `drawn.spotsPerRace` keeps it fixed there.
      // The `?? drawn.spotsPerRace` fallback stays defensive: `pendingPlan`
      // and `heats` are set together by `drawWithPlan` and cleared together
      // by `selectLevel`, so `save()` cannot currently reach this with heats
      // drawn and no plan even on the validated path.
      spotsPerRace: requiresStructureValidation
          ? (pendingPlan.value?.spotsPerRace ?? drawn.spotsPerRace)
          : drawn.spotsPerRace,
    );

    final removed = {for (final r in drawn.races) r.id}
        .difference({for (final r in updated[drawnAt].races) r.id});
    if (removed.isEmpty) return updated;

    // A shrunk round deletes races the later ones may still list as their
    // source. Leaving those ids behind would have the operator validate a
    // structure whose bracket is quietly broken.
    for (var i = drawnAt + 1; i < updated.length; i++) {
      updated[i] = updated[i].copyWith(
        races: [
          for (final race in updated[i].races)
            race.copyWith(
              sourceRaceIds: [
                for (final id in race.sourceRaceIds)
                  if (!removed.contains(id)) id,
              ],
            ),
        ],
      );
    }
    return updated;
  }

  /// Rebuilds the level's races to match the drawn heat count. Existing races
  /// are reused in order so any downstream `sourceRaceIds` wiring survives;
  /// only the surplus is dropped and the shortfall allocated.
  List<ProgrammeRace> _racesForDraw(List<ProgrammeRace> existing) => [
        for (var i = 0; i < heats.length; i++)
          if (i < existing.length)
            existing[i].copyWith(
              number: i + 1,
              athleteIds: [for (final a in heats[i]) a.id],
              // A redraw invalidates any recorded result outright: the
              // athletes who crossed the line no longer match who is seated
              // here. The confirmation dialog above this call is what makes
              // discarding it safe.
              finishOrder: const [],
              penalties: const [],
            )
          else
            ProgrammeRace(
              id: _programme.allocateId(),
              number: i + 1,
              athleteIds: [for (final a in heats[i]) a.id],
            ),
      ];

  RoundLevel? _levelOf(RoundType? type) {
    if (type == null) return null;
    for (final level in structure?.levels ?? const <RoundLevel>[]) {
      if (level.type == type) return level;
    }
    return null;
  }
}

/// One club's spread across the drawn heats: [perHeat] holds one count per
/// heat, in heat order, so the view can render it as a row of the matrix.
/// [clubId] is 0 for the pooled unaffiliated athletes.
typedef ClubSpread = ({
  int clubId,
  String label,
  List<int> perHeat,
  int total,
});
