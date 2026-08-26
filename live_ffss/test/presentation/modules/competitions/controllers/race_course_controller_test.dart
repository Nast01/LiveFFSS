import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/rfid/rfid_writer.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
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
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/race.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/module/competitions/controllers/race_course_controller.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';
import 'package:mocktail/mocktail.dart';

class _MockRaceRepo extends Mock implements RaceRepository {}

class _MockClubRepo extends Mock implements ClubRepository {}

class _MockRfidWriter extends Mock implements RfidWriter {}

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
  late _MockRfidWriter rfid;

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
    final controller = RaceCourseController(programme, raceRepo, clubRepo, rfid)
      ..applyArguments(arguments());
    await controller.load();
    return controller;
  }

  setUp(() {
    rfid = _MockRfidWriter();
    raceRepo = _MockRaceRepo();
    clubRepo = _MockClubRepo();
    when(() => clubRepo.getAthleteClubs(any(), any()))
        .thenAnswer((_) async => const <int, Club>{});
  });

  tearDown(Get.reset);

  group('RaceCourseController.applyArguments', () {
    test('parses every context field from the map', () {
      final controller = RaceCourseController(
        _FakeProgrammeService(
            const CompetitionProgramme(competitionId: competitionId)),
        raceRepo,
        clubRepo,
        rfid,
      );
      controller.applyArguments({
        'race': makeRace(),
        'competition': makeCompetition(),
        'categoryId': 7,
        'categoryLabel': 'Cadets',
        'roundType': RoundType.serie,
        'raceNumber': 2,
        'programmeRaceId': 11,
      });

      expect(controller.race.value?.id, raceId);
      expect(controller.competition.value?.id, competitionId);
      expect(controller.categoryId, 7);
      expect(controller.categoryLabel, 'Cadets');
      expect(controller.roundType, RoundType.serie);
      expect(controller.raceNumber, 2);
      expect(controller.programmeRaceId, 11);
    });

    test('leaves defaults on a non-map argument', () {
      final controller = RaceCourseController(
        _FakeProgrammeService(
            const CompetitionProgramme(competitionId: competitionId)),
        raceRepo,
        clubRepo,
        rfid,
      );
      controller.applyArguments(null);

      expect(controller.race.value, isNull);
      expect(controller.categoryId, isNull);
      expect(controller.categoryLabel, '');
      expect(controller.roundType, RoundType.unknown);
      expect(controller.raceNumber, 0);
      expect(controller.programmeRaceId, isNull);
    });
  });

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
      final again = RaceCourseController(programme, raceRepo, clubRepo, rfid)
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

    test('undo on a freshly loaded course does nothing and does not throw',
        () async {
      final c = await loadWith([10, 11]);

      expect(() => c.undo(), returnsNormally);
      expect(c.finishOrder, isEmpty);
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

    test(
        'persisting a result leaves a sibling structure for another category untouched',
        () async {
      // Two categories of the same event (Senior, Junior) share raceId and each
      // carry their own structure — entering Senior's result must not disturb
      // Junior's, which shares nothing but the race.
      const otherCategoryId = 6;
      const otherProgrammeRaceId = 88;
      const initial = CompetitionProgramme(
        competitionId: competitionId,
        nextLocalId: 100,
        structures: [
          EventStructure(
            raceId: raceId,
            categoryId: categoryId,
            raceLabel: 'Race',
            categoryLabel: 'Senior',
            levels: [
              RoundLevel(
                type: RoundType.serie,
                races: [
                  ProgrammeRace(
                    id: programmeRaceId,
                    number: 1,
                    athleteIds: [10, 11],
                  ),
                ],
              ),
            ],
          ),
          EventStructure(
            raceId: raceId,
            categoryId: otherCategoryId,
            raceLabel: 'Race',
            categoryLabel: 'Junior',
            levels: [
              RoundLevel(
                type: RoundType.serie,
                races: [
                  ProgrammeRace(
                    id: otherProgrammeRaceId,
                    number: 1,
                    athleteIds: [20, 21],
                  ),
                ],
              ),
            ],
          ),
        ],
      );
      programme = _FakeProgrammeService(initial);
      when(() => raceRepo.getEntries(raceId)).thenAnswer((_) async => [
            Entry(
              id: 1,
              category: const Category(id: categoryId, name: 'Senior'),
              status: 1,
              statusLabel: 'Engagé',
              athletes: [athlete(10), athlete(11)],
            ),
          ]);
      final c = RaceCourseController(programme, raceRepo, clubRepo, rfid)
        ..applyArguments(arguments());
      await c.load();

      // Identity, not equality: a rebuilt-but-value-equal structure would pass
      // an equality check and hide exactly the bug this guards against.
      final juniorStructureBefore = programme.current.value!.structures[1];

      c.assign(c.athletes.first);

      final juniorStructureAfter = programme.current.value!.structures[1];
      expect(identical(juniorStructureBefore, juniorStructureAfter), isTrue);
    });
  });

  group('RaceCourseController withdrawals', () {
    test('a forfeit takes no place and the others close the gap', () async {
      final c = await loadWith([10, 11, 12]);

      c.assign(c.athletes[0]);
      c.setPenalty(c.athletes[1], CoursePenaltyKind.forfeit);
      c.assign(c.athletes[2]);

      expect(c.placeOf(c.athletes[2]), 2);
      expect(c.penaltyOf(c.athletes[1])?.kind, CoursePenaltyKind.forfeit);
    });

    test('a disqualification carries its code', () async {
      final c = await loadWith([10, 11]);

      c.setPenalty(c.athletes[0], CoursePenaltyKind.disqualified, code: '4.7');

      expect(c.penaltyOf(c.athletes[0])?.code, '4.7');
      expect(saved().penalties.single.code, '4.7');
    });

    test('penalising a ranked athlete pulls them out of the ranking', () async {
      final c = await loadWith([10, 11]);
      c.assign(c.athletes[0]);
      c.assign(c.athletes[1]);

      c.setPenalty(c.athletes[0], CoursePenaltyKind.disqualified, code: 'x');

      expect(c.placeOf(c.athletes[0]), isNull);
      expect(c.placeOf(c.athletes[1]), 1);
    });

    test('clearing a penalty puts the athlete back among those to come',
        () async {
      final c = await loadWith([10]);
      c.setPenalty(c.athletes[0], CoursePenaltyKind.forfeit);

      c.clearPenalty(c.athletes[0]);

      expect(c.penaltyOf(c.athletes[0]), isNull);
      expect(c.isComplete, isFalse);
    });

    test('the course is complete when nobody is left to place', () async {
      final c = await loadWith([10, 11]);
      c.assign(c.athletes[0]);
      expect(c.isComplete, isFalse);

      c.setPenalty(c.athletes[1], CoursePenaltyKind.forfeit);

      expect(c.isComplete, isTrue);
    });

    test('a withdrawn athlete sinks below those still to come', () async {
      final c = await loadWith([10, 11]);

      c.setPenalty(c.athletes[0], CoursePenaltyKind.forfeit);

      expect(c.orderedAthletes.map((a) => a.id), [11, 10]);
    });

    test('assigning a withdrawn athlete leaves the ranking untouched',
        () async {
      final c = await loadWith([10, 11]);
      c.setPenalty(c.athletes[0], CoursePenaltyKind.disqualified, code: 'x');

      c.assign(c.athletes[0]);

      expect(c.finishOrder, isEmpty);
      expect(c.message.value, isA<UiMessageError>());
    });
  });

  group('RaceCourseController scanning', () {
    late StreamController<String> stream;

    setUp(() {
      stream = StreamController<String>();
      when(() => rfid.readBracelets()).thenAnswer((_) => stream.stream);
      when(() => rfid.isSupported).thenReturn(true);
    });

    tearDown(() {
      // Not awaited: an unlistened single-subscription controller's close()
      // never completes, which would hang this tearDown.
      if (!stream.isClosed) stream.close();
    });

    test('a scanned bracelet takes the next place', () async {
      final c = await loadWith([10, 11]);
      c.startScan();

      stream.add('L10;B10');
      await pumpEventQueue();

      expect(c.placeOf(c.athletes[0]), 1);
      c.stopScan();
    });

    test('the tie lock applies to a scan exactly as to a tap', () async {
      final c = await loadWith([10, 11, 12]);
      c.startScan();
      stream.add('L10;B10');
      await pumpEventQueue();

      c.toggleTieLock();
      stream.add('L11;B11');
      await pumpEventQueue();

      expect(c.placeOf(c.athletes[1]), 1);
      c.stopScan();
    });

    test('a bracelet of nobody in this course reports and changes nothing',
        () async {
      final c = await loadWith([10]);
      c.startScan();

      stream.add('L999;NOBODY');
      await pumpEventQueue();

      expect(c.finishOrder, isEmpty);
      expect(c.message.value, isA<UiMessageError>());
      c.stopScan();
    });

    test(
        'scanning a withdrawn athlete\'s bracelet reports and leaves everyone\'s place alone',
        () async {
      final c = await loadWith([10, 11, 12]);
      c.assign(c.athletes[1]);
      c.setPenalty(c.athletes[0], CoursePenaltyKind.forfeit);
      c.startScan();

      stream.add('L10;B10');
      await pumpEventQueue();

      expect(c.placeOf(c.athletes[0]), isNull);
      expect(c.placeOf(c.athletes[1]), 1);
      expect(c.message.value, isA<UiMessageError>());
      c.stopScan();
    });

    test('a bracelet already ranked is not ranked twice', () async {
      final c = await loadWith([10, 11]);
      c.startScan();
      stream.add('L10;B10');
      await pumpEventQueue();
      stream.add('L10;B10');
      await pumpEventQueue();

      expect(c.finishOrder, [
        [10],
      ]);
      c.stopScan();
    });

    test('the session stops itself once the course is complete', () async {
      final c = await loadWith([10]);
      c.startScan();

      stream.add('L10;B10');
      await pumpEventQueue();

      expect(c.isComplete, isTrue);
      expect(c.isScanning.value, isFalse);
    });

    test('canScan follows the hardware', () async {
      when(() => rfid.isSupported).thenReturn(false);
      final c = await loadWith([10]);

      expect(c.canScan, isFalse);
    });
  });
}
