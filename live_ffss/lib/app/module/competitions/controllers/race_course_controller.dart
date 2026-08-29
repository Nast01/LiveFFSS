import 'dart:async';

import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/core/rfid/bracelet_payload.dart';
import 'package:live_ffss/app/core/rfid/rfid_writer.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/course_penalty.dart';
import 'package:live_ffss/app/domain/models/course_ranking.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/race.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';

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
  );

  final ProgrammeService _programme;
  final RaceRepository _raceRepo;
  final ClubRepository _clubRepo;
  final RfidWriter _rfid;

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
}
