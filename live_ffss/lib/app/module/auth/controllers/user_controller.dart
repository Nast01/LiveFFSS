import 'package:get/get.dart';
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

  void navigateToLogin() {
    try {
      Get.toNamed(Routes.login);
    } catch (e) {
      _showErrorSnackbar('navigation_error'.tr);
    }
  }

  void navigateToProfile() {
    try {
      if (!isLoggedIn) {
        navigateToLogin();
        return;
      }
      Get.toNamed(Routes.profile);
    } catch (e) {
      _showErrorSnackbar('navigation_error'.tr);
    }
  }

  void navigateToSettings() {
    try {
      if (!isLoggedIn) {
        navigateToLogin();
        return;
      }
      Get.toNamed(Routes.settings);
    } catch (e) {
      _showErrorSnackbar('navigation_error'.tr);
    }
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
    } catch (e) {
      try {
        await _authRepository.logout();
      } catch (_) {}
      Get.offAllNamed(Routes.home);
    }
  }

  void _refreshDependentControllers() {
    if (Get.isRegistered<HomeController>()) {
      try {
        Get.find<HomeController>().refreshAfterLogout();
      } catch (_) {}
    }
    Get.forceAppUpdate();
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'error'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
      duration: const Duration(seconds: 3),
    );
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
