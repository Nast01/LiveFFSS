import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/providers.dart';

/// La langue choisie dans l'application. `system` suit le téléphone, avec le
/// français en repli (`resolveAppLocale`).
enum AppLanguage {
  system(null),
  french('fr'),
  english('en');

  const AppLanguage(this.code);

  /// La valeur enregistrée, et la langue imposée à l'application.
  final String? code;

  Locale? get locale => code == null ? null : Locale(code!);

  static AppLanguage fromCode(String? code) {
    for (final language in values) {
      if (language.code != null && language.code == code) return language;
    }
    return system;
  }
}

class AppLanguageNotifier extends AsyncNotifier<AppLanguage> {
  /// Clé globale (`AppEnvironment.globalKeys`) : une préférence d'interface
  /// survit à un changement de serveur.
  static const storageKey = 'language';

  @override
  Future<AppLanguage> build() async => AppLanguage.fromCode(
    await ref.watch(localStoreProvider).read(storageKey),
  );

  Future<void> select(AppLanguage language) async {
    state = AsyncData(language);
    final store = ref.read(localStoreProvider);
    final code = language.code;
    if (code == null) {
      await store.delete(storageKey);
    } else {
      await store.write(storageKey, code);
    }
  }
}

final appLanguageProvider =
    AsyncNotifierProvider<AppLanguageNotifier, AppLanguage>(
      AppLanguageNotifier.new,
    );
