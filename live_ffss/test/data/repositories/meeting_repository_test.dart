import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/datasources/meeting_remote_datasource.dart';
import 'package:live_ffss/app/data/dtos/meeting_dto.dart';
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

  test('createMeeting formats date/times and forwards', () async {
    when(() => ds.createMeeting(
          name: any(named: 'name'),
          description: any(named: 'description'),
          dayIso: any(named: 'dayIso'),
          beginTime: any(named: 'beginTime'),
          endTime: any(named: 'endTime'),
          competitionId: any(named: 'competitionId'),
        )).thenAnswer((_) async => true);

    final ok = await repo.createMeeting(
      name: 'Test',
      description: 'Desc',
      date: DateTime(2026, 5, 1),
      beginHour: DateTime(2026, 5, 1, 10, 30),
      endHour: DateTime(2026, 5, 1, 11, 45),
      competitionId: 99,
    );

    expect(ok, true);
    verify(() => ds.createMeeting(
          name: 'Test',
          description: 'Desc',
          dayIso: '2026-05-01',
          beginTime: '10:30',
          endTime: '11:45',
          competitionId: 99,
        )).called(1);
  });

  test('deleteMeeting forwards meetingId', () async {
    when(() => ds.deleteMeeting(any())).thenAnswer((_) async => true);
    final ok = await repo.deleteMeeting(7);
    expect(ok, true);
    verify(() => ds.deleteMeeting(7)).called(1);
  });
}
