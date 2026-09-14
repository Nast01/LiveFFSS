import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:live_ffss/app/data/services/meeting_service.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';
import 'package:live_ffss/app/domain/models/race_format_detail.dart';
import 'package:live_ffss/app/domain/models/slot.dart';
import 'package:mocktail/mocktail.dart';

class _MockMeetingRepo extends Mock implements MeetingRepository {}

void main() {
  late _MockMeetingRepo repo;
  late MeetingService service;

  setUp(() {
    repo = _MockMeetingRepo();
    service = MeetingService(repo);
  });

  RaceFormatDetail partie(int id) => RaceFormatDetail(
        id: id,
        order: 1,
        label: '',
        fullLabel: '',
        levelLabel: '',
        level: 'heat',
        numberOfRun: 1,
        qualificationMethod: 'none',
        qualificationMethodLabel: '',
        spotsPerRace: 8,
        qualifyingSpots: 0,
      );

  Meeting meeting(int id, {List<Slot> slots = const []}) => Meeting(
        id: id,
        name: 'R$id',
        description: 'Plage',
        date: DateTime(2026, 9, 12),
        beginHour: DateTime(2026, 9, 12, 8),
        endHour: DateTime(2026, 9, 12, 8),
        slots: slots,
      );

  Slot slot(int id, {RaceFormatDetail? detail}) => Slot(
        id: id,
        name: 's$id',
        beginHour: DateTime(1970, 1, 1, 8),
        endHour: DateTime(1970, 1, 1, 8, 10),
        raceFormatDetail: detail,
      );

  test('load fills meetings and lowers the loading flag', () async {
    when(() => repo.getMeetings(42)).thenAnswer((_) async => [meeting(1)]);

    expect(await service.load(42), isTrue);

    expect(service.meetings.single.id, 1);
    expect(service.isLoading.value, isFalse);
    expect(service.hasError.value, isFalse);
  });

  test('a failure flips hasError and keeps the meetings already held',
      () async {
    when(() => repo.getMeetings(42)).thenAnswer((_) async => [meeting(1)]);
    await service.load(42);
    when(() => repo.getMeetings(42)).thenThrow(const ApiException('boom'));

    expect(await service.reload(), isFalse);

    // Une journée périmée mais réelle vaut mieux qu'une page blanche.
    expect(service.meetings.single.id, 1);
    expect(service.hasError.value, isTrue);
  });

  test('silent keeps isLoading down', () async {
    when(() => repo.getMeetings(42)).thenAnswer((_) async {
      expect(service.isLoading.value, isFalse);
      return [meeting(1)];
    });

    await service.load(42, silent: true);
  });

  test('reload before any load does nothing', () async {
    expect(await service.reload(), isFalse);
    verifyNever(() => repo.getMeetings(any()));
  });

  test('switching competition clears the previous meetings first', () async {
    when(() => repo.getMeetings(42)).thenAnswer((_) async => [meeting(1)]);
    await service.load(42);

    when(() => repo.getMeetings(43)).thenThrow(const ApiException('boom'));
    await service.load(43);

    // Sinon les réunions de la compétition 42 resteraient affichées sous la 43.
    expect(service.meetings, isEmpty);
  });

  test('byId finds a meeting, or nothing', () async {
    when(() => repo.getMeetings(42)).thenAnswer((_) async => [meeting(7)]);
    await service.load(42);

    expect(service.byId(7)?.id, 7);
    expect(service.byId(8), isNull);
  });

  test(
      'a load superseded by a newer competition is discarded, not '
      'merely overwritten', () async {
    final pendingFor42 = Completer<List<Meeting>>();
    when(() => repo.getMeetings(42)).thenAnswer((_) => pendingFor42.future);
    when(() => repo.getMeetings(43)).thenAnswer((_) async => [meeting(2)]);

    // load(42) suspends on the unresolved completer before load(43) starts —
    // the same shape as a controller torn down mid-request by a route change.
    final first = service.load(42);
    final second = service.load(43);

    expect(await second, isTrue);
    expect(service.meetings.single.id, 2);

    pendingFor42.complete([meeting(1)]);
    expect(await first, isFalse);

    // The stale response must not have clobbered competition 43's list.
    expect(service.meetings.single.id, 2);
    expect(service.isLoading.value, isFalse);
  });

  test(
      'a slow non-silent load still lowers isLoading after a silent '
      'refresh resolves first', () async {
    final firstCall = Completer<List<Meeting>>();
    final silentCall = Completer<List<Meeting>>();
    final calls = [firstCall, silentCall];
    var callIndex = 0;
    when(() => repo.getMeetings(42))
        .thenAnswer((_) => calls[callIndex++].future);

    final firstLoad = service.load(42);
    expect(service.isLoading.value, isTrue);

    final silentReload = service.reload(silent: true);

    silentCall.complete([meeting(1)]);
    expect(await silentReload, isTrue);
    // Le silencieux a fini, mais le premier appel — celui qui a levé le
    // drapeau — est toujours en vol.
    expect(service.isLoading.value, isTrue);

    firstCall.complete([meeting(1)]);
    expect(await firstLoad, isFalse);
    expect(service.isLoading.value, isFalse);
  });

  test('placedPartieIds spans every meeting and skips manual items', () async {
    when(() => repo.getMeetings(42)).thenAnswer((_) async => [
          meeting(1, slots: [slot(10, detail: partie(100)), slot(11)]),
          meeting(2, slots: [slot(12, detail: partie(200))]),
        ]);
    await service.load(42);

    expect(service.placedPartieIds, {100, 200});
  });

  test('competitionId remembers the loaded competition', () async {
    expect(service.competitionId, isNull);
    when(() => repo.getMeetings(42)).thenAnswer((_) async => []);

    await service.load(42);

    expect(service.competitionId, 42);
  });
}
