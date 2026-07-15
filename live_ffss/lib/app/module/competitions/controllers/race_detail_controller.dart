import 'dart:async';

import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/entry.dart';
import 'package:live_ffss/app/domain/models/heat.dart';
import 'package:live_ffss/app/domain/models/race.dart';
import 'package:live_ffss/app/domain/models/result.dart';

class RaceDetailController extends GetxController {
  RaceDetailController(this._raceRepo, this._clubRepo);

  final RaceRepository _raceRepo;
  final ClubRepository _clubRepo;

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
  final RxMap<int, AttendanceStatus> attendance =
      <int, AttendanceStatus>{}.obs;

  /// How the flat athlete list is ordered. Drives [sortedAthletes].
  final Rx<AthleteSortMode> sortMode = AthleteSortMode.name.obs;

  // Resolved at first load and reused across polls. Shared by heats (club
  // labels) and entries (cap images). [_athleteClubIndexFuture] de-dupes
  // concurrent builds — heats and entries both request it on init.
  Map<int, Club>? _athleteClubIndex;
  Future<Map<int, Club>>? _athleteClubIndexFuture;

  // Clubs fetched one-by-one (via getClubDetail) to backfill logos the club
  // list didn't resolve. Keyed by clubId, cached for the session.
  final Map<int, Club> _clubDetailCache = {};

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
      // Clubs must be loaded before heats so each result row can display its
      // athlete's club label. Cached after first success — subsequent polls
      // skip the club call. If the club call fails, the heat call is NOT
      // attempted and the error propagates.
      final index = await _ensureAthleteClubIndex();
      final loaded = await _raceRepo.getHeats(raceId);
      heats.value = _injectClubsIntoHeats(loaded, index);
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
    entriesLoading.value = true;
    entriesError.value = null;
    try {
      final loaded = await _raceRepo.getEntries(raceId);
      entries.value = await _injectClubsIntoEntries(loaded);
      // Progressive enhancement: the list is already visible; fetch the logos
      // still missing (per-club, deduped) and patch them in when they arrive.
      unawaited(_backfillMissingClubLogos());
    } on AppException catch (e) {
      entriesError.value = e;
    } finally {
      entriesLoading.value = false;
    }
  }

  /// Resolves each athlete's [Club] (for cap/logo images) via the shared club
  /// index. Best-effort: if the club fetch fails the entries are returned
  /// as-is so the list still renders — only images are missing.
  Future<List<Entry>> _injectClubsIntoEntries(List<Entry> loaded) async {
    Map<int, Club> index;
    try {
      index = await _ensureAthleteClubIndex();
    } on AppException {
      return loaded;
    }
    if (index.isEmpty) return loaded;
    return loaded
        .map((e) => e.copyWith(
              athletes: e.athletes
                  .map((a) => a.copyWith(club: index[a.id] ?? a.club))
                  .toList(),
            ))
        .toList();
  }

  bool _hasImage(Club? club) =>
      club != null &&
      ((club.capUrl?.isNotEmpty ?? false) ||
          (club.logoUrl?.isNotEmpty ?? false));

  /// For each engaged athlete still missing a club image, fetches that club's
  /// detail by [Athlete.clubId] (deduped across athletes, cached, best-effort)
  /// and patches the resolved logo into [entries]. Runs after the list is shown
  /// so images fill in progressively; failures leave the initial fallback.
  ///
  /// The cache-apply step runs unconditionally so a reload — which re-fetches
  /// entries whose athletes come back with no club — still gets the logos we
  /// resolved on a previous load.
  Future<void> _backfillMissingClubLogos() async {
    final missing = <int>{
      for (final entry in entries)
        for (final athlete in entry.athletes)
          if (!_hasImage(athlete.club) &&
              athlete.clubId > 0 &&
              !_clubDetailCache.containsKey(athlete.clubId))
            athlete.clubId,
    };

    if (missing.isNotEmpty) {
      await Future.wait(missing.map((clubId) async {
        try {
          _clubDetailCache[clubId] = await _clubRepo.getClubDetail(clubId);
        } on AppException {
          // Best-effort: this club keeps its initial-letter fallback.
        }
      }));
    }

    _applyCachedClubLogos();
  }

  /// Patches [entries] with any club already in [_clubDetailCache], reassigning
  /// only when something actually changed (avoids a spurious rebuild).
  void _applyCachedClubLogos() {
    if (_clubDetailCache.isEmpty) return;
    var changed = false;
    final patched = entries.map((e) {
      return e.copyWith(
        athletes: e.athletes.map((a) {
          if (_hasImage(a.club)) return a;
          final detail = a.clubId > 0 ? _clubDetailCache[a.clubId] : null;
          if (detail == null) return a;
          changed = true;
          return a.copyWith(club: detail);
        }).toList(),
      );
    }).toList();
    if (changed) entries.value = patched;
  }

  /// Builds (or returns the cached) athlete-id → club index. Concurrent callers
  /// share the same in-flight future; on failure the future is cleared so the
  /// next call retries.
  Future<Map<int, Club>> _ensureAthleteClubIndex() {
    final cached = _athleteClubIndex;
    if (cached != null) return Future.value(cached);
    return _athleteClubIndexFuture ??= _loadAthleteClubIndex();
  }

  Future<Map<int, Club>> _loadAthleteClubIndex() async {
    try {
      final competitionId = competition.value?.id;
      final index = competitionId != null
          ? await _buildAthleteClubIndex(competitionId)
          : <int, Club>{};
      _athleteClubIndex = index;
      return index;
    } finally {
      _athleteClubIndexFuture = null;
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

  AttendanceStatus attendanceOf(Athlete athlete) =>
      attendance[athlete.id] ?? AttendanceStatus.waiting;

  /// Cycles waiting → present → absent → waiting. Manual toggle used until the
  /// RFID bracelet scan drives presence automatically.
  void cycleAttendance(Athlete athlete) {
    final next = switch (attendanceOf(athlete)) {
      AttendanceStatus.waiting => AttendanceStatus.present,
      AttendanceStatus.present => AttendanceStatus.absent,
      AttendanceStatus.absent => AttendanceStatus.waiting,
    };
    attendance[athlete.id] = next;
  }

  /// Sets an explicit presence status (from the long-press selection menu).
  void setAttendance(Athlete athlete, AttendanceStatus status) {
    attendance[athlete.id] = status;
  }

  // TODO(rfid): wire the NFC/RFID bracelet reader to resolve an athlete by
  // bracelet id and mark them present. Placeholder for now.
  void scanRfid() {}

  Future<Map<int, Club>> _buildAthleteClubIndex(int competitionId) async {
    final clubs = await _clubRepo.getClubs(competitionId);
    final index = <int, Club>{};
    for (final club in clubs) {
      for (final athlete in club.athletes) {
        index[athlete.id] = club;
      }
    }
    return index;
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
                            .map((a) =>
                                a.copyWith(club: index[a.id] ?? a.club))
                            .toList(),
                      ))
                  .toList(),
            ))
        .toList();
  }
}

enum AttendanceStatus { waiting, present, absent }

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
