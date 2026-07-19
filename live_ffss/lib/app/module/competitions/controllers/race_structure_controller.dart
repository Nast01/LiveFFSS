import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/race.dart';

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
}
