import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:live_ffss/app/core/services/language_service.dart';
import 'package:live_ffss/app/core/themes/app_theme.dart';
import 'package:live_ffss/app/core/translations/app_translations.dart';
import 'package:live_ffss/app/data/services/api_service.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import 'package:live_ffss/app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize secure storage
  await Get.putAsync(() async => const FlutterSecureStorage());

  // Initialize user service (singleton)
  await Get.putAsync(() async => await UserService().init());

  // Initialize language service (singleton)
  await Get.putAsync(() async => await LanguageService().init());
  // Get the initial locale from language service
  final languageService = Get.find<LanguageService>();
  final initialLocale = languageService
      .getLocaleFromString(languageService.currentLanguage.value);

  // Initialize API service (singleton)
  await Get.putAsync(() async => ApiService());

  runApp(
    GetMaterialApp(
      title: 'app_title'.tr,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      theme: appThemeData,
      debugShowCheckedModeBanner: false,
      // Add translations
      translations: AppTranslations(),
      locale: initialLocale,
      fallbackLocale: const Locale('fr', 'FR'),
    ),
  );
}
