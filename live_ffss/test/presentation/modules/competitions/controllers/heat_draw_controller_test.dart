import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:intl/intl.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/data/services/attendance_service.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/attendance_status.dart';
import 'package:live_ffss/app/domain/models/category.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/club.dart';
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
import 'package:live_ffss/app/module/competitions/controllers/heat_draw_controller.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';
import 'package:mocktail/mocktail.dart';

class _MockRaceRepo extends Mock implements RaceRepository {}

class _MockAttendance extends Mock implements AttendanceService {}

class _MockClubRepo extends Mock implements ClubRepository {}

class _MockMeetingRepo extends Mock implements MeetingRepository {}

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
  late _MockClubRepo clubRepo;
  late _MockMeetingRepo meetingRepo;
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
      clubRepo,
      attendance,
      programme,
      meetingRepo,
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
    clubRepo = _MockClubRepo();
    when(() => clubRepo.getClubs(any())).thenAnswer((_) async => const []);
    when(() => clubRepo.getClubDetails(any()))
        .thenAnswer((_) async => const <int, Club>{});
    when(() => clubRepo.getAthleteClubs(any(), any()))
        .thenAnswer((_) async => const <int, Club>{});
    programme = _FakeProgrammeService(programmeWith());
    meetingRepo = _MockMeetingRepo();
    when(() => meetingRepo.getMeetings(any())).thenAnswer((_) async => const []);
    when(() => meetingRepo.syncLanes(
          runId: any(named: 'runId'),
          entryIds: any(named: 'entryIds'),
          existing: any(named: 'existing'),
        )).thenAnswer((i) async =>
        (i.namedArguments[const Symbol('entryIds')] as List<int>).length);
    when(() => raceRepo.getEntries(any())).thenAnswer((_) async => const []);
    when(() => attendance.forRace(any()))
        .thenReturn(const <int, AttendanceStatus>{});
  });

  setUpAll(() {
    registerFallbackValue(const <int>[]);
    registerFallbackValue(const <Athlete>[]);
    registerFallbackValue(const <Lane>[]);
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

    test('keeps only the entries marked present', () async {
      when(() => raceRepo.getEntries(raceId)).thenAnswer((_) async => [
            entry(1, [athlete(1)]),
            entry(2, [athlete(2)]),
            entry(3, [athlete(3)]),
          ]);
      when(() => attendance.forRace(raceId)).thenReturn({
        1: AttendanceStatus.present,
        2: AttendanceStatus.absent,
        // 3 was never pointed → waiting → excluded.
      });

      final controller = build();
      await controller.load();

      expect(controller.presentEntries.map((e) => e.id), [1]);
      expect(controller.engagedCount.value, 3);
      expect(controller.presentCount, 1);
      expect(controller.presentPeopleCount.value, 1);
    });

    // Une place assoit un engagement : l'équipe entière, ou rien. Un relais
    // auquel il manque un nageur n'est pas prêt à partir.
    test('une équipe ne part que si tous ses athlètes sont présents',
        () async {
      when(() => raceRepo.getEntries(raceId)).thenAnswer((_) async => [
            entry(1, [athlete(1), athlete(2)]),
            entry(2, [athlete(3), athlete(4)]),
          ]);
      when(() => attendance.forRace(raceId)).thenReturn({
        1: AttendanceStatus.present,
        2: AttendanceStatus.present,
        3: AttendanceStatus.present,
        // 4 manque : l'équipe 2 reste à quai.
      });

      final controller = build();
      await controller.load();

      expect(controller.presentEntries.map((e) => e.id), [1]);
      // La bannière compte les têtes, pas les équipes.
      expect(controller.presentPeopleCount.value, 3);
      expect(controller.presentCount, 1);
    });

    test('un engagement forfait n est pas tiré, présent ou pas', () async {
      when(() => raceRepo.getEntries(raceId)).thenAnswer((_) async => [
            entry(1, [athlete(1)]),
            entry(2, [athlete(2)]).copyWith(isForfeit: true),
          ]);
      when(() => attendance.forRace(raceId)).thenReturn({
        1: AttendanceStatus.present,
        2: AttendanceStatus.present,
      });

      final controller = build();
      await controller.load();

      expect(controller.presentEntries.map((e) => e.id), [1]);
    });

    test('resolves each present athlete club so the avatar can show a logo',
        () async {
      when(() => raceRepo.getEntries(raceId)).thenAnswer((_) async => [
            entry(1, [athlete(1, clubId: 7)]),
          ]);
      when(() => attendance.forRace(raceId))
          .thenReturn({1: AttendanceStatus.present});
      when(() => clubRepo.getAthleteClubs(competitionId, any()))
          .thenAnswer((_) async => const {
                1: Club(id: 7, name: 'Nice', logoUrl: 'https://logo/7.png'),
              });

      final controller = build();
      await controller.load();

      final lead = controller.presentEntries.single.athletes.single;
      expect(lead.club?.name, 'Nice');
      expect(lead.club?.logoUrl, 'https://logo/7.png');
    });

    test('a club fetch failure still loads the athletes, without clubs',
        () async {
      when(() => raceRepo.getEntries(raceId)).thenAnswer((_) async => [
            entry(1, [athlete(1, clubId: 7)]),
          ]);
      when(() => attendance.forRace(raceId))
          .thenReturn({1: AttendanceStatus.present});
      when(() => clubRepo.getAthleteClubs(any(), any()))
          .thenThrow(const NetworkException('boom'));

      final controller = build();
      await controller.load();

      expect(controller.error.value, isNull);
      expect(controller.presentEntries.single.athletes.single.club, isNull);
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

      expect(controller.presentEntries.map((e) => e.id), [1]);
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

  group('HeatDrawController.drawFromDeclared', () {
    Future<HeatDrawController> withPresent(int count) async {
      when(() => raceRepo.getEntries(raceId)).thenAnswer((_) async => [
            for (var i = 1; i <= count; i++) entry(i, [athlete(i)]),
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

      controller.drawFromDeclared();

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

      controller.drawFromDeclared();

      expect(controller.heats, isEmpty);
      expect(controller.message.value, isA<UiMessageError>());
    });

    test('changing level clears a draw made for the previous one', () async {
      final controller = await withPresent(6);
      controller.drawFromDeclared();
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
      controller.drawFromDeclared();
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
            for (var i = 1; i <= count; i++) entry(i, [athlete(i)]),
          ]);
      when(() => attendance.forRace(raceId)).thenReturn({
        for (var i = 1; i <= count; i++) i: AttendanceStatus.present,
      });
      final controller = build();
      await controller.load();
      controller.drawFromDeclared();
      return controller;
    }

    test('moves an entry to the end of the target heat', () async {
      final controller = await drawn(8);
      final moved = controller.heats.first.first;

      controller.moveEntry(moved, 1);

      expect(controller.heats[1].last.id, moved.id);
      expect(controller.heats.first.any((a) => a.id == moved.id), isFalse);
      expect(controller.heatIndexOf(moved), 1);
    });

    test('never duplicates or drops an athlete', () async {
      final controller = await drawn(8);
      final moved = controller.heats.first.first;

      controller.moveEntry(moved, 1);

      final ids = controller.heats.expand((h) => h).map((a) => a.id).toList();
      expect(ids.toSet(), hasLength(8));
      expect(ids, hasLength(8));
    });

    test('moving an athlete into their own heat changes nothing', () async {
      final controller = await drawn(8);
      final before = controller.heats.map((h) => h.map((a) => a.id).toList());
      final stayer = controller.heats[1].first;

      controller.moveEntry(stayer, 1);

      expect(controller.heats.map((h) => h.map((a) => a.id).toList()), before);
    });

    test('an out-of-range heat index is ignored', () async {
      final controller = await drawn(8);
      final before = controller.heats.map((h) => h.map((a) => a.id).toList());

      controller.moveEntry(controller.heats.first.first, 99);

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
            for (var i = 1; i <= count; i++) entry(i, [athlete(i)]),
          ]);
      when(() => attendance.forRace(raceId)).thenReturn({
        for (var i = 1; i <= count; i++) i: AttendanceStatus.present,
      });
      final controller = build();
      await controller.load();
      controller.drawFromDeclared();
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
      // Aucun tour placé dans cette fixture : le tirage est enregistré en
      // local et le message dit que les places n'ont pas pu partir.
      expect(controller.message.value!.translationKey,
          'heat_draw_lanes_unplaced');
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

    // Un tirage seul ne réduit plus un tour déclaré : c'est le déroulement qui
    // fixe le nombre de séries. Mais l'opérateur peut adopter la proposition
    // depuis la boîte de validation, et les courses en trop doivent partir.
    test('adopter un plan plus étroit retire les courses en trop', () async {
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
      expect(controller.heats, hasLength(3));

      controller.drawWithPlan((raceCount: 1, spotsPerRace: 4));
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
        clubRepo,
        attendance,
        programme,
        meetingRepo,
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
      controller.drawFromDeclared();

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

    test('a redraw clears the finishOrder and penalties of the race it reuses',
        () async {
      final controller = await drawn(
        4,
        levels: const [
          RoundLevel(type: RoundType.serie, races: [
            ProgrammeRace(
              id: 1,
              number: 1,
              athleteIds: [99],
              finishOrder: [
                [99],
              ],
              penalties: [
                CoursePenalty(athleteId: 99, kind: CoursePenaltyKind.forfeit),
              ],
            ),
          ]),
        ],
      );

      await controller.save();

      final reused = savedRaces(RoundType.serie).first;
      expect(reused.finishOrder, isEmpty);
      expect(reused.penalties, isEmpty);
    });

    // C'est l'engagement que la place FFSS portera : sans lui, le tirage ne
    // peut pas être poussé sur le site.
    test('écrit l engagement de chaque ligne, l équipe entière comprise',
        () async {
      when(() => raceRepo.getEntries(raceId)).thenAnswer((_) async => [
            entry(1, [athlete(11), athlete(12)]),
            entry(2, [athlete(21), athlete(22)]),
          ]);
      when(() => attendance.forRace(raceId)).thenReturn({
        for (final id in [11, 12, 21, 22]) id: AttendanceStatus.present,
      });
      final controller = build();
      await controller.load();
      controller.drawWithPlan((raceCount: 1, spotsPerRace: 4));

      await controller.save();

      final race = savedRaces(RoundType.serie).single;
      expect(race.entryIds.toSet(), {1, 2});
      // Les athlètes restent à plat, dans l'ordre des lignes, pour tout ce
      // qui affiche ou classe des personnes.
      expect(race.athleteIds.toSet(), {11, 12, 21, 22});
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

  group('HeatDrawController.clubDistribution', () {
    Entry withClub(int id, int clubId, String name) => entry(id, [
          athlete(id, clubId: clubId)
              .copyWith(club: clubId > 0 ? Club(id: clubId, name: name) : null),
        ]);

    test('is empty before a draw', () {
      expect(build().clubDistribution, isEmpty);
    });

    test('counts each club per heat, biggest first', () {
      final controller = build();
      controller.heats.value = [
        [withClub(1, 7, 'Nice'), withClub(2, 8, 'Antibes')],
        [withClub(3, 7, 'Nice'), withClub(4, 7, 'Nice')],
      ];

      final spread = controller.clubDistribution;

      expect(spread.map((s) => s.label), ['Nice', 'Antibes']);
      expect(spread.first.perHeat, [1, 2]);
      expect(spread.first.total, 3);
      expect(spread.last.perHeat, [1, 0]);
      expect(spread.last.total, 1);
    });

    test('every row spans every heat, including the ones a club skips', () {
      final controller = build();
      controller.heats.value = [
        [withClub(1, 7, 'Nice')],
        <Entry>[],
        [withClub(2, 8, 'Antibes')],
      ];

      final spread = controller.clubDistribution;

      // Both clubs hold one athlete, so the label tie-break orders them.
      expect(spread.map((s) => s.label), ['Antibes', 'Nice']);
      expect(spread.first.perHeat, [0, 0, 1]);
      expect(spread.last.perHeat, [1, 0, 0]);
    });

    test('ties are broken by label so the order never wobbles', () {
      final controller = build();
      controller.heats.value = [
        [withClub(1, 9, 'Zuydcoote'), withClub(2, 8, 'Antibes')],
      ];

      expect(controller.clubDistribution.map((s) => s.label),
          ['Antibes', 'Zuydcoote']);
    });

    test('groups on the resolved club, not the athlete raw clubId', () {
      // Both sit in the FFSS bucket organisme, which the mapper splits into the
      // real clubs — grouping on the raw id would merge two different clubs.
      final controller = build();
      controller.heats.value = [
        [
          entry(1, [
            athlete(1, clubId: 245)
                .copyWith(club: const Club(id: 7, name: 'Nice')),
          ]),
          entry(2, [
            athlete(2, clubId: 245)
                .copyWith(club: const Club(id: 8, name: 'Antibes')),
          ]),
        ],
      ];

      final spread = controller.clubDistribution;

      expect(spread.map((s) => s.clubId), [8, 7]);
      expect(spread.map((s) => s.label), ['Antibes', 'Nice']);
      expect(spread.every((s) => s.total == 1), isTrue);
    });

    test('only the clubs holding a drawn athlete get a row', () {
      final controller = build();
      controller.heats.value = [
        [withClub(1, 7, 'Nice')],
      ];

      // Antibes fielded nobody here, so it must not appear at all.
      expect(controller.clubDistribution.map((s) => s.label), ['Nice']);
    });

    test('unaffiliated athletes are one row, kept last', () {
      final controller = build();
      controller.heats.value = [
        [withClub(1, 0, ''), withClub(2, 0, ''), withClub(3, 7, 'Nice')],
      ];

      final spread = controller.clubDistribution;

      expect(spread.map((s) => s.clubId), [7, 0]);
      // Two unaffiliated athletes in one heat share no club, so the row must
      // never read as a clustering the draw failed to spread.
      expect(spread.last.total, 2);
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
      when(() => raceRepo.getEntries(raceId)).thenAnswer(
          (_) async => [for (final a in all) entry(a.id, [a])]);
      when(() => attendance.forRace(raceId)).thenReturn({
        for (final a in all) a.id: AttendanceStatus.present,
      });
      final controller = HeatDrawController(
        raceRepo,
        clubRepo,
        attendance,
        programme,
        meetingRepo,
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

  group('entries, as opposed to athletes', () {
    test('a relay team counts once, however many athletes it fields', () async {
      // Heats seat entries: a team of four takes one lane, not four. The
      // athlete count still drives the presence line, hence the two figures.
      when(() => raceRepo.getRaces(competitionId))
          .thenAnswer((_) async => [makeRace()]);
      when(() => raceRepo.getEntries(raceId)).thenAnswer((_) async => [
            entry(1, [athlete(1), athlete(2), athlete(3), athlete(4)]),
            entry(2, [athlete(5), athlete(6), athlete(7), athlete(8)]),
          ]);
      when(() => attendance.forRace(raceId)).thenReturn({});

      final controller = build();
      await controller.load();

      expect(controller.engagedCount.value, 8); // athletes
      expect(controller.entryCount.value, 2); // teams
      expect(controller.eligibleCount.value, 2);
    });

    test('a forfeited entry is entered but does not start', () async {
      when(() => raceRepo.getRaces(competitionId))
          .thenAnswer((_) async => [makeRace()]);
      when(() => raceRepo.getEntries(raceId)).thenAnswer((_) async => [
            entry(1, [athlete(1)]),
            entry(2, [athlete(2)]).copyWith(isForfeit: true),
          ]);
      when(() => attendance.forRace(raceId)).thenReturn({});

      final controller = build();
      await controller.load();

      expect(controller.entryCount.value, 2);
      // The structure editor sizes its heats on this one.
      expect(controller.eligibleCount.value, 1);
    });

    test('another category weighs on neither count', () async {
      when(() => raceRepo.getRaces(competitionId))
          .thenAnswer((_) async => [makeRace()]);
      when(() => raceRepo.getEntries(raceId)).thenAnswer((_) async => [
            entry(1, [athlete(1)]),
            entry(2, [athlete(2)], category: 999),
          ]);
      when(() => attendance.forRace(raceId)).thenReturn({});

      final controller = build();
      await controller.load();

      expect(controller.entryCount.value, 1);
      expect(controller.eligibleCount.value, 1);
    });
  });

  group('le tirage suit le déroulement', () {
    /// Loads a controller whose round declares [raceCount] courses of [spots]
    /// places, with [present] athletes checked in.
    Future<HeatDrawController> withDeclared({
      required int present,
      required int raceCount,
      int spots = 8,
      String speciality = 'Eau-plate',
    }) async {
      programme = _FakeProgrammeService(programmeWith(levels: [
        RoundLevel(
          type: RoundType.serie,
          spotsPerRace: spots,
          races: [
            for (var i = 1; i <= raceCount; i++)
              ProgrammeRace(id: i, number: i),
          ],
        ),
        const RoundLevel(type: RoundType.finale, spotsPerRace: 8),
      ]));
      final all = [for (var i = 1; i <= present; i++) athlete(i)];
      when(() => raceRepo.getEntries(raceId)).thenAnswer(
          (_) async => [for (final a in all) entry(a.id, [a])]);
      when(() => attendance.forRace(raceId)).thenReturn({
        for (final a in all) a.id: AttendanceStatus.present,
      });
      final controller = HeatDrawController(
        raceRepo,
        clubRepo,
        attendance,
        programme,
        meetingRepo,
        random: Random(7),
      )
        ..race.value = makeRace(speciality: speciality)
        ..competition.value = makeCompetition()
        ..categoryId = categoryId
        ..categoryLabel = 'Senior';
      await controller.load();
      return controller;
    }

    // Le déroulement est ce que l'organisateur a arrêté pour l'épreuve. Recompter
    // les séries sur le nombre de présents en fabrique un autre en silence, et
    // l'enregistrement écrase alors le déroulement par ce compte-là.
    test('un tour déclaré à trois séries en tire trois', () async {
      final controller = await withDeclared(present: 10, raceCount: 3);

      controller.drawFromDeclared();

      expect(controller.heats, hasLength(3));
      expect(controller.pendingPlan.value, (raceCount: 3, spotsPerRace: 8));
    });

    test('les présents se répartissent sur toutes les séries déclarées',
        () async {
      final controller = await withDeclared(present: 10, raceCount: 3);

      controller.drawFromDeclared();

      expect(controller.heats.expand((h) => h).map((a) => a.id).toSet(),
          hasLength(10));
      expect(controller.heats.every((h) => h.isNotEmpty), isTrue);
    });

    // Enregistrer sur un tirage recompté remplaçait les trois séries déclarées
    // par deux : le déroulement se trouvait modifié par un tirage.
    test('enregistrer conserve les courses du déroulement', () async {
      final controller = await withDeclared(present: 10, raceCount: 3);
      controller.drawFromDeclared();

      await controller.save();

      final level = programme.current.value!.structures.single.levels
          .firstWhere((l) => l.type == RoundType.serie);
      expect(level.races, hasLength(3));
      expect(level.races.map((r) => r.number), [1, 2, 3]);
      expect(level.spotsPerRace, 8);
    });

    // Douze présents sur deux séries de quatre ne tiennent pas : personne ne
    // peut trancher à la place de l'opérateur, donc on lui demande.
    test('un déroulement trop étroit pour les présents demande validation',
        () async {
      final controller =
          await withDeclared(present: 12, raceCount: 2, spots: 4);

      expect(controller.requiresStructureValidation, isTrue);
    });

    test('un déroulement qui suffit ne demande rien en bassin', () async {
      final controller = await withDeclared(present: 10, raceCount: 3);

      expect(controller.requiresStructureValidation, isFalse);
    });

    // Rien n'a été arrêté pour ce tour : il n'y a pas de déroulement à
    // respecter, donc rien à faire valider non plus.
    test('un tour sans course déclarée garde le tirage direct', () async {
      final controller = await withDeclared(present: 10, raceCount: 0);

      expect(controller.requiresStructureValidation, isFalse);

      controller.drawFromDeclared();

      expect(controller.heats, hasLength(2)); // 10 présents, 8 places
    });

    test('une série côtière reste soumise à validation même si elle suffit',
        () async {
      final controller =
          await withDeclared(present: 10, raceCount: 3, speciality: 'Côtier');

      expect(controller.requiresStructureValidation, isTrue);
    });
  });

  group('enregistrer pousse les places', () {
    DateTime hhmm(String v) => DateFormat('HH:mm').parse(v);

    Run course(int id, {List<Lane> lanes = const []}) => Run(
          id: id,
          name: 'Série 1',
          label: '',
          fullLabel: '',
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
              name: 'Séries',
              beginHour: hhmm('08:00'),
              endHour: hhmm('08:10'),
              runs: runs,
            ),
          ],
        );

    /// Un tour d'une série, tirée et liée (ou non) à sa course FFSS.
    Future<HeatDrawController> drawnLinked({int runId = 25}) async {
      programme = _FakeProgrammeService(programmeWith(levels: [
        RoundLevel(type: RoundType.serie, serverId: 39, races: [
          ProgrammeRace(id: 1, number: 1, runId: runId),
        ]),
      ]));
      when(() => raceRepo.getEntries(raceId)).thenAnswer((_) async => [
            entry(101, [athlete(11)]),
            entry(102, [athlete(12)]),
          ]);
      when(() => attendance.forRace(raceId)).thenReturn({
        11: AttendanceStatus.present,
        12: AttendanceStatus.present,
      });
      final controller = build();
      await controller.load();
      controller.drawWithPlan((raceCount: 1, spotsPerRace: 4));
      return controller;
    }

    test('chaque série pousse ses engagements sur les places de sa course',
        () async {
      final controller = await drawnLinked();
      final existing = [const Lane(id: 7, number: 1)];
      when(() => meetingRepo.getMeetings(competitionId))
          .thenAnswer((_) async => [
                meetingWith([course(25, lanes: existing)])
              ]);

      await controller.save();

      final captured = verify(() => meetingRepo.syncLanes(
            runId: 25,
            entryIds: captureAny(named: 'entryIds'),
            existing: captureAny(named: 'existing'),
          )).captured;
      expect((captured[0] as List<int>).toSet(), {101, 102});
      expect(captured[1], existing);
      expect(controller.message.value!.translationKey,
          'heat_draw_saved_pushed');
      expect(controller.message.value, isA<UiMessageSuccess>());
    });

    // Le choix retenu : le tirage reste sur l'appareil, et l'opérateur sait
    // qu'il lui reste à placer le tour puis à réenregistrer.
    test('une série sans course est signalée, le tirage reste enregistré',
        () async {
      final controller = await drawnLinked(runId: 0);

      await controller.save();

      verifyNever(() => meetingRepo.syncLanes(
            runId: any(named: 'runId'),
            entryIds: any(named: 'entryIds'),
            existing: any(named: 'existing'),
          ));
      expect(controller.saved.value, isTrue);
      expect(programme.saveCount, 1);
      expect(controller.message.value!.translationKey,
          'heat_draw_lanes_unplaced');
    });

    test('un envoi incomplet est signalé comme un échec', () async {
      final controller = await drawnLinked();
      when(() => meetingRepo.getMeetings(competitionId))
          .thenAnswer((_) async => [
                meetingWith([course(25)])
              ]);
      when(() => meetingRepo.syncLanes(
            runId: any(named: 'runId'),
            entryIds: any(named: 'entryIds'),
            existing: any(named: 'existing'),
          )).thenAnswer((_) async => 1); // 2 demandées, 1 passée

      await controller.save();

      expect(controller.saved.value, isTrue);
      expect(controller.message.value!.translationKey,
          'heat_draw_lanes_failed');
    });

    // Pousser sans avoir pu lire l'existant créerait des doublons à côté des
    // places par défaut : mieux vaut ne rien envoyer et le dire.
    test('réunions illisibles : rien ne part, et c est dit', () async {
      final controller = await drawnLinked();
      when(() => meetingRepo.getMeetings(competitionId))
          .thenThrow(const NetworkException('coupé'));

      await controller.save();

      verifyNever(() => meetingRepo.syncLanes(
            runId: any(named: 'runId'),
            entryIds: any(named: 'entryIds'),
            existing: any(named: 'existing'),
          ));
      expect(controller.saved.value, isTrue);
      expect(controller.message.value!.translationKey,
          'heat_draw_lanes_failed');
    });
  });
}
