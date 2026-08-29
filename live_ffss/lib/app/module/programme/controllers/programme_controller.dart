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

/// The four criteria the structure overview can be narrowed by. The view
/// renders one chip per arm, so a new criterion costs a single enum value.
enum StructureFilter { speciality, discipline, gender, category }

/// One selectable value of a criterion: what rows are matched on, and how to
/// name it in the selection sheet.
///
/// [value] is an id for every criterion but the gender, whose rows are matched
/// on the [Gender] itself — and whose [label] is left empty, since naming a
/// gender needs `.tr`, which belongs to the view.
class FilterOption {
  const FilterOption(this.value, this.label);

  final Object value;
  final String label;
}

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
    required this.specialityId,
    required this.specialityLabel,
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

  /// Eau plate or Côtier, carried per row rather than per competition: a
  /// programme can mix both, and the filter bar separates them.
  final int specialityId;
  final String specialityLabel;

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

  /// Values ticked per criterion. Empty means "no restriction", which is why
  /// nothing here needs an explicit "all" arm.
  final Map<StructureFilter, RxSet<Object>> _filters = {
    for (final filter in StructureFilter.values) filter: <Object>{}.obs,
  };

  /// The rows the active filters leave: ANDed across criteria, ORed inside one.
  /// Everything the operator acts on — the list, the counters, the bulk
  /// actions — goes through here, so the filter is never a mere display trick.
  List<OverviewRow> get visibleRows => rows.where(_matches).toList();

  bool _matches(OverviewRow row) =>
      _passes(StructureFilter.speciality, row.specialityId) &&
      _passes(StructureFilter.discipline, row.disciplineId) &&
      _passes(StructureFilter.gender, row.gender) &&
      _passes(StructureFilter.category, row.categoryId);

  bool _passes(StructureFilter filter, Object value) {
    final selected = _filters[filter]!;
    return selected.isEmpty || selected.contains(value);
  }

  bool get hasActiveFilters =>
      _filters.values.any((selected) => selected.isNotEmpty);

  int selectedCount(StructureFilter filter) => _filters[filter]!.length;

  bool isSelected(StructureFilter filter, Object value) =>
      _filters[filter]!.contains(value);

  void toggle(StructureFilter filter, Object value) {
    final selected = _filters[filter]!;
    if (!selected.remove(value)) selected.add(value);
  }

  void clear(StructureFilter filter) => _filters[filter]!.clear();

  void clearFilters() {
    for (final selected in _filters.values) {
      selected.clear();
    }
  }

  /// The values [filter] can take, distinct and drawn from the loaded rows, so
  /// the sheet never offers a choice that would empty the list.
  List<FilterOption> optionsFor(StructureFilter filter) {
    final labelByValue = <Object, String>{};
    for (final row in rows) {
      switch (filter) {
        case StructureFilter.speciality:
          labelByValue[row.specialityId] = row.specialityLabel;
        case StructureFilter.discipline:
          labelByValue[row.disciplineId] = row.raceLabel;
        case StructureFilter.gender:
          labelByValue[row.gender] = '';
        case StructureFilter.category:
          labelByValue[row.categoryId] = row.categoryLabel;
      }
    }
    final options = [
      for (final entry in labelByValue.entries)
        FilterOption(entry.key, entry.value),
    ];
    if (filter == StructureFilter.gender) {
      // Genders carry no label here — the view translates them — so they sort
      // on the enum, which already reads men, women, mixed.
      options.sort((a, b) =>
          (a.value as Gender).index.compareTo((b.value as Gender).index));
    } else {
      options.sort((a, b) => a.label.compareTo(b.label));
    }
    return options;
  }

  /// Drops ticked values that no longer exist in [rows]. Without this, an
  /// épreuve the server stopped returning would leave the operator on an empty
  /// list with nothing left to un-tick.
  void _pruneFilters() {
    for (final filter in StructureFilter.values) {
      final selected = _filters[filter]!;
      if (selected.isEmpty) continue;
      final available = {for (final o in optionsFor(filter)) o.value};
      selected.removeWhere((value) => !available.contains(value));
    }
  }

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
            specialityId: race.specialityId,
            specialityLabel: race.specialityLabel,
            entryCount: count,
            structure: _structureFor(race.id, category.id),
            defaultSpotsPerRace: race.defaultSpotsPerRace,
            raceFormat: formats[(race.disciplineId, race.gender, category.id)],
          ));
        }
      }
      rows.value = built;
      _pruneFilters();
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

  /// Applies the default structure to every visible row that has entries but
  /// no structure yet, and persists all of them in one save. The heat size
  /// comes from the race speciality — 16 coastal, 8 pool.
  Future<void> generateAllDefaults() async {
    final toAdd = <EventStructure>[];
    for (final row in visibleRows) {
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

  /// Visible rows for which FFSS holds no déroulement yet.
  List<OverviewRow> get rowsWithoutRaceFormat =>
      visibleRows.where((r) => !r.hasRaceFormat).toList();

  int get missingRaceFormatCount => rowsWithoutRaceFormat.length;

  /// Gender of the épreuve [raceId] — the FFSS `Race.id`, not a
  /// [ProgrammeRace] id. [EventStructure] carries no gender of its own, so
  /// anything showing a structure and needing the gender resolves it here.
  /// [Gender.unknown] when the épreuve is not among the loaded rows.
  Gender genderForRace(int raceId) {
    for (final row in rows) {
      if (row.raceId == raceId) return row.gender;
    }
    return Gender.unknown;
  }

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

  /// What the two bulk actions would touch, so their labels can say it rather
  /// than leaving the operator to count the rows on screen.
  int get generatableCount =>
      visibleRows.where((r) => r.structure == null && r.entryCount > 0).length;

  int get deletableCount =>
      visibleRows.where((r) => r.structure != null).length;

  bool get hasAnyStructure => deletableCount > 0;

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

  /// Drops the structures of every visible row, heats included. The sites,
  /// schedule blocks and day starts are left alone — they are not part of the
  /// structure tree, and neither is anything the filter currently hides.
  Future<void> deleteAllStructures() async {
    final current = _programme.current.value;
    if (current == null || current.structures.isEmpty) return;
    final visible = {for (final r in visibleRows) (r.raceId, r.categoryId)};
    final kept = current.structures
        .where((s) => !visible.contains((s.raceId, s.categoryId)))
        .toList();
    if (kept.length == current.structures.length) return;
    await _programme.save(current.copyWith(structures: kept));
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
          specialityId: row.specialityId,
          specialityLabel: row.specialityLabel,
          entryCount: row.entryCount,
          structure: _structureFor(row.raceId, row.categoryId),
          defaultSpotsPerRace: row.defaultSpotsPerRace,
          raceFormat: row.raceFormat,
        ),
    ];
  }
}
