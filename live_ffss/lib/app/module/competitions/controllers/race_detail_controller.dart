import 'dart:async';

import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/core/rfid/bracelet_payload.dart';
import 'package:live_ffss/app/core/rfid/rfid_writer.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/data/services/attendance_service.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/attendance_status.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/entry.dart';
import 'package:live_ffss/app/domain/models/heat.dart';
import 'package:live_ffss/app/domain/models/race.dart';
import 'package:live_ffss/app/domain/models/result.dart';

class RaceDetailController extends GetxController {
  RaceDetailController(
    this._raceRepo,
    this._clubRepo,
    this._rfidWriter,
    this._attendance,
  );

  final RaceRepository _raceRepo;
  final ClubRepository _clubRepo;
  final RfidWriter _rfidWriter;
  final AttendanceService _attendance;

  static const Duration _pollInterval = Duration(seconds: 10);

  final Rxn<Race> race = Rxn<Race>();
  final Rxn<Competition> competition = Rxn<Competition>();

  /// 0 = Entries, 1 = Heats, 2 = Summary
  final RxInt currentTabIndex = 1.obs;

  final RxBool isLoading = false.obs;
  final Rxn<AppException> error = Rxn<AppException>();
  final RxList<Heat> heats = <Heat>[].obs;

  final RxBool entriesLoading = false.obs;
  final Rxn<AppException> entriesError = Rxn<AppException>();
  final RxList<Entry> entries = <Entry>[].obs;

  /// Presence tracking, keyed by athlete id. Populated lazily via
  /// [attendanceOf] — a missing key means the default [AttendanceStatus.waiting]
  /// (athletes start "en attente marshalling"). NOT cleared on reload/poll so a
  /// pull-to-refresh keeps the marshaller's validations.
  final RxMap<int, AttendanceStatus> attendance = <int, AttendanceStatus>{}.obs;

  /// Guards the one-shot restore from storage: after the first load, the map in
  /// memory is the source of truth, so a reload must never overwrite pointing
  /// the marshaller has done since.
  bool _attendanceRestored = false;

  /// How the flat athlete list is ordered. Drives [sortedAthletes].
  final Rx<AthleteSortMode> sortMode = AthleteSortMode.name.obs;

  final RxBool isScanning = false.obs;
  final RxList<ScanResult> scanLog = <ScanResult>[].obs;
  final RxInt presentCount = 0.obs;
  StreamSubscription<String>? _scanSub;

  // Athlete id -> club, resolved once from the engaged athletes and reused by
  // both heats (club labels) and entries (cap images) across every poll.
  // [_clubsFuture] de-dupes concurrent resolutions.
  Map<int, Club> _clubs = const {};
  Future<void>? _clubsFuture;

