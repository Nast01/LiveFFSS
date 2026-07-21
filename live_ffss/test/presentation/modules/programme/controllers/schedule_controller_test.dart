import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/programme_site.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/module/programme/controllers/schedule_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockStorage storage;
  late ProgrammeService service;
  late ScheduleController controller;

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

  CompetitionProgramme seed() => const CompetitionProgramme(
        competitionId: 42,
        nextLocalId: 100,
        sites: [ProgrammeSite(id: 1, name: 'Côtier 1', type: SiteType.cotier)],
        structures: [
          EventStructure(
            raceId: 500,
            categoryId: 7,
            raceLabel: '100m',
            categoryLabel: 'Cadets',
            levels: [
              RoundLevel(type: RoundType.serie, races: [
                ProgrammeRace(id: 10, number: 1),
                ProgrammeRace(id: 11, number: 2),
              ]),
            ],
          ),
        ],
      );

  setUp(() async {
    storage = _MockStorage();
    when(() => storage.read(key: any(named: 'key'))).thenAnswer((_) async => null);
    when(() => storage.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((_) async {});
    service = ProgrammeService(storage);
    await service.save(seed());
    controller = ScheduleController(service);
    controller.setCompetition(withDates);
  });

  test('setCompetition derives days and defaults the site', () {
    expect(controller.days, [DateTime(2026, 6, 13), DateTime(2026, 6, 14)]);
    expect(controller.selectedSiteId.value, 1);
  });

  test('unscheduled lists races with no block', () {
    expect(controller.unscheduled.map((i) => i.raceId), [10, 11]);
  });

  test('addRace appends a race block; the next appends after it', () async {
    await controller.addRace(10, 1, day);
    await controller.addRace(11, 1, day);
    final rows = controller.rowsFor(1, day);
    expect(rows.map((r) => r.block.raceId), [10, 11]);
    expect(rows[0].begin, DateTime(2026, 6, 13, 9));
    expect(rows[1].begin, DateTime(2026, 6, 13, 9, 10));
    expect(controller.unscheduled, isEmpty);
  });

  test('addManual inserts a manual block into the sequence', () async {
    await controller.addRace(10, 1, day);
    await controller.addManual('Pause', 30, 1, day);
    final rows = controller.rowsFor(1, day);
    expect(rows[1].block.manualLabel, 'Pause');
    expect(rows[1].begin, DateTime(2026, 6, 13, 9, 10));
  });

  test('reorder moves a block and reflows times', () async {
    await controller.addRace(10, 1, day);
    await controller.addRace(11, 1, day);
    await controller.reorder(1, day, 1, 0);
    final rows = controller.rowsFor(1, day);
    expect(rows.map((r) => r.block.raceId), [11, 10]);
    expect(rows[0].begin, DateTime(2026, 6, 13, 9));
  });

  test('setDuration reflows following blocks', () async {
    await controller.addRace(10, 1, day);
    await controller.addRace(11, 1, day);
    final firstBlockId = controller.rowsFor(1, day).first.block.id;
    await controller.setDuration(firstBlockId, 20);
    expect(controller.rowsFor(1, day)[1].begin, DateTime(2026, 6, 13, 9, 20));
  });

  test('removeBlock on a race returns it to the palette', () async {
    await controller.addRace(10, 1, day);
    final blockId = controller.rowsFor(1, day).single.block.id;
    await controller.removeBlock(blockId);
    expect(controller.rowsFor(1, day), isEmpty);
    expect(controller.unscheduled.map((i) => i.raceId), contains(10));
  });

  test('setDayStart shifts all derived times', () async {
    await controller.addRace(10, 1, day);
    await controller.setDayStart(1, day, 8 * 60 + 30);
    expect(controller.rowsFor(1, day).single.begin, DateTime(2026, 6, 13, 8, 30));
  });

  group('site deletion reconciliation', () {
    CompetitionProgramme seedTwoSites() => const CompetitionProgramme(
          competitionId: 42,
          nextLocalId: 100,
          sites: [
            ProgrammeSite(id: 1, name: 'Côtier 1', type: SiteType.cotier),
            ProgrammeSite(id: 2, name: 'Côtier 2', type: SiteType.cotier),
          ],
        );

    test('deleting the selected site reselects the first remaining site',
        () async {
      await service.save(seedTwoSites());
      controller = ScheduleController(service);
      controller.onInit();
      controller.setCompetition(withDates);
      expect(controller.selectedSiteId.value, 1);

      await service.save(service.current.value!.copyWith(
        sites: const [
          ProgrammeSite(id: 2, name: 'Côtier 2', type: SiteType.cotier),
        ],
      ));
      await Future<void>.delayed(Duration.zero);

      expect(controller.selectedSiteId.value, 2);
    });

    test('deleting the last site clears the selection', () async {
      await service.save(seed());
      controller = ScheduleController(service);
      controller.onInit();
      controller.setCompetition(withDates);
      expect(controller.selectedSiteId.value, 1);

      await service.save(
        service.current.value!.copyWith(sites: const []),
      );
      await Future<void>.delayed(Duration.zero);

      expect(controller.selectedSiteId.value, null);
    });
  });
}
