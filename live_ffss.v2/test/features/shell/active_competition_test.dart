import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/features/shell/active_competition.dart';

import '../../support/competitions.dart';
import '../../support/in_memory_local_store.dart';

class _CountingStore extends InMemoryLocalStore {
  int writeCount = 0;

  @override
  Future<void> write(String key, String value) {
    writeCount++;
    return super.write(key, value);
  }
}

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

  test('rien d\'enregistré : aucune sélection', () async {
    expect(await container.read(activeCompetitionProvider.future), isNull);
  });

  test('relit l\'id enregistré, sans résumé', () async {
    store.values[ActiveCompetitionNotifier.storageKey] = '1453';

    final selection = await container.read(activeCompetitionProvider.future);

    expect(selection?.id, 1453);
    expect(selection?.summary, isNull);
  });

  test('un id illisible vaut aucune sélection', () async {
    store.values[ActiveCompetitionNotifier.storageKey] = 'abc';

    expect(await container.read(activeCompetitionProvider.future), isNull);
  });

  test('select garde le résumé en mémoire et enregistre l\'id', () async {
    await container.read(activeCompetitionProvider.future);
    final c = competition(42, start: DateTime(2025, 5, 1));

    await container.read(activeCompetitionProvider.notifier).select(c);

    expect(container.read(activeCompetitionProvider).value, (
      id: 42,
      summary: c,
    ));
    expect(store.values[ActiveCompetitionNotifier.storageKey], '42');
  });

  test('ensure ne réécrit pas le même id', () async {
    store.values[ActiveCompetitionNotifier.storageKey] = '7';
    await container.read(activeCompetitionProvider.future);
    final c = competition(7, start: DateTime(2025, 5, 1));
    await container.read(activeCompetitionProvider.notifier).select(c);
    store.values[ActiveCompetitionNotifier.storageKey] = 'témoin';

    await container.read(activeCompetitionProvider.notifier).ensure(7);

    expect(container.read(activeCompetitionProvider).value, (
      id: 7,
      summary: c,
    ));
    expect(store.values[ActiveCompetitionNotifier.storageKey], 'témoin');
  });

  test('ensure enregistre un nouvel id', () async {
    await container.read(activeCompetitionProvider.future);

    await container.read(activeCompetitionProvider.notifier).ensure(8);

    expect(container.read(activeCompetitionProvider).value, (
      id: 8,
      summary: null,
    ));
    expect(store.values[ActiveCompetitionNotifier.storageKey], '8');
  });

  test('ensure avant la fin du chargement ne réécrit rien', () async {
    final counting = _CountingStore()
      ..values[ActiveCompetitionNotifier.storageKey] = '7';
    final other = ProviderContainer(
      overrides: [localStoreProvider.overrideWithValue(counting)],
      retry: noRetry,
    );
    addTearDown(other.dispose);

    await other.read(activeCompetitionProvider.notifier).ensure(7);

    expect(counting.writeCount, 0);
  });
}
