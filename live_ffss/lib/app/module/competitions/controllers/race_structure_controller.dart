import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/race.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';

/// One entry of the round menu bar: a round of one category's structure.
/// Carries no label of its own — translating is the view's job.
class RoundTab {
  const RoundTab({required this.structure, required this.level});

  final EventStructure structure;
  final RoundLevel level;

  int get categoryId => structure.categoryId;
  String get categoryLabel => structure.categoryLabel;
  RoundType get type => level.type;
}

/// Feeds the race-detail "Séries" tab with the locally-defined structure(s) for
/// this race (one per category), plus per-category engaged counts. Read-only.
class RaceStructureController extends GetxController {
  RaceStructureController(this._programme, this._raceRepo);

  final ProgrammeService _programme;
  final RaceRepository _raceRepo;

  final Rxn<Race> race = Rxn<Race>();
  final Rxn<Competition> competition = Rxn<Competition>();
  final RxBool isLoading = true.obs;
  final RxList<EventStructure> structures = <EventStructure>[].obs;

  Map<int, int> _entryCountByCategory = const {};

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
      } on AppException {
        // Entries unavailable (offline / API error): the structure still
        // renders; category counts fall back to zero.
        _entryCountByCategory = const {};
      }
    } finally {
      isLoading.value = false;
    }
  }

  bool get hasStructure => structures.any((s) => s.levels.isNotEmpty);

  int entryCountFor(int categoryId) => _entryCountByCategory[categoryId] ?? 0;

  bool get showCategoryHeaders => structures.length > 1;

  /// The menu bar: one entry per category × round actually defined, categories
  /// in the order [structures] holds them, rounds in the structure's own order.
  List<RoundTab> get tabs => [
        for (final s in structures)
          for (final level in s.levels) RoundTab(structure: s, level: level),
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
