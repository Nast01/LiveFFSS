import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/features/settings/app_language.dart';

import '../../support/in_memory_local_store.dart';

void main() {
  late InMemoryLocalStore store;
  late ProviderContainer container;

  setUp(() {
    store = InMemoryLocalStore();
    container = ProviderContainer(
      overrides: [localStoreProvider.overrideWithValue(store)],
      retry: noRetry,
    );
    addTearDown(container.dispose);
  });

  test('rien d\'enregistré : la langue du téléphone', () async {
    expect(
      await container.read(appLanguageProvider.future),
      AppLanguage.system,
    );
  });

  test('relit la langue enregistrée', () async {
    store.values[AppLanguageNotifier.storageKey] = 'en';

    expect(
      await container.read(appLanguageProvider.future),
      AppLanguage.english,
    );
  });

  test('une valeur inconnue vaut la langue du téléphone', () async {
    store.values[AppLanguageNotifier.storageKey] = 'klingon';

    expect(
      await container.read(appLanguageProvider.future),
      AppLanguage.system,
    );
  });

  test('select change la langue et l\'enregistre', () async {
    await container.read(appLanguageProvider.future);

    await container
        .read(appLanguageProvider.notifier)
        .select(AppLanguage.french);

    expect(container.read(appLanguageProvider).value, AppLanguage.french);
    expect(store.values[AppLanguageNotifier.storageKey], 'fr');
  });

  test('la langue du téléphone ne force aucune locale', () {
    expect(AppLanguage.system.locale, isNull);
    expect(AppLanguage.french.locale, const Locale('fr'));
    expect(AppLanguage.english.locale, const Locale('en'));
  });
}
