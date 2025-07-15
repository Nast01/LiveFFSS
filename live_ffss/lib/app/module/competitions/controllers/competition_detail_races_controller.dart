import 'package:get/get.dart';
import 'package:live_ffss/app/data/models/competition_model.dart';
import 'package:live_ffss/app/data/models/race_model.dart';
import 'package:live_ffss/app/data/services/api_service.dart';

class CompetitionDetailRacesController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  Rxn<CompetitionModel> competition = Rxn<CompetitionModel>();
  final RxList<RaceModel> allRaces = <RaceModel>[].obs;
  final RxList<RaceModel> filteredRaces = <RaceModel>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  // Filter for epreuves
  final RxInt selectedFilterIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();

    // Get the competition from arguments
    competition.value = Get.arguments as CompetitionModel;
    loadRaces();
  }

  // Filter methods
  void setFilterIndex(int index) {
    selectedFilterIndex.value = index;
    // Apply filter logic here if needed
    _applyRaceFilter();
  }

  Future<void> loadRaces() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final loadedRaces =
          await _apiService.getRaces(competition.value?.id ?? 0);

      // Sort races by raceType and name
      loadedRaces.sort((a, b) {
        final typeComparison = a.raceTypeId.compareTo(b.raceTypeId);
        if (typeComparison != 0) {
          return typeComparison;
        }
        return a.name.compareTo(b.name);
      });

      selectedFilterIndex.value = 0; // Reset filter to "Tous"
      allRaces.value = loadedRaces;
      _applyRaceFilter(); // Apply initial filter

      isLoading.value = false;
    } catch (e) {
      hasError.value = true;
      isLoading.value = false;
    }
  }

  void _applyRaceFilter() {
    // Implement filter logic based on selectedFilterIndex
    // 0: Tous, 1: Plage, 2: Mer, 3: Piscine
    switch (selectedFilterIndex.value) {
      case 0:
        // Show all races
        filteredRaces.value = List.from(allRaces);
        break;
      case 1:
        // Filter for beach races
        filteredRaces.value =
            allRaces.where((race) => race.raceType == "Côtier").toList();
        break;
      case 2:
        // Filter for swimming races
        filteredRaces.value =
            allRaces.where((race) => race.raceType == "Eau-plate").toList();
        break;
    }
  }
}
