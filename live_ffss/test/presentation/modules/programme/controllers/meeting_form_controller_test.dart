import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:live_ffss/app/data/repositories/auth_repository.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:live_ffss/app/data/services/meeting_service.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';
import 'package:live_ffss/app/domain/models/run.dart';
import 'package:live_ffss/app/domain/models/slot.dart';
import 'package:live_ffss/app/domain/models/user.dart';
import 'package:live_ffss/app/module/programme/controllers/meeting_form_controller.dart';
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
  late MeetingFormController controller;

  setUpAll(() {
    registerFallbackValue('');
    registerFallbackValue(DateTime(2026));
  });

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

  /// A réunion already on FFSS, one créneau 08:00→08:10 carrying one course
  /// 08:00→08:10 — both parsed from a bare `HH:mm`, per the mapper, and
  /// landing on 1970-01-01, unlike the réunion's own date/beginHour/endHour.
  Meeting meetingWithItems() => Meeting(
        id: 1,
        name: 'R1',
        description: 'Plage',
        date: DateTime(2026, 9, 12),
        beginHour: DateTime(2026, 9, 12, 8),
        endHour: DateTime(2026, 9, 12, 8, 10),
        slots: [
          Slot(
            id: 10,
            name: 'Créneau',
            beginHour: DateFormat('HH:mm').parse('08:00'),
            endHour: DateFormat('HH:mm').parse('08:10'),
            runs: [
              Run(
                id: 11,
                name: 'Course',
                label: '',
                fullLabel: '',
                status: RunStatus.waiting,
                statusLabel: '',
                site: 'Plage',
                beginTime: DateFormat('HH:mm').parse('08:00'),
                endTime: DateFormat('HH:mm').parse('08:10'),
              ),
            ],
          ),
        ],
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
        MeetingFormController(meetings, meetingRepo, programme, userService);
  });

  const defaultStart = 8 * 60;

  test('a fresh form starts on the first competition day at 08:00', () {
    controller.applyArguments({'competition': comp, 'meeting': null});

    expect(controller.isEditing, isFalse);
    expect(controller.date.value, DateTime(2026, 9, 12));
    expect(controller.startMinutes.value, defaultStart);
    expect(controller.site.value, isNull);
  });

  test('editing seeds every field from the meeting, site included', () {
    final existing = meeting(1, DateTime(2026, 9, 13), description: 'Bassin')
        .copyWith(beginHour: DateTime(2026, 9, 13, 14, 30));

    controller.applyArguments({'competition': comp, 'meeting': existing});

    expect(controller.isEditing, isTrue);
    expect(controller.date.value, DateTime(2026, 9, 13));
    expect(controller.startMinutes.value, 14 * 60 + 30);
    expect(controller.site.value, 'Bassin');
  });

  test('creating sends the site as the description and ends at its start',
      () async {
    // Une réunion sans item ne « dure » pas : sa fin est son début.
    controller.applyArguments({'competition': comp, 'meeting': null});
    controller.site.value = 'Plage';
    when(() => meetingRepo.submitMeeting(
          competitionId: any(named: 'competitionId'),
          name: any(named: 'name'),
          description: any(named: 'description'),
          date: any(named: 'date'),
          beginHour: any(named: 'beginHour'),
          endHour: any(named: 'endHour'),
          id: any(named: 'id'),
        )).thenAnswer((_) async => 7);
    when(() => meetingRepo.getMeetings(42)).thenAnswer((_) async => []);

    expect(await controller.save('Matin — Plage'), isTrue);

    final captured = verify(() => meetingRepo.submitMeeting(
          competitionId: 42,
          name: 'Matin — Plage',
          description: captureAny(named: 'description'),
          date: DateTime(2026, 9, 12),
          beginHour: captureAny(named: 'beginHour'),
          endHour: captureAny(named: 'endHour'),
          id: null,
        )).captured;
    expect(captured[0], 'Plage');
    expect(captured[1], DateTime(2026, 9, 12, 8));
    expect(captured[2], DateTime(2026, 9, 12, 8));
  });

  test('an empty title is refused without a single call', () async {
    controller.applyArguments({'competition': comp, 'meeting': null});
    controller.site.value = 'Plage';

    expect(await controller.save('   '), isFalse);

    expect(controller.message.value, isA<UiMessageError>());
    verifyNever(() => meetingRepo.submitMeeting(
        competitionId: any(named: 'competitionId'),
        name: any(named: 'name'),
        description: any(named: 'description'),
        date: any(named: 'date'),
        beginHour: any(named: 'beginHour'),
        endHour: any(named: 'endHour'),
        id: any(named: 'id')));
  });

  test('no site is refused — every course of the réunion inherits it',
      () async {
    controller.applyArguments({'competition': comp, 'meeting': null});

    expect(await controller.save('Matin'), isFalse);
    expect(controller.message.value, isA<UiMessageError>());
  });

  test('a signed-out operator is refused before anything leaves the device',
      () async {
    userService.currentUser.value = null;
    controller.applyArguments({'competition': comp, 'meeting': null});
    controller.site.value = 'Plage';

    expect(await controller.save('Matin'), isFalse);
    expect(controller.message.value, isA<UiMessageError>());
  });

  test('a refusal from FFSS is reported and the form stays open', () async {
    controller.applyArguments({'competition': comp, 'meeting': null});
    controller.site.value = 'Plage';
    when(() => meetingRepo.submitMeeting(
          competitionId: any(named: 'competitionId'),
          name: any(named: 'name'),
          description: any(named: 'description'),
          date: any(named: 'date'),
          beginHour: any(named: 'beginHour'),
          endHour: any(named: 'endHour'),
          id: any(named: 'id'),
        )).thenAnswer((_) async => 0);

    expect(await controller.save('Matin'), isFalse);

    expect(controller.message.value, isA<UiMessageError>());
    expect(controller.isSaving.value, isFalse);
  });

  test('changing the date alone shifts no item', () async {
    // submitSlot et submitRun n'envoient que HH:mm, jamais le jour.
    final existing = meetingWithItems(); // créneau 8:00→8:10, course 8:00→8:10
    controller.applyArguments({'competition': comp, 'meeting': existing});
    controller.date.value = DateTime(2026, 9, 13);
    when(() => meetingRepo.submitMeeting(
          competitionId: any(named: 'competitionId'),
          name: any(named: 'name'),
          description: any(named: 'description'),
          date: any(named: 'date'),
          beginHour: any(named: 'beginHour'),
          endHour: any(named: 'endHour'),
          id: any(named: 'id'),
        )).thenAnswer((_) async => 1);
    when(() => meetingRepo.getMeetings(42)).thenAnswer((_) async => [existing]);

    expect(await controller.save('Matin'), isTrue);

    verifyNever(() => meetingRepo.submitSlot(
        meetingId: any(named: 'meetingId'),
        name: any(named: 'name'),
        beginHour: any(named: 'beginHour'),
        endHour: any(named: 'endHour'),
        raceFormatDetailId: any(named: 'raceFormatDetailId'),
        id: any(named: 'id')));
  });

  test('moving the start hour shifts every item by the same amount', () async {
    // Une réunion qui démarre à 09:00 pendant que son premier item dit encore
    // 08:00 énonce deux choses différentes sur la même matinée.
    final existing = meetingWithItems();
    controller.applyArguments({'competition': comp, 'meeting': existing});
    controller.startMinutes.value = 9 * 60;
    when(() => meetingRepo.submitSlot(
          meetingId: any(named: 'meetingId'),
          name: any(named: 'name'),
          beginHour: any(named: 'beginHour'),
          endHour: any(named: 'endHour'),
          raceFormatDetailId: any(named: 'raceFormatDetailId'),
          id: any(named: 'id'),
        )).thenAnswer((_) async => 10);
    when(() => meetingRepo.submitRun(
          slotId: any(named: 'slotId'),
          name: any(named: 'name'),
          beginHour: any(named: 'beginHour'),
          endHour: any(named: 'endHour'),
          site: any(named: 'site'),
          id: any(named: 'id'),
        )).thenAnswer((_) async => 11);
    when(() => meetingRepo.submitMeeting(
          competitionId: any(named: 'competitionId'),
          name: any(named: 'name'),
          description: any(named: 'description'),
          date: any(named: 'date'),
          beginHour: any(named: 'beginHour'),
          endHour: any(named: 'endHour'),
          id: any(named: 'id'),
        )).thenAnswer((_) async => 1);
    when(() => meetingRepo.getMeetings(42)).thenAnswer((_) async => [existing]);

    expect(await controller.save('Matin'), isTrue);

    verify(() => meetingRepo.submitSlot(
          meetingId: 1,
          name: any(named: 'name'),
          beginHour: DateTime(2026, 9, 12, 9),
          endHour: DateTime(2026, 9, 12, 9, 10),
          raceFormatDetailId: any(named: 'raceFormatDetailId'),
          id: 10,
        )).called(1);
    verify(() => meetingRepo.submitRun(
          slotId: 10,
          name: any(named: 'name'),
          beginHour: DateTime(2026, 9, 12, 9),
          endHour: DateTime(2026, 9, 12, 9, 10),
          site: any(named: 'site'),
          id: 11,
        )).called(1);
  });

  test('a refused item stops the move rather than half-shifting the day',
      () async {
    final existing = meetingWithItems();
    controller.applyArguments({'competition': comp, 'meeting': existing});
    controller.startMinutes.value = 9 * 60;
    when(() => meetingRepo.submitSlot(
          meetingId: any(named: 'meetingId'),
          name: any(named: 'name'),
          beginHour: any(named: 'beginHour'),
          endHour: any(named: 'endHour'),
          raceFormatDetailId: any(named: 'raceFormatDetailId'),
          id: any(named: 'id'),
        )).thenAnswer((_) async => 0);

    expect(await controller.save('Matin'), isFalse);

    expect(controller.message.value, isA<UiMessageError>());
    verifyNever(() => meetingRepo.submitRun(
        slotId: any(named: 'slotId'),
        name: any(named: 'name'),
        beginHour: any(named: 'beginHour'),
        endHour: any(named: 'endHour'),
        site: any(named: 'site'),
        id: any(named: 'id')));
  });
}
