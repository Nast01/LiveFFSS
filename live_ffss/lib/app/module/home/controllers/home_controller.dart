import 'package:get/get.dart';
import 'package:live_ffss/app/core/enum/enum.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/core/services/language_service.dart';
import 'package:live_ffss/app/data/repositories/competition_repository.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/routes/app_pages.dart';

enum HomeFilter { all, coastal, pool, mixed }

class HomeController extends GetxController {
  HomeController(
    this._competitionRepo,
    this._userService,
    this._languageService,
  );

  final CompetitionRepository _competitionRepo;
  final UserService _userService;
  final LanguageService _languageService;

  final RxList<Competition> competitions = <Competition>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxInt displayedItems = 3.obs;
  final Rx<HomeFilter> selectedFilter = HomeFilter.all.obs;

  @override
  void onInit() {
    super.onInit();
    loadCompetitions();
  }

  Future<void> loadCompetitions() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      final loaded = await _competitionRepo.getAllCompetitions(
        type: CompetitionType.mixte,
        visibility: CompetitionVisibility.passed,
      );
      loaded.sort((a, b) {
        final dateComparison = (a.beginDate ?? DateTime(0))
            .compareTo(b.beginDate ?? DateTime(0));
        if (dateComparison != 0) return dateComparison;
        return a.name.compareTo(b.name);
      });
      competitions.value = loaded;
    } on AppException {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void loadMore() {
    final maxItems = listCompetitions.length;
    if (displayedItems.value < maxItems) {
      displayedItems.value =
          (displayedItems.value + 3).clamp(0, maxItems);
    }
  }

  void setFilter(HomeFilter filter) {
    selectedFilter.value = filter;
  }

  List<Competition> get carouselCompetitions =>
      competitions.take(5).toList();

  List<Competition> get listCompetitions =>
      competitions.length > 5 ? competitions.skip(5).toList() : [];

  List<Competition> get displayedListCompetitions =>
      listCompetitions.take(displayedItems.value).toList();

  bool get hasMoreToLoad => displayedItems.value < listCompetitions.length;

  bool get isLoggedIn => _userService.isLoggedIn;

  void navigateToCompetitionDetails(Competition competition) {
    Get.toNamed(Routes.competitionDetail, arguments: competition);
  }

  RxString get appTitle => 'app_title'.tr.obs;

  RxString get currentLanguage => _languageService.currentLanguage;

  void changeLanguage(String languageCode) {
    _languageService.changeLanguage(languageCode);
  }

  void refreshAfterLogout() {
    displayedItems.value = 3;
    selectedFilter.value = HomeFilter.all;
    loadCompetitions();
    update();
  }
}
