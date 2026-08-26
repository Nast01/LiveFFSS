import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
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
import 'package:live_ffss/app/module/competitions/controllers/race_course_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockRaceRepo extends Mock implements RaceRepository {}

class _MockClubRepo extends Mock implements ClubRepository {}

/// Keeps the programme in memory so the controller's read-modify-write can be
/// asserted end to end, without secure storage.
class _FakeProgrammeService implements ProgrammeService {
  _FakeProgrammeService(CompetitionProgramme initial) {
    current.value = initial;
  }

  @override
  final Rxn<CompetitionProgramme> current = Rxn<CompetitionProgramme>();

  @override
  Future<void> load(int competitionId) async {}

  @override
  Future<void> save(CompetitionProgramme programme) async {
    current.value = programme;
  }

  @override
  int allocateId() {
    final p = current.value!;
    current.value = p.copyWith(nextLocalId: p.nextLocalId + 1);
    return p.nextLocalId;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const raceId = 10;
  const competitionId = 99;
  const categoryId = 5;
  const programmeRaceId = 77;

  late _MockRaceRepo raceRepo;
  late _MockClubRepo clubRepo;
  late _FakeProgrammeService programme;

  setUpAll(() => registerFallbackValue(const <Athlete>[]));

  Athlete athlete(int id) => Athlete(
        id: id,
        licenseeNumber: 'L$id',
        firstName: 'A$id',
        lastName: 'B$id',
        gender: Gender.female,
        year: 2000,
        nationalityCode: '',
        nationality: '',
        isValid: true,
      );

  Race makeRace() => const Race(
        id: raceId,
        name: 'Race',
        nameEnglish: 'Race',
        distance: 100,
        gender: Gender.female,
        athletesPerTeam: 1,
        specialityId: 1,
        specialityLabel: 'Côtier',
        disciplineId: 1,
        isEligibleToNationalRecord: false,
        categories: [],
      );

  Competition makeCompetition() => const Competition(
        id: competitionId,
        name: 'Comp',
        statusCode: 1,
        statusLabel: 'OPEN',
        speciality: 1,
        specialityLabel: 'Côtier',
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
        organizerClub: Club(id: 0, name: ''),
      );

  CompetitionProgramme programmeWith(ProgrammeRace race) =>
      CompetitionProgramme(
        competitionId: competitionId,
        nextLocalId: 100,
        structures: [
          EventStructure(
            raceId: raceId,
            categoryId: categoryId,
            raceLabel: 'Race',
            categoryLabel: 'Senior',
            levels: [
              RoundLevel(type: RoundType.serie, races: [race])
            ],
          ),
        ],
      );

  /// The stored race, read back out of the fake programme.
  ProgrammeRace saved() =>
      programme.current.value!.structures.single.levels.single.races.single;

  Map<String, Object?> arguments() => {
        'race': makeRace(),
        'competition': makeCompetition(),
        'categoryId': categoryId,
        'categoryLabel': 'Senior',
        'roundType': RoundType.serie,
        'raceNumber': 1,
        'programmeRaceId': programmeRaceId,
      };

  Future<RaceCourseController> loadWith(List<int> athleteIds) async {
    programme = _FakeProgrammeService(programmeWith(
      ProgrammeRace(id: programmeRaceId, number: 1, athleteIds: athleteIds),
    ));
    when(() => raceRepo.getEntries(raceId)).thenAnswer((_) async => [
          Entry(
            id: 1,
            category: const Category(id: categoryId, name: 'Senior'),
            status: 1,
            statusLabel: 'Engagé',
            athletes: [for (final id in athleteIds) athlete(id)],
          ),
        ]);
    final controller = RaceCourseController(programme, raceRepo, clubRepo)
      ..applyArguments(arguments());
    await controller.load();
    return controller;
  }

  setUp(() {
    raceRepo = _MockRaceRepo();
    clubRepo = _MockClubRepo();
    when(() => clubRepo.getAthleteClubs(any(), any()))
        .thenAnswer((_) async => const <int, Club>{});
  });

  tearDown(Get.reset);

  group('RaceCourseController.load', () {
    test('lists the athletes the draw put in this race', () async {
      final c = await loadWith([10, 11, 12]);

      expect(c.athletes.map((a) => a.id), [10, 11, 12]);
      expect(c.isLoading.value, isFalse);
    });

    test('reopens on the order already recorded', () async {
      final c = await loadWith([10, 11]);
      c.assign(c.athletes.first);

      // A second controller on the same programme sees the stored order.
      final again = RaceCourseController(programme, raceRepo, clubRepo)
        ..applyArguments(arguments());
      await again.load();

      expect(again.placeOf(again.athletes.first), 1);
    });
  });

  group('RaceCourseController entry', () {
    test('the first athlete entered takes the first place', () async {
      final c = await loadWith([10, 11]);

      c.assign(c.athletes.first);

      expect(c.placeOf(c.athletes.first), 1);
      expect(c.nextPlaceValue, 2);
    });

    test('the tie lock gives the same place until it is released', () async {
      final c = await loadWith([10, 11, 12]);

      c.assign(c.athletes[0]);
      c.toggleTieLock();
      c.assign(c.athletes[1]);
      c.toggleTieLock();
      c.assign(c.athletes[2]);

      expect(c.placeOf(c.athletes[0]), 1);
      expect(c.placeOf(c.athletes[1]), 1);
      // Two firsts consume two places; the third athlete is third.
      expect(c.placeOf(c.athletes[2]), 3);
    });

    test('undo takes back the last entry', () async {
      final c = await loadWith([10, 11]);
      c.assign(c.athletes[0]);
      c.assign(c.athletes[1]);

      c.undo();

      expect(c.placeOf(c.athletes[1]), isNull);
      expect(c.placeOf(c.athletes[0]), 1);
    });

    test('removing an athlete renumbers the ones after', () async {
      final c = await loadWith([10, 11, 12]);
      c.assign(c.athletes[0]);
      c.assign(c.athletes[1]);
      c.assign(c.athletes[2]);

      c.remove(c.athletes[1]);

      expect(c.placeOf(c.athletes[0]), 1);
      expect(c.placeOf(c.athletes[1]), isNull);
      expect(c.placeOf(c.athletes[2]), 2);
    });

    test('every entry is persisted as it happens', () async {
      final c = await loadWith([10, 11]);

      c.assign(c.athletes.first);

      expect(saved().finishOrder, [
        [10],
      ]);
    });

    test('the ranked rise in place order, the rest keep the draw order',
        () async {
      final c = await loadWith([10, 11, 12]);

      c.assign(c.athletes[2]);

      expect(c.orderedAthletes.map((a) => a.id), [12, 10, 11]);
    });
  });
}
