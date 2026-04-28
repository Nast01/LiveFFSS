import 'package:get/get.dart';
import 'package:live_ffss/app/core/services/language_service.dart';
import 'package:live_ffss/app/domain/models/club_ranking.dart';
import 'package:live_ffss/app/domain/models/competition.dart';

class CompetitionDetailController extends GetxController {
  CompetitionDetailController(this._languageService);

  final LanguageService _languageService;

  Rxn<Competition> competition = Rxn<Competition>();

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxInt currentTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is Competition) {
      competition.value = arg;
    }
  }

  List<ClubRanking> get clubRankingsLimited => List.empty();

  RxString get currentLanguage => _languageService.currentLanguage;
  bool get isFrench => _languageService.isFrench;
  bool get isEnglish => _languageService.isEnglish;

  void changeTab(int index) {
    currentTabIndex.value = index;
  }

  Future<void> refreshData() async {
    // No-op until rankings are wired up.
  }
}
