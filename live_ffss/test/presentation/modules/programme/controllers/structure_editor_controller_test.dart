import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/race_format_repository.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/race_format_detail.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/module/programme/controllers/structure_editor_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockStorage extends Mock implements FlutterSecureStorage {}

class _MockRaceFormatRepo extends Mock implements RaceFormatRepository {}

void main() {
  late _MockStorage storage;
  late ProgrammeService service;
  late StructureEditorController controller;
  late _MockRaceFormatRepo raceFormatRepo;

  setUpAll(() => registerFallbackValue(''));

  const args = StructureEditorArgs(
    competitionId: 42,
    raceId: 100,
    categoryId: 7,
    raceLabel: '100m',
    categoryLabel: 'Cadets',
    entryCount: 20,
  );

  setUp(() async {
    storage = _MockStorage();
    when(() => storage.read(key: any(named: 'key')))
        .thenAnswer((_) async => null);
    when(() =>
            storage.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((_) async {});
    service = ProgrammeService(storage);
    await service.load(42);
    raceFormatRepo = _MockRaceFormatRepo();
    when(() => raceFormatRepo.deleteRaceFormatDetail(any()))
        .thenAnswer((_) async => true);
    controller = StructureEditorController(service, raceFormatRepo);
    controller.start(args);
  });

  test('start creates an empty structure with the event defaults', () {
    final s = controller.structure.value!;
    expect(s.raceId, 100);
    expect(s.categoryId, 7);
    expect(s.spotsPerRace, 8);
    expect(s.levels, isEmpty);
  });

  test('proposeDefault builds séries + finale for 20 entries at 8 spots', () {
    controller.proposeDefault();

    final levels = controller.structure.value!.levels;
    expect(levels.map((l) => l.type), [RoundType.serie, RoundType.finale]);
    expect(levels[0].races.length, 3); // ceil(20 / 8)
    expect(levels[1].races.length, 1);
  });

  group('race size per round', () {
    test('proposed levels carry the structure default', () {
      controller.proposeDefault();

      final s = controller.structure.value!;
      expect(s.levels.map((l) => l.spotsPerRace), [8, 8]);
    });

    test('setLevelSpotsPerRace changes only that round', () {
      controller.proposeDefault();

      controller.setLevelSpotsPerRace(1, 16);

      final s = controller.structure.value!;
      expect(s.spotsForLevel(s.levels[0]), 8);
      expect(s.spotsForLevel(s.levels[1]), 16);
      // The structure default is untouched: it only seeds new rounds.
      expect(s.spotsPerRace, 8);
    });

    test('a round with no size of its own falls back to the default', () {
      // What a programme authored before the field existed looks like.
      controller.addLevel(RoundType.finale);
      final s = controller.structure.value!;
      final legacy = s.levels.single.copyWith(spotsPerRace: 0);

      expect(s.spotsForLevel(legacy), 8);
    });

    test('a new round starts at the structure default, not zero', () {
      controller.addLevel(RoundType.serie);

      expect(controller.structure.value!.levels.single.spotsPerRace, 8);
    });

    test('a non-positive size is rejected', () {
      controller.proposeDefault();

      controller.setLevelSpotsPerRace(0, 0);

      expect(controller.structure.value!.levels[0].spotsPerRace, 8);
    });
  });

  group('seeding from the server rounds', () {
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
    const finale = RaceFormatDetail(
      id: 33,
      order: 2,
      label: 'Finale',
      fullLabel: 'Finale',
      levelLabel: 'Finale',
      level: 'final',
      numberOfRun: 1,
      qualificationMethod: 'course',
      qualificationMethodLabel: 'Par course',
      spotsPerRace: 16,
      qualifyingSpots: 8,
    );

    const withServerRounds = StructureEditorArgs(
      competitionId: 42,
      raceId: 100,
      categoryId: 7,
      raceLabel: '100m',
      categoryLabel: 'Cadets',
      entryCount: 20,
      serverDetails: [semi, finale],
    );

    test('start() alone never writes to the shared programme service', () {
      // Regression: allocating ids and persisting during onInit marked the
      // structure overview — mounted underneath and observing the same Rx —
      // dirty mid-build, which crashed on opening the editor.
      controller.start(withServerRounds);

      expect(controller.structure.value!.levels, isEmpty);
      expect(service.current.value!.structures, isEmpty);
      expect(service.current.value!.nextLocalId, 1);
      verifyNever(() =>
          storage.write(key: any(named: 'key'), value: any(named: 'value')));
    });

    test('a brand-new structure adopts the FFSS rounds', () {
      controller.start(withServerRounds);
      controller.seedFromServerIfNeeded();

      final s = controller.structure.value!;
      expect(s.levels.map((l) => l.type), [RoundType.demi, RoundType.finale]);
      expect(s.levels.map((l) => l.races.length), [2, 1]);
      expect(s.levels.map((l) => l.spotsPerRace), [18, 16]);
      expect(s.levels.last.qualifiersPerRace, 8);
    });

    test('the seeded structure is persisted, so ids are not reissued', () {
      controller.start(withServerRounds);
      controller.seedFromServerIfNeeded();

      final stored = service.current.value!.structures.single;
      expect(stored.levels, hasLength(2));
      expect(service.current.value!.nextLocalId, 4); // 3 races allocated
    });

    test('a stored structure emptied of its rounds adopts the server ones',
        () async {
      // The operator deleted every round; reopening the editor must be able to
      // pull the FFSS ones back, which the "never stored" guard used to block.
      controller.start(withServerRounds);
      controller.seedFromServerIfNeeded();
      await controller.removeLevel(0);
      await controller.removeLevel(0);
      expect(controller.structure.value!.levels, isEmpty);

      controller.start(withServerRounds);
      controller.seedFromServerIfNeeded();

      expect(controller.structure.value!.levels.map((l) => l.type),
          [RoundType.demi, RoundType.finale]);
    });

    test('a stored structure wins over the server rounds', () {
      // The operator already authored something: the server must not overwrite
      // it, which is the whole point of authoring locally.
      controller.start(const StructureEditorArgs(
        competitionId: 42,
        raceId: 100,
        categoryId: 7,
        raceLabel: '100m',
        categoryLabel: 'Cadets',
        entryCount: 20,
      ));
      controller.addLevel(RoundType.finale);

      controller.start(withServerRounds);
      controller.seedFromServerIfNeeded();

      final s = controller.structure.value!;
      expect(s.levels.map((l) => l.type), [RoundType.finale]);
    });

    test('seeding twice does not allocate a second set of ids', () {
      controller.start(withServerRounds);
      controller.seedFromServerIfNeeded();
      final afterFirst = service.current.value!.nextLocalId;

      controller.seedFromServerIfNeeded();

      expect(service.current.value!.nextLocalId, afterFirst);
      expect(service.current.value!.structures.single.levels, hasLength(2));
    });

    test('a round seeded from FFSS remembers its partie id', () {
      controller.start(withServerRounds);
      controller.seedFromServerIfNeeded();

      expect(
          controller.structure.value!.levels.map((l) => l.serverId), [32, 33]);
    });

    test('no server rounds leaves an empty structure, nothing persisted', () {
      controller.start(const StructureEditorArgs(
        competitionId: 42,
        raceId: 100,
        categoryId: 7,
        raceLabel: '100m',
        categoryLabel: 'Cadets',
        entryCount: 20,
      ));
      controller.seedFromServerIfNeeded();

      expect(controller.structure.value!.levels, isEmpty);
      expect(service.current.value!.structures, isEmpty);
    });
  });

  group('reimportFromServer', () {
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
    const withServerRounds = StructureEditorArgs(
      competitionId: 42,
      raceId: 100,
      categoryId: 7,
      raceLabel: '100m',
      categoryLabel: 'Cadets',
      entryCount: 20,
      serverDetails: [semi],
    );

    test('replaces authored rounds with the server ones', () {
      controller.start(withServerRounds);
      controller.addLevel(RoundType.finale);
      controller.setRaceCount(0, 4);
      expect(controller.structure.value!.levels.single.type, RoundType.finale);

      controller.reimportFromServer();

      final levels = controller.structure.value!.levels;
      expect(levels.map((l) => l.type), [RoundType.demi]);
      expect(levels.single.races, hasLength(2));
      expect(levels.single.spotsPerRace, 18);
      expect(levels.single.serverId, 32);
      expect(controller.message.value, isA<UiMessageSuccess>());
    });

    test('persists the replacement', () {
      controller.start(withServerRounds);
      controller.addLevel(RoundType.finale);

      controller.reimportFromServer();

      expect(service.current.value!.structures.single.levels.single.type,
          RoundType.demi);
    });

    test('does nothing when FFSS declares no round', () {
      controller.start(args); // no serverDetails
      controller.addLevel(RoundType.finale);

      controller.reimportFromServer();

      expect(controller.structure.value!.levels.single.type, RoundType.finale);
      expect(controller.hasServerRounds, isFalse);
    });

    test('hasServerRounds reflects what the déroulement carries', () {
      controller.start(withServerRounds);
      expect(controller.hasServerRounds, isTrue);
    });

    test('never deletes anything on the server', () {
      // Re-importing adopts what FFSS holds; it must not touch it.
      controller.start(withServerRounds);
      controller.addLevel(RoundType.finale);

      controller.reimportFromServer();

      verifyNever(() => raceFormatRepo.deleteRaceFormatDetail(any()));
    });
  });

  group('removeLevel', () {
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

    Future<void> withServerRound() async {
      controller.start(const StructureEditorArgs(
        competitionId: 42,
        raceId: 100,
        categoryId: 7,
        raceLabel: '100m',
        categoryLabel: 'Cadets',
        entryCount: 20,
        serverDetails: [semi],
      ));
      controller.seedFromServerIfNeeded();
    }

    test('a round backed by FFSS is deleted on the server too', () async {
      await withServerRound();

      await controller.removeLevel(0);

      verify(() => raceFormatRepo.deleteRaceFormatDetail(32)).called(1);
      expect(controller.structure.value!.levels, isEmpty);
    });

    test('a hand-added round calls nothing', () async {
      controller.addLevel(RoundType.finale);

      await controller.removeLevel(0);

      verifyNever(() => raceFormatRepo.deleteRaceFormatDetail(any()));
      expect(controller.structure.value!.levels, isEmpty);
    });

    test('a refused deletion keeps the round rather than diverging', () async {
      await withServerRound();
      when(() => raceFormatRepo.deleteRaceFormatDetail(any()))
          .thenAnswer((_) async => false);

      await controller.removeLevel(0);

      expect(controller.structure.value!.levels, hasLength(1));
      expect(controller.message.value, isA<UiMessageError>());
    });

    test('a network failure keeps the round and clears the busy flag',
        () async {
      await withServerRound();
      when(() => raceFormatRepo.deleteRaceFormatDetail(any()))
          .thenThrow(const NetworkException('offline'));

      await controller.removeLevel(0);

      expect(controller.structure.value!.levels, hasLength(1));
      expect(controller.message.value, isA<UiMessageError>());
      expect(controller.isDeletingLevel.value, isFalse);
    });
  });

  test('races get unique ids from the service counter', () {
    controller.proposeDefault();

    final ids = controller.structure.value!.levels
        .expand((l) => l.races)
        .map((r) => r.id)
        .toList();
    expect(ids.toSet().length, ids.length); // all unique
  });

  test('proposeDefault wires quarts/finale to all previous races by default',
      () {
    controller.proposeDefault();

    final levels = controller.structure.value!.levels;
    final serieIds = levels[0].races.map((r) => r.id).toList();
    final finale = levels[1].races.single;
    expect(finale.sourceRaceIds, serieIds); // opt2: all → all
  });

  test('setRaceCount adds/removes races on a level', () {
    controller.proposeDefault();
    controller.setRaceCount(0, 5);
    expect(controller.structure.value!.levels[0].races.length, 5);
    controller.setRaceCount(0, 2);
    expect(controller.structure.value!.levels[0].races.length, 2);
  });

  test('setWiring overrides the sources of one race (opt1)', () {
    controller.proposeDefault();
    final serieIds =
        controller.structure.value!.levels[0].races.map((r) => r.id).toList();
    final finaleId = controller.structure.value!.levels[1].races.single.id;

    controller.setWiring(1, finaleId, [serieIds.first]);

    expect(controller.structure.value!.levels[1].races.single.sourceRaceIds,
        [serieIds.first]);
  });

  group('reordering the rounds', () {
    test('moveLevel swaps two rounds of the same level and persists', () {
      controller.addLevel(RoundType.serie);
      controller.addLevel(RoundType.serie);
      controller.setRaceCount(0, 3);

      controller.moveLevel(1, -1);

      final levels = controller.structure.value!.levels;
      expect(levels[0].races, isEmpty);
      expect(levels[1].races.length, 3);
      final stored =
          service.current.value!.structures.firstWhere((s) => s.raceId == 100);
      expect(stored.levels[1].races.length, 3);
    });

    test('moveLevel refuses a move that would break the hierarchy', () {
      controller.addLevel(RoundType.serie);
      controller.addLevel(RoundType.finale);

      controller.moveLevel(1, -1);

      expect(controller.structure.value!.levels.map((l) => l.type),
          [RoundType.serie, RoundType.finale]);
    });

    test('moveLevel re-wires the rounds it swapped', () {
      controller.addLevel(RoundType.serie);
      controller.addLevel(RoundType.serie);
      controller.setRaceCount(0, 2);
      controller.setRaceCount(1, 1);

      controller.moveLevel(0, 1);

      final levels = controller.structure.value!.levels;
      final firstIds = levels[0].races.map((r) => r.id).toList();
      expect(levels[0].races.single.sourceRaceIds, isEmpty);
      expect(levels[1].races.first.sourceRaceIds, firstIds);
    });

    test('canMoveLevel is false at both ends of the list', () {
      controller.addLevel(RoundType.serie);
      controller.addLevel(RoundType.serie);

      expect(controller.canMoveLevel(0, -1), isFalse);
      expect(controller.canMoveLevel(1, 1), isFalse);
      expect(controller.canMoveLevel(0, 1), isTrue);
    });

    test('addLevel inserts the round at its rank instead of appending', () {
      controller.addLevel(RoundType.serie);
      controller.addLevel(RoundType.finale);
      controller.addLevel(RoundType.demi);
      controller.addLevel(RoundType.quart);

      expect(controller.structure.value!.levels.map((l) => l.type), [
        RoundType.serie,
        RoundType.quart,
        RoundType.demi,
        RoundType.finale,
      ]);
    });

    test('a round inserted mid-structure becomes the feeder of the next one',
        () {
      controller.proposeDefault();

      controller.addLevel(RoundType.demi);

      final levels = controller.structure.value!.levels;
      expect(levels.map((l) => l.type),
          [RoundType.serie, RoundType.demi, RoundType.finale]);
      // The demi holds no race yet, so the finale it now follows is fed by
      // none — rather than still claiming the séries two rounds above.
      expect(levels[2].races.single.sourceRaceIds, isEmpty);
    });
  });

  test('every mutation persists the whole programme', () async {
    controller.proposeDefault();
    // proposeDefault writes once; the structure is now in the stored programme.
    final stored = service.current.value!;
    expect(stored.structures.any((s) => s.raceId == 100), isTrue);
    verify(() => storage.write(key: 'programme_42', value: any(named: 'value')))
        .called(greaterThan(0));
  });
}
