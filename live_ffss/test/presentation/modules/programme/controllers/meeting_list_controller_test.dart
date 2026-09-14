import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/auth_repository.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:live_ffss/app/data/services/meeting_service.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/domain/models/user.dart';
import 'package:live_ffss/app/module/programme/controllers/meeting_list_controller.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';
import 'package:mocktail/mocktail.dart';

class _MockStorage extends Mock implements FlutterSecureStorage {}

class _MockMeetingRepo extends Mock implements MeetingRepository {}

class _MockAuthRepo extends Mock implements AuthRepository {}

void main() {
  late _MockStorage storage;
  late ProgrammeService programme;
  late _MockMeetingRepo meetingRepo;
  late MeetingService meetings;
  late UserService userService;
  late MeetingListController controller;

  setUpAll(() => registerFallbackValue(''));

  /// Any non-null user is a session as far as this screen is concerned.
  final loggedInUser = User(
    token: 'tok',
    tokenExpiration: DateTime(2030),
    label: 'FFSS',
    type: UserType.organisme,
    role: UserRole.admin,
  );

  const baseCompetition = Competition(
    id: 42,
    name: 'Championnat',
    statusCode: 0,
    statusLabel: '',
    speciality: 1,
    specialityLabel: '',
    typeWater: '',
    typePool: '',
    typeChrono: '',
    isEligibleToNationalRecord: false,
    numberOfLanes: 8,
    organizer: '',
    hasBegun: false,
    hasResult: false,
    hasPassed: false,
    level: 0,
    levelLabel: '',
    organizerClub: Club(id: 1, name: 'Club'),
  );

  final comp = baseCompetition.copyWith(
    beginDate: DateTime(2026, 9, 12),
    endDate: DateTime(2026, 9, 13),
  );

  Meeting meeting(int id, DateTime date, {String description = 'Plage'}) =>
      Meeting(
        id: id,
        name: 'R$id',
        description: description,
        date: date,
        beginHour: DateTime(date.year, date.month, date.day, 8),
        endHour: DateTime(date.year, date.month, date.day, 11),
      );

  setUp(() async {
    storage = _MockStorage();
    when(() => storage.read(key: any(named: 'key')))
        .thenAnswer((_) async => null);
    when(() =>
            storage.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((_) async {});
    programme = ProgrammeService(storage);
    meetingRepo = _MockMeetingRepo();
    meetings = MeetingService(meetingRepo);
    userService = UserService(_MockAuthRepo());
    userService.currentUser.value = loggedInUser;
    controller =
        MeetingListController(meetings, meetingRepo, programme, userService);
  });

  test('setCompetition derives the competition days', () async {
    when(() => meetingRepo.getMeetings(42)).thenAnswer((_) async => []);

    await controller.setCompetition(comp);

    expect(controller.days.length, 2);
    expect(controller.days.first, DateTime(2026, 9, 12));
  });

  test('meetingsOn returns every meeting of that day, earliest first',
      () async {
    when(() => meetingRepo.getMeetings(42)).thenAnswer((_) async => [
          meeting(2, DateTime(2026, 9, 12))
              .copyWith(beginHour: DateTime(2026, 9, 12, 14)),
          meeting(1, DateTime(2026, 9, 12)),
          meeting(3, DateTime(2026, 9, 13)),
        ]);
    await controller.setCompetition(comp);

    final saturday = controller.meetingsOn(DateTime(2026, 9, 12));

    expect(saturday.map((m) => m.id), [1, 2]);
  });

  test('a day with no meeting returns an empty list', () async {
    when(() => meetingRepo.getMeetings(42))
        .thenAnswer((_) async => [meeting(1, DateTime(2026, 9, 12))]);
    await controller.setCompetition(comp);

    expect(controller.meetingsOn(DateTime(2026, 9, 13)), isEmpty);
  });

  test('unscheduledRoundCount ignores rounds with no serverId', () async {
    // Un tour sans serverId ne peut porter aucun créneau côté FFSS :
    // l'annoncer ne vaudrait à l'opérateur qu'un refus qu'il ne peut pas
    // corriger depuis cet écran.
    await programme.save(const CompetitionProgramme(
      competitionId: 42,
      structures: [
        EventStructure(
          raceId: 1,
          categoryId: 2,
          raceLabel: 'Surfski',
          categoryLabel: 'Junior',
          levels: [
            RoundLevel(type: RoundType.serie, serverId: 100),
            RoundLevel(type: RoundType.finale, serverId: 0),
          ],
        ),
      ],
    ));
    when(() => meetingRepo.getMeetings(42)).thenAnswer((_) async => []);
    await controller.setCompetition(comp);

    expect(controller.unscheduledRoundCount, 1);
  });

  test('deleteMeeting reloads the tree on success', () async {
    when(() => meetingRepo.getMeetings(42))
        .thenAnswer((_) async => [meeting(1, DateTime(2026, 9, 12))]);
    await controller.setCompetition(comp);
    when(() => meetingRepo.deleteMeeting(1)).thenAnswer((_) async => true);
    when(() => meetingRepo.getMeetings(42)).thenAnswer((_) async => []);

    await controller.deleteMeeting(1);

    expect(meetings.meetings, isEmpty);
    expect(controller.isDeleting.value, isFalse);
  });

  test('deleteMeeting reports a refusal and leaves the tree alone', () async {
    when(() => meetingRepo.getMeetings(42))
        .thenAnswer((_) async => [meeting(1, DateTime(2026, 9, 12))]);
    await controller.setCompetition(comp);
    when(() => meetingRepo.deleteMeeting(1)).thenAnswer((_) async => false);

    await controller.deleteMeeting(1);

    expect(controller.message.value, isA<UiMessageError>());
    expect(meetings.meetings.single.id, 1);
  });

  test('deleteMeeting reports an AppException with its detail', () async {
    when(() => meetingRepo.getMeetings(42)).thenAnswer((_) async => []);
    await controller.setCompetition(comp);
    when(() => meetingRepo.deleteMeeting(1))
        .thenThrow(const ApiException('Invalid token'));

    await controller.deleteMeeting(1);

    expect(controller.message.value, isA<UiMessageError>());
    expect((controller.message.value! as UiMessageError).details,
        contains('Invalid token'));
  });

  test('a signed-out operator is refused before anything leaves the device',
      () async {
    // FFSS répondrait à une écriture anonyme par un « Invalid Token » nu qui
    // se lit comme une panne serveur.
    userService.currentUser.value = null;

    await controller.deleteMeeting(1);

    expect(controller.message.value, isA<UiMessageError>());
    verifyNever(() => meetingRepo.deleteMeeting(any()));
  });
}
