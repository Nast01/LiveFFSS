import 'dart:async';

import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/core/rfid/bracelet_payload.dart';
import 'package:live_ffss/app/core/rfid/rfid_writer.dart';
import 'dart:math';

import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/course_penalty.dart';
import 'package:live_ffss/app/domain/models/course_ranking.dart';
import 'package:live_ffss/app/domain/models/entry.dart';
import 'package:live_ffss/app/domain/models/heat_draw.dart';
import 'package:live_ffss/app/domain/models/lane.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';
import 'package:live_ffss/app/domain/models/qualification.dart';
import 'package:live_ffss/app/domain/models/run.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/race.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';

/// How places are entered.
///
/// [automatic] hands out the next place on a press — the marshalling flow, and
/// what a bracelet scan drives. [manual] lets the operator type a rank
/// straight onto a row, to correct rather than to record.
enum CourseEntryMode { automatic, manual }

/// Records the finishing order of one drawn course. The order is the state;
/// places are computed from it (see `course_ranking.dart`), which is what makes
/// a removal renumber and a tie an ordinary group.
///
/// Device-local: FFSS documents no write endpoint for a result, so everything
/// here persists into the authored programme through [ProgrammeService].
class RaceCourseController extends GetxController {
  RaceCourseController(
    this._programme,
    this._raceRepo,
    this._clubRepo,
    this._rfid,
    this._meetings, {
    Random? random,
  }) : _random = random ?? Random();

  final ProgrammeService _programme;
  final RaceRepository _raceRepo;
  final ClubRepository _clubRepo;
  final RfidWriter _rfid;
  final MeetingRepository _meetings;
  final Random _random;

  /// The FFSS `serie` this course's results hang off, once created. Kept so a
  /// second validation rewrites it rather than stacking a new one.
  int _heatId = 0;

  /// True while a validation is in flight, so the button can stand down.
  final RxBool isPublishing = false.obs;

  final Rxn<Race> race = Rxn<Race>();
  final Rxn<Competition> competition = Rxn<Competition>();
  int? categoryId;
  String categoryLabel = '';
  RoundType roundType = RoundType.unknown;
  int raceNumber = 0;
  int? programmeRaceId;

  final RxBool isLoading = true.obs;

  /// The line-up, in the order the draw left it.
  final RxList<Athlete> athletes = <Athlete>[].obs;

  /// Finishing groups, in order. A group of several is a declared tie.
  final RxList<List<int>> finishOrder = <List<int>>[].obs;

  /// Athletes out of the ranking. Kept apart from [finishOrder] precisely so
  /// they take no place — the athletes after them number as though they had
  /// not started.
  final RxList<CoursePenalty> penalties = <CoursePenalty>[].obs;

  final RxBool isScanning = false.obs;
  final Rxn<UiMessage> message = Rxn<UiMessage>();
  StreamSubscription<String>? _scanSub;

  /// While set, the next athlete entered joins the last group rather than
  /// opening one. A lock rather than a gesture on a ranked athlete, because a
  /// bracelet cannot be long-pressed and one procedure has to serve both.
  final RxBool tieLock = false.obs;

  /// Which way places are entered. Switching does not touch the ranking
  /// already entered: one switches to correct, not to start over.
  final Rx<CourseEntryMode> entryMode = CourseEntryMode.automatic.obs;

  void setEntryMode(CourseEntryMode mode) => entryMode.value = mode;

  @override
  void onInit() {
    super.onInit();
    applyArguments(Get.arguments);
    load();
  }

  void applyArguments(Object? arg) {
    if (arg is! Map) return;
    final r = arg['race'];
    if (r is Race) race.value = r;
    final c = arg['competition'];
    if (c is Competition) competition.value = c;
    final cid = arg['categoryId'];
    if (cid is int) categoryId = cid;
    final cl = arg['categoryLabel'];
    if (cl is String) categoryLabel = cl;
    final rt = arg['roundType'];
    if (rt is RoundType) roundType = rt;
    final rn = arg['raceNumber'];
    if (rn is int) raceNumber = rn;
    final pid = arg['programmeRaceId'];
    if (pid is int) programmeRaceId = pid;
  }

