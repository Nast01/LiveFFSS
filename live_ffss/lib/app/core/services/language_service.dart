import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LanguageService extends GetxService {
  LanguageService(this._storage);

  /// Localisateur conserve pour les extensions de presentation, qui n'ont pas
  /// de constructeur ou injecter quoi que ce soit — voir `RaceFormatting`.
  static LanguageService get to => Get.find();

  final FlutterSecureStorage _storage;
  final RxString currentLanguage = 'fr_FR'.obs;

  bool get isEnglish => currentLanguage.value == 'en_US';

  Future<LanguageService> init() async {
    final savedLanguage = await _storage.read(key: 'language');
    if (savedLanguage != null) {
      await changeLanguage(savedLanguage);
    }
    return this;
  }

  /// La langue change à l'écran avant que l'écriture ne parte — l'interface
  /// n'a pas à attendre le disque pour se retourner — mais l'écriture est
  /// attendue : non attendue, son échec partait en erreur asynchrone que
  /// personne n'écoutait, et la langue revenait à la précédente au prochain
  /// démarrage sans que rien ne l'ait dit.
  Future<void> changeLanguage(String languageCode) async {
    currentLanguage.value = languageCode;
    Get.updateLocale(getLocaleFromString(languageCode));
    await _storage.write(key: 'language', value: languageCode);
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
