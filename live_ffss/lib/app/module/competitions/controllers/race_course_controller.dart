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
import 'package:live_ffss/app/domain/models/competitor.dart'
    show competitorsOf, isCompetitorOrder;
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

  /// Whether the caller told us which série this course has — 0 included, which
  /// means "none yet". The Séries tab always knows, and being believed at 0 is
  /// what keeps opening a course to score it from reading the whole réunion
  /// tree only to learn there is nothing to read back.
  bool _heatIdGiven = false;

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

  /// The line-up, in the order the draw left it. One row per engagement: a
  /// relay team takes a single place, whichever of its members touches home.
  final RxList<Entry> competitors = <Entry>[].obs;

  /// Finishing groups, in order. A group of several is a declared tie.
  final RxList<List<int>> competitorOrder = <List<int>>[].obs;

  /// Engagements out of the ranking. Kept apart from [competitorOrder]
  /// precisely so they take no place — the competitors after them number as
  /// though they had not started.
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
    final heat = arg['heatId'];
    if (heat is int) {
      _heatId = heat;
      _heatIdGiven = true;
    }
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

      final entries = await _raceRepo.getEntries(raceIdValue);
      final byEntry = {for (final entry in entries) entry.id: entry};
      final byAthlete = <int, Athlete>{
        for (final entry in entries)
          for (final athlete in entry.athletes) athlete.id: athlete,
      };
      final lineUp = competitorsOf(
        stored ?? const ProgrammeRace(id: 0, number: 0),
        entries: byEntry,
        athletes: byAthlete,
      );

      final droppedWholeRanking = _readStoredRanking(stored, lineUp);

      // Entries arrive with no club on their athletes — the mappers never set
      // one — and that club is what every row shows.
      final drawnAthletes = [for (final entry in lineUp) ...entry.athletes];
      Map<int, Club> clubs;
      try {
        clubs =
            await _clubRepo.getAthleteClubs(competitionIdValue, drawnAthletes);
      } on AppException {
        clubs = const {};
      }
      competitors.value = [
        for (final entry in lineUp)
          entry.copyWith(athletes: [
            for (final athlete in entry.athletes)
              athlete.copyWith(club: clubs[athlete.id] ?? athlete.club),
          ]),
      ];

      if (competitorOrder.isEmpty && penalties.isEmpty) {
        await _seedFromPublished(stored);
      }
      // A ranking dropped whole is only worth saying once it has stayed lost.
      // When the read-back refilled the course with the federation's own
      // places nothing was lost, and saying otherwise would raise a false
      // alarm on exactly the courses that read-back exists for.
      if (droppedWholeRanking && competitorOrder.isEmpty && penalties.isEmpty) {
        message.trigger(const UiMessageError('course_ranking_dropped'));
      }
    } on AppException {
      // The line-up is unavailable; the screen shows an empty course rather
      // than failing outright, and reopening it retries.
      competitors.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Reopens the ranking [stored] holds against the line-up actually engaged.
  ///
  /// Three cases, and they must not be confused. An order every id of which
  /// names a competitor is this course's own and comes back untouched. An
  /// order NO id of which names a competitor was written when the competitor
  /// was the athlete: it names nothing here, and reading it back would invent
  /// places, so it goes — with its penalties. In between sits the one the
  /// all-or-nothing rule used to throw away with the rest: a current order
  /// that has lost an engagement — withdrawn on FFSS since the draw, or
  /// missing from a truncated `getEntries` — which keeps everyone still
  /// engaged, renumbered densely.
  ///
  /// Either loss that stands is said out loud. Finding a ranking silently
  /// blank, or silently one place short, is how a marshal publishes a result
  /// they never entered. An order that was simply never scored stays silent:
  /// that is the ordinary state of a course not yet run.
  ///
  /// Returns whether the order was dropped whole — the one loss this does not
  /// announce itself, because only [load] knows whether the read-back from
  /// FFSS then refilled the course. The partial loss is settled here: its
  /// ranking stays non-empty, so no read-back runs behind it.
  bool _readStoredRanking(ProgrammeRace? stored, List<Entry> lineUp) {
    final storedOrder = [
      for (final group in stored?.competitorOrder ?? const <List<int>>[])
        [...group],
    ];
    final storedPenalties = [...?stored?.penalties];

    if (isCompetitorOrder(storedOrder, lineUp)) {
      competitorOrder.value = storedOrder;
      penalties.value = storedPenalties;
      return false;
    }

    final present = {for (final entry in lineUp) entry.id};
    // Not one id belongs to this course: the order was written in the other
    // namespace, and nothing in it can be salvaged.
    if (!storedOrder.any((group) => group.any(present.contains))) {
      competitorOrder.value = const [];
      penalties.value = const [];
      return true;
    }

    var order = storedOrder;
    for (final group in storedOrder) {
      for (final id in group) {
        if (!present.contains(id)) order = withoutCompetitor(order, id);
      }
    }
    competitorOrder.value = order;
    penalties.value = [
      for (final penalty in storedPenalties)
        if (present.contains(penalty.competitorId)) penalty,
    ];
    message.trigger(const UiMessageError('course_ranking_competitor_gone'));
    return false;
  }

  /// Takes back the ranking FFSS already holds for this course.
  ///
  /// With no migration of the rankings written under the old athlete-keyed
  /// meaning, this is what keeps a course already validated from reopening
  /// blank. Best-effort: a read that fails leaves the course to be scored,
  /// which beats an error screen at the water's edge.
  Future<void> _seedFromPublished(ProgrammeRace? stored) async {
    if (!_heatIdGiven) {
      _heatId = await _resolveHeatId(stored);
      _heatIdGiven = true;
    }
    if (_heatId == 0) return;
    try {
      final byHeat = await _meetings.getHeatResultsByHeat([_heatId]);
      final results = byHeat[_heatId] ?? const <HeatResult>[];
      if (results.isEmpty) return;

      // An engagement this course's line-up does not carry has no row to land
      // on — another heat of the same race — so it is skipped, not invented.
      final known = {for (final entry in competitors) entry.id};
      // A shared rank is a declared tie: it stays one group, and the places
      // after it renumber accordingly.
      final groups = <int, List<int>>{};
      for (final result in results) {
        final rank = result.rank;
        if (rank == null || !known.contains(result.entryId)) continue;
        (groups[rank] ??= []).add(result.entryId);
      }
      final ranks = groups.keys.toList()..sort();
      final order = [for (final rank in ranks) groups[rank]!];

      // Only a result without a rank is out of the ranking: the same
      // invariant `setPenalty` protects, so a rank and a penalty can never be
      // read back onto the same engagement.
      final withdrawn = [
        for (final result in results)
          if (result.rank == null && known.contains(result.entryId))
            if (_penaltyKindOf(result) case final CoursePenaltyKind kind)
              CoursePenalty(
                competitorId: result.entryId,
                kind: kind,
                code: result.complement ?? '',
              ),
      ];
      if (order.isEmpty && withdrawn.isEmpty) return;

      competitorOrder.value = order;
      penalties.value = withdrawn;
      // Repair the local copy instead of paying the read again on every open
      // — and hand `_seedNextRound` the stored order it qualifies from.
      _persist();
    } on AppException {
      // The course is left to be scored.
    }
  }

  CoursePenaltyKind? _penaltyKindOf(HeatResult result) =>
      switch (result.status) {
        1 => CoursePenaltyKind.disqualified,
        2 => CoursePenaltyKind.forfeit,
        _ => result.isDisqualified ? CoursePenaltyKind.disqualified : null,
      };

  /// This course's série when the caller did not hand one over: the fallback,
  /// and it pays for the whole réunion tree.
  ///
  /// No caller reaches this branch today — the Séries tab always passes
  /// `heatId` in — but it is not dead: it is the fallback for a future entry
  /// point that opens this screen without one.
  Future<int> _resolveHeatId(ProgrammeRace? stored) async {
    final competitionId = competition.value?.id;
    if (stored == null || stored.runId == 0 || competitionId == null) return 0;
    try {
      final located =
          _locate(await _meetings.getMeetings(competitionId), stored.runId);
      return located?.$2.heat?.id ?? 0;
    } on AppException {
      return 0;
    }
  }

  int get nextPlaceValue => nextPlace(competitorOrder);

  int? placeOf(Entry entry) => placesOf(competitorOrder)[entry.id];

  /// Ranked engagements first in place order, then those still to come in the
  /// order the draw left them. The finished screen is the result itself, which
  /// is why there is no separate recap to build or to keep in step.
  List<Entry> get orderedCompetitors {
    final places = placesOf(competitorOrder);
    final ranked = [
      for (final entry in competitors)
        if (places.containsKey(entry.id)) entry,
    ]..sort((a, b) => places[a.id]!.compareTo(places[b.id]!));
    return [
      ...ranked,
      for (final entry in competitors)
        if (!places.containsKey(entry.id) && penaltyOf(entry) == null) entry,
      for (final entry in competitors)
        if (penaltyOf(entry) != null) entry,
    ];
  }

  final RxSet<int> expandedEntries = <int>{}.obs;

  bool isEntryExpanded(Entry entry) => expandedEntries.contains(entry.id);

  void toggleEntry(Entry entry) {
    if (!expandedEntries.remove(entry.id)) expandedEntries.add(entry.id);
  }

  /// Substituting a member isn't wired to FFSS yet; the screen shows the
  /// button so the gesture exists, and says the rest is coming.
  void requestSubstitution(Entry entry, Athlete athlete) {
    message.trigger(const UiMessageError('relay_substitute_coming_soon'));
  }

  void assign(Entry entry) {
    // A withdrawal takes no place: ranking a forfeit or a disqualification
    // here would corrupt every place after it, exactly the invariant
    // setPenalty protects when a ranked engagement is withdrawn. Reinstating
    // is a deliberate act — clearPenalty, offered from the row menu — not
    // something a scan should do as a side effect.
    if (penaltyOf(entry) != null) {
      message.trigger(const UiMessageError('course_athlete_withdrawn'));
      return;
    }
    // A bracelet read twice, a teammate's bracelet read after the first, or a
    // row tapped twice, must report rather than silently re-persist the same
    // order — the operator has no other way to tell a good read from a
    // duplicate.
    if (placeOf(entry) != null) {
      message.trigger(const UiMessageError('course_athlete_already_ranked'));
      return;
    }
    competitorOrder.value =
        withFinisher(competitorOrder, entry.id, tied: tieLock.value);
    _persist();
  }

  /// Puts [entry] at [place], or takes it out of the ranking when [place] is
  /// not a place — an emptied field.
  ///
  /// Sharing a rank with someone declares a tie, and the places after it shift
  /// accordingly; see [withPlace].
  void setPlace(Entry entry, int place) {
    // Same invariant `assign` protects: a withdrawal takes no place, and
    // ranking one here would falsify every place behind it.
    if (penaltyOf(entry) != null) {
      message.trigger(const UiMessageError('course_athlete_withdrawn'));
      return;
    }
    competitorOrder.value = place < 1
        ? withoutCompetitor(competitorOrder, entry.id)
        : withPlace(competitorOrder, entry.id, place);
    _persist();
  }

  void remove(Entry entry) {
    competitorOrder.value = withoutCompetitor(competitorOrder, entry.id);
    _persist();
  }

  void undo() {
    competitorOrder.value = withoutLastFinisher(competitorOrder);
    _persist();
  }

  void toggleTieLock() => tieLock.value = !tieLock.value;

  CoursePenalty? penaltyOf(Entry entry) {
    for (final penalty in penalties) {
      if (penalty.competitorId == entry.id) return penalty;
    }
    return null;
  }

  /// Marks an engagement out of the ranking, pulling it out of the order
  /// first: a disqualified team that had already been placed must not keep a
  /// place. A relay is withdrawn whole — the penalty is the team's, not one
  /// leg's.
  void setPenalty(
    Entry entry,
    CoursePenaltyKind kind, {
    String code = '',
  }) {
    competitorOrder.value = withoutCompetitor(competitorOrder, entry.id);
    penalties.value = [
      for (final penalty in penalties)
        if (penalty.competitorId != entry.id) penalty,
      CoursePenalty(competitorId: entry.id, kind: kind, code: code),
    ];
    _persist();
  }

  void clearPenalty(Entry entry) {
    penalties.value = [
      for (final penalty in penalties)
        if (penalty.competitorId != entry.id) penalty,
    ];
    _persist();
  }

  /// Whether every engagement is accounted for — placed or withdrawn. This is
  /// what ends a scanning session, and why the highest place a course hands
  /// out is its number of teams minus its withdrawals.
  bool get isComplete {
    final places = placesOf(competitorOrder);
    return competitors.every(
      (e) => places.containsKey(e.id) || penaltyOf(e) != null,
    );
  }

  bool get canScan => _rfid.isSupported;

  /// Opens a continuous read session. Each bracelet whose licence matches an
  /// athlete of this course ranks that athlete's engagement at the next place,
  /// tie lock included — the same procedure as a tap, which is the whole
  /// reason the lock is a mode rather than a gesture.
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
    Entry? match;
    for (final entry in competitors) {
      if (entry.athletes.any((a) => a.licenseeNumber == licence)) {
        match = entry;
        break;
      }
    }
    if (match == null) {
      message.trigger(const UiMessageError('course_bracelet_not_in_race'));
      return;
    }
    // A team crosses the line once: a teammate's bracelet read afterwards
    // falls onto the duplicate `assign` already reports.
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
                            competitorOrder: [
                              for (final group in competitorOrder) [...group],
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
        outcomes: _outcomesFor(seats, stored),
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
  ///
  /// A draw made before [ProgrammeRace.entryIds] existed carries no engagement
  /// id at all, and `competitorsOf` then makes each athlete its own competitor
  /// — so this course's ranking is keyed by athlete. Matching such a seat by
  /// its engagement would find nothing and publish the whole heat as classified
  /// with no rank. The two id spaces are unrelated, so the branch is on where
  /// the line-up came from, never a fallback from one lookup to the other.
  List<CourseOutcome> _outcomesFor(List<LaneSeat> seats, ProgrammeRace stored) {
    final competitorsAreAthletes = stored.entryIds.isEmpty;
    final places = placesOf(competitorOrder);
    final penaltyOf = <int, CoursePenalty>{
      for (final penalty in penalties) penalty.competitorId: penalty,
    };
    return [
      for (final seat in seats)
        () {
          final competitorIds =
              competitorsAreAthletes ? seat.athleteIds : [seat.entryId];
          CoursePenalty? penalty;
          int? place;
          for (final id in competitorIds) {
            penalty ??= penaltyOf[id];
            place ??= places[id];
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
      if (target.competitorOrder.isNotEmpty || target.penalties.isNotEmpty) {
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
            for (final group in competitorOrder) [...group],
          ]
        : stored.competitorOrder;
    final applied = mine ? penalties.toList() : stored.penalties;
    final penalised = {for (final p in applied) p.competitorId};
    return [
      for (final group in order)
        for (final id in group)
          if (!penalised.contains(id)) id,
    ];
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
