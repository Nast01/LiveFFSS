import 'dart:async';
import 'dart:ui';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/app_host.dart';
import 'package:live_ffss_v2/core/config/app_environment.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/notifications/reminder_scheduler.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/core/storage/local_store.dart';
import 'package:live_ffss_v2/data/ffss/dtos/deroulement_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/epreuve_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/reunion_dto.dart';
import 'package:live_ffss_v2/data/ffss/mappers/deroulement_mapper.dart';
import 'package:live_ffss_v2/data/ffss/mappers/results_mapper.dart';
import 'package:live_ffss_v2/data/ffss/mappers/reunion_mapper.dart';
import 'package:live_ffss_v2/data/repositories/meeting_repository.dart';
import 'package:live_ffss_v2/data/repositories/results_repository.dart';
import 'package:live_ffss_v2/domain/account.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/domain/discipline.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/follows.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/my_space.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/run_status.dart';
import 'package:live_ffss_v2/domain/series_link.dart';
import 'package:live_ffss_v2/features/auth/session.dart';
import 'package:live_ffss_v2/features/follows/follows_providers.dart';
import 'package:live_ffss_v2/features/programme/programme_providers.dart';
import 'package:live_ffss_v2/features/reminders/reminders_formatting.dart';
import 'package:live_ffss_v2/features/reminders/reminders_providers.dart';
import 'package:live_ffss_v2/features/results/results_formatting.dart';
import 'package:live_ffss_v2/features/settings/reminder_lead.dart';
import 'package:live_ffss_v2/features/settings/server_switch.dart';
import 'package:live_ffss_v2/features/shell/current_competition.dart';
import 'package:live_ffss_v2/features/shell/space_competition.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/competitions.dart';
import '../../support/fixtures.dart';
import '../../support/in_memory_local_store.dart';

class _MockResultsRepository extends Mock implements ResultsRepository {}

class _MockMeetingRepository extends Mock implements MeetingRepository {}

class _FakeScheduler implements ReminderScheduler {
  /// Ce que l'utilisateur répondrait à la demande.
  bool granted = true;

  /// La permission déjà accordée, avant toute demande.
  bool permitted = true;
  int permissionRequests = 0;
  int cancels = 0;
  final List<List<Reminder>> replaced = [];

  /// Ce que le planificateur a fait, dans l'ordre.
  final List<String> calls = [];

  /// Retient `replaceAll` tant qu'il n'est pas complété.
  Completer<void>? replaceGate;

  @override
  Future<bool> isPermitted() async => permitted;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    permitted = granted;
    return granted;
  }

  @override
  Future<void> replaceAll(List<Reminder> reminders) async {
    calls.add('replaceAll');
    await replaceGate?.future;
    replaced.add(reminders);
    calls.add('replaced');
  }

  @override
  Future<void> cancelAll() async {
    cancels++;
    calls.add('cancelAll');
  }

  @override
  Future<void> show(Reminder reminder) async {}
}

class _FailingStore extends InMemoryLocalStore {
  @override
  Future<String?> read(String key) async =>
      throw const StorageException('illisible');
}

class _FakeSession extends SessionNotifier {
  _FakeSession(this._account);

  final Account? _account;

  @override
  Future<Account?> build() async => _account;
}

/// La compétition des onglets, que le test change.
class _Current extends Notifier<CompetitionSummary?> {
  _Current(this._initial);

  final CompetitionSummary? _initial;

  @override
  CompetitionSummary? build() => _initial;

  void set(CompetitionSummary? competition) => state = competition;
}

final _currentProvider = NotifierProvider<_Current, CompetitionSummary?>(
  () => _Current(null),
);

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

