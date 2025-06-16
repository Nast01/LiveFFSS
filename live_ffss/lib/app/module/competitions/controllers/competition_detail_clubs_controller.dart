import 'package:get/get.dart';
import 'package:live_ffss/app/core/services/language_service.dart';
import 'package:live_ffss/app/data/models/club_model.dart';
import 'package:live_ffss/app/data/models/competition_model.dart';
import 'package:live_ffss/app/data/services/api_service.dart';
import 'package:live_ffss/app/data/services/user_service.dart';

class CompetitionDetailClubsController extends GetxController {
  final UserService _userService = Get.find<UserService>();
  final LanguageService _languageService = Get.find<LanguageService>();
  final ApiService _apiService = Get.find<ApiService>();

  Rxn<CompetitionModel> competition = Rxn<CompetitionModel>();
  final RxList<ClubModel> allClubs = <ClubModel>[].obs;
  final RxList<ClubModel> filteredClubs = <ClubModel>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Get the competition from arguments
    competition.value = Get.arguments as CompetitionModel;
    loadClubs();
  }

  Future<void> loadClubs() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final loadedClubs =
          await _apiService.getClubs(competition.value?.id ?? 0);

      // Sort races by raceType and name
      loadedClubs.sort((a, b) {
        return a.name.compareTo(b.name);
      });

      allClubs.value = loadedClubs;
      _applyClubFilter(); // Apply initial filter
      isLoading.value = false;
    } catch (e) {
      hasError.value = true;
      isLoading.value = false;
    }
  }

  void _applyClubFilter() {
    filteredClubs.value = List.from(allClubs);
  }
}
