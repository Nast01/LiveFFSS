import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/features/home/favorites.dart';

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

  test('rien d\'enregistré : aucun favori', () async {
    expect(await container.read(favoritesProvider.future), isEmpty);
  });

  test('relit les favoris enregistrés', () async {
    store.values[FavoritesNotifier.storageKey] = '[3,1]';

    expect(await container.read(favoritesProvider.future), {1, 3});
  });

  test('une valeur illisible vaut aucun favori, sans erreur', () async {
    store.values[FavoritesNotifier.storageKey] = 'pas du json';

    expect(await container.read(favoritesProvider.future), isEmpty);
  });

  test('toggle ajoute puis retire, et enregistre à chaque fois', () async {
    await container.read(favoritesProvider.future);
    final notifier = container.read(favoritesProvider.notifier);

    await notifier.toggle(5);
    expect(container.read(favoritesProvider).value, {5});
    expect(store.values[FavoritesNotifier.storageKey], '[5]');

    await notifier.toggle(5);
    expect(container.read(favoritesProvider).value, isEmpty);
    expect(store.values[FavoritesNotifier.storageKey], '[]');
  });
}
