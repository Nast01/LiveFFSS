import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
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

void main() {
  late _MockStorage storage;
  late _MockRaceRepo raceRepo;
  late ProgrammeService service;
  late RaceStructureController controller;

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

  Entry entry(int id, int categoryId) => Entry(
        id: id,
        raceId: 500,
        category: Category(id: categoryId, name: 'Cat$categoryId'),
        status: 0,
        statusLabel: '',
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
          RoundLevel(type: RoundType.serie, races: [ProgrammeRace(id: 13, number: 1)]),
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
          RoundLevel(type: RoundType.finale, races: [ProgrammeRace(id: 12, number: 1)]),
        ],
      ),
      EventStructure(
        raceId: 999,
        categoryId: 7,
        raceLabel: 'Autre',
        categoryLabel: 'Cadets',
        levels: [
          RoundLevel(type: RoundType.serie, races: [ProgrammeRace(id: 20, number: 1)]),
        ],
      ),
    ],
  );

  setUp(() {
    storage = _MockStorage();
    raceRepo = _MockRaceRepo();
    when(() => storage.read(key: any(named: 'key')))
        .thenAnswer((_) async => jsonEncode(seed.toJson()));
    when(() => storage.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((_) async {});
    service = ProgrammeService(storage);
    controller = RaceStructureController(service, raceRepo);
  });

  test('load filters structures to the race and sorts by category label', () async {
    when(() => raceRepo.getEntries(500)).thenAnswer((_) async => const []);
    await controller.load(race(500), competition);

    expect(controller.isLoading.value, isFalse);
    expect(controller.structures.map((s) => s.categoryLabel), ['Cadets', 'Juniors']);
    expect(controller.hasStructure, isTrue);
    expect(controller.showCategoryHeaders, isTrue);
  });

  test('entryCountFor counts entries grouped by category', () async {
    when(() => raceRepo.getEntries(500)).thenAnswer(
        (_) async => [entry(1, 7), entry(2, 7), entry(3, 7), entry(4, 8), entry(5, 8)]);
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

  test('a getEntries failure degrades to zero counts; structure still loads', () async {
    when(() => raceRepo.getEntries(500)).thenThrow(const NetworkException('boom'));
    await controller.load(race(500), competition);

    expect(controller.isLoading.value, isFalse);
    expect(controller.hasStructure, isTrue);
    expect(controller.entryCountFor(7), 0);
  });
}
