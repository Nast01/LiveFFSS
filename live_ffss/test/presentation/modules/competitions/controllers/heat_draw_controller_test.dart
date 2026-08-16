import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/data/services/attendance_service.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/attendance_status.dart';
import 'package:live_ffss/app/domain/models/category.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/entry.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/race.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/module/competitions/controllers/heat_draw_controller.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';
import 'package:mocktail/mocktail.dart';

class _MockRaceRepo extends Mock implements RaceRepository {}

class _MockAttendance extends Mock implements AttendanceService {}

/// Real store semantics without secure storage: `save` keeps the programme in
/// memory so the controller's read-modify-write can be asserted end to end.
class _FakeProgrammeService implements ProgrammeService {
  _FakeProgrammeService(CompetitionProgramme initial) {
    current.value = initial;
  }

  @override
  final Rxn<CompetitionProgramme> current = Rxn<CompetitionProgramme>();

  int saveCount = 0;

  @override
  Future<void> load(int competitionId) async {}

  @override
  Future<void> save(CompetitionProgramme programme) async {
    saveCount++;
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

  late _MockRaceRepo raceRepo;
  late _MockAttendance attendance;
  late _FakeProgrammeService programme;

  Athlete athlete(int id, {int clubId = 0}) => Athlete(
        id: id,
        licenseeNumber: 'L$id',
        firstName: 'A$id',
        lastName: 'B$id',
        gender: Gender.female,
        year: 2000,
        nationalityCode: '',
        nationality: '',
        isValid: true,
        clubId: clubId,
      );

  Entry entry(int id, List<Athlete> athletes, {int category = categoryId}) =>
      Entry(
        id: id,
        category: Category(id: category, name: 'Cat$category'),
        status: 1,
        statusLabel: 'Engagé',
        athletes: athletes,
      );

  Race makeRace({String speciality = 'Côtier'}) => Race(
        id: raceId,
        name: 'Race',
        nameEnglish: 'Race',
        distance: 100,
        gender: Gender.female,
        athletesPerTeam: 1,
        specialityId: 1,
        specialityLabel: speciality,
        disciplineId: 1,
        isEligibleToNationalRecord: false,
        categories: const [],
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

  CompetitionProgramme programmeWith({
    int spotsPerRace = 4,
    List<RoundLevel> levels = const [
      RoundLevel(type: RoundType.serie),
      RoundLevel(type: RoundType.finale),
    ],
  }) =>
      CompetitionProgramme(
        competitionId: competitionId,
        nextLocalId: 100,
        structures: [
          EventStructure(
            raceId: raceId,
            categoryId: categoryId,
            raceLabel: 'Race',
            categoryLabel: 'Senior',
            spotsPerRace: spotsPerRace,
            levels: levels,
          ),
        ],
      );

  HeatDrawController build() {
    Get.arguments;
    return HeatDrawController(
      raceRepo,
      attendance,
      programme,
      random: Random(7),
    )
      ..race.value = makeRace()
      ..competition.value = makeCompetition()
      ..categoryId = categoryId
      ..categoryLabel = 'Senior';
  }

  setUp(() {
    raceRepo = _MockRaceRepo();
    attendance = _MockAttendance();
    programme = _FakeProgrammeService(programmeWith());
    when(() => raceRepo.getEntries(any())).thenAnswer((_) async => const []);
    when(() => attendance.forRace(any()))
        .thenReturn(const <int, AttendanceStatus>{});
  });

  tearDown(Get.reset);

  group('HeatDrawController.load', () {
    test('a round chosen by the caller survives the load', () async {
      // The Séries tab opens the draw on the round it is showing; load() must
      // not snap the selection back to the first round of the structure.
      final controller = build()..selectedLevel.value = RoundType.finale;

      await controller.load();

      expect(controller.selectedLevel.value, RoundType.finale);
    });

    test('with no round chosen, the first of the structure is used', () async {
      final controller = build();

      await controller.load();

      expect(controller.selectedLevel.value, RoundType.serie);
    });

    test('keeps only the athletes marked present', () async {
      when(() => raceRepo.getEntries(raceId)).thenAnswer((_) async => [
            entry(1, [athlete(1), athlete(2), athlete(3)]),
          ]);
      when(() => attendance.forRace(raceId)).thenReturn({
        1: AttendanceStatus.present,
        2: AttendanceStatus.absent,
        // 3 was never pointed → waiting → excluded.
      });

      final controller = build();
      await controller.load();

      expect(controller.presentAthletes.map((a) => a.id), [1]);
      expect(controller.engagedCount.value, 3);
      expect(controller.presentCount, 1);
    });

    test('ignores athletes of another category', () async {
      when(() => raceRepo.getEntries(raceId)).thenAnswer((_) async => [
            entry(1, [athlete(1)]),
            entry(2, [athlete(2)], category: 999),
          ]);
      when(() => attendance.forRace(raceId)).thenReturn({
        1: AttendanceStatus.present,
        2: AttendanceStatus.present,
      });

      final controller = build();
      await controller.load();

      expect(controller.presentAthletes.map((a) => a.id), [1]);
      expect(controller.engagedCount.value, 1);
    });

    test('exposes the levels the structure declares and preselects the first',
        () async {
      final controller = build();
      await controller.load();

      expect(controller.availableLevels, [RoundType.serie, RoundType.finale]);
      expect(controller.selectedLevel.value, RoundType.serie);
    });

    test('surfaces an entries failure without throwing', () async {
      when(() => raceRepo.getEntries(any()))
          .thenThrow(const NetworkException('offline'));

      final controller = build();
      await controller.load();

      expect(controller.error.value, isA<NetworkException>());
      expect(controller.isLoading.value, isFalse);
    });
  });

  group('HeatDrawController.drawFromPresent', () {
    Future<HeatDrawController> withPresent(int count) async {
      when(() => raceRepo.getEntries(raceId)).thenAnswer((_) async => [
            entry(1, [for (var i = 1; i <= count; i++) athlete(i)]),
          ]);
      when(() => attendance.forRace(raceId)).thenReturn({
        for (var i = 1; i <= count; i++) i: AttendanceStatus.present,
      });
      final controller = build();
      await controller.load();
      return controller;
    }

    test('draws the present athletes into balanced heats', () async {
      final controller = await withPresent(10);

      controller.drawFromPresent();

      // 10 present, 4 spots per race → 3 heats of 4/3/3.
      expect(controller.heats, hasLength(3));
      expect(controller.heats.map((h) => h.length).toList()..sort(), [3, 3, 4]);
      expect(
        controller.heats.expand((h) => h).map((a) => a.id).toSet(),
        hasLength(10),
      );
    });

    test('reports an error instead of drawing when nobody is present',
        () async {
      final controller = await withPresent(0);

      controller.drawFromPresent();

      expect(controller.heats, isEmpty);
      expect(controller.message.value, isA<UiMessageError>());
    });

    test('changing level clears a draw made for the previous one', () async {
      final controller = await withPresent(6);
      controller.drawFromPresent();
      expect(controller.heats, isNotEmpty);

      controller.selectLevel(RoundType.finale);

      expect(controller.heats, isEmpty);
      expect(controller.selectedLevel.value, RoundType.finale);
    });
  });

  group('HeatDrawController.discardDraw', () {
    test('clears a draw and the plan it was drawn with', () async {
      when(() => raceRepo.getEntries(raceId)).thenAnswer((_) async => [
            entry(1, [for (var i = 1; i <= 6; i++) athlete(i)]),
          ]);
      when(() => attendance.forRace(raceId)).thenReturn({
        for (var i = 1; i <= 6; i++) i: AttendanceStatus.present,
      });
      final controller = build();
      await controller.load();
      controller.drawFromPresent();
      expect(controller.heats, isNotEmpty);
      expect(controller.pendingPlan.value, isNotNull);

      controller.discardDraw();

      expect(controller.heats, isEmpty);
      expect(controller.pendingPlan.value, isNull);
    });
  });

  group('HeatDrawController.moveAthlete', () {
    Future<HeatDrawController> drawn(int count) async {
      when(() => raceRepo.getEntries(raceId)).thenAnswer((_) async => [
            entry(1, [for (var i = 1; i <= count; i++) athlete(i)]),
          ]);
      when(() => attendance.forRace(raceId)).thenReturn({
        for (var i = 1; i <= count; i++) i: AttendanceStatus.present,
      });
      final controller = build();
      await controller.load();
      controller.drawFromPresent();
      return controller;
    }

    test('moves an athlete to the end of the target heat', () async {
      final controller = await drawn(8);
      final moved = controller.heats.first.first;

      controller.moveAthlete(moved, 1);

      expect(controller.heats[1].last.id, moved.id);
      expect(controller.heats.first.any((a) => a.id == moved.id), isFalse);
      expect(controller.heatIndexOf(moved), 1);
    });

    test('never duplicates or drops an athlete', () async {
      final controller = await drawn(8);
      final moved = controller.heats.first.first;

      controller.moveAthlete(moved, 1);

      final ids = controller.heats.expand((h) => h).map((a) => a.id).toList();
      expect(ids.toSet(), hasLength(8));
      expect(ids, hasLength(8));
    });

    test('moving an athlete into their own heat changes nothing', () async {
      final controller = await drawn(8);
      final before = controller.heats.map((h) => h.map((a) => a.id).toList());
      final stayer = controller.heats[1].first;

      controller.moveAthlete(stayer, 1);

      expect(controller.heats.map((h) => h.map((a) => a.id).toList()), before);
    });

    test('an out-of-range heat index is ignored', () async {
      final controller = await drawn(8);
      final before = controller.heats.map((h) => h.map((a) => a.id).toList());

      controller.moveAthlete(controller.heats.first.first, 99);

      expect(controller.heats.map((h) => h.map((a) => a.id).toList()), before);
    });
  });

  group('HeatDrawController.save', () {
    Future<HeatDrawController> drawn(
      int count, {
      List<RoundLevel>? levels,
    }) async {
      if (levels != null) {
        programme = _FakeProgrammeService(programmeWith(levels: levels));
      }
      when(() => raceRepo.getEntries(raceId)).thenAnswer((_) async => [
            entry(1, [for (var i = 1; i <= count; i++) athlete(i)]),
          ]);
      when(() => attendance.forRace(raceId)).thenReturn({
        for (var i = 1; i <= count; i++) i: AttendanceStatus.present,
      });
      final controller = build();
      await controller.load();
      controller.drawFromPresent();
      return controller;
    }

    List<ProgrammeRace> savedRaces(RoundType type) =>
        programme.current.value!.structures.single.levels
            .firstWhere((l) => l.type == type)
            .races;

    test('writes one race per heat, with the athletes in lane order', () async {
      final controller = await drawn(10);
      final expected =
          controller.heats.map((h) => h.map((a) => a.id).toList()).toList();

      await controller.save();

      final races = savedRaces(RoundType.serie);
      expect(races, hasLength(3));
      expect(races.map((r) => r.athleteIds), expected);
      expect(races.map((r) => r.number), [1, 2, 3]);
      expect(controller.saved.value, isTrue);
      expect(controller.message.value, isA<UiMessageSuccess>());
    });

    test('adjusts the race count upwards, allocating new local ids', () async {
      final controller = await drawn(
        10,
        levels: const [
          RoundLevel(type: RoundType.serie, races: [
            ProgrammeRace(id: 1, number: 1),
          ]),
        ],
      );

      await controller.save();

      final races = savedRaces(RoundType.serie);
      expect(races, hasLength(3));
      // The pre-existing race keeps its id so downstream wiring survives.
      expect(races.first.id, 1);
      expect(races.map((r) => r.id).toSet(), hasLength(3));
    });

    test('adjusts the race count downwards, dropping the surplus', () async {
      final controller = await drawn(
        3,
        levels: const [
          RoundLevel(type: RoundType.serie, races: [
            ProgrammeRace(id: 1, number: 1),
            ProgrammeRace(id: 2, number: 2),
            ProgrammeRace(id: 3, number: 3),
          ]),
        ],
      );

      await controller.save();

      expect(savedRaces(RoundType.serie), hasLength(1));
    });

    test('leaves the other levels untouched', () async {
      final controller = await drawn(10);

      await controller.save();

      expect(savedRaces(RoundType.finale), isEmpty);
    });

    test(
        'a pool race keeps the round declared size, even though fewer '
        'athletes are present than seats', () async {
      programme = _FakeProgrammeService(programmeWith(
        levels: const [RoundLevel(type: RoundType.serie, spotsPerRace: 8)],
      ));
      final present = [for (var i = 1; i <= 6; i++) athlete(i)];
      when(() => raceRepo.getEntries(raceId))
          .thenAnswer((_) async => [entry(1, present)]);
      when(() => attendance.forRace(raceId)).thenReturn({
        for (final a in present) a.id: AttendanceStatus.present,
      });
      final controller = HeatDrawController(
        raceRepo,
        attendance,
        programme,
        random: Random(7),
      )
        ..race.value = makeRace(speciality: 'Eau-plate')
        ..competition.value = makeCompetition()
        ..categoryId = categoryId
        ..categoryLabel = 'Senior';
      await controller.load();
      // 6 present at 8 declared spots draws into a single heat of 6 — the
      // proposal a validated path would show, but this pool round takes the
      // no-dialog path and must not let the draw shrink its declared size.
      controller.drawFromPresent();

      await controller.save();

      final level = programme.current.value!.structures.single.levels.single;
      expect(level.races, hasLength(1));
      expect(level.spotsPerRace, 8);
    });

    test('hasExistingComposition reports a level already drawn', () async {
      final controller = await drawn(
        4,
        levels: const [
          RoundLevel(type: RoundType.serie, races: [
            ProgrammeRace(id: 1, number: 1, athleteIds: [1, 2]),
          ]),
        ],
      );

      expect(controller.hasExistingComposition, isTrue);
    });

    test('hasExistingComposition is false for an untouched level', () async {
      final controller = await drawn(4);

      expect(controller.hasExistingComposition, isFalse);
    });

    test('saving without a draw writes nothing', () async {
      when(() => raceRepo.getEntries(raceId)).thenAnswer((_) async => const []);
      final controller = build();
      await controller.load();

      await controller.save();

      expect(programme.saveCount, 0);
      expect(controller.saved.value, isFalse);
    });
  });

  group('HeatDrawController structure validation', () {
    /// Loads a controller whose category has [present] athletes checked in.
    Future<HeatDrawController> withPresent(
      int present, {
      String speciality = 'Côtier',
      List<RoundLevel> levels = const [
        RoundLevel(type: RoundType.serie, spotsPerRace: 16),
        RoundLevel(type: RoundType.finale, spotsPerRace: 16),
      ],
    }) async {
      programme = _FakeProgrammeService(programmeWith(levels: levels));
      final all = [for (var i = 1; i <= present; i++) athlete(i)];
      when(() => raceRepo.getEntries(raceId))
          .thenAnswer((_) async => [entry(1, all)]);
      when(() => attendance.forRace(raceId)).thenReturn({
        for (final a in all) a.id: AttendanceStatus.present,
      });
      final controller = HeatDrawController(
        raceRepo,
        attendance,
        programme,
        random: Random(7),
      )
        ..race.value = makeRace(speciality: speciality)
        ..competition.value = makeCompetition()
        ..categoryId = categoryId
        ..categoryLabel = 'Senior';
      await controller.load();
      return controller;
    }

    test('a coastal série must be validated', () async {
      final controller = await withPresent(20);

      expect(controller.selectedLevel.value, RoundType.serie);
      expect(controller.requiresStructureValidation, isTrue);
    });

    test('a pool série is drawn without validation', () async {
      final controller = await withPresent(20, speciality: 'Eau-plate');

      expect(controller.requiresStructureValidation, isFalse);
    });

    test('a coastal finale is drawn without validation', () async {
      final controller = await withPresent(20);
      controller.selectLevel(RoundType.finale);

      expect(controller.requiresStructureValidation, isFalse);
    });

    test('declaredPlan reads the round as authored', () async {
      final controller = await withPresent(20, levels: const [
        RoundLevel(type: RoundType.serie, spotsPerRace: 16, races: [
          ProgrammeRace(id: 1, number: 1),
          ProgrammeRace(id: 2, number: 2),
          ProgrammeRace(id: 3, number: 3),
        ]),
      ]);

      expect(controller.declaredPlan, (raceCount: 3, spotsPerRace: 16));
    });

    test('proposedPlan tightens the round onto the athletes present', () async {
      final controller = await withPresent(20, levels: const [
        RoundLevel(type: RoundType.serie, spotsPerRace: 16, races: [
          ProgrammeRace(id: 1, number: 1),
          ProgrammeRace(id: 2, number: 2),
          ProgrammeRace(id: 3, number: 3),
        ]),
      ]);

      expect(controller.proposedPlan, (raceCount: 2, spotsPerRace: 10));
    });

    test('drawWithPlan draws exactly the plan it is given', () async {
      final controller = await withPresent(20);

      controller.drawWithPlan((raceCount: 4, spotsPerRace: 5));

      expect(controller.heats, hasLength(4));
      expect(controller.heats.expand((h) => h), hasLength(20));
      expect(controller.pendingPlan.value, (raceCount: 4, spotsPerRace: 5));
    });

    test('drawWithPlan reports when nobody is present', () async {
      final controller = await withPresent(0);

      controller.drawWithPlan((raceCount: 2, spotsPerRace: 8));

      expect(controller.heats, isEmpty);
      expect(controller.pendingPlan.value, isNull);
      expect(controller.message.value, isA<UiMessageError>());
    });

    test('changing round drops the plan the heats were drawn with', () async {
      final controller = await withPresent(20);
      controller.drawWithPlan((raceCount: 2, spotsPerRace: 10));

      controller.selectLevel(RoundType.finale);

      expect(controller.heats, isEmpty);
      expect(controller.pendingPlan.value, isNull);
    });

    test('save writes the validated race size onto the round', () async {
      final controller = await withPresent(20, levels: const [
        RoundLevel(type: RoundType.serie, spotsPerRace: 16, races: [
          ProgrammeRace(id: 1, number: 1),
          ProgrammeRace(id: 2, number: 2),
          ProgrammeRace(id: 3, number: 3),
        ]),
      ]);
      controller.drawWithPlan(controller.proposedPlan);

      await controller.save();

      final level = programme.current.value!.structures.single.levels.single;
      expect(level.races, hasLength(2));
      expect(level.spotsPerRace, 10);
    });

    test('save strips the wiring of a race the shrink removed', () async {
      final controller = await withPresent(20, levels: const [
        RoundLevel(type: RoundType.serie, spotsPerRace: 16, races: [
          ProgrammeRace(id: 1, number: 1),
          ProgrammeRace(id: 2, number: 2),
          ProgrammeRace(id: 3, number: 3),
        ]),
        RoundLevel(type: RoundType.finale, spotsPerRace: 16, races: [
          ProgrammeRace(id: 4, number: 1, sourceRaceIds: [1, 2, 3]),
        ]),
      ]);
      controller.drawWithPlan(controller.proposedPlan);

      await controller.save();

      final levels = programme.current.value!.structures.single.levels;
      // Série 3 is gone, so the finale may no longer claim it as a source.
      expect(levels.first.races, hasLength(2));
      expect(levels.last.races.single.sourceRaceIds, [1, 2]);
    });

    test('save leaves the wiring alone when no race is removed', () async {
      final controller = await withPresent(32, levels: const [
        RoundLevel(type: RoundType.serie, spotsPerRace: 16, races: [
          ProgrammeRace(id: 1, number: 1),
          ProgrammeRace(id: 2, number: 2),
        ]),
        RoundLevel(type: RoundType.finale, spotsPerRace: 16, races: [
          ProgrammeRace(id: 4, number: 1, sourceRaceIds: [1, 2]),
        ]),
      ]);
      controller.drawWithPlan(controller.proposedPlan);

      await controller.save();

      final levels = programme.current.value!.structures.single.levels;
      expect(levels.first.races, hasLength(2));
      expect(levels.last.races.single.sourceRaceIds, [1, 2]);
    });
  });
}
