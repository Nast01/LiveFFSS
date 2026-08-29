import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/datasources/meeting_remote_datasource.dart';
import 'package:live_ffss/app/data/dtos/meeting_dto.dart';
import 'package:live_ffss/app/data/dtos/run_dto.dart';
import 'package:live_ffss/app/data/dtos/slot_dto.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
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
}