  Timer? _pollTimer;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is Map) {
      final r = arg['race'];
      final c = arg['competition'];
      if (r is Race) race.value = r;
      if (c is Competition) competition.value = c;
    } else if (arg is Race) {
      race.value = arg;
    }

    if (race.value != null) {
      loadHeats(initial: true);
      loadEntries();
    }
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    _scanSub?.cancel();
    super.onClose();
  }

  void changeTab(int index) {
    currentTabIndex.value = index;
  }

  Future<void> loadHeats({bool initial = false}) async {
    final raceId = race.value?.id;
    if (raceId == null) return;
    if (initial) {
      isLoading.value = true;
      error.value = null;
    }
    try {
      final loaded = await _raceRepo.getHeats(raceId);
      // Club labels are decoration on a heat row; the heats themselves are the
      // point. They render with whatever clubs are resolved so far and pick the
      // rest up on the next poll, rather than being held hostage to a club call.
      heats.value = _injectClubsIntoHeats(loaded, _clubs);
      _ensurePolling();
    } on AppException catch (e) {
      if (initial) error.value = e;
    } finally {
      if (initial) isLoading.value = false;
    }
  }

  Future<void> loadEntries() async {
    final raceId = race.value?.id;
    if (raceId == null) return;
    _restoreAttendance(raceId);
    entriesLoading.value = true;
    entriesError.value = null;
    try {
      final loaded = await _raceRepo.getEntries(raceId);
      entries.value = _withClubs(loaded);
      // Progressive enhancement: the list is on screen already, so resolving
      // the clubs (a list call plus one per club) happens behind it and patches
      // the rows when it lands.
      unawaited(_ensureClubs());
    } on AppException catch (e) {
      entriesError.value = e;
    } finally {
      entriesLoading.value = false;
    }
  }

  /// Copies the resolved club onto every engaged athlete. Athletes the
  /// resolution did not reach keep whatever club they arrived with, which is
  /// normally none — [ClubAvatar] then falls back to the club initial.
  List<Entry> _withClubs(List<Entry> loaded) {
    if (_clubs.isEmpty) return loaded;
    return [
      for (final entry in loaded)
        entry.copyWith(
          athletes: [
            for (final athlete in entry.athletes)
              athlete.copyWith(club: _clubs[athlete.id] ?? athlete.club),
          ],
        ),
    ];
  }

  /// Resolves every engaged athlete's club once, then patches the rows already
  /// on screen. Concurrent callers share the in-flight resolution; on failure
  /// the future is cleared so a pull-to-refresh retries.
  ///
  /// Engaged athletes are the right input for both tabs: a heat can only seat
  /// someone who is engaged, so this index covers the heat rows too.
  Future<void> _ensureClubs() {
    if (_clubs.isNotEmpty) return Future.value();
    return _clubsFuture ??= _resolveClubs();
  }

  Future<void> _resolveClubs() async {
    try {
      final competitionId = competition.value?.id;
      final athletes = [
        for (final entry in entries) ...entry.athletes,
      ];
      if (competitionId == null || athletes.isEmpty) return;
      _clubs = await _clubRepo.getAthleteClubs(competitionId, athletes);
      if (_clubs.isEmpty) return;
      entries.value = _withClubs(entries);
      if (heats.isNotEmpty) heats.value = _injectClubsIntoHeats(heats, _clubs);
    } on AppException {
      // Best-effort: every row keeps the club initial rather than an image.
    } finally {
      _clubsFuture = null;
    }
  }

  /// Flat list of every engaged athlete, ordered per [sortMode]. Reads
  /// [entries] and [sortMode] (and [attendance] when sorting by presence) so it
  /// recomputes reactively inside `Obx`.
  List<Athlete> get sortedAthletes {
    final all = entries.expand((e) => e.athletes).toList();
    all.sort(switch (sortMode.value) {
      AthleteSortMode.name => _byName,
      AthleteSortMode.club => (a, b) {
          final byClub =
              a.clubLabel.toLowerCase().compareTo(b.clubLabel.toLowerCase());
          return byClub != 0 ? byClub : _byName(a, b);
        },
      AthleteSortMode.attendance => (a, b) {
          final byStatus =
              attendanceOf(a).index.compareTo(attendanceOf(b).index);
          return byStatus != 0 ? byStatus : _byName(a, b);
        },
    });
    return all;
  }

  int _byName(Athlete a, Athlete b) {
    final byLast = a.lastName.toLowerCase().compareTo(b.lastName.toLowerCase());
    if (byLast != 0) return byLast;
    return a.firstName.toLowerCase().compareTo(b.firstName.toLowerCase());
  }

  void setSortMode(AthleteSortMode mode) => sortMode.value = mode;

  /// Presence tally over the engaged athletes, in the same flattening as
  /// [sortedAthletes] — an athlete entered twice counts twice, so the total
  /// always matches the number of rows in the list. Reads [entries] and
  /// [attendance], so it recomputes reactively inside `Obx`.
  ({int waiting, int present, int absent, int total}) get attendanceCounts {
    var waiting = 0;
    var present = 0;
    var absent = 0;
    for (final entry in entries) {
      for (final athlete in entry.athletes) {
        switch (attendanceOf(athlete)) {
          case AttendanceStatus.waiting:
            waiting++;
          case AttendanceStatus.present:
            present++;
          case AttendanceStatus.absent:
            absent++;
        }
      }
    }
    return (
      waiting: waiting,
      present: present,
      absent: absent,
      total: waiting + present + absent,
    );
  }

  AttendanceStatus attendanceOf(Athlete athlete) =>
      attendance[athlete.id] ?? AttendanceStatus.waiting;

  /// Reloads what was pointed for this race on a previous visit. Runs once per
  /// controller life — see [_attendanceRestored].
  void _restoreAttendance(int raceId) {
    if (_attendanceRestored) return;
    _attendanceRestored = true;
    final stored = _attendance.forRace(raceId);
    if (stored.isNotEmpty) attendance.addAll(stored);
  }

  /// Persists the whole race after a change. Not awaited: pointing must feel
  /// instant, and [AttendanceService] serialises the writes itself.
  void _persistAttendance() {
    final raceId = race.value?.id;
    if (raceId == null) return;
    unawaited(_attendance.save(raceId, Map.of(attendance)));
  }

  /// Cycles waiting → present → absent → waiting. Manual toggle used until the
  /// RFID bracelet scan drives presence automatically.
  void cycleAttendance(Athlete athlete) {
    final next = switch (attendanceOf(athlete)) {
      AttendanceStatus.waiting => AttendanceStatus.present,
      AttendanceStatus.present => AttendanceStatus.absent,
      AttendanceStatus.absent => AttendanceStatus.waiting,
    };
    attendance[athlete.id] = next;
    _persistAttendance();
  }

  /// Sets an explicit presence status (from the long-press selection menu).
  void setAttendance(Athlete athlete, AttendanceStatus status) {
    attendance[athlete.id] = status;
    _persistAttendance();
  }

  bool get canScanBracelets => _rfidWriter.isSupported;

  /// Starts a continuous bracelet-read session. Each scanned bracelet whose
  /// licence matches an engaged athlete sets that athlete present. Idempotent
  /// while already scanning.
  void startScan() {
    if (isScanning.value) return;
    scanLog.clear();
    presentCount.value = 0;
    isScanning.value = true;
    _scanSub = _rfidWriter.readBracelets().listen(
      _onScanPayload,
      onError: (Object e) {
        final key = e is RfidException ? e.message : 'bracelet_unreadable';
        scanLog.insert(0, ScanResult(key, ScanOutcome.unreadable));
      },
    );
  }

  void _onScanPayload(String payload) {
    final licence = parseBraceletLicence(payload);
    Athlete? match;
    for (final e in entries) {
      for (final a in e.athletes) {
        if (a.licenseeNumber == licence) {
          match = a;
          break;
        }
      }
      if (match != null) break;
    }
    if (match == null) {
      scanLog.insert(0, ScanResult(licence, ScanOutcome.notEntered));
      return;
    }
    attendance[match.id] = AttendanceStatus.present;
    _persistAttendance();
    scanLog.insert(
        0,
        ScanResult(
            '${match.lastName} ${match.firstName}', ScanOutcome.present));
    presentCount.value++;
  }

  /// Stops the read session and releases the NFC hardware.
  void stopScan() {
    _scanSub?.cancel();
    _scanSub = null;
    isScanning.value = false;
  }

  /// Starts the poll timer if not already running. Called from [loadHeats]
  /// after the first successful load, so a failed initial load doesn't keep
  /// polling silently — the user must retry via pull-to-refresh.
  void _ensurePolling() {
    _pollTimer ??= Timer.periodic(_pollInterval, (_) => loadHeats());
  }

  List<Heat> _injectClubsIntoHeats(List<Heat> heats, Map<int, Club> index) {
    if (index.isEmpty) return heats;
    return heats
        .map((h) => h.copyWith(
              results: h.results
                  .map((r) => r.copyWith(
                        athletes: r.athletes
                            .map((a) => a.copyWith(club: index[a.id] ?? a.club))
                            .toList(),
                      ))
                  .toList(),
            ))
        .toList();
  }
}

enum ScanOutcome { present, notEntered, unreadable }

/// One line in the scan log: a display label plus the outcome (which the view
/// maps to a colour / translation). For `unreadable` the label is the
/// `RfidException` message key (e.g. `nfc_disabled`, `bracelet_unreadable`).
class ScanResult {
  const ScanResult(this.label, this.outcome);

  final String label;
  final ScanOutcome outcome;
}

enum AthleteSortMode { name, club, attendance }

enum HeatLiveStatus { official, live, unofficial }

extension HeatLiveStatusX on Heat {
  HeatLiveStatus get liveStatus {
    if (done) return HeatLiveStatus.official;
    if (startDate != null) return HeatLiveStatus.live;
    return HeatLiveStatus.unofficial;
  }
}

extension ResultLaneX on List<Result> {
  /// Lane is not provided by the API — derive from list order.
  int laneOf(Result result) => indexOf(result) + 1;
}

extension AthleteClubLabelX on Athlete {
  String get clubLabel => club?.name ?? '';
}
