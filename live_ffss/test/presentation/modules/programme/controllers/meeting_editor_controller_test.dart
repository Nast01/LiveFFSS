import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/auth_repository.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:live_ffss/app/data/services/meeting_service.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/race_format_detail.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/domain/models/run.dart';
import 'package:live_ffss/app/domain/models/slot.dart';
import 'package:live_ffss/app/domain/models/user.dart';
import 'package:live_ffss/app/module/programme/controllers/meeting_editor_controller.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';
import 'package:mocktail/mocktail.dart';

class _MockStorage extends Mock implements FlutterSecureStorage {}

class _MockMeetingRepo extends Mock implements MeetingRepository {}

class _MockAuthRepo extends Mock implements AuthRepository {}

void main() {
  late _MockStorage storage;
  late _MockMeetingRepo repo;
  late ProgrammeService programme;
  late MeetingService meetings;
  late UserService user;
  late MeetingEditorController controller;

  /// Any non-null user is a session as far as this screen is concerned.
  final loggedIn = User(
    token: 'tok',
    tokenExpiration: DateTime(2030),
    label: 'FFSS',
    type: UserType.organisme,
    role: UserRole.admin,
  );

  final day = DateTime(2026, 9, 12);

  DateTime hm(int h, int m) => DateTime(1970, 1, 1, h, m);
  DateTime onDay(int h, int m) => DateTime(2026, 9, 12, h, m);

  Run run(int id, String name, int bh, int bm, int eh, int em,
          {String site = 'Plage'}) =>
      Run(
        id: id,
        name: name,
        label: name,
        fullLabel: name,
        status: RunStatus.waiting,
        statusLabel: '',
        site: site,
        beginTime: hm(bh, bm),
        endTime: hm(eh, em),
      );

  RaceFormatDetail partie(int id) => RaceFormatDetail(
        id: id,
        order: 1,
        label: '',
        fullLabel: '',
        levelLabel: '',
        level: 'heat',
        numberOfRun: 1,
        qualificationMethod: 'none',
        qualificationMethodLabel: '',
        spotsPerRace: 8,
        qualifyingSpots: 0,
      );

  Slot slot(int id, String name, int bh, int bm, int eh, int em,
          {List<Run> runs = const [], RaceFormatDetail? detail}) =>
      Slot(
        id: id,
        name: name,
        beginHour: hm(bh, bm),
        endHour: hm(eh, em),
        raceFormatDetail: detail,
        runs: runs,
      );

  Meeting meeting({List<Slot> slots = const [], int startHour = 8}) => Meeting(
        id: 1,
        name: 'Matin',
        description: 'Plage',
        date: day,
        beginHour: DateTime(2026, 9, 12, startHour),
        endHour: DateTime(2026, 9, 12, startHour),
        slots: slots,
      );

  /// Charge [tree] dans le service et pointe le contrôleur sur la réunion 1.
  Future<void> seed(List<Meeting> tree) async {
    when(() => repo.getMeetings(42)).thenAnswer((_) async => tree);
    await meetings.load(42);
    controller.applyArguments({'meetingId': 1});
  }

  /// Stubbe tout ce qu'une écriture peut appeler, avec des succès.
  void stubWritesOk() {
    when(() => repo.submitSlot(
          meetingId: any(named: 'meetingId'),
          name: any(named: 'name'),
          beginHour: any(named: 'beginHour'),
          endHour: any(named: 'endHour'),
          raceFormatDetailId: any(named: 'raceFormatDetailId'),
          id: any(named: 'id'),
        )).thenAnswer((_) async => 10);
    when(() => repo.submitRun(
          slotId: any(named: 'slotId'),
          name: any(named: 'name'),
          beginHour: any(named: 'beginHour'),
          endHour: any(named: 'endHour'),
          site: any(named: 'site'),
          id: any(named: 'id'),
        )).thenAnswer((_) async => 11);
    when(() => repo.submitMeeting(
          competitionId: any(named: 'competitionId'),
          name: any(named: 'name'),
          description: any(named: 'description'),
          date: any(named: 'date'),
          beginHour: any(named: 'beginHour'),
          endHour: any(named: 'endHour'),
          id: any(named: 'id'),
        )).thenAnswer((_) async => 1);
    when(() => repo.createDefaultLanes(
          runId: any(named: 'runId'),
          count: any(named: 'count'),
        )).thenAnswer((_) async => 8);
    when(() => repo.deleteRun(any())).thenAnswer((_) async => true);
    when(() => repo.deleteSlot(any())).thenAnswer((_) async => true);
  }

  setUpAll(() {
    registerFallbackValue(DateTime(2026));
    registerFallbackValue('');
  });

  setUp(() async {
    storage = _MockStorage();
    when(() => storage.read(key: any(named: 'key')))
        .thenAnswer((_) async => null);
    when(() =>
            storage.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((_) async {});

    repo = _MockMeetingRepo();

    programme = ProgrammeService(storage);
    await programme.load(42);

    // UserService.init() calls AuthRepository.restoreSession(), which this
    // test never stubs — schedule_controller_test.dart and
    // meeting_form_controller_test.dart both skip init() entirely and set
    // currentUser directly, which is what actually compiles and runs.
    user = UserService(_MockAuthRepo());
    user.currentUser.value = loggedIn;

    meetings = MeetingService(repo);
    controller = MeetingEditorController(meetings, repo, programme, user);
  });

  test('items come from the meeting the arguments named', () async {
    await seed([
      meeting(slots: [slot(10, 'Accueil', 8, 0, 8, 10)]),
      Meeting(
        id: 2,
        name: 'Après-midi',
        description: 'Bassin',
        date: day,
        beginHour: onDay(14, 0),
        endHour: onDay(14, 0),
        slots: [slot(20, 'Autre', 14, 0, 14, 10)],
      ),
    ]);

    expect(controller.items.single.slotId, 10);
    expect(controller.site, 'Plage');
  });

  test('addManualItem lands at the end of the réunion for 10 minutes',
      () async {
    await seed([
      meeting(slots: [slot(10, 'Accueil', 8, 0, 8, 10)])
    ]);
    stubWritesOk();

    await controller.addManualItem('Pause');

    verify(() => repo.submitSlot(
          meetingId: 1,
          name: 'Pause',
          beginHour: onDay(8, 10),
          endHour: onDay(8, 20),
          raceFormatDetailId: null,
          id: null,
        )).called(1);
  });

  test('the first item of an empty réunion starts at its own start', () async {
    await seed([meeting(startHour: 9)]);
    stubWritesOk();

    await controller.addManualItem('Accueil');

    verify(() => repo.submitSlot(
          meetingId: 1,
          name: 'Accueil',
          beginHour: onDay(9, 0),
          endHour: onDay(9, 10),
          raceFormatDetailId: null,
          id: null,
        )).called(1);
  });

  test('addManualItem pushes the new end of réunion', () async {
    // La liste rechargée porte l'item qui vient d'atterrir : la fin poussée
    // doit être calculée sur elle, pas sur celle d'avant l'écriture.
    when(() => repo.getMeetings(42)).thenAnswer((_) async => [
          meeting(slots: [slot(10, 'Pause', 8, 0, 8, 10)])
        ]);
    await meetings.load(42);
    controller.applyArguments({'meetingId': 1});
    stubWritesOk();

    await controller.addManualItem('Pause');

    verify(() => repo.submitMeeting(
          competitionId: 42,
          name: 'Matin',
          description: 'Plage',
          date: day,
          beginHour: onDay(8, 0),
          endHour: onDay(8, 10),
          id: 1,
        )).called(1);
  });

  test(
      'addManualItem on a gapped réunion places the new item after the real '
      'last item, not a packed end', () async {
    // Un trou entre 8:10 et 9:00 : un recompactage depuis le début rendrait
    // 8:30 (10 + 10 minutes bout à bout), alors que le dernier item réel
    // finit à 9:10 — c'est là que le nouvel item doit atterrir.
    await seed([
      meeting(slots: [
        slot(10, 'A', 8, 0, 8, 10),
        slot(20, 'B', 9, 0, 9, 10),
      ]),
    ]);
    stubWritesOk();

    await controller.addManualItem('Pause');

    verify(() => repo.submitSlot(
          meetingId: 1,
          name: 'Pause',
          beginHour: onDay(9, 10),
          endHour: onDay(9, 20),
          raceFormatDetailId: null,
          id: null,
        )).called(1);
  });

  test('a signed-out operator is refused before anything leaves the device',
      () async {
    // FFSS répondrait à une écriture anonyme par un « Invalid Token » nu qui
    // se lit comme une panne serveur.
    await seed([meeting()]);
    user.currentUser.value = null;

    await controller.addManualItem('Pause');

    expect(controller.message.value, isA<UiMessageError>());
    verifyNever(() => repo.submitSlot(
        meetingId: any(named: 'meetingId'),
        name: any(named: 'name'),
        beginHour: any(named: 'beginHour'),
        endHour: any(named: 'endHour'),
        raceFormatDetailId: any(named: 'raceFormatDetailId'),
        id: any(named: 'id')));
  });

  test('scheduleRound creates one course per name, back to back', () async {
    await seed([meeting()]);
    stubWritesOk();

    await controller.scheduleRound(
      partieId: 100,
      name: 'Séries - Surfski - Dames - Junior',
      courseNames: const ['Série 1', 'Série 2'],
      spotsPerRace: 8,
    );

    verify(() => repo.submitRun(
          slotId: 10,
          name: 'Série 1',
          beginHour: onDay(8, 0),
          endHour: onDay(8, 10),
          site: 'Plage',
          id: null,
        )).called(1);
    verify(() => repo.submitRun(
          slotId: 10,
          name: 'Série 2',
          beginHour: onDay(8, 10),
          endHour: onDay(8, 20),
          site: 'Plage',
          id: null,
        )).called(1);
  });

  test('the créneau lasts one slot per course', () async {
    await seed([meeting()]);
    stubWritesOk();

    await controller.scheduleRound(
      partieId: 100,
      name: 'Séries',
      courseNames: const ['Série 1', 'Série 2'],
      spotsPerRace: 8,
    );

    verify(() => repo.submitSlot(
          meetingId: 1,
          name: 'Séries',
          beginHour: onDay(8, 0),
          endHour: onDay(8, 20),
          raceFormatDetailId: 100,
          id: null,
        )).called(1);
  });

  test('a round with no course still gets a non-zero créneau', () async {
    // Un créneau de longueur nulle serait invisible sur la frise et
    // laisserait l'item suivant démarrer à la même minute.
    await seed([meeting()]);
    stubWritesOk();

    await controller.scheduleRound(
      partieId: 100,
      name: 'Séries',
      courseNames: const [],
      spotsPerRace: 0,
    );

    verify(() => repo.submitSlot(
          meetingId: 1,
          name: 'Séries',
          beginHour: onDay(8, 0),
          endHour: onDay(8, 10),
          raceFormatDetailId: 100,
          id: null,
        )).called(1);
  });

  test('scheduleRound opens each course with spotsPerRace free spots',
      () async {
    await seed([meeting()]);
    stubWritesOk();

    await controller.scheduleRound(
      partieId: 100,
      name: 'Séries',
      courseNames: const ['Série 1'],
      spotsPerRace: 8,
    );

    verify(() => repo.createDefaultLanes(runId: 11, count: 8)).called(1);
  });

  test('spotsPerRace 0 creates no spot at all', () async {
    await seed([meeting()]);
    stubWritesOk();

    await controller.scheduleRound(
      partieId: 100,
      name: 'Séries',
      courseNames: const ['Série 1'],
      spotsPerRace: 0,
    );

    verifyNever(() => repo.createDefaultLanes(
        runId: any(named: 'runId'), count: any(named: 'count')));
  });

  test('each heat records the course it runs as, position by position',
      () async {
    // Enregistré et non re-dérivé : supprimer une course décalerait
    // silencieusement chaque heat suivant sur un départ qui n'est pas le sien.
    await programme.save(const CompetitionProgramme(
      competitionId: 42,
      structures: [
        EventStructure(
          raceId: 1,
          categoryId: 2,
          raceLabel: 'Surfski',
          categoryLabel: 'Junior',
          levels: [
            RoundLevel(type: RoundType.serie, serverId: 100, races: [
              ProgrammeRace(id: 1, number: 1),
              ProgrammeRace(id: 2, number: 2),
            ]),
          ],
        ),
      ],
    ));
    await seed([meeting()]);
    stubWritesOk();
    var runId = 100;
    when(() => repo.submitRun(
          slotId: any(named: 'slotId'),
          name: any(named: 'name'),
          beginHour: any(named: 'beginHour'),
          endHour: any(named: 'endHour'),
          site: any(named: 'site'),
          id: any(named: 'id'),
        )).thenAnswer((_) async => ++runId);

    await controller.scheduleRound(
      partieId: 100,
      name: 'Séries',
      courseNames: const ['Série 1', 'Série 2'],
      spotsPerRace: 0,
    );

    final races =
        programme.current.value!.structures.single.levels.single.races;
    expect(races[0].runId, 101);
    expect(races[1].runId, 102);
  });

  test('a refused course leaves its heat runId at 0 and the rest lands',
      () async {
    // Une demi-manche sur le site est mauvaise ; une demi-manche que
    // l'opérateur croit complète est pire.
    await programme.save(const CompetitionProgramme(
      competitionId: 42,
      structures: [
        EventStructure(
          raceId: 1,
          categoryId: 2,
          raceLabel: 'Surfski',
          categoryLabel: 'Junior',
          levels: [
            RoundLevel(type: RoundType.serie, serverId: 100, races: [
              ProgrammeRace(id: 1, number: 1),
              ProgrammeRace(id: 2, number: 2),
            ]),
          ],
        ),
      ],
    ));
    await seed([meeting()]);
    stubWritesOk();
    final answers = <int>[0, 102];
    var call = 0;
    when(() => repo.submitRun(
          slotId: any(named: 'slotId'),
          name: any(named: 'name'),
          beginHour: any(named: 'beginHour'),
          endHour: any(named: 'endHour'),
          site: any(named: 'site'),
          id: any(named: 'id'),
        )).thenAnswer((_) async => answers[call++]);

    await controller.scheduleRound(
      partieId: 100,
      name: 'Séries',
      courseNames: const ['Série 1', 'Série 2'],
      spotsPerRace: 0,
    );

    final races =
        programme.current.value!.structures.single.levels.single.races;
    expect(races[0].runId, 0);
    expect(races[1].runId, 102);
    expect(controller.message.value, isA<UiMessageError>());
  });

  test('unscheduledRounds skips a round already placed in ANOTHER meeting',
      () async {
    // C'est la raison d'être de MeetingService.placedPartieIds : sans elle,
    // le même tour serait proposé deux fois.
    await programme.save(const CompetitionProgramme(
      competitionId: 42,
      structures: [
        EventStructure(
          raceId: 1,
          categoryId: 2,
          raceLabel: 'Surfski',
          categoryLabel: 'Junior',
          levels: [
            RoundLevel(type: RoundType.serie, serverId: 100),
            RoundLevel(type: RoundType.finale, serverId: 200),
          ],
        ),
      ],
    ));
    await seed([
      meeting(),
      Meeting(
        id: 2,
        name: 'Après-midi',
        description: 'Bassin',
        date: day,
        beginHour: onDay(14, 0),
        endHour: onDay(14, 0),
        slots: [slot(20, 'Séries', 14, 0, 14, 10, detail: partie(100))],
      ),
    ]);

    expect(controller.unscheduledRounds.map((r) => r.partieId), [200]);
  });

  test('unscheduledRounds skips a round with no serverId', () async {
    await programme.save(const CompetitionProgramme(
      competitionId: 42,
      structures: [
        EventStructure(
          raceId: 1,
          categoryId: 2,
          raceLabel: 'Surfski',
          categoryLabel: 'Junior',
          levels: [RoundLevel(type: RoundType.serie, serverId: 0)],
        ),
      ],
    ));
    await seed([meeting()]);

    expect(controller.unscheduledRounds, isEmpty);
  });

  test('setRunDuration repacks the réunion, not just its end', () async {
    // Une course plus longue chevauche la suivante, une plus courte laisse un
    // trou — et son créneau doit suivre dans les deux cas.
    await seed([
      meeting(slots: [
        slot(10, 'Séries', 8, 0, 8, 20, detail: partie(100), runs: [
          run(11, 'Série 1', 8, 0, 8, 10),
          run(12, 'Série 2', 8, 10, 8, 20),
        ]),
      ]),
    ]);
    stubWritesOk();
    // Le rechargement post-écriture doit porter l'arbre déjà redimensionné,
    // sinon le recompactage ne verrait aucune dérive et n'écrirait rien.
    when(() => repo.getMeetings(42)).thenAnswer((_) async => [
          meeting(slots: [
            slot(10, 'Séries', 8, 0, 8, 30, detail: partie(100), runs: [
              run(11, 'Série 1', 8, 0, 8, 20),
              run(12, 'Série 2', 8, 10, 8, 20),
            ]),
          ]),
        ]);

    await controller.setRunDuration(11, 20);

    // La course 11 s'allonge…
    verify(() => repo.submitRun(
          slotId: 10,
          name: 'Série 1',
          beginHour: onDay(8, 0),
          endHour: onDay(8, 20),
          site: 'Plage',
          id: 11,
        )).called(1);
    // …et la 12 est repoussée d'autant.
    verify(() => repo.submitRun(
          slotId: 10,
          name: 'Série 2',
          beginHour: onDay(8, 20),
          endHour: onDay(8, 30),
          site: 'Plage',
          id: 12,
        )).called(1);
  });

  test('setSlotDuration repacks the réunion', () async {
    await seed([
      meeting(slots: [
        slot(10, 'Accueil', 8, 0, 8, 10),
        slot(20, 'Pause', 8, 10, 8, 20),
      ]),
    ]);
    stubWritesOk();
    // Idem : le rechargement doit refléter le créneau 10 déjà allongé à 30
    // minutes, sinon le recompactage ne verrait rien à repousser.
    when(() => repo.getMeetings(42)).thenAnswer((_) async => [
          meeting(slots: [
            slot(10, 'Accueil', 8, 0, 8, 30),
            slot(20, 'Pause', 8, 10, 8, 20),
          ]),
        ]);

    await controller.setSlotDuration(10, 30);

    verify(() => repo.submitSlot(
          meetingId: 1,
          name: 'Pause',
          beginHour: onDay(8, 30),
          endHour: onDay(8, 40),
          raceFormatDetailId: null,
          id: 20,
        )).called(1);
    // Rien ne vérifiait jusqu'ici la fin poussée par un recompactage.
    verify(() => repo.submitMeeting(
          competitionId: 42,
          name: 'Matin',
          description: 'Plage',
          date: day,
          beginHour: onDay(8, 0),
          endHour: onDay(8, 40),
          id: 1,
        )).called(1);
  });

  test('a duration below one minute is refused', () async {
    await seed([
      meeting(slots: [slot(10, 'Accueil', 8, 0, 8, 10)])
    ]);

    await controller.setSlotDuration(10, 0);
    await controller.setRunDuration(11, 0);

    verifyNever(() => repo.submitSlot(
        meetingId: any(named: 'meetingId'),
        name: any(named: 'name'),
        beginHour: any(named: 'beginHour'),
        endHour: any(named: 'endHour'),
        raceFormatDetailId: any(named: 'raceFormatDetailId'),
        id: any(named: 'id')));
  });

  test('reorderItems repacks from the réunion start in the new order',
      () async {
    // Un créneau ne porte aucun rang côté FFSS : ses nouvelles heures SONT
    // son nouveau rang.
    await seed([
      meeting(slots: [
        slot(10, 'Accueil', 8, 0, 8, 10),
        slot(20, 'Pause', 8, 10, 8, 40),
      ]),
    ]);
    stubWritesOk();

    await controller.reorderItems(1, 0);

    verify(() => repo.submitSlot(
          meetingId: 1,
          name: 'Pause',
          beginHour: onDay(8, 0),
          endHour: onDay(8, 30),
          raceFormatDetailId: null,
          id: 20,
        )).called(1);
    verify(() => repo.submitSlot(
          meetingId: 1,
          name: 'Accueil',
          beginHour: onDay(8, 30),
          endHour: onDay(8, 40),
          raceFormatDetailId: null,
          id: 10,
        )).called(1);
  });

  test('a downward move accounts for the item leaving the list', () async {
    // Un déplacement vers le bas est rapporté contre la liste AVANT le
    // retrait, donc l'index cible est trop haut d'un cran. Avec deux items
    // seulement, `newIndex - 1` et `newIndex` retombent sur le même index une
    // fois `clamp`é — il faut un troisième item pour que l'écart se voie :
    // avec l'ajustement l'ordre devient [B, A, C], sans lui [B, C, A], et
    // seul l'item du milieu diffère entre les deux.
    await seed([
      meeting(slots: [
        slot(10, 'A', 8, 0, 8, 10),
        slot(20, 'B', 8, 10, 8, 20),
        slot(30, 'C', 8, 20, 8, 30),
      ]),
    ]);
    stubWritesOk();

    await controller.reorderItems(0, 2);

    verify(() => repo.submitSlot(
          meetingId: 1,
          name: 'A',
          beginHour: onDay(8, 10),
          endHour: onDay(8, 20),
          raceFormatDetailId: null,
          id: 10,
        )).called(1);
  });

  test('a no-op reorder writes nothing', () async {
    await seed([
      meeting(slots: [
        slot(10, 'A', 8, 0, 8, 10),
        slot(20, 'B', 8, 10, 8, 20),
      ]),
    ]);
    stubWritesOk();

    await controller.reorderItems(0, 1);

    verifyNever(() => repo.submitSlot(
        meetingId: any(named: 'meetingId'),
        name: any(named: 'name'),
        beginHour: any(named: 'beginHour'),
        endHour: any(named: 'endHour'),
        raceFormatDetailId: any(named: 'raceFormatDetailId'),
        id: any(named: 'id')));
  });

  test('removeRun deletes its créneau when it was the last course', () async {
    // Un créneau vidé n'a plus de site propre : la frise le rangerait parmi
    // les items manuels, là où personne ne cherchera le tour qu'il vient de
    // vider.
    await seed([
      meeting(slots: [
        slot(10, 'Séries', 8, 0, 8, 10,
            detail: partie(100), runs: [run(11, 'Série 1', 8, 0, 8, 10)]),
      ]),
    ]);
    stubWritesOk();

    await controller.removeRun(11);

    verify(() => repo.deleteRun(11)).called(1);
    verify(() => repo.deleteSlot(10)).called(1);
  });

  test('removeRun keeps the créneau when other courses remain', () async {
    await seed([
      meeting(slots: [
        slot(10, 'Séries', 8, 0, 8, 20, detail: partie(100), runs: [
          run(11, 'Série 1', 8, 0, 8, 10),
          run(12, 'Série 2', 8, 10, 8, 20),
        ]),
      ]),
    ]);
    stubWritesOk();

    await controller.removeRun(11);

    verify(() => repo.deleteRun(11)).called(1);
    verifyNever(() => repo.deleteSlot(any()));
  });

  test('removeSlot repacks the réunion afterwards', () async {
    await seed([
      meeting(slots: [
        slot(10, 'A', 8, 0, 8, 10),
        slot(20, 'B', 8, 10, 8, 20),
      ]),
    ]);
    stubWritesOk();
    // Après la suppression, FFSS ne porte plus que B, resté à 8:10.
    when(() => repo.getMeetings(42)).thenAnswer((_) async => [
          meeting(slots: [slot(20, 'B', 8, 10, 8, 20)])
        ]);

    await controller.removeSlot(10);

    verify(() => repo.submitSlot(
          meetingId: 1,
          name: 'B',
          beginHour: onDay(8, 0),
          endHour: onDay(8, 10),
          raceFormatDetailId: null,
          id: 20,
        )).called(1);
  });

  test(
      'a failed reload stops the repack rather than computing from stale '
      'state', () async {
    // Sinon la fin poussée serait celle d'avant l'écriture, et signalée comme
    // un succès.
    await seed([
      meeting(slots: [slot(10, 'A', 8, 0, 8, 10)])
    ]);
    stubWritesOk();
    when(() => repo.getMeetings(42)).thenThrow(const ApiException('boom'));

    await controller.removeSlot(10);

    expect(controller.message.value, isA<UiMessageError>());
    verifyNever(() => repo.submitMeeting(
        competitionId: any(named: 'competitionId'),
        name: any(named: 'name'),
        description: any(named: 'description'),
        date: any(named: 'date'),
        beginHour: any(named: 'beginHour'),
        endHour: any(named: 'endHour'),
        id: any(named: 'id')));
  });

  test('an AppException on a write is reported with its detail', () async {
    await seed([meeting()]);
    when(() => repo.submitSlot(
          meetingId: any(named: 'meetingId'),
          name: any(named: 'name'),
          beginHour: any(named: 'beginHour'),
          endHour: any(named: 'endHour'),
          raceFormatDetailId: any(named: 'raceFormatDetailId'),
          id: any(named: 'id'),
        )).thenThrow(const ApiException('Invalid token'));

    await controller.addManualItem('Pause');

    expect(controller.message.value, isA<UiMessageError>());
    expect((controller.message.value! as UiMessageError).details,
        contains('Invalid token'));
    expect(controller.isBusy.value, isFalse);
  });
}
