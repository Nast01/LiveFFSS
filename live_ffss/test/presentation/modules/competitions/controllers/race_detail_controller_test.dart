import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/core/rfid/rfid_writer.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/data/services/attendance_service.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/attendance_status.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/category.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/entry.dart';
import 'package:live_ffss/app/domain/models/heat.dart';
import 'package:live_ffss/app/domain/models/race.dart';
import 'package:live_ffss/app/domain/models/result.dart';
import 'package:live_ffss/app/module/competitions/controllers/race_detail_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockRaceRepo extends Mock implements RaceRepository {}

class _MockClubRepo extends Mock implements ClubRepository {}

class _MockRfidWriter extends Mock implements RfidWriter {}

class _MockAttendanceService extends Mock implements AttendanceService {}

void main() {
  late _MockRaceRepo raceRepo;
  late _MockClubRepo clubRepo;
  late _MockRfidWriter rfidWriter;
  late _MockAttendanceService attendanceService;
  late RaceDetailController controller;

  setUpAll(() {
    registerFallbackValue(const <int, AttendanceStatus>{});
    registerFallbackValue(const <Athlete>[]);
  });

  Race makeRace(int id) => Race(
        id: id,
        name: 'Race$id',
        nameEnglish: 'Race$id (en)',
        distance: 100,
        gender: Gender.female,
        athletesPerTeam: 1,
        specialityId: 1,
        specialityLabel: 'Eau-plate',
        disciplineId: 1,
        isEligibleToNationalRecord: false,
        categories: const [],
      );

  Competition makeCompetition(int id) => Competition(
        id: id,
        name: 'Comp$id',
        statusCode: 1,
        statusLabel: 'OPEN',
        speciality: 1,
        specialityLabel: 'Eau-plate',
        typeWater: '',
        typePool: '',
        typeChrono: '',
        isEligibleToNationalRecord: false,
        numberOfLanes: 8,
        organizer: '',
        hasBegun: false,
        hasResult: false,
        hasPassed: false,
        level: 1,
        levelLabel: 'N',
        organizerClub: const Club(id: 0, name: ''),
      );

  Heat makeHeat({
    int id = 1,
    int number = 1,
    List<Result> results = const [],
  }) =>
      Heat(
          id: id,
          name: 'S$number',
          done: false,
          number: number,
          results: results);

  Result resultWithAthlete(int athleteId) {
    final athlete = Athlete(
      id: athleteId,
      licenseeNumber: '',
      firstName: 'X',
      lastName: 'Y',
      gender: Gender.female,
      year: 2010,
      nationalityCode: '',
      nationality: '',
      isValid: true,
    );
    return Result(
      id: 'r$athleteId',
      isValid: true,
      status: 1,
      statusLabel: 'OK',
      rank: 1,
      time: 1000,
      timeLabel: '10.00',
      athletes: [athlete],
    );
  }

  setUp(() {
    raceRepo = _MockRaceRepo();
    clubRepo = _MockClubRepo();
    rfidWriter = _MockRfidWriter();
    attendanceService = _MockAttendanceService();
    when(() => raceRepo.getHeats(any())).thenAnswer((_) async => const []);
    when(() => raceRepo.getEntries(any())).thenAnswer((_) async => const []);
    when(() => clubRepo.getAthleteClubs(any(), any()))
        .thenAnswer((_) async => const <int, Club>{});
    when(() => attendanceService.forRace(any()))
        .thenReturn(const <int, AttendanceStatus>{});
    when(() => attendanceService.save(any(), any())).thenAnswer((_) async {});
    controller =
        RaceDetailController(raceRepo, clubRepo, rfidWriter, attendanceService);
    controller.race.value = makeRace(10);
    controller.competition.value = makeCompetition(99);
  });

  tearDown(() {
    controller.onClose();
    Get.reset();
  });

  group('RaceDetailController.loadHeats', () {
    test('heats render before the clubs are resolved', () async {
      // Club labels decorate a heat row; the heats are the point. A club call
      // that is slow or broken must not keep them off screen.
      when(() => raceRepo.getHeats(any())).thenAnswer((_) async => [
            makeHeat(results: [resultWithAthlete(42)]),
          ]);

      await controller.loadHeats(initial: true);

      expect(
          controller.heats.single.results.single.athletes.single.club, isNull);
      expect(controller.error.value, isNull);
    });

    test('a club failure leaves the heats on screen without labels', () async {
      when(() => raceRepo.getHeats(any())).thenAnswer((_) async => [
            makeHeat(results: [resultWithAthlete(42)]),
          ]);
      when(() => clubRepo.getAthleteClubs(any(), any()))
          .thenThrow(const NetworkException('boom'));

      await controller.loadHeats(initial: true);
      await controller.loadEntries();
      await pumpEventQueue();

      expect(controller.heats, hasLength(1));
      expect(controller.error.value, isNull);
    });

    test('resolving the clubs labels the heats already on screen', () async {
      when(() => raceRepo.getHeats(any())).thenAnswer((_) async => [
            makeHeat(results: [resultWithAthlete(42)]),
          ]);
      when(() => raceRepo.getEntries(any())).thenAnswer((_) async => [
            Entry(
              id: 1,
              category: const Category(id: 1, name: 'Senior'),
              status: 1,
              statusLabel: 'Engagé',
              athletes: [resultWithAthlete(42).athletes.single],
            ),
          ]);
      when(() => clubRepo.getAthleteClubs(any(), any())).thenAnswer(
        (_) async => const {42: Club(id: 1, name: 'ASCE 35')},
      );

      await controller.loadHeats(initial: true);
      await controller.loadEntries();
      await pumpEventQueue();

      expect(controller.heats.single.results.single.athletes.single.club?.name,
          'ASCE 35');
    });

    test('resolves the clubs once, however many polls run', () async {
      when(() => raceRepo.getEntries(any())).thenAnswer((_) async => [
            Entry(
              id: 1,
              category: const Category(id: 1, name: 'Senior'),
              status: 1,
              statusLabel: 'Engagé',
              athletes: [resultWithAthlete(42).athletes.single],
            ),
          ]);
      when(() => clubRepo.getAthleteClubs(any(), any())).thenAnswer(
        (_) async => const {42: Club(id: 1, name: 'ASCE 35')},
      );

      await controller.loadEntries();
      await pumpEventQueue();
      await controller.loadHeats(initial: true);
      await controller.loadHeats();
      await controller.loadHeats();

      verify(() => clubRepo.getAthleteClubs(any(), any())).called(1);
      verify(() => raceRepo.getHeats(10)).called(3);
    });

    test('skips club resolution entirely when no competition is set', () async {
      controller.competition.value = null;

      await controller.loadHeats(initial: true);
      await controller.loadEntries();
      await pumpEventQueue();

      verifyNever(() => clubRepo.getAthleteClubs(any(), any()));
      verify(() => raceRepo.getHeats(10)).called(1);
    });

    test('no-ops when race is not set', () async {
      controller.race.value = null;

      await controller.loadHeats(initial: true);

      verifyNever(() => clubRepo.getClubs(any()));
      verifyNever(() => raceRepo.getHeats(any()));
    });
  });

  group('RaceDetailController.loadEntries', () {
    Athlete athlete(int id, {int clubId = 0}) => Athlete(
          id: id,
          licenseeNumber: '',
          firstName: 'A$id',
          lastName: 'B$id',
          gender: Gender.female,
          year: 2000,
          nationalityCode: '',
          nationality: '',
          isValid: true,
          clubId: clubId,
        );

    Entry makeEntry({
      required int id,
      required String clubName,
      List<Athlete> athletes = const [],
    }) =>
        Entry(
          id: id,
          category: const Category(id: 1, name: 'Senior'),
          organisme: Club(id: id, name: clubName),
          status: 1,
          statusLabel: 'Engagé',
          athletes: athletes,
        );

    test('loads entries in the order returned by the data source', () async {
      when(() => raceRepo.getEntries(any())).thenAnswer((_) async => [
            makeEntry(id: 1, clubName: 'Nice'),
            makeEntry(id: 2, clubName: 'Antibes'),
            makeEntry(id: 3, clubName: 'Marseille'),
          ]);

      await controller.loadEntries();

      expect(
        controller.entries.map((e) => e.organisme!.name),
        ['Nice', 'Antibes', 'Marseille'],
      );
      expect(controller.entriesLoading.value, isFalse);
      expect(controller.entriesError.value, isNull);
      verify(() => raceRepo.getEntries(10)).called(1);
    });

    test('patches the rows once the clubs resolve', () async {
      when(() => raceRepo.getEntries(any())).thenAnswer((_) async => [
            makeEntry(id: 1, clubName: 'Nice', athletes: [athlete(42)]),
          ]);
      when(() => clubRepo.getAthleteClubs(any(), any())).thenAnswer(
        (_) async =>
            const {42: Club(id: 7, name: 'Nice', capUrl: 'https://cap/42.png')},
      );

      await controller.loadEntries();
      // The list is on screen before the clubs are asked for.
      expect(controller.entries.single.athletes.single.club, isNull);

      await pumpEventQueue();

      expect(controller.entries.single.athletes.single.club?.capUrl,
          'https://cap/42.png');
    });

    test('resolves from every engaged athlete, not just the listed ones',
        () async {
      // The regression the shared resolver exists for: clubmates the club list
      // never named used to go unresolved.
      when(() => raceRepo.getEntries(any())).thenAnswer((_) async => [
            makeEntry(id: 1, clubName: 'Nice', athletes: [
              athlete(1, clubId: 7),
              athlete(2, clubId: 7),
            ]),
          ]);
      when(() => clubRepo.getAthleteClubs(any(), any())).thenAnswer(
        (_) async => const {
          1: Club(id: 7, name: 'Nice', logoUrl: 'l'),
          2: Club(id: 7, name: 'Nice', logoUrl: 'l'),
        },
      );

      await controller.loadEntries();
      await pumpEventQueue();

      expect(controller.entries.single.athletes.map((a) => a.club?.logoUrl),
          ['l', 'l']);
      final passed = verify(() => clubRepo.getAthleteClubs(99, captureAny()))
          .captured
          .single as List<Athlete>;
      expect(passed.map((a) => a.id), [1, 2]);
    });

    test('a reload keeps the resolved clubs without asking again', () async {
      when(() => raceRepo.getEntries(any())).thenAnswer((_) async => [
            makeEntry(id: 1, clubName: 'X', athletes: [athlete(5, clubId: 77)]),
          ]);
      when(() => clubRepo.getAthleteClubs(any(), any())).thenAnswer(
        (_) async => const {5: Club(id: 77, name: 'Nice', logoUrl: 'l')},
      );

      await controller.loadEntries();
      await pumpEventQueue();
      expect(controller.entries.single.athletes.single.club?.logoUrl, 'l');

      await controller.loadEntries();
      await pumpEventQueue();

      expect(controller.entries.single.athletes.single.club?.logoUrl, 'l');
      verify(() => clubRepo.getAthleteClubs(any(), any())).called(1);
    });

    test('renders entries even if the club resolution fails', () async {
      when(() => raceRepo.getEntries(any())).thenAnswer((_) async => [
            makeEntry(id: 1, clubName: 'Nice', athletes: [athlete(42)]),
          ]);
      when(() => clubRepo.getAthleteClubs(any(), any()))
          .thenThrow(const NetworkException('boom'));

      await controller.loadEntries();
      await pumpEventQueue();

      expect(controller.entriesError.value, isNull);
      expect(controller.entries.single.athletes.single.club, isNull);
    });

    test('surfaces an error and leaves entries empty on failure', () async {
      when(() => raceRepo.getEntries(any()))
          .thenThrow(const NetworkException('boom'));

      await controller.loadEntries();

      expect(controller.entriesError.value, isA<NetworkException>());
      expect(controller.entries, isEmpty);
      expect(controller.entriesLoading.value, isFalse);
    });

    test('no-ops when race is not set', () async {
      controller.race.value = null;

      await controller.loadEntries();

      verifyNever(() => raceRepo.getEntries(any()));
    });
  });

  group('RaceDetailController presence', () {
    Athlete makeAthlete({
      required int id,
      required String firstName,
      required String lastName,
      int year = 2000,
      String clubLabel = '',
    }) =>
        Athlete(
          id: id,
          licenseeNumber: '',
          firstName: firstName,
          lastName: lastName,
          gender: Gender.female,
          year: year,
          nationalityCode: '',
          nationality: '',
          isValid: true,
          clubLabel: clubLabel,
        );

    Entry entryWithAthletes(int id, List<Athlete> athletes) => Entry(
          id: id,
          category: const Category(id: 1, name: 'Senior'),
          status: 1,
          statusLabel: 'Engagé',
          athletes: athletes,
        );

    test('sortedAthletes flattens every entry and orders by last then first',
        () {
      controller.entries.value = [
        entryWithAthletes(1, [
          makeAthlete(id: 1, firstName: 'Zoe', lastName: 'Martin'),
          makeAthlete(id: 2, firstName: 'Anna', lastName: 'Dupont'),
        ]),
        entryWithAthletes(2, [
          makeAthlete(id: 3, firstName: 'Bob', lastName: 'Dupont'),
        ]),
      ];

      expect(
        controller.sortedAthletes.map((a) => a.id),
        // Dupont/Anna, Dupont/Bob, Martin/Zoe
        [2, 3, 1],
      );
    });

    test('defaults to sorting by name', () {
      expect(controller.sortMode.value, AthleteSortMode.name);
    });

    test('sortMode club orders by club then name', () {
      controller.entries.value = [
        entryWithAthletes(1, [
          makeAthlete(
              id: 1, firstName: 'Zoe', lastName: 'Aaa', clubLabel: 'Nice'),
          makeAthlete(
              id: 2, firstName: 'Anna', lastName: 'Bbb', clubLabel: 'Antibes'),
          makeAthlete(
              id: 3, firstName: 'Bob', lastName: 'Aaa', clubLabel: 'Antibes'),
        ]),
      ];

      controller.setSortMode(AthleteSortMode.club);

      expect(
        controller.sortedAthletes.map((a) => a.id),
        // Antibes/Aaa/Bob, Antibes/Bbb/Anna, Nice/Aaa/Zoe
        [3, 2, 1],
      );
    });

    test('sortMode attendance groups by status then name', () {
      final present = makeAthlete(id: 1, firstName: 'A', lastName: 'Zzz');
      final waiting = makeAthlete(id: 2, firstName: 'B', lastName: 'Yyy');
      final absent = makeAthlete(id: 3, firstName: 'C', lastName: 'Xxx');
      controller.entries.value = [
        entryWithAthletes(1, [present, waiting, absent]),
      ];
      controller.attendance[1] = AttendanceStatus.present;
      controller.attendance[3] = AttendanceStatus.absent;

      controller.setSortMode(AthleteSortMode.attendance);

      // waiting (index 0), present (index 1), absent (index 2)
      expect(controller.sortedAthletes.map((a) => a.id), [2, 1, 3]);
    });

    test('athletes default to waiting', () {
      final athlete = makeAthlete(id: 7, firstName: 'Jo', lastName: 'Roux');
      expect(controller.attendanceOf(athlete), AttendanceStatus.waiting);
    });

    test('cycleAttendance rotates waiting → present → absent → waiting', () {
      final athlete = makeAthlete(id: 7, firstName: 'Jo', lastName: 'Roux');

      controller.cycleAttendance(athlete);
      expect(controller.attendanceOf(athlete), AttendanceStatus.present);

      controller.cycleAttendance(athlete);
      expect(controller.attendanceOf(athlete), AttendanceStatus.absent);

      controller.cycleAttendance(athlete);
      expect(controller.attendanceOf(athlete), AttendanceStatus.waiting);
    });

    test('setAttendance sets an explicit status directly', () {
      final athlete = makeAthlete(id: 7, firstName: 'Jo', lastName: 'Roux');

      controller.setAttendance(athlete, AttendanceStatus.absent);
      expect(controller.attendanceOf(athlete), AttendanceStatus.absent);

      controller.setAttendance(athlete, AttendanceStatus.present);
      expect(controller.attendanceOf(athlete), AttendanceStatus.present);
    });

    test('presence is tracked per athlete id', () {
      final a = makeAthlete(id: 1, firstName: 'A', lastName: 'A');
      final b = makeAthlete(id: 2, firstName: 'B', lastName: 'B');

      controller.cycleAttendance(a);

      expect(controller.attendanceOf(a), AttendanceStatus.present);
      expect(controller.attendanceOf(b), AttendanceStatus.waiting);
    });
  });

  group('RaceDetailController.attendanceCounts', () {
    Athlete makeAthlete({required int id}) => Athlete(
          id: id,
          licenseeNumber: '',
          firstName: 'A$id',
          lastName: 'B$id',
          gender: Gender.female,
          year: 2000,
          nationalityCode: '',
          nationality: '',
          isValid: true,
        );

    Entry entryWithAthletes(int id, List<Athlete> athletes) => Entry(
          id: id,
          category: const Category(id: 1, name: 'Senior'),
          status: 1,
          statusLabel: 'Engagé',
          athletes: athletes,
        );

    test('is all zero when nobody is engaged', () {
      final counts = controller.attendanceCounts;

      expect(counts.waiting, 0);
      expect(counts.present, 0);
      expect(counts.absent, 0);
      expect(counts.total, 0);
    });

    test('counts every engaged athlete as waiting before any pointing', () {
      controller.entries.value = [
        entryWithAthletes(1, [makeAthlete(id: 1), makeAthlete(id: 2)]),
        entryWithAthletes(2, [makeAthlete(id: 3)]),
      ];

      final counts = controller.attendanceCounts;

      expect(counts.waiting, 3);
      expect(counts.present, 0);
      expect(counts.absent, 0);
      expect(counts.total, 3);
    });

    test('splits the engaged athletes across the three statuses', () {
      controller.entries.value = [
        entryWithAthletes(1, [
          makeAthlete(id: 1),
          makeAthlete(id: 2),
          makeAthlete(id: 3),
        ]),
        entryWithAthletes(2, [makeAthlete(id: 4)]),
      ];

      controller.setAttendance(makeAthlete(id: 1), AttendanceStatus.present);
      controller.setAttendance(makeAthlete(id: 2), AttendanceStatus.present);
      controller.setAttendance(makeAthlete(id: 3), AttendanceStatus.absent);

      final counts = controller.attendanceCounts;

      expect(counts.waiting, 1);
      expect(counts.present, 2);
      expect(counts.absent, 1);
      expect(counts.total, 4);
    });

    test('ignores stored statuses of athletes not engaged in this race', () {
      controller.entries.value = [
        entryWithAthletes(1, [makeAthlete(id: 1)]),
      ];
      // Left over from a previous load of a larger start list.
      controller.attendance[999] = AttendanceStatus.present;

      final counts = controller.attendanceCounts;

      expect(counts.present, 0);
      expect(counts.waiting, 1);
      expect(counts.total, 1);
    });
  });

  group('RaceDetailController attendance persistence', () {
    Athlete makeAthlete({required int id}) => Athlete(
          id: id,
          licenseeNumber: 'L$id',
          firstName: 'A$id',
          lastName: 'B$id',
          gender: Gender.female,
          year: 2000,
          nationalityCode: '',
          nationality: '',
          isValid: true,
        );

    Entry entryWithAthletes(int id, List<Athlete> athletes) => Entry(
          id: id,
          category: const Category(id: 1, name: 'Senior'),
          status: 1,
          statusLabel: 'Engagé',
          athletes: athletes,
        );

    test('restores the stored statuses for this race on load', () async {
      when(() => attendanceService.forRace(10)).thenReturn({
        1: AttendanceStatus.present,
        2: AttendanceStatus.absent,
      });
      when(() => raceRepo.getEntries(any())).thenAnswer((_) async => [
            entryWithAthletes(1, [makeAthlete(id: 1), makeAthlete(id: 2)]),
          ]);

      await controller.loadEntries();

      expect(controller.attendanceOf(makeAthlete(id: 1)),
          AttendanceStatus.present);
      expect(
          controller.attendanceOf(makeAthlete(id: 2)), AttendanceStatus.absent);
      verify(() => attendanceService.forRace(10)).called(1);
    });

    test('a reload does not overwrite pointing done since the first load',
        () async {
      when(() => attendanceService.forRace(10))
          .thenReturn({1: AttendanceStatus.present});
      when(() => raceRepo.getEntries(any())).thenAnswer((_) async => [
            entryWithAthletes(1, [makeAthlete(id: 1)]),
          ]);

      await controller.loadEntries();
      controller.setAttendance(makeAthlete(id: 1), AttendanceStatus.absent);
      await controller.loadEntries();

      expect(
          controller.attendanceOf(makeAthlete(id: 1)), AttendanceStatus.absent);
      verify(() => attendanceService.forRace(10)).called(1);
    });

    test('cycleAttendance persists the new state', () async {
      controller.cycleAttendance(makeAthlete(id: 7));
      await pumpEventQueue();

      verify(() => attendanceService.save(10, {7: AttendanceStatus.present}))
          .called(1);
    });

    test('setAttendance persists the new state', () async {
      controller.setAttendance(makeAthlete(id: 7), AttendanceStatus.absent);
      await pumpEventQueue();

      verify(() => attendanceService.save(10, {7: AttendanceStatus.absent}))
          .called(1);
    });

    test('a bracelet scan persists the athlete it marks present', () async {
      final payloads = StreamController<String>();
      when(() => rfidWriter.isSupported).thenReturn(true);
      when(() => rfidWriter.readBracelets()).thenAnswer((_) => payloads.stream);
      controller.entries.value = [
        entryWithAthletes(1, [makeAthlete(id: 7)]),
      ];

      controller.startScan();
      payloads.add('L7');
      await pumpEventQueue();

      verify(() => attendanceService.save(10, {7: AttendanceStatus.present}))
          .called(1);
      controller.stopScan();
      await payloads.close();
    });

    test('nothing is persisted when the race is unknown', () async {
      controller.race.value = null;

      controller.setAttendance(makeAthlete(id: 7), AttendanceStatus.present);
      await pumpEventQueue();

      verifyNever(() => attendanceService.save(any(), any()));
    });
  });

  group('HeatLiveStatusX', () {
    test('done heat → official', () {
      expect(
        const Heat(id: 1, name: 'S1', done: true, number: 1).liveStatus,
        HeatLiveStatus.official,
      );
    });

    test('not done with startDate → live', () {
      expect(
        Heat(
          id: 1,
          name: 'S1',
          done: false,
          number: 1,
          startDate: DateTime(2026, 5, 1, 10),
        ).liveStatus,
        HeatLiveStatus.live,
      );
    });

    test('not done, no startDate → unofficial', () {
      expect(
        const Heat(id: 1, name: 'S1', done: false, number: 1).liveStatus,
        HeatLiveStatus.unofficial,
      );
    });
  });

  group('startScan', () {
    late StreamController<String> scanStream;

    Athlete scanAthlete(int id, String lastName, String licence) => Athlete(
          id: id,
          licenseeNumber: licence,
          firstName: 'X',
          lastName: lastName,
          gender: Gender.female,
          year: 2000,
          nationalityCode: '',
          nationality: '',
          isValid: true,
        );

    Entry scanEntry(List<Athlete> athletes) => Entry(
          id: 1,
          category: const Category(id: 1, name: 'Senior'),
          status: 1,
          statusLabel: 'Engagé',
          athletes: athletes,
        );

    setUp(() {
      scanStream = StreamController<String>();
      when(() => rfidWriter.readBracelets())
          .thenAnswer((_) => scanStream.stream);
    });

    tearDown(() {
      // Not awaited: an unlistened single-subscription StreamController's
      // close() future never completes (no listener to deliver the done
      // event to), which would hang this tearDown for the whole test's
      // timeout in tests that never call startScan().
      if (!scanStream.isClosed) scanStream.close();
    });

    test('a matching bracelet marks the athlete present', () async {
      final jean = scanAthlete(1, 'DUPONT', '123');
      controller.entries.value = [
        scanEntry([jean])
      ];
      controller.startScan();
      scanStream.add('123;DUPONT');
      await pumpEventQueue();
      expect(controller.attendanceOf(jean), AttendanceStatus.present);
      expect(controller.presentCount.value, 1);
      expect(controller.scanLog.first.outcome, ScanOutcome.present);
    });

    test('an unknown licence logs notEntered and leaves attendance', () async {
      final jean = scanAthlete(1, 'DUPONT', '123');
      controller.entries.value = [
        scanEntry([jean])
      ];
      controller.startScan();
      scanStream.add('999;NOBODY');
      await pumpEventQueue();
      expect(controller.attendanceOf(jean), AttendanceStatus.waiting);
      expect(controller.scanLog.first.outcome, ScanOutcome.notEntered);
      expect(controller.presentCount.value, 0);
    });

    test('a stream error logs unreadable', () async {
      controller.startScan();
      scanStream.addError(const RfidException('bracelet_unreadable'));
      await pumpEventQueue();
      expect(controller.scanLog.first.outcome, ScanOutcome.unreadable);
      expect(controller.scanLog.first.label, 'bracelet_unreadable');
    });

    test('stopScan cancels the subscription; later events are ignored',
        () async {
      final jean = scanAthlete(1, 'DUPONT', '123');
      controller.entries.value = [
        scanEntry([jean])
      ];
      controller.startScan();
      controller.stopScan();
      scanStream.add('123;DUPONT');
      await pumpEventQueue();
      expect(controller.attendanceOf(jean), AttendanceStatus.waiting);
      expect(controller.isScanning.value, isFalse);
    });

    test('canScanBracelets reflects the writer', () {
      when(() => rfidWriter.isSupported).thenReturn(true);
      expect(controller.canScanBracelets, isTrue);
    });
  });
}
