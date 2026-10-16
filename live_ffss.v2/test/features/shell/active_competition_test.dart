import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/features/shell/active_competition.dart';

import '../../support/competitions.dart';
import '../../support/in_memory_local_store.dart';

void main() {
  late InMemoryLocalStore store;
  late ProviderContainer container;

  setUp(() {
    store = InMemoryLocalStore();
    container = ProviderContainer(
      overrides: [localStoreProvider.overrideWithValue(store)],
      retry: (_, _) => null,
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
}
