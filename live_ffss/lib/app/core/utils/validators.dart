import 'package:get/get.dart';

class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'id_required'.tr;
    }

    // final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    // if (!emailRegExp.hasMatch(value)) {
    //   return 'invalid_id'.tr;
    // }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'password_required'.tr;
    }

    // if (value.length < 6) {
    //   return 'Password must be at least 6 characters';
    // }

    return null;
  }
}
