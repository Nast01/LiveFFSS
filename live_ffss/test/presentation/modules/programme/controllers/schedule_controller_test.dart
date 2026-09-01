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
import 'package:live_ffss/app/domain/models/race_format_detail.dart';
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

  test('setCompetition derives days and defaults to every site', () {
    expect(controller.days, [DateTime(2026, 6, 13), DateTime(2026, 6, 14)]);
    // « Tous » : la vue s'ouvre sur la journée entière, pas sur un site
    // arbitraire dont l'opérateur ignore qu'il en masque d'autres.
    expect(controller.selectedSite.value, isNull);
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

    test('supprimer le site sélectionné rebascule sur « Tous »', () async {
      await service.save(seedTwoSites());
      controller = ScheduleController(service, meetingRepo, userService);
      controller.onInit();
      controller.setCompetition(withDates);
      controller.selectedSite.value = 'Côtier 1';

      await service.save(service.current.value!.copyWith(
        sites: const [
          ProgrammeSite(id: 2, name: 'Côtier 2', type: SiteType.cotier),
        ],
      ));
      await Future<void>.delayed(Duration.zero);

      expect(controller.selectedSite.value, isNull);
    });

    test('un site encore porté par une course survit à sa suppression locale',
        () async {
      // Le site vient de FFSS autant que de la liste locale : effacer la
      // fiche locale ne fait pas disparaître les courses qui s'y courent.
      await service.save(seedTwoSites());
      controller = ScheduleController(service, meetingRepo, userService);
      controller.onInit();
      controller.setCompetition(withDates);
      controller.meetings.value = [
        Meeting(
          id: 1,
          name: 'Réunion',
          description: '',
          date: day,
          beginHour: DateTime(2026, 6, 13, 8),
          endHour: DateTime(2026, 6, 13, 18),
          slots: [
            Slot(
              id: 1,
              name: 'Créneau',
              beginHour: DateFormat('HH:mm').parse('08:00'),
              endHour: DateFormat('HH:mm').parse('08:10'),
              runs: [
                Run(
                  id: 1,
                  name: 'Course',
                  label: '',
                  fullLabel: '',
                  status: RunStatus.waiting,
                  statusLabel: '',
                  site: 'Côtier 1',
                  beginTime: DateFormat('HH:mm').parse('08:00'),
                  endTime: DateFormat('HH:mm').parse('08:10'),
                ),
              ],
            ),
          ],
        ),
      ];
      controller.selectedSite.value = 'Côtier 1';

      await service.save(service.current.value!.copyWith(
        sites: const [
          ProgrammeSite(id: 2, name: 'Côtier 2', type: SiteType.cotier),
        ],
      ));
      await Future<void>.delayed(Duration.zero);

      expect(controller.selectedSite.value, 'Côtier 1');
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

  group('setMeetingStart', () {
    /// The hour and minute a write actually carried, ignoring its date.
    String hm(DateTime t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    /// A day already on FFSS: réunion 78 starting at 08:00 with one manual
    /// créneau 66 running 08:00 → 08:10.
    void loadedDay() {
      controller.setCompetition(withDates);
      controller.meetings.value = [seedMeetingWithSlot()];
    }

    void answerWrites() {
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
      when(() => meetingRepo.getMeetings(any()))
          .thenAnswer((_) async => [seedMeetingWithSlot()]);
    }

    test('hors session, rien ne part', () async {
      loadedDay();
      userService.currentUser.value = null;

      await controller.setMeetingStart(day, 9 * 60);

      verifyNever(() => meetingRepo.submitMeeting(
            competitionId: any(named: 'competitionId'),
            name: any(named: 'name'),
            description: any(named: 'description'),
            date: any(named: 'date'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            id: any(named: 'id'),
          ));
      expect(controller.message.value!.translationKey, 'login_required');
    });

    test('décale chaque créneau du même écart que le départ', () async {
      // Déplacer le départ sans déplacer les items laisserait la journée
      // commencer avant son premier créneau : les horaires ne voudraient plus
      // rien dire.
      loadedDay();
      answerWrites();

      await controller.setMeetingStart(day, 9 * 60);

      final captured = verify(() => meetingRepo.submitSlot(
            meetingId: any(named: 'meetingId'),
            name: any(named: 'name'),
            beginHour: captureAny(named: 'beginHour'),
            endHour: captureAny(named: 'endHour'),
            raceFormatDetailId: any(named: 'raceFormatDetailId'),
            id: captureAny(named: 'id'),
          )).captured;
      expect(hm(captured[0] as DateTime), '09:00');
      expect(hm(captured[1] as DateTime), '09:10');
      expect(captured[2], 66); // une mise à jour, pas un doublon
    });

    test('pousse le nouveau départ de la réunion', () async {
      loadedDay();
      answerWrites();

      await controller.setMeetingStart(day, 9 * 60);

      final captured = verify(() => meetingRepo.submitMeeting(
            competitionId: any(named: 'competitionId'),
            name: any(named: 'name'),
            description: any(named: 'description'),
            date: any(named: 'date'),
            beginHour: captureAny(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            id: captureAny(named: 'id'),
          )).captured;
      expect(hm(captured[0] as DateTime), '09:00');
      expect(captured[1], 78); // la réunion existante, mise à jour
    });

    test('un créneau refusé arrête le décalage et le dit', () async {
      // Poursuivre laisserait la journée à moitié décalée, ce que le
      // rechargement suivant afficherait sans jamais l'expliquer.
      loadedDay();
      answerWrites();
      when(() => meetingRepo.submitSlot(
            meetingId: any(named: 'meetingId'),
            name: any(named: 'name'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            raceFormatDetailId: any(named: 'raceFormatDetailId'),
            id: any(named: 'id'),
          )).thenAnswer((_) async => 0);

      await controller.setMeetingStart(day, 9 * 60);

      expect(controller.message.value!.translationKey, 'schedule_item_failed');
      verifyNever(() => meetingRepo.submitMeeting(
            competitionId: any(named: 'competitionId'),
            name: any(named: 'name'),
            description: any(named: 'description'),
            date: any(named: 'date'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            id: any(named: 'id'),
          ));
    });

    test('une panne réseau porte la raison du serveur', () async {
      loadedDay();
      answerWrites();
      when(() => meetingRepo.submitSlot(
            meetingId: any(named: 'meetingId'),
            name: any(named: 'name'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            raceFormatDetailId: any(named: 'raceFormatDetailId'),
            id: any(named: 'id'),
          )).thenThrow(const NetworkException('offline'));

      await controller.setMeetingStart(day, 9 * 60);

      expect(controller.message.value!.details, 'offline');
    });

    test('une journée sans réunion ne crée rien et le dit', () async {
      // Rien à décaler : créer une réunion vide sur un simple réglage d'heure
      // laisserait des journées fantômes sur le site fédéral.
      controller.setCompetition(withDates);
      answerWrites();

      await controller.setMeetingStart(day, 9 * 60);

      verifyNever(() => meetingRepo.submitMeeting(
            competitionId: any(named: 'competitionId'),
            name: any(named: 'name'),
            description: any(named: 'description'),
            date: any(named: 'date'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            id: any(named: 'id'),
          ));
      expect(controller.message.value!.translationKey, 'schedule_no_meeting');
    });
  });

  group('reload silencieux', () {
    test('ne lève jamais isLoading, pour ne pas arracher le geste', () async {
      // Un tirer-pour-rafraîchir qui remplace la liste par un indicateur de
      // chargement retire la roue de sous le doigt de l'opérateur.
      controller.setCompetition(withDates);
      when(() => meetingRepo.getMeetings(42))
          .thenAnswer((_) async => [seedMeetingWithSlot()]);
      var sawLoading = false;
      final worker = ever<bool>(controller.isLoading, (v) {
        if (v) sawLoading = true;
      });

      await controller.reload(silent: true);

      worker.dispose();
      expect(sawLoading, isFalse);
      expect(controller.isLoading.value, isFalse);
      expect(controller.meetings, hasLength(1));
    });

    test('un échec reste signalé même en silencieux', () async {
      controller.setCompetition(withDates);
      when(() => meetingRepo.getMeetings(42))
          .thenThrow(const NetworkException('offline'));

      expect(await controller.reload(silent: true), isFalse);
      expect(controller.hasError.value, isTrue);
    });

    test('un rechargement ordinaire lève toujours isLoading', () async {
      controller.setCompetition(withDates);
      when(() => meetingRepo.getMeetings(42))
          .thenAnswer((_) async => [seedMeetingWithSlot()]);
      var sawLoading = false;
      final worker = ever<bool>(controller.isLoading, (v) {
        if (v) sawLoading = true;
      });

      await controller.reload();

      worker.dispose();
      expect(sawLoading, isTrue);
    });
  });

  group('recalcul des horaires apres une modification', () {
    String hm(DateTime t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    /// A day of three back-to-back manual items, 10 minutes each from 08:00.
    Meeting threeItems() => Meeting(
          id: 78,
          name: 'Réunion',
          description: '',
          date: day,
          beginHour: timeOf(8, 0),
          endHour: timeOf(8, 30),
          slots: [
            Slot(
                id: 1,
                name: 'Accueil',
                beginHour: timeOf(8, 0),
                endHour: timeOf(8, 10)),
            Slot(
                id: 2,
                name: 'Briefing',
                beginHour: timeOf(8, 10),
                endHour: timeOf(8, 20)),
            Slot(
                id: 3,
                name: 'Remise des prix',
                beginHour: timeOf(8, 20),
                endHour: timeOf(8, 30)),
          ],
        );

    /// After the delete, FFSS no longer holds the middle item — but the third
    /// still carries the times it had, which is the hole under test.
    Meeting withoutMiddle() => threeItems().copyWith(
          slots: [threeItems().slots.first, threeItems().slots.last],
        );

    void answerWrites() {
      when(() => meetingRepo.deleteSlot(any())).thenAnswer((_) async => true);
      when(() => meetingRepo.submitSlot(
            meetingId: any(named: 'meetingId'),
            name: any(named: 'name'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            raceFormatDetailId: any(named: 'raceFormatDetailId'),
            id: any(named: 'id'),
          )).thenAnswer((_) async => 3);
      when(() => meetingRepo.submitMeeting(
            competitionId: any(named: 'competitionId'),
            name: any(named: 'name'),
            description: any(named: 'description'),
            date: any(named: 'date'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            id: any(named: 'id'),
          )).thenAnswer((_) async => 78);
    }

    setUp(() {
      controller.setCompetition(withDates);
      controller.meetings.value = [threeItems()];
      answerWrites();
      when(() => meetingRepo.getMeetings(42))
          .thenAnswer((_) async => [withoutMiddle()]);
    });

    test('supprimer au milieu remonte les items suivants', () async {
      // Sans ce recalcul la journee garde un trou de dix minutes la ou l item
      // se trouvait, et les horaires affiches deviennent faux jusqu au soir.
      await controller.removeSlot(2);

      final captured = verify(() => meetingRepo.submitSlot(
            meetingId: any(named: 'meetingId'),
            name: any(named: 'name'),
            beginHour: captureAny(named: 'beginHour'),
            endHour: captureAny(named: 'endHour'),
            raceFormatDetailId: any(named: 'raceFormatDetailId'),
            id: captureAny(named: 'id'),
          )).captured;
      expect(captured, hasLength(3)); // un seul creneau reecrit
      expect(hm(captured[0] as DateTime), '08:10');
      expect(hm(captured[1] as DateTime), '08:20');
      expect(captured[2], 3);
    });

    test('les items situes avant ne sont pas reecrits pour rien', () async {
      await controller.removeSlot(2);

      verifyNever(() => meetingRepo.submitSlot(
            meetingId: any(named: 'meetingId'),
            name: any(named: 'name'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            raceFormatDetailId: any(named: 'raceFormatDetailId'),
            id: 1,
          ));
    });

    test('la fin de reunion suit le dernier item recale', () async {
      await controller.removeSlot(2);

      final captured = verify(() => meetingRepo.submitMeeting(
            competitionId: any(named: 'competitionId'),
            name: any(named: 'name'),
            description: any(named: 'description'),
            date: any(named: 'date'),
            beginHour: any(named: 'beginHour'),
            endHour: captureAny(named: 'endHour'),
            id: any(named: 'id'),
          )).captured;
      expect(hm(captured.last as DateTime), '08:20');
    });

    test('un recalage refuse est signale', () async {
      when(() => meetingRepo.submitSlot(
            meetingId: any(named: 'meetingId'),
            name: any(named: 'name'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            raceFormatDetailId: any(named: 'raceFormatDetailId'),
            id: any(named: 'id'),
          )).thenAnswer((_) async => 0);

      await controller.removeSlot(2);

      expect(controller.message.value!.translationKey, 'schedule_item_failed');
    });

    test('raccourcir un item remonte aussi ceux qui suivent', () async {
      // Meme trou, meme cause : changer une duree deplace tout ce qui suit.
      when(() => meetingRepo.getMeetings(42)).thenAnswer((_) async => [
            threeItems().copyWith(slots: [
              threeItems().slots.first.copyWith(endHour: timeOf(8, 5)),
              threeItems().slots[1],
              threeItems().slots.last,
            ])
          ]);

      await controller.setSlotDuration(1, 5);

      final captured = verify(() => meetingRepo.submitSlot(
            meetingId: any(named: 'meetingId'),
            name: any(named: 'name'),
            beginHour: captureAny(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            raceFormatDetailId: any(named: 'raceFormatDetailId'),
            id: captureAny(named: 'id'),
          )).captured;
      // Le premier a deja ete recale par setSlotDuration lui-meme ; les deux
      // suivants remontent de cinq minutes.
      expect(hm(captured[captured.length - 4] as DateTime), '08:05');
      expect(captured[captured.length - 3], 2);
      expect(hm(captured[captured.length - 2] as DateTime), '08:15');
      expect(captured.last, 3);
    });
  });

  group('reorderSlots', () {
    String hm(DateTime t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    Meeting threeItems() => Meeting(
          id: 78,
          name: 'Réunion',
          description: '',
          date: day,
          beginHour: timeOf(8, 0),
          endHour: timeOf(8, 30),
          slots: [
            Slot(
                id: 1,
                name: 'Accueil',
                beginHour: timeOf(8, 0),
                endHour: timeOf(8, 10)),
            Slot(
                id: 2,
                name: 'Briefing',
                beginHour: timeOf(8, 10),
                endHour: timeOf(8, 25)),
            Slot(
                id: 3,
                name: 'Remise des prix',
                beginHour: timeOf(8, 25),
                endHour: timeOf(8, 35)),
          ],
        );

    setUp(() {
      controller.setCompetition(withDates);
      controller.meetings.value = [threeItems()];
      when(() => meetingRepo.getMeetings(42))
          .thenAnswer((_) async => [threeItems()]);
      when(() => meetingRepo.submitSlot(
            meetingId: any(named: 'meetingId'),
            name: any(named: 'name'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            raceFormatDetailId: any(named: 'raceFormatDetailId'),
            id: any(named: 'id'),
          )).thenAnswer((_) async => 1);
      when(() => meetingRepo.submitMeeting(
            competitionId: any(named: 'competitionId'),
            name: any(named: 'name'),
            description: any(named: 'description'),
            date: any(named: 'date'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            id: any(named: 'id'),
          )).thenAnswer((_) async => 78);
    });

    test('remonter le dernier en tête recale toute la journée', () async {
      // 10 + 15 + 10 minutes : l'ordre change, les durées ne bougent pas.
      await controller.reorderSlots(day, 2, 0);

      final captured = verify(() => meetingRepo.submitSlot(
            meetingId: any(named: 'meetingId'),
            name: captureAny(named: 'name'),
            beginHour: captureAny(named: 'beginHour'),
            endHour: captureAny(named: 'endHour'),
            raceFormatDetailId: any(named: 'raceFormatDetailId'),
            id: any(named: 'id'),
          )).captured;
      expect(captured[0], 'Remise des prix');
      expect(hm(captured[1] as DateTime), '08:00');
      expect(hm(captured[2] as DateTime), '08:10'); // garde ses 10 minutes
      expect(captured[3], 'Accueil');
      expect(hm(captured[4] as DateTime), '08:10');
      expect(captured[6], 'Briefing');
      expect(hm(captured[7] as DateTime), '08:20');
      expect(hm(captured[8] as DateTime), '08:35'); // garde ses 15 minutes
    });

    test('un déplacement vers le bas vise la bonne place', () async {
      // ReorderableListView compte newIndex sur la liste AVANT le retrait :
      // sans la correction, l'item atterrirait une place trop loin.
      await controller.reorderSlots(day, 0, 2);

      final captured = verify(() => meetingRepo.submitSlot(
            meetingId: any(named: 'meetingId'),
            name: captureAny(named: 'name'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            raceFormatDetailId: any(named: 'raceFormatDetailId'),
            id: any(named: 'id'),
          )).captured;
      expect(captured, ['Briefing', 'Accueil']);
    });

    test('déposer un item à sa propre place n envoie rien', () async {
      await controller.reorderSlots(day, 1, 2);

      verifyNever(() => meetingRepo.submitSlot(
            meetingId: any(named: 'meetingId'),
            name: any(named: 'name'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            raceFormatDetailId: any(named: 'raceFormatDetailId'),
            id: any(named: 'id'),
          ));
    });

    test('hors session, rien ne part', () async {
      userService.currentUser.value = null;

      await controller.reorderSlots(day, 2, 0);

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
  });

  group('placer un tour', () {
    String hm(DateTime t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    /// A local structure whose rounds carry the FFSS partie ids they were
    /// given when the déroulement was pushed from the Structure tab.
    CompetitionProgramme structures({int serieServerId = 39}) =>
        CompetitionProgramme(
          competitionId: 42,
          nextLocalId: 100,
          sites: const [
            ProgrammeSite(id: 1, name: 'Plage', type: SiteType.cotier)
          ],
          structures: [
            EventStructure(
              raceId: 500,
              categoryId: 7,
              raceLabel: 'Surfski',
              categoryLabel: 'Junior',
              levels: [
                RoundLevel(
                  type: RoundType.serie,
                  serverId: serieServerId,
                  races: const [
                    ProgrammeRace(id: 1, number: 1),
                    ProgrammeRace(id: 2, number: 2),
                  ],
                ),
                const RoundLevel(
                  type: RoundType.finale,
                  serverId: 40,
                  races: [ProgrammeRace(id: 3, number: 1)],
                ),
              ],
            ),
          ],
        );

    Meeting emptyDay() => Meeting(
          id: 78,
          name: 'Réunion',
          description: '',
          date: day,
          beginHour: timeOf(8, 0),
          endHour: timeOf(8, 0),
        );

    setUp(() async {
      controller.setCompetition(withDates);
      await service.save(structures());
      controller.meetings.value = [emptyDay()];
      when(() => meetingRepo.getMeetings(42))
          .thenAnswer((_) async => [emptyDay()]);
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
      when(() => meetingRepo.submitRun(
            slotId: any(named: 'slotId'),
            name: any(named: 'name'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            site: any(named: 'site'),
            id: any(named: 'id'),
          )).thenAnswer((_) async => 24);
      when(() => meetingRepo.createDefaultLanes(
              runId: any(named: 'runId'), count: any(named: 'count')))
          .thenAnswer((invocation) async =>
              invocation.namedArguments[const Symbol('count')] as int);
    });

    test('propose un tour par niveau, avec son nombre de courses', () {
      final rounds = controller.unscheduledRounds;

      expect(rounds, hasLength(2));
      expect(rounds.first.type, RoundType.serie);
      expect(rounds.first.partieId, 39);
      expect(rounds.first.courseCount, 2);
      expect(rounds.first.raceLabel, 'Surfski');
      expect(rounds.first.categoryLabel, 'Junior');
    });

    test('un tour absent de FFSS n est pas proposé', () async {
      // Sans partie sur le serveur, aucun créneau ne peut s'y accrocher : le
      // proposer mènerait droit à un refus que l'opérateur ne comprendrait pas.
      await service.save(structures(serieServerId: 0));

      expect(controller.unscheduledRounds.map((r) => r.partieId), [40]);
    });

    test('un tour déjà porté par un créneau disparaît de la liste', () {
      controller.meetings.value = [
        emptyDay().copyWith(slots: [
          Slot(
            id: 66,
            name: 'Séries - Surfski',
            beginHour: timeOf(8, 0),
            endHour: timeOf(8, 10),
            raceFormatDetail: const RaceFormatDetail(
              id: 39,
              order: 1,
              label: '',
              fullLabel: '',
              levelLabel: '',
              level: 'heat',
              numberOfRun: 2,
              qualificationMethod: 'none',
              qualificationMethodLabel: '',
              spotsPerRace: 8,
              qualifyingSpots: 0,
            ),
          ),
        ])
      ];

      expect(controller.unscheduledRounds.map((r) => r.partieId), [40]);
    });

    test('placer un tour crée un créneau lié à sa partie', () async {
      // Les courses viendront du site FFSS : ce créneau les accueillera, et sa
      // durée vaut la durée par défaut multipliée par leur nombre — deux ici.
      await controller.scheduleRound(
        partieId: 39,
        name: 'Séries - Surfski - Dames - Junior',
        courseNames: const ['Série 1 - Surfski', 'Série 2 - Surfski'],
        spotsPerRace: 8,
        site: 'Plage',
        day: day,
      );

      final captured = verify(() => meetingRepo.submitSlot(
            meetingId: captureAny(named: 'meetingId'),
            name: captureAny(named: 'name'),
            beginHour: captureAny(named: 'beginHour'),
            endHour: captureAny(named: 'endHour'),
            raceFormatDetailId: captureAny(named: 'raceFormatDetailId'),
            id: any(named: 'id'),
          )).captured;
      expect(captured[0], 78);
      expect(captured[1], 'Séries - Surfski - Dames - Junior');
      expect(hm(captured[2] as DateTime), '08:00');
      expect(hm(captured[3] as DateTime), '08:20');
      expect(captured[4], 39);
    });

    test('hors session, rien ne part', () async {
      userService.currentUser.value = null;

      await controller.scheduleRound(
          partieId: 39,
          name: 'x',
          courseNames: const ['a', 'b'],
          spotsPerRace: 8,
          site: 'Plage',
          day: day);

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

    test('un tour sans course occupe quand même la durée par défaut', () async {
      // Une durée nulle rendrait l'item invisible sur la frise et laisserait
      // le suivant démarrer à la même minute.
      await controller.scheduleRound(
          partieId: 39,
          name: 'x',
          courseNames: const [],
          spotsPerRace: 8,
          site: 'Plage',
          day: day);

      final captured = verify(() => meetingRepo.submitSlot(
            meetingId: any(named: 'meetingId'),
            name: any(named: 'name'),
            beginHour: captureAny(named: 'beginHour'),
            endHour: captureAny(named: 'endHour'),
            raceFormatDetailId: any(named: 'raceFormatDetailId'),
            id: any(named: 'id'),
          )).captured;
      expect(hm(captured[0] as DateTime), '08:00');
      expect(hm(captured[1] as DateTime), '08:10');
    });

    test('un refus du serveur est signalé', () async {
      when(() => meetingRepo.submitSlot(
            meetingId: any(named: 'meetingId'),
            name: any(named: 'name'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            raceFormatDetailId: any(named: 'raceFormatDetailId'),
            id: any(named: 'id'),
          )).thenAnswer((_) async => 0);

      await controller.scheduleRound(
          partieId: 39,
          name: 'x',
          courseNames: const ['a', 'b'],
          spotsPerRace: 8,
          site: 'Plage',
          day: day);

      expect(controller.message.value!.translationKey, 'schedule_item_failed');
    });

    // Le créneau n'est qu'un contenant : ce sont ses courses qui se courent.
    // Elles s'enchaînent bout à bout, chacune pour la durée par défaut.
    test('placer un tour crée ses courses, enchaînées dans le créneau',
        () async {
      await controller.scheduleRound(
        partieId: 39,
        name: 'Séries - Surfski - Dames - Junior',
        courseNames: const [
          'Série 1 - Surfski - Dames - Junior',
          'Série 2 - Surfski - Dames - Junior',
        ],
        spotsPerRace: 8,
        site: 'Plage',
        day: day,
      );

      final captured = verify(() => meetingRepo.submitRun(
            slotId: captureAny(named: 'slotId'),
            name: captureAny(named: 'name'),
            beginHour: captureAny(named: 'beginHour'),
            endHour: captureAny(named: 'endHour'),
            site: captureAny(named: 'site'),
            id: any(named: 'id'),
          )).captured;

      expect(captured, hasLength(10));
      expect(captured[0], 66);
      expect(captured[1], 'Série 1 - Surfski - Dames - Junior');
      expect(hm(captured[2] as DateTime), '08:00');
      expect(hm(captured[3] as DateTime), '08:10');
      expect(captured[4], 'Plage');
      expect(captured[6], 'Série 2 - Surfski - Dames - Junior');
      expect(hm(captured[7] as DateTime), '08:10');
      expect(hm(captured[8] as DateTime), '08:20');
    });

    // Une course s'ouvre avec ses emplacements de départ, autant que le tour
    // en déclare : sans eux, elle arrive vide sur la ligne de départ.
    test('chaque course s ouvre avec les places de son tour', () async {
      await controller.scheduleRound(
        partieId: 39,
        name: 'x',
        courseNames: const ['a', 'b'],
        spotsPerRace: 8,
        site: 'Plage',
        day: day,
      );

      verify(() => meetingRepo.createDefaultLanes(runId: 24, count: 8))
          .called(2);
    });

    test('un tour sans place déclarée ne demande aucune place', () async {
      await controller.scheduleRound(
        partieId: 39,
        name: 'x',
        courseNames: const ['a'],
        spotsPerRace: 0,
        site: 'Plage',
        day: day,
      );

      verifyNever(() => meetingRepo.createDefaultLanes(
          runId: any(named: 'runId'), count: any(named: 'count')));
    });

    // Poser la moitié des courses sans le dire laisserait l'opérateur devant
    // un tour incomplet qu'il croit complet.
    test('une course refusée n arrête pas les suivantes mais est signalée',
        () async {
      when(() => meetingRepo.submitRun(
            slotId: any(named: 'slotId'),
            name: 'a',
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            site: any(named: 'site'),
            id: any(named: 'id'),
          )).thenAnswer((_) async => 0);

      await controller.scheduleRound(
        partieId: 39,
        name: 'x',
        courseNames: const ['a', 'b'],
        spotsPerRace: 8,
        site: 'Plage',
        day: day,
      );

      verify(() => meetingRepo.submitRun(
            slotId: any(named: 'slotId'),
            name: 'b',
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            site: any(named: 'site'),
            id: any(named: 'id'),
          )).called(1);
      expect(
          controller.message.value!.translationKey, 'schedule_courses_failed');
    });

    test('le tour propose le nombre de places de son niveau', () {
      expect(controller.unscheduledRounds.first.spotsPerRace, 8);
    });
  });


  group('filtrage par site', () {
    DateTime time(String hhmm) => DateFormat('HH:mm').parse(hhmm);

    Run run(String site) => Run(
          id: 1,
          name: 'Course',
          label: '',
          fullLabel: '',
          status: RunStatus.waiting,
          statusLabel: '',
          site: site,
          beginTime: time('08:00'),
          endTime: time('08:10'),
        );

    void seedRuns(List<Run> runs) {
      controller.meetings.value = [
        Meeting(
          id: 1,
          name: 'Réunion',
          description: '',
          date: day,
          beginHour: DateTime(day.year, day.month, day.day, 8),
          endHour: DateTime(day.year, day.month, day.day, 18),
          slots: [
            Slot(
              id: 1,
              name: 'Créneau',
              beginHour: time('08:00'),
              endHour: time('08:10'),
              runs: runs,
            ),
          ],
        ),
      ];
    }

    // La liste locale est saisie à la main, les courses portent le site que
    // FFSS leur donne : ni l'une ni l'autre ne connaît la totalité.
    test('les sites proposés réunissent ceux des courses et la liste locale',
        () {
      seedRuns([run('OCEAN 1'), run('OCEAN 2')]);

      expect(controller.siteNamesFor(day), ['Côtier 1', 'OCEAN 1', 'OCEAN 2']);
    });

    test('un site connu des deux côtés n apparaît qu une fois', () {
      seedRuns([run('Côtier 1')]);

      expect(controller.siteNamesFor(day), ['Côtier 1']);
    });

    test('un site sans nom ne devient pas un bouton vide', () {
      seedRuns([run('')]);

      expect(controller.siteNamesFor(day), ['Côtier 1']);
    });

    test('les sites d une autre journée ne polluent pas celle-ci', () {
      seedRuns([run('OCEAN 1')]);

      expect(controller.siteNamesFor(DateTime(2026, 6, 14)), ['Côtier 1']);
    });

    test('« Tous » laisse passer tous les sites', () {
      expect(controller.selectedSite.value, isNull);
      expect(controller.showsSite('OCEAN 1'), isTrue);
      expect(controller.showsSite('OCEAN 2'), isTrue);
    });

    test('un site sélectionné ne laisse passer que lui', () {
      controller.selectedSite.value = 'OCEAN 1';

      expect(controller.showsSite('OCEAN 1'), isTrue);
      expect(controller.showsSite('OCEAN 2'), isFalse);
    });
  });

  group('supprimer une course', () {
    String hm(DateTime t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    DateTime hhmm(String v) => DateFormat('HH:mm').parse(v);

    Run courseOf(int id, String name, String begin, String end) => Run(
          id: id,
          name: name,
          label: name,
          fullLabel: name,
          status: RunStatus.waiting,
          statusLabel: '',
          site: 'OCEAN 1',
          beginTime: hhmm(begin),
          endTime: hhmm(end),
        );

    /// Une journée d'un seul créneau portant deux courses de dix minutes.
    Meeting twoCourses() => Meeting(
          id: 78,
          name: 'Réunion',
          description: '',
          date: day,
          beginHour: timeOf(8, 0),
          endHour: timeOf(8, 20),
          slots: [
            Slot(
              id: 66,
              name: 'Demies - Surfski',
              beginHour: hhmm('08:00'),
              endHour: hhmm('08:20'),
              runs: [
                courseOf(25, 'Demie 1', '08:00', '08:10'),
                courseOf(26, 'Demie 2', '08:10', '08:20'),
              ],
            ),
          ],
        );

    /// Ce que FFSS renvoie une fois la première course partie : la seconde
    /// garde l'heure qu'elle avait, et le créneau sa durée — le trou à combler.
    Meeting oneCourseLeft() => twoCourses().copyWith(
          slots: [
            twoCourses().slots.single.copyWith(
              runs: [courseOf(26, 'Demie 2', '08:10', '08:20')],
            ),
          ],
        );

    setUp(() {
      controller.setCompetition(withDates);
      controller.meetings.value = [twoCourses()];
      when(() => meetingRepo.deleteRun(any())).thenAnswer((_) async => true);
      when(() => meetingRepo.deleteSlot(any())).thenAnswer((_) async => true);
      when(() => meetingRepo.submitRun(
            slotId: any(named: 'slotId'),
            name: any(named: 'name'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            site: any(named: 'site'),
            id: any(named: 'id'),
          )).thenAnswer((_) async => 26);
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
      when(() => meetingRepo.getMeetings(42))
          .thenAnswer((_) async => [oneCourseLeft()]);
    });

    test('la course part du serveur', () async {
      await controller.removeRun(25);

      verify(() => meetingRepo.deleteRun(25)).called(1);
    });

    // Le créneau garde son rang dans la journée : seule sa durée change.
    test('le créneau rétrécit de la durée de la course partie', () async {
      await controller.removeRun(25);

      final captured = verify(() => meetingRepo.submitSlot(
            meetingId: any(named: 'meetingId'),
            name: any(named: 'name'),
            beginHour: captureAny(named: 'beginHour'),
            endHour: captureAny(named: 'endHour'),
            raceFormatDetailId: any(named: 'raceFormatDetailId'),
            id: any(named: 'id'),
          )).captured;
      expect(hm(captured[0] as DateTime), '08:00');
      expect(hm(captured[1] as DateTime), '08:10');
    });

    // Sans cela la course restante garde 08:10 alors que son créneau commence
    // à 08:00 : la frise affiche un trou de dix minutes qui n'existe pas.
    test('la course restante remonte au début de son créneau', () async {
      await controller.removeRun(25);

      final captured = verify(() => meetingRepo.submitRun(
            slotId: any(named: 'slotId'),
            name: any(named: 'name'),
            beginHour: captureAny(named: 'beginHour'),
            endHour: captureAny(named: 'endHour'),
            site: any(named: 'site'),
            id: captureAny(named: 'id'),
          )).captured;
      expect(hm(captured[0] as DateTime), '08:00');
      expect(hm(captured[1] as DateTime), '08:10');
      expect(captured[2], 26);
    });

    // Un créneau vidé de ses courses réapparaîtrait sous « Items manuels »,
    // là où l'opérateur ne le cherchera jamais.
    test('supprimer la dernière course emporte son créneau', () async {
      controller.meetings.value = [oneCourseLeft()];
      when(() => meetingRepo.getMeetings(42)).thenAnswer(
          (_) async => [oneCourseLeft().copyWith(slots: const [])]);

      await controller.removeRun(26);

      verify(() => meetingRepo.deleteRun(26)).called(1);
      verify(() => meetingRepo.deleteSlot(66)).called(1);
    });

    test('un créneau qui garde des courses n est pas supprimé', () async {
      await controller.removeRun(25);

      verifyNever(() => meetingRepo.deleteSlot(any()));
    });

    test('hors session, rien ne part', () async {
      userService.currentUser.value = null;

      await controller.removeRun(25);

      verifyNever(() => meetingRepo.deleteRun(any()));
      expect(controller.message.value!.translationKey, 'login_required');
    });

    test('un refus du serveur est signalé et ne recalcule rien', () async {
      when(() => meetingRepo.deleteRun(any())).thenAnswer((_) async => false);

      await controller.removeRun(25);

      expect(controller.message.value!.translationKey, 'schedule_item_failed');
      verifyNever(() => meetingRepo.submitSlot(
            meetingId: any(named: 'meetingId'),
            name: any(named: 'name'),
            beginHour: any(named: 'beginHour'),
            endHour: any(named: 'endHour'),
            raceFormatDetailId: any(named: 'raceFormatDetailId'),
            id: any(named: 'id'),
          ));
    });

    test('une course inconnue ne déclenche aucun appel', () async {
      await controller.removeRun(999);

      verifyNever(() => meetingRepo.deleteRun(any()));
    });
  });
}
