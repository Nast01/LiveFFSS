import 'dart:math';

import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/data/services/attendance_service.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/attendance_status.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/heat_draw.dart';
import 'package:live_ffss/app/domain/models/heat_plan.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/race.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';

/// Draws the athletes marked present into the heats of one round level, for a
/// single (race, category) — the scope of an [EventStructure].
///
/// The draw lives only on the device: FFSS has no write endpoint for heats, so
/// it is persisted into the authored programme through [ProgrammeService].
class HeatDrawController extends GetxController {
  HeatDrawController(
    this._raceRepo,
    this._attendance,
    this._programme, {
    Random? random,
  }) : _random = random ?? Random();

  final RaceRepository _raceRepo;
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
      presentAthletes.value = [
        for (final athlete in ofCategory)
          if (attendance[athlete.id] == AttendanceStatus.present) athlete,
      ];
    } on AppException catch (e) {
      error.value = e;
    } finally {
      isLoading.value = false;
    }
  }

  void selectLevel(RoundType type) {
    if (selectedLevel.value == type) return;
    selectedLevel.value = type;
    // The heat count depends on the level's own composition, so a previous
    // draw means nothing here.
    heats.clear();
  }

  void drawFromPresent() {
    if (presentAthletes.isEmpty) {
      message.value = const UiMessageError('heat_draw_no_present');
      return;
    }
    heats.value = drawHeats(
      present: presentAthletes.toList(),
      raceCount: proposeHeatPlan(
        presentCount: presentCount,
        maxSpotsPerRace: spotsPerRace,
      ).raceCount,
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

  List<RoundLevel> _levelsWithDraw(List<RoundLevel> levels, RoundType type) => [
        for (final level in levels)
          if (level.type == type)
            level.copyWith(races: _racesForDraw(level.races))
          else
            level,
      ];

  /// Rebuilds the level's races to match the drawn heat count. Existing races
  /// are reused in order so any downstream `sourceRaceIds` wiring survives;
  /// only the surplus is dropped and the shortfall allocated.
  List<ProgrammeRace> _racesForDraw(List<ProgrammeRace> existing) => [
        for (var i = 0; i < heats.length; i++)
          if (i < existing.length)
            existing[i].copyWith(
              number: i + 1,
              athleteIds: [for (final a in heats[i]) a.id],
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
