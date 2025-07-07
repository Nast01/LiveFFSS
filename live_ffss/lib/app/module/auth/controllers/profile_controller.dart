import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:live_ffss/app/module/auth/controllers/user_controller.dart';
import 'package:live_ffss/app/module/home/controllers/home_controller.dart';
import '../../../data/services/user_service.dart';
import '../../../data/models/user_model.dart';

class ProfileController extends GetxController {
  final UserService _userService = Get.find<UserService>();
  final UserController _userController = Get.find<UserController>();

  // Reactive getters
  bool get isLoggedIn => _userService.isLoggedIn;
  UserModel? get currentUser => _userService.currentUser.value;

  // User display information
  String get userDisplayName {
    if (!isLoggedIn || currentUser == null) return 'unknown_user'.tr;

    if (hasFirstName && hasLastName) {
      return '${currentUser!.firstName} ${currentUser!.lastName}';
    } else if (hasFirstName) {
      return currentUser!.firstName!;
    } else if (hasLastName) {
      return currentUser!.lastName!;
    } else {
      return currentUser!.label;
    }
  }

  String get userInitials {
    if (!isLoggedIn || currentUser == null) return '?';

    if (hasFirstName && hasLastName) {
      return '${currentUser!.firstName![0]}${currentUser!.lastName![0]}';
    } else if (hasFirstName) {
      return currentUser!.firstName![0];
    } else if (hasLastName) {
      return currentUser!.lastName![0];
    } else {
      return currentUser!.label[0];
    }
  }

  String get userLabel => currentUser?.label ?? 'unknown'.tr;
  String? get firstName => currentUser?.firstName;
  String? get lastName => currentUser?.lastName;
  String? get licenseeNumber => currentUser?.number;
  String? get clubName => currentUser?.club;

  // User type and role information
  String get userTypeLabel {
    if (!isLoggedIn || currentUser == null) return 'unknown'.tr;

    switch (currentUser!.type) {
      case 'licencie':
        return 'licensee'.tr;
      case 'organisme':
        return 'organisme'.tr;
      default:
        return currentUser!.type;
    }
  }

  String get userRole {
    if (!isLoggedIn || currentUser == null) return 'unknown'.tr;

    switch (currentUser!.role) {
      case 'admin':
        return 'administrator'.tr;
      case 'user':
        return 'user'.tr;
      default:
        return currentUser!.role;
    }
  }

  // Additional information
  String? get birthYear {
    // This would need to be added to UserModel if available
    // For now, return null or implement based on your data structure
    return null;
  }

  String get tokenExpirationFormatted {
    if (!isLoggedIn || currentUser?.tokenExpirationDate == null) {
      return 'unknown'.tr;
    }

    final expirationDate = currentUser!.tokenExpirationDate!;
    final now = DateTime.now();

    if (expirationDate.isBefore(now)) {
      return 'expired'.tr;
    } else {
      final formatter = DateFormat('dd/MM/yyyy HH:mm');
      return formatter.format(expirationDate);
    }
  }

  String get sessionStatus {
    if (!isLoggedIn) return 'not_connected'.tr;

    if (currentUser?.tokenExpirationDate == null) {
      return 'unknown'.tr;
    }

    final expirationDate = currentUser!.tokenExpirationDate!;
    final now = DateTime.now();

    if (expirationDate.isBefore(now)) {
      return 'session_expired'.tr;
    } else {
      final duration = expirationDate.difference(now);
      if (duration.inDays > 0) {
        return 'expires_in_days'.trParams({'days': duration.inDays.toString()});
      } else if (duration.inHours > 0) {
        return 'expires_in_hours'
            .trParams({'hours': duration.inHours.toString()});
      } else {
        return 'expires_soon'.tr;
      }
    }
  }

  // Boolean getters for conditional display
  bool get hasFirstName => currentUser?.firstName?.isNotEmpty == true;
  bool get hasLastName => currentUser?.lastName?.isNotEmpty == true;
  bool get hasLicenseeNumber => currentUser?.number?.isNotEmpty == true;
  bool get hasClub => currentUser?.club?.isNotEmpty == true;
  bool get hasYear => birthYear?.isNotEmpty == true;
  bool get isLicensee => currentUser?.type == 'licencie';
  bool get isOrganization => currentUser?.type == 'organisme';

  // Actions
  void navigateToLogin() {
    _userController.navigateToLogin();
  }

  Future<void> logout() async {
    _refreshDependentControllers();
    await _userController.logout();
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

  Future<void> refreshProfile() async {
    try {
      // Refresh user session to get latest data
      await _userService.checkUserSession();

      // Force UI update
      update();

      // Show success message
      Get.snackbar(
        'success'.tr,
        'profile_refreshed'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      // Show error message
      Get.snackbar(
        'error'.tr,
        'refresh_failed'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  void onInit() {
    super.onInit();

    // Listen to user changes
    ever(_userService.currentUser, (_) => update());
  }
}
