import 'package:get/get.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/race.dart';

class CompetitionDetailRacesController extends GetxController {
  CompetitionDetailRacesController(this._raceRepo);

  final RaceRepository _raceRepo;

  Rxn<Competition> competition = Rxn<Competition>();
  final RxList<Race> allRaces = <Race>[].obs;
  final RxList<Race> filteredRaces = <Race>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxInt selectedFilterIndex = 0.obs;

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

  void setFilterIndex(int index) {
    selectedFilterIndex.value = index;
    _applyRaceFilter();
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

      selectedFilterIndex.value = 0;
      allRaces.value = loaded;
      _applyRaceFilter();
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void _applyRaceFilter() {
    switch (selectedFilterIndex.value) {
      case 0:
        filteredRaces.value = List.from(allRaces);
      case 1:
        filteredRaces.value =
            allRaces.where((r) => r.specialityLabel == 'Côtier').toList();
      case 2:
        filteredRaces.value =
            allRaces.where((r) => r.specialityLabel == 'Eau-plate').toList();
      default:
        filteredRaces.value = List.from(allRaces);
    }
  }
}
