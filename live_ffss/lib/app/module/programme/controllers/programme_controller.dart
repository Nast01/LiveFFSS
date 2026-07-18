import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';

/// One line of the structure overview: an épreuve × category, its entry count,
/// and the structure defined for it (null if none yet).
class OverviewRow {
  const OverviewRow({
    required this.raceId,
    required this.categoryId,
    required this.raceLabel,
    required this.categoryLabel,
    required this.entryCount,
    required this.structure,
  });

  final int raceId;
  final int categoryId;
  final String raceLabel;
  final String categoryLabel;
  final int entryCount;
  final EventStructure? structure;
}

class ProgrammeController extends GetxController {
  ProgrammeController(this._raceRepo, this._programme);

  final RaceRepository _raceRepo;
  final ProgrammeService _programme;

  final Rxn<Competition> competition = Rxn<Competition>();
  final RxInt currentTabIndex = 0.obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxList<OverviewRow> rows = <OverviewRow>[].obs;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is Competition) {
      load(arg);
    } else {
      isLoading.value = false;
    }
  }

  void changeTab(int index) => currentTabIndex.value = index;

  Future<void> load(Competition comp) async {
    competition.value = comp;
    try {
      isLoading.value = true;
      hasError.value = false;

      await _programme.load(comp.id);
      final races = await _raceRepo.getRaces(comp.id);

      final built = <OverviewRow>[];
      for (final race in races) {
        final entries = await _raceRepo.getEntries(race.id);
        for (final category in race.categories) {
          final count =
              entries.where((e) => e.category.id == category.id).length;
          built.add(OverviewRow(
            raceId: race.id,
            categoryId: category.id,
            raceLabel: race.name,
            categoryLabel: category.name,
            entryCount: count,
            structure: _structureFor(race.id, category.id),
          ));
        }
      }
      rows.value = built;
    } on AppException {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  EventStructure? _structureFor(int raceId, int categoryId) {
    final structures = _programme.current.value?.structures ?? const [];
    for (final s in structures) {
      if (s.raceId == raceId && s.categoryId == categoryId) return s;
    }
    return null;
  }
}