String _hhmm(DateTime time) =>
    '${time.hour.toString().padLeft(2, '0')}:'
    '${time.minute.toString().padLeft(2, '0')}';

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
  final round = heatsRoundOf(waiting, event36073);
  final start = round.first.plannedStart!;
  // Sa propre série : la seconde course du tour, plus tard que la première.
  final ownHeat = round[1];
  final ownStart = ownHeat.plannedStart!;
  // Une course hors du tour séries, comme une finale.
  final finalHeat = [
    for (final meeting in waiting.meetings)
      for (final item in meeting.items)
        for (final heat in item.heats)
          if (!round.contains(heat) &&
              heat.plannedStart != null &&
              heat.plannedStart != start &&
              heat.plannedStart != ownStart)
            heat,
  ].first;

  const followed = FollowedAthlete(
    participantId: 1,
    name: 'Un ATHLETE',
    entryIds: [5],
    eventIds: [36073],
  );

  test('le tour séries de la fixture a deux courses à heures distinctes', () {
    expect(round, hasLength(2));
    expect(ownStart, isNot(start));
  });

  group('upcomingRaces', () {
    test('une course par épreuve au tour séries non terminé', () {
      final races = upcomingRaces(
        [
          followed,
          const FollowedAthlete(
            participantId: 2,
            name: 'Deux ATHLETE',
            eventIds: [36074, 36087],
          ),
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
      expect(races.first.ownHeat, isFalse);
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
            const FollowedAthlete(
              participantId: 1,
              name: 'Un',
              eventIds: [999],
            ),
          ],
          events,
          waiting,
        ),
        isEmpty,
      );
    });

    test("l'athlète connecté, aussi suivi, ne compte qu'une fois", () {
      expect(
        upcomingRaces([followed, followed], events, waiting),
        hasLength(1),
      );
    });

    test('sa série connue : son heure à elle', () {
      final races = upcomingRaces(
        [followed],
        events,
        waiting,
        knownHeats: {(entryId: 5, eventId: 36073): ownHeat.id},
      );

      expect(races.single.start, ownStart);
      expect(races.single.ownHeat, isTrue);
    });

    test('une série inconnue du programme : repli sur le tour', () {
      final races = upcomingRaces(
        [followed],
        events,
        waiting,
        knownHeats: {(entryId: 5, eventId: 36073): 999999},
      );

      expect(races.single.start, start);
      expect(races.single.ownHeat, isFalse);
    });

    test("un autre engagement que le sien ne compte pas", () {
      final races = upcomingRaces(
        [followed],
        events,
        waiting,
        knownHeats: {(entryId: 6, eventId: 36073): ownHeat.id},
      );

      expect(races.single.start, start);
    });

    test('sa série courue : plus rien pour cette épreuve', () {
      final ran = _mapHeats(
        waiting,
        (heat) => heat.id == ownHeat.id
            ? heat.copyWith(status: RunStatus.finished)
            : heat,
      );
      expect(
        upcomingRaces(
          [followed],
          events,
          ran,
          knownHeats: {(entryId: 5, eventId: 36073): ownHeat.id},
        ),
        isEmpty,
      );
    });

    test('une finale connue est rappelée aussi', () {
      final races = upcomingRaces(
        [followed],
        events,
        waiting,
        knownHeats: {(entryId: 5, eventId: 36073): finalHeat.id},
      );

      expect(races.single.start, finalHeat.plannedStart);
      expect(races.single.ownHeat, isTrue);
    });
  });

  group('rappels', () {
    final race = (
      participantId: 1,
      name: 'Un ATHLETE',
      event: event36073,
      start: start,
      ownHeat: false,
    );

    test('id stable, propre au participant et à l’épreuve, sur 31 bits', () {
      expect(reminderId(1, 36073), reminderId(1, 36073));
      expect({
        reminderId(1, 36073),
        reminderId(1, 36074),
        reminderId(2, 36073),
      }, hasLength(3));
      // Un id de participant de l'ordre du milliard reste sur 31 bits et
      // distinct de son voisin.
      expect(reminderId(987654321, 36073), inInclusiveRange(0, 0x7fffffff));
      expect(reminderId(2147483646, 36073), inInclusiveRange(0, 0x7fffffff));
      expect(reminderId(987654321, 36073), isNot(reminderId(987654322, 36073)));
    });

    test('heure du tour : « épreuve dans », texte en français', () {
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
          title: 'Un ATHLETE : épreuve dans 15 min',
          body: '${athleteRaceTitle(event36073, fr)} · prévu à ${_hhmm(start)}',
        ),
      ]);
    });

    test('heure de sa série : « départ dans »', () {
      final reminders = remindersFor(
        [
          (
            participantId: 1,
            name: 'Un ATHLETE',
            event: event36073,
            start: start,
            ownHeat: true,
          ),
        ],
        ReminderLead.five,
        start.subtract(const Duration(hours: 1)),
        fr,
      );

      expect(reminders.single.title, 'Un ATHLETE : départ dans 5 min');
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

    test('message de permission', () {
      String? hint(
        ReminderLead? lead,
        bool? permitted, {
        bool denied = false,
      }) => reminderPermissionHint(
        lead: lead,
        permitted: permitted,
        denied: denied,
        l10n: fr,
      );
      expect(
        hint(ReminderLead.fifteen, false),
        startsWith('Notifications non autorisées'),
      );
      expect(hint(ReminderLead.fifteen, true), isNull);
      expect(hint(ReminderLead.fifteen, null), isNull);
      expect(hint(ReminderLead.off, false), isNull);
      expect(
        hint(ReminderLead.off, false, denied: true),
        startsWith('Notifications refusées'),
      );
    });

    test('libellés du délai', () {
      expect(reminderLeadLabel(ReminderLead.off, fr), 'Désactivé');
      expect(reminderLeadLabel(ReminderLead.thirty, fr), '30 min avant');
    });
  });

  group('délai et permission', () {
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
      scheduler.permitted = false;
      final container = containerWith(store);
      await container.read(reminderLeadProvider.future);

      await container
          .read(reminderLeadProvider.notifier)
          .select(ReminderLead.thirty);

      expect(scheduler.permissionRequests, 1);
      expect(container.read(reminderLeadProvider).value, ReminderLead.thirty);
      expect(store.values[ReminderLeadNotifier.storageKey], '30');
      expect(container.read(reminderPermissionDeniedProvider), isFalse);
      expect(await container.read(reminderPermissionProvider.future), isTrue);
    });

    test('permission refusée au choix : désactivé, avec un message', () async {
      scheduler
        ..permitted = false
        ..granted = false;
      final container = containerWith(store);
      await container.read(reminderLeadProvider.future);

      await container
          .read(reminderLeadProvider.notifier)
          .select(ReminderLead.thirty);

      expect(container.read(reminderLeadProvider).value, ReminderLead.off);
      expect(store.values[ReminderLeadNotifier.storageKey], '0');
      expect(container.read(reminderPermissionDeniedProvider), isTrue);
    });

    group('suivre un athlète', () {
      const participant = Participant(
        id: 1,
        firstName: 'Un',
        lastName: 'ATHLETE',
        entries: [
          ParticipantEntry(entryId: 5, eventId: 36073, categoryName: ''),
        ],
      );

      Future<ProviderContainer> follow() async {
        final container = containerWith(store);
        await toggleAthleteFollow(container, competitionId, participant);
        return container;
      }

      test('sans permission : la demande, accordée', () async {
        scheduler.permitted = false;
        final container = await follow();

        expect(scheduler.permissionRequests, 1);
        expect(
          container.read(reminderLeadProvider).value,
          ReminderLead.fifteen,
        );
        expect(
          container.read(followsProvider(competitionId)).value?.athletes,
          hasLength(1),
        );
      });

      test('refusée : rappels désactivés, avec un message', () async {
        scheduler
          ..permitted = false
          ..granted = false;
        final container = await follow();

        expect(container.read(reminderLeadProvider).value, ReminderLead.off);
        expect(container.read(reminderPermissionDeniedProvider), isTrue);
        expect(store.values[ReminderLeadNotifier.storageKey], '0');
        // Le suivi reste : seul le rappel est refusé.
        expect(
          container.read(followsProvider(competitionId)).value?.athletes,
          hasLength(1),
        );
      });

      test('déjà permise, ou rappels désactivés : rien demandé', () async {
        await follow();
        expect(scheduler.permissionRequests, 0);

        scheduler.permitted = false;
        store.values[ReminderLeadNotifier.storageKey] = '0';
        store.values.remove('follows_$competitionId');
        await follow();
        expect(scheduler.permissionRequests, 0);
      });

      test('ne plus suivre : rien demandé', () async {
        final container = await follow();
        scheduler.permitted = false;

        await toggleAthleteFollow(container, competitionId, participant);

        expect(scheduler.permissionRequests, 0);
        expect(
          container.read(followsProvider(competitionId)).value?.athletes,
          isEmpty,
        );
      });
    });
  });

  group('remindersProvider', () {
    late InMemoryLocalStore store;
    late _FakeScheduler scheduler;
    late _MockResultsRepository results;
    late _MockMeetingRepository meetings;
    late DateTime now;
    late Account? account;
    var coastal = false;

    const followsJson =
        '{"athletes":[{"participantId":1,"name":"Un ATHLETE",'
        '"entryIds":[5],"eventIds":[36073]}],"clubs":[]}';
    const selfJson =
        '{"account":"ATHLETE Deux","athlete":{"participantId":2,'
        '"name":"Deux ATHLETE","entryIds":[7],"eventIds":[36074]}}';

    setUp(() {
      store = InMemoryLocalStore()
        ..values['language'] = 'fr'
        ..values['follows_$competitionId'] = followsJson
        ..values['reminder_self_$competitionId'] = selfJson;
      scheduler = _FakeScheduler();
      results = _MockResultsRepository();
      meetings = _MockMeetingRepository();
      now = start.subtract(const Duration(hours: 2));
      account = const Account(label: 'ATHLETE Deux');
      coastal = false;
      when(() => results.getEvents(any())).thenAnswer((_) async => events);
      when(
        () => results.getParticipants(any()),
      ).thenThrow(const NetworkException('pas pour les rappels'));
      when(() => meetings.getProgramme(any())).thenAnswer((_) async => waiting);
    });

    List<Override> overrides({List<Override> extra = const []}) => [
      localStoreProvider.overrideWithValue(store),
      reminderSchedulerProvider.overrideWithValue(scheduler),
      resultsRepositoryProvider.overrideWithValue(results),
      meetingRepositoryProvider.overrideWithValue(meetings),
      clockProvider.overrideWithValue(() => now),
      sessionProvider.overrideWith(() => _FakeSession(account)),
      spaceCompetitionProvider.overrideWith(
        (ref, id) async => competition(
          id,
          start: DateTime(2026, 3, 27),
          disciplines: coastal
              ? const {Discipline.coastal}
              : const {Discipline.flatWater},
        ),
      ),
      ...extra,
    ];

    ProviderContainer build({List<Override> extra = const []}) {
      final c = ProviderContainer(
        overrides: overrides(extra: extra),
        retry: noRetry,
      );
      addTearDown(c.dispose);
      return c;
    }

    Future<List<Reminder>> plan(ProviderContainer container, [int id = 1416]) {
      container.listen(remindersProvider(id), (_, _) {});
      return container.read(remindersProvider(id).future);
    }

    test('planifie les suivis et l’athlète connecté, sans lire les '
        'participants', () async {
      final container = build();

      final reminders = await plan(container);

      expect(scheduler.replaced, [reminders]);
      expect(
        {for (final r in reminders) r.id},
        {reminderId(1, 36073), reminderId(2, 36074)},
      );
      expect(
        reminders.firstWhere((r) => r.id == reminderId(1, 36073)),
        Reminder(
          id: reminderId(1, 36073),
          at: start.subtract(const Duration(minutes: 15)),
          title: 'Un ATHLETE : épreuve dans 15 min',
          body: '${athleteRaceTitle(event36073, fr)} · prévu à ${_hhmm(start)}',
        ),
      );
      verifyNever(() => results.getParticipants(any()));
      // Rien n'est demandé hors d'un geste de l'utilisateur.
      expect(scheduler.permissionRequests, 0);
    });

    test('spectateur sans suivi : rien de lu', () async {
      store.values.remove('follows_$competitionId');
      store.values.remove('reminder_self_$competitionId');
      account = null;
      final container = build();

      expect(await plan(container), isEmpty);
      expect(scheduler.cancels, 1);
      verifyNever(() => results.getEvents(any()));
      verifyNever(() => results.getParticipants(any()));
      verifyNever(() => meetings.getProgramme(any()));
    });

    test("l'athlète enregistré d'un autre compte : écarté et effacé", () async {
      account = const Account(label: 'MARTIN Paul');
      final container = build();

      final reminders = await plan(container);

      expect({for (final r in reminders) r.id}, {reminderId(1, 36073)});
      expect(store.values.containsKey('reminder_self_$competitionId'), isFalse);
    });

    test('sa série connue : son heure, « départ dans »', () async {
      store.values['known_heats_$competitionId'] =
          '[{"entryId":5,"eventId":36073,"heatId":${ownHeat.id}}]';
      final container = build();

      final reminders = await plan(container);
      final mine = reminders.firstWhere((r) => r.id == reminderId(1, 36073));

      expect(mine.at, ownStart.subtract(const Duration(minutes: 15)));
      expect(mine.title, 'Un ATHLETE : départ dans 15 min');
    });

    test('sa série relue à une autre heure : le rappel suit', () {
      fakeAsync((async) {
        store.values['known_heats_$competitionId'] =
            '[{"entryId":5,"eventId":36073,"heatId":${ownHeat.id}}]';
        final container = build();
        container.listen(remindersProvider(competitionId), (_, _) {});
        container.listen(programmeProvider(competitionId), (_, _) {});
        async.flushMicrotasks();
        expect(scheduler.replaced, hasLength(1));

        final moved = _mapHeats(
          waiting,
          (heat) => heat.id == ownHeat.id
              ? heat.copyWith(
                  plannedStart: ownStart.add(const Duration(minutes: 20)),
                )
              : heat,
        );
        when(() => meetings.getProgramme(any())).thenAnswer((_) async => moved);
        async.elapse(programmeRefresh);
        async.flushMicrotasks();

        expect(scheduler.replaced, hasLength(2));
        expect(
          scheduler.replaced.last
              .firstWhere((r) => r.id == reminderId(1, 36073))
              .at,
          ownStart.add(const Duration(minutes: 5)),
        );
        container.dispose();
      });
    });

    test('rappel déjà passé : rien de planifié', () async {
      now = start.subtract(const Duration(minutes: 10));
      final container = build();

      expect(await plan(container), isEmpty);
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

    test('désactivé : cancelAll, rien de lu ni de planifié', () async {
      store.values[ReminderLeadNotifier.storageKey] = '0';
      final container = build();

      expect(await plan(container), isEmpty);
      expect(scheduler.cancels, 1);
      expect(scheduler.replaced, isEmpty);
      verifyNever(() => results.getEvents(any()));
    });

    test('désactiver après planification : cancelAll', () async {
      final container = build();
      await plan(container);
      expect(scheduler.replaced, hasLength(1));

      await container
          .read(reminderLeadProvider.notifier)
          .select(ReminderLead.off);
      await container.read(remindersProvider(competitionId).future);

      expect(scheduler.cancels, 1);
      expect(scheduler.replaced, hasLength(1));
    });

    test('sans permission : rien de planifié ni demandé, le réglage reste ; '
        'accordée sur un geste, planifié', () async {
      scheduler.permitted = false;
      final container = build();

      expect(await plan(container), isEmpty);
      expect(scheduler.replaced, isEmpty);
      expect(scheduler.permissionRequests, 0);
      expect(container.read(reminderLeadProvider).value, ReminderLead.fifteen);
      expect(container.read(reminderPermissionDeniedProvider), isFalse);
      expect(
        store.values.containsKey(ReminderLeadNotifier.storageKey),
        isFalse,
      );

      await container
          .read(reminderLeadProvider.notifier)
          .select(ReminderLead.fifteen);
      await container.read(remindersProvider(competitionId).future);

      expect(scheduler.replaced, hasLength(1));
    });

    test('compétition côtière : rien de lu ni de planifié', () async {
      coastal = true;
      final container = build();

      expect(await plan(container), isEmpty);
      expect(scheduler.replaced, isEmpty);
      verifyNever(() => results.getEvents(any()));
    });

    test('une lecture en échec ne touche pas aux rappels', () async {
      when(
        () => results.getEvents(any()),
      ).thenThrow(const NetworkException('hors ligne'));
      final container = build();

      expect(await plan(container), isEmpty);
      expect(scheduler.replaced, isEmpty);
      expect(scheduler.cancels, 0);
    });

    test('changer de compétition remplace les rappels de l’autre', () async {
      final other = competition(1500, start: DateTime(2026, 3, 27));
      final container = build(
        extra: [
          remindersSupportedProvider.overrideWithValue(true),
          currentCompetitionProvider.overrideWith(
            (ref) => ref.watch(_currentProvider),
          ),
        ],
      );
      container
          .read(_currentProvider.notifier)
          .set(competition(competitionId, start: DateTime(2026, 3, 27)));
      container.listen(activeRemindersProvider, (_, _) {});
      await container.read(remindersProvider(competitionId).future);
      expect(scheduler.replaced, hasLength(1));

      // Rien de suivi sur l'autre : ses rappels (aucun) remplacent ceux-ci.
      container.read(_currentProvider.notifier).set(other);
      container.read(activeRemindersProvider);
      await container.read(remindersProvider(other.id).future);

      expect(scheduler.cancels, 1);
    });

    test('changement de serveur : annulés, puis replanifiés par la nouvelle '
        'app', () async {
      final host = AppContainerHost(
        environment: AppEnvironment.development,
        overrides: overrides(
          extra: [globalStoreProvider.overrideWithValue(GlobalStore(store))],
        ),
      );
      addTearDown(host.dispose);
      await plan(host.container);
      expect(scheduler.replaced, hasLength(1));

      await switchServer(host.container, AppEnvironment.production);
      expect(scheduler.cancels, 1);
      await plan(host.container);

      // Même compétition, mêmes suivis : la nouvelle app les replanifie.
      expect(scheduler.replaced, hasLength(2));
    });

    test("changement de serveur : une planification de l'ancienne app encore "
        "en cours finit avant l'annulation, et aucune ne part après", () async {
      final host = AppContainerHost(
        environment: AppEnvironment.development,
        overrides: overrides(
          extra: [globalStoreProvider.overrideWithValue(GlobalStore(store))],
        ),
      );
      addTearDown(host.dispose);
      scheduler.replaceGate = Completer<void>();
      host.container.listen(remindersProvider(1416), (_, _) {});
      await pumpEventQueue();
      // Une ou plusieurs, selon les relectures du lancement : toutes en vol.
      expect(scheduler.calls.toSet(), {'replaceAll'});

      final switching = switchServer(host.container, AppEnvironment.production);
      await pumpEventQueue();
      scheduler.replaceGate!.complete();
      scheduler.replaceGate = null;
      expect(await switching, isTrue);
      await pumpEventQueue();

      final cancelled = scheduler.calls.indexOf('cancelAll');
      expect(cancelled, greaterThan(scheduler.calls.lastIndexOf('replaced')));
      expect(scheduler.calls.sublist(cancelled), ['cancelAll']);
    });
  });
}
