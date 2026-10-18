import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/domain/outbox.dart';
import 'package:live_ffss_v2/domain/race_result.dart';
import 'package:live_ffss_v2/features/officiel/outbox_store.dart';

import '../../support/in_memory_local_store.dart';

void main() {
  late InMemoryLocalStore local;
  late OutboxStore store;

  setUp(() {
    local = InMemoryLocalStore();
    store = OutboxStore(local);
  });

  const pending = OutboxOperation(
    id: 'a',
    account: 'DUPONT Jean',
    competitionId: 1416,
    placeId: 11,
    seriesId: 5,
    entryId: 7,
    change: ResultChange(
      chronos: [100, null, 300],
      mark: ResultMark.disqualified,
      code: '12',
    ),
    attempts: 2,
  );
  const rejected = OutboxOperation(
    id: 'b',
    account: 'MARTIN Paul',
    competitionId: 1416,
    placeId: 12,
    resultId: 99,
    seriesId: 5,
    entryId: 8,
    change: ResultChange(mark: ResultMark.forfeit),
    state: OutboxState.rejected,
    rejection: OutboxRejection.server,
    reason: 'engagement inconnu',
    faults: 1,
  );
  final sent = OutboxOperation(
    id: 'c',
    account: 'DUPONT Jean',
    competitionId: 1416,
    placeId: 13,
    resultId: 100,
    seriesId: 5,
    entryId: 9,
    change: const ResultChange(chronos: [1]),
    state: OutboxState.sent,
    sentAt: DateTime.utc(2026, 10, 18, 9, 30),
  );

  Future<List<OutboxOperation>> operations() async =>
      (await store.load() as OutboxLoaded).operations;

  test('rien d\'enregistré : file vide', () async {
    expect(await operations(), isEmpty);
  });

  test('ce qui est enregistré se relit à l\'identique', () async {
    await store.save([pending, rejected, sent]);
    expect(await operations(), [pending, rejected, sent]);
  });

  test('une valeur illisible est signalée telle quelle', () async {
    local.values[OutboxStore.storageKey] = '{pas du json';
    expect(
      await store.load(),
      isA<OutboxUnreadable>().having((u) => u.raw, 'raw', '{pas du json'),
    );
    local.values[OutboxStore.storageKey] = '{"a": 1}';
    expect(await store.load(), isA<OutboxUnreadable>());
  });

  test('une copie de côté garde la valeur sous sa propre clé', () async {
    final at = DateTime.utc(2026, 10, 18);
    await store.backup('{pas du json', at);
    expect(
      local
          .values['${OutboxStore.backupKeyPrefix}${at.millisecondsSinceEpoch}'],
      '{pas du json',
    );
  });

  test('seules les 3 copies de côté les plus récentes sont gardées', () async {
    final start = DateTime.utc(2026, 10, 18);
    String key(int i) =>
        '${OutboxStore.backupKeyPrefix}'
        '${start.add(Duration(minutes: i)).millisecondsSinceEpoch}';
    for (var i = 0; i < 5; i++) {
      await store.backup('copie $i', start.add(Duration(minutes: i)));
    }
    final backups = Map.fromEntries(
      local.values.entries.where(
        (e) => e.key.startsWith(OutboxStore.backupKeyPrefix),
      ),
    );
    expect(backups, {key(2): 'copie 2', key(3): 'copie 3', key(4): 'copie 4'});
    expect(local.values.containsKey(OutboxStore.storageKey), isFalse);
  });

  test('une ligne illisible est gardée telle quelle et réécrite', () async {
    await store.save([pending]);
    final rows = jsonDecode(local.values[OutboxStore.storageKey]!) as List;
    final unknown = <Object?>[
      {'id': 3},
      'texte',
      {...(rows.single as Map<String, dynamic>), 'state': 'inconnu'},
      {...(rows.single as Map<String, dynamic>), 'rejection': 'inconnu'},
    ];
    local.values[OutboxStore.storageKey] = jsonEncode([...unknown, ...rows]);

    final loaded = await store.load() as OutboxLoaded;
    expect(loaded.operations, [pending]);
    expect(loaded.unknown, unknown);

    await store.save(loaded.operations, unknown: loaded.unknown);
    final again = await store.load() as OutboxLoaded;
    expect(again.operations, [pending]);
    expect(again.unknown, unknown);
  });
}
