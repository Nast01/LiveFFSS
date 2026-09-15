import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/rfid/rfid_writer.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:intl/intl.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
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
import 'package:live_ffss/app/domain/models/lane.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';
import 'package:live_ffss/app/domain/models/race.dart';
import 'package:live_ffss/app/domain/models/run.dart';
import 'package:live_ffss/app/domain/models/slot.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/module/competitions/controllers/race_course_controller.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';
import 'package:mocktail/mocktail.dart';

class _MockRaceRepo extends Mock implements RaceRepository {}

class _MockClubRepo extends Mock implements ClubRepository {}

class _MockRfidWriter extends Mock implements RfidWriter {}

class _MockMeetingRepo extends Mock implements MeetingRepository {}

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
  late _MockMeetingRepo meetingRepo;

  setUpAll(() {
    registerFallbackValue(const <Athlete>[]);
    registerFallbackValue(const <int>[]);
    registerFallbackValue(const <Lane>[]);
    registerFallbackValue(const <CourseOutcome>[]);
  });

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

  Future<RaceCourseController> loadWithEntries(
    List<({int entryId, List<int> athleteIds})> spec, {
    List<List<int>> competitorOrder = const [],
  }) async {
    programme = _FakeProgrammeService(programmeWith(ProgrammeRace(
      id: programmeRaceId,
      number: 1,
      entryIds: [for (final e in spec) e.entryId],
      athleteIds: [for (final e in spec) ...e.athleteIds],
      competitorOrder: competitorOrder,
    )));
    when(() => raceRepo.getEntries(raceId)).thenAnswer((_) async => [
          for (final e in spec)
            Entry(
              id: e.entryId,
              category: const Category(id: categoryId, name: 'Senior'),
              status: 1,
              statusLabel: 'Engagé',
              athletes: [for (final id in e.athleteIds) athlete(id)],
            ),
        ]);
    final controller =
        RaceCourseController(programme, raceRepo, clubRepo, rfid, meetingRepo)
          ..applyArguments(arguments());
    await controller.load();
    return controller;
  }

  /// Un engagement par athlète : l'épreuve individuelle ordinaire.
  Future<RaceCourseController> loadWith(List<int> athleteIds) =>
      loadWithEntries([
        for (final id in athleteIds) (entryId: id * 10, athleteIds: [id]),
      ]);

  setUp(() {
    rfid = _MockRfidWriter();
    meetingRepo = _MockMeetingRepo();
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
        meetingRepo,
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
        meetingRepo,
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
    test('lists the engagements the draw put in this race', () async {
      final c = await loadWith([10, 11, 12]);

      expect(c.competitors.map((e) => e.id), [100, 110, 120]);
      expect(c.isLoading.value, isFalse);
    });

    // Le club n'arrive jamais sur `Entry.athletes[].club` : il est résolu à
    // part. Sans ce raccord, chaque ClubAvatar de l'écran retomberait sur
    // l'initiale du club.
    test('les athlètes des engagements portent leur club résolu', () async {
      when(() => clubRepo.getAthleteClubs(any(), any())).thenAnswer(
        (_) async => const {10: Club(id: 3, name: 'SNS Nice')},
      );

      final c = await loadWith([10]);

      expect(c.competitors.single.athletes.single.club?.name, 'SNS Nice');
    });

    // Un relais fait tomber chaque athlete dans son propre club : patcher
    // l'engagement ne doit pas rabattre toute l'equipe sur un seul.
    test('chaque relayeur porte son propre club resolu', () async {
      when(() => clubRepo.getAthleteClubs(any(), any())).thenAnswer(
        (_) async => const {
          101: Club(id: 3, name: 'SNS Nice'),
          102: Club(id: 4, name: 'SNS Antibes'),
        },
      );

      final c = await loadWithEntries([
        (entryId: 10, athleteIds: [101, 102]),
      ]);

      expect(
        c.competitors.single.athletes.map((a) => a.club?.name),
        ['SNS Nice', 'SNS Antibes'],
      );
    });

    test('reopens on the order already recorded', () async {
      final c = await loadWith([10, 11]);
      c.assign(c.competitors.first);

      // A second controller on the same programme sees the stored order.
      final again =
          RaceCourseController(programme, raceRepo, clubRepo, rfid, meetingRepo)
            ..applyArguments(arguments());
      await again.load();

      expect(again.placeOf(again.competitors.first), 1);
    });
  });

  group('RaceCourseController entry', () {
    test('the first competitor entered takes the first place', () async {
      final c = await loadWith([10, 11]);

      c.assign(c.competitors.first);

      expect(c.placeOf(c.competitors.first), 1);
      expect(c.nextPlaceValue, 2);
    });

    test('the tie lock gives the same place until it is released', () async {
      final c = await loadWith([10, 11, 12]);

      c.assign(c.competitors[0]);
      c.toggleTieLock();
      c.assign(c.competitors[1]);
      c.toggleTieLock();
      c.assign(c.competitors[2]);

      expect(c.placeOf(c.competitors[0]), 1);
      expect(c.placeOf(c.competitors[1]), 1);
      // Two firsts consume two places; the third competitor is third.
      expect(c.placeOf(c.competitors[2]), 3);
    });

    test('undo takes back the last entry', () async {
      final c = await loadWith([10, 11]);
      c.assign(c.competitors[0]);
      c.assign(c.competitors[1]);

      c.undo();

      expect(c.placeOf(c.competitors[1]), isNull);
      expect(c.placeOf(c.competitors[0]), 1);
    });

    test('undo on a freshly loaded course does nothing and does not throw',
        () async {
      final c = await loadWith([10, 11]);

      expect(() => c.undo(), returnsNormally);
      expect(c.competitorOrder, isEmpty);
    });

    test(
        'assigning an already-ranked competitor again reports and does not '
        're-persist', () async {
      final c = await loadWith([10, 11]);
      c.assign(c.competitors.first);

      c.assign(c.competitors.first);

      expect(c.competitorOrder, [
        [100],
      ]);
      expect(c.message.value, isA<UiMessageError>());
    });

    test('removing a competitor renumbers the ones after', () async {
      final c = await loadWith([10, 11, 12]);
      c.assign(c.competitors[0]);
      c.assign(c.competitors[1]);
      c.assign(c.competitors[2]);

      c.remove(c.competitors[1]);

      expect(c.placeOf(c.competitors[0]), 1);
      expect(c.placeOf(c.competitors[1]), isNull);
      expect(c.placeOf(c.competitors[2]), 2);
    });

    test('every entry is persisted as it happens', () async {
      final c = await loadWith([10, 11]);

      c.assign(c.competitors.first);

      expect(saved().competitorOrder, [
        [100],
      ]);
    });

    test('the ranked rise in place order, the rest keep the draw order',
        () async {
      final c = await loadWith([10, 11, 12]);

      c.assign(c.competitors[2]);

      expect(c.orderedCompetitors.map((e) => e.id), [120, 100, 110]);
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
      final c =
          RaceCourseController(programme, raceRepo, clubRepo, rfid, meetingRepo)
            ..applyArguments(arguments());
      await c.load();

      // Identity, not equality: a rebuilt-but-value-equal structure would pass
      // an equality check and hide exactly the bug this guards against.
      final juniorStructureBefore = programme.current.value!.structures[1];

      c.assign(c.competitors.first);

      final juniorStructureAfter = programme.current.value!.structures[1];
      expect(identical(juniorStructureBefore, juniorStructureAfter), isTrue);
    });
  });

  group('RaceCourseController withdrawals', () {
    test('a forfeit takes no place and the others close the gap', () async {
      final c = await loadWith([10, 11, 12]);

      c.assign(c.competitors[0]);
      c.setPenalty(c.competitors[1], CoursePenaltyKind.forfeit);
      c.assign(c.competitors[2]);

      expect(c.placeOf(c.competitors[2]), 2);
      expect(c.penaltyOf(c.competitors[1])?.kind, CoursePenaltyKind.forfeit);
    });

    test('a disqualification carries its code', () async {
      final c = await loadWith([10, 11]);

      c.setPenalty(c.competitors[0], CoursePenaltyKind.disqualified,
          code: '4.7');

      expect(c.penaltyOf(c.competitors[0])?.code, '4.7');
      expect(saved().penalties.single.code, '4.7');
    });

    test('penalising a ranked competitor pulls them out of the ranking',
        () async {
      final c = await loadWith([10, 11]);
      c.assign(c.competitors[0]);
      c.assign(c.competitors[1]);

      c.setPenalty(c.competitors[0], CoursePenaltyKind.disqualified, code: 'x');

      expect(c.placeOf(c.competitors[0]), isNull);
      expect(c.placeOf(c.competitors[1]), 1);
    });

    test('clearing a penalty puts the competitor back among those to come',
        () async {
      final c = await loadWith([10]);
      c.setPenalty(c.competitors[0], CoursePenaltyKind.forfeit);

      c.clearPenalty(c.competitors[0]);

      expect(c.penaltyOf(c.competitors[0]), isNull);
      expect(c.isComplete, isFalse);
    });

    test('the course is complete when nobody is left to place', () async {
      final c = await loadWith([10, 11]);
      c.assign(c.competitors[0]);
      expect(c.isComplete, isFalse);

      c.setPenalty(c.competitors[1], CoursePenaltyKind.forfeit);

      expect(c.isComplete, isTrue);
    });

    test('a withdrawn competitor sinks below those still to come', () async {
      final c = await loadWith([10, 11]);

      c.setPenalty(c.competitors[0], CoursePenaltyKind.forfeit);

      expect(c.orderedCompetitors.map((e) => e.id), [110, 100]);
    });

    test('assigning a withdrawn competitor leaves the ranking untouched',
        () async {
      final c = await loadWith([10, 11]);
      c.setPenalty(c.competitors[0], CoursePenaltyKind.disqualified, code: 'x');

      c.assign(c.competitors[0]);

      expect(c.competitorOrder, isEmpty);
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

      expect(c.placeOf(c.competitors[0]), 1);
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

      expect(c.placeOf(c.competitors[1]), 1);
      c.stopScan();
    });

    test('a bracelet of nobody in this course reports and changes nothing',
        () async {
      final c = await loadWith([10]);
      c.startScan();

      stream.add('L999;NOBODY');
      await pumpEventQueue();

      expect(c.competitorOrder, isEmpty);
      expect(c.message.value, isA<UiMessageError>());
      c.stopScan();
    });

    test(
        'scanning a withdrawn competitor\'s bracelet reports and leaves everyone\'s place alone',
        () async {
      final c = await loadWith([10, 11, 12]);
      c.assign(c.competitors[1]);
      c.setPenalty(c.competitors[0], CoursePenaltyKind.forfeit);
      c.startScan();

      stream.add('L10;B10');
      await pumpEventQueue();

      expect(c.placeOf(c.competitors[0]), isNull);
      expect(c.placeOf(c.competitors[1]), 1);
      expect(c.message.value, isA<UiMessageError>());
      c.stopScan();
    });

    test('a bracelet already ranked is not ranked twice, and reports',
        () async {
      final c = await loadWith([10, 11]);
      c.startScan();
      stream.add('L10;B10');
      await pumpEventQueue();
      stream.add('L10;B10');
      await pumpEventQueue();

      expect(c.competitorOrder, [
        [100],
      ]);
      // A re-read must be told apart from a good one: the operator has no
      // other way to know the second scan changed nothing.
      expect(c.message.value, isA<UiMessageError>());
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

  group('validate', () {
    DateTime hhmm(String v) => DateFormat('HH:mm').parse(v);

    Entry entryOf(int id, List<int> athleteIds) => Entry(
          id: id,
          category: const Category(id: categoryId, name: 'Senior'),
          status: 1,
          statusLabel: '',
          athletes: [for (final a in athleteIds) athlete(a)],
        );

    Run course(int id, String name, List<Lane> lanes) => Run(
          id: id,
          name: name,
          label: name,
          fullLabel: name,
          status: RunStatus.waiting,
          statusLabel: '',
          site: 'OCEAN 1',
          beginTime: hhmm('08:00'),
          endTime: hhmm('08:10'),
          lanes: lanes,
        );

    Meeting meetingWith(List<Run> runs) => Meeting(
          id: 78,
          name: 'Réunion',
          description: '',
          date: DateTime(2026, 6, 13),
          beginHour: DateTime(2026, 6, 13, 8),
          endHour: DateTime(2026, 6, 13, 18),
          slots: [
            Slot(
              id: 66,
              name: 'Demies',
              beginHour: hhmm('08:00'),
              endHour: hhmm('08:20'),
              runs: runs,
            ),
          ],
        );

    /// Un déroulement de deux demies qualifiant 2 par course vers une finale.
    CompetitionProgramme chain({
      String method = 'course',
      int spots = 2,
      List<ProgrammeRace>? finals,
    }) =>
        CompetitionProgramme(
          competitionId: competitionId,
          nextLocalId: 200,
          structures: [
            EventStructure(
              raceId: raceId,
              categoryId: categoryId,
              raceLabel: 'Race',
              categoryLabel: 'Senior',
              levels: [
                RoundLevel(
                  type: RoundType.demi,
                  serverId: 39,
                  qualifiersPerRace: spots,
                  qualificationMethod: method,
                  races: [
                    const ProgrammeRace(
                      id: programmeRaceId,
                      number: 1,
                      runId: 25,
                      entryIds: [101, 102, 103],
                      athleteIds: [1, 2, 3],
                    ),
                    const ProgrammeRace(
                      id: 78,
                      number: 2,
                      runId: 26,
                      entryIds: [201, 202],
                      athleteIds: [4, 5],
                      competitorOrder: [
                        [201],
                        [202]
                      ],
                    ),
                  ],
                ),
                RoundLevel(
                  type: RoundType.finale,
                  serverId: 40,
                  races: finals ??
                      const [ProgrammeRace(id: 90, number: 1, runId: 30)],
                ),
              ],
            ),
          ],
        );

    Future<RaceCourseController> ready({
      CompetitionProgramme? seed,
      List<Lane> lanes = const [
        Lane(id: 71, number: 1),
        Lane(id: 72, number: 2),
        Lane(id: 73, number: 3),
      ],
    }) async {
      programme = _FakeProgrammeService(seed ?? chain());
      when(() => raceRepo.getEntries(raceId)).thenAnswer((_) async => [
            entryOf(101, [1]),
            entryOf(102, [2]),
            entryOf(103, [3]),
            entryOf(201, [4]),
            entryOf(202, [5]),
          ]);
      when(() => clubRepo.getAthleteClubs(any(), any()))
          .thenAnswer((_) async => const <int, Club>{});
      when(() => meetingRepo.getMeetings(competitionId)).thenAnswer(
        (_) async => [
          meetingWith([
            course(25, 'Demie 1', lanes),
            course(30, 'Finale', const [
              Lane(id: 81, number: 1),
              Lane(id: 82, number: 2),
            ]),
          ])
        ],
      );
      when(() => meetingRepo.getLaneSeats(any())).thenAnswer((_) async => [
            (laneId: 71, number: 1, entryId: 101, athleteIds: [1]),
            (laneId: 72, number: 2, entryId: 102, athleteIds: [2]),
            (laneId: 73, number: 3, entryId: 103, athleteIds: [3]),
          ]);
      when(() => meetingRepo.publishCourseResults(
            raceId: any(named: 'raceId'),
            heatName: any(named: 'heatName'),
            heatNumber: any(named: 'heatNumber'),
            outcomes: any(named: 'outcomes'),
            heatId: any(named: 'heatId'),
            link: any(named: 'link'),
          )).thenAnswer((_) async => 94369);
      when(() => meetingRepo.syncLanes(
                runId: any(named: 'runId'),
                entryIds: any(named: 'entryIds'),
                existing: any(named: 'existing'),
              ))
          .thenAnswer((i) async =>
              (i.namedArguments[const Symbol('entryIds')] as List<int>).length);

      Get.arguments;
      final controller =
          RaceCourseController(programme, raceRepo, clubRepo, rfid, meetingRepo)
            ..race.value = makeRace()
            ..competition.value = makeCompetition()
            ..categoryId = categoryId
            ..categoryLabel = 'Senior'
            ..roundType = RoundType.demi
            ..raceNumber = 1
            ..programmeRaceId = programmeRaceId;
      await controller.load();
      return controller;
    }

    List<CourseOutcome> capturedOutcomes() =>
        verify(() => meetingRepo.publishCourseResults(
              raceId: any(named: 'raceId'),
              heatName: any(named: 'heatName'),
              heatNumber: any(named: 'heatNumber'),
              outcomes: captureAny(named: 'outcomes'),
              heatId: any(named: 'heatId'),
              link: any(named: 'link'),
            )).captured.single as List<CourseOutcome>;

    test('publie un résultat par couloir, rang compris', () async {
      final controller = await ready();
      controller.competitorOrder.value = [
        [102],
        [101],
        [103]
      ];

      await controller.validate();

      final outcomes = capturedOutcomes();
      expect(outcomes.map((o) => (o.entryId, o.laneId, o.rank, o.status)), [
        (101, 71, 2, 0),
        (102, 72, 1, 0),
        (103, 73, 3, 0),
      ]);
    });

    // Un ex-aequo consomme les places qu'il occupe : deux premiers ne
    // laissent personne deuxième.
    test('un ex-aequo partage son rang', () async {
      final controller = await ready();
      controller.competitorOrder.value = [
        [101, 102],
        [103]
      ];

      await controller.validate();

      expect(capturedOutcomes().map((o) => o.rank), [1, 1, 3]);
    });

    // statut : 0 classé, 1 disqualifié, 2 forfait. Un non-classé ne prend
    // pas de rang, sinon il apparaîtrait au classement.
    test('un forfait et un disqualifié partent sans rang', () async {
      final controller = await ready();
      controller.competitorOrder.value = [
        [101]
      ];
      controller.penalties.value = const [
        CoursePenalty(competitorId: 102, kind: CoursePenaltyKind.forfeit),
        CoursePenalty(
            competitorId: 103,
            kind: CoursePenaltyKind.disqualified,
            code: 'DSQ'),
      ];

      await controller.validate();

      expect(
        capturedOutcomes()
            .map((o) => (o.entryId, o.rank, o.status, o.complement)),
        [
          (101, 1, 0, null),
          (102, null, 2, null),
          (103, null, 1, 'DSQ'),
        ],
      );
    });

    // Un tirage antérieur à `entryIds` ne nomme que des athlètes, et
    // `competitorsOf` en fait ses compétiteurs : chercher le rang d'un couloir
    // par son engagement n'y trouverait rien et publierait toute la série
    // classée sans rang.
    test('un tirage d avant les entryIds publie quand même ses rangs',
        () async {
      final controller = await ready(
        seed: const CompetitionProgramme(
          competitionId: competitionId,
          nextLocalId: 200,
          structures: [
            EventStructure(
              raceId: raceId,
              categoryId: categoryId,
              raceLabel: 'Race',
              categoryLabel: 'Senior',
              levels: [
                RoundLevel(type: RoundType.demi, serverId: 39, races: [
                  ProgrammeRace(
                    id: programmeRaceId,
                    number: 1,
                    runId: 25,
                    athleteIds: [1, 2],
                  ),
                ]),
              ],
            ),
          ],
        ),
      );
      when(() => meetingRepo.getLaneSeats(any())).thenAnswer((_) async => [
            (laneId: 71, number: 1, entryId: 101, athleteIds: [1]),
            (laneId: 72, number: 2, entryId: 102, athleteIds: [2]),
          ]);

      controller.assign(controller.competitors[0]);
      controller.assign(controller.competitors[1]);
      await controller.validate();

      expect(capturedOutcomes().map((o) => (o.entryId, o.rank, o.status)), [
        (101, 1, 0),
        (102, 2, 0),
      ]);
    });

    test('la course est rattachée à sa série', () async {
      final controller = await ready();
      controller.competitorOrder.value = [
        [101]
      ];

      await controller.validate();

      final link = verify(() => meetingRepo.publishCourseResults(
            raceId: any(named: 'raceId'),
            heatName: any(named: 'heatName'),
            heatNumber: any(named: 'heatNumber'),
            outcomes: any(named: 'outcomes'),
            heatId: any(named: 'heatId'),
            link: captureAny(named: 'link'),
          )).captured.single as CourseHeatLink?;
      expect(link!.runId, 25);
      expect(link.slotId, 66);
      expect(link.site, 'OCEAN 1');
    });

    // « Par course » : chaque demie envoie ses 2 premiers. La finale doit
    // recevoir les qualifiés des DEUX demies — celle qu'on valide et celle
    // déjà courue — sinon revalider effacerait le travail de l'autre.
    test('la finale reçoit les qualifiés de toutes les demies courues',
        () async {
      final controller = await ready();
      controller.competitorOrder.value = [
        [101],
        [102],
        [103]
      ];

      await controller.validate();

      final finale =
          programme.current.value!.structures.single.levels.last.races.single;
      expect(finale.entryIds.toSet(), {101, 102, 201, 202});
      expect(finale.athleteIds.toSet(), {1, 2, 4, 5});
    });

    test('les places de la finale sont poussées sur FFSS', () async {
      final controller = await ready();
      controller.competitorOrder.value = [
        [101],
        [102],
        [103]
      ];

      await controller.validate();

      final pushed = verify(() => meetingRepo.syncLanes(
            runId: 30,
            entryIds: captureAny(named: 'entryIds'),
            existing: any(named: 'existing'),
          )).captured.single as List<int>;
      expect(pushed.toSet(), {101, 102, 201, 202});
    });

    // Même garde-fou que la synchronisation entre appareils : un ordre
    // d'arrivée déjà saisi ne se perd pas dans une requalification.
    test('une course du tour suivant qui porte des résultats est intacte',
        () async {
      final controller = await ready(
        seed: chain(finals: const [
          ProgrammeRace(
            id: 90,
            number: 1,
            runId: 30,
            entryIds: [999],
            athleteIds: [9],
            competitorOrder: [
              [9]
            ],
          ),
        ]),
      );
      controller.competitorOrder.value = [
        [101],
        [102],
        [103]
      ];

      await controller.validate();

      final finale =
          programme.current.value!.structures.single.levels.last.races.single;
      expect(finale.entryIds, [999]);
    });

    test('sans course sur FFSS, rien ne part et c est dit', () async {
      final controller = await ready(
        seed: const CompetitionProgramme(
          competitionId: competitionId,
          nextLocalId: 200,
          structures: [
            EventStructure(
              raceId: raceId,
              categoryId: categoryId,
              raceLabel: 'Race',
              categoryLabel: 'Senior',
              levels: [
                RoundLevel(type: RoundType.demi, serverId: 39, races: [
                  ProgrammeRace(
                      id: programmeRaceId, number: 1, entryIds: [101]),
                ]),
              ],
            ),
          ],
        ),
      );
      controller.competitorOrder.value = [
        [101]
      ];

      await controller.validate();

      verifyNever(() => meetingRepo.publishCourseResults(
            raceId: any(named: 'raceId'),
            heatName: any(named: 'heatName'),
            heatNumber: any(named: 'heatNumber'),
            outcomes: any(named: 'outcomes'),
            heatId: any(named: 'heatId'),
            link: any(named: 'link'),
          ));
      expect(
          controller.message.value!.translationKey, 'course_publish_unplaced');
    });

    // Revalider ne doit pas empiler les séries côté FFSS.
    test('la série créée est retenue et réutilisée à la revalidation',
        () async {
      final controller = await ready();
      controller.competitorOrder.value = [
        [101]
      ];

      await controller.validate();
      await controller.validate();

      final ids = verify(() => meetingRepo.publishCourseResults(
            raceId: any(named: 'raceId'),
            heatName: any(named: 'heatName'),
            heatNumber: any(named: 'heatNumber'),
            outcomes: any(named: 'outcomes'),
            heatId: captureAny(named: 'heatId'),
            link: any(named: 'link'),
          )).captured;
      expect(ids, [null, 94369]);
    });
  });

  group('modes de saisie', () {
    test('le mode automatique est celui par défaut', () async {
      final controller = await loadWith([1, 2, 3]);

      expect(controller.entryMode.value, CourseEntryMode.automatic);
    });

    test('basculer en manuel et revenir', () async {
      final controller = await loadWith([1, 2, 3]);

      controller.setEntryMode(CourseEntryMode.manual);
      expect(controller.entryMode.value, CourseEntryMode.manual);

      controller.setEntryMode(CourseEntryMode.automatic);
      expect(controller.entryMode.value, CourseEntryMode.automatic);
    });

    // Changer de mode ne touche pas au classement déjà saisi : on bascule pour
    // corriger, pas pour recommencer.
    test('changer de mode conserve le classement', () async {
      final controller = await loadWith([1, 2, 3]);
      controller.assign(controller.competitors[0]);
      controller.assign(controller.competitors[1]);

      controller.setEntryMode(CourseEntryMode.manual);

      expect(controller.placeOf(controller.competitors[0]), 1);
      expect(controller.placeOf(controller.competitors[1]), 2);
    });
  });

  group('setPlace', () {
    test('affecte le rang saisi', () async {
      final controller = await loadWith([1, 2, 3]);

      controller.setPlace(controller.competitors[1], 1);

      expect(controller.placeOf(controller.competitors[1]), 1);
      expect(saved().competitorOrder, [
        [20]
      ]);
    });

    test('un rang déjà pris crée un ex-aequo et décale la suite', () async {
      final controller = await loadWith([1, 2, 3]);
      controller.assign(controller.competitors[0]);
      controller.assign(controller.competitors[1]);

      controller.setPlace(controller.competitors[2], 1);

      expect(controller.placeOf(controller.competitors[0]), 1);
      expect(controller.placeOf(controller.competitors[2]), 1);
      expect(controller.placeOf(controller.competitors[1]), 3);
    });

    test('un rang vidé sort l engagement du classement', () async {
      final controller = await loadWith([1, 2, 3]);
      controller.assign(controller.competitors[0]);
      controller.assign(controller.competitors[1]);

      controller.setPlace(controller.competitors[0], 0);

      expect(controller.placeOf(controller.competitors[0]), isNull);
      expect(controller.placeOf(controller.competitors[1]), 1);
    });

    // Même invariant que `assign` : un forfait ne prend pas de place, sans
    // quoi tous les rangs suivants seraient faux.
    test('un engagement pénalisé ne peut pas être classé à la main', () async {
      final controller = await loadWith([1, 2, 3]);
      controller.setPenalty(
          controller.competitors[1], CoursePenaltyKind.forfeit);

      controller.setPlace(controller.competitors[1], 1);

      expect(controller.placeOf(controller.competitors[1]), isNull);
      expect(controller.message.value, isA<UiMessageError>());
    });
  });

  group('RaceCourseController relais', () {
    late StreamController<String> stream;

    setUp(() {
      stream = StreamController<String>();
      when(() => rfid.readBracelets()).thenAnswer((_) => stream.stream);
      when(() => rfid.isSupported).thenReturn(true);
    });

    tearDown(() {
      if (!stream.isClosed) stream.close();
    });

    test('une equipe prend une seule place', () async {
      final controller = await loadWithEntries([
        (entryId: 10, athleteIds: [101, 102]),
        (entryId: 20, athleteIds: [201, 202]),
      ]);

      controller.assign(controller.competitors.first);
      controller.assign(controller.competitors.last);

      expect(controller.placeOf(controller.competitors.first), 1);
      expect(controller.placeOf(controller.competitors.last), 2);
    });

    test('le premier bracelet lu classe l equipe', () async {
      final controller = await loadWithEntries([
        (entryId: 10, athleteIds: [101, 102]),
      ]);
      // Le deuxieme relayeur franchit la ligne : c'est l'equipe qui est classee.
      controller.startScan();
      stream.add('L102;B102');
      await pumpEventQueue();

      expect(controller.placeOf(controller.competitors.single), 1);
    });

    test('un coequipier lu ensuite est un doublon', () async {
      final controller = await loadWithEntries([
        (entryId: 10, athleteIds: [101, 102]),
        (entryId: 20, athleteIds: [201]),
      ]);
      controller.startScan();
      stream.add('L101;B101');
      await pumpEventQueue();
      stream.add('L102;B102');
      await pumpEventQueue();

      expect(controller.message.value,
          const UiMessageError('course_athlete_already_ranked'));
      expect(controller.competitorOrder.length, 1);
    });

    test('la course est complete quand toutes les equipes sont placees',
        () async {
      final controller = await loadWithEntries([
        (entryId: 10, athleteIds: [101, 102]),
        (entryId: 20, athleteIds: [201, 202]),
      ]);

      controller.assign(controller.competitors.first);
      expect(controller.isComplete, isFalse);
      controller.assign(controller.competitors.last);
      expect(controller.isComplete, isTrue);
    });

    test('un forfait sort toute l equipe du classement', () async {
      final controller = await loadWithEntries([
        (entryId: 10, athleteIds: [101, 102]),
        (entryId: 20, athleteIds: [201]),
      ]);

      controller.setPenalty(
          controller.competitors.first, CoursePenaltyKind.forfeit);
      controller.assign(controller.competitors.last);

      expect(controller.placeOf(controller.competitors.last), 1);
      expect(saved().penalties.single.competitorId, 10);
    });

    // Le classement stocke par l'ancien code nomme des athletes : il ne nomme
    // aucun engagement de la course, donc il est ecarte plutot que mal relu.
    test('un classement herite de relais est ecarte au chargement', () async {
      final controller = await loadWithEntries(
        [
          (entryId: 10, athleteIds: [101, 102]),
        ],
        competitorOrder: const [
          [101],
          [102]
        ],
      );

      expect(controller.competitorOrder, isEmpty);
    });

    // Un engagement retire sur FFSS entre le tirage et la reouverture ne doit
    // pas emporter le classement des autres avec lui.
    test('un engagement disparu laisse le classement des autres', () async {
      final controller = await loadWithEntries(
        [
          (entryId: 10, athleteIds: [101]),
          (entryId: 30, athleteIds: [301]),
        ],
        competitorOrder: const [
          [10],
          [20],
          [30]
        ],
      );

      expect(controller.competitorOrder, [
        [10],
        [30]
      ]);
      // Les places se resserrent : le troisieme devient deuxieme.
      expect(controller.placeOf(controller.competitors.last), 2);
    });

    test('un engagement disparu est dit a l ecran', () async {
      final controller = await loadWithEntries(
        [
          (entryId: 10, athleteIds: [101]),
        ],
        competitorOrder: const [
          [10],
          [20]
        ],
      );

      expect(controller.message.value,
          const UiMessageError('course_ranking_competitor_gone'));
    });

    test('la penalite d un engagement disparu part avec lui', () async {
      programme = _FakeProgrammeService(programmeWith(const ProgrammeRace(
        id: programmeRaceId,
        number: 1,
        entryIds: [10],
        athleteIds: [101],
        competitorOrder: [
          [10],
          [20]
        ],
        penalties: [
          CoursePenalty(competitorId: 10, kind: CoursePenaltyKind.forfeit),
          CoursePenalty(competitorId: 20, kind: CoursePenaltyKind.forfeit),
        ],
      )));
      when(() => raceRepo.getEntries(raceId)).thenAnswer((_) async => [
            Entry(
              id: 10,
              category: const Category(id: categoryId, name: 'Senior'),
              status: 1,
              statusLabel: 'Engagé',
              athletes: [athlete(101)],
            ),
          ]);
      final controller =
          RaceCourseController(programme, raceRepo, clubRepo, rfid, meetingRepo)
            ..applyArguments(arguments());
      await controller.load();

      expect(controller.penalties.map((p) => p.competitorId), [10]);
    });

    test('un classement herite est dit a l ecran, lui aussi', () async {
      final controller = await loadWithEntries(
        [
          (entryId: 10, athleteIds: [101, 102]),
        ],
        competitorOrder: const [
          [101],
          [102]
        ],
      );

      expect(controller.message.value,
          const UiMessageError('course_ranking_dropped'));
    });

    // Une course pas encore courue est le cas ordinaire : rien a signaler.
    test('une course sans classement ne dit rien', () async {
      final controller = await loadWithEntries([
        (entryId: 10, athleteIds: [101, 102]),
      ]);

      expect(controller.message.value, isNull);
    });

    test('un classement d engagements est relu tel quel', () async {
      final controller = await loadWithEntries(
        [
          (entryId: 10, athleteIds: [101, 102]),
          (entryId: 20, athleteIds: [201]),
        ],
        competitorOrder: const [
          [20],
          [10]
        ],
      );

      expect(controller.placeOf(controller.competitors.last), 1);
    });
  });
}
