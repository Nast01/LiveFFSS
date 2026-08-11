import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/mappers/athlete_mapper.dart'
    show genderCode, parseGender;
import 'package:live_ffss/app/data/repositories/race_format_repository.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/race_format_configuration.dart';
import 'package:live_ffss/app/domain/models/race_format_detail.dart';
import 'package:live_ffss/app/domain/models/structure_generator.dart';
import 'package:live_ffss/app/presentation/modules/competitions/race_formatting.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';

/// One line of the structure overview: an épreuve × category, its entry count,
/// and the structure defined for it (null if none yet).
class OverviewRow {
  const OverviewRow({
    required this.raceId,
    required this.categoryId,
    required this.raceLabel,
    required this.categoryLabel,
    required this.gender,
    required this.disciplineId,
    required this.entryCount,
    required this.structure,
    required this.defaultSpotsPerRace,
    this.raceFormat,
  });

  final int raceId;
  final int categoryId;
  final String raceLabel;
  final String categoryLabel;
  final Gender gender;

  /// With [gender], identifies the déroulement this row belongs to — that pair
  /// is what `deroulement/submit` takes, not a race id.
  final int disciplineId;
  final int entryCount;
  final EventStructure? structure;

  /// Heat size to seed a structure with, resolved from the race speciality —
  /// 16 for coastal, 8 for pool. The controller resolves it so no `.tr`-free
  /// caller has to reach back to the Race.
  final int defaultSpotsPerRace;

  /// The "déroulement" FFSS holds for this épreuve × category, if any. Its
  /// `details` are the rounds the server already defines, which seed a new
  /// local structure far better than the flat default.
  final RaceFormatConfiguration? raceFormat;

  bool get hasRaceFormat => raceFormat != null;
}

class ProgrammeController extends GetxController {
  ProgrammeController(this._raceRepo, this._programme, this._raceFormatRepo);

  final RaceRepository _raceRepo;
  final ProgrammeService _programme;
  final RaceFormatRepository _raceFormatRepo;

  final Rxn<Competition> competition = Rxn<Competition>();
  final RxInt currentTabIndex = 0.obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxList<OverviewRow> rows = <OverviewRow>[].obs;

  /// True while a déroulement is being written to FFSS. Unlike the rest of the
  /// programme feature, that call leaves the device.
  final RxBool isSubmitting = false.obs;
  final Rxn<UiMessage> message = Rxn<UiMessage>();

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

