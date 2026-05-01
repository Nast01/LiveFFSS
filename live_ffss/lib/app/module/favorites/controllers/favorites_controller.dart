import 'package:get/get.dart';
import 'package:live_ffss/app/data/services/user_preferences_service.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/module/home/controllers/home_controller.dart';

class FavoritesController extends GetxController {
  FavoritesController(this._homeController, this._prefs);

  final HomeController _homeController;
  final UserPreferencesService _prefs;

  List<Competition> get favoriteCompetitions {
    final ids = _prefs.favoriteIds;
    return _homeController.competitions
        .where((c) => ids.contains(c.id))
        .toList();
  }

  RxBool get isLoading => _homeController.isLoading;
  RxBool get hasError => _homeController.hasError;
  RxList<Competition> get competitions => _homeController.competitions;
  RxSet<int> get favoriteIds => _prefs.favoriteIds;

  @override
  void onInit() {
    super.onInit();
    if (_homeController.competitions.isEmpty &&
        !_homeController.isLoading.value &&
        !_homeController.hasError.value) {
      _homeController.loadCompetitions();
    }
  }

  Future<void> retry() => _homeController.loadCompetitions();
  Future<void> toggleFavorite(int id) => _prefs.toggleFavorite(id);
  Future<void> navigateToCompetitionDetails(Competition c) =>
      _homeController.navigateToCompetitionDetails(c);
}
