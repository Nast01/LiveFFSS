import 'package:get/get.dart';
import 'package:live_ffss/app/core/enum/enum.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/core/services/language_service.dart';
import 'package:live_ffss/app/data/repositories/competition_repository.dart';
import 'package:live_ffss/app/data/services/user_preferences_service.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/presentation/modules/home/competition_formatting.dart';
import 'package:live_ffss/app/routes/app_pages.dart';

enum HomeFilter { all, coastal, pool, mixed }

enum TemporalFilter { lastViewed, thisWeek, all }

class HomeController extends GetxController {
  HomeController(
    this._competitionRepo,
    this._userService,
    this._languageService,
    this._prefs,
  );

  final CompetitionRepository _competitionRepo;
  final UserService _userService;
  final LanguageService _languageService;
  final UserPreferencesService _prefs;

  final RxList<Competition> competitions = <Competition>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxList<Competition> thisWeekCompetitions = <Competition>[].obs;
  final RxBool isLoadingThisWeek = false.obs;
  final RxBool hasErrorThisWeek = false.obs;
  final Rx<HomeFilter> selectedDiscipline = HomeFilter.all.obs;
  final Rx<TemporalFilter> selectedTemporal = TemporalFilter.thisWeek.obs;
  final RxString searchQuery = ''.obs;

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

  Future<void> loadThisWeek() async {
    try {
      isLoadingThisWeek.value = true;
      hasErrorThisWeek.value = false;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final monday = today.subtract(Duration(days: today.weekday - 1));
      final sunday = monday.add(const Duration(days: 6));
      final loaded = await _competitionRepo.getCompetitionsForRange(
        from: monday,
        to: sunday,
      );
      loaded.sort((a, b) {
        final dateComparison = (a.beginDate ?? DateTime(0))
            .compareTo(b.beginDate ?? DateTime(0));
        if (dateComparison != 0) return dateComparison;
        return a.name.compareTo(b.name);
      });
      thisWeekCompetitions.value = loaded;
    } on AppException {
      hasErrorThisWeek.value = true;
    } finally {
      isLoadingThisWeek.value = false;
    }
  }

  void setTemporal(TemporalFilter t) {
    selectedTemporal.value = t;
    if (t == TemporalFilter.thisWeek &&
        thisWeekCompetitions.isEmpty &&
        !hasErrorThisWeek.value) {
      loadThisWeek();
    }
  }
  void setDiscipline(HomeFilter d) => selectedDiscipline.value = d;
  void setSearchQuery(String q) => searchQuery.value = q;

  RxSet<int> get favoriteIds => _prefs.favoriteIds;
  bool isFavorite(int id) => _prefs.isFavorite(id);
  Future<void> toggleFavorite(int id) => _prefs.toggleFavorite(id);

  List<Competition> get filteredCompetitions {
    Iterable<Competition> result = competitions;

    switch (selectedTemporal.value) {
      case TemporalFilter.lastViewed:
        final byId = {for (final c in competitions) c.id: c};
        result = _prefs.lastViewedIds
            .map((id) => byId[id])
            .where((c) => c != null)
            .cast<Competition>();
      case TemporalFilter.thisWeek:
        result = thisWeekCompetitions;
      case TemporalFilter.all:
        // no-op
    }

    switch (selectedDiscipline.value) {
      case HomeFilter.pool:
        result = result.where((c) => c.isSwimming);
      case HomeFilter.coastal:
        result = result.where((c) => c.isBeach);
      case HomeFilter.all:
      case HomeFilter.mixed:
        // no-op
    }

    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result.where((c) =>
          c.name.toLowerCase().contains(q) ||
          (c.location?.toLowerCase().contains(q) ?? false));
    }

    return result.toList();
  }

  bool get isLoggedIn => _userService.isLoggedIn;

  Future<void> navigateToCompetitionDetails(Competition competition) async {
    await _prefs.recordView(competition.id);
    Get.toNamed(Routes.competitionDetail, arguments: competition);
  }

  String get appTitleKey => 'app_title';

  RxString get currentLanguage => _languageService.currentLanguage;

  void changeLanguage(String languageCode) {
    _languageService.changeLanguage(languageCode);
  }

  void refreshAfterLogout() {
    selectedDiscipline.value = HomeFilter.all;
    selectedTemporal.value = TemporalFilter.thisWeek;
    searchQuery.value = '';
    thisWeekCompetitions.clear();
    hasErrorThisWeek.value = false;
    loadCompetitions();
  }
}