  /// [silent] keeps [isLoading] down so the list stays on screen — a
  /// pull-to-refresh that swapped the rows for a spinner would yank the
  /// indicator out from under the finger.
  Future<void> load(Competition comp, {bool silent = false}) async {
    competition.value = comp;
    try {
      if (!silent) isLoading.value = true;
      hasError.value = false;

      await _programme.load(comp.id);
      final races = await _raceRepo.getRaces(comp.id);
      final formats = await _loadRaceFormats(comp.id);

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
            gender: race.gender,
            disciplineId: race.disciplineId,
            entryCount: count,
            structure: _structureFor(race.id, category.id),
            defaultSpotsPerRace: race.defaultSpotsPerRace,
            raceFormat: formats[(race.disciplineId, race.gender, category.id)],
          ));
        }
      }
      rows.value = built;
      await _adoptServerRoundsForEmptyStructures();
    } on AppException {
      hasError.value = true;
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  /// Re-fetches races, entries and déroulements without blanking the list.
  /// Named `reload` because `refresh` is already taken by GetxController.
  Future<void> reload() async {
    final comp = competition.value;
    if (comp == null) return;
    await load(comp, silent: true);
  }

  /// Applies the default structure to every row that has entries but no
  /// structure yet, and persists all of them in one save. The heat size comes
  /// from the race speciality — 16 coastal, 8 pool.
  Future<void> generateAllDefaults() async {
    final toAdd = <EventStructure>[];
    for (final row in rows) {
      if (row.structure != null || row.entryCount <= 0) continue;
      toAdd.add(EventStructure(
        raceId: row.raceId,
        categoryId: row.categoryId,
        raceLabel: row.raceLabel,
        categoryLabel: row.categoryLabel,
        spotsPerRace: row.defaultSpotsPerRace,
        levels: buildDefaultLevels(
          entryCount: row.entryCount,
          spotsPerRace: row.defaultSpotsPerRace,
          allocateId: _programme.allocateId,
        ),
      ));
    }
    if (toAdd.isEmpty) return;

    final current = _programme.current.value ??
        CompetitionProgramme(competitionId: competition.value!.id);
    final existingKeys =
        current.structures.map((s) => (s.raceId, s.categoryId)).toSet();
    final updated = current.copyWith(structures: [
      ...current.structures,
      ...toAdd.where((s) => !existingKeys.contains((s.raceId, s.categoryId))),
    ]);
    await _programme.save(updated);
  }

  /// Déroulements indexed by the triple that identifies an épreuve × category.
  ///
  /// A déroulement carries no race id — its own `Id` lives in a different
  /// namespace from `Race.id` — so (discipline, gender, category) is the only
  /// key the two sides share. Best-effort: if the call fails the overview still
  /// renders, simply without any server rounds to seed from.
  Future<Map<(int, Gender, int), RaceFormatConfiguration>> _loadRaceFormats(
      int competitionId) async {
    final byKey = <(int, Gender, int), RaceFormatConfiguration>{};
    try {
      final formats = await _raceFormatRepo.getRaceFormats(competitionId);
      for (final format in formats) {
        final gender = parseGender(format.gender);
        for (final category in format.categories) {
          byKey[(format.disciplineId, gender, category.id)] = format;
        }
      }
    } on AppException {
      // Leaves the map empty — the structures stay authorable offline.
    }
    return byKey;
  }

  /// Re-adopts the rounds FFSS declares for every stored structure that holds
  /// none — typically one whose rounds were all deleted.
  ///
  /// This is what makes a refresh actually pull the server state back: without
  /// it an emptied structure stayed empty for good, since the editor only ever
  /// seeded structures it had never stored. A structure that still holds rounds
  /// is left untouched — that is authored work, and the local copy wins.
  Future<void> _adoptServerRoundsForEmptyStructures() async {
    final programme = _programme.current.value;
    if (programme == null) return;

    final detailsByKey = <(int, int), List<RaceFormatDetail>>{};
    for (final row in rows) {
      final details = row.raceFormat?.details ?? const <RaceFormatDetail>[];
      if (details.isNotEmpty) {
        detailsByKey[(row.raceId, row.categoryId)] = details;
      }
    }

    var changed = false;
    final updated = <EventStructure>[];
    for (final structure in programme.structures) {
      final details = detailsByKey[(structure.raceId, structure.categoryId)];
      if (structure.levels.isNotEmpty || details == null) {
        updated.add(structure);
        continue;
      }
      updated.add(structure.copyWith(
        levels: buildLevelsFromDetails(
          details: details,
          // Bumps nextLocalId, hence the re-read below rather than reusing
          // the `programme` captured above.
          allocateId: _programme.allocateId,
        ),
      ));
      changed = true;
    }
    if (!changed) return;
    await _programme.save(
      _programme.current.value!.copyWith(structures: updated),
    );
  }

  /// Rows for which FFSS holds no déroulement yet.
  List<OverviewRow> get rowsWithoutRaceFormat =>
      rows.where((r) => !r.hasRaceFormat).toList();

  int get missingRaceFormatCount => rowsWithoutRaceFormat.length;

  /// Creates the déroulement covering [row], then reloads so the new server
  /// state — including the rounds it may come with — reaches the list.
  ///
  /// A déroulement spans every category of its (discipline, gender), so this
  /// submits the *whole* category set: the id of an existing déroulement when
  /// there is one, which turns the call into an update rather than a duplicate.
  Future<void> createRaceFormatFor(OverviewRow row) =>
      _submitGroups([(row.disciplineId, row.gender)]);

  /// Same, for every épreuve × category FFSS does not cover yet, grouped so a
  /// discipline × gender is submitted once with all its categories.
  Future<void> createMissingRaceFormats() {
    final groups = <(int, Gender)>[];
    for (final row in rowsWithoutRaceFormat) {
      final key = (row.disciplineId, row.gender);
      if (!groups.contains(key)) groups.add(key);
    }
    return _submitGroups(groups);
  }

  Future<void> _submitGroups(List<(int, Gender)> groups) async {
    final comp = competition.value;
    if (comp == null || groups.isEmpty || isSubmitting.value) return;
    isSubmitting.value = true;
    var created = 0;
    try {
      for (final (disciplineId, gender) in groups) {
        final peers = rows
            .where((r) => r.disciplineId == disciplineId && r.gender == gender);
        final categoryIds = <int>{for (final r in peers) r.categoryId}.toList();
        final existing = peers
            .map((r) => r.raceFormat)
            .whereType<RaceFormatConfiguration>()
            .firstOrNull;
        final id = await _raceFormatRepo.submitRaceFormat(
          competitionId: comp.id,
          disciplineId: disciplineId,
          gender: genderCode(gender),
          categoryIds: categoryIds,
          id: existing?.id,
        );
        if (id > 0) created++;
      }
    } on AppException {
      message.value = const UiMessageError('race_format_create_failed');
      return;
    } finally {
      isSubmitting.value = false;
    }
    message.value = created == groups.length
        ? const UiMessageSuccess('race_format_created')
        : const UiMessageError('race_format_create_failed');
    await load(comp);
  }

  bool get hasAnyStructure =>
      (_programme.current.value?.structures ?? const []).isNotEmpty;

  /// Drops the structure of one épreuve × category. Also destroys the heats
  /// drawn into its races — the view confirms before calling this.
  Future<void> deleteStructure(int raceId, int categoryId) async {
    final current = _programme.current.value;
    if (current == null) return;
    final kept = current.structures
        .where((s) => !(s.raceId == raceId && s.categoryId == categoryId))
        .toList();
    if (kept.length == current.structures.length) return;
    await _programme.save(current.copyWith(structures: kept));
  }

  /// Drops every structure of the competition, heats included. The sites,
  /// schedule blocks and day starts are left alone — they are not part of the
  /// structure tree.
  Future<void> deleteAllStructures() async {
    final current = _programme.current.value;
    if (current == null || current.structures.isEmpty) return;
    await _programme.save(current.copyWith(structures: const []));
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
          gender: row.gender,
          disciplineId: row.disciplineId,
          entryCount: row.entryCount,
          structure: _structureFor(row.raceId, row.categoryId),
          defaultSpotsPerRace: row.defaultSpotsPerRace,
          raceFormat: row.raceFormat,
        ),
    ];
  }
}
