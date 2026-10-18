import 'dart:ui';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/config/app_environment.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/notifications/reminder_scheduler.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/ffss/dtos/deroulement_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/epreuve_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/reunion_dto.dart';
import 'package:live_ffss_v2/data/ffss/mappers/deroulement_mapper.dart';
import 'package:live_ffss_v2/data/ffss/mappers/results_mapper.dart';
import 'package:live_ffss_v2/data/ffss/mappers/reunion_mapper.dart';
import 'package:live_ffss_v2/data/repositories/meeting_repository.dart';
import 'package:live_ffss_v2/data/repositories/results_repository.dart';
import 'package:live_ffss_v2/domain/discipline.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/my_space.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/run_status.dart';
import 'package:live_ffss_v2/domain/series_link.dart';
import 'package:live_ffss_v2/features/my_space/my_space_providers.dart';
import 'package:live_ffss_v2/features/programme/programme_providers.dart';
import 'package:live_ffss_v2/features/reminders/reminders_formatting.dart';
import 'package:live_ffss_v2/features/reminders/reminders_providers.dart';
import 'package:live_ffss_v2/features/results/results_formatting.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/competitions.dart';
import '../../support/fixtures.dart';
import '../../support/in_memory_local_store.dart';

class _MockResultsRepository extends Mock implements ResultsRepository {}

class _MockMeetingRepository extends Mock implements MeetingRepository {}

class _FakeScheduler implements ReminderScheduler {
  bool granted = true;
  int permissionRequests = 0;
  int cancels = 0;
  final List<List<Reminder>> replaced = [];

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return granted;
  }

  @override
  Future<void> replaceAll(List<Reminder> reminders) async =>
      replaced.add(reminders);

  @override
  Future<void> cancelAll() async => cancels++;
}

class _FailingStore extends InMemoryLocalStore {
  @override
  Future<String?> read(String key) async =>
      throw const StorageException('illisible');
}

List<Map<String, dynamic>> _rows(String name) =>
    (fixture(name)['data'] as List<dynamic>).cast<Map<String, dynamic>>();

Programme _fixtureProgramme() {
  final progressions = [
    for (final row in _rows('deroulement'))
      ?DeroulementDto.fromJson(row).toDomain(),
  ];
  final meetings = [
    for (final row in _rows('reunion')) ?ReunionDto.fromJson(row).toDomain(),
  ];
  return Programme(
    meetings: withRaces(meetings, progressions),
    progressions: progressions,
  );
}

/// Le programme où chaque course prend ce que [change] en fait.
Programme _mapHeats(Programme programme, Heat Function(Heat heat) change) =>
    programme.copyWith(
      meetings: [
        for (final meeting in programme.meetings)
          meeting.copyWith(
            items: [
              for (final item in meeting.items)
                item.copyWith(
                  heats: [for (final heat in item.heats) change(heat)],
                ),
            ],
          ),
      ],
    );

