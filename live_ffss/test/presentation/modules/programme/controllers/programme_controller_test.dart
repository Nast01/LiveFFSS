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
import 'package:live_ffss/app/module/programme/controllers/programme_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockRaceRepo extends Mock implements RaceRepository {}

class _MockStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockRaceRepo raceRepo;
  late ProgrammeService service;
  late ProgrammeController controller;

  setUpAll(() => registerFallbackValue(''));

  const cadets = Category(id: 7, name: 'Cadets');
  const juniors = Category(id: 8, name: 'Juniors');
  const seniors = Category(id: 9, name: 'Seniors');

  Race race(int id, String name, List<Category> cats) => Race(
        id: id,
        name: name,
        nameEnglish: name,
        distance: 100,
        gender: Gender.mixed,
        athletesPerTeam: 1,
        specialityId: 1,
        specialityLabel: '',
        disciplineId: 1,
        isEligibleToNationalRecord: false,
        categories: cats,
      );

  Entry entry(int id, int raceId, Category cat) => Entry(
        id: id,
        raceId: raceId,
        category: cat,
        status: 0,
        statusLabel: '',
      );

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

  late _MockStorage storage;

  setUp(() {
    raceRepo = _MockRaceRepo();
    storage = _MockStorage();
    when(() => storage.read(key: any(named: 'key')))
        .thenAnswer((_) async => null);
    when(() => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'))).thenAnswer((_) async {});
    service = ProgrammeService(storage);
    controller = ProgrammeController(raceRepo, service);
  });

  test('builds one row per épreuve × category with its entry count', () async {
    when(() => raceRepo.getRaces(42))
        .thenAnswer((_) async => [race(100, '100m', [cadets, juniors])]);
    when(() => raceRepo.getEntries(100)).thenAnswer((_) async => [
          entry(1, 100, cadets),
          entry(2, 100, cadets),
          entry(3, 100, juniors),
        ]);

    await controller.load(competition);

    expect(controller.rows.length, 2);
    final cadetsRow = controller.rows.firstWhere((r) => r.categoryId == 7);
    expect(cadetsRow.entryCount, 2);
    expect(cadetsRow.raceLabel, '100m');
    expect(cadetsRow.structure, isNull);
    expect(controller.isLoading.value, isFalse);
  });

  test('sets hasError when the repository throws AppException', () async {
    when(() => raceRepo.getRaces(42))
        .thenThrow(const NetworkException('offline'));

    await controller.load(competition);

    expect(controller.hasError.value, isTrue);
    expect(controller.rows, isEmpty);
    expect(controller.isLoading.value, isFalse);
  });

  test('changeTab updates the tab index', () {
    controller.changeTab(1);
    expect(controller.currentTabIndex.value, 1);
  });

  test(
      'rows are re-derived when the stored programme changes after load()',
      () async {
    when(() => raceRepo.getRaces(42))
        .thenAnswer((_) async => [race(100, '100m', [cadets])]);
    when(() => raceRepo.getEntries(100))
        .thenAnswer((_) async => [entry(1, 100, cadets)]);

    // onInit() registers the ever() worker that watches the stored
    // programme; production code relies on GetX's Get.put to trigger it.
    controller.onInit();
    await controller.load(competition);
    expect(controller.rows.single.structure, isNull);

    const structure = EventStructure(
      raceId: 100,
      categoryId: 7,
      raceLabel: '100m',
      categoryLabel: 'Cadets',
    );
    await service.save(
      const CompetitionProgramme(competitionId: 42, structures: [structure]),
    );

    expect(controller.rows.single.structure, isNotNull);
    expect(controller.rows.single.structure!.raceId, 100);
    // Everything else on the row is preserved, not refetched.
    expect(controller.rows.single.entryCount, 1);
    expect(controller.rows.single.raceLabel, '100m');
  });

  test(
      'generateAllDefaults fills only the undefined rows and persists once',
      () async {
    when(() => raceRepo.getRaces(42)).thenAnswer(
      (_) async => [race(100, '100m', [cadets, juniors, seniors])],
    );
    when(() => raceRepo.getEntries(100)).thenAnswer((_) async => [
          entry(1, 100, cadets),
          entry(2, 100, juniors),
          entry(3, 100, seniors),
        ]);

    const existing = EventStructure(
      raceId: 100,
      categoryId: 8, // juniors: already defined
      raceLabel: '100m',
      categoryLabel: 'Juniors',
      levels: [
        RoundLevel(type: RoundType.finale, races: [
          ProgrammeRace(id: 1, number: 1),
        ]),
      ],
    );
    when(() => storage.read(key: 'programme_42')).thenAnswer(
      (_) async => jsonEncode(
        const CompetitionProgramme(
          competitionId: 42,
          nextLocalId: 2,
          structures: [existing],
        ).toJson(),
      ),
    );

    controller.onInit();
    await controller.load(competition);

    final juniorsBefore =
        controller.rows.firstWhere((r) => r.categoryId == 8);
    expect(juniorsBefore.structure, existing);
    final cadetsBefore = controller.rows.firstWhere((r) => r.categoryId == 7);
    expect(cadetsBefore.structure, isNull);

    await controller.generateAllDefaults();

    final cadetsRow = controller.rows.firstWhere((r) => r.categoryId == 7);
    final seniorsRow = controller.rows.firstWhere((r) => r.categoryId == 9);
    final juniorsRow = controller.rows.firstWhere((r) => r.categoryId == 8);

    expect(cadetsRow.structure, isNotNull);
    expect(seniorsRow.structure, isNotNull);
    expect(juniorsRow.structure, existing); // left untouched

    verify(() => storage.write(
        key: 'programme_42', value: any(named: 'value'))).called(1);
  });
}
