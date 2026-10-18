import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/domain/account.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/features/auth/session.dart';
import 'package:live_ffss_v2/features/follows/follows_providers.dart';
import 'package:live_ffss_v2/features/follows/reminder_records.dart';

import '../../support/in_memory_local_store.dart';

const _competitionId = 1416;
const _account = Account(label: 'ATHLETE Compte', type: 'licencie');

/// Une session déjà ouverte, sans réseau.
class _Session extends SessionNotifier {
  _Session(this.account);

  final Account? account;

  @override
  Future<Account?> build() async => account;
}

/// La lecture de [gatedKey] rend, après [gate], la valeur qu'elle a trouvée
/// en partant : une lecture lente du stockage, pendant laquelle `build` est
/// encore en cours.
class _GatedStore extends InMemoryLocalStore {
  _GatedStore(this.gatedKey);

  final String gatedKey;
  final gate = Completer<void>();

  @override
  Future<String?> read(String key) async {
    final value = values[key];
    if (key == gatedKey) await gate.future;
    return value;
  }
}

Participant _participant(int id, List<int> entryIds) => Participant(
  id: id,
  firstName: 'Un',
  lastName: 'ATHLETE',
  club: 'Club A',
  entries: [
    for (final entryId in entryIds)
      ParticipantEntry(entryId: entryId, eventId: 36073, categoryName: 'Open'),
  ],
);

String _selfRecord(String account, Participant participant) => jsonEncode({
  'account': account,
  'athlete': {
    'participantId': participant.id,
    'name': 'Un ATHLETE',
    'club': participant.club,
    'entryIds': [for (final e in participant.entries) e.entryId],
    'eventIds': [for (final e in participant.entries) e.eventId],
  },
});

ProviderContainer _container(InMemoryLocalStore store, {Account? account}) {
  final container = ProviderContainer(
    overrides: [
      localStoreProvider.overrideWithValue(store),
      sessionProvider.overrideWith(() => _Session(account)),
    ],
    retry: noRetry,
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('selfAthleteProvider', () {
    test('enregistré pendant sa première lecture : gardé, pas écrasé par '
        'la valeur lue avant', () async {
      final store = _GatedStore('reminder_self_$_competitionId');
      final old = _participant(1, [10]);
      final saved = _participant(2, [20]);
      store.values['reminder_self_$_competitionId'] = _selfRecord(
        _account.label,
        old,
      );
      final c = _container(store, account: _account);
      c.listen(selfAthleteProvider(_competitionId), (_, _) {});
      // La lecture est partie avec l'ancien athlète.
      await pumpEventQueue();

      final saving = c
          .read(selfAthleteProvider(_competitionId).notifier)
          .save(_account.label, saved);
      await pumpEventQueue();
      store.gate.complete();
      await saving;
      await pumpEventQueue();

      final athlete = await c.read(selfAthleteProvider(_competitionId).future);
      expect(athlete?.participantId, 2);
      expect(
        store.values['reminder_self_$_competitionId'],
        contains('"participantId":2'),
      );
    });
  });

  group('knownHeatsProvider', () {
    const key = 'known_heats_$_competitionId';

    Future<void> follow(ProviderContainer c, Participant participant) async {
      await c.read(followsProvider(_competitionId).future);
      await c
          .read(followsProvider(_competitionId).notifier)
          .toggleAthlete(participant);
    }

    test('plusieurs séries apprises pendant la première lecture : toutes '
        'gardées', () async {
      final store = _GatedStore(key);
      final c = _container(store);
      await follow(c, _participant(1, [1, 2, 3]));
      c.listen(knownHeatsProvider(_competitionId), (_, _) {});
      final known = c.read(knownHeatsProvider(_competitionId).notifier);

      final recording = [
        for (final entryId in [1, 2, 3])
          known.record([
            (entryId: entryId, eventId: 36073, heatId: 470 + entryId),
          ]),
      ];
      await pumpEventQueue();
      store.gate.complete();
      await Future.wait(recording);
      await pumpEventQueue();

      const expected = {
        (entryId: 1, eventId: 36073): 471,
        (entryId: 2, eventId: 36073): 472,
        (entryId: 3, eventId: 36073): 473,
      };
      expect(await c.read(knownHeatsProvider(_competitionId).future), expected);
      // Relues par un autre lancement : la dernière écriture a tout.
      final relaunched = _container(
        InMemoryLocalStore()..values.addAll(store.values),
      );
      expect(
        await relaunched.read(knownHeatsProvider(_competitionId).future),
        expected,
      );
    });

    test("ni suivi ni athlète connecté : rien d'écrit", () async {
      final store = InMemoryLocalStore();
      final c = _container(store, account: _account);
      await follow(c, _participant(1, [1]));

      await c.read(knownHeatsProvider(_competitionId).notifier).record([
        (entryId: 9, eventId: 36073, heatId: 479),
      ]);

      expect(await c.read(knownHeatsProvider(_competitionId).future), isEmpty);
      expect(store.values.containsKey(key), isFalse);
    });

    test("suivi et athlète connecté : les leurs seulement", () async {
      final store = InMemoryLocalStore();
      final self = _participant(2, [20]);
      store.values['reminder_self_$_competitionId'] = _selfRecord(
        _account.label,
        self,
      );
      final c = _container(store, account: _account);
      await follow(c, _participant(1, [10]));

      await c.read(knownHeatsProvider(_competitionId).notifier).record([
        (entryId: 10, eventId: 36073, heatId: 479),
        (entryId: 20, eventId: 36073, heatId: 480),
        (entryId: 30, eventId: 36073, heatId: 481),
      ]);

      expect(await c.read(knownHeatsProvider(_competitionId).future), {
        (entryId: 10, eventId: 36073): 479,
        (entryId: 20, eventId: 36073): 480,
      });
    });
  });
}
