import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/config/app_environment.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/core/router/app_router.dart';
import 'package:live_ffss_v2/features/settings/start_tab.dart';

import '../../support/in_memory_local_store.dart';

class _FailingStore extends InMemoryLocalStore {
  @override
  Future<String?> read(String key) async =>
      throw const StorageException('illisible');

  @override
  Future<void> write(String key, String value) async =>
      throw const StorageException('plein');
}

void main() {
  late InMemoryLocalStore store;
  late ProviderContainer container;

  ProviderContainer containerWith(InMemoryLocalStore local) {
    final c = ProviderContainer(
      overrides: [localStoreProvider.overrideWithValue(local)],
      retry: noRetry,
    );
    addTearDown(c.dispose);
    return c;
  }

  setUp(() {
    store = InMemoryLocalStore();
    container = containerWith(store);
  });

  group('startTabProvider', () {
    test("rien d'enregistré : l'accueil", () async {
      expect(await container.read(startTabProvider.future), StartTab.home);
    });

    test("relit l'onglet enregistré", () async {
      store.values[StartTabNotifier.storageKey] = 'live';

      expect(await container.read(startTabProvider.future), StartTab.live);
    });

    test("une valeur inconnue vaut l'accueil", () async {
      store.values[StartTabNotifier.storageKey] = 'carte';

      expect(await container.read(startTabProvider.future), StartTab.home);
    });

    test("select change l'onglet et l'enregistre", () async {
      await container.read(startTabProvider.future);

      await container.read(startTabProvider.notifier).select(StartTab.results);

      expect(container.read(startTabProvider).value, StartTab.results);
      expect(store.values[StartTabNotifier.storageKey], 'results');
    });

    test(
      "stockage en panne : l'accueil, et le choix gardé en mémoire",
      () async {
        final failing = containerWith(_FailingStore());

        expect(await failing.read(startTabProvider.future), StartTab.home);
        await failing.read(startTabProvider.notifier).select(StartTab.live);
        expect(failing.read(startTabProvider).value, StartTab.live);
      },
    );

    test("clé globale : elle survit à un changement d'environnement", () {
      expect(AppEnvironment.globalKeys, contains(StartTabNotifier.storageKey));
    });
  });

  group('onglet au lancement', () {
    test("chaque onglet a sa racine", () {
      expect(startTabLocation(StartTab.home), Routes.home);
      expect(startTabLocation(StartTab.programme), Routes.programme);
      expect(startTabLocation(StartTab.live), Routes.live);
      expect(startTabLocation(StartTab.results), Routes.results);
    });

    test("seule l'ouverture sur l'accueil est redirigée", () {
      expect(startTabRedirect(Routes.home, StartTab.live), Routes.live);
      expect(startTabRedirect(Routes.home, StartTab.home), isNull);
      // Un lien direct garde sa page.
      expect(
        startTabRedirect(
          '/resultats/competition/1416/recherche',
          StartTab.live,
        ),
        isNull,
      );
    });

    test('appliqué une fois, au premier affichage', () async {
      var reads = 0;
      final redirect = LaunchRedirect(() async {
        reads++;
        return StartTab.programme;
      });

      expect(await redirect(Routes.home), Routes.programme);
      // Revenir ensuite sur l'accueil ne doit pas renvoyer ailleurs.
      expect(redirect(Routes.home), isNull);
      expect(redirect(Routes.live), isNull);
      expect(reads, 1);
    });

    test(
      'un lien direct au lancement : rien, et plus jamais ensuite',
      () async {
        final redirect = LaunchRedirect(() async => StartTab.live);

        expect(await redirect(Routes.mySpace), isNull);
        expect(redirect(Routes.home), isNull);
      },
    );

    test("lit l'onglet enregistré", () async {
      store.values[StartTabNotifier.storageKey] = 'results';
      final redirect = LaunchRedirect(
        () => container.read(startTabProvider.future),
      );

      expect(await redirect(Routes.home), Routes.results);
    });
  });

  test(
    "une lecture de la préférence en échec n'empêche pas le lancement",
    () async {
      final redirect = LaunchRedirect(() async => throw StateError('panne'));

      expect(await redirect(Routes.home), isNull);
      expect(redirect(Routes.home), isNull);
    },
  );

  test("libellé de l'onglet d'ouverture", () {
    final fr = lookupAppLocalizations(const Locale('fr'));
    expect(startTabLabel(StartTab.home, fr), 'Accueil');
    expect(startTabLabel(StartTab.programme, fr), 'Programme');
    expect(startTabLabel(StartTab.live, fr), 'Live');
    expect(startTabLabel(StartTab.results, fr), 'Résultats');
  });
}
