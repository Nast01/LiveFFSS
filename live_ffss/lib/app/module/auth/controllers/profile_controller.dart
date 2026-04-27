import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import 'package:live_ffss/app/domain/models/user.dart';
import 'package:live_ffss/app/module/auth/controllers/user_controller.dart';
import 'package:live_ffss/app/module/home/controllers/home_controller.dart';

class ProfileController extends GetxController {
  final UserService _userService = Get.find<UserService>();
  final UserController _userController = Get.find<UserController>();

  bool get isLoggedIn => _userService.isLoggedIn;
  User? get currentUser => _userService.currentUser.value;

  String get userDisplayName {
    final u = currentUser;
    if (u == null) return 'unknown_user'.tr;
    if (hasFirstName && hasLastName) return '${u.firstName} ${u.lastName}';
    if (hasFirstName) return u.firstName!;
    if (hasLastName) return u.lastName!;
    return u.label;
  }

  String get userInitials {
    final u = currentUser;
    if (u == null) return '?';
    if (hasFirstName && hasLastName) return '${u.firstName![0]}${u.lastName![0]}';
    if (hasFirstName) return u.firstName![0];
    if (hasLastName) return u.lastName![0];
    return u.label.isNotEmpty ? u.label[0] : '?';
  }

  String get userLabel => currentUser?.label ?? 'unknown'.tr;
  String? get firstName => currentUser?.firstName;
  String? get lastName => currentUser?.lastName;
  String? get licenseeNumber => currentUser?.licenseeNumber;
  String? get clubName => currentUser?.clubName;

  String get userTypeLabel {
    final u = currentUser;
    if (u == null) return 'unknown'.tr;
    return switch (u.type) {
      UserType.licensee => 'licensee'.tr,
      UserType.organisme => 'organisme'.tr,
      UserType.unknown => 'unknown'.tr,
    };
  }

  String get userRole {
    final u = currentUser;
    if (u == null) return 'unknown'.tr;
    return switch (u.role) {
      UserRole.admin => 'administrator'.tr,
      UserRole.user => 'user'.tr,
      UserRole.unknown => 'unknown'.tr,
    };
  }

  String? get birthYear => null;

  String get tokenExpirationFormatted {
    final exp = currentUser?.tokenExpiration;
    if (exp == null) return 'unknown'.tr;
    if (exp.isBefore(DateTime.now())) return 'expired'.tr;
    return DateFormat('dd/MM/yyyy HH:mm').format(exp);
  }

  String get sessionStatus {
    if (!isLoggedIn) return 'not_connected'.tr;
    final exp = currentUser?.tokenExpiration;
    if (exp == null) return 'unknown'.tr;
    final now = DateTime.now();
    if (exp.isBefore(now)) return 'session_expired'.tr;
    final d = exp.difference(now);
    if (d.inDays > 0) return 'expires_in_days'.trParams({'days': d.inDays.toString()});
    if (d.inHours > 0) return 'expires_in_hours'.trParams({'hours': d.inHours.toString()});
    return 'expires_soon'.tr;
  }

  bool get hasFirstName => currentUser?.firstName?.isNotEmpty == true;
  bool get hasLastName => currentUser?.lastName?.isNotEmpty == true;
  bool get hasLicenseeNumber => currentUser?.licenseeNumber?.isNotEmpty == true;
  bool get hasClub => currentUser?.clubName?.isNotEmpty == true;
  bool get hasYear => birthYear?.isNotEmpty == true;
  bool get isLicensee => currentUser?.type == UserType.licensee;
  bool get isOrganization => currentUser?.type == UserType.organisme;

  void navigateToLogin() => _userController.navigateToLogin();

  Future<void> logout() async {
    _refreshDependentControllers();
    await _userController.logout();
  }

  void _refreshDependentControllers() {
    if (Get.isRegistered<HomeController>()) {
      try {
        Get.find<HomeController>().refreshAfterLogout();
      } catch (_) {}
    }
    Get.forceAppUpdate();
  }

  Future<void> refreshProfile() async {
    Get.snackbar(
      'success'.tr,
      'profile_refreshed'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Get.theme.colorScheme.onPrimary,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void onInit() {
    super.onInit();
    ever(_userService.currentUser, (_) => update());
  }
}
