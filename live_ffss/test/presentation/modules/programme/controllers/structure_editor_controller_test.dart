import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/module/programme/controllers/structure_editor_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockStorage storage;
  late ProgrammeService service;
  late StructureEditorController controller;

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
    when(() => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'))).thenAnswer((_) async {});
    service = ProgrammeService(storage);
    await service.load(42);
    controller = StructureEditorController(service);
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
    expect(levels.map((l) => l.type),
        [RoundType.serie, RoundType.finale]);
    expect(levels[0].races.length, 3); // ceil(20 / 8)
    expect(levels[1].races.length, 1);
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

  test('every mutation persists the whole programme', () async {
    controller.proposeDefault();
    // proposeDefault writes once; the structure is now in the stored programme.
    final stored = service.current.value!;
    expect(stored.structures.any((s) => s.raceId == 100), isTrue);
    verify(() => storage.write(
        key: 'programme_42', value: any(named: 'value'))).called(greaterThan(0));
  });
}