  Future<void> load() async {
    final raceIdValue = race.value?.id;
    final competitionIdValue = competition.value?.id;
    if (raceIdValue == null || competitionIdValue == null) {
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    try {
      await _programme.load(competitionIdValue);
      final stored = _storedRace();
      finishOrder.value = [
        for (final group in stored?.finishOrder ?? const <List<int>>[])
          [...group],
      ];
      penalties.value = [...?stored?.penalties];

      final entries = await _raceRepo.getEntries(raceIdValue);
      final byId = <int, Athlete>{
        for (final entry in entries)
          for (final athlete in entry.athletes) athlete.id: athlete,
      };
      // The draw's order is the line-up's order; an id no entry accounts for is
      // an athlete withdrawn since, and is dropped rather than shown blank.
      final lineUp = [
        for (final id in stored?.athleteIds ?? const <int>[])
          if (byId[id] case final Athlete athlete) athlete,
      ];

      Map<int, Club> clubs;
      try {
        clubs = await _clubRepo.getAthleteClubs(competitionIdValue, lineUp);
      } on AppException {
        clubs = const {};
      }
      athletes.value = [
        for (final athlete in lineUp)
          athlete.copyWith(club: clubs[athlete.id] ?? athlete.club),
      ];
    } on AppException {
      // The line-up is unavailable; the screen shows an empty course rather
      // than failing outright, and reopening it retries.
      athletes.clear();
    } finally {
      isLoading.value = false;
    }
  }

  int get nextPlaceValue => nextPlace(finishOrder);

  int? placeOf(Athlete athlete) => placesOf(finishOrder)[athlete.id];

  /// Ranked athletes first in place order, then those still to come in the
  /// order the draw left them. The finished screen is the result itself, which
  /// is why there is no separate recap to build or to keep in step.
  List<Athlete> get orderedAthletes {
    final places = placesOf(finishOrder);
    final ranked = [
      for (final athlete in athletes)
        if (places.containsKey(athlete.id)) athlete,
    ]..sort((a, b) => places[a.id]!.compareTo(places[b.id]!));
    return [
      ...ranked,
      for (final athlete in athletes)
        if (!places.containsKey(athlete.id) && penaltyOf(athlete) == null)
          athlete,
      for (final athlete in athletes)
        if (penaltyOf(athlete) != null) athlete,
    ];
  }

  void assign(Athlete athlete) {
    // A withdrawal takes no place: ranking a forfeit or a disqualification
    // here would corrupt every place after it, exactly the invariant
    // setPenalty protects when a ranked athlete is withdrawn. Reinstating is
    // a deliberate act — clearPenalty, offered from the row menu — not
    // something a scan should do as a side effect.
    if (penaltyOf(athlete) != null) {
      message.trigger(const UiMessageError('course_athlete_withdrawn'));
      return;
    }
    // A bracelet read twice, or a row tapped twice, must report rather than
    // silently re-persist the same order — the operator has no other way to
    // tell a good read from a duplicate.
    if (placeOf(athlete) != null) {
      message.trigger(const UiMessageError('course_athlete_already_ranked'));
      return;
    }
    finishOrder.value =
        withFinisher(finishOrder, athlete.id, tied: tieLock.value);
    _persist();
  }

  /// Puts [athlete] at [place], or takes them out of the ranking when [place]
  /// is not a place — an emptied field.
  ///
  /// Sharing a rank with someone declares a tie, and the places after it shift
  /// accordingly; see [withPlace].
  void setPlace(Athlete athlete, int place) {
    // Same invariant `assign` protects: a withdrawal takes no place, and
    // ranking one here would falsify every place behind it.
    if (penaltyOf(athlete) != null) {
      message.trigger(const UiMessageError('course_athlete_withdrawn'));
      return;
    }
    finishOrder.value = place < 1
        ? withoutAthlete(finishOrder, athlete.id)
        : withPlace(finishOrder, athlete.id, place);
    _persist();
  }

  void remove(Athlete athlete) {
    finishOrder.value = withoutAthlete(finishOrder, athlete.id);
    _persist();
  }

  void undo() {
    finishOrder.value = withoutLastFinisher(finishOrder);
    _persist();
  }

  void toggleTieLock() => tieLock.value = !tieLock.value;

  CoursePenalty? penaltyOf(Athlete athlete) {
    for (final penalty in penalties) {
      if (penalty.athleteId == athlete.id) return penalty;
    }
    return null;
  }

  /// Marks an athlete out of the ranking, pulling them out of the order first:
  /// a disqualified swimmer who had already been placed must not keep a place.
  void setPenalty(
    Athlete athlete,
    CoursePenaltyKind kind, {
    String code = '',
  }) {
    finishOrder.value = withoutAthlete(finishOrder, athlete.id);
    penalties.value = [
      for (final penalty in penalties)
        if (penalty.athleteId != athlete.id) penalty,
      CoursePenalty(athleteId: athlete.id, kind: kind, code: code),
    ];
    _persist();
  }

  void clearPenalty(Athlete athlete) {
    penalties.value = [
      for (final penalty in penalties)
        if (penalty.athleteId != athlete.id) penalty,
    ];
    _persist();
  }

  /// Whether every athlete is accounted for — placed or withdrawn. This is what
  /// ends a scanning session, and why the highest place a course hands out is
  /// its line-up minus its withdrawals.
  bool get isComplete {
    final places = placesOf(finishOrder);
    return athletes.every(
      (a) => places.containsKey(a.id) || penaltyOf(a) != null,
    );
  }

  bool get canScan => _rfid.isSupported;

  /// Opens a continuous read session. Each bracelet whose licence matches an
  /// athlete of this course takes the next place, tie lock included — the same
  /// procedure as a tap, which is the whole reason the lock is a mode rather
  /// than a gesture.
  void startScan() {
    if (isScanning.value || isComplete) return;
    isScanning.value = true;
    _scanSub = _rfid.readBracelets().listen(
      _onBracelet,
      onError: (Object e) {
        message.trigger(UiMessageError(
          e is RfidException ? e.message : 'bracelet_unreadable',
        ));
      },
    );
  }

  void stopScan() {
    _scanSub?.cancel();
    _scanSub = null;
    isScanning.value = false;
  }

  void _onBracelet(String payload) {
    final licence = parseBraceletLicence(payload);
    Athlete? match;
    for (final athlete in athletes) {
      if (athlete.licenseeNumber == licence) {
        match = athlete;
        break;
      }
    }
    if (match == null) {
      message.trigger(const UiMessageError('course_bracelet_not_in_race'));
      return;
    }
    assign(match);
    // Nothing left to place: holding the hardware open would only invite a
    // stray read.
    if (isComplete) stopScan();
  }

  @override
  void onClose() {
    _scanSub?.cancel();
    super.onClose();
  }

  /// A race can be shared by two categories (Junior and Senior heats of the
  /// same 50m event), which produces two structures with the same [Race.id]
  /// and different `categoryId`. Only "we know the category and it differs"
  /// rules a structure out — an unset [categoryId] must not rule out every
  /// structure and silently persist nothing.
  bool _isOtherStructure(EventStructure structure) =>
      structure.raceId != race.value?.id ||
      (categoryId != null && structure.categoryId != categoryId);

  ProgrammeRace? _storedRace() {
    for (final structure
        in _programme.current.value?.structures ?? const <EventStructure>[]) {
      if (_isOtherStructure(structure)) continue;
      for (final level in structure.levels) {
        for (final stored in level.races) {
          if (stored.id == programmeRaceId) return stored;
        }
      }
    }
    return null;
  }

  /// Writes the order back into the programme. Not awaited: entering a result
  /// must feel instant, and there is no Save button to fall back on — a marshal
  /// does not save, and losing a session's entries is not a trade worth making.
  /// A failure is still surfaced, just asynchronously: silence here would mean
  /// the operator has no way to know the entry they just made never landed.
  void _persist() {
    final current = _programme.current.value;
    if (current == null || programmeRaceId == null) return;
    _programme
        .save(current.copyWith(
      structures: [
        for (final structure in current.structures)
          if (_isOtherStructure(structure))
            structure
          else
            structure.copyWith(
              levels: [
                for (final level in structure.levels)
                  level.copyWith(
                    races: [
                      for (final stored in level.races)
                        if (stored.id == programmeRaceId)
                          stored.copyWith(
                            finishOrder: [
                              for (final group in finishOrder) [...group],
                            ],
                            penalties: [...penalties],
                          )
                        else
                          stored,
                    ],
                  ),
              ],
            ),
      ],
    ))
        // ProgrammeService.save() writes through FlutterSecureStorage, which
        // throws a PlatformException — not an AppException — on failure; that
        // is the type this actually has to catch.
        .catchError((Object _) {
      message.trigger(const UiMessageError('course_save_failed'));
    });
  }

  /// Publishes this course on FFSS and reseeds the round that follows.
  ///
  /// Three steps, in order: one result per lane hung off the course's `serie`,
  /// then the qualifiers computed from every course of the round already run,
  /// then those qualifiers drawn into the next round and pushed onto its
  /// places.
  ///
  /// Deliberately re-runnable: each press recomputes the next round whole,
  /// from all the courses run so far, so validating Demie 2 after Demie 1 adds
  /// its qualifiers instead of replacing them.
  Future<void> validate() async {
    if (isPublishing.value) return;
    final race = this.race.value;
    final competition = this.competition.value;
    final stored = _storedRace();
    if (race == null || competition == null || stored == null) return;

    if (stored.runId == 0) {
      message.trigger(const UiMessageError('course_publish_unplaced'));
      return;
    }

    isPublishing.value = true;
    try {
      final meetings = await _meetings.getMeetings(competition.id);
      final located = _locate(meetings, stored.runId);
      if (located == null) {
        message.trigger(const UiMessageError('course_publish_unplaced'));
        return;
      }
      final (slotId, run) = located;

      final seats = await _meetings.getLaneSeats(
        [for (final lane in run.lanes) lane.id],
      );
      if (seats.isEmpty) {
        message.trigger(const UiMessageError('course_publish_no_lane'));
        return;
      }

      final heatId = await _meetings.publishCourseResults(
        raceId: race.id,
        heatName: run.name,
        heatNumber: raceNumber,
        outcomes: _outcomesFor(seats),
        heatId: _heatId == 0 ? null : _heatId,
        link: (
          slotId: slotId,
          runId: run.id,
          runName: run.name,
          beginHour: run.beginTime,
          endHour: run.endTime,
          site: run.site,
        ),
      );
      if (heatId == 0) {
        message.trigger(const UiMessageError('course_publish_failed'));
        return;
      }
      _heatId = heatId;

      await _seedNextRound(race, meetings);
      message.trigger(const UiMessageSuccess('course_published'));
    } on AppException catch (e) {
      message
          .trigger(UiMessageError('course_publish_failed', details: e.detail));
    } finally {
      isPublishing.value = false;
    }
  }

  /// The course [runId] names, with the créneau holding it — `course/submit`
  /// rewrites the whole course, so the link needs both.
  (int, Run)? _locate(List<Meeting> meetings, int runId) {
    for (final meeting in meetings) {
      for (final slot in meeting.slots) {
        for (final run in slot.runs) {
          if (run.id == runId) return (slot.id, run);
        }
      }
    }
    return null;
  }

  /// One outcome per seated engagement: its rank when it finished, its status
  /// otherwise. A team races as one, so any of its athletes speaks for it.
  List<CourseOutcome> _outcomesFor(List<LaneSeat> seats) {
    final places = placesOf(finishOrder);
    final penaltyOf = <int, CoursePenalty>{
      for (final penalty in penalties) penalty.athleteId: penalty,
    };
    return [
      for (final seat in seats)
        () {
          CoursePenalty? penalty;
          int? place;
          for (final athleteId in seat.athleteIds) {
            penalty ??= penaltyOf[athleteId];
            place ??= places[athleteId];
          }
          final status = switch (penalty?.kind) {
            CoursePenaltyKind.disqualified => 1,
            CoursePenaltyKind.forfeit => 2,
            // An unknown kind is still out of the ranking; calling it a
            // disqualification would invent a decision the referee did not make,
            // so it goes out as a plain forfeit.
            CoursePenaltyKind.unknown => 2,
            null => 0,
          };
          return (
            entryId: seat.entryId,
            laneId: seat.laneId,
            // Out of the ranking takes no place: sending one would put them
            // back in the classification.
            rank: penalty == null ? place : null,
            status: status,
            complement: (penalty?.code.isEmpty ?? true) ? null : penalty!.code,
          );
        }(),
    ];
  }

  /// Recomputes the next round from every course of this one already run, then
  /// writes it locally and onto the FFSS places.
  Future<void> _seedNextRound(Race race, List<Meeting> meetings) async {
    final programme = _programme.current.value;
    if (programme == null) return;
    final structure = _structure(programme);
    if (structure == null) return;

    final at = structure.levels.indexWhere((l) => l.type == roundType);
    if (at < 0 || at + 1 >= structure.levels.length) return;
    final current = structure.levels[at];
    final next = structure.levels[at + 1];

    final qualified = qualifiedEntries(
      rankedByRace: [
        for (final stored in current.races) _rankedEntriesOf(stored),
      ],
      method: current.qualificationMethod,
      spots: current.qualifiersPerRace,
    );
    if (qualified.isEmpty) return;

    final entries = await _entriesById();
    final drawn = drawHeats(
      present: [
        for (final id in qualified)
          if (entries[id] case final Entry entry) entry,
      ],
      raceCount: next.races.length,
      random: _random,
    );
    if (drawn.isEmpty) return;

    // A course already run is never reseeded: losing a finish order to a
    // requalification would be worse than any stale line-up.
    final seeded = <ProgrammeRace>[];
    for (var i = 0; i < next.races.length; i++) {
      final target = next.races[i];
      if (target.finishOrder.isNotEmpty || target.penalties.isNotEmpty) {
        seeded.add(target);
        continue;
      }
      final field = i < drawn.length ? drawn[i] : const <Entry>[];
      seeded.add(target.copyWith(
        entryIds: [for (final entry in field) entry.id],
        athleteIds: [
          for (final entry in field) ...entry.athletes.map((a) => a.id),
        ],
      ));
    }

    await _programme.save(_programme.current.value!.copyWith(structures: [
      for (final s in _programme.current.value!.structures)
        if (_isOtherStructure(s))
          s
        else
          s.copyWith(levels: [
            for (var i = 0; i < s.levels.length; i++)
              if (i == at + 1)
                s.levels[i].copyWith(races: seeded)
              else
                s.levels[i],
          ]),
    ]));

    for (final target in seeded) {
      if (target.runId == 0 || target.entryIds.isEmpty) continue;
      final located = _locate(meetings, target.runId);
      if (located == null) continue;
      await _meetings.syncLanes(
        runId: target.runId,
        entryIds: target.entryIds,
        existing: located.$2.lanes,
      );
    }
  }

  /// The entries of one course, best first, anyone out of the ranking dropped
  /// — what a qualification is computed from.
  ///
  /// For the course being validated the screen wins over the store: `_persist`
  /// is deliberately not awaited, so the order the operator just entered may
  /// not have reached the programme yet, and qualifying without it would leave
  /// this very course out of its own final.
  List<int> _rankedEntriesOf(ProgrammeRace stored) {
    final mine = stored.id == programmeRaceId;
    final order = mine
        ? [
            for (final group in finishOrder) [...group],
          ]
        : stored.finishOrder;
    final applied = mine ? penalties.toList() : stored.penalties;
    if (order.isEmpty || stored.entryIds.isEmpty) return const [];
    final penalised = {for (final p in applied) p.athleteId};
    // The draw wrote both lists in lane order, so an entry's athletes are
    // found by walking them together.
    final entryOfAthlete = <int, int>{};
    var cursor = 0;
    for (final entryId in stored.entryIds) {
      if (cursor >= stored.athleteIds.length) break;
      entryOfAthlete[stored.athleteIds[cursor]] = entryId;
      cursor++;
    }
    final ranked = <int>[];
    for (final group in order) {
      for (final athleteId in group) {
        if (penalised.contains(athleteId)) continue;
        final entryId = entryOfAthlete[athleteId];
        if (entryId != null && !ranked.contains(entryId)) ranked.add(entryId);
      }
    }
    return ranked;
  }

  Future<Map<int, Entry>> _entriesById() async {
    final raceId = race.value?.id;
    if (raceId == null) return const {};
    final entries = await _raceRepo.getEntries(raceId);
    return {
      for (final entry in entries)
        if (entry.category.id == categoryId) entry.id: entry,
    };
  }

  EventStructure? _structure(CompetitionProgramme programme) {
    for (final structure in programme.structures) {
      if (!_isOtherStructure(structure)) return structure;
    }
    return null;
  }
}
