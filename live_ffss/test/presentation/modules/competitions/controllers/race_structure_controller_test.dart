import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/category.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/entry.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/race.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/module/competitions/controllers/race_structure_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockStorage extends Mock implements FlutterSecureStorage {}

class _MockRaceRepo extends Mock implements RaceRepository {}

class _MockClubRepo extends Mock implements ClubRepository {}

void main() {
  late _MockStorage storage;
  late _MockRaceRepo raceRepo;
  late _MockClubRepo clubRepo;
  late ProgrammeService service;
  late RaceStructureController controller;

  setUpAll(() {
    registerFallbackValue('');
    registerFallbackValue(const <Athlete>[]);
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
    when(() => clubRepo.getAthleteClubs(any(), any()))
        .thenAnswer((_) async => const <int, Club>{});
    when(() => storage.read(key: any(named: 'key')))
        .thenAnswer((_) async => jsonEncode(seed.toJson()));
    when(() =>
            storage.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((_) async {});
    service = ProgrammeService(storage);
    controller = RaceStructureController(service, raceRepo, clubRepo);
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
}
