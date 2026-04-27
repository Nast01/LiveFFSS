import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/di/initial_binding.dart';
import 'package:live_ffss/app/core/services/language_service.dart';
import 'package:live_ffss/app/core/themes/app_theme.dart';
import 'package:live_ffss/app/core/translations/app_translations.dart';
import 'package:live_ffss/app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await InitialBinding.register();

  final languageService = Get.find<LanguageService>();
  final initialLocale = languageService
      .getLocaleFromString(languageService.currentLanguage.value);

  runApp(
    GetMaterialApp(
      title: 'app_title'.tr,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      theme: appThemeData,
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: initialLocale,
      fallbackLocale: const Locale('fr', 'FR'),
    ),
  );
}
