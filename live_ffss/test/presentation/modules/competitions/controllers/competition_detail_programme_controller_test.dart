import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/programme_site.dart';
import 'package:live_ffss/app/domain/models/race.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/domain/models/schedule_block.dart';
import 'package:live_ffss/app/module/competitions/controllers/competition_detail_programme_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockStorage extends Mock implements FlutterSecureStorage {}

class _MockRaceRepo extends Mock implements RaceRepository {}

void main() {
  late _MockStorage storage;
  late _MockRaceRepo raceRepo;
  late ProgrammeService service;
  late CompetitionDetailProgrammeController controller;

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

  // A programme whose structure race 500 owns ProgrammeRace ids 10/11, with a
  // scheduled block for race 10 on site 1, day 13.
  CompetitionProgramme seed() => CompetitionProgramme(
        competitionId: 42,
        nextLocalId: 100,
        sites: const [
          ProgrammeSite(id: 1, name: 'Côtier 1', type: SiteType.cotier),
        ],
        structures: const [
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
        blocks: [
          ScheduleBlock(id: 20, siteId: 1, day: day, order: 0, raceId: 10),
        ],
      );

  setUp(() {
    storage = _MockStorage();
    raceRepo = _MockRaceRepo();
    when(() => storage.read(key: any(named: 'key')))
        .thenAnswer((_) async => jsonEncode(seed().toJson()));
    when(() => storage.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((_) async {});
    service = ProgrammeService(storage);
    controller = CompetitionDetailProgrammeController(service, raceRepo);
  });

  test('load derives days, defaults the site, and exposes the schedule', () async {
    when(() => raceRepo.getRaces(42)).thenAnswer((_) async => [race(500)]);
    await controller.load(withDates);

    expect(controller.isLoading.value, isFalse);
    expect(controller.days, [DateTime(2026, 6, 13), DateTime(2026, 6, 14)]);
    expect(controller.selectedSiteId.value, 1);
    expect(controller.hasProgramme, isTrue);

    final rows = controller.rowsFor(1, day);
    expect(rows.single.block.raceId, 10);
    expect(rows.single.begin, DateTime(2026, 6, 13, 9));
    expect(controller.startMinutesFor(1, day), 540);
    expect(controller.itemFor(10)?.number, 1);
  });

  test('raceForBlock bridges a scheduled race to its domain Race', () async {
    when(() => raceRepo.getRaces(42)).thenAnswer((_) async => [race(500)]);
    await controller.load(withDates);
    expect(controller.raceForBlock(10)?.id, 500);
  });

  test('raceForBlock returns null for an unmatched race id', () async {
    when(() => raceRepo.getRaces(42)).thenAnswer((_) async => [race(500)]);
    await controller.load(withDates);
    expect(controller.raceForBlock(9999), isNull);
  });

  test('hasProgramme is false when no block is scheduled', () async {
    when(() => storage.read(key: any(named: 'key'))).thenAnswer(
        (_) async => jsonEncode(const CompetitionProgramme(competitionId: 42).toJson()));
    when(() => raceRepo.getRaces(42)).thenAnswer((_) async => const []);
    await controller.load(withDates);
    expect(controller.hasProgramme, isFalse);
  });

  test('a getRaces failure degrades gracefully — schedule renders, taps inert',
      () async {
    when(() => raceRepo.getRaces(42)).thenThrow(const NetworkException('boom'));
    await controller.load(withDates);

    expect(controller.isLoading.value, isFalse);
    expect(controller.hasProgramme, isTrue); // programme is local, still shown
    expect(controller.raceForBlock(10), isNull); // no races → inert tap
  });
}
