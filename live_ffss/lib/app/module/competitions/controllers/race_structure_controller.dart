import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:live_ffss/app/data/repositories/race_format_repository.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/course_penalty.dart';
import 'package:live_ffss/app/domain/models/course_ranking.dart';
import 'package:live_ffss/app/domain/models/entry.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';
import 'package:live_ffss/app/domain/models/run.dart';
import 'package:live_ffss/app/domain/models/slot.dart';
import 'package:live_ffss/app/domain/models/race.dart';
import 'package:live_ffss/app/domain/models/structure_generator.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/data/mappers/athlete_mapper.dart'
    show parseGender;
import 'package:live_ffss/app/presentation/modules/competitions/race_formatting.dart';

/// One entry of the round menu bar: a round of one category's structure.
/// Carries no label of its own — translating is the view's job.
class RoundTab {
  const RoundTab({
    required this.structure,
    required this.level,
    required this.levelIndex,
  });

  final EventStructure structure;
  final RoundLevel level;

  /// Position of [level] within its own structure's chain.
  final int levelIndex;

  int get categoryId => structure.categoryId;
  String get categoryLabel => structure.categoryLabel;
  RoundType get type => level.type;

  /// Whether this round opens its structure's chain. Only an opening round is
  /// drawn from the athletes present — every later round is seated by whoever
  /// qualifies out of the one before it.
  bool get isFirstRound => levelIndex == 0;
}

/// Feeds the race-detail "Séries" tab with the locally-defined structure(s) for
/// this race (one per category), plus per-category engaged counts. Read-only.
class RaceStructureController extends GetxController {
  RaceStructureController(
    this._programme,
    this._raceRepo,
    this._clubRepo,
    this._meetings,
    this._raceFormatRepo,
  );

  final ProgrammeService _programme;
  final RaceRepository _raceRepo;
  final ClubRepository _clubRepo;
  final MeetingRepository _meetings;
  final RaceFormatRepository _raceFormatRepo;

  final Rxn<Race> race = Rxn<Race>();
  final Rxn<Competition> competition = Rxn<Competition>();
  final RxBool isLoading = true.obs;
  final RxList<EventStructure> structures = <EventStructure>[].obs;

  Map<int, int> _entryCountByCategory = const {};

  /// The competition's réunions, for the créneaux and courses the rounds of
  /// this race were scheduled into.
  final RxList<Meeting> _meetingsOfCompetition = <Meeting>[].obs;

