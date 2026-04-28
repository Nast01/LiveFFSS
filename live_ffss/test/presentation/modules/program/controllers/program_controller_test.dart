import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';
import 'package:live_ffss/app/module/program/controllers/program_controller.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements MeetingRepository {}

class _FakeMeeting extends Fake implements Meeting {}

Competition makeCompetition(int id) => Competition(
      id: id,
      name: 'C$id',
      statusCode: 0,
      statusLabel: '',
      speciality: 0,
      specialityLabel: '',
      typeWater: '',
      typePool: '',
      typeChrono: '',
      isEligibleToNationalRecord: false,
      numberOfLanes: 0,
      organizer: 'X',
      hasBegun: false,
      hasResult: false,
      hasPassed: false,
      level: 0,
      levelLabel: '',
      organizerClub: const Club(id: 1, name: 'X'),
    );

Meeting makeMeeting(int id) => Meeting(
      id: id,
      name: 'M$id',
      description: '',
      date: DateTime(2026, 5, 1),
      beginHour: DateTime(2026, 5, 1, 10),
      endHour: DateTime(2026, 5, 1, 12),
    );

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeMeeting());
  });

  late _MockRepo repo;
  late ProgramController controller;

  setUp(() {
    repo = _MockRepo();
    controller = ProgramController(repo);
  });

  group('ProgramController.setCompetition', () {
    test('null competition clears meetings', () {
      controller.meetings.value = [makeMeeting(1)];
      controller.setCompetition(null);
      expect(controller.competition.value, isNull);
      expect(controller.meetings, isEmpty);
    });

    test('non-null competition triggers loadMeetings', () async {
      when(() => repo.getMeetings(any())).thenAnswer((_) async => []);

      controller.setCompetition(makeCompetition(42));
      await Future<void>.delayed(Duration.zero);

      expect(controller.competition.value?.id, 42);
      verify(() => repo.getMeetings(42)).called(1);
    });
  });

  group('ProgramController.loadMeetings', () {
    test('on success: stores result and clears flags', () async {
      controller.competition.value = makeCompetition(99);
      when(() => repo.getMeetings(any())).thenAnswer((_) async => []);

      await controller.loadMeetings();

      expect(controller.isLoading.value, false);
      expect(controller.hasError.value, false);
    });

    test('on exception sets hasError', () async {
      controller.competition.value = makeCompetition(99);
      when(() => repo.getMeetings(any())).thenThrow(Exception('boom'));

      await controller.loadMeetings();

      expect(controller.hasError.value, true);
      expect(controller.isLoading.value, false);
    });
  });

  group('ProgramController.submitMeeting', () {
    test('on success: emits UiMessageSuccess and reloads', () async {
      controller.competition.value = makeCompetition(99);
      when(() => repo.createMeeting(
            name: any(named: 'name'),
            description: any(named: 'description'),
            date: any(named: 'date'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            competitionId: any(named: 'competitionId'),
          )).thenAnswer((_) async => true);
      when(() => repo.getMeetings(any())).thenAnswer((_) async => []);

      final ok = await controller.submitMeeting(
        name: 'N',
        description: 'D',
        date: DateTime(2026, 5, 1),
        beginTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 12, minute: 0),
      );

      expect(ok, isTrue);
      expect(controller.message.value, isA<UiMessageSuccess>());
      expect(controller.message.value?.translationKey,
          'meeting_created_successfully');
      verify(() => repo.createMeeting(
            name: 'N',
            description: 'D',
            date: DateTime(2026, 5, 1),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            competitionId: 99,
          )).called(1);
    });

    test('end before begin: emits UiMessageError, returns false, no API call',
        () async {
      controller.competition.value = makeCompetition(99);

      final ok = await controller.submitMeeting(
        name: 'N',
        description: 'D',
        date: DateTime(2026, 5, 1),
        beginTime: const TimeOfDay(hour: 12, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 0),
      );

      expect(ok, isFalse);
      expect(controller.message.value, isA<UiMessageError>());
      expect(controller.message.value?.translationKey,
          'end_time_must_be_after_begin_time');
      verifyNever(() => repo.createMeeting(
            name: any(named: 'name'),
            description: any(named: 'description'),
            date: any(named: 'date'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            competitionId: any(named: 'competitionId'),
          ));
    });

    test('on exception: emits UiMessageError', () async {
      controller.competition.value = makeCompetition(99);
      when(() => repo.createMeeting(
            name: any(named: 'name'),
            description: any(named: 'description'),
            date: any(named: 'date'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            competitionId: any(named: 'competitionId'),
          )).thenThrow(Exception('x'));

      final ok = await controller.submitMeeting(
        name: 'N',
        description: 'D',
        date: DateTime(2026, 5, 1),
        beginTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 12, minute: 0),
      );

      expect(ok, isFalse);
      expect(controller.message.value, isA<UiMessageError>());
    });
  });

  group('ProgramController.deleteMeeting', () {
    test('on success: removes from list and emits UiMessageSuccess', () async {
      controller.competition.value = makeCompetition(99);
      final m = makeMeeting(7);
      controller.meetings.value = [m];
      when(() => repo.deleteMeeting(any())).thenAnswer((_) async => true);

      await controller.deleteMeeting(m);

      expect(controller.meetings, isEmpty);
      expect(controller.message.value, isA<UiMessageSuccess>());
    });

    test('on exception: emits UiMessageError, list unchanged', () async {
      controller.competition.value = makeCompetition(99);
      final m = makeMeeting(7);
      controller.meetings.value = [m];
      when(() => repo.deleteMeeting(any())).thenThrow(Exception('boom'));

      await controller.deleteMeeting(m);

      expect(controller.meetings.length, 1);
      expect(controller.message.value, isA<UiMessageError>());
    });
  });
}
