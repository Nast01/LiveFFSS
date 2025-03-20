import 'package:get/get.dart';
import 'package:live_ffss/app/core/services/language_service.dart';
import 'package:live_ffss/app/data/models/competition_model.dart';
import 'package:live_ffss/app/data/services/api_service.dart';
import 'package:live_ffss/app/routes/app_pages.dart';
import '../../../data/services/user_service.dart';

class HomeController extends GetxController {
  final UserService _userService = Get.find<UserService>();
  final LanguageService _languageService = Get.find<LanguageService>();
  final ApiService _apiService = Get.find<ApiService>();
  final RxList<CompetitionModel> competitions = <CompetitionModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxInt displayedItems = 3.obs;
  final RxString selectedFilter = 'TOUS'.obs;

  @override
  void onInit() {
    super.onInit();
    loadCompetitions();
  }

  Future<void> loadCompetitions() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      // In a real app, you would use the API
      // final response = await http.get(Uri.parse(apiUrl));
      // if (response.statusCode == 200) {
      //   final List<dynamic> data = json.decode(response.body);
      //   final loadedCompetitions = data.map((json) => Competition.fromJson(json)).toList();

      final loadedCompetitions = await _apiService.getAllCompetitions();

      // Sort competitions by begin date and then by name
      loadedCompetitions.sort((a, b) {
        final dateComparison =
            (a.beginDate ?? DateTime(0)).compareTo(b.beginDate ?? DateTime(0));
        if (dateComparison != 0) {
          return dateComparison;
        }
        return a.name.compareTo(b.name);
      });

      competitions.value = loadedCompetitions;
      isLoading.value = false;
    } catch (e) {
      hasError.value = true;
      isLoading.value = false;
    }
  }

  void loadMore() {
    final maxItems = competitions.length - 5;
    if (displayedItems.value < maxItems) {
      displayedItems.value += 3;
      if (displayedItems.value > maxItems) {
        displayedItems.value = maxItems;
      }
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    // In a real app, you would filter competitions here
    // For now, we just update the filter selection
  }

  List<CompetitionModel> get carouselCompetitions =>
      competitions.take(5).toList();

  List<CompetitionModel> get listCompetitions =>
      competitions.length > 5 ? competitions.skip(5).toList() : [];

  List<CompetitionModel> get displayedListCompetitions =>
      listCompetitions.take(displayedItems.value).toList();

  bool get hasMoreToLoad => displayedItems.value < listCompetitions.length;

  Rx<bool> get isLoggedIn {
    if (_userService.currentUser.value != null) {
      return true.obs;
    } else {
      return false.obs;
    }
  }

  void navigateToCompetitionDetails(CompetitionModel competition) {
    // In a real app, you would navigate to the competition details page
    Get.toNamed(Routes.competitionDetail, arguments: competition);
  }

  RxString get appTitle => 'app_title'.tr.obs;

  // Current language
  RxString get currentLanguage => _languageService.currentLanguage;

  void changeLanguage(String languageCode) {
    _languageService.changeLanguage(languageCode);
  }
}