  /// Athlete id -> athlete, built from the entries this race already fetches,
  /// with clubs resolved. It is what turns a drawn race's `athleteIds` back
  /// into rows the operator can read.
  Map<int, Athlete> _athletesById = const {};

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    Race? r;
    Competition? c;
    if (arg is Map) {
      final ar = arg['race'];
      final ac = arg['competition'];
      if (ar is Race) r = ar;
      if (ac is Competition) c = ac;
    } else if (arg is Race) {
      r = arg;
    }
    if (r != null && c != null) {
      load(r, c);
    } else {
      if (r != null) race.value = r;
      if (c != null) competition.value = c;
      isLoading.value = false;
    }
  }

  Future<void> load(Race race, Competition competition) async {
    this.race.value = race;
    this.competition.value = competition;
    isLoading.value = true;
    try {
      await _programme.load(competition.id);
      // The déroulement lives on FFSS: a device that never authored it must
      // still see the épreuve's rounds. Same bargain as the entries below —
      // offline, whatever is stored locally still renders.
      try {
        await _seedStructuresFromServer(race, competition.id);
      } on AppException {
        // Local copy only.
      }
      final all =
          _programme.current.value?.structures ?? const <EventStructure>[];
      structures.value = all.where((s) => s.raceId == race.id).toList()
        ..sort((a, b) => a.categoryLabel.compareTo(b.categoryLabel));
      // Clamped rather than reset: reloading after a draw must leave the
      // operator on the round they were looking at, while opening a race with
      // fewer rounds must not leave the selection past the end.
      final tabCount = tabs.length;
      selectedTabIndex.value =
          tabCount == 0 ? 0 : selectedTabIndex.value.clamp(0, tabCount - 1);
      try {
        final entries = await _raceRepo.getEntries(race.id);
        final counts = <int, int>{};
        for (final e in entries) {
          counts[e.category.id] = (counts[e.category.id] ?? 0) + 1;
        }
        _entryCountByCategory = counts;
        _athletesById = await _indexAthletes(entries, competition.id);
      } on AppException {
        // Entries unavailable (offline / API error): the structure still
        // renders; category counts fall back to zero and a drawn race lists
        // no athlete.
        _entryCountByCategory = const {};
        _athletesById = const {};
      }
      try {
        _meetingsOfCompetition.value = await _meetings.getMeetings(
          competition.id,
        );
      } on AppException {
        // Same bargain as the entries: the schedule is a complement here, not
        // the reason this screen exists. Without it the rounds still read,
        // only their site and times go missing.
        _meetingsOfCompetition.clear();
      }
      // The draw a first device pushed lives in the FFSS places: this is what
      // makes it visible on every other device.
      try {
        await _importCompositions(race);
        final refreshed =
            _programme.current.value?.structures ?? const <EventStructure>[];
        structures.value = refreshed.where((s) => s.raceId == race.id).toList()
          ..sort((a, b) => a.categoryLabel.compareTo(b.categoryLabel));
      } on AppException {
        // The local composition stands.
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// What the operator typed in the filter bar, already folded for comparison.
  final RxString filter = ''.obs;

  /// Races the operator opened by hand. A filtered race is open regardless —
  /// surviving the filter is itself the reason to show its line-up.
  final RxSet<int> _expandedRaceIds = <int>{}.obs;

  void setFilter(String value) => filter.value = _fold(value);

  bool isExpanded(ProgrammeRace race) =>
      filter.value.isNotEmpty || _expandedRaceIds.contains(race.id);

  void toggleExpanded(ProgrammeRace race) {
    if (!_expandedRaceIds.remove(race.id)) _expandedRaceIds.add(race.id);
  }

  void expandAll(Iterable<ProgrammeRace> races) =>
      _expandedRaceIds.addAll(races.map((r) => r.id));

  void collapseAll() => _expandedRaceIds.clear();

  /// Whether every one of [races] is open, which is what turns the expand-all
  /// button into a collapse-all button.
  bool allExpanded(Iterable<ProgrammeRace> races) =>
      races.isNotEmpty && races.every(isExpanded);

  /// The races holding an athlete the filter matches. An empty filter matches
  /// everything, so the list comes back untouched.
  List<ProgrammeRace> matchingRaces(Iterable<ProgrammeRace> races) {
    if (filter.value.isEmpty) return races.toList();
    return [
      for (final race in races)
        if (athletesOf(race).any(matchesFilter)) race,
    ];
  }

  /// Whether this athlete is what the operator is looking for — surname, first
  /// name or club, in any case and with or without the accents.
  bool matchesFilter(Athlete athlete) {
    final needle = filter.value;
    if (needle.isEmpty) return true;
    final club = athlete.club?.name.isNotEmpty == true
        ? athlete.club!.name
        : athlete.clubLabel;
    return _fold('${athlete.lastName} ${athlete.firstName} $club')
        .contains(needle);
  }

  /// Lowercases and strips the accents a marshal will not type: searching for
  /// "noel" has to find NOËL, and "remy" has to find Rémy.
  static String _fold(String value) {
    const accented = 'àáâãäåçèéêëìíîïñòóôõöùúûüýÿœæ';
    const plain = 'aaaaaaceeeeiiiinooooouuuuyyoa';
    final buffer = StringBuffer();
    for (final rune in value.toLowerCase().runes) {
      final char = String.fromCharCode(rune);
      final at = accented.indexOf(char);
      buffer.write(at < 0 ? char : plain[at]);
    }
    return buffer.toString().trim();
  }

  /// The athletes a drawn race holds, in the order the draw left them. Ids the
  /// entries do not account for are skipped rather than rendered as a blank
  /// row — an athlete withdrawn since the draw is the ordinary way that happens.
  List<Athlete> athletesOf(ProgrammeRace race) => [
        for (final id in race.athleteIds)
          if (_athletesById[id] case final Athlete athlete) athlete,
      ];

  /// The place this athlete took in a scored race, or null while it has no
  /// result. Computed from the stored order by the same function the entry
  /// screen uses — the two therefore cannot disagree about a ranking.
  int? placeIn(ProgrammeRace race, Athlete athlete) =>
      placesOf(race.finishOrder)[athlete.id];

  /// The withdrawal this athlete carries in a scored race, if any.
  CoursePenalty? penaltyIn(ProgrammeRace race, Athlete athlete) {
    for (final penalty in race.penalties) {
      if (penalty.athleteId == athlete.id) return penalty;
    }
    return null;
  }

  /// Indexes the engaged athletes and resolves their clubs. Best-effort on the
  /// clubs: without them the rows still read, only the logos fall back to the
  /// club initial.
  Future<Map<int, Athlete>> _indexAthletes(
    List<Entry> entries,
    int competitionId,
  ) async {
    final athletes = [for (final entry in entries) ...entry.athletes];
    if (athletes.isEmpty) return const {};
    Map<int, Club> clubs;
    try {
      clubs = await _clubRepo.getAthleteClubs(competitionId, athletes);
    } on AppException {
      clubs = const {};
    }
    return {
      for (final athlete in athletes)
        athlete.id: athlete.copyWith(club: clubs[athlete.id] ?? athlete.club),
    };
  }

  /// Materialises the server déroulements of this race into the local
  /// programme: a structure that does not exist locally is created, one whose
  /// rounds were emptied is reseeded — the same rule the Structure overview
  /// applies. A structure that holds rounds is authored work and stays.
  Future<void> _seedStructuresFromServer(Race race, int competitionId) async {
    final formats = await _raceFormatRepo.getRaceFormats(competitionId);
    final mine = [
      for (final format in formats)
        if (format.disciplineId == race.disciplineId &&
            parseGender(format.gender) == race.gender &&
            format.details.isNotEmpty)
          format,
    ];
    if (mine.isEmpty) return;

    final programme = _programme.current.value ??
        CompetitionProgramme(competitionId: competitionId);
    final updated = [...programme.structures];
    var changed = false;
    for (final format in mine) {
      for (final category in format.categories) {
        final at = updated.indexWhere(
            (s) => s.raceId == race.id && s.categoryId == category.id);
        if (at >= 0 && updated[at].levels.isNotEmpty) continue;
        final levels = buildLevelsFromDetails(
          details: format.details,
          allocateId: _programme.allocateId,
        );
        if (at >= 0) {
          updated[at] = updated[at].copyWith(levels: levels);
        } else {
          updated.add(EventStructure(
            raceId: race.id,
            categoryId: category.id,
            raceLabel: race.name,
            categoryLabel: category.name,
            spotsPerRace: race.defaultSpotsPerRace,
            levels: levels,
          ));
        }
        changed = true;
      }
    }
    if (!changed) return;
    await _programme.save(
      (_programme.current.value ?? programme).copyWith(structures: updated),
    );
  }

  /// Adopts, into the local races, the compositions the FFSS places carry —
  /// what another device pushed when it saved its draw.
  ///
  /// The server is the shared truth, with one guard: a race holding recorded
  /// results is never overwritten, whatever the server says — losing a finish
  /// order to a sync would be worse than any stale seating. Empty seats adopt
  /// nothing either: a freshly placed round says nothing about the draw.
  Future<void> _importCompositions(Race race) async {
    final programme = _programme.current.value;
    if (programme == null) return;

    var changed = false;
    final updated = <EventStructure>[];
    for (final structure in programme.structures) {
      if (structure.raceId != race.id) {
        updated.add(structure);
        continue;
      }
      final levels = <RoundLevel>[];
      for (final level in structure.levels) {
        final imported = await _importLevel(level);
        if (!identical(imported, level)) changed = true;
        levels.add(imported);
      }
      updated.add(structure.copyWith(levels: levels));
    }
    if (!changed) return;
    await _programme.save(
      _programme.current.value!.copyWith(structures: updated),
    );
  }

  Future<RoundLevel> _importLevel(RoundLevel level) async {
    final courses = coursesOfLevel(level);
    if (courses.isEmpty || level.races.isEmpty) return level;

    // A course claims the race that recorded it; the leftovers pair by rank —
    // the order both sides were created in.
    final races = [...level.races];
    final claimed = <int>{};
    final pairs = <(int, Run)>[];
    final unmatchedCourses = <Run>[];
    for (final course in courses) {
      final at = races.indexWhere((r) => r.runId == course.id);
      at >= 0
          ? _claim(pairs, claimed, at, course)
          : unmatchedCourses.add(course);
    }
    var cursor = 0;
    for (final course in unmatchedCourses) {
      while (cursor < races.length &&
          (claimed.contains(cursor) || races[cursor].runId != 0)) {
        cursor++;
      }
      if (cursor >= races.length) break;
      _claim(pairs, claimed, cursor, course);
    }

    var changed = false;
    for (final (at, course) in pairs) {
      final race = races[at];
      if (race.finishOrder.isNotEmpty || race.penalties.isNotEmpty) continue;
      if (course.lanes.isEmpty) continue;
      final seats =
          await _meetings.getLaneSeats([for (final l in course.lanes) l.id]);
      if (seats.isEmpty) continue;
      final entryIds = [for (final seat in seats) seat.entryId];
      final athleteIds = [
        for (final seat in seats) ...seat.athleteIds,
      ];
      if (race.runId == course.id &&
          _sameIds(race.entryIds, entryIds) &&
          _sameIds(race.athleteIds, athleteIds)) {
        continue;
      }
      races[at] = race.copyWith(
        runId: course.id,
        entryIds: entryIds,
        athleteIds: athleteIds,
      );
      changed = true;
    }
    return changed ? level.copyWith(races: races) : level;
  }

  static void _claim(
    List<(int, Run)> pairs,
    Set<int> claimed,
    int at,
    Run course,
  ) {
    pairs.add((at, course));
    claimed.add(at);
  }

  static bool _sameIds(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// The créneaux FFSS holds for this round — those hung off its `partie`.
  /// Normally one; nothing on the federal side forbids several.
  List<Slot> slotsForLevel(RoundLevel level) {
    if (level.serverId <= 0) return const [];
    return [
      for (final meeting in _meetingsOfCompetition)
        for (final slot in meeting.slots)
          if (slot.raceFormatDetail?.id == level.serverId) slot,
    ];
  }

  /// The round's courses, in running order across its créneaux.
  List<Run> coursesOfLevel(RoundLevel level) => [
        for (final slot in slotsForLevel(level)) ...slot.runs,
      ]..sort((a, b) => a.beginTime.compareTo(b.beginTime));

  /// Where and when one drawn heat actually starts, or null while the round
  /// has no course to run it in.
  ///
  /// Prefers the course the heat recorded when it was created. Falls back to
  /// the course of the same rank — which is what a course created by hand on
  /// the federal site leaves us with — and says so, because rank is a
  /// reasonable guess and not a fact.
  RaceSchedule? scheduleFor(RoundLevel level, ProgrammeRace race) {
    final courses = coursesOfLevel(level);
    if (courses.isEmpty) return null;
    if (race.runId != 0) {
      for (final course in courses) {
        if (course.id == race.runId) {
          return RaceSchedule(run: course, isGuess: false);
        }
      }
    }
    final rank = level.races.indexWhere((r) => r.id == race.id);
    if (rank < 0 || rank >= courses.length) return null;
    return RaceSchedule(run: courses[rank], isGuess: true);
  }

  /// The distinct sites this round runs on, in course order. Empty while it
  /// has no course, or while its courses carry no site.
  List<String> sitesOfLevel(RoundLevel level) {
    final seen = <String>[];
    for (final course in coursesOfLevel(level)) {
      if (course.site.isNotEmpty && !seen.contains(course.site)) {
        seen.add(course.site);
      }
    }
    return seen;
  }

  bool get hasStructure => structures.any((s) => s.levels.isNotEmpty);

  int entryCountFor(int categoryId) => _entryCountByCategory[categoryId] ?? 0;

  bool get showCategoryHeaders => structures.length > 1;

  /// The menu bar: one entry per category × round actually defined, categories
  /// in the order [structures] holds them, rounds in the structure's own order.
  List<RoundTab> get tabs => [
        for (final s in structures)
          for (var i = 0; i < s.levels.length; i++)
            RoundTab(structure: s, level: s.levels[i], levelIndex: i),
      ];

  final RxInt selectedTabIndex = 0.obs;

  RoundTab? get selectedTab {
    final all = tabs;
    if (all.isEmpty) return null;
    return all[selectedTabIndex.value.clamp(0, all.length - 1)];
  }

  void selectTab(int index) {
    if (index < 0 || index >= tabs.length) return;
    selectedTabIndex.value = index;
  }
}

/// Where and when a drawn heat runs.
class RaceSchedule {
  const RaceSchedule({required this.run, required this.isGuess});

  final Run run;

  /// True when the heat recorded no course of its own — or recorded one that
  /// no longer exists — and this course was matched by rank instead. Right in
  /// the ordinary case, but the view says so rather than passing it off as
  /// established.
  final bool isGuess;
}
