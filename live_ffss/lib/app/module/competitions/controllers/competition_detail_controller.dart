import 'package:get/get.dart';
import 'package:live_ffss/app/data/services/user_preferences_service.dart';
import 'package:live_ffss/app/domain/models/competition.dart';

class CompetitionDetailController extends GetxController {
  CompetitionDetailController(this._prefs);

  final UserPreferencesService _prefs;

  final Rxn<Competition> competition = Rxn<Competition>();
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

  RxSet<int> get favoriteIds => _prefs.favoriteIds;
  Future<void> toggleFavorite(int id) => _prefs.toggleFavorite(id);

  void changeTab(int index) {
    currentTabIndex.value = index;
  }
}