void main() {
  const competitionId = 1416;
  final fr = lookupAppLocalizations(const Locale('fr'));
  final events = [
    for (final row in _rows('epreuves_1416'))
      ?EpreuveDto.fromJson(row).toDomain(),
  ];
  final waiting = _mapHeats(
    _fixtureProgramme(),
    (heat) => heat.copyWith(status: RunStatus.waiting),
  );
  final event36073 = events.firstWhere((e) => e.id == 36073);
  final start = heatsRoundOf(waiting, event36073).first.plannedStart!;
  const connected = Participant(
    id: 2,
    firstName: 'Deux',
    lastName: 'ATHLETE',
    entries: [ParticipantEntry(entryId: 7, eventId: 36074, categoryName: '')],
  );

  group('upcomingRaces', () {
    const followed = (participantId: 1, name: 'Un ATHLETE', eventIds: [36073]);

    test('une course par épreuve au tour séries non terminé', () {
      final races = upcomingRaces(
        [
          followed,
          (participantId: 2, name: 'Deux ATHLETE', eventIds: [36074, 36087]),
        ],
        events,
        waiting,
      );

      // 36087 n'a pas de tour séries au programme.
      expect(
        [for (final r in races) (r.participantId, r.event.id)],
        [(1, 36073), (2, 36074)],
      );
      expect(races.first.start, start);
      expect(races.first.name, 'Un ATHLETE');
    });

    test('tour séries terminé, épreuve inconnue : rien', () {
      final done = _mapHeats(
        waiting,
        (heat) => heat.copyWith(status: RunStatus.finished),
      );
      expect(upcomingRaces([followed], events, done), isEmpty);
      expect(
        upcomingRaces(
          [
            (participantId: 1, name: 'Un', eventIds: const [999]),
          ],
          events,
          waiting,
        ),
        isEmpty,
      );
    });

    test("l'athlète connecté, aussi suivi, ne compte qu'une fois", () {
      final races = upcomingRaces(
        [
          followed,
          (participantId: 1, name: 'Un ATHLETE', eventIds: const [36073]),
        ],
        events,
        waiting,
      );
      expect(races, hasLength(1));
    });
  });

  group('rappels', () {
    final race = (
      participantId: 1,
      name: 'Un ATHLETE',
      event: event36073,
      start: start,
    );

    test('id stable, propre au participant et à l’épreuve, sur 31 bits', () {
      expect(reminderId(1, 36073), reminderId(1, 36073));
      expect({
        reminderId(1, 36073),
        reminderId(1, 36074),
        reminderId(2, 36073),
      }, hasLength(3));
      expect(reminderId(987654321, 36073), inInclusiveRange(0, 0x7fffffff));
    });

    test('à l’heure du départ moins le délai, texte en français', () {
      final reminders = remindersFor(
        [race],
        ReminderLead.fifteen,
        start.subtract(const Duration(hours: 1)),
        fr,
      );

      expect(reminders, [
        Reminder(
          id: reminderId(1, 36073),
          at: start.subtract(const Duration(minutes: 15)),
          title: 'Un ATHLETE : départ dans 15 min',
          body:
              '${athleteRaceTitle(event36073, fr)} · prévu à '
              '${start.hour.toString().padLeft(2, '0')}:'
              '${start.minute.toString().padLeft(2, '0')}',
        ),
      ]);
    });

    test('rappel passé ou désactivé : aucun', () {
      final now = start.subtract(const Duration(minutes: 10));
      expect(remindersFor([race], ReminderLead.fifteen, now, fr), isEmpty);
      expect(remindersFor([race], ReminderLead.five, now, fr), hasLength(1));
      expect(
        remindersFor([race], ReminderLead.off, DateTime(2000), fr),
        isEmpty,
      );
    });

    test('libellés du délai', () {
      expect(reminderLeadLabel(ReminderLead.off, fr), 'Désactivé');
      expect(reminderLeadLabel(ReminderLead.thirty, fr), '30 min avant');
    });
  });

  group('reminderLeadProvider', () {
    late InMemoryLocalStore store;
    late _FakeScheduler scheduler;

    ProviderContainer containerWith(InMemoryLocalStore local) {
      final c = ProviderContainer(
        overrides: [
          localStoreProvider.overrideWithValue(local),
          reminderSchedulerProvider.overrideWithValue(scheduler),
        ],
        retry: noRetry,
      );
      addTearDown(c.dispose);
      return c;
    }

    setUp(() {
      store = InMemoryLocalStore();
      scheduler = _FakeScheduler();
    });

    test('15 min par défaut, valeur enregistrée relue', () async {
      expect(
        await containerWith(store).read(reminderLeadProvider.future),
        ReminderLead.fifteen,
      );
      store.values[ReminderLeadNotifier.storageKey] = '5';
      expect(
        await containerWith(store).read(reminderLeadProvider.future),
        ReminderLead.five,
      );
      expect(
        await containerWith(_FailingStore()).read(reminderLeadProvider.future),
        ReminderLead.fifteen,
      );
    });

    test('clé globale', () {
      expect(
        AppEnvironment.globalKeys,
        contains(ReminderLeadNotifier.storageKey),
      );
    });

    test('désactiver ne demande rien et s’enregistre', () async {
      final container = containerWith(store);
      await container.read(reminderLeadProvider.future);

      await container
          .read(reminderLeadProvider.notifier)
          .select(ReminderLead.off);

      expect(container.read(reminderLeadProvider).value, ReminderLead.off);
      expect(store.values[ReminderLeadNotifier.storageKey], '0');
      expect(scheduler.permissionRequests, 0);
    });

    test('activer demande la permission', () async {
      final container = containerWith(store);
      await container.read(reminderLeadProvider.future);

      await container
          .read(reminderLeadProvider.notifier)
          .select(ReminderLead.thirty);

      expect(scheduler.permissionRequests, 1);
      expect(container.read(reminderLeadProvider).value, ReminderLead.thirty);
      expect(store.values[ReminderLeadNotifier.storageKey], '30');
      expect(container.read(reminderPermissionDeniedProvider), isFalse);
    });

    test('permission refusée : désactivé, avec un message', () async {
      scheduler.granted = false;
      final container = containerWith(store);
      await container.read(reminderLeadProvider.future);

      await container
          .read(reminderLeadProvider.notifier)
          .select(ReminderLead.thirty);

      expect(container.read(reminderLeadProvider).value, ReminderLead.off);
      expect(store.values[ReminderLeadNotifier.storageKey], '0');
      expect(container.read(reminderPermissionDeniedProvider), isTrue);
    });
  });

  group('remindersProvider', () {
    late InMemoryLocalStore store;
    late _FakeScheduler scheduler;
    late _MockResultsRepository results;
    late _MockMeetingRepository meetings;
    late DateTime now;
    var coastal = false;

    setUp(() {
      store = InMemoryLocalStore()
        ..values['language'] = 'fr'
        ..values['follows_$competitionId'] =
            '{"athletes":[{"participantId":1,"name":"Un ATHLETE",'
            '"entryIds":[5],"eventIds":[36073]}],"clubs":[]}';
      scheduler = _FakeScheduler();
      results = _MockResultsRepository();
      meetings = _MockMeetingRepository();
      now = start.subtract(const Duration(hours: 2));
      coastal = false;
      when(() => results.getEvents(any())).thenAnswer((_) async => events);
      when(() => meetings.getProgramme(any())).thenAnswer((_) async => waiting);
    });

    ProviderContainer build() {
      final c = ProviderContainer(
        overrides: [
          localStoreProvider.overrideWithValue(store),
          reminderSchedulerProvider.overrideWithValue(scheduler),
          resultsRepositoryProvider.overrideWithValue(results),
          meetingRepositoryProvider.overrideWithValue(meetings),
          clockProvider.overrideWithValue(() => now),
          spaceCompetitionProvider.overrideWith(
            (ref, id) async => competition(
              id,
              start: DateTime(2026, 3, 27),
              disciplines: coastal
                  ? const {Discipline.coastal}
                  : const {Discipline.flatWater},
            ),
          ),
          mySpaceCardsProvider.overrideWith(
            (ref, id) async =>
                const MySpaceCards(cards: [MySpaceCard.athlete(connected)]),
          ),
        ],
        retry: noRetry,
      );
      addTearDown(c.dispose);
      return c;
    }

    final expected = [
      Reminder(
        id: reminderId(1, 36073),
        at: start.subtract(const Duration(minutes: 15)),
        title: 'Un ATHLETE : départ dans 15 min',
        body:
            '${athleteRaceTitle(event36073, fr)} · prévu à '
            '${start.hour.toString().padLeft(2, '0')}:'
            '${start.minute.toString().padLeft(2, '0')}',
      ),
    ];

    test('planifie les athlètes suivis et l’athlète connecté', () async {
      final container = build();
      container.listen(remindersProvider(competitionId), (_, _) {});

      final reminders = await container.read(
        remindersProvider(competitionId).future,
      );

      expect(scheduler.replaced, hasLength(1));
      expect(reminders, scheduler.replaced.single);
      expect(
        {for (final r in reminders) r.id},
        {reminderId(1, 36073), reminderId(2, 36074)},
      );
      expect(
        reminders.firstWhere((r) => r.id == reminderId(1, 36073)),
        expected.single,
      );
      expect(
        reminders.firstWhere((r) => r.id == reminderId(2, 36074)).title,
        'Deux ATHLETE : départ dans 15 min',
      );
    });

    test('rappel déjà passé : rien de planifié', () async {
      now = start.subtract(const Duration(minutes: 10));
      final container = build();
      container.listen(remindersProvider(competitionId), (_, _) {});

      expect(
        await container.read(remindersProvider(competitionId).future),
        isEmpty,
      );
      expect(scheduler.replaced, isEmpty);
    });

    test('relecture identique du programme : pas de nouvel appel', () {
      fakeAsync((async) {
        final container = build();
        container.listen(remindersProvider(competitionId), (_, _) {});
        // Le programme est ouvert ailleurs (onglet Programme) : il se relit.
        container.listen(programmeProvider(competitionId), (_, _) {});
        async.flushMicrotasks();
        expect(scheduler.replaced, hasLength(1));

        async.elapse(programmeRefresh);
        async.flushMicrotasks();
        verify(
          () => meetings.getProgramme(competitionId),
        ).called(greaterThan(1));
        expect(scheduler.replaced, hasLength(1));
        container.dispose();
      });
    });

    test('course déplacée : replanifiée', () {
      fakeAsync((async) {
        final container = build();
        container.listen(remindersProvider(competitionId), (_, _) {});
        container.listen(programmeProvider(competitionId), (_, _) {});
        async.flushMicrotasks();
        expect(scheduler.replaced, hasLength(1));

        final moved = _mapHeats(
          waiting,
          (heat) => heat.copyWith(
            plannedStart: heat.plannedStart?.add(const Duration(minutes: 30)),
          ),
        );
        when(() => meetings.getProgramme(any())).thenAnswer((_) async => moved);
        async.elapse(programmeRefresh);
        async.flushMicrotasks();

        expect(scheduler.replaced, hasLength(2));
        expect(
          scheduler.replaced.last.first.at,
          start.add(const Duration(minutes: 15)),
        );
        container.dispose();
      });
    });

    test('le programme ne se relit pas pour les rappels seuls ; un écran qui '
        "l'ouvre ensuite les replanifie", () {
      fakeAsync((async) {
        final container = build();
        container.listen(remindersProvider(competitionId), (_, _) {});
        async.flushMicrotasks();
        expect(scheduler.replaced, hasLength(1));

        async.elapse(programmeRefresh * 3);
        async.flushMicrotasks();
        verify(() => meetings.getProgramme(competitionId)).called(1);

        final moved = _mapHeats(
          waiting,
          (heat) => heat.copyWith(
            plannedStart: heat.plannedStart?.add(const Duration(minutes: 30)),
          ),
        );
        when(() => meetings.getProgramme(any())).thenAnswer((_) async => moved);
        container.listen(programmeProvider(competitionId), (_, _) {});
        // Riverpod reconstruit les rappels sur une minuterie nulle.
        async.elapse(Duration.zero);

        expect(scheduler.replaced, hasLength(2));
        container.dispose();
      });
    });

    test('désactivé : cancelAll, rien de planifié', () async {
      store.values[ReminderLeadNotifier.storageKey] = '0';
      final container = build();
      container.listen(remindersProvider(competitionId), (_, _) {});

      expect(
        await container.read(remindersProvider(competitionId).future),
        isEmpty,
      );
      expect(scheduler.cancels, 1);
      expect(scheduler.replaced, isEmpty);
      verifyNever(() => results.getEvents(any()));
    });

    test('désactiver après planification : cancelAll', () async {
      final container = build();
      container.listen(remindersProvider(competitionId), (_, _) {});
      await container.read(remindersProvider(competitionId).future);
      expect(scheduler.replaced, hasLength(1));

      await container
          .read(reminderLeadProvider.notifier)
          .select(ReminderLead.off);
      await container.read(remindersProvider(competitionId).future);

      expect(scheduler.cancels, 1);
      expect(scheduler.replaced, hasLength(1));
    });

    test('permission refusée : rien de planifié, rappels désactivés', () async {
      scheduler.granted = false;
      final container = build();
      container.listen(remindersProvider(competitionId), (_, _) {});

      await container.read(remindersProvider(competitionId).future);
      await container.read(remindersProvider(competitionId).future);

      expect(scheduler.replaced, isEmpty);
      expect(container.read(reminderLeadProvider).value, ReminderLead.off);
      expect(container.read(reminderPermissionDeniedProvider), isTrue);
      expect(store.values[ReminderLeadNotifier.storageKey], '0');
    });

    test('compétition côtière : rien de lu ni de planifié', () async {
      coastal = true;
      final container = build();
      container.listen(remindersProvider(competitionId), (_, _) {});

      expect(
        await container.read(remindersProvider(competitionId).future),
        isEmpty,
      );
      expect(scheduler.replaced, isEmpty);
      verifyNever(() => results.getEvents(any()));
    });

    test('une lecture en échec ne touche pas aux rappels', () async {
      when(
        () => results.getEvents(any()),
      ).thenThrow(const NetworkException('hors ligne'));
      final container = build();
      container.listen(remindersProvider(competitionId), (_, _) {});

      expect(
        await container.read(remindersProvider(competitionId).future),
        isEmpty,
      );
      expect(scheduler.replaced, isEmpty);
      expect(scheduler.cancels, 0);
    });
  });
}
