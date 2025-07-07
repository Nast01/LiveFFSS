import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import 'package:live_ffss/app/module/auth/controllers/auth_controller.dart';
import 'package:live_ffss/app/module/home/controllers/home_controller.dart';
import 'package:live_ffss/app/routes/app_pages.dart';

class UserController extends GetxController {
  final UserService _userService = Get.find<UserService>();

  // Reactive getters
  bool get isLoggedIn => _userService.isLoggedIn;
  String? get userFirstLetter => _userService.userFirstLetter;

  // Observable for reactive UI updates
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
      // Clear user data first to avoid state conflicts
      _userService.clearCurrentUser();

      // If AuthController is available, let it handle the logout process
      if (Get.isRegistered<AuthController>()) {
        try {
          _refreshDependentControllers();
          await Get.find<AuthController>().logout();
          _showSuccessSnackbar('logout_success'.tr);
          // AuthController.logout() already navigates to home, so we're done
          return;
        } catch (authError) {
          // If AuthController fails, continue with manual logout
        }
      }

      // Manual logout: clear storage and navigate
      try {
        final storage = Get.find<FlutterSecureStorage>();
        await storage.deleteAll();
      } catch (storageError) {
        // Ignore storage errors
      }

      // Navigate to home page and clear all previous routes
      Get.offAllNamed(Routes.home);
    } catch (e) {
      // Even if everything fails, ensure user is cleared and navigate to home
      _userService.clearCurrentUser();
      Get.offAllNamed(Routes.home);
    }
  }

  void _refreshDependentControllers() {
    // Refresh HomeController if it's registered
    if (Get.isRegistered<HomeController>()) {
      try {
        final homeController = Get.find<HomeController>();
        homeController.refreshAfterLogout();
      } catch (e) {
        // Ignore if HomeController refresh fails
      }
    }

    // Force update the UI
    Get.forceAppUpdate();
  }

  Future<void> _handleDirectLogout() async {
    try {
      // Clear user session directly through user service
      _userService.clearCurrentUser();

      // Clear secure storage if available
      final storage = Get.find<FlutterSecureStorage>();
      await storage.deleteAll();
    } catch (e) {
      throw Exception('Direct logout failed: $e');
    }
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
