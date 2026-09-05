import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:intl/intl.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:live_ffss/app/data/repositories/race_format_repository.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/category.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/course_penalty.dart';
import 'package:live_ffss/app/domain/models/entry.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/heat.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';
import 'package:live_ffss/app/domain/models/race.dart';
import 'package:live_ffss/app/domain/models/discipline.dart';
import 'package:live_ffss/app/domain/models/lane.dart';
import 'package:live_ffss/app/domain/models/race_format_configuration.dart';
import 'package:live_ffss/app/domain/models/race_format_detail.dart';
import 'package:live_ffss/app/domain/models/run.dart';
import 'package:live_ffss/app/domain/models/slot.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/module/competitions/controllers/race_structure_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockStorage extends Mock implements FlutterSecureStorage {}

class _MockRaceRepo extends Mock implements RaceRepository {}

class _MockClubRepo extends Mock implements ClubRepository {}

class _MockMeetingRepo extends Mock implements MeetingRepository {}

class _MockRaceFormatRepo extends Mock implements RaceFormatRepository {}

void main() {
  late _MockStorage storage;
  late _MockRaceRepo raceRepo;
  late _MockClubRepo clubRepo;
  late _MockMeetingRepo meetingRepo;
  late _MockRaceFormatRepo raceFormatRepo;
  late ProgrammeService service;
  late RaceStructureController controller;

  setUpAll(() {
    registerFallbackValue('');
    registerFallbackValue(const <Athlete>[]);
    registerFallbackValue(const <int>[]);
  });

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

  Athlete makeAthlete(int id, {int clubId = 0}) => Athlete(
        id: id,
        licenseeNumber: 'L$id',
        firstName: 'A$id',
        lastName: 'B$id',
        gender: Gender.male,
        year: 2000,
        nationalityCode: '',
        nationality: '',
        isValid: true,
        clubId: clubId,
      );

  Entry entry(int id, int categoryId, {List<Athlete> athletes = const []}) =>
      Entry(
        id: id,
        raceId: 500,
        category: Category(id: categoryId, name: 'Cat$categoryId'),
        status: 0,
        statusLabel: '',
        athletes: athletes,
      );

  // Race 500 has two category structures (Cadets=7, Juniors=8). Race 999 has one
  // (Cadets). Juniors is intentionally listed before Cadets to test sorting.
  const seed = CompetitionProgramme(
    competitionId: 42,
    structures: [
      EventStructure(
        raceId: 500,
        categoryId: 8,
        raceLabel: '100m',
        categoryLabel: 'Juniors',
        levels: [
          RoundLevel(
              type: RoundType.serie, races: [ProgrammeRace(id: 13, number: 1)]),
        ],
      ),
      EventStructure(
        raceId: 500,
        categoryId: 7,
        raceLabel: '100m',
        categoryLabel: 'Cadets',
        spotsPerRace: 8,
        levels: [
          RoundLevel(type: RoundType.serie, qualifiersPerRace: 4, races: [
            ProgrammeRace(id: 10, number: 1),
            ProgrammeRace(id: 11, number: 2),
          ]),
          RoundLevel(
              type: RoundType.finale,
              races: [ProgrammeRace(id: 12, number: 1)]),
        ],
      ),
      EventStructure(
        raceId: 999,
        categoryId: 7,
        raceLabel: 'Autre',
        categoryLabel: 'Cadets',
        levels: [
          RoundLevel(
              type: RoundType.serie, races: [ProgrammeRace(id: 20, number: 1)]),
        ],
      ),
    ],
  );

  setUp(() {
    storage = _MockStorage();
    raceRepo = _MockRaceRepo();
    clubRepo = _MockClubRepo();
    meetingRepo = _MockMeetingRepo();
    when(() => meetingRepo.getMeetings(any()))
        .thenAnswer((_) async => const []);
    when(() => meetingRepo.getLaneSeats(any()))
        .thenAnswer((_) async => const []);
    raceFormatRepo = _MockRaceFormatRepo();
    when(() => raceFormatRepo.getRaceFormats(any()))
        .thenAnswer((_) async => const []);
    when(() => clubRepo.getAthleteClubs(any(), any()))
        .thenAnswer((_) async => const <int, Club>{});
    when(() => storage.read(key: any(named: 'key')))
        .thenAnswer((_) async => jsonEncode(seed.toJson()));
    when(() =>
            storage.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((_) async {});
    service = ProgrammeService(storage);
    controller = RaceStructureController(
        service, raceRepo, clubRepo, meetingRepo, raceFormatRepo);
  });

  test('load filters structures to the race and sorts by category label',
      () async {
    when(() => raceRepo.getEntries(500)).thenAnswer((_) async => const []);
    await controller.load(race(500), competition);

    expect(controller.isLoading.value, isFalse);
    expect(controller.structures.map((s) => s.categoryLabel),
        ['Cadets', 'Juniors']);
    expect(controller.hasStructure, isTrue);
    expect(controller.showCategoryHeaders, isTrue);
  });

  test('entryCountFor counts entries grouped by category', () async {
    when(() => raceRepo.getEntries(500)).thenAnswer((_) async =>
        [entry(1, 7), entry(2, 7), entry(3, 7), entry(4, 8), entry(5, 8)]);
    await controller.load(race(500), competition);

    expect(controller.entryCountFor(7), 3);
    expect(controller.entryCountFor(8), 2);
    expect(controller.entryCountFor(99), 0);
  });

  test('a single-structure race hides category headers', () async {
    when(() => raceRepo.getEntries(999)).thenAnswer((_) async => const []);
    await controller.load(race(999), competition);

    expect(controller.structures.length, 1);
    expect(controller.showCategoryHeaders, isFalse);
    expect(controller.hasStructure, isTrue);
  });

  test('a race with no structure has hasStructure false', () async {
    when(() => raceRepo.getEntries(12345)).thenAnswer((_) async => const []);
    await controller.load(race(12345), competition);

    expect(controller.structures, isEmpty);
    expect(controller.hasStructure, isFalse);
  });

  test('a getEntries failure degrades to zero counts; structure still loads',
      () async {
    when(() => raceRepo.getEntries(500))
        .thenThrow(const NetworkException('boom'));
    await controller.load(race(500), competition);

    expect(controller.isLoading.value, isFalse);
    expect(controller.hasStructure, isTrue);
    expect(controller.entryCountFor(7), 0);
  });

  group('round tabs', () {
    test('one tab per category and round, in category then round order',
        () async {
      when(() => raceRepo.getEntries(500)).thenAnswer((_) async => const []);
      await controller.load(race(500), competition);

      expect(
        controller.tabs.map((t) => (t.categoryLabel, t.type)),
        [
          ('Cadets', RoundType.serie),
          ('Cadets', RoundType.finale),
          ('Juniors', RoundType.serie),
        ],
      );
    });

    test('only the opening round of each structure is drawable', () async {
      when(() => raceRepo.getEntries(500)).thenAnswer((_) async => const []);
      await controller.load(race(500), competition);

      expect(
        controller.tabs.map((t) => (t.categoryLabel, t.type, t.isFirstRound)),
        [
          ('Cadets', RoundType.serie, true),
          ('Cadets', RoundType.finale, false),
          // A later category opens its own chain, so its série is drawable too.
          ('Juniors', RoundType.serie, true),
        ],
      );
    });

    test('the first tab is selected once the structures load', () async {
      when(() => raceRepo.getEntries(500)).thenAnswer((_) async => const []);
      await controller.load(race(500), competition);

      expect(controller.selectedTabIndex.value, 0);
      expect(controller.selectedTab?.type, RoundType.serie);
      expect(controller.selectedTab?.categoryLabel, 'Cadets');
    });

    test('selectTab moves the selection', () async {
      when(() => raceRepo.getEntries(500)).thenAnswer((_) async => const []);
      await controller.load(race(500), competition);

      controller.selectTab(2);

      expect(controller.selectedTab?.categoryLabel, 'Juniors');
    });

    test('selectTab ignores an index outside the list', () async {
      when(() => raceRepo.getEntries(500)).thenAnswer((_) async => const []);
      await controller.load(race(500), competition);

      controller.selectTab(9);
      controller.selectTab(-1);

      expect(controller.selectedTabIndex.value, 0);
    });

    test('a reload with fewer tabs pulls the selection back in range',
        () async {
      when(() => raceRepo.getEntries(500)).thenAnswer((_) async => const []);
      when(() => raceRepo.getEntries(999)).thenAnswer((_) async => const []);
      await controller.load(race(500), competition);
      controller.selectTab(2);

      // Coming back from the structure editor, the race may hold fewer rounds.
      await controller.load(race(999), competition);

      expect(controller.selectedTabIndex.value, 0);
      expect(controller.selectedTab, isNotNull);
    });

    test('a race with no structure has no tab and no selection', () async {
      when(() => raceRepo.getEntries(12345)).thenAnswer((_) async => const []);
      await controller.load(race(12345), competition);

      expect(controller.tabs, isEmpty);
      expect(controller.selectedTab, isNull);
    });
  });

  group('RaceStructureController.athletesOf', () {
    test('translates the stored ids, in the order the draw left them',
        () async {
      when(() => raceRepo.getEntries(500)).thenAnswer((_) async => [
            entry(1, 7, athletes: [makeAthlete(31), makeAthlete(30)]),
          ]);
      await controller.load(race(500), competition);

      const drawn = ProgrammeRace(id: 1, number: 1, athleteIds: [31, 30]);

      expect(controller.athletesOf(drawn).map((a) => a.id), [31, 30]);
    });

    test('skips an id no entry accounts for', () async {
      when(() => raceRepo.getEntries(500)).thenAnswer((_) async => [
            entry(1, 7, athletes: [makeAthlete(31)]),
          ]);
      await controller.load(race(500), competition);

      const drawn = ProgrammeRace(id: 1, number: 1, athleteIds: [31, 999]);

      expect(controller.athletesOf(drawn).map((a) => a.id), [31]);
    });

    test('carries the resolved club so the row can show its logo', () async {
      when(() => raceRepo.getEntries(500)).thenAnswer((_) async => [
            entry(1, 7, athletes: [makeAthlete(31, clubId: 4)]),
          ]);
      when(() => clubRepo.getAthleteClubs(any(), any())).thenAnswer(
        (_) async => const {31: Club(id: 4, name: 'Nice', logoUrl: 'l')},
      );
      await controller.load(race(500), competition);

      const drawn = ProgrammeRace(id: 1, number: 1, athleteIds: [31]);

      expect(controller.athletesOf(drawn).single.club?.logoUrl, 'l');
    });

    test('a club failure still yields the athletes, without clubs', () async {
      when(() => raceRepo.getEntries(500)).thenAnswer((_) async => [
            entry(1, 7, athletes: [makeAthlete(31, clubId: 4)]),
          ]);
      when(() => clubRepo.getAthleteClubs(any(), any()))
          .thenThrow(const NetworkException('boom'));
      await controller.load(race(500), competition);

      const drawn = ProgrammeRace(id: 1, number: 1, athleteIds: [31]);

      expect(controller.athletesOf(drawn).single.club, isNull);
    });

    test('an undrawn race yields nothing', () async {
      when(() => raceRepo.getEntries(500)).thenAnswer((_) async => const []);
      await controller.load(race(500), competition);

      expect(controller.athletesOf(const ProgrammeRace(id: 1, number: 1)),
          isEmpty);
    });
  });

  group('RaceStructureController filtering', () {
    const s1 = ProgrammeRace(id: 1, number: 1, athleteIds: [31, 32]);
    const s2 = ProgrammeRace(id: 2, number: 2, athleteIds: [33]);

    Future<void> loadWith(List<Athlete> athletes) async {
      when(() => raceRepo.getEntries(500))
          .thenAnswer((_) async => [entry(1, 7, athletes: athletes)]);
      when(() => clubRepo.getAthleteClubs(any(), any())).thenAnswer(
        (_) async => {
          for (final a in athletes)
            if (a.clubId > 0) a.id: Club(id: a.clubId, name: 'Nice'),
        },
      );
      await controller.load(race(500), competition);
    }

    Athlete named(int id, String first, String last, {int clubId = 0}) =>
        makeAthlete(id, clubId: clubId)
            .copyWith(firstName: first, lastName: last);

    test('an empty filter hides nothing', () async {
      await loadWith(
          [named(31, 'Jean', 'Dupont'), named(33, 'Paul', 'Martin')]);

      expect(controller.matchingRaces(const [s1, s2]), [s1, s2]);
    });

    test('matches on the last name, whatever the case', () async {
      await loadWith(
          [named(31, 'Jean', 'Dupont'), named(33, 'Paul', 'Martin')]);

      controller.setFilter('DUPO');

      expect(controller.matchingRaces(const [s1, s2]), [s1]);
    });

    test('matches on the first name', () async {
      await loadWith(
          [named(31, 'Jean', 'Dupont'), named(33, 'Paul', 'Martin')]);

      controller.setFilter('paul');

      expect(controller.matchingRaces(const [s1, s2]), [s2]);
    });

    test('matches on the club', () async {
      await loadWith([
        named(31, 'Jean', 'Dupont', clubId: 4),
        named(33, 'Paul', 'Martin'),
      ]);

      controller.setFilter('nice');

      expect(controller.matchingRaces(const [s1, s2]), [s1]);
    });

    test('an accent typed or not typed still matches', () async {
      // A marshal on a beach types "noel", never "Noël".
      await loadWith([named(31, 'Rémy', 'Noël'), named(33, 'Paul', 'Martin')]);

      controller.setFilter('noel');
      expect(controller.matchingRaces(const [s1, s2]), [s1]);

      controller.setFilter('remy');
      expect(controller.matchingRaces(const [s1, s2]), [s1]);
    });

    test('a filter nobody matches hides every race', () async {
      await loadWith([named(31, 'Jean', 'Dupont')]);

      controller.setFilter('zzz');

      expect(controller.matchingRaces(const [s1, s2]), isEmpty);
    });
  });

  group('RaceStructureController expansion', () {
    const s1 = ProgrammeRace(id: 1, number: 1, athleteIds: [31]);
    const s2 = ProgrammeRace(id: 2, number: 2, athleteIds: [33]);

    test('everything starts collapsed', () {
      expect(controller.isExpanded(s1), isFalse);
    });

    test('toggling opens then closes one race', () {
      controller.toggleExpanded(s1);
      expect(controller.isExpanded(s1), isTrue);

      controller.toggleExpanded(s1);
      expect(controller.isExpanded(s1), isFalse);
    });

    test('expandAll opens the races it is given, collapseAll closes them', () {
      controller.expandAll(const [s1, s2]);
      expect(controller.isExpanded(s1), isTrue);
      expect(controller.isExpanded(s2), isTrue);

      controller.collapseAll();
      expect(controller.isExpanded(s1), isFalse);
    });

    test('allExpanded reports whether the button should collapse instead', () {
      expect(controller.allExpanded(const [s1, s2]), isFalse);

      controller.expandAll(const [s1, s2]);
      expect(controller.allExpanded(const [s1, s2]), isTrue);
    });

    test('a filtered race is open whatever the operator toggled', () async {
      // Surviving the filter is itself the reason to be open.
      controller.setFilter('anything');

      expect(controller.isExpanded(s1), isTrue);
    });
  });

  group('RaceStructureController results', () {
    test('reads a place out of the stored order', () async {
      when(() => raceRepo.getEntries(500)).thenAnswer((_) async => [
            entry(1, 7, athletes: [makeAthlete(31), makeAthlete(32)]),
          ]);
      await controller.load(race(500), competition);

      const drawn = ProgrammeRace(
        id: 1,
        number: 1,
        athleteIds: [31, 32],
        finishOrder: [
          [32],
          [31],
        ],
      );

      expect(controller.placeIn(drawn, makeAthlete(32)), 1);
      expect(controller.placeIn(drawn, makeAthlete(31)), 2);
    });

    test('an unscored race gives no place', () async {
      when(() => raceRepo.getEntries(500)).thenAnswer((_) async => const []);
      await controller.load(race(500), competition);

      const drawn = ProgrammeRace(id: 1, number: 1, athleteIds: [31]);

      expect(controller.placeIn(drawn, makeAthlete(31)), isNull);
      expect(controller.penaltyIn(drawn, makeAthlete(31)), isNull);
    });

    test('reads a withdrawal and its code', () async {
      when(() => raceRepo.getEntries(500)).thenAnswer((_) async => const []);
      await controller.load(race(500), competition);

      const drawn = ProgrammeRace(
        id: 1,
        number: 1,
        athleteIds: [31],
        penalties: [
          CoursePenalty(
            athleteId: 31,
            kind: CoursePenaltyKind.disqualified,
            code: '4.7',
          ),
        ],
      );

      final penalty = controller.penaltyIn(drawn, makeAthlete(31));

      expect(penalty?.kind, CoursePenaltyKind.disqualified);
      expect(penalty?.code, '4.7');
    });
  });

  group('les créneaux du tour', () {
    /// Le même déroulement, mais dont les tours connaissent leur partie FFSS
    /// et dont les séries retiennent la course qu'elles courent.
    CompetitionProgramme linked({
      int serieServerId = 39,
      List<int> runIds = const [25, 26],
    }) =>
        CompetitionProgramme(
          competitionId: 42,
          structures: [
            EventStructure(
              raceId: 500,
              categoryId: 7,
              raceLabel: '100m',
              categoryLabel: 'Cadets',
              levels: [
                RoundLevel(
                  type: RoundType.serie,
                  serverId: serieServerId,
                  races: [
                    ProgrammeRace(id: 10, number: 1, runId: runIds[0]),
                    ProgrammeRace(id: 11, number: 2, runId: runIds[1]),
                  ],
                ),
              ],
            ),
          ],
        );

    DateTime hhmm(String v) => DateFormat('HH:mm').parse(v);

    Run course(int id, String name, String begin, String end,
            {String site = 'OCEAN 1'}) =>
        Run(
          id: id,
          name: name,
          label: name,
          fullLabel: name,
          status: RunStatus.waiting,
          statusLabel: '',
          site: site,
          beginTime: hhmm(begin),
          endTime: hhmm(end),
        );

    /// Une réunion d'un créneau rattaché à la partie [partieId].
    Meeting meeting({int partieId = 39, List<Run> runs = const []}) => Meeting(
          id: 78,
          name: 'Réunion',
          description: '',
          date: DateTime(2026, 6, 13),
          beginHour: DateTime(2026, 6, 13, 8),
          endHour: DateTime(2026, 6, 13, 18),
          slots: [
            Slot(
              id: 66,
              name: 'Séries - 100m - Cadets',
              beginHour: hhmm('08:00'),
              endHour: hhmm('08:20'),
              raceFormatDetail: RaceFormatDetail(
                id: partieId,
                order: 1,
                label: '',
                fullLabel: '',
                levelLabel: '',
                level: 'heat',
                numberOfRun: 2,
                qualificationMethod: 'none',
                qualificationMethodLabel: '',
                spotsPerRace: 8,
                qualifyingSpots: 0,
              ),
              runs: runs,
            ),
          ],
        );

    final twoCourses = [
      course(25, 'Série 1', '08:00', '08:10'),
      course(26, 'Série 2', '08:10', '08:20'),
    ];

    Future<void> loadWith(
      CompetitionProgramme programme,
      List<Meeting> meetings,
    ) async {
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => jsonEncode(programme.toJson()));
      when(() => meetingRepo.getMeetings(42)).thenAnswer((_) async => meetings);
      when(() => raceRepo.getEntries(500)).thenAnswer((_) async => const []);
      controller = RaceStructureController(ProgrammeService(storage), raceRepo,
          clubRepo, meetingRepo, raceFormatRepo);
      await controller.load(race(500), competition);
    }

    RoundLevel serieLevel() => controller.structures.single.levels.single;

    test('le créneau du tour est celui rattaché à sa partie', () async {
      await loadWith(linked(), [meeting(runs: twoCourses)]);

      expect(controller.slotsForLevel(serieLevel()).map((s) => s.id), [66]);
    });

    test('un tour absent de FFSS n a aucun créneau', () async {
      await loadWith(linked(serieServerId: 0), [meeting(runs: twoCourses)]);

      expect(controller.slotsForLevel(serieLevel()), isEmpty);
    });

    // L'id retenu au moment de la création : c'est lui qui dit où et quand la
    // série part, sans rien deviner.
    test('une série liée retrouve sa course exactement', () async {
      await loadWith(linked(), [meeting(runs: twoCourses)]);

      final schedule =
          controller.scheduleFor(serieLevel(), serieLevel().races[1])!;

      expect(schedule.run.id, 26);
      expect(schedule.run.site, 'OCEAN 1');
      expect(schedule.isGuess, isFalse);
    });

    // Les courses créées à la main sur le site FFSS n'ont pu être liées à
    // rien : on rapproche par rang, mais on le dit.
    test('une série sans lien retombe sur la course de même rang, signalée',
        () async {
      await loadWith(linked(runIds: const [0, 0]), [meeting(runs: twoCourses)]);

      final schedule =
          controller.scheduleFor(serieLevel(), serieLevel().races[1])!;

      expect(schedule.run.id, 26);
      expect(schedule.isGuess, isTrue);
    });

    test('une série dont la course a été supprimée retombe sur le rang aussi',
        () async {
      await loadWith(
        linked(runIds: const [25, 999]),
        [meeting(runs: twoCourses)],
      );

      final schedule =
          controller.scheduleFor(serieLevel(), serieLevel().races[1])!;

      expect(schedule.run.id, 26);
      expect(schedule.isGuess, isTrue);
    });

    test('sans course, la série n a pas d horaire du tout', () async {
      await loadWith(linked(), [meeting()]);

      expect(controller.scheduleFor(serieLevel(), serieLevel().races.first),
          isNull);
    });

    // Le déroulement doit rester lisible hors ligne : les horaires sont un
    // complément, pas la raison d'être de cet écran.
    test('des réunions indisponibles laissent le déroulement s afficher',
        () async {
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => jsonEncode(linked().toJson()));
      when(() => meetingRepo.getMeetings(42))
          .thenThrow(const NetworkException('coupé'));
      when(() => raceRepo.getEntries(500)).thenAnswer((_) async => const []);
      controller = RaceStructureController(ProgrammeService(storage), raceRepo,
          clubRepo, meetingRepo, raceFormatRepo);

      await controller.load(race(500), competition);

      expect(controller.hasStructure, isTrue);
      expect(controller.slotsForLevel(serieLevel()), isEmpty);
      expect(controller.scheduleFor(serieLevel(), serieLevel().races.first),
          isNull);
    });
  });

  group('la vue se reconstruit depuis l API', () {
    DateTime hhmm(String v) => DateFormat('HH:mm').parse(v);

    RaceFormatConfiguration format({
      List<Category> categories = const [Category(id: 7, name: 'Cadets')],
      List<RaceFormatDetail> details = const [],
    }) =>
        RaceFormatConfiguration(
          id: 900,
          competitionId: 42,
          disciplineId: 1,
          label: '100m',
          fullLabel: '100m - Messieurs',
          gender: 'H',
          genderLabel: 'Messieurs',
          discipline: const Discipline(
            id: '1',
            name: '100m',
            speciality: 1,
            specialityLabel: 'Eau-plate',
          ),
          categories: categories,
          details: details,
        );

    const serverSerie = RaceFormatDetail(
      id: 39,
      order: 1,
      label: 'Série',
      fullLabel: '100m - Série',
      levelLabel: 'Série',
      level: 'heat',
      numberOfRun: 2,
      qualificationMethod: 'course',
      qualificationMethodLabel: 'Par course',
      spotsPerRace: 8,
      qualifyingSpots: 4,
    );

    Run course(int id, {List<Lane> lanes = const []}) => Run(
          id: id,
          name: 'Série',
          label: '',
          fullLabel: '',
          status: RunStatus.waiting,
          statusLabel: '',
          site: 'OCEAN 1',
          beginTime: hhmm('08:00'),
          endTime: hhmm('08:10'),
          lanes: lanes,
        );

    Meeting meetingWith(List<Run> runs, {int partieId = 39}) => Meeting(
          id: 78,
          name: 'Réunion',
          description: '',
          date: DateTime(2026, 6, 13),
          beginHour: DateTime(2026, 6, 13, 8),
          endHour: DateTime(2026, 6, 13, 18),
          slots: [
            Slot(
              id: 66,
              name: 'Séries',
              beginHour: hhmm('08:00'),
              endHour: hhmm('08:20'),
              raceFormatDetail: RaceFormatDetail(
                id: partieId,
                order: 1,
                label: '',
                fullLabel: '',
                levelLabel: '',
                level: 'heat',
                numberOfRun: runs.length,
                qualificationMethod: 'none',
                qualificationMethodLabel: '',
                spotsPerRace: 8,
                qualifyingSpots: 0,
              ),
              runs: runs,
            ),
          ],
        );

    Future<void> loadFresh({CompetitionProgramme? local}) async {
      when(() => storage.read(key: any(named: 'key'))).thenAnswer(
          (_) async => local == null ? null : jsonEncode(local.toJson()));
      when(() => raceRepo.getEntries(500)).thenAnswer((_) async => const []);
      controller = RaceStructureController(ProgrammeService(storage), raceRepo,
          clubRepo, meetingRepo, raceFormatRepo);
      await controller.load(race(500), competition);
    }

    // Le déroulement vit sur FFSS : un appareil qui ne l'a jamais édité doit
    // quand même voir les tours de l'épreuve.
    test('sans structure locale, les tours viennent du déroulement serveur',
        () async {
      when(() => raceFormatRepo.getRaceFormats(42)).thenAnswer((_) async => [
            format(details: const [serverSerie])
          ]);

      await loadFresh();

      final level = controller.structures.single.levels.single;
      expect(level.type, RoundType.serie);
      expect(level.serverId, 39);
      expect(level.races, hasLength(2));
      expect(level.spotsPerRace, 8);
      expect(controller.structures.single.categoryLabel, 'Cadets');
    });

    test('un déroulement d une autre épreuve ne sème rien ici', () async {
      when(() => raceFormatRepo.getRaceFormats(42)).thenAnswer((_) async => [
            format(details: const [serverSerie]).copyWith(disciplineId: 999),
          ]);

      await loadFresh();

      expect(controller.hasStructure, isFalse);
    });

    // Le tirage poussé par un premier appareil vit dans les places : un
    // second appareil le lit de là, engagement par engagement.
    test('la composition d un autre appareil arrive par les places', () async {
      when(() => raceFormatRepo.getRaceFormats(42)).thenAnswer((_) async => [
            format(details: const [serverSerie])
          ]);
      when(() => meetingRepo.getMeetings(42)).thenAnswer((_) async => [
            meetingWith([
              course(25, lanes: const [
                Lane(id: 71, number: 1),
                Lane(id: 72, number: 2),
              ]),
              course(26, lanes: const [Lane(id: 73, number: 1)]),
            ]),
          ]);
      when(() => meetingRepo.getLaneSeats([71, 72])).thenAnswer((_) async => [
            (laneId: 71, number: 1, entryId: 101, athleteIds: [11]),
            (laneId: 72, number: 2, entryId: 102, athleteIds: [12]),
          ]);
      when(() => meetingRepo.getLaneSeats([73])).thenAnswer((_) async => [
            (laneId: 73, number: 1, entryId: 103, athleteIds: [13, 14]),
          ]);

      await loadFresh();

      final races = controller.structures.single.levels.single.races;
      expect(races[0].entryIds, [101, 102]);
      expect(races[0].athleteIds, [11, 12]);
      expect(races[0].runId, 25);
      expect(races[1].entryIds, [103]);
      expect(races[1].athleteIds, [13, 14]);
      expect(races[1].runId, 26);
    });

    // Le serveur est la vérité partagée : un re-tirage poussé par l'autre
    // appareil remplace la copie locale — tant qu'elle ne porte pas de
    // résultats.
    test('une composition locale sans résultat s efface devant le serveur',
        () async {
      final local = CompetitionProgramme(
        competitionId: 42,
        nextLocalId: 100,
        structures: [
          EventStructure(
            raceId: 500,
            categoryId: 7,
            raceLabel: '100m',
            categoryLabel: 'Cadets',
            levels: [
              RoundLevel(type: RoundType.serie, serverId: 39, races: const [
                ProgrammeRace(
                    id: 1, number: 1, entryIds: [999], athleteIds: [99]),
              ]),
            ],
          ),
        ],
      );
      when(() => meetingRepo.getMeetings(42)).thenAnswer((_) async => [
            meetingWith([
              course(25, lanes: const [Lane(id: 71, number: 1)]),
            ]),
          ]);
      when(() => meetingRepo.getLaneSeats([71])).thenAnswer((_) async => [
            (laneId: 71, number: 1, entryId: 101, athleteIds: [11]),
          ]);

      await loadFresh(local: local);

      final drawn = controller.structures.single.levels.single.races.single;
      expect(drawn.entryIds, [101]);
      expect(drawn.athleteIds, [11]);
      expect(drawn.runId, 25);
    });

    test('une série qui porte des résultats n est jamais écrasée', () async {
      final local = CompetitionProgramme(
        competitionId: 42,
        nextLocalId: 100,
        structures: [
          EventStructure(
            raceId: 500,
            categoryId: 7,
            raceLabel: '100m',
            categoryLabel: 'Cadets',
            levels: [
              RoundLevel(type: RoundType.serie, serverId: 39, races: const [
                ProgrammeRace(
                  id: 1,
                  number: 1,
                  entryIds: [999],
                  athleteIds: [99],
                  finishOrder: [
                    [99]
                  ],
                ),
              ]),
            ],
          ),
        ],
      );
      when(() => meetingRepo.getMeetings(42)).thenAnswer((_) async => [
            meetingWith([
              course(25, lanes: const [Lane(id: 71, number: 1)]),
            ]),
          ]);
      when(() => meetingRepo.getLaneSeats([71])).thenAnswer((_) async => [
            (laneId: 71, number: 1, entryId: 101, athleteIds: [11]),
          ]);

      await loadFresh(local: local);

      final drawn = controller.structures.single.levels.single.races.single;
      expect(drawn.entryIds, [999]);
      expect(drawn.athleteIds, [99]);
    });

    // Des places encore vides (le tour vient d'être posé) ne disent rien du
    // tirage : la copie locale reste.
    test('des places vides n effacent pas un tirage local', () async {
      final local = CompetitionProgramme(
        competitionId: 42,
        nextLocalId: 100,
        structures: [
          EventStructure(
            raceId: 500,
            categoryId: 7,
            raceLabel: '100m',
            categoryLabel: 'Cadets',
            levels: [
              RoundLevel(type: RoundType.serie, serverId: 39, races: const [
                ProgrammeRace(
                    id: 1, number: 1, entryIds: [999], athleteIds: [99]),
              ]),
            ],
          ),
        ],
      );
      when(() => meetingRepo.getMeetings(42)).thenAnswer((_) async => [
            meetingWith([
              course(25, lanes: const [Lane(id: 71, number: 1)]),
            ]),
          ]);
      when(() => meetingRepo.getLaneSeats([71]))
          .thenAnswer((_) async => const []);

      await loadFresh(local: local);

      final drawn = controller.structures.single.levels.single.races.single;
      expect(drawn.entryIds, [999]);
    });

    // Une course ajoutée sur le site fédéral n'a aucune série locale où se
    // loger : sans création, sa composition reste invisible sur la tablette
    // alors que la course, elle, s'affiche.
    test('une course créée sur le site apporte sa composition avec elle',
        () async {
      when(() => raceFormatRepo.getRaceFormats(42)).thenAnswer((_) async => [
            format(details: const [serverSerie])
          ]);
      when(() => meetingRepo.getMeetings(42)).thenAnswer((_) async => [
            meetingWith([
              course(25, lanes: const [Lane(id: 71, number: 1)]),
              course(26, lanes: const [Lane(id: 72, number: 1)]),
              course(27, lanes: const [Lane(id: 73, number: 1)]),
            ]),
          ]);
      when(() => meetingRepo.getLaneSeats([71])).thenAnswer((_) async => [
            (laneId: 71, number: 1, entryId: 101, athleteIds: [11]),
          ]);
      when(() => meetingRepo.getLaneSeats([72])).thenAnswer((_) async => [
            (laneId: 72, number: 1, entryId: 102, athleteIds: [12]),
          ]);
      when(() => meetingRepo.getLaneSeats([73])).thenAnswer((_) async => [
            (laneId: 73, number: 1, entryId: 103, athleteIds: [13]),
          ]);

      // Le déroulement n'en déclare que deux : la troisième course est celle
      // que l'opérateur a ajoutée depuis le site.
      await loadFresh();

      final races = controller.structures.single.levels.single.races;
      expect(races, hasLength(3));
      expect(races[2].runId, 27);
      expect(races[2].entryIds, [103]);
      expect(races[2].athleteIds, [13]);
    });

    test('une course sans engagement ne crée pas de série fantôme', () async {
      when(() => raceFormatRepo.getRaceFormats(42)).thenAnswer((_) async => [
            format(details: const [serverSerie])
          ]);
      when(() => meetingRepo.getMeetings(42)).thenAnswer((_) async => [
            meetingWith([
              course(25, lanes: const [Lane(id: 71, number: 1)]),
              course(26, lanes: const [Lane(id: 72, number: 1)]),
              // Programmée mais jamais composée : rien à montrer, donc rien
              // à créer — sinon chaque course au programme ajouterait une
              // série vide au tour.
              course(27, lanes: const [Lane(id: 73, number: 1)]),
            ]),
          ]);
      when(() => meetingRepo.getLaneSeats([71])).thenAnswer((_) async => [
            (laneId: 71, number: 1, entryId: 101, athleteIds: [11]),
          ]);
      when(() => meetingRepo.getLaneSeats([72])).thenAnswer((_) async => [
            (laneId: 72, number: 1, entryId: 102, athleteIds: [12]),
          ]);
      when(() => meetingRepo.getLaneSeats([73]))
          .thenAnswer((_) async => const []);

      await loadFresh();

      expect(controller.structures.single.levels.single.races, hasLength(2));
    });

    test('hors ligne, la vue s affiche quand même', () async {
      when(() => raceFormatRepo.getRaceFormats(42))
          .thenThrow(const NetworkException('coupé'));

      await loadFresh();

      expect(controller.isLoading.value, isFalse);
      expect(controller.hasStructure, isFalse);
    });
  });

  group('les pilules ne montrent que l épreuve ouverte', () {
    const cadet = Category(id: 7, name: 'Cadets');
    const junior = Category(id: 8, name: 'Juniors');

    RaceFormatConfiguration formatFor(List<Category> categories) =>
        RaceFormatConfiguration(
          id: 900,
          competitionId: 42,
          disciplineId: 1,
          label: '100m',
          fullLabel: '100m - Messieurs',
          gender: 'H',
          genderLabel: 'Messieurs',
          discipline: const Discipline(
            id: '1',
            name: '100m',
            speciality: 1,
            specialityLabel: 'Eau-plate',
          ),
          categories: categories,
          details: const [
            RaceFormatDetail(
              id: 39,
              order: 1,
              label: 'Série',
              fullLabel: '',
              levelLabel: 'Série',
              level: 'heat',
              numberOfRun: 1,
              qualificationMethod: 'none',
              qualificationMethodLabel: '',
              spotsPerRace: 8,
              qualifyingSpots: 0,
            ),
          ],
        );

    Future<void> loadRace(
      Race r, {
      CompetitionProgramme? local,
      List<Category> formatCategories = const [cadet],
    }) async {
      when(() => storage.read(key: any(named: 'key'))).thenAnswer(
          (_) async => local == null ? null : jsonEncode(local.toJson()));
      when(() => raceRepo.getEntries(r.id)).thenAnswer((_) async => const []);
      when(() => raceFormatRepo.getRaceFormats(42))
          .thenAnswer((_) async => [formatFor(formatCategories)]);
      controller = RaceStructureController(ProgrammeService(storage), raceRepo,
          clubRepo, meetingRepo, raceFormatRepo);
      await controller.load(r, competition);
    }

    // Sur FFSS, « 90m Sprint Cadet » et « 90m Sprint Junior » sont deux
    // épreuves qui partagent discipline et genre. Un déroulement les couvre
    // toutes : semer ses catégories telles quelles collait les tours du
    // Junior sur l'épreuve Cadet.
    test('une catégorie que l épreuve ne court pas n est pas semée', () async {
      await loadRace(
        race(500).copyWith(categories: const [cadet]),
        formatCategories: const [junior],
      );

      expect(controller.structures, isEmpty);
      expect(controller.tabs, isEmpty);
    });

    test('seule l intersection avec les catégories de l épreuve est semée',
        () async {
      await loadRace(
        race(500).copyWith(categories: const [cadet]),
        formatCategories: const [cadet, junior],
      );

      expect(controller.structures.map((s) => s.categoryId), [7]);
      expect(controller.tabs, hasLength(1));
      expect(controller.tabs.single.categoryId, 7);
    });

    // Les appareils qui ont tourné avec la version fautive portent déjà des
    // structures parasites : la vue ne doit plus les montrer, sans exiger de
    // purge du stockage.
    test('une structure stockée hors des catégories de l épreuve est ignorée',
        () async {
      final polluted = CompetitionProgramme(
        competitionId: 42,
        nextLocalId: 100,
        structures: [
          EventStructure(
            raceId: 500,
            categoryId: 7,
            raceLabel: '100m',
            categoryLabel: 'Cadets',
            levels: [
              RoundLevel(type: RoundType.serie, serverId: 39, races: const [
                ProgrammeRace(id: 1, number: 1),
              ]),
            ],
          ),
          EventStructure(
            raceId: 500,
            categoryId: 8,
            raceLabel: '100m',
            categoryLabel: 'Juniors',
            levels: [
              RoundLevel(type: RoundType.finale, serverId: 40, races: const [
                ProgrammeRace(id: 2, number: 1),
              ]),
            ],
          ),
        ],
      );

      await loadRace(
        race(500).copyWith(categories: const [cadet]),
        local: polluted,
      );

      expect(controller.structures.map((s) => s.categoryId), [7]);
      expect(controller.tabs.map((t) => t.type), [RoundType.serie]);
    });

    // Une épreuve qui ne déclare aucune catégorie ne peut rien filtrer : on
    // n'invente pas une restriction qui masquerait un travail existant.
    test('une épreuve sans catégorie déclarée garde ce qui est stocké',
        () async {
      final stored = CompetitionProgramme(
        competitionId: 42,
        nextLocalId: 100,
        structures: [
          EventStructure(
            raceId: 500,
            categoryId: 7,
            raceLabel: '100m',
            categoryLabel: 'Cadets',
            levels: [
              RoundLevel(type: RoundType.serie, races: const [
                ProgrammeRace(id: 1, number: 1),
              ]),
            ],
          ),
        ],
      );

      await loadRace(race(500), local: stored, formatCategories: const []);

      expect(controller.structures.map((s) => s.categoryId), [7]);
    });
  });

  group('reload', () {
    // Le geste de rafraîchir montre déjà son propre indicateur : basculer
    // isLoading remplacerait la liste par un spinner sous le doigt.
    test('ne rebascule pas la vue en chargement', () async {
      when(() => raceRepo.getEntries(500)).thenAnswer((_) async => const []);
      await controller.load(race(500), competition);

      var sawLoading = false;
      final worker = ever<bool>(controller.isLoading, (v) {
        if (v) sawLoading = true;
      });
      await controller.reload();
      worker.dispose();

      expect(sawLoading, isFalse);
      expect(controller.isLoading.value, isFalse);
    });

    // C'est tout l'intérêt du geste : reprendre au serveur ce qu'un autre
    // appareil y a mis depuis l'ouverture de l'écran.
    test('reprend les épreuves, les réunions et les déroulements', () async {
      when(() => raceRepo.getEntries(500)).thenAnswer((_) async => const []);
      await controller.load(race(500), competition);

      await controller.reload();

      verify(() => raceRepo.getEntries(500)).called(2);
      verify(() => meetingRepo.getMeetings(42)).called(2);
      verify(() => raceFormatRepo.getRaceFormats(42)).called(2);
    });

    test('sans épreuve chargée, il ne se passe rien', () async {
      await controller.reload();

      verifyNever(() => raceRepo.getEntries(any()));
    });
  });

  group('les résultats de l API priment sur la copie locale', () {
    DateTime hhmm(String v) => DateFormat('HH:mm').parse(v);

    Run course(int id, {Heat? heat, List<Lane> lanes = const []}) => Run(
          id: id,
          name: 'Série',
          label: '',
          fullLabel: '',
          status: RunStatus.waiting,
          statusLabel: '',
          site: 'OCEAN 1',
          beginTime: hhmm('08:00'),
          endTime: hhmm('08:10'),
          lanes: lanes,
          heat: heat,
        );

    Meeting meetingWith(List<Run> runs) => Meeting(
          id: 78,
          name: 'Réunion',
          description: '',
          date: DateTime(2026, 6, 13),
          beginHour: DateTime(2026, 6, 13, 8),
          endHour: DateTime(2026, 6, 13, 18),
          slots: [
            Slot(
              id: 66,
              name: 'Séries',
              beginHour: hhmm('08:00'),
              endHour: hhmm('08:20'),
              raceFormatDetail: const RaceFormatDetail(
                id: 39,
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
              ),
              runs: runs,
            ),
          ],
        );

    /// Un tour local dont la série porte déjà un ordre d'arrivée : 11 devant 12.
    CompetitionProgramme localOrder() => const CompetitionProgramme(
          competitionId: 42,
          nextLocalId: 100,
          structures: [
            EventStructure(
              raceId: 500,
              categoryId: 7,
              raceLabel: '100m',
              categoryLabel: 'Cadets',
              levels: [
                RoundLevel(type: RoundType.serie, serverId: 39, races: [
                  ProgrammeRace(
                    id: 1,
                    number: 1,
                    runId: 25,
                    entryIds: [101, 102],
                    athleteIds: [11, 12],
                    finishOrder: [
                      [11],
                      [12]
                    ],
                  ),
                ]),
              ],
            ),
          ],
        );

    Future<void> loadWithResults(List<HeatResult> results) async {
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => jsonEncode(localOrder().toJson()));
      when(() => raceRepo.getEntries(500)).thenAnswer((_) async => const []);
      when(() => meetingRepo.getMeetings(42)).thenAnswer((_) async => [
            meetingWith([
              course(25,
                  heat: const Heat(id: 94369),
                  lanes: const [Lane(id: 71, number: 1)]),
            ]),
          ]);
      when(() => meetingRepo.getHeatResults(94369))
          .thenAnswer((_) async => results);
      when(() => meetingRepo.getLaneSeats([71])).thenAnswer((_) async => [
            (laneId: 71, number: 1, entryId: 101, athleteIds: [11]),
            (laneId: 71, number: 2, entryId: 102, athleteIds: [12]),
          ]);
      controller = RaceStructureController(ProgrammeService(storage), raceRepo,
          clubRepo, meetingRepo, raceFormatRepo);
      await controller.load(race(500), competition);
    }

    ProgrammeRace serieRace() =>
        controller.structures.single.levels.single.races.single;

    // Le serveur a le dernier mot : un classement corrigé sur un autre
    // appareil doit s'afficher ici, pas la copie locale devenue fausse.
    test('le rang affiché vient du résultat FFSS', () async {
      await loadWithResults(const [
        (entryId: 101, rank: 2, isDisqualified: false, complement: null),
        (entryId: 102, rank: 1, isDisqualified: false, complement: null),
      ]);

      expect(controller.placeInRace(serieRace(), 11), 2);
      expect(controller.placeInRace(serieRace(), 12), 1);
    });

    test('une disqualification FFSS sort l athlète du classement', () async {
      await loadWithResults(const [
        (entryId: 101, rank: null, isDisqualified: true, complement: 'DSQ'),
        (entryId: 102, rank: 1, isDisqualified: false, complement: null),
      ]);

      expect(controller.placeInRace(serieRace(), 11), isNull);
      final penalty = controller.penaltyInRace(serieRace(), 11);
      expect(penalty!.kind, CoursePenaltyKind.disqualified);
      expect(penalty.code, 'DSQ');
      expect(controller.penaltyInRace(serieRace(), 12), isNull);
    });

    // Sans résultat sur FFSS, l'écran continue de lire ce que l'appareil sait.
    test('sans résultat FFSS, le classement local est conservé', () async {
      await loadWithResults(const []);

      expect(controller.placeInRace(serieRace(), 11), 1);
      expect(controller.placeInRace(serieRace(), 12), 2);
    });

    test('une course sans série ne déclenche aucune lecture', () async {
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => jsonEncode(localOrder().toJson()));
      when(() => raceRepo.getEntries(500)).thenAnswer((_) async => const []);
      when(() => meetingRepo.getMeetings(42)).thenAnswer((_) async => [
            meetingWith([course(25)])
          ]);
      controller = RaceStructureController(ProgrammeService(storage), raceRepo,
          clubRepo, meetingRepo, raceFormatRepo);

      await controller.load(race(500), competition);

      verifyNever(() => meetingRepo.getHeatResults(any()));
      expect(controller.placeInRace(serieRace(), 11), 1);
    });
  });

  group('la jointure avec le serveur se répare toute seule', () {
    RaceFormatConfiguration formatWith(List<RaceFormatDetail> details) =>
        RaceFormatConfiguration(
          id: 900,
          competitionId: 42,
          disciplineId: 1,
          label: '100m',
          fullLabel: '100m',
          gender: 'H',
          genderLabel: 'Messieurs',
          discipline: const Discipline(
            id: '1',
            name: '100m',
            speciality: 1,
            specialityLabel: 'Eau-plate',
          ),
          categories: const [Category(id: 7, name: 'Cadets')],
          details: details,
        );

    const serverSerie = RaceFormatDetail(
      id: 63,
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

    /// Une structure locale accrochée à une partie que FFSS n'a plus.
    CompetitionProgramme stale() => const CompetitionProgramme(
          competitionId: 42,
          nextLocalId: 100,
          structures: [
            EventStructure(
              raceId: 500,
              categoryId: 7,
              raceLabel: '100m',
              categoryLabel: 'Cadets',
              levels: [
                RoundLevel(type: RoundType.serie, serverId: 39, races: [
                  ProgrammeRace(id: 1, number: 1, athleteIds: [11]),
                ]),
              ],
            ),
          ],
        );

    // Le second appareil ne voyait rien : ses tours pointaient des parties
    // disparues, donc aucun créneau ne correspondait et l'import des
    // compositions n'avait aucune course où aller chercher.
    test('un serverId périmé adopte celui du serveur', () async {
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => jsonEncode(stale().toJson()));
      when(() => raceRepo.getEntries(500)).thenAnswer((_) async => const []);
      when(() => raceFormatRepo.getRaceFormats(42)).thenAnswer((_) async => [
            formatWith(const [serverSerie])
          ]);
      controller = RaceStructureController(ProgrammeService(storage), raceRepo,
          clubRepo, meetingRepo, raceFormatRepo);

      await controller.load(
          race(500).copyWith(
            categories: const [Category(id: 7, name: 'Cadets')],
          ),
          competition);

      expect(controller.structures.single.levels.single.serverId, 63);
      // Le tirage déjà fait sur cet appareil n'est pas emporté par la réparation.
      expect(controller.structures.single.levels.single.races.single.athleteIds,
          [11]);
    });

    test('sans déroulement serveur, la structure locale est laissée intacte',
        () async {
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => jsonEncode(stale().toJson()));
      when(() => raceRepo.getEntries(500)).thenAnswer((_) async => const []);
      when(() => raceFormatRepo.getRaceFormats(42))
          .thenAnswer((_) async => const []);
      controller = RaceStructureController(ProgrammeService(storage), raceRepo,
          clubRepo, meetingRepo, raceFormatRepo);

      await controller.load(
          race(500).copyWith(
            categories: const [Category(id: 7, name: 'Cadets')],
          ),
          competition);

      expect(controller.structures.single.levels.single.serverId, 39);
    });
  });
}
