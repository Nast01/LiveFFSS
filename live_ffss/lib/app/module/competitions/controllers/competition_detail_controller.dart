import 'package:get/get.dart';
import 'package:live_ffss/app/core/services/language_service.dart';
import 'package:live_ffss/app/data/models/club_ranking.dart';
import 'package:live_ffss/app/data/models/competition_model.dart';

class CompetitionDetailController extends GetxController {
  final LanguageService _languageService = Get.find<LanguageService>();

  Rxn<CompetitionModel> competition = Rxn<CompetitionModel>();

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxInt currentTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();

    // Get the competition from arguments
    competition.value = Get.arguments as CompetitionModel;
  }

  List<ClubRanking> get clubRankingsLimited =>
      List.empty(); //.take(3).toList();

  // Current language
  RxString get currentLanguage => _languageService.currentLanguage;
  bool get isFrench => _languageService.isFrench;
  bool get isEnglish => _languageService.isEnglish;

  void changeTab(int index) {
    currentTabIndex.value = index;
  }

  Future<void> refreshData() async {
    // await fetchCompetitionDetails();
  }
}
