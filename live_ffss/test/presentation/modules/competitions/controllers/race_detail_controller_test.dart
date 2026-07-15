import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
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

void main() {
  late _MockRaceRepo raceRepo;
  late _MockClubRepo clubRepo;
  late RaceDetailController controller;

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
      Heat(id: id, name: 'S$number', done: false, number: number, results: results);

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
    when(() => raceRepo.getHeats(any())).thenAnswer((_) async => const []);
    when(() => clubRepo.getClubs(any())).thenAnswer((_) async => const []);
    controller = RaceDetailController(raceRepo, clubRepo);
    controller.race.value = makeRace(10);
    controller.competition.value = makeCompetition(99);
  });

  tearDown(() {
    controller.onClose();
    Get.reset();
  });

  group('RaceDetailController.loadHeats', () {
    test('loads clubs BEFORE heats and injects them into result athletes',
        () async {
      const clubA = Club(
        id: 1,
        name: 'ASCE 35',
        athletes: [
          Athlete(
            id: 42,
            licenseeNumber: '',
            firstName: 'Marion',
            lastName: 'Gaillard',
            gender: Gender.female,
            year: 2009,
            nationalityCode: '',
            nationality: '',
            isValid: true,
          ),
        ],
      );

      // Order matters: clubs must resolve before getHeats is called.
      final order = <String>[];
      when(() => clubRepo.getClubs(any())).thenAnswer((_) async {
        order.add('clubs');
        return [clubA];
      });
      when(() => raceRepo.getHeats(any())).thenAnswer((_) async {
        order.add('heats');
        return [
          makeHeat(results: [resultWithAthlete(42)]),
        ];
      });

      await controller.loadHeats(initial: true);

      expect(order, ['clubs', 'heats']);
      verify(() => clubRepo.getClubs(99)).called(1);
      verify(() => raceRepo.getHeats(10)).called(1);

      final injectedAthlete =
          controller.heats.single.results.single.athletes.single;
      expect(injectedAthlete.club, isNotNull);
      expect(injectedAthlete.club!.name, 'ASCE 35');
    });

    test('club fetch failure prevents the heats fetch and surfaces an error',
        () async {
      when(() => clubRepo.getClubs(any()))
          .thenThrow(const NetworkException('boom'));

      await controller.loadHeats(initial: true);

      verify(() => clubRepo.getClubs(99)).called(1);
      verifyNever(() => raceRepo.getHeats(any()));
      expect(controller.error.value, isA<NetworkException>());
      expect(controller.isLoading.value, isFalse);
      expect(controller.heats, isEmpty);
    });

    test('retry after a club failure re-attempts the club fetch', () async {
      var clubAttempt = 0;
      when(() => clubRepo.getClubs(any())).thenAnswer((_) async {
        clubAttempt++;
        if (clubAttempt == 1) throw const NetworkException('boom');
        return const [];
      });

      await controller.loadHeats(initial: true);
      expect(controller.error.value, isA<NetworkException>());

      // User pulls to refresh.
      await controller.loadHeats(initial: true);

      expect(clubAttempt, 2);
      expect(controller.error.value, isNull);
      verify(() => raceRepo.getHeats(10)).called(1);
    });

    test('reuses cached club index across calls (only one club fetch)',
        () async {
      await controller.loadHeats(initial: true);
      await controller.loadHeats();
      await controller.loadHeats();

      verify(() => clubRepo.getClubs(99)).called(1);
      verify(() => raceRepo.getHeats(10)).called(3);
    });

    test('skips club fetch entirely when no competition is set', () async {
      controller.competition.value = null;

      await controller.loadHeats(initial: true);

      verifyNever(() => clubRepo.getClubs(any()));
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

    test("injects each athlete's club (cap image) from the club index",
        () async {
      when(() => raceRepo.getEntries(any())).thenAnswer((_) async => [
            makeEntry(id: 1, clubName: 'Nice', athletes: [athlete(42)]),
          ]);
      when(() => clubRepo.getClubs(any())).thenAnswer((_) async => [
            Club(
              id: 7,
              name: 'Nice',
              capUrl: 'https://cap/42.png',
              athletes: [athlete(42).copyWith(club: null)],
            ),
          ]);

      await controller.loadEntries();

      final injected = controller.entries.single.athletes.single;
      expect(injected.club?.capUrl, 'https://cap/42.png');
    });

    test('backfills a missing club logo via getClubDetail (progressive)',
        () async {
      // Club list misses the athlete → no image from the index.
      when(() => raceRepo.getEntries(any())).thenAnswer((_) async => [
            makeEntry(
              id: 1,
              clubName: 'X',
              athletes: [athlete(5, clubId: 77)],
            ),
          ]);
      when(() => clubRepo.getClubs(any())).thenAnswer((_) async => const []);
      when(() => clubRepo.getClubDetail(77)).thenAnswer(
        (_) async =>
            const Club(id: 77, name: 'Nice', logoUrl: 'https://logo/77.png'),
      );

      await controller.loadEntries();
      await pumpEventQueue();

      final injected = controller.entries.single.athletes.single;
      expect(injected.club?.logoUrl, 'https://logo/77.png');
      verify(() => clubRepo.getClubDetail(77)).called(1);
    });

    test('backfill fetches each club once, deduped across athletes', () async {
      when(() => raceRepo.getEntries(any())).thenAnswer((_) async => [
            makeEntry(id: 1, clubName: 'X', athletes: [
              athlete(5, clubId: 77),
              athlete(6, clubId: 77),
            ]),
          ]);
      when(() => clubRepo.getClubs(any())).thenAnswer((_) async => const []);
      when(() => clubRepo.getClubDetail(77)).thenAnswer(
        (_) async => const Club(id: 77, name: 'Nice', logoUrl: 'l'),
      );

      await controller.loadEntries();
      await pumpEventQueue();

      verify(() => clubRepo.getClubDetail(77)).called(1);
    });

    test('reload re-applies a cached club logo without re-fetching', () async {
      when(() => raceRepo.getEntries(any())).thenAnswer((_) async => [
            makeEntry(id: 1, clubName: 'X', athletes: [athlete(5, clubId: 77)]),
          ]);
      when(() => clubRepo.getClubs(any())).thenAnswer((_) async => const []);
      when(() => clubRepo.getClubDetail(77)).thenAnswer(
        (_) async => const Club(id: 77, name: 'Nice', logoUrl: 'l'),
      );

      await controller.loadEntries();
      await pumpEventQueue();
      expect(controller.entries.single.athletes.single.club?.logoUrl, 'l');

      // Reload: entries come back with no club, but the logo is re-applied
      // from cache and getClubDetail is NOT called again.
      await controller.loadEntries();
      await pumpEventQueue();

      expect(controller.entries.single.athletes.single.club?.logoUrl, 'l');
      verify(() => clubRepo.getClubDetail(77)).called(1);
    });

    test('renders entries even if the club fetch fails (best-effort images)',
        () async {
      when(() => raceRepo.getEntries(any())).thenAnswer((_) async => [
            makeEntry(id: 1, clubName: 'Nice', athletes: [athlete(42)]),
          ]);
      when(() => clubRepo.getClubs(any()))
          .thenThrow(const NetworkException('boom'));

      await controller.loadEntries();

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
      final present =
          makeAthlete(id: 1, firstName: 'A', lastName: 'Zzz');
      final waiting =
          makeAthlete(id: 2, firstName: 'B', lastName: 'Yyy');
      final absent =
          makeAthlete(id: 3, firstName: 'C', lastName: 'Xxx');
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
}
