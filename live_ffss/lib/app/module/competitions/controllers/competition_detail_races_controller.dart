import 'package:get/get.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/race.dart';
import 'package:live_ffss/app/presentation/shared/filter_chip_bar.dart';

/// The criteria the events list can be narrowed by. The view renders one chip
/// per arm, so a new criterion costs a single enum value.
enum RaceFilter { speciality, discipline, gender, category }

class CompetitionDetailRacesController extends GetxController {
  CompetitionDetailRacesController(this._raceRepo);

  final RaceRepository _raceRepo;

  Rxn<Competition> competition = Rxn<Competition>();
  final RxList<Race> allRaces = <Race>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;

  /// Values ticked per criterion. Empty means "no restriction", which is why
  /// nothing here needs an explicit "all" arm.
  final Map<RaceFilter, RxSet<Object>> _filters = {
    for (final filter in RaceFilter.values) filter: <Object>{}.obs,
  };

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is Competition) {
      competition.value = arg;
      loadRaces(arg.id);
    } else {
      isLoading.value = false;
    }
  }

  /// The épreuves the active filters leave: ANDed across criteria, ORed inside
  /// one.
  List<Race> get filteredRaces => allRaces.where(_matches).toList();

  bool _matches(Race race) =>
      _passes(RaceFilter.speciality, race.specialityId) &&
      _passes(RaceFilter.discipline, race.disciplineId) &&
      _passes(RaceFilter.gender, race.gender) &&
      _passesCategory(race);

  bool _passes(RaceFilter filter, Object value) {
    final selected = _filters[filter]!;
    return selected.isEmpty || selected.contains(value);
  }

  /// An épreuve runs several categories at once, so one ticked category is
  /// enough to keep it: hiding it because another of its categories was not
  /// picked would hide an épreuve that genuinely takes place.
  bool _passesCategory(Race race) {
    final selected = _filters[RaceFilter.category]!;
    if (selected.isEmpty) return true;
    return race.categories.any((c) => selected.contains(c.id));
  }

  bool get hasActiveFilters =>
      _filters.values.any((selected) => selected.isNotEmpty);

  int selectedCount(RaceFilter filter) => _filters[filter]!.length;

  bool isSelected(RaceFilter filter, Object value) =>
      _filters[filter]!.contains(value);

  void toggle(RaceFilter filter, Object value) {
    final selected = _filters[filter]!;
    if (!selected.remove(value)) selected.add(value);
  }

  void clear(RaceFilter filter) => _filters[filter]!.clear();

  void clearFilters() {
    for (final selected in _filters.values) {
      selected.clear();
    }
  }

  /// The values [filter] can take, distinct and drawn from the loaded épreuves,
  /// so the sheet never offers a choice that would empty the list.
  List<FilterOption> optionsFor(RaceFilter filter) {
    final labelByValue = <Object, String>{};
    for (final race in allRaces) {
      switch (filter) {
        case RaceFilter.speciality:
          labelByValue[race.specialityId] = race.specialityLabel;
        case RaceFilter.discipline:
          labelByValue[race.disciplineId] = race.name;
        case RaceFilter.gender:
          labelByValue[race.gender] = '';
        case RaceFilter.category:
          for (final category in race.categories) {
            labelByValue[category.id] = category.name;
          }
      }
    }
    final options = [
      for (final entry in labelByValue.entries)
        FilterOption(entry.key, entry.value),
    ];
    if (filter == RaceFilter.gender) {
      // Genders carry no label here — the bar translates them — so they sort
      // on the enum, which already reads men, women, mixed.
      options.sort((a, b) =>
          (a.value as Gender).index.compareTo((b.value as Gender).index));
    } else {
      options.sort((a, b) => a.label.compareTo(b.label));
    }
    return options;
  }

  /// Drops ticked values that no longer exist among the loaded épreuves.
  /// Without this, a discipline the server stopped returning would leave the
  /// operator on an empty list with nothing left to un-tick.
  void _pruneFilters() {
    for (final filter in RaceFilter.values) {
      final selected = _filters[filter]!;
      if (selected.isEmpty) continue;
      final available = {for (final o in optionsFor(filter)) o.value};
      selected.removeWhere((value) => !available.contains(value));
    }
  }

  Future<void> loadRaces(int competitionId) async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final loaded = await _raceRepo.getRaces(competitionId);
      loaded.sort((a, b) {
        final typeCompare = a.specialityId.compareTo(b.specialityId);
        if (typeCompare != 0) return typeCompare;
        return a.name.compareTo(b.name);
      });

      allRaces.value = loaded;
      _pruneFilters();
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }
}
