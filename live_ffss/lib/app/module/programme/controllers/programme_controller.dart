import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/structure_generator.dart';

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

  // Kept so it can be disposed in onClose — _programme is a permanent service,
  // so an undisposed worker would retain this (lazyPut) controller for the
  // app's lifetime.
  Worker? _structuresWorker;

  @override
  void onInit() {
    super.onInit();
    _structuresWorker = ever<CompetitionProgramme?>(
      _programme.current,
      (_) => _refreshStructures(),
    );
    final arg = Get.arguments;
    if (arg is Competition) {
      load(arg);
    } else {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _structuresWorker?.dispose();
    super.onClose();
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

  /// Applies the default structure (8 spots/race) to every row that has
  /// entries but no structure yet, and persists all of them in one save.
  Future<void> generateAllDefaults() async {
    final toAdd = <EventStructure>[];
    for (final row in rows) {
      if (row.structure != null || row.entryCount <= 0) continue;
      toAdd.add(EventStructure(
        raceId: row.raceId,
        categoryId: row.categoryId,
        raceLabel: row.raceLabel,
        categoryLabel: row.categoryLabel,
        spotsPerRace: 8,
        levels: buildDefaultLevels(
          entryCount: row.entryCount,
          spotsPerRace: 8,
          allocateId: _programme.allocateId,
        ),
      ));
    }
    if (toAdd.isEmpty) return;

    final current = _programme.current.value ??
        CompetitionProgramme(competitionId: competition.value!.id);
    final existingKeys = current.structures
        .map((s) => (s.raceId, s.categoryId))
        .toSet();
    final updated = current.copyWith(structures: [
      ...current.structures,
      ...toAdd.where(
          (s) => !existingKeys.contains((s.raceId, s.categoryId))),
    ]);
    await _programme.save(updated);
  }

  EventStructure? _structureFor(int raceId, int categoryId) {
    final structures = _programme.current.value?.structures ?? const [];
    for (final s in structures) {
      if (s.raceId == raceId && s.categoryId == categoryId) return s;
    }
    return null;
  }

  /// Re-derives each row's `structure` from the current stored programme,
  /// without refetching races/entries. Keeps the overview in sync after an
  /// operator edits a structure elsewhere and returns.
  void _refreshStructures() {
    if (rows.isEmpty) return;
    rows.value = [
      for (final row in rows)
        OverviewRow(
          raceId: row.raceId,
          categoryId: row.categoryId,
          raceLabel: row.raceLabel,
          categoryLabel: row.categoryLabel,
          entryCount: row.entryCount,
          structure: _structureFor(row.raceId, row.categoryId),
        ),
    ];
  }
}
