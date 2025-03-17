import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LanguageService extends GetxService {
  final FlutterSecureStorage _storage = Get.find<FlutterSecureStorage>();

  final RxString currentLanguage = 'fr_FR'.obs;

  Future<LanguageService> init() async {
    // Load saved language preference
    final savedLanguage = await _storage.read(key: 'language');
    if (savedLanguage != null) {
      changeLanguage(savedLanguage);
    }
    return this;
  }

  void changeLanguage(String languageCode) {
    currentLanguage.value = languageCode;
    Get.updateLocale(getLocaleFromString(languageCode));
    _storage.write(key: 'language', value: languageCode);
  }

  Locale getLocaleFromString(String code) {
    switch (code) {
      case 'fr_FR':
        return const Locale('fr', 'FR');
      case 'en_US':
      default:
        return const Locale('en', 'US');
    }
  }
}
