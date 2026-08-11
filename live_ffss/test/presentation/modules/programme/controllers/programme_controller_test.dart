import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/race_format_repository.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/domain/models/discipline.dart';
import 'package:live_ffss/app/domain/models/race_format_configuration.dart';
import 'package:live_ffss/app/domain/models/race_format_detail.dart';
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
import 'package:live_ffss/app/presentation/shared/ui_message.dart';
import 'package:mocktail/mocktail.dart';

class _MockRaceRepo extends Mock implements RaceRepository {}

class _MockStorage extends Mock implements FlutterSecureStorage {}

class _MockRaceFormatRepo extends Mock implements RaceFormatRepository {}

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
  late _MockRaceFormatRepo raceFormatRepo;

  setUp(() {
    raceRepo = _MockRaceRepo();
    storage = _MockStorage();
    when(() => storage.read(key: any(named: 'key')))
        .thenAnswer((_) async => null);
    when(() =>
            storage.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((_) async {});
    service = ProgrammeService(storage);
    raceFormatRepo = _MockRaceFormatRepo();
    when(() => raceFormatRepo.getRaceFormats(any()))
        .thenAnswer((_) async => const []);
    controller = ProgrammeController(raceRepo, service, raceFormatRepo);
  });

  test('builds one row per épreuve × category with its entry count', () async {
    when(() => raceRepo.getRaces(42)).thenAnswer((_) async => [
          race(100, '100m', [cadets, juniors])
        ]);
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

  group('genderForRace', () {
    test('reports the gender of the épreuve behind a structure', () async {
      when(() => raceRepo.getRaces(42)).thenAnswer((_) async => [
            race(100, '100m', [cadets]).copyWith(gender: Gender.female),
          ]);
      when(() => raceRepo.getEntries(100))
          .thenAnswer((_) async => [entry(1, 100, cadets)]);

      await controller.load(competition);

      expect(controller.genderForRace(100), Gender.female);
    });

    test('an épreuve it never loaded is unknown, not a wrong guess', () {
      expect(controller.genderForRace(999), Gender.unknown);
    });
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

  test('rows are re-derived when the stored programme changes after load()',
      () async {
    when(() => raceRepo.getRaces(42)).thenAnswer((_) async => [
          race(100, '100m', [cadets])
        ]);
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

  test('generateAllDefaults fills only the undefined rows and persists once',
      () async {
    when(() => raceRepo.getRaces(42)).thenAnswer(
      (_) async => [
        race(100, '100m', [cadets, juniors, seniors])
      ],
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

    final juniorsBefore = controller.rows.firstWhere((r) => r.categoryId == 8);
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

    verify(() => storage.write(key: 'programme_42', value: any(named: 'value')))
        .called(1);
  });

  group('joining déroulements to rows', () {
    /// A déroulement is keyed by (discipline, gender) and fans out over its
    /// categories; its own Id lives in a different namespace from Race.id, so
    /// that triple is the only key the two sides share.
    RaceFormatConfiguration format({
      required int id,
      required int disciplineId,
      required String gender,
      required List<Category> categories,
      List<RaceFormatDetail> details = const [],
    }) =>
        RaceFormatConfiguration(
          id: id,
          competitionId: 42,
          disciplineId: disciplineId,
          label: 'Nage',
          fullLabel: 'Nage',
          gender: gender,
          genderLabel: gender,
          discipline: const Discipline(
              id: '5', name: 'Nage', speciality: 1, specialityLabel: 'Côtier'),
          categories: categories,
          details: details,
        );

    const semi = RaceFormatDetail(
      id: 32,
      order: 1,
      label: 'Demi-finale',
      fullLabel: 'Demi-finale',
      levelLabel: 'Demi-finale',
      level: 'semi',
      numberOfRun: 2,
      qualificationMethod: 'none',
      qualificationMethodLabel: 'N/A',
      spotsPerRace: 18,
      qualifyingSpots: 0,
    );

    Future<void> loadWithFormats(List<RaceFormatConfiguration> formats) async {
      // Race 100 is Gender.mixed (see the `race` helper) → gender code "M".
      when(() => raceRepo.getRaces(42)).thenAnswer((_) async => [
            race(100, '100m', [cadets, juniors])
          ]);
      when(() => raceRepo.getEntries(100))
          .thenAnswer((_) async => [entry(1, 100, cadets)]);
      when(() => raceFormatRepo.getRaceFormats(42))
          .thenAnswer((_) async => formats);
      await controller.load(competition);
    }

    test('attaches the déroulement to the matching épreuve × category',
        () async {
      await loadWithFormats([
        format(
          id: 362,
          disciplineId: 1,
          gender: 'M',
          categories: const [cadets],
          details: const [semi],
        ),
      ]);

      final cadetsRow = controller.rows.firstWhere((r) => r.categoryId == 7);
      final juniorsRow = controller.rows.firstWhere((r) => r.categoryId == 8);
      expect(cadetsRow.raceFormat?.id, 362);
      expect(cadetsRow.hasRaceFormat, isTrue);
      // Same discipline and gender, but the déroulement does not cover this
      // category — no match.
      expect(juniorsRow.raceFormat, isNull);
      expect(juniorsRow.hasRaceFormat, isFalse);
    });

    test('a déroulement covering several categories matches each of them',
        () async {
      await loadWithFormats([
        format(
            id: 362,
            disciplineId: 1,
            gender: 'M',
            categories: const [cadets, juniors]),
      ]);

      expect(controller.rows.every((r) => r.raceFormat?.id == 362), isTrue);
    });

    test('a mismatched gender does not match', () async {
      await loadWithFormats([
        format(
            id: 362, disciplineId: 1, gender: 'F', categories: const [cadets]),
      ]);

      expect(controller.rows.every((r) => r.raceFormat == null), isTrue);
    });

    test('a mismatched discipline does not match', () async {
      await loadWithFormats([
        format(
            id: 362, disciplineId: 99, gender: 'M', categories: const [cadets]),
      ]);

      expect(controller.rows.every((r) => r.raceFormat == null), isTrue);
    });

    test('a failing déroulement call still renders the rows', () async {
      when(() => raceRepo.getRaces(42)).thenAnswer((_) async => [
            race(100, '100m', [cadets])
          ]);
      when(() => raceRepo.getEntries(100))
          .thenAnswer((_) async => [entry(1, 100, cadets)]);
      when(() => raceFormatRepo.getRaceFormats(42))
          .thenThrow(const NetworkException('offline'));

      await controller.load(competition);

      expect(controller.hasError.value, isFalse);
      expect(controller.rows.single.raceFormat, isNull);
    });
  });

  group('reload (pull to refresh)', () {
    Future<void> loadOnce() async {
      when(() => raceRepo.getRaces(42)).thenAnswer((_) async => [
            race(100, '100m', [cadets])
          ]);
      when(() => raceRepo.getEntries(100))
          .thenAnswer((_) async => [entry(1, 100, cadets)]);
      await controller.load(competition);
    }

    test('re-fetches races, entries and déroulements', () async {
      await loadOnce();
      clearInteractions(raceRepo);
      clearInteractions(raceFormatRepo);

      await controller.reload();

      verify(() => raceRepo.getRaces(42)).called(1);
      verify(() => raceRepo.getEntries(100)).called(1);
      verify(() => raceFormatRepo.getRaceFormats(42)).called(1);
    });

    test('never raises isLoading, so the list is not swapped for a spinner',
        () async {
      await loadOnce();
      var sawLoading = false;
      final worker = ever<bool>(controller.isLoading, (v) {
        if (v) sawLoading = true;
      });

      await controller.reload();

      worker.dispose();
      expect(sawLoading, isFalse);
      expect(controller.isLoading.value, isFalse);
    });

    test('picks up rows that appeared server-side', () async {
      await loadOnce();
      when(() => raceRepo.getRaces(42)).thenAnswer((_) async => [
            race(100, '100m', [cadets, juniors])
          ]);

      await controller.reload();

      expect(controller.rows, hasLength(2));
    });

    test('a failure surfaces the error state', () async {
      await loadOnce();
      when(() => raceRepo.getRaces(42))
          .thenThrow(const NetworkException('offline'));

      await controller.reload();

      expect(controller.hasError.value, isTrue);
    });

    test('does nothing when no competition has been loaded yet', () async {
      await controller.reload();

      verifyNever(() => raceRepo.getRaces(any()));
    });
  });

  group('re-adopting server rounds on refresh', () {
    const semi = RaceFormatDetail(
      id: 32,
      order: 1,
      label: 'Demi-finale',
      fullLabel: 'Demi-finale',
      levelLabel: 'Demi-finale',
      level: 'semi',
      numberOfRun: 2,
      qualificationMethod: 'none',
      qualificationMethodLabel: 'N/A',
      spotsPerRace: 18,
      qualifyingSpots: 0,
    );

    /// Race 100 is Gender.mixed with disciplineId 1 (see the `race` helper).
    RaceFormatConfiguration formatWithRounds() => const RaceFormatConfiguration(
          id: 362,
          competitionId: 42,
          disciplineId: 1,
          label: 'Nage',
          fullLabel: 'Nage',
          gender: 'M',
          genderLabel: 'Mixte',
          discipline: Discipline(
              id: '1', name: 'Nage', speciality: 1, specialityLabel: 'Côtier'),
          categories: [cadets],
          details: [semi],
        );

    Future<void> loadWithStoredStructure(EventStructure stored) async {
      when(() => raceRepo.getRaces(42)).thenAnswer((_) async => [
            race(100, '100m', [cadets])
          ]);
      when(() => raceRepo.getEntries(100))
          .thenAnswer((_) async => [entry(1, 100, cadets)]);
      when(() => raceFormatRepo.getRaceFormats(42))
          .thenAnswer((_) async => [formatWithRounds()]);
      when(() => storage.read(key: 'programme_42')).thenAnswer(
        (_) async => jsonEncode(
          CompetitionProgramme(competitionId: 42, structures: [stored])
              .toJson(),
        ),
      );
      controller.onInit();
      await controller.load(competition);
    }

    EventStructure storedStructure({List<RoundLevel> levels = const []}) =>
        EventStructure(
          raceId: 100,
          categoryId: 7,
          raceLabel: '100m',
          categoryLabel: 'Cadets',
          levels: levels,
        );

    test('a structure emptied of its rounds gets the server ones back',
        () async {
      // The exact case: the operator deleted every round, and the structure
      // used to stay empty for good.
      await loadWithStoredStructure(storedStructure());

      final levels = controller.rows.single.structure!.levels;
      expect(levels, hasLength(1));
      expect(levels.single.type, RoundType.demi);
      expect(levels.single.races, hasLength(2));
      expect(levels.single.spotsPerRace, 18);
      expect(levels.single.serverId, 32);
    });

    test('a structure that still holds rounds is left untouched', () async {
      await loadWithStoredStructure(storedStructure(levels: const [
        RoundLevel(type: RoundType.finale, spotsPerRace: 99),
      ]));

      final levels = controller.rows.single.structure!.levels;
      expect(levels.map((l) => l.type), [RoundType.finale]);
      expect(levels.single.spotsPerRace, 99);
    });

    test('no structure is created for an épreuve that has none locally',
        () async {
      when(() => raceRepo.getRaces(42)).thenAnswer((_) async => [
            race(100, '100m', [cadets])
          ]);
      when(() => raceRepo.getEntries(100))
          .thenAnswer((_) async => [entry(1, 100, cadets)]);
      when(() => raceFormatRepo.getRaceFormats(42))
          .thenAnswer((_) async => [formatWithRounds()]);

      controller.onInit();
      await controller.load(competition);

      // Opening the editor or "Générer tout" creates structures — a refresh
      // must not silently fill the programme.
      expect(controller.rows.single.structure, isNull);
      expect(service.current.value!.structures, isEmpty);
    });

    test('nothing to adopt means no write at all', () async {
      await loadWithStoredStructure(storedStructure(levels: const [
        RoundLevel(type: RoundType.finale),
      ]));
      clearInteractions(storage);

      await controller.reload();

      verifyNever(
          () => storage.write(key: 'programme_42', value: any(named: 'value')));
    });
  });

  group('creating déroulements on the server', () {
    Race raceOf(int id, int disciplineId, Gender gender, List<Category> cats) =>
        Race(
          id: id,
          name: 'R$id',
          nameEnglish: 'R$id',
          distance: 100,
          gender: gender,
          athletesPerTeam: 1,
          specialityId: 1,
          specialityLabel: '',
          disciplineId: disciplineId,
          isEligibleToNationalRecord: false,
          categories: cats,
        );

    Future<void> loadRaces(List<Race> races) async {
      when(() => raceRepo.getRaces(42)).thenAnswer((_) async => races);
      for (final r in races) {
        when(() => raceRepo.getEntries(r.id))
            .thenAnswer((_) async => [entry(1, r.id, r.categories.first)]);
      }
      await controller.load(competition);
    }

    setUp(() {
      when(() => raceFormatRepo.submitRaceFormat(
            competitionId: any(named: 'competitionId'),
            disciplineId: any(named: 'disciplineId'),
            gender: any(named: 'gender'),
            categoryIds: any(named: 'categoryIds'),
            id: any(named: 'id'),
          )).thenAnswer((_) async => 366);
    });

    test('submits discipline, gender code and every category of the group',
        () async {
      await loadRaces([
        raceOf(100, 8, Gender.male, [cadets]),
        raceOf(101, 8, Gender.male, [juniors]),
      ]);

      await controller.createMissingRaceFormats();

      final call = verify(() => raceFormatRepo.submitRaceFormat(
            competitionId: captureAny(named: 'competitionId'),
            disciplineId: captureAny(named: 'disciplineId'),
            gender: captureAny(named: 'gender'),
            categoryIds: captureAny(named: 'categoryIds'),
            id: captureAny(named: 'id'),
          )).captured;
      expect(call[0], 42);
      expect(call[1], 8);
      expect(call[2], 'H'); // Gender.male → "H", not "M"
      expect(call[3], [7, 8]);
      expect(call[4], isNull); // nothing existed → a creation
    });

    test('one call per discipline × gender, not one per category', () async {
      await loadRaces([
        raceOf(100, 8, Gender.male, [cadets]),
        raceOf(101, 8, Gender.male, [juniors]),
        raceOf(102, 8, Gender.female, [cadets]),
        raceOf(103, 13, Gender.male, [cadets]),
      ]);

      await controller.createMissingRaceFormats();

      verify(() => raceFormatRepo.submitRaceFormat(
            competitionId: any(named: 'competitionId'),
            disciplineId: any(named: 'disciplineId'),
            gender: any(named: 'gender'),
            categoryIds: any(named: 'categoryIds'),
            id: any(named: 'id'),
          )).called(3);
    });

    test('reloads afterwards so the new server state reaches the list',
        () async {
      await loadRaces([
        raceOf(100, 8, Gender.male, [cadets])
      ]);
      clearInteractions(raceFormatRepo);
      when(() => raceFormatRepo.getRaceFormats(any()))
          .thenAnswer((_) async => const []);
      when(() => raceFormatRepo.submitRaceFormat(
            competitionId: any(named: 'competitionId'),
            disciplineId: any(named: 'disciplineId'),
            gender: any(named: 'gender'),
            categoryIds: any(named: 'categoryIds'),
            id: any(named: 'id'),
          )).thenAnswer((_) async => 366);

      await controller.createMissingRaceFormats();

      verify(() => raceFormatRepo.getRaceFormats(42)).called(1);
      expect(controller.message.value, isA<UiMessageSuccess>());
    });

    test('a rejected submission surfaces an error and does not claim success',
        () async {
      await loadRaces([
        raceOf(100, 8, Gender.male, [cadets])
      ]);
      when(() => raceFormatRepo.submitRaceFormat(
            competitionId: any(named: 'competitionId'),
            disciplineId: any(named: 'disciplineId'),
            gender: any(named: 'gender'),
            categoryIds: any(named: 'categoryIds'),
            id: any(named: 'id'),
          )).thenAnswer((_) async => 0);

      await controller.createMissingRaceFormats();

      expect(controller.message.value, isA<UiMessageError>());
    });

    test('a network failure is reported, not swallowed', () async {
      await loadRaces([
        raceOf(100, 8, Gender.male, [cadets])
      ]);
      when(() => raceFormatRepo.submitRaceFormat(
            competitionId: any(named: 'competitionId'),
            disciplineId: any(named: 'disciplineId'),
            gender: any(named: 'gender'),
            categoryIds: any(named: 'categoryIds'),
            id: any(named: 'id'),
          )).thenThrow(const NetworkException('offline'));

      await controller.createMissingRaceFormats();

      expect(controller.message.value, isA<UiMessageError>());
      expect(controller.isSubmitting.value, isFalse);
    });

    test('nothing missing → no call at all', () async {
      await loadRaces([
        raceOf(100, 8, Gender.male, [cadets])
      ]);
      // Pretend the row is covered.
      controller.rows.value = [
        for (final r in controller.rows)
          OverviewRow(
            raceId: r.raceId,
            categoryId: r.categoryId,
            raceLabel: r.raceLabel,
            categoryLabel: r.categoryLabel,
            gender: r.gender,
            disciplineId: r.disciplineId,
            entryCount: r.entryCount,
            structure: r.structure,
            defaultSpotsPerRace: r.defaultSpotsPerRace,
            raceFormat: const RaceFormatConfiguration(
              id: 1,
              label: 'x',
              fullLabel: 'x',
              gender: 'H',
              genderLabel: 'Homme',
              discipline: Discipline(
                  id: '8', name: 'x', speciality: 1, specialityLabel: ''),
            ),
          ),
      ];

      expect(controller.missingRaceFormatCount, 0);
      await controller.createMissingRaceFormats();

      verifyNever(() => raceFormatRepo.submitRaceFormat(
            competitionId: any(named: 'competitionId'),
            disciplineId: any(named: 'disciplineId'),
            gender: any(named: 'gender'),
            categoryIds: any(named: 'categoryIds'),
            id: any(named: 'id'),
          ));
    });
  });

  group('deleting structures', () {
    /// A drawn structure: deleting it also destroys the heats stored on its
    /// races, which is what the confirmation in the view warns about.
    const drawnCadets = EventStructure(
      raceId: 100,
      categoryId: 7,
      raceLabel: '100m',
      categoryLabel: 'Cadets',
      levels: [
        RoundLevel(type: RoundType.serie, races: [
          ProgrammeRace(id: 1, number: 1, athleteIds: [11, 12]),
        ]),
      ],
    );
    const juniorsStructure = EventStructure(
      raceId: 100,
      categoryId: 8,
      raceLabel: '100m',
      categoryLabel: 'Juniors',
      levels: [RoundLevel(type: RoundType.finale)],
    );

    Future<void> loadWith(List<EventStructure> structures) async {
      when(() => raceRepo.getRaces(42)).thenAnswer((_) async => [
            race(100, '100m', [cadets, juniors])
          ]);
      when(() => raceRepo.getEntries(100)).thenAnswer((_) async => [
            entry(1, 100, cadets),
            entry(2, 100, juniors),
          ]);
      when(() => storage.read(key: 'programme_42')).thenAnswer(
        (_) async => jsonEncode(
          CompetitionProgramme(competitionId: 42, structures: structures)
              .toJson(),
        ),
      );
      controller.onInit();
      await controller.load(competition);
    }

    EventStructure? rowStructure(int categoryId) =>
        controller.rows.firstWhere((r) => r.categoryId == categoryId).structure;

    test('deleteStructure removes only the targeted épreuve × category',
        () async {
      await loadWith([drawnCadets, juniorsStructure]);

      await controller.deleteStructure(100, 7);

      expect(rowStructure(7), isNull);
      expect(rowStructure(8), juniorsStructure);
    });

    test('deleteStructure leaves the rest of the programme intact', () async {
      await loadWith([drawnCadets, juniorsStructure]);

      await controller.deleteStructure(100, 7);

      expect(service.current.value!.structures, [juniorsStructure]);
      expect(service.current.value!.competitionId, 42);
    });

    test('deleting an épreuve with no structure changes nothing', () async {
      await loadWith([juniorsStructure]);

      await controller.deleteStructure(100, 7);

      expect(service.current.value!.structures, [juniorsStructure]);
      verifyNever(
          () => storage.write(key: 'programme_42', value: any(named: 'value')));
    });

    test('deleteAllStructures empties them all at once', () async {
      await loadWith([drawnCadets, juniorsStructure]);

      await controller.deleteAllStructures();

      expect(service.current.value!.structures, isEmpty);
      expect(rowStructure(7), isNull);
      expect(rowStructure(8), isNull);
      verify(() =>
              storage.write(key: 'programme_42', value: any(named: 'value')))
          .called(1);
    });

    test('deleteAllStructures with nothing to delete writes nothing', () async {
      await loadWith(const []);

      await controller.deleteAllStructures();

      verifyNever(
          () => storage.write(key: 'programme_42', value: any(named: 'value')));
    });

    test('hasAnyStructure drives the enabled state of the global action',
        () async {
      await loadWith(const []);
      expect(controller.hasAnyStructure, isFalse);

      await controller.generateAllDefaults();
      expect(controller.hasAnyStructure, isTrue);

      await controller.deleteAllStructures();
      expect(controller.hasAnyStructure, isFalse);
    });
  });
}
