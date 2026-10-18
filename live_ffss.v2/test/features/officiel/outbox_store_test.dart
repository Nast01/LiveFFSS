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
    reason: 'validé par le juge des résultats',
  );

  test('rien d\'enregistré : file vide', () async {
    expect(await store.load(), isEmpty);
  });

  test('ce qui est enregistré se relit à l\'identique', () async {
    await store.save([pending, rejected]);
    expect(await store.load(), [pending, rejected]);
  });

  test('une valeur illisible vaut une file vide', () async {
    local.values[OutboxStore.storageKey] = '{pas du json';
    expect(await store.load(), isEmpty);
  });

  test('une ligne mal typée est écartée seule', () async {
    await store.save([pending]);
    final rows = jsonDecode(local.values[OutboxStore.storageKey]!) as List;
    local.values[OutboxStore.storageKey] = jsonEncode([
      {'id': 3},
      'texte',
      {...(rows.single as Map<String, dynamic>), 'state': 'inconnu'},
      ...rows,
    ]);
    expect(await store.load(), [pending]);
  });
}
