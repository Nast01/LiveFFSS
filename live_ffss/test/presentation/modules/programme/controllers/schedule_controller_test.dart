import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/auth_repository.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/programme_site.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/domain/models/run.dart';
import 'package:live_ffss/app/domain/models/slot.dart';
import 'package:live_ffss/app/domain/models/user.dart';
import 'package:live_ffss/app/module/programme/controllers/schedule_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockStorage extends Mock implements FlutterSecureStorage {}

class _MockMeetingRepo extends Mock implements MeetingRepository {}

class _MockAuthRepo extends Mock implements AuthRepository {}

void main() {
  late _MockStorage storage;
  late ProgrammeService service;
  late _MockMeetingRepo meetingRepo;
  late UserService userService;
  late ScheduleController controller;

  setUpAll(() => registerFallbackValue(''));

  /// Any non-null user is a session as far as this screen is concerned.
  final loggedInUser = User(
    token: 'tok',
    tokenExpiration: DateTime(2030),
    label: 'FFSS',
    type: UserType.organisme,
    role: UserRole.admin,
  );

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

  /// [day] at a given hour/minute — the réunion's real date, unlike a bare
  /// `HH:mm` Slot/Run time (see [ScheduleController.endMinutesOfDay] doc).
  DateTime timeOf(int h, int m) => DateTime(day.year, day.month, day.day, h, m);

  /// A réunion already on FFSS, with one manual créneau (08:00 → 08:10).
  Meeting seedMeetingWithSlot() => Meeting(
        id: 78,
        name: 'Réunion',
        description: '',
        date: day,
        beginHour: timeOf(8, 0),
        endHour: timeOf(8, 10),
        slots: [
          Slot(
            id: 66,
            name: 'Accueil des clubs',
            beginHour: timeOf(8, 0),
            endHour: timeOf(8, 10),
          ),
        ],
      );

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
    when(() => storage.read(key: any(named: 'key')))
        .thenAnswer((_) async => null);
    when(() =>
            storage.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((_) async {});
    service = ProgrammeService(storage);
    await service.save(seed());
    meetingRepo = _MockMeetingRepo();
    userService = UserService(_MockAuthRepo());
    userService.currentUser.value = loggedInUser;
    controller = ScheduleController(service, meetingRepo, userService);
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

  group('addRaces', () {
    test('schedules every race of the group in one go', () async {
      await controller.addRaces([10, 11], 1, day);

      final rows = controller.rowsFor(1, day);
      expect(rows.map((r) => r.block.raceId), [10, 11]);
      expect(rows.map((r) => r.block.order), [0, 1]);
      expect(controller.unscheduled, isEmpty);
    });

    test('gives each new block an id of its own', () async {
      await controller.addRaces([10, 11], 1, day);

      final ids = controller.rowsFor(1, day).map((r) => r.block.id).toList();
      expect(ids.toSet().length, 2);
      // The allocation must survive the save, or the next block reuses an id.
      expect(service.current.value!.nextLocalId,
          greaterThan(ids.reduce((a, b) => a > b ? a : b)));
    });

    test('appends after what is already scheduled', () async {
      await controller.addRace(10, 1, day);

      await controller.addRaces([11], 1, day);

      expect(controller.rowsFor(1, day).map((r) => r.block.raceId), [10, 11]);
    });

    test('an empty selection changes nothing', () async {
      await controller.addRaces(const [], 1, day);

      expect(controller.rowsFor(1, day), isEmpty);
    });
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
    expect(
        controller.rowsFor(1, day).single.begin, DateTime(2026, 6, 13, 8, 30));
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
      controller = ScheduleController(service, meetingRepo, userService);
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
      controller = ScheduleController(service, meetingRepo, userService);
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

  group('endMinutesOfDay', () {
    /// Minutes past midnight — the controller's unit, per the class doc: a
    /// [Slot]/[Run] `DateTime` is parsed from a bare `HH:mm` and lands on
    /// 1970-01-01, while [Meeting.beginHour] carries the réunion's real date,
    /// so comparing the two as [DateTime]s would always read as "before".
    int minutes(int h, int m) => h * 60 + m;

    DateTime time(String hhmm) => DateFormat('HH:mm').parse(hhmm);

    /// A course of the day's single créneau, as FFSS returns it: its own
    /// site and a bare `HH:mm` begin/end, unrelated to the réunion's date.
    Run run(
            {required String site,
            required String begin,
            required String end}) =>
        Run(
          id: 1,
          name: 'Course',
          label: '',
          fullLabel: '',
          status: RunStatus.waiting,
          statusLabel: '',
          site: site,
          beginTime: time(begin),
          endTime: time(end),
        );

    /// A réunion on [day] starting at 08:00, with at most one créneau: one
    /// carrying [runs] when given, or a manual one spanning
    /// [slotBegin]..[slotEnd] when there are no runs to hang it on.
    Meeting meetingWith(
        {List<Run> runs = const [], String? slotBegin, String? slotEnd}) {
      final slots = [
        if (runs.isNotEmpty || slotBegin != null)
          Slot(
            id: 1,
            name: 'Créneau',
            beginHour: time(slotBegin ?? '08:00'),
            endHour: time(slotEnd ?? '08:00'),
            runs: runs,
          ),
      ];
      return Meeting(
        id: 1,
        name: 'Réunion',
        description: '',
        date: day,
        beginHour: DateTime(day.year, day.month, day.day, 8),
        endHour: DateTime(day.year, day.month, day.day, 18),
        slots: slots,
      );
    }

    test('la fin de journée est le maximum des sites, pas leur somme', () {
      controller.meetings.value = [
        meetingWith(runs: [
          run(site: 'Plage', begin: '08:00', end: '08:30'),
          run(site: 'Bassin', begin: '08:00', end: '09:00'),
        ])
      ];

      expect(controller.endMinutesOfDay(day), minutes(9, 0));
    });

    test('une journée sans item finit à son heure de départ', () {
      controller.meetings.value = [meetingWith(runs: const [])];

      expect(controller.endMinutesOfDay(day), minutes(8, 0));
    });

    test('un créneau sans course compte par ses propres heures', () {
      // A manual item has no course: without this case it would not weigh on
      // the day's end, and the réunion would come back too short.
      controller.meetings.value = [
        meetingWith(slotBegin: '08:00', slotEnd: '08:40', runs: const [])
      ];

      expect(controller.endMinutesOfDay(day), minutes(8, 40));
    });

    test('une journée sans réunion du tout démarre par défaut à 08:00', () {
      // The réunion's own default (08:00) differs from the local planner's
      // (09:00, see [planner.defaultStartMinutes]) — reconciled in
      // ScheduleController.defaultMeetingStartMinutes.
      expect(controller.meetings, isEmpty);

      expect(controller.endMinutesOfDay(day), minutes(8, 0));
    });
  });

  group('reload', () {
    test('pulls the current competition\'s réunion tree', () async {
      final meeting = Meeting(
        id: 1,
        name: 'Réunion',
        description: '',
        date: day,
        beginHour: DateTime(day.year, day.month, day.day, 8),
        endHour: DateTime(day.year, day.month, day.day, 18),
      );
      when(() => meetingRepo.getMeetings(42))
          .thenAnswer((_) async => [meeting]);

      await controller.reload();

      expect(controller.meetings, [meeting]);
    });

    test('does nothing before a competition is known', () async {
      controller = ScheduleController(service, meetingRepo, userService);

      await controller.reload();

      expect(controller.meetings, isEmpty);
      verifyNever(() => meetingRepo.getMeetings(any()));
    });

    test(
        'un chargement réussi remplit la journée sans laisser croire à une panne',
        () async {
      final meeting = Meeting(
        id: 2,
        name: 'Réunion',
        description: '',
        date: day,
        beginHour: DateTime(day.year, day.month, day.day, 8),
        endHour: DateTime(day.year, day.month, day.day, 18),
      );
      when(() => meetingRepo.getMeetings(42))
          .thenAnswer((_) async => [meeting]);

      await controller.reload();

      expect(controller.meetings, [meeting]);
      expect(controller.hasError.value, isFalse);
      expect(controller.isLoading.value, isFalse);
    });

    // Une panne réseau ne doit ni faire disparaître la journée déjà connue ni
    // se taire : un jour obsolète mais réel vaut mieux qu'un jour vide qui se
    // fait passer pour une réunion absente, et l'opérateur doit pouvoir voir
    // que ça a échoué pour retenter.
    test(
        'une panne réseau signale l\'échec sans effacer la journée déjà chargée',
        () async {
      final meeting = Meeting(
        id: 1,
        name: 'Réunion',
        description: '',
        date: day,
        beginHour: DateTime(day.year, day.month, day.day, 8),
        endHour: DateTime(day.year, day.month, day.day, 18),
      );
      when(() => meetingRepo.getMeetings(42))
          .thenAnswer((_) async => [meeting]);
      await controller.reload();
      expect(controller.meetings, [meeting]);

      when(() => meetingRepo.getMeetings(42))
          .thenThrow(const NetworkException('offline'));

      await controller.reload();

      expect(controller.hasError.value, isTrue);
      expect(controller.meetings, [meeting]);
      expect(controller.isLoading.value, isFalse);
    });
  });

  group('addManualItem', () {
    void stubWrites({int meetingId = 78, int slotId = 66}) {
      when(() => meetingRepo.submitMeeting(
            competitionId: any(named: 'competitionId'),
            name: any(named: 'name'),
            description: any(named: 'description'),
            date: any(named: 'date'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            id: any(named: 'id'),
          )).thenAnswer((_) async => meetingId);
      when(() => meetingRepo.submitSlot(
            meetingId: any(named: 'meetingId'),
            name: any(named: 'name'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            raceFormatDetailId: any(named: 'raceFormatDetailId'),
            id: any(named: 'id'),
          )).thenAnswer((_) async => slotId);
      when(() => meetingRepo.getMeetings(42))
          .thenAnswer((_) async => [seedMeetingWithSlot()]);
    }

    // Aucune réunion n'existe pour ce jour : le premier item la crée, sinon
    // il n'aurait rien où s'accrocher.
    test('le premier item d une journée crée la réunion', () async {
      stubWrites();

      await controller.addManualItem('Accueil des clubs', day);

      verify(() => meetingRepo.submitMeeting(
            competitionId: 42,
            name: any(named: 'name'),
            description: '',
            date: day,
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            id: null,
          )).called(1);
      verify(() => meetingRepo.submitSlot(
            meetingId: 78,
            name: 'Accueil des clubs',
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            raceFormatDetailId: null,
            id: null,
          )).called(1);
    });

    // Le créneau dure 10 minutes, donc la journée finit à 08:10 : la réunion
    // doit être renvoyée une seconde fois pour porter cette nouvelle fin.
    test('la fin de réunion est renvoyée après l ajout', () async {
      stubWrites();

      await controller.addManualItem('Accueil des clubs', day);

      verify(() => meetingRepo.submitMeeting(
            competitionId: 42,
            name: any(named: 'name'),
            description: '',
            date: day,
            beginHour: any(named: 'beginHour'),
            endHour: timeOf(8, 10),
            id: 78,
          )).called(1);
    });

    // Les heures du créneau sont calculées par le contrôleur, pas relues du
    // serveur : sans les capturer, `beginMinutes` pourrait valoir n'importe
    // quoi et la suite resterait verte, puisque les autres assertions lisent
    // le rechargement simulé.
    test('le créneau part à la fin de journée courante, pour 10 minutes',
        () async {
      stubWrites();

      await controller.addManualItem('Accueil des clubs', day);

      final times = verify(() => meetingRepo.submitSlot(
            meetingId: 78,
            name: 'Accueil des clubs',
            beginHour: captureAny(named: 'beginHour'),
            endHour: captureAny(named: 'endHour'),
            raceFormatDetailId: null,
            id: null,
          )).captured;
      expect(times, [timeOf(8, 0), timeOf(8, 10)]);
    });

    // La journée finit déjà à 08:10 : le nouvel item s'y accroche au lieu de
    // repartir du début. Un `beginMinutes` codé en dur passerait le test
    // précédent mais pas celui-ci.
    test('un item suivant part de la fin réelle de la journée', () async {
      stubWrites();
      controller.meetings.value = [seedMeetingWithSlot()];

      await controller.addManualItem('Briefing', day);

      final times = verify(() => meetingRepo.submitSlot(
            meetingId: 78,
            name: 'Briefing',
            beginHour: captureAny(named: 'beginHour'),
            endHour: captureAny(named: 'endHour'),
            raceFormatDetailId: null,
            id: null,
          )).captured;
      expect(times, [timeOf(8, 10), timeOf(8, 20)]);
    });

    // meetingFor reconnaît la réunion du jour. Si elle cessait de la trouver,
    // chaque item ajouterait une réunion de plus sur FFSS.
    test('une journée qui a déjà sa réunion n en crée pas une seconde',
        () async {
      stubWrites();
      controller.meetings.value = [seedMeetingWithSlot()];

      await controller.addManualItem('Briefing', day);

      verifyNever(() => meetingRepo.submitMeeting(
            competitionId: any(named: 'competitionId'),
            name: any(named: 'name'),
            description: any(named: 'description'),
            date: any(named: 'date'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            id: null,
          ));
    });

    // DateFormat('EEEE d MMMM y', 'fr_FR') lève une LocaleDataException tant
    // que les symboles de date ne sont pas chargés. Ce n'est pas une
    // AppException : rien ne la rattrape, et le premier item de la journée
    // disparaît en silence. main() appelle initializeDateFormatting avant
    // runApp, exactement comme ici.
    test('la réunion créée porte le jour dans la langue de l app', () async {
      await initializeDateFormatting();
      Get.locale = const Locale('fr', 'FR');
      addTearDown(() => Get.locale = null);
      stubWrites();

      await controller.addManualItem('Accueil des clubs', day);

      final name = verify(() => meetingRepo.submitMeeting(
            competitionId: 42,
            name: captureAny(named: 'name'),
            description: '',
            date: day,
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            id: null,
          )).captured.single;
      expect(name, 'samedi 13 juin 2026');
    });

    // Le rechargement a échoué : endMinutesOfDay lirait la journée d'avant
    // l'ajout et remonterait une fin trop courte, annoncée comme un succès.
    test('un rechargement en échec empêche la remontée de fin', () async {
      stubWrites();
      when(() => meetingRepo.getMeetings(42))
          .thenThrow(const NetworkException('offline'));

      await controller.addManualItem('Accueil des clubs', day);

      verifyNever(() => meetingRepo.submitMeeting(
            competitionId: any(named: 'competitionId'),
            name: any(named: 'name'),
            description: any(named: 'description'),
            date: any(named: 'date'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            id: 78,
          ));
      expect(controller.message.value!.translationKey,
          'schedule_meeting_end_failed');
    });

    test('hors session, rien ne part', () async {
      userService.currentUser.value = null;

      await controller.addManualItem('Accueil des clubs', day);

      verifyNever(() => meetingRepo.submitSlot(
            meetingId: any(named: 'meetingId'),
            name: any(named: 'name'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            raceFormatDetailId: any(named: 'raceFormatDetailId'),
            id: any(named: 'id'),
          ));
      expect(controller.message.value!.translationKey, 'login_required');
    });

    // Sans réunion valide, le créneau n'aurait aucun parent où s'accrocher.
    test('une réunion refusée par FFSS n envoie aucun créneau', () async {
      when(() => meetingRepo.submitMeeting(
            competitionId: any(named: 'competitionId'),
            name: any(named: 'name'),
            description: any(named: 'description'),
            date: any(named: 'date'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            id: any(named: 'id'),
          )).thenAnswer((_) async => 0);

      await controller.addManualItem('Accueil des clubs', day);

      verifyNever(() => meetingRepo.submitSlot(
            meetingId: any(named: 'meetingId'),
            name: any(named: 'name'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            raceFormatDetailId: any(named: 'raceFormatDetailId'),
            id: any(named: 'id'),
          ));
      // L'opérateur tape "ajouter", rien ne part : sans message, il n'a
      // aucun moyen de savoir que ce n'est pas juste sans effet.
      expect(
          controller.message.value!.translationKey, 'failed_to_create_meeting');
    });

    test('un échec réseau à la création de la réunion le signale', () async {
      when(() => meetingRepo.submitMeeting(
            competitionId: any(named: 'competitionId'),
            name: any(named: 'name'),
            description: any(named: 'description'),
            date: any(named: 'date'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            id: any(named: 'id'),
          )).thenThrow(const NetworkException('offline'));

      await controller.addManualItem('Accueil des clubs', day);

      verifyNever(() => meetingRepo.submitSlot(
            meetingId: any(named: 'meetingId'),
            name: any(named: 'name'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            raceFormatDetailId: any(named: 'raceFormatDetailId'),
            id: any(named: 'id'),
          ));
      expect(
          controller.message.value!.translationKey, 'failed_to_create_meeting');
      expect(controller.message.value!.details, 'offline');
    });

    test('un échec réseau à la création du créneau le signale', () async {
      when(() => meetingRepo.submitMeeting(
            competitionId: any(named: 'competitionId'),
            name: any(named: 'name'),
            description: any(named: 'description'),
            date: any(named: 'date'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            id: any(named: 'id'),
          )).thenAnswer((_) async => 78);
      when(() => meetingRepo.submitSlot(
            meetingId: any(named: 'meetingId'),
            name: any(named: 'name'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            raceFormatDetailId: any(named: 'raceFormatDetailId'),
            id: any(named: 'id'),
          )).thenThrow(const NetworkException('offline'));

      await controller.addManualItem('Accueil des clubs', day);

      expect(controller.message.value!.translationKey, 'schedule_item_failed');
      expect(controller.message.value!.details, 'offline');
    });

    // Le créneau a bien été enregistré : seule la remontée de la fin de
    // réunion échoue. FFSS garde alors une fin obsolète pour cette journée,
    // invisible depuis l'appareil puisque l'en-tête recalcule la sienne à
    // partir des créneaux — d'où l'obligation de le signaler ici.
    test('une remontée de fin refusée par FFSS le signale', () async {
      when(() => meetingRepo.submitMeeting(
            competitionId: any(named: 'competitionId'),
            name: any(named: 'name'),
            description: any(named: 'description'),
            date: any(named: 'date'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            id: null,
          )).thenAnswer((_) async => 78);
      when(() => meetingRepo.submitMeeting(
            competitionId: any(named: 'competitionId'),
            name: any(named: 'name'),
            description: any(named: 'description'),
            date: any(named: 'date'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            id: 78,
          )).thenAnswer((_) async => 0);
      when(() => meetingRepo.submitSlot(
            meetingId: any(named: 'meetingId'),
            name: any(named: 'name'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            raceFormatDetailId: any(named: 'raceFormatDetailId'),
            id: any(named: 'id'),
          )).thenAnswer((_) async => 66);
      when(() => meetingRepo.getMeetings(42))
          .thenAnswer((_) async => [seedMeetingWithSlot()]);

      await controller.addManualItem('Accueil des clubs', day);

      expect(controller.message.value!.translationKey,
          'schedule_meeting_end_failed');
    });

    test('un échec réseau lors de la remontée de fin le signale', () async {
      when(() => meetingRepo.submitMeeting(
            competitionId: any(named: 'competitionId'),
            name: any(named: 'name'),
            description: any(named: 'description'),
            date: any(named: 'date'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            id: null,
          )).thenAnswer((_) async => 78);
      when(() => meetingRepo.submitMeeting(
            competitionId: any(named: 'competitionId'),
            name: any(named: 'name'),
            description: any(named: 'description'),
            date: any(named: 'date'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            id: 78,
          )).thenThrow(const NetworkException('offline'));
      when(() => meetingRepo.submitSlot(
            meetingId: any(named: 'meetingId'),
            name: any(named: 'name'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            raceFormatDetailId: any(named: 'raceFormatDetailId'),
            id: any(named: 'id'),
          )).thenAnswer((_) async => 66);
      when(() => meetingRepo.getMeetings(42))
          .thenAnswer((_) async => [seedMeetingWithSlot()]);

      await controller.addManualItem('Accueil des clubs', day);

      expect(controller.message.value!.translationKey,
          'schedule_meeting_end_failed');
      expect(controller.message.value!.details, 'offline');
    });

    test('un créneau refusé par FFSS le signale', () async {
      when(() => meetingRepo.submitMeeting(
            competitionId: any(named: 'competitionId'),
            name: any(named: 'name'),
            description: any(named: 'description'),
            date: any(named: 'date'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            id: any(named: 'id'),
          )).thenAnswer((_) async => 78);
      when(() => meetingRepo.submitSlot(
            meetingId: any(named: 'meetingId'),
            name: any(named: 'name'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            raceFormatDetailId: any(named: 'raceFormatDetailId'),
            id: any(named: 'id'),
          )).thenAnswer((_) async => 0);

      await controller.addManualItem('Accueil des clubs', day);

      expect(controller.message.value!.translationKey, 'schedule_item_failed');
    });
  });

  group('setSlotDuration', () {
    setUp(() {
      controller.meetings.value = [seedMeetingWithSlot()];
    });

    test('redimensionne le créneau à partir de son propre début', () async {
      when(() => meetingRepo.submitSlot(
            meetingId: any(named: 'meetingId'),
            name: any(named: 'name'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            raceFormatDetailId: any(named: 'raceFormatDetailId'),
            id: any(named: 'id'),
          )).thenAnswer((_) async => 66);
      when(() => meetingRepo.submitMeeting(
            competitionId: any(named: 'competitionId'),
            name: any(named: 'name'),
            description: any(named: 'description'),
            date: any(named: 'date'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            id: any(named: 'id'),
          )).thenAnswer((_) async => 78);
      when(() => meetingRepo.getMeetings(42)).thenAnswer((_) async => [
            seedMeetingWithSlot().copyWith(slots: [
              seedMeetingWithSlot()
                  .slots
                  .single
                  .copyWith(endHour: timeOf(8, 20)),
            ]),
          ]);

      await controller.setSlotDuration(66, 20);

      verify(() => meetingRepo.submitSlot(
            meetingId: 78,
            name: 'Accueil des clubs',
            beginHour: timeOf(8, 0),
            endHour: timeOf(8, 20),
            raceFormatDetailId: null,
            id: 66,
          )).called(1);
      verify(() => meetingRepo.submitMeeting(
            competitionId: 42,
            name: any(named: 'name'),
            description: any(named: 'description'),
            date: day,
            beginHour: any(named: 'beginHour'),
            endHour: timeOf(8, 20),
            id: 78,
          )).called(1);
    });

    test('hors session, rien ne part', () async {
      userService.currentUser.value = null;

      await controller.setSlotDuration(66, 20);

      verifyNever(() => meetingRepo.submitSlot(
            meetingId: any(named: 'meetingId'),
            name: any(named: 'name'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            raceFormatDetailId: any(named: 'raceFormatDetailId'),
            id: any(named: 'id'),
          ));
      expect(controller.message.value!.translationKey, 'login_required');
    });

    // Sans rechargement réussi, la fin remontée serait celle d'avant le
    // redimensionnement — trop courte, et présentée comme un succès.
    test('un rechargement en échec empêche la remontée de fin', () async {
      when(() => meetingRepo.submitSlot(
            meetingId: any(named: 'meetingId'),
            name: any(named: 'name'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            raceFormatDetailId: any(named: 'raceFormatDetailId'),
            id: any(named: 'id'),
          )).thenAnswer((_) async => 66);
      when(() => meetingRepo.getMeetings(42))
          .thenThrow(const NetworkException('offline'));

      await controller.setSlotDuration(66, 20);

      verifyNever(() => meetingRepo.submitMeeting(
            competitionId: any(named: 'competitionId'),
            name: any(named: 'name'),
            description: any(named: 'description'),
            date: any(named: 'date'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            id: any(named: 'id'),
          ));
      expect(controller.message.value!.translationKey,
          'schedule_meeting_end_failed');
    });

    test('un créneau inconnu ne fait rien', () async {
      await controller.setSlotDuration(999, 20);

      verifyNever(() => meetingRepo.submitSlot(
            meetingId: any(named: 'meetingId'),
            name: any(named: 'name'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            raceFormatDetailId: any(named: 'raceFormatDetailId'),
            id: any(named: 'id'),
          ));
    });

    // Un jeton expiré ou une coupure réseau ne doit pas planter en silence :
    // l'opérateur doit voir pourquoi son geste n'a rien changé.
    test('un échec réseau le signale', () async {
      when(() => meetingRepo.submitSlot(
            meetingId: any(named: 'meetingId'),
            name: any(named: 'name'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            raceFormatDetailId: any(named: 'raceFormatDetailId'),
            id: any(named: 'id'),
          )).thenThrow(const NetworkException('offline'));

      await controller.setSlotDuration(66, 20);

      expect(controller.message.value!.translationKey, 'schedule_item_failed');
      expect(controller.message.value!.details, 'offline');
    });
  });

  group('removeSlot', () {
    setUp(() {
      controller.meetings.value = [seedMeetingWithSlot()];
    });

    test('supprime le créneau puis pousse la nouvelle fin', () async {
      when(() => meetingRepo.deleteSlot(66)).thenAnswer((_) async => true);
      when(() => meetingRepo.getMeetings(42)).thenAnswer(
          (_) async => [seedMeetingWithSlot().copyWith(slots: const [])]);
      when(() => meetingRepo.submitMeeting(
            competitionId: any(named: 'competitionId'),
            name: any(named: 'name'),
            description: any(named: 'description'),
            date: any(named: 'date'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            id: any(named: 'id'),
          )).thenAnswer((_) async => 78);

      await controller.removeSlot(66);

      verify(() => meetingRepo.deleteSlot(66)).called(1);
      verify(() => meetingRepo.submitMeeting(
            competitionId: 42,
            name: any(named: 'name'),
            description: any(named: 'description'),
            date: day,
            beginHour: any(named: 'beginHour'),
            endHour: timeOf(8, 0),
            id: 78,
          )).called(1);
    });

    test('hors session, rien ne part', () async {
      userService.currentUser.value = null;

      await controller.removeSlot(66);

      verifyNever(() => meetingRepo.deleteSlot(any()));
      expect(controller.message.value!.translationKey, 'login_required');
    });

    test('un échec de suppression le signale', () async {
      when(() => meetingRepo.deleteSlot(66)).thenAnswer((_) async => false);

      await controller.removeSlot(66);

      expect(controller.message.value!.translationKey, 'schedule_item_failed');
    });

    test('un échec réseau le signale', () async {
      when(() => meetingRepo.deleteSlot(66))
          .thenThrow(const NetworkException('offline'));

      await controller.removeSlot(66);

      expect(controller.message.value!.translationKey, 'schedule_item_failed');
      expect(controller.message.value!.details, 'offline');
    });

    // La suppression a bien eu lieu, mais la liste rechargée porte encore le
    // créneau : la fin remontée serait trop longue, et donnée pour bonne.
    test('un rechargement en échec empêche la remontée de fin', () async {
      when(() => meetingRepo.deleteSlot(66)).thenAnswer((_) async => true);
      when(() => meetingRepo.getMeetings(42))
          .thenThrow(const NetworkException('offline'));

      await controller.removeSlot(66);

      verifyNever(() => meetingRepo.submitMeeting(
            competitionId: any(named: 'competitionId'),
            name: any(named: 'name'),
            description: any(named: 'description'),
            date: any(named: 'date'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            id: any(named: 'id'),
          ));
      expect(controller.message.value!.translationKey,
          'schedule_meeting_end_failed');
    });

    test('un créneau inconnu ne fait rien', () async {
      await controller.removeSlot(999);

      verifyNever(() => meetingRepo.deleteSlot(any()));
    });
  });
}
