import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/auth_repository.dart';
import 'package:live_ffss/app/data/repositories/race_format_repository.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import 'package:live_ffss/app/domain/models/user.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/race_format_detail.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/module/programme/controllers/structure_editor_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockStorage extends Mock implements FlutterSecureStorage {}

class _MockRaceFormatRepo extends Mock implements RaceFormatRepository {}

class _MockAuthRepo extends Mock implements AuthRepository {}

void main() {
  late _MockStorage storage;
  late ProgrammeService service;
  late StructureEditorController controller;
  late _MockRaceFormatRepo raceFormatRepo;
  late UserService userService;

  setUpAll(() => registerFallbackValue(''));

  /// Any non-null user is a session as far as the editor is concerned.
  final loggedInUser = User(
    token: 'tok',
    tokenExpiration: DateTime(2030),
    label: 'FFSS',
    type: UserType.organisme,
    role: UserRole.admin,
  );

  const args = StructureEditorArgs(
    competitionId: 42,
    raceId: 100,
    categoryId: 7,
    raceLabel: '100m',
    categoryLabel: 'Cadets',
    entryCount: 20,
    eligibleCount: 20,
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
    userService = UserService(_MockAuthRepo());
    // An operator authoring a déroulement is signed in; the signed-out case
    // has its own group below.
    userService.currentUser.value = loggedInUser;
    controller =
        StructureEditorController(service, raceFormatRepo, userService);
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

  test('proposeDefault sizes the structure on the starters, not the roster',
      () {
    // 20 entered, 5 of them forfeit: fifteen swimmers need two heats at eight,
    // not three. Sizing on the roster would leave a heat nobody swims.
    controller.start(const StructureEditorArgs(
      competitionId: 42,
      raceId: 100,
      categoryId: 7,
      raceLabel: '100m',
      categoryLabel: 'Cadets',
      entryCount: 20,
      eligibleCount: 15,
    ));

    controller.proposeDefault();

    final levels = controller.structure.value!.levels;
    expect(levels[0].races.length, 2); // ceil(15 / 8)
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
      eligibleCount: 20,
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
        eligibleCount: 20,
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
        eligibleCount: 20,
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
      eligibleCount: 20,
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
        eligibleCount: 20,
        serverDetails: [semi],
      ));
      controller.seedFromServerIfNeeded();
    }

    test('a round backed by FFSS is deleted on the server too', () async {
      await withServerRound();

      expect(await controller.removeLevel(0), LevelRemoval.removed);

      verify(() => raceFormatRepo.deleteRaceFormatDetail(32)).called(1);
      expect(controller.structure.value!.levels, isEmpty);
    });

    test('a hand-added round calls nothing', () async {
      await controller.addLevel(RoundType.finale);

      expect(await controller.removeLevel(0), LevelRemoval.removed);

      verifyNever(() => raceFormatRepo.deleteRaceFormatDetail(any()));
      expect(controller.structure.value!.levels, isEmpty);
    });

    // The round is kept and the refusal is named, so the view can offer to drop
    // it from the device anyway — a partie FFSS no longer holds would otherwise
    // be stuck in the editor for good.
    test('a refused deletion keeps the round and says the server refused',
        () async {
      await withServerRound();
      when(() => raceFormatRepo.deleteRaceFormatDetail(any()))
          .thenAnswer((_) async => false);

      expect(await controller.removeLevel(0), LevelRemoval.serverRefused);

      expect(controller.structure.value!.levels, hasLength(1));
      expect(controller.message.value, isA<UiMessageError>());
    });

    test('a network failure keeps the round and clears the busy flag',
        () async {
      await withServerRound();
      when(() => raceFormatRepo.deleteRaceFormatDetail(any()))
          .thenThrow(const NetworkException('offline'));

      expect(await controller.removeLevel(0), LevelRemoval.serverRefused);

      expect(controller.structure.value!.levels, hasLength(1));
      expect(controller.message.value, isA<UiMessageError>());
      expect(controller.isDeletingLevel.value, isFalse);
    });

    test('the failure carries the reason FFSS gave for it', () async {
      // "Could not delete" says nothing an operator can act on; the server's
      // own words distinguish a locked competition from a transport failure.
      await withServerRound();
      when(() => raceFormatRepo.deleteRaceFormatDetail(any())).thenThrow(
          const ApiException('Déroulement verrouillé', statusCode: 409));

      expect(await controller.removeLevel(0), LevelRemoval.serverRefused);

      expect(controller.message.value!.details,
          'Déroulement verrouillé (HTTP 409)');
    });

    // FFSS answers 404 for a partie it no longer holds, and 403 for a bad
    // token — the two are never confused. A 404 means the round is definitively
    // gone there, so asking "remove it anyway?" would ask a question whose
    // answer can only be yes.
    test('a partie FFSS no longer holds is dropped without asking', () async {
      await withServerRound();
      when(() => raceFormatRepo.deleteRaceFormatDetail(any())).thenThrow(
          const ApiException('The requested resource was not found.',
              statusCode: 404));

      expect(await controller.removeLevel(0), LevelRemoval.removed);

      expect(controller.structure.value!.levels, isEmpty);
      expect(controller.message.value, isA<UiMessageSuccess>());
      expect(controller.message.value!.translationKey,
          'round_delete_already_gone');
    });

    test('a plain refusal carries no invented reason', () async {
      await withServerRound();
      when(() => raceFormatRepo.deleteRaceFormatDetail(any()))
          .thenAnswer((_) async => false);

      await controller.removeLevel(0);

      expect(controller.message.value!.details, isNull);
    });

    test('signed out, the refusal is named as such and not as a server one',
        () async {
      // Offering "drop it locally" here would orphan a partie that is alive on
      // FFSS; the operator needs to sign in, not to hide it.
      await withServerRound();
      userService.currentUser.value = null;

      expect(await controller.removeLevel(0), LevelRemoval.needsLogin);

      expect(controller.structure.value!.levels, hasLength(1));
      expect(controller.message.value!.translationKey, 'login_required');
    });

    test('removeLevelLocally drops the round without calling the server',
        () async {
      await withServerRound();

      controller.removeLevelLocally(0);

      expect(controller.structure.value!.levels, isEmpty);
      verifyNever(() => raceFormatRepo.deleteRaceFormatDetail(any()));
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
      // The finale is fed by the demi that now precedes it, not by the séries
      // two rounds above.
      final demiIds = levels[1].races.map((r) => r.id).toList();
      expect(levels[2].races.single.sourceRaceIds, demiIds);
    });
  });

  group('defaults of a hand-added round', () {
    test('a quart starts with 4 races and 8 qualifiers each', () {
      controller.addLevel(RoundType.quart);

      final level = controller.structure.value!.levels.single;
      expect(level.races.length, 4);
      expect(level.qualifiersPerRace, 8);
      expect(level.races.map((r) => r.number), [1, 2, 3, 4]);
    });

    test('a demi starts with 2 races and 8 qualifiers each', () {
      controller.addLevel(RoundType.demi);

      final level = controller.structure.value!.levels.single;
      expect(level.races.length, 2);
      expect(level.qualifiersPerRace, 8);
    });

    test('a finale starts with one race and no qualifier', () {
      controller.addLevel(RoundType.finale);

      final level = controller.structure.value!.levels.single;
      expect(level.races.length, 1);
      expect(level.qualifiersPerRace, 0);
    });

    test('the races of a hand-added round get ids of their own', () {
      controller.addLevel(RoundType.quart);
      controller.addLevel(RoundType.demi);

      final ids = controller.structure.value!.levels
          .expand((l) => l.races)
          .map((r) => r.id)
          .toList();
      expect(ids.toSet().length, ids.length);
      expect(ids.every((id) => id > 0), isTrue);
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

  group('pushing rounds to FFSS', () {
    const linked = StructureEditorArgs(
      competitionId: 42,
      raceId: 100,
      categoryId: 7,
      raceLabel: '100m',
      categoryLabel: 'Cadets',
      entryCount: 20,
      eligibleCount: 18,
      disciplineId: 8,
      gender: Gender.male,
      raceFormatId: 428,
    );

    void answerSubmitWith(int id) {
      when(() => raceFormatRepo.submitRaceFormatDetail(
            raceFormatId: any(named: 'raceFormatId'),
            order: any(named: 'order'),
            level: any(named: 'level'),
            raceCount: any(named: 'raceCount'),
            qualificationMethod: any(named: 'qualificationMethod'),
            spotsPerRace: any(named: 'spotsPerRace'),
            qualifyingSpots: any(named: 'qualifyingSpots'),
            categoryIds: any(named: 'categoryIds'),
            id: any(named: 'id'),
          )).thenAnswer((_) async => id);
    }

    test('the editor reports how many entries will actually start', () {
      controller.start(linked);

      expect(controller.entryCount, 20);
      expect(controller.eligibleCount, 18);
    });

    group('adding a round', () {
      test('creates the partie at once and keeps the id it was given',
          () async {
        controller.start(linked);
        answerSubmitWith(512);

        await controller.addLevel(RoundType.finale);

        final level = controller.structure.value!.levels.single;
        expect(level.serverId, 512);
        final captured = verify(() => raceFormatRepo.submitRaceFormatDetail(
              raceFormatId: captureAny(named: 'raceFormatId'),
              order: captureAny(named: 'order'),
              level: captureAny(named: 'level'),
              raceCount: any(named: 'raceCount'),
              qualificationMethod: any(named: 'qualificationMethod'),
              spotsPerRace: any(named: 'spotsPerRace'),
              qualifyingSpots: any(named: 'qualifyingSpots'),
              categoryIds: captureAny(named: 'categoryIds'),
              id: captureAny(named: 'id'),
            )).captured;
        expect(captured[0], 428);
        expect(captured[1], 1); // ordre, one-based
        expect(captured[2], 'final'); // the API vocabulary, not ours
        expect(captured[3], [7]);
        expect(captured[4], isNull); // a creation
      });

      test('a round added with no déroulement stays local', () async {
        // Nothing to hang a partie on yet; the round is kept and will go out
        // with the next push, which creates the déroulement first.
        controller.start(args);

        await controller.addLevel(RoundType.finale);

        expect(controller.structure.value!.levels.single.serverId, 0);
        verifyNever(() => raceFormatRepo.submitRaceFormatDetail(
              raceFormatId: any(named: 'raceFormatId'),
              order: any(named: 'order'),
              level: any(named: 'level'),
              raceCount: any(named: 'raceCount'),
              qualificationMethod: any(named: 'qualificationMethod'),
              spotsPerRace: any(named: 'spotsPerRace'),
              qualifyingSpots: any(named: 'qualifyingSpots'),
              categoryIds: any(named: 'categoryIds'),
              id: any(named: 'id'),
            ));
      });

      test('a refused creation keeps the round and says so', () async {
        controller.start(linked);
        answerSubmitWith(0);

        await controller.addLevel(RoundType.finale);

        expect(controller.structure.value!.levels, hasLength(1));
        expect(controller.structure.value!.levels.single.serverId, 0);
        expect(controller.message.value, isA<UiMessageError>());
      });

      test('a network failure keeps the round rather than losing the edit',
          () async {
        controller.start(linked);
        when(() => raceFormatRepo.submitRaceFormatDetail(
              raceFormatId: any(named: 'raceFormatId'),
              order: any(named: 'order'),
              level: any(named: 'level'),
              raceCount: any(named: 'raceCount'),
              qualificationMethod: any(named: 'qualificationMethod'),
              spotsPerRace: any(named: 'spotsPerRace'),
              qualifyingSpots: any(named: 'qualifyingSpots'),
              categoryIds: any(named: 'categoryIds'),
              id: any(named: 'id'),
            )).thenThrow(const NetworkException('offline'));

        await controller.addLevel(RoundType.finale);

        expect(controller.structure.value!.levels, hasLength(1));
        expect(controller.message.value, isA<UiMessageError>());
      });
    });

    group('pushAll', () {
      test('sends every round in order, updating the ones already there',
          () async {
        controller.start(linked);
        answerSubmitWith(0); // ids are captured, not consumed, below
        when(() => raceFormatRepo.submitRaceFormatDetail(
              raceFormatId: any(named: 'raceFormatId'),
              order: any(named: 'order'),
              level: any(named: 'level'),
              raceCount: any(named: 'raceCount'),
              qualificationMethod: any(named: 'qualificationMethod'),
              spotsPerRace: any(named: 'spotsPerRace'),
              qualifyingSpots: any(named: 'qualifyingSpots'),
              categoryIds: any(named: 'categoryIds'),
              id: any(named: 'id'),
            )).thenAnswer((_) async => 900);
        controller.structure.value = controller.structure.value!.copyWith(
          levels: const [
            RoundLevel(
              type: RoundType.serie,
              serverId: 31,
              spotsPerRace: 8,
              qualifiersPerRace: 2,
              qualificationMethod: 'course',
              races: [
                ProgrammeRace(id: 1, number: 1),
                ProgrammeRace(id: 2, number: 2),
                ProgrammeRace(id: 3, number: 3),
              ],
            ),
            RoundLevel(
              type: RoundType.finale,
              spotsPerRace: 8,
              races: [ProgrammeRace(id: 4, number: 1)],
            ),
          ],
        );

        await controller.pushAll();

        final captured = verify(() => raceFormatRepo.submitRaceFormatDetail(
              raceFormatId: any(named: 'raceFormatId'),
              order: captureAny(named: 'order'),
              level: captureAny(named: 'level'),
              raceCount: captureAny(named: 'raceCount'),
              qualificationMethod: captureAny(named: 'qualificationMethod'),
              spotsPerRace: captureAny(named: 'spotsPerRace'),
              qualifyingSpots: any(named: 'qualifyingSpots'),
              categoryIds: any(named: 'categoryIds'),
              id: captureAny(named: 'id'),
            )).captured;
        // Round one: an update, carrying its own race count and logic.
        expect(captured.sublist(0, 6), [1, 'heat', 3, 'course', 8, 31]);
        // Round two: a creation, defaulting to no qualification logic.
        expect(captured.sublist(6), [2, 'final', 1, 'none', 8, null]);
      });

      test('records the ids the server assigned', () async {
        controller.start(linked);
        answerSubmitWith(777);
        controller.structure.value = controller.structure.value!.copyWith(
          levels: const [RoundLevel(type: RoundType.finale)],
        );

        await controller.pushAll();

        expect(controller.structure.value!.levels.single.serverId, 777);
      });

      test('creates the déroulement first when there is none', () async {
        controller.start(args); // no raceFormatId
        when(() => raceFormatRepo.submitRaceFormat(
              competitionId: any(named: 'competitionId'),
              disciplineId: any(named: 'disciplineId'),
              gender: any(named: 'gender'),
              categoryIds: any(named: 'categoryIds'),
              id: any(named: 'id'),
            )).thenAnswer((_) async => 999);
        answerSubmitWith(512);
        controller.structure.value = controller.structure.value!.copyWith(
          levels: const [RoundLevel(type: RoundType.finale)],
        );

        await controller.pushAll();

        verify(() => raceFormatRepo.submitRaceFormat(
              competitionId: 42,
              disciplineId: any(named: 'disciplineId'),
              gender: any(named: 'gender'),
              categoryIds: [7],
              id: null,
            )).called(1);
        // The parties hang off the déroulement that was just created.
        verify(() => raceFormatRepo.submitRaceFormatDetail(
              raceFormatId: 999,
              order: any(named: 'order'),
              level: any(named: 'level'),
              raceCount: any(named: 'raceCount'),
              qualificationMethod: any(named: 'qualificationMethod'),
              spotsPerRace: any(named: 'spotsPerRace'),
              qualifyingSpots: any(named: 'qualifyingSpots'),
              categoryIds: any(named: 'categoryIds'),
              id: any(named: 'id'),
            )).called(1);
      });

      test('a refused déroulement stops before sending any partie', () async {
        controller.start(args);
        when(() => raceFormatRepo.submitRaceFormat(
              competitionId: any(named: 'competitionId'),
              disciplineId: any(named: 'disciplineId'),
              gender: any(named: 'gender'),
              categoryIds: any(named: 'categoryIds'),
              id: any(named: 'id'),
            )).thenAnswer((_) async => 0);
        controller.structure.value = controller.structure.value!.copyWith(
          levels: const [RoundLevel(type: RoundType.finale)],
        );

        await controller.pushAll();

        verifyNever(() => raceFormatRepo.submitRaceFormatDetail(
              raceFormatId: any(named: 'raceFormatId'),
              order: any(named: 'order'),
              level: any(named: 'level'),
              raceCount: any(named: 'raceCount'),
              qualificationMethod: any(named: 'qualificationMethod'),
              spotsPerRace: any(named: 'spotsPerRace'),
              qualifyingSpots: any(named: 'qualifyingSpots'),
              categoryIds: any(named: 'categoryIds'),
              id: any(named: 'id'),
            ));
        expect(controller.message.value, isA<UiMessageError>());
      });

      test('progress is reported and cleared, failure included', () async {
        controller.start(linked);
        controller.structure.value = controller.structure.value!.copyWith(
          levels: const [
            RoundLevel(type: RoundType.serie),
            RoundLevel(type: RoundType.finale),
          ],
        );
        final seen = <String>[];
        when(() => raceFormatRepo.submitRaceFormatDetail(
              raceFormatId: any(named: 'raceFormatId'),
              order: any(named: 'order'),
              level: any(named: 'level'),
              raceCount: any(named: 'raceCount'),
              qualificationMethod: any(named: 'qualificationMethod'),
              spotsPerRace: any(named: 'spotsPerRace'),
              qualifyingSpots: any(named: 'qualifyingSpots'),
              categoryIds: any(named: 'categoryIds'),
              id: any(named: 'id'),
            )).thenAnswer((_) async {
          seen.add('${controller.pushDone.value}/${controller.pushTotal.value}');
          return 5;
        });

        await controller.pushAll();

        expect(seen, ['0/2', '1/2']);
        expect(controller.pushTotal.value, 0);
        expect(controller.isPushing.value, isFalse);
      });

      test('nothing to push means no call at all', () async {
        controller.start(linked);

        await controller.pushAll();

        verifyNever(() => raceFormatRepo.submitRaceFormatDetail(
              raceFormatId: any(named: 'raceFormatId'),
              order: any(named: 'order'),
              level: any(named: 'level'),
              raceCount: any(named: 'raceCount'),
              qualificationMethod: any(named: 'qualificationMethod'),
              spotsPerRace: any(named: 'spotsPerRace'),
              qualifyingSpots: any(named: 'qualifyingSpots'),
              categoryIds: any(named: 'categoryIds'),
              id: any(named: 'id'),
            ));
      });
    });

    test('setQualificationMethod changes only the targeted round', () {
      controller.start(linked);
      controller.structure.value = controller.structure.value!.copyWith(
        levels: const [
          RoundLevel(type: RoundType.serie),
          RoundLevel(type: RoundType.finale),
        ],
      );

      controller.setQualificationMethod(0, 'partie');

      final levels = controller.structure.value!.levels;
      expect(levels[0].qualificationMethod, 'partie');
      expect(levels[1].qualificationMethod, 'none');
    });
  });

  group('the editor refuses to write without a session', () {
    const linked = StructureEditorArgs(
      competitionId: 42,
      raceId: 100,
      categoryId: 7,
      raceLabel: '100m',
      categoryLabel: 'Cadets',
      entryCount: 20,
      eligibleCount: 20,
      disciplineId: 8,
      gender: Gender.male,
      raceFormatId: 428,
    );

    setUp(() => userService.currentUser.value = null);

    test('adding a round stays local and names the real cause', () async {
      // FFSS answers an anonymous write with "Invalid Token", which reads as a
      // server fault; refusing here says what actually needs doing.
      controller.start(linked);

      await controller.addLevel(RoundType.finale);

      expect(controller.structure.value!.levels, hasLength(1));
      verifyNever(() => raceFormatRepo.submitRaceFormatDetail(
            raceFormatId: any(named: 'raceFormatId'),
            order: any(named: 'order'),
            level: any(named: 'level'),
            raceCount: any(named: 'raceCount'),
            qualificationMethod: any(named: 'qualificationMethod'),
            spotsPerRace: any(named: 'spotsPerRace'),
            qualifyingSpots: any(named: 'qualifyingSpots'),
            categoryIds: any(named: 'categoryIds'),
            id: any(named: 'id'),
          ));
      expect(controller.message.value!.translationKey, 'login_required');
    });

    test('pushAll sends nothing at all', () async {
      controller.start(linked);
      controller.structure.value = controller.structure.value!
          .copyWith(levels: const [RoundLevel(type: RoundType.finale)]);

      await controller.pushAll();

      verifyNever(() => raceFormatRepo.submitRaceFormatDetail(
            raceFormatId: any(named: 'raceFormatId'),
            order: any(named: 'order'),
            level: any(named: 'level'),
            raceCount: any(named: 'raceCount'),
            qualificationMethod: any(named: 'qualificationMethod'),
            spotsPerRace: any(named: 'spotsPerRace'),
            qualifyingSpots: any(named: 'qualifyingSpots'),
            categoryIds: any(named: 'categoryIds'),
            id: any(named: 'id'),
          ));
      expect(controller.message.value!.translationKey, 'login_required');
      expect(controller.isPushing.value, isFalse);
    });

    test('removing a round backed by FFSS is refused, and it stays', () async {
      controller.start(linked);
      controller.structure.value = controller.structure.value!.copyWith(
          levels: const [RoundLevel(type: RoundType.finale, serverId: 31)]);

      await controller.removeLevel(0);

      verifyNever(() => raceFormatRepo.deleteRaceFormatDetail(any()));
      expect(controller.structure.value!.levels, hasLength(1));
      expect(controller.message.value!.translationKey, 'login_required');
    });

    test('a purely local round can still be removed offline', () async {
      // Nothing to call: the round exists only on this device.
      controller.start(linked);
      controller.structure.value = controller.structure.value!
          .copyWith(levels: const [RoundLevel(type: RoundType.finale)]);

      await controller.removeLevel(0);

      expect(controller.structure.value!.levels, isEmpty);
    });
  });
}
