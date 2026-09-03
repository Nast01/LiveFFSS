import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/datasources/meeting_remote_datasource.dart';
import 'package:live_ffss/app/data/dtos/meeting_dto.dart';
import 'package:live_ffss/app/data/dtos/run_dto.dart';
import 'package:live_ffss/app/data/dtos/slot_dto.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:live_ffss/app/domain/models/lane.dart';
import 'package:mocktail/mocktail.dart';

class _MockDataSource extends Mock implements MeetingRemoteDataSource {}

void main() {
  late _MockDataSource ds;
  late MeetingRepository repo;

  MeetingDto makeDto(int id) => MeetingDto(
        id: id,
        name: 'M$id',
        description: '',
        date: '2026-05-01',
        beginHour: '10:00',
        endHour: '12:00',
      );

  setUp(() {
    ds = _MockDataSource();
    repo = MeetingRepositoryImpl(ds);
  });

  test('getMeetings forwards id and maps to domain', () async {
    when(() => ds.getMeetings(any(),
            start: any(named: 'start'), length: any(named: 'length')))
        .thenAnswer((_) async => [makeDto(1), makeDto(2)]);
    final list = await repo.getMeetings(42);
    expect(list.length, 2);
    expect(list.first.id, 1);
    verify(() => ds.getMeetings(42, start: 0, length: 100)).called(1);
  });

  List<MeetingDto> page(int from, int count) =>
      [for (var i = 0; i < count; i++) makeDto(from + i)];

  // FFSS sert 30 lignes quand on ne demande pas de fenêtre : lire la première
  // page seulement ferait disparaître des journées entières de l'écran.
  test('pagine jusqu à une page courte', () async {
    when(() => ds.getMeetings(1451, start: 0, length: 100))
        .thenAnswer((_) async => page(1, 100));
    when(() => ds.getMeetings(1451, start: 100, length: 100))
        .thenAnswer((_) async => page(101, 5));

    final all = await repo.getMeetings(1451);

    expect(all, hasLength(105));
  });

  test('une page courte suffit, sans second appel', () async {
    when(() => ds.getMeetings(1451, start: 0, length: 100))
        .thenAnswer((_) async => page(1, 3));

    expect(await repo.getMeetings(1451), hasLength(3));
    verifyNever(() => ds.getMeetings(1451, start: 100, length: 100));
  });

  test('submitMeeting formats date/times and forwards', () async {
    when(() => ds.submitMeeting(
          competitionId: any(named: 'competitionId'),
          name: any(named: 'name'),
          description: any(named: 'description'),
          dayIso: any(named: 'dayIso'),
          beginTime: any(named: 'beginTime'),
          endTime: any(named: 'endTime'),
          id: any(named: 'id'),
        )).thenAnswer((_) async => 78);

    final id = await repo.submitMeeting(
      name: 'Test',
      description: 'Desc',
      date: DateTime(2026, 5, 1),
      beginHour: DateTime(2026, 5, 1, 10, 30),
      endHour: DateTime(2026, 5, 1, 11, 45),
      competitionId: 99,
    );

    expect(id, 78);
    verify(() => ds.submitMeeting(
          competitionId: 99,
          name: 'Test',
          description: 'Desc',
          dayIso: '2026-05-01',
          beginTime: '10:30',
          endTime: '11:45',
          id: null,
        )).called(1);
  });

  test('deleteMeeting forwards meetingId', () async {
    when(() => ds.deleteMeeting(any())).thenAnswer((_) async => true);
    final ok = await repo.deleteMeeting(7);
    expect(ok, true);
    verify(() => ds.deleteMeeting(7)).called(1);
  });

  RunDto makeRunDto(int slotId) => RunDto(
        id: slotId * 100,
        name: 'run-of-slot-$slotId',
        label: 'R$slotId',
        fullLabel: 'Run of slot $slotId',
        status: 0,
        statusLabel: '',
        site: '',
        beginTime: '08:00',
        endTime: '08:05',
      );

  test('the courses of each créneau go out together, not one after another',
      () async {
    // Twenty créneaux must not cost twenty latencies end to end.
    final gates = {
      for (final id in [1, 2, 3]) id: Completer<List<RunDto>>()
    };
    when(() => ds.getMeetings(1451, start: 0, length: 100)).thenAnswer(
      (_) async => [
        makeDto(78).copyWith(slots: [
          for (final id in [1, 2, 3])
            SlotDto(id: id, name: 'C$id', beginHour: '08:00', endHour: '08:10'),
        ]),
      ],
    );
    for (final id in gates.keys) {
      when(() => ds.getRuns(id, start: 0, length: 100))
          .thenAnswer((_) => gates[id]!.future);
    }

    final loading = repo.getMeetings(1451);
    await Future<void>.delayed(Duration.zero);

    verify(() => ds.getRuns(1, start: 0, length: 100)).called(1);
    verify(() => ds.getRuns(2, start: 0, length: 100)).called(1);
    verify(() => ds.getRuns(3, start: 0, length: 100)).called(1);

    // Each gate resolves with a run that names its own slot id, so a
    // scrambled zip between slotIds and Future.wait's output — e.g. a
    // reversed order, or an off-by-one index — would attach the wrong
    // course to the wrong créneau and fail this assertion.
    for (final id in gates.keys) {
      gates[id]!.complete([makeRunDto(id)]);
    }
    final meetings = await loading;

    final slots = meetings.single.slots;
    for (final id in [1, 2, 3]) {
      final slot = slots.firstWhere((s) => s.id == id);
      expect(slot.runs, hasLength(1));
      expect(slot.runs.single.name, 'run-of-slot-$id');
    }
  });

  // Une compétition de trois jours peut porter plus de cent créneaux : les
  // lâcher tous d'un coup ouvre autant de sockets. Le lot suivant ne part
  // qu'une fois le précédent rendu.
  test('les créneaux partent par lots, pas tous d un coup', () async {
    final ids = [for (var i = 1; i <= 12; i++) i];
    final gates = {for (final id in ids) id: Completer<List<RunDto>>()};
    when(() => ds.getMeetings(1451, start: 0, length: 100)).thenAnswer(
      (_) async => [
        makeDto(78).copyWith(slots: [
          for (final id in ids)
            SlotDto(id: id, name: 'C$id', beginHour: '08:00', endHour: '08:10'),
        ]),
      ],
    );
    for (final id in ids) {
      when(() => ds.getRuns(id, start: 0, length: 100))
          .thenAnswer((_) => gates[id]!.future);
    }

    final loading = repo.getMeetings(1451);
    await Future<void>.delayed(Duration.zero);

    for (final id in ids.take(8)) {
      verify(() => ds.getRuns(id, start: 0, length: 100)).called(1);
    }
    for (final id in ids.skip(8)) {
      verifyNever(() => ds.getRuns(id, start: 0, length: 100));
    }

    for (final id in ids.take(8)) {
      gates[id]!.complete([makeRunDto(id)]);
    }
    await Future<void>.delayed(Duration.zero);
    for (final id in ids.skip(8)) {
      verify(() => ds.getRuns(id, start: 0, length: 100)).called(1);
      gates[id]!.complete([makeRunDto(id)]);
    }

    final slots = (await loading).single.slots;
    for (final id in ids) {
      expect(slots.firstWhere((s) => s.id == id).runs.single.name,
          'run-of-slot-$id');
    }
  });

  test('a créneau s courses page past a full first batch', () async {
    when(() => ds.getMeetings(1451, start: 0, length: 100)).thenAnswer(
      (_) async => [
        makeDto(78).copyWith(slots: [
          const SlotDto(
              id: 9, name: 'C9', beginHour: '08:00', endHour: '08:10'),
        ]),
      ],
    );
    when(() => ds.getRuns(9, start: 0, length: 100)).thenAnswer(
      (_) async => [for (var i = 0; i < 100; i++) makeRunDto(9)],
    );
    when(() => ds.getRuns(9, start: 100, length: 100))
        .thenAnswer((_) async => [makeRunDto(9)]);

    final meetings = await repo.getMeetings(1451);

    expect(meetings.single.slots.single.runs, hasLength(101));
    verify(() => ds.getRuns(9, start: 0, length: 100)).called(1);
    verify(() => ds.getRuns(9, start: 100, length: 100)).called(1);
  });

  // La route « courses d'un créneau » est cassée côté FFSS : elle répond
  // success:false quel que soit le créneau. Laisser remonter l'erreur vide
  // l'onglet Programme entier, alors que la réunion transporte déjà ses
  // courses. Un créneau illisible ne doit coûter que ses propres courses.
  test('un créneau dont les courses sont illisibles garde celles de la réunion',
      () async {
    when(() => ds.getMeetings(1451, start: 0, length: 100))
        .thenAnswer((_) async => [
              makeDto(1).copyWith(slots: [
                SlotDto(
                  id: 9,
                  name: 'C9',
                  beginHour: '08:00',
                  endHour: '08:10',
                  runs: [makeRunDto(9)],
                ),
              ]),
            ]);
    when(() => ds.getRuns(9, start: 0, length: 100))
        .thenThrow(const ApiException('filterByCreneau() only accepts...'));

    final meetings = await repo.getMeetings(1451);

    expect(meetings.single.slots.single.runs.single.name, 'run-of-slot-9');
  });

  test('l échec d un créneau n emporte pas les courses de ses voisins',
      () async {
    when(() => ds.getMeetings(1451, start: 0, length: 100))
        .thenAnswer((_) async => [
              makeDto(1).copyWith(slots: [
                const SlotDto(
                    id: 1, name: 'C1', beginHour: '08:00', endHour: '08:10'),
                const SlotDto(
                    id: 2, name: 'C2', beginHour: '08:10', endHour: '08:20'),
              ]),
            ]);
    when(() => ds.getRuns(1, start: 0, length: 100))
        .thenThrow(const ApiException('cassé'));
    when(() => ds.getRuns(2, start: 0, length: 100))
        .thenAnswer((_) async => [makeRunDto(2)]);

    final slots = (await repo.getMeetings(1451)).single.slots;

    expect(slots.firstWhere((s) => s.id == 1).runs, isEmpty);
    expect(
        slots.firstWhere((s) => s.id == 2).runs.single.name, 'run-of-slot-2');
  });

  group('createDefaultLanes', () {
    setUp(() {
      when(() => ds.submitLane(
          runId: any(named: 'runId'),
          number: any(named: 'number'),
          id: any(named: 'id'))).thenAnswer((_) async => 1);
    });

    // Une course s'ouvre avec autant d'emplacements que son tour en déclare
    // (`RaceFormatDetail.spotsPerRace`), numérotés à partir de 1 : c'est le
    // dossard que l'opérateur lit sur la ligne de départ.
    test('crée autant de places que le tour en déclare, numérotées dès 1',
        () async {
      final created = await repo.createDefaultLanes(runId: 20, count: 3);

      expect(created, 3);
      final numbers = verify(() => ds.submitLane(
          runId: 20,
          number: captureAny(named: 'number'),
          id: any(named: 'id'))).captured;
      expect(numbers, [1, 2, 3]);
    });

    test('un tour sans place déclarée n appelle pas le serveur', () async {
      expect(await repo.createDefaultLanes(runId: 20, count: 0), 0);

      verifyNever(() => ds.submitLane(
          runId: any(named: 'runId'),
          number: any(named: 'number'),
          id: any(named: 'id')));
    });

    // Un refus isolé ne doit pas laisser la course à moitié équipée sans
    // qu'on le sache : les suivantes partent, et le compte rendu est exact.
    test('une place refusée n empêche pas les suivantes', () async {
      when(() => ds.submitLane(runId: 20, number: 2, id: any(named: 'id')))
          .thenAnswer((_) async => 0);

      expect(await repo.createDefaultLanes(runId: 20, count: 3), 2);
    });
  });

  test('deleteLane forwards the lane id', () async {
    when(() => ds.deleteLane(any())).thenAnswer((_) async => true);

    expect(await repo.deleteLane(6), isTrue);
    verify(() => ds.deleteLane(6)).called(1);
  });

  test('submitRun forwards every field and returns the assigned id', () async {
    when(() => ds.submitRun(
          slotId: any(named: 'slotId'),
          name: any(named: 'name'),
          beginTime: any(named: 'beginTime'),
          endTime: any(named: 'endTime'),
          site: any(named: 'site'),
          id: any(named: 'id'),
        )).thenAnswer((_) async => 24);

    final id = await repo.submitRun(
      slotId: 75,
      name: 'Demie 1',
      beginHour: DateTime(2026, 6, 13, 8),
      endHour: DateTime(2026, 6, 13, 8, 10),
      site: 'OCEAN 1',
    );

    expect(id, 24);
    verify(() => ds.submitRun(
          slotId: 75,
          name: 'Demie 1',
          beginTime: '08:00',
          endTime: '08:10',
          site: 'OCEAN 1',
          id: null,
        )).called(1);
  });

  test('deleteRun forwards the run id', () async {
    when(() => ds.deleteRun(any())).thenAnswer((_) async => true);

    expect(await repo.deleteRun(24), isTrue);
    verify(() => ds.deleteRun(24)).called(1);
  });

  group('syncLanes', () {
    Lane lane(int id, int number) => Lane(id: id, number: number);

    setUp(() {
      when(() => ds.submitLane(
            runId: any(named: 'runId'),
            number: any(named: 'number'),
            entryId: any(named: 'entryId'),
            id: any(named: 'id'),
          )).thenAnswer((_) async => 1);
      when(() => ds.deleteLane(any())).thenAnswer((_) async => true);
    });

    // Le tour a déjà ouvert la course avec ses places par défaut : les
    // réécrire plutôt qu'en créer d'autres, sinon la course cumule les vides
    // et les affectées.
    test('réutilise les places existantes avant d en créer', () async {
      final synced = await repo.syncLanes(
        runId: 24,
        entryIds: const [101, 102, 103],
        existing: [lane(7, 1), lane(8, 2)],
      );

      expect(synced, 3);
      verify(() => ds.submitLane(runId: 24, number: 1, entryId: 101, id: 7))
          .called(1);
      verify(() => ds.submitLane(runId: 24, number: 2, entryId: 102, id: 8))
          .called(1);
      verify(() =>
              ds.submitLane(runId: 24, number: 3, entryId: 103, id: null))
          .called(1);
      verifyNever(() => ds.deleteLane(any()));
    });

    // Huit places par défaut pour trois partants laisseraient cinq couloirs
    // fantômes sur la feuille de résultats.
    test('supprime les places en trop', () async {
      await repo.syncLanes(
        runId: 24,
        entryIds: const [101],
        existing: [lane(7, 1), lane(8, 2), lane(9, 3)],
      );

      verify(() => ds.submitLane(runId: 24, number: 1, entryId: 101, id: 7))
          .called(1);
      verify(() => ds.deleteLane(8)).called(1);
      verify(() => ds.deleteLane(9)).called(1);
    });

    // FFSS ne garantit aucun ordre : reprendre les places par numéro évite
    // que la place 2 devienne la 1 au gré du payload.
    test('reprend les places par numéro croissant', () async {
      await repo.syncLanes(
        runId: 24,
        entryIds: const [101, 102],
        existing: [lane(9, 2), lane(7, 1)],
      );

      verify(() => ds.submitLane(runId: 24, number: 1, entryId: 101, id: 7))
          .called(1);
      verify(() => ds.submitLane(runId: 24, number: 2, entryId: 102, id: 9))
          .called(1);
    });

    test('un refus n arrête pas les suivantes et le compte est honnête',
        () async {
      when(() => ds.submitLane(
            runId: 24,
            number: 2,
            entryId: any(named: 'entryId'),
            id: any(named: 'id'),
          )).thenAnswer((_) async => 0);

      final synced = await repo.syncLanes(
        runId: 24,
        entryIds: const [101, 102, 103],
        existing: const [],
      );

      expect(synced, 2);
    });
  });
}
