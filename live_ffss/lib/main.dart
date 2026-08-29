import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:live_ffss/app/core/di/initial_binding.dart';
import 'package:live_ffss/app/core/services/language_service.dart';
import 'package:live_ffss/app/core/themes/app_theme.dart';
import 'package:live_ffss/app/core/translations/app_translations.dart';
import 'package:live_ffss/app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Loads the locale date symbols every non-`en_US` `DateFormat` needs. Without
  // it, a locale-parameterised format (the réunion name in ScheduleController)
  // throws LocaleDataException — which is not an AppException, so nothing
  // catches it.
  await initializeDateFormatting();
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
