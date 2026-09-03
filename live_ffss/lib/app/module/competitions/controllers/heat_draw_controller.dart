import 'dart:math';

import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/data/services/attendance_service.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/attendance_status.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/entry.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/heat_draw.dart';
import 'package:live_ffss/app/domain/models/heat_plan.dart';
import 'package:live_ffss/app/domain/models/lane.dart';
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
    this._programme,
    this._meetings, {
    Random? random,
  }) : _random = random ?? Random();

  final RaceRepository _raceRepo;
  final ClubRepository _clubRepo;
  final AttendanceService _attendance;
  final ProgrammeService _programme;

  /// For the FFSS spots: the drawn line-up is pushed onto each heat's course
  /// when the draw is saved — the spots are what results are entered against.
  final MeetingRepository _meetings;
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

  /// The current draw: one list of entries per heat, in lane order. Entries,
  /// not athletes — a lane seats one engagement whatever its size, so a relay
  /// team of four takes one lane exactly as it does on the federal site.
  final RxList<List<Entry>> heats = <List<Entry>>[].obs;

  /// The plan the heats on screen were drawn with. Null until a draw has run;
  /// [save] writes it back into the structure.
  final Rxn<HeatPlan> pendingPlan = Rxn<HeatPlan>();

  final RxInt engagedCount = 0.obs;

  /// Entries of this category, and the ones that will actually start —
  /// forfeits excluded. Entries, not athletes: a heat seats a relay team in one
  /// lane whatever its size, so the structure is sized on these. [engagedCount]
  /// stays an athlete count, because the presence line counts people.
  final RxInt entryCount = 0.obs;
  final RxInt eligibleCount = 0.obs;

  /// Entries eligible for the draw: not forfeited, and with every one of
  /// their athletes marked present in Engagés — a team missing a member is
  /// not ready to race. For individual épreuves this is exactly "the athlete
  /// is present", as before.
  final RxList<Entry> presentEntries = <Entry>[].obs;

  /// People checked in, for the presence banner — which counts heads, not
  /// engagements: [engagedCount] does too.
  final RxInt presentPeopleCount = 0.obs;

  /// True once the draw has been written into the programme, so the view can
  /// leave the screen.
  final RxBool saved = false.obs;

  /// Competitors the draw will seat — entries, since a lane seats one.
  int get presentCount => presentEntries.length;

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
  ///
  /// Two reasons. A coastal série always asks — the operator is validating
  /// their structure, not being warned. And any round whose declared
  /// composition cannot seat everyone present asks too: nobody but the
  /// operator can decide between running the round they authored and running
  /// the one the turnout forces.
  ///
  /// A round declaring nothing has no déroulement to respect, so it keeps the
  /// direct path rather than opening a dialog with an empty side.
  bool get requiresStructureValidation =>
      ((race.value?.isBeach ?? false) &&
          selectedLevel.value == RoundType.serie) ||
      (hasDeclaredPlan && !declaredPlanSeatsPresent);

  /// Whether the round declares a composition at all. A série added by hand
  /// starts at zero races, unlike a quart, a demi or a finale.
  bool get hasDeclaredPlan => declaredPlan.raceCount > 0;

  /// Whether the round as declared has room for everyone checked in.
  bool get declaredPlanSeatsPresent {
    final plan = declaredPlan;
    return plan.raceCount > 0 &&
        plan.raceCount * plan.spotsPerRace >= presentCount;
  }

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
      final entriesOfCategory =
          entries.where((e) => e.category.id == categoryId).toList();
      entryCount.value = entriesOfCategory.length;
      eligibleCount.value = entriesOfCategory.where((e) => !e.isForfeit).length;

      final attendance = _attendance.forRace(raceId);
      presentPeopleCount.value = ofCategory
          .where((a) => attendance[a.id] == AttendanceStatus.present)
          .length;
      final present = [
        for (final entry in entriesOfCategory)
          if (!entry.isForfeit &&
              entry.athletes.isNotEmpty &&
              entry.athletes
                  .every((a) => attendance[a.id] == AttendanceStatus.present))
            entry,
      ];

      final clubs = await _clubIndex(
          competitionId, [for (final e in present) ...e.athletes]);
      presentEntries.value = clubs.isEmpty
          ? present
          : [
              for (final entry in present)
                entry.copyWith(athletes: [
                  for (final athlete in entry.athletes)
                    athlete.copyWith(club: clubs[athlete.id] ?? athlete.club),
                ]),
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
      for (final entry in heats[heat]) {
        // The resolved club wins over the raw id: the FFSS bucket organisme is
        // split into real clubs on the way in, so an athlete's own clubId can
        // name the bucket while their club names the club. A team counts once
        // — the matrix reads competitors, and a relay team is one.
        final lead = entry.athletes.isNotEmpty ? entry.athletes.first : null;
        final resolved = lead?.club?.id ?? entryClubId(entry);
        final id = resolved > 0 ? resolved : 0;
        final name = lead?.club?.name ?? '';
        labels[id] ??= name.isNotEmpty ? name : (lead?.clubLabel ?? '');
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

  /// Draws the round as the déroulement declares it, for the rounds that need
  /// no validation.
  ///
  /// The heat count comes from the structure the organiser settled on, not
  /// from the turnout. Recomputing it here quietly authored a different round
  /// — and [save] then wrote that count back over the declared one, so a draw
  /// could shrink a structure nobody had touched.
  ///
  /// Falls back to the proposal only when the round declares nothing to
  /// respect; [requiresStructureValidation] sends every other mismatch to the
  /// operator first.
  void drawFromDeclared() =>
      drawWithPlan(declaredPlanSeatsPresent ? declaredPlan : proposedPlan);

  void drawWithPlan(HeatPlan plan) {
    if (presentEntries.isEmpty) {
      message.trigger(const UiMessageError('heat_draw_no_present'));
      return;
    }
    pendingPlan.value = plan;
    heats.value = drawHeats(
      present: presentEntries.toList(),
      raceCount: plan.raceCount,
      random: _random,
    );
  }

  /// Moves [entry] to the end of [targetHeat], removing it from wherever it
  /// currently sits. A no-op when the entry is already in that heat. A relay
  /// team moves as one — its athletes have no lane of their own.
  void moveEntry(Entry entry, int targetHeat) {
    if (targetHeat < 0 || targetHeat >= heats.length) return;
    final updated = [
      for (final heat in heats)
        [
          for (final e in heat)
            if (e.id != entry.id) e,
        ],
    ];
    if (updated[targetHeat].any((e) => e.id == entry.id)) return;
    updated[targetHeat].add(entry);
    heats.value = updated;
  }

  int heatIndexOf(Entry entry) =>
      heats.indexWhere((heat) => heat.any((e) => e.id == entry.id));

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
    // The local save stands whatever the push does: the operator chose to keep
    // a draw on the device and be told what could not leave it.
    saved.value = true;

    final drawn = _savedRaces(structures, level);
    final report = await _pushLanes(drawn);
    if (report.failed > 0) {
      message.trigger(UiMessageError('heat_draw_lanes_failed',
          details: '${report.failed}/${drawn.length}'));
    } else if (report.unlinked > 0) {
      message.trigger(UiMessageError('heat_draw_lanes_unplaced',
          details: '${report.unlinked}/${drawn.length}'));
    } else {
      message.trigger(const UiMessageSuccess('heat_draw_saved_pushed'));
    }
  }

  List<ProgrammeRace> _savedRaces(
    List<EventStructure> structures,
    RoundType type,
  ) {
    for (final s in structures) {
      if (s.raceId != race.value?.id || s.categoryId != categoryId) continue;
      for (final level in s.levels) {
        if (level.type == type) return level.races;
      }
    }
    return const [];
  }

  /// Pushes each drawn heat onto the FFSS spots of its course — the spots are
  /// what results are entered against on the federal side.
  ///
  /// [unlinked] counts the heats whose round has no course on the programme
  /// yet: nothing to push onto, the operator places the round and saves again.
  /// [failed] counts the ones whose push did not fully land. Reading the
  /// réunions first is not optional: pushing blind would create spots beside
  /// the default ones instead of rewriting them.
  Future<({int unlinked, int failed})> _pushLanes(
    List<ProgrammeRace> drawn,
  ) async {
    final linked = <ProgrammeRace>[];
    var unlinked = 0;
    for (final race in drawn) {
      if (race.entryIds.isEmpty) continue;
      race.runId != 0 ? linked.add(race) : unlinked++;
    }
    if (linked.isEmpty) return (unlinked: unlinked, failed: 0);

    final competitionId = competition.value?.id;
    Map<int, List<Lane>>? existingByRun;
    if (competitionId != null) {
      try {
        final meetings = await _meetings.getMeetings(competitionId);
        existingByRun = {
          for (final meeting in meetings)
            for (final slot in meeting.slots)
              for (final run in slot.runs) run.id: run.lanes,
        };
      } on AppException {
        existingByRun = null;
      }
    }
    if (existingByRun == null) {
      return (unlinked: unlinked, failed: linked.length);
    }

    var failed = 0;
    for (final race in linked) {
      try {
        final synced = await _meetings.syncLanes(
          runId: race.runId,
          entryIds: race.entryIds,
          existing: existingByRun[race.runId] ?? const [],
        );
        if (synced < race.entryIds.length) failed++;
      } on AppException {
        failed++;
      }
    }
    return (unlinked: unlinked, failed: failed);
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
              entryIds: [for (final e in heats[i]) e.id],
              athleteIds: [
                for (final e in heats[i]) ...e.athletes.map((a) => a.id),
              ],
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
              entryIds: [for (final e in heats[i]) e.id],
              athleteIds: [
                for (final e in heats[i]) ...e.athletes.map((a) => a.id),
              ],
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
