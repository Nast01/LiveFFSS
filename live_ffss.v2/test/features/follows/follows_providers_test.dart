import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/core/storage/local_store.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/features/follows/follows_providers.dart';

import '../../support/in_memory_local_store.dart';

class _FailingWrites extends InMemoryLocalStore {
  @override
  Future<void> write(String key, String value) async =>
      throw const UnknownException('disque plein');
}

const _participant = Participant(
  id: 4,
  firstName: 'Un',
  lastName: 'ATHLETE',
  club: 'Club A',
  entries: [ParticipantEntry(entryId: 3, eventId: 1, categoryName: 'Open')],
);

ProviderContainer _container(LocalStore store) {
  final container = ProviderContainer(
    overrides: [localStoreProvider.overrideWithValue(store)],
    retry: noRetry,
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test("rien d'enregistré : aucun suivi", () async {
    final container = _container(InMemoryLocalStore());

    final follows = await container.read(followsProvider(1416).future);

    expect(follows.athletes, isEmpty);
    expect(follows.clubs, isEmpty);
  });

  test(
    'toggleAthlete suit puis retire, sous la clé de la compétition',
    () async {
      final store = InMemoryLocalStore();
      final container = _container(store);
      await container.read(followsProvider(1416).future);
      final notifier = container.read(followsProvider(1416).notifier);

      await notifier.toggleAthlete(_participant);
      expect(
        container.read(followsProvider(1416)).value!.athletes.single.name,
        'Un ATHLETE',
      );
      expect(store.values.keys, ['follows_1416']);

      await notifier.toggleAthlete(_participant);
      expect(container.read(followsProvider(1416)).value!.athletes, isEmpty);
    },
  );

  test('toggleClub suit puis retire', () async {
    final container = _container(InMemoryLocalStore());
    await container.read(followsProvider(1416).future);
    final notifier = container.read(followsProvider(1416).notifier);

    await notifier.toggleClub(7, 'Club B');
    expect(container.read(followsProvider(1416)).value!.clubs.single.id, 7);

    await notifier.toggleClub(7, 'Club B');
    expect(container.read(followsProvider(1416)).value!.clubs, isEmpty);
  });

  test('les suivis sont relus, par compétition', () async {
    final store = InMemoryLocalStore();
    final first = _container(store);
    await first.read(followsProvider(1416).future);
    final notifier = first.read(followsProvider(1416).notifier);
    await notifier.toggleClub(7, 'Club B');
    await notifier.toggleAthlete(_participant);

    final second = _container(store);
    final same = await second.read(followsProvider(1416).future);
    final other = await second.read(followsProvider(1417).future);

    expect(same.clubs.single.label, 'Club B');
    expect(same.athletes.single.entryIds, [3]);
    expect(other.clubs, isEmpty);
    expect(other.athletes, isEmpty);
  });

  test('une valeur illisible vaut aucun suivi, sans erreur', () async {
    for (final raw in ['pas du json', '[1,2]', '{"athletes":"x"}']) {
      final store = InMemoryLocalStore()..values['follows_1416'] = raw;
      final container = _container(store);

      final follows = await container.read(followsProvider(1416).future);

      expect(follows.athletes, isEmpty, reason: raw);
      expect(follows.clubs, isEmpty, reason: raw);
    }
  });

  test("un échec d'écriture garde le choix en mémoire", () async {
    final container = _container(_FailingWrites());
    await container.read(followsProvider(1416).future);

    await container
        .read(followsProvider(1416).notifier)
        .toggleClub(7, 'Club B');

    final state = container.read(followsProvider(1416));
    expect(state.hasError, isFalse);
    expect(state.value!.clubs.single.id, 7);
  });
}
