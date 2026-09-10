import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/auth_repository.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import 'package:live_ffss/app/module/auth/controllers/auth_controller.dart';
import 'package:live_ffss/app/module/home/controllers/home_controller.dart';
import 'package:live_ffss/app/routes/app_pages.dart';

class UserController extends GetxController {
  final UserService _userService = Get.find<UserService>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  bool get isLoggedIn => _userService.isLoggedIn;
  String? get userFirstLetter => _userService.userFirstLetter;

  Rx<bool> get isUserLoggedIn => _userService.isLoggedIn.obs;

  void navigateToLogin() => Get.toNamed<void>(Routes.login);

  void navigateToProfile() {
    if (!isLoggedIn) {
      navigateToLogin();
      return;
    }
    Get.toNamed<void>(Routes.profile);
  }

  Future<void> logout() async {
    try {
      _refreshDependentControllers();

      if (Get.isRegistered<AuthController>()) {
        await Get.find<AuthController>().logout();
      } else {
        await _authRepository.logout();
      }
      _showSuccessSnackbar('logout_success'.tr);
      Get.offAllNamed(Routes.home);
    } on AppException {
      // La session doit tomber meme si le serveur refuse de la fermer :
      // seconde tentative en local, puis retour a l'accueil quoi qu'il arrive.
      try {
        await _authRepository.logout();
      } on AppException {
        // Rien de plus a tenter ; le token local est de toute facon efface.
      }
      Get.offAllNamed(Routes.home);
    }
  }

  void _refreshDependentControllers() {
    // refreshAfterLogout ne fait qu'ecrire des Rx et relancer un chargement :
    // rien n'y leve, et isRegistered couvre deja le controleur absent.
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().refreshAfterLogout();
    }
    Get.forceAppUpdate();
  }

  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'success'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Get.theme.colorScheme.onPrimary,
      duration: const Duration(seconds: 2),
    );
  }
}
