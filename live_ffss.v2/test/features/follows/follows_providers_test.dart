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

class _FailingReads extends InMemoryLocalStore {
  @override
  Future<String?> read(String key) async =>
      throw const StorageException('illisible');
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

  test("unfollowAthlete retire par l'id, sans le participant", () async {
    final store = InMemoryLocalStore();
    final container = _container(store);
    await container.read(followsProvider(1416).future);
    final notifier = container.read(followsProvider(1416).notifier);
    await notifier.toggleAthlete(_participant);

    await notifier.unfollowAthlete(_participant.id);
    expect(container.read(followsProvider(1416)).value!.athletes, isEmpty);
    expect(store.values['follows_1416'], isNot(contains('Un ATHLETE')));

    // Déjà retiré : rien ne change.
    await notifier.unfollowAthlete(_participant.id);
    expect(container.read(followsProvider(1416)).value!.athletes, isEmpty);
  });

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

  test('une lecture en échec part de suivis vides, sans erreur', () async {
    final container = _container(_FailingReads());

    final follows = await container.read(followsProvider(1416).future);

    expect(follows.athletes, isEmpty);
    expect(follows.clubs, isEmpty);
  });

  test('une ligne illisible est écartée seule', () async {
    final store = InMemoryLocalStore()
      ..values['follows_1416'] =
          '{"athletes":[3,{"participantId":4,"name":"A","entryIds":[1]},'
          '{"participantId":"x","name":"B"}],'
          '"clubs":["z",{"id":7,"label":"Club B"}]}';
    final container = _container(store);

    final follows = await container.read(followsProvider(1416).future);

    expect(follows.athletes.map((a) => a.participantId), [4]);
    expect(follows.clubs.map((c) => c.id), [7]);
  });

  test('un retrait enregistré est relu par un autre conteneur', () async {
    final store = InMemoryLocalStore();
    final first = _container(store);
    await first.read(followsProvider(1416).future);
    final notifier = first.read(followsProvider(1416).notifier);
    await notifier.toggleClub(7, 'Club B');
    await notifier.toggleClub(7, 'Club B');

    final second = _container(store);
    final follows = await second.read(followsProvider(1416).future);

    expect(follows.clubs, isEmpty);
  });

  test('deux bascules de suite sont toutes deux gardées', () async {
    final store = InMemoryLocalStore();
    final container = _container(store);
    await container.read(followsProvider(1416).future);
    final notifier = container.read(followsProvider(1416).notifier);

    await Future.wait([
      notifier.toggleClub(7, 'Club B'),
      notifier.toggleAthlete(_participant),
    ]);

    final follows = container.read(followsProvider(1416)).value!;
    expect(follows.clubs.single.id, 7);
    expect(follows.athletes.single.participantId, 4);
    final second = _container(store);
    final reread = await second.read(followsProvider(1416).future);
    expect(reread.clubs.single.id, 7);
    expect(reread.athletes.single.participantId, 4);
  });
}
