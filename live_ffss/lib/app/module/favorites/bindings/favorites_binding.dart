import 'package:get/get.dart';
import 'package:live_ffss/app/data/services/user_preferences_service.dart';
import 'package:live_ffss/app/module/home/controllers/home_controller.dart';
import '../controllers/favorites_controller.dart';

class FavoritesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FavoritesController>(
      () => FavoritesController(
        Get.find<HomeController>(),
        Get.find<UserPreferencesService>(),
      ),
    );
  }
}
