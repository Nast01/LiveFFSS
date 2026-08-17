import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/entry.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/race.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';

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
  RaceStructureController(this._programme, this._raceRepo, this._clubRepo);

  final ProgrammeService _programme;
  final RaceRepository _raceRepo;
  final ClubRepository _clubRepo;

  final Rxn<Race> race = Rxn<Race>();
  final Rxn<Competition> competition = Rxn<Competition>();
  final RxBool isLoading = true.obs;
  final RxList<EventStructure> structures = <EventStructure>[].obs;

  Map<int, int> _entryCountByCategory = const {};

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
