import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_pages.dart';
import '../../../data/services/user_service.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final UserService _userService = Get.find<UserService>();

  final idController = TextEditingController();
  final passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onClose() {
    idController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> login() async {
    if (formKey.currentState!.validate()) {
      try {
        isLoading.value = true;
        errorMessage.value = '';

        final user = await _authRepository.login(
          idController.text.trim(),
          passwordController.text,
        );

        // Update user service with current user
        _userService.setCurrentUser(user!);

        // Navigate to home page
        Get.offAllNamed(Routes.home);
      } catch (e) {
        errorMessage.value = e.toString();
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> logout() async {
    try {
      await _authRepository.logout();
      _userService.clearCurrentUser();
      Get.offAllNamed(Routes.home);
    } catch (e) {
      Get.snackbar('error'.tr, 'logout_error'.tr);
    }
  }

  Future<void> checkLoginStatus() async {
    await _userService.checkUserSession();
  }
}
