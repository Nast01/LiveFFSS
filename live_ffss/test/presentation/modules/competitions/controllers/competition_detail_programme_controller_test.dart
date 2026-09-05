import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/race.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/domain/models/run.dart';
import 'package:live_ffss/app/domain/models/slot.dart';
import 'package:live_ffss/app/module/competitions/controllers/competition_detail_programme_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockStorage extends Mock implements FlutterSecureStorage {}

class _MockRaceRepo extends Mock implements RaceRepository {}

class _MockMeetingRepo extends Mock implements MeetingRepository {}

void main() {
  late _MockStorage storage;
  late _MockRaceRepo raceRepo;
  late _MockMeetingRepo meetingRepo;
  late ProgrammeService service;
  late CompetitionDetailProgrammeController controller;

  setUpAll(() => registerFallbackValue(''));

  const competition = Competition(
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

  final withDates = competition.copyWith(
    beginDate: DateTime(2026, 6, 13),
    endDate: DateTime(2026, 6, 14),
  );
  final day = DateTime(2026, 6, 13);

  // A Slot's/Run's HH:mm lands on 1970-01-01; only Meeting.date carries the
  // réunion's real day. The fixtures keep that split so a test cannot pass on
  // a date comparison the real payload would fail.
  DateTime hhmm(String value) {
    final parts = value.split(':');
    return DateTime(1970, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
  }

  Race race(int id) => Race(
        id: id,
        name: 'Race$id',
        nameEnglish: 'Race$id (en)',
        distance: 100,
        gender: Gender.male,
        athletesPerTeam: 1,
        specialityId: 1,
        specialityLabel: 'Eau-plate',
        disciplineId: 1,
        isEligibleToNationalRecord: false,
        categories: const [],
      );

  Run course(int id,
          {String site = 'Côtier 1',
          String begin = '08:00',
          String end = '08:10'}) =>
      Run(
        id: id,
        name: 'Série 1',
        label: '100m · Cadets',
        fullLabel: '100m · Cadets · Série 1',
        status: RunStatus.waiting,
        statusLabel: '',
        site: site,
        beginTime: hhmm(begin),
        endTime: hhmm(end),
      );

  Meeting meetingOn(DateTime date, List<Slot> slots) => Meeting(
        id: 78,
        name: 'Réunion',
        description: '',
        date: date,
        beginHour: DateTime(date.year, date.month, date.day, 8),
        endHour: DateTime(date.year, date.month, date.day, 18),
        slots: slots,
      );

  Slot slotWith(int id, List<Run> runs, {String name = 'Séries'}) => Slot(
        id: id,
        name: name,
        beginHour: hhmm('08:00'),
        endHour: hhmm('08:10'),
        runs: runs,
      );

  // The local programme is kept for one job only: bridging a tapped course to
  // its épreuve. Course 900 is the FFSS course backing ProgrammeRace 10, which
  // belongs to the structure of race 500.
  CompetitionProgramme seed() => const CompetitionProgramme(
        competitionId: 42,
        nextLocalId: 100,
        structures: [
          EventStructure(
            raceId: 500,
            categoryId: 7,
            raceLabel: '100m',
            categoryLabel: 'Cadets',
            levels: [
              RoundLevel(type: RoundType.serie, races: [
                ProgrammeRace(id: 10, number: 1, runId: 900),
              ]),
            ],
          ),
        ],
      );

  setUp(() {
    storage = _MockStorage();
    raceRepo = _MockRaceRepo();
    meetingRepo = _MockMeetingRepo();
    when(() => storage.read(key: any(named: 'key')))
        .thenAnswer((_) async => jsonEncode(seed().toJson()));
    when(() =>
            storage.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((_) async {});
    when(() => raceRepo.getRaces(42)).thenAnswer((_) async => [race(500)]);
    service = ProgrammeService(storage);
    controller =
        CompetitionDetailProgrammeController(service, raceRepo, meetingRepo);
  });

  test('load reads the day schedule from the FFSS réunion tree', () async {
    when(() => meetingRepo.getMeetings(42)).thenAnswer((_) async => [
          meetingOn(day, [
            slotWith(1, [course(900, site: 'Côtier 1')]),
          ]),
        ]);

    await controller.load(withDates);

    expect(controller.isLoading.value, isFalse);
    expect(controller.hasProgramme, isTrue);
    final sections = controller.sectionsFor(day);
    expect(sections.single.title, 'Côtier 1');
    expect(sections.single.items.single.runId, 900);
  });

  test('siteNamesFor lists the day\'s sites, leaving manual items out',
      () async {
    when(() => meetingRepo.getMeetings(42)).thenAnswer((_) async => [
          meetingOn(day, [
            slotWith(1, [
              course(900, site: 'Côtier 1', begin: '08:00', end: '08:10'),
              course(901, site: 'Côtier 2', begin: '08:10', end: '08:20'),
            ]),
            slotWith(2, const [], name: 'Pause déjeuner'),
          ]),
        ]);

    await controller.load(withDates);

    expect(controller.siteNamesFor(day), ['Côtier 1', 'Côtier 2']);
  });

  test('the day falls back to its first site until one is picked', () async {
    when(() => meetingRepo.getMeetings(42)).thenAnswer((_) async => [
          meetingOn(day, [
            slotWith(1, [
              course(900, site: 'Côtier 1', begin: '08:00', end: '08:10'),
              course(901, site: 'Côtier 2', begin: '08:10', end: '08:20'),
            ]),
          ]),
        ]);

    await controller.load(withDates);
    expect(controller.activeSiteFor(day), 'Côtier 1');

    controller.selectedSite.value = 'Côtier 2';
    expect(controller.activeSiteFor(day), 'Côtier 2');
  });

  test('a site picked on another day does not blank this one', () async {
    // Day two runs elsewhere. Keeping the stale pick would show an empty day
    // rather than the schedule that is actually there.
    when(() => meetingRepo.getMeetings(42)).thenAnswer((_) async => [
          meetingOn(day, [
            slotWith(1, [course(900, site: 'Côtier 1')]),
          ]),
        ]);

    await controller.load(withDates);
    controller.selectedSite.value = 'Bassin nord';

    expect(controller.activeSiteFor(day), 'Côtier 1');
  });

  test('only the active site shows, but manual items always do', () async {
    when(() => meetingRepo.getMeetings(42)).thenAnswer((_) async => [
          meetingOn(day, [
            slotWith(1, [
              course(900, site: 'Côtier 1', begin: '08:00', end: '08:10'),
              course(901, site: 'Côtier 2', begin: '08:10', end: '08:20'),
            ]),
            slotWith(2, const [], name: 'Remise des prix'),
          ]),
        ]);

    await controller.load(withDates);
    controller.selectedSite.value = 'Côtier 2';

    final visible = controller.visibleSectionsFor(day);
    expect(visible.where((s) => !s.isManual).map((s) => s.title), ['Côtier 2']);
    expect(visible.where((s) => s.isManual), hasLength(1));
  });

  test('raceForRun bridges a course to its épreuve through the local programme',
      () async {
    when(() => meetingRepo.getMeetings(42)).thenAnswer((_) async => [
          meetingOn(day, [
            slotWith(1, [course(900)]),
          ]),
        ]);

    await controller.load(withDates);

    expect(controller.raceForRun(900)?.id, 500);
    expect(controller.raceForRun(9999), isNull);
  });

  test('a getRaces failure leaves the schedule readable and the taps inert',
      () async {
    when(() => meetingRepo.getMeetings(42)).thenAnswer((_) async => [
          meetingOn(day, [
            slotWith(1, [course(900)]),
          ]),
        ]);
    when(() => raceRepo.getRaces(42)).thenThrow(const NetworkException('boom'));

    await controller.load(withDates);

    expect(controller.hasError.value, isFalse);
    expect(controller.hasProgramme, isTrue);
    expect(controller.raceForRun(900), isNull);
  });

  test('a getMeetings failure reports the error instead of an empty programme',
      () async {
    when(() => meetingRepo.getMeetings(42))
        .thenThrow(const NetworkException('boom'));

    await controller.load(withDates);

    expect(controller.isLoading.value, isFalse);
    expect(controller.hasError.value, isTrue);
    expect(controller.hasProgramme, isFalse);
  });
}
