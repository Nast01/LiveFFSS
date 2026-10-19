import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/ffss/dtos/deroulement_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/epreuve_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/reunion_dto.dart';
import 'package:live_ffss_v2/data/ffss/mappers/deroulement_mapper.dart';
import 'package:live_ffss_v2/data/ffss/mappers/results_mapper.dart';
import 'package:live_ffss_v2/data/ffss/mappers/reunion_mapper.dart';
import 'package:live_ffss_v2/data/repositories/engagement_repository.dart';
import 'package:live_ffss_v2/data/repositories/meeting_repository.dart';
import 'package:live_ffss_v2/data/repositories/results_repository.dart';
import 'package:live_ffss_v2/domain/account.dart';
import 'package:live_ffss_v2/domain/competition_roles.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/domain/discipline.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/lane_assignment.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/run_status.dart';
import 'package:live_ffss_v2/features/auth/competition_roles.dart';
import 'package:live_ffss_v2/features/auth/session.dart';
import 'package:live_ffss_v2/features/my_space/club_forfeits_providers.dart';
import 'package:live_ffss_v2/features/shell/space_competition.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/fixtures.dart';

class _MockResultsRepository extends Mock implements ResultsRepository {}

class _MockMeetingRepository extends Mock implements MeetingRepository {}

class _MockEngagementRepository extends Mock implements EngagementRepository {}

class _FakeSession extends SessionNotifier {
  _FakeSession(this._account);

  final Account? _account;

  @override
  Future<Account?> build() async => _account;
}

List<Map<String, dynamic>> _rows(String name) =>
    (fixture(name)['data'] as List<dynamic>).cast<Map<String, dynamic>>();

/// Le programme de la fixture, ses courses remises à courir : celles du
/// tour séries de 36073, 36074 et 36075 sont 479 (8 h 00, places 2816 à
/// 2821) et 480 (8 h 04, places 2822 à 2829).
Programme _waitingProgramme() {
  final progressions = [
    for (final row in _rows('deroulement'))
      ?DeroulementDto.fromJson(row).toDomain(),
  ];
  final meetings = [
    for (final row in _rows('reunion')) ?ReunionDto.fromJson(row).toDomain(),
  ];
  return _mapHeats(
    Programme(
      meetings: withRaces(meetings, progressions),
      progressions: progressions,
    ),
    (heat) => heat.copyWith(status: RunStatus.waiting),
  );
}

Programme _mapHeats(Programme programme, Heat Function(Heat heat) change) =>
    programme.copyWith(
      meetings: [
        for (final meeting in programme.meetings)
          meeting.copyWith(
            items: [
              for (final item in meeting.items)
                item.copyWith(heats: [for (final h in item.heats) change(h)]),
            ],
          ),
      ],
    );

Participant _athlete(int id, String last, List<(int, int)> entries) =>
    Participant(
      id: id,
      firstName: 'Prénom',
      lastName: last,
      club: 'CLUB Test',
      clubId: 99,
      entries: [
        for (final (entryId, eventId) in entries)
          ParticipantEntry(
            entryId: entryId,
            eventId: eventId,
            categoryName: 'Cadet',
          ),
      ],
    );

LaneAssignment _lane(
  int placeId,
  int lane,
  int entryId, {
  bool forfeit = false,
}) => LaneAssignment(
  id: placeId,
  lane: lane,
  athletes: const ['ATHLETE Un'],
  entryId: entryId,
  forfeit: forfeit,
);

void main() {
  const competitionId = 1416;
  const clubId = 99;
  const key = (competitionId: competitionId, clubId: clubId);
  final waiting = _waitingProgramme();
  final events = [
    for (final row in _rows('epreuves_1416'))
      ?EpreuveDto.fromJson(row).toDomain(),
  ];
  const roundEvents = {36073, 36074, 36075};
  // Une épreuve eau plate dont aucun tour séries n'est au programme.
  final noRound = events.firstWhere((e) => !roundEvents.contains(e.id));

  // UN court 36073 (engagement 101) ; DEUX court 36074 (102) et, avec
  // TROIS, l'engagement 200 de 36075 : un seul engagement, une seule ligne.
  // QUATRE n'est pas du club ; l'épreuve 1 n'est pas une épreuve eau plate.
  final participants = [
    _athlete(1, 'UN', [(101, 36073), (900, 1)]),
    _athlete(2, 'DEUX', [(102, 36074), (200, 36075)]),
    _athlete(3, 'TROIS', [(200, 36075)]),
    _athlete(4, 'QUATRE', [(300, 36073)]).copyWith(clubId: 7),
  ];
  const referee = CompetitionRoles(
    roles: ['referent_sportif'],
    refereeClubs: [ClubRef(id: clubId, label: 'CLUB Test')],
  );

  late Programme programme;
  late _MockResultsRepository results;
  late _MockMeetingRepository meetings;
  late _MockEngagementRepository engagements;
  late Map<int, LaneAssignment?> lanes;
  late Set<int> failing;
  late List<int> reads;
  late int peak;
  late Future<CompetitionRoles> Function() rolesRead;
  // Le programme que relit `getMeetingItem` : celui de la lecture, sauf
  // si le test fait partir une course entre-temps.
  Programme? slots;
  late List<int> itemReads;
  var disciplines = {Discipline.flatWater};
  var now = DateTime(2026, 3, 27, 7);
  Account? account = const Account(label: 'REFERENT Club');

  setUpAll(() {
    registerFallbackValue(<int>[]);
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    programme = waiting;
    disciplines = {Discipline.flatWater};
    now = DateTime(2026, 3, 27, 7);
    rolesRead = () async => referee;
    account = const Account(label: 'REFERENT Club');
    results = _MockResultsRepository();
    meetings = _MockMeetingRepository();
    engagements = _MockEngagementRepository();
    lanes = {
      for (var i = 2816; i <= 2829; i++) i: null,
      2817: _lane(2817, 2, 101),
      2823: _lane(2823, 2, 102, forfeit: true),
      2825: _lane(2825, 4, 200),
    };
    failing = {};
    reads = [];
    slots = null;
    itemReads = [];
    peak = 0;
    var inFlight = 0;
    when(() => meetings.getProgramme(any())).thenAnswer((_) async => programme);
    when(() => results.getEvents(any())).thenAnswer((_) async => events);
    when(
      () => results.getParticipants(any()),
    ).thenAnswer((_) async => participants);
    when(() => meetings.getLanes(any())).thenAnswer((invocation) async {
      final ids = (invocation.positionalArguments.first as Iterable<int>)
          .toList();
      reads.addAll(ids);
      inFlight += ids.length;
      if (inFlight > peak) peak = inFlight;
      await Future<void>.delayed(const Duration(milliseconds: 5));
      inFlight -= ids.length;
      return {
        for (final id in ids)
          if (!failing.contains(id) && lanes.containsKey(id)) id: lanes[id],
      };
    });
    when(
      () => engagements.setForfeit(any(), forfeit: any(named: 'forfeit')),
    ).thenAnswer((_) async {});
    when(
      () => meetings.getMeetingItem(any(), day: any(named: 'day')),
    ).thenAnswer((invocation) async {
      final id = invocation.positionalArguments.first as int;
      itemReads.add(id);
      return [
        for (final meeting in (slots ?? programme).meetings)
          for (final item in meeting.items)
            if (item.id == id) item,
      ].firstOrNull;
    });
  });

  ProviderContainer container() {
    final c = ProviderContainer(
      overrides: [
        resultsRepositoryProvider.overrideWithValue(results),
        meetingRepositoryProvider.overrideWithValue(meetings),
        engagementRepositoryProvider.overrideWithValue(engagements),
        spaceCompetitionProvider.overrideWith(
          (ref, id) async => CompetitionSummary(
            id: id,
            name: 'Championnat',
            startDate: DateTime(2026, 3, 27),
            endDate: DateTime(2026, 3, 29),
            disciplines: disciplines,
          ),
        ),
        competitionRolesProvider.overrideWith((ref, id) => rolesRead()),
        sessionProvider.overrideWith(() => _FakeSession(account)),
        clockProvider.overrideWithValue(() => now),
      ],
      retry: noRetry,
    );
    addTearDown(c.dispose);
    return c;
  }

  Future<List<ClubForfeit>> read(ProviderContainer c) async {
    final sub = c.listen(clubForfeitsProvider(key), (_, _) {});
    addTearDown(sub.close);
    // Les droits sont lus d'avance, comme la page qui les suit ; en cours
    // ou en échec, c'est ce que le test veut.
    final roles = c.read(competitionRolesProvider(competitionId).future);
    await Future.any([roles, pumpEventQueue()]).catchError((Object _) {});
    await c.read(sessionProvider.future);
    return c.read(clubForfeitsProvider(key).future);
  }

  ClubForfeit of(List<ClubForfeit> list, int entryId) =>
      list.singleWhere((f) => f.entryId == entryId);

  List<ClubForfeit> current(ProviderContainer c) =>
      c.read(clubForfeitsProvider(key)).value!;

  ClubForfeitsNotifier notifier(ProviderContainer c) =>
      c.read(clubForfeitsProvider(key).notifier);

  void verifyNoSend() => verifyNever(
    () => engagements.setForfeit(any(), forfeit: any(named: 'forfeit')),
  );

  void holdSends(Completer<void> sent) => when(
    () => engagements.setForfeit(any(), forfeit: any(named: 'forfeit')),
  ).thenAnswer((_) => sent.future);

  Programme with479(Heat Function(Heat heat) change) =>
      _mapHeats(waiting, (h) => h.id == 479 ? change(h) : h);

  group('lecture', () {
    test('un engagement par ligne, un relais une fois avec ses relayeurs, '
        'sa série, son couloir et son état', () async {
      final list = await read(container());

      expect(list.map((f) => f.entryId), unorderedEquals([101, 102, 200]));
      final relay = of(list, 200);
      expect(relay.athletes, ['Prénom DEUX', 'Prénom TROIS']);
      expect(relay.heat?.id, 480);
      expect(relay.lane, 4);
      expect(relay.forfeit, isFalse);

      final un = of(list, 101);
      expect(un.athletes, ['Prénom UN']);
      expect(un.heat?.id, 479);
      expect(un.lane, 2);
      expect(un.forfeit, isFalse);
      expect(un.locked, isFalse);
      expect(un.deadline, DateTime(2026, 3, 27, 7, 50));
      expect(un.sending, ForfeitSending.idle);

      expect(of(list, 102).forfeit, isTrue);
      expect(of(list, 102).deadline, DateTime(2026, 3, 27, 7, 54));
    });

    test("6 places au plus en vol, et la lecture s'arrête quand chaque "
        'engagement est trouvé', () async {
      lanes = {
        for (var i = 2816; i <= 2829; i++) i: null,
        2816: _lane(2816, 1, 101),
        2817: _lane(2817, 2, 102),
        2818: _lane(2818, 3, 200),
      };

      final list = await read(container());

      expect(peak, lessThanOrEqualTo(6));
      expect(reads.toSet().length, reads.length);
      expect(reads, isNot(contains(2829)));
      expect(list.every((f) => f.heat?.id == 479), isTrue);
    });

    test('place illisible : état inconnu, jamais « pas forfait »', () async {
      failing = {2823};

      final list = await read(container());

      final deux = of(list, 102);
      expect(deux.forfeit, isNull);
      expect(deux.heat, isNull);
      expect(deux.placesUnread, isTrue);
      expect(of(list, 101).forfeit, isFalse);
      // Tout est lu faute de trouver 102 : le plafond est atteint.
      expect(peak, 6);
    });

    test('absent de toutes les places lues : pas encore placé, état '
        'inconnu, échéance de la plus tôt des courses à courir', () async {
      lanes[2817] = null;
      // 479 sans heure : l'échéance vient de 480.
      programme = with479((h) => h.copyWith(plannedStart: null));

      final un = of(await read(container()), 101);

      expect(un.heat, isNull);
      expect(un.lane, isNull);
      expect(un.forfeit, isNull);
      expect(un.placesUnread, isFalse);
      expect(un.locked, isFalse);
      expect(un.deadline, DateTime(2026, 3, 27, 7, 54));
    });

    test("trouvé dans une course courue du tour : verrouillé à toute heure, "
        "rien n'est envoyé", () async {
      programme = with479((h) => h.copyWith(status: RunStatus.finished));
      final c = container();

      final un = of(await read(c), 101);

      expect(un.heat?.id, 479);
      expect(un.locked, isTrue);
      // Les places des courses à courir passent d'abord.
      expect(reads.indexOf(2822), lessThan(reads.indexOf(2817)));
      expect(
        await notifier(c).setForfeit(101, forfeit: true),
        ForfeitOutcome.locked,
      );
      verifyNoSend();
    });

    for (final status in [RunStatus.marshalling, RunStatus.inProgress]) {
      test('course partie ($status) : verrouillé, rien ne part', () async {
        programme = with479((h) => h.copyWith(status: status));
        final c = container();

        final un = of(await read(c), 101);

        expect(un.heat?.id, 479);
        expect(un.locked, isTrue);
        expect(
          await notifier(c).setForfeit(101, forfeit: true),
          ForfeitOutcome.locked,
        );
        verifyNoSend();
      });
    }

    test(
      "place illisible d'une course courue : inconnu et verrouillé",
      () async {
        programme = with479((h) => h.copyWith(status: RunStatus.finished));
        failing = {2817};

        final un = of(await read(container()), 101);

        expect(un.forfeit, isNull);
        expect(un.locked, isTrue);
      },
    );

    test('tour séries absent du programme : verrouillé', () async {
      when(() => results.getParticipants(any())).thenAnswer(
        (_) async => [
          ...participants,
          _athlete(5, 'CINQ', [(500, noRound.id)]),
        ],
      );
      final c = container();

      final cinq = of(await read(c), 500);

      expect(cinq.deadline, isNull);
      expect(cinq.locked, isTrue);
      expect(
        await notifier(c).setForfeit(500, forfeit: true),
        ForfeitOutcome.locked,
      );
      verifyNoSend();
    });

    test("aucune course du tour n'a d'heure : verrouillé", () async {
      programme = _mapHeats(waiting, (h) => h.copyWith(plannedStart: null));

      final list = await read(container());

      expect(list.every((f) => f.locked && f.deadline == null), isTrue);
    });

    test("compétition côtière : rien n'est lu", () async {
      disciplines = {Discipline.coastal};

      final list = await read(container());

      expect(list, isEmpty);
      verifyNever(() => meetings.getLanes(any()));
    });

    test('refresh relit les places', () async {
      final c = container();
      await read(c);
      reads.clear();
      lanes[2817] = _lane(2817, 2, 101, forfeit: true);

      await notifier(c).refresh();

      expect(reads, isNotEmpty);
      expect(of(current(c), 101).forfeit, isTrue);
    });
  });

  group('setForfeit', () {
    test(
      "déclare tout de suite, montre l'envoi, puis relit la place",
      () async {
        final c = container();
        await read(c);
        final sent = Completer<void>();
        holdSends(sent);
        reads.clear();
        lanes[2817] = _lane(2817, 2, 101, forfeit: true);

        final outcome = notifier(c).setForfeit(101, forfeit: true);
        await pumpEventQueue();

        expect(of(current(c), 101).forfeit, isTrue);
        expect(of(current(c), 101).sending, ForfeitSending.sending);

        sent.complete();
        expect(await outcome, ForfeitOutcome.done);
        verify(() => engagements.setForfeit(101, forfeit: true)).called(1);
        expect(reads, [2817]);
        expect(of(current(c), 101).forfeit, isTrue);
        expect(of(current(c), 101).sending, ForfeitSending.idle);
      },
    );

    test('annule un forfait déclaré', () async {
      final c = container();
      await read(c);
      lanes[2823] = _lane(2823, 2, 102);

      final outcome = await notifier(c).setForfeit(102, forfeit: false);

      expect(outcome, ForfeitOutcome.done);
      verify(() => engagements.setForfeit(102, forfeit: false)).called(1);
    });

    test("état inconnu : l'envoi est gardé et dit, pas pris pour un état "
        'lu', () async {
      lanes[2817] = null;
      final c = container();
      await read(c);
      now = DateTime(2026, 3, 27, 7, 12);

      final outcome = await notifier(c).setForfeit(101, forfeit: true);

      expect(outcome, ForfeitOutcome.done);
      verify(() => engagements.setForfeit(101, forfeit: true)).called(1);
      final un = of(current(c), 101);
      expect(un.forfeit, isNull);
      expect(un.lastSent, (forfeit: true, at: DateTime(2026, 3, 27, 7, 12)));

      // Gardé à la relecture tant que le fournisseur vit.
      await notifier(c).refresh();
      expect(of(current(c), 101).lastSent?.forfeit, isTrue);
    });

    test("la place relue contredit l'envoi : un résultat qui le dit", () async {
      final c = container();
      await read(c);

      final outcome = await notifier(c).setForfeit(101, forfeit: true);

      expect(outcome, ForfeitOutcome.unconfirmed);
      expect(of(current(c), 101).forfeit, isFalse);
    });

    test("un échec rend l'état précédent", () async {
      final c = container();
      await read(c);
      when(
        () => engagements.setForfeit(any(), forfeit: any(named: 'forfeit')),
      ).thenThrow(const AuthException('Invalid token'));

      final outcome = await notifier(c).setForfeit(101, forfeit: true);

      expect(outcome, ForfeitOutcome.failed);
      expect(of(current(c), 101).forfeit, isFalse);
      expect(of(current(c), 101).sending, ForfeitSending.idle);
      expect(of(current(c), 101).lastSent, isNull);
    });

    test("un refus du site rend l'état précédent", () async {
      final c = container();
      await read(c);
      when(
        () => engagements.setForfeit(any(), forfeit: any(named: 'forfeit')),
      ).thenThrow(const ApiException('Accès refusé'));

      final outcome = await notifier(c).setForfeit(102, forfeit: false);

      expect(outcome, ForfeitOutcome.failed);
      expect(of(current(c), 102).forfeit, isTrue);
      expect(of(current(c), 102).sending, ForfeitSending.idle);
    });

    test("second appui pendant l'envoi : occupé, un seul envoi", () async {
      final c = container();
      await read(c);
      final sent = Completer<void>();
      holdSends(sent);

      final first = notifier(c).setForfeit(101, forfeit: true);
      await pumpEventQueue();
      expect(
        await notifier(c).setForfeit(101, forfeit: false),
        ForfeitOutcome.busy,
      );
      sent.complete();
      await first;

      verify(
        () => engagements.setForfeit(any(), forfeit: any(named: 'forfeit')),
      ).called(1);
    });

    test("un rafraîchissement pendant l'envoi garde « envoi »", () async {
      final c = container();
      await read(c);
      final sent = Completer<void>();
      holdSends(sent);

      final first = notifier(c).setForfeit(101, forfeit: true);
      await pumpEventQueue();
      await notifier(c).refresh();

      expect(of(current(c), 101).sending, ForfeitSending.sending);
      sent.complete();
      await first;
      expect(of(current(c), 101).sending, ForfeitSending.idle);
    });

    test("course partie depuis la lecture : verrouillé à l'envoi, sans "
        'appel', () async {
      final c = container();
      await read(c);
      slots = with479((h) => h.copyWith(status: RunStatus.inProgress));

      final outcome = await notifier(c).setForfeit(101, forfeit: true);

      expect(outcome, ForfeitOutcome.locked);
      expect(itemReads, [177]);
      verifyNoSend();
      expect(of(current(c), 101).forfeit, isFalse);
      expect(of(current(c), 101).locked, isTrue);
      expect(of(current(c), 101).sending, ForfeitSending.idle);
    });

    test("créneau illisible à l'envoi : échec, sans appel", () async {
      final c = container();
      await read(c);
      when(
        () => meetings.getMeetingItem(any(), day: any(named: 'day')),
      ).thenThrow(const NetworkException('hors ligne'));

      final outcome = await notifier(c).setForfeit(101, forfeit: true);

      expect(outcome, ForfeitOutcome.failed);
      verifyNoSend();
      expect(of(current(c), 101).forfeit, isFalse);
    });

    test("échéance passée l'écran ouvert : refusé sans appel", () async {
      final c = container();
      await read(c);
      now = DateTime(2026, 3, 27, 7, 50);

      final outcome = await notifier(c).setForfeit(101, forfeit: true);

      expect(outcome, ForfeitOutcome.locked);
      verifyNoSend();
      expect(of(current(c), 101).forfeit, isFalse);
    });

    test('compte sans droit sur ce club : aucun appel', () async {
      rolesRead = () async => const CompetitionRoles(
        roles: ['referent_sportif'],
        refereeClubs: [ClubRef(id: 7, label: 'Autre')],
      );
      final c = container();
      await read(c);

      expect(
        await notifier(c).setForfeit(101, forfeit: true),
        ForfeitOutcome.notAllowed,
      );
      verifyNoSend();
    });

    test('droits en cours de lecture : aucun appel', () async {
      final pending = Completer<CompetitionRoles>();
      rolesRead = () => pending.future;
      final c = container();
      await read(c);

      expect(
        await notifier(c).setForfeit(101, forfeit: true),
        ForfeitOutcome.notAllowed,
      );
      verifyNoSend();
    });

    test('droits en échec : aucun appel', () async {
      rolesRead = () async => throw const NetworkException('hors ligne');
      final c = container();
      await read(c);

      expect(
        await notifier(c).setForfeit(101, forfeit: true),
        ForfeitOutcome.notAllowed,
      );
      verifyNoSend();
    });

    test('sans session : aucun appel', () async {
      account = null;
      final c = container();
      await read(c);

      expect(
        await notifier(c).setForfeit(101, forfeit: true),
        ForfeitOutcome.notAllowed,
      );
      verifyNoSend();
    });

    test("l'admin peut déclarer", () async {
      rolesRead = () async => const CompetitionRoles(roles: ['admin']);
      final c = container();
      await read(c);
      lanes[2817] = _lane(2817, 2, 101, forfeit: true);

      expect(
        await notifier(c).setForfeit(101, forfeit: true),
        ForfeitOutcome.done,
      );
      verify(() => engagements.setForfeit(101, forfeit: true)).called(1);
    });
  });

  group('le temps de la page du club', () {
    /// L'onglet Forfaits ouvert, comme la page : gardé par [keeper], suivi
    /// par l'onglet le temps qu'il est montré.
    Future<(ClubForfeitsKeeper, ProviderSubscription<Object?>)> openTab(
      ProviderContainer c,
    ) async {
      final keeper = ClubForfeitsKeeper(c, key)..open();
      addTearDown(keeper.close);
      final tab = c.listen(clubForfeitsProvider(key), (_, _) {});
      // Comme la page, qui suit les droits ; `read` garderait l'onglet
      // ouvert jusqu'à la fin du test.
      final roles = c.listen(
        competitionRolesProvider(competitionId),
        (_, _) {},
      );
      addTearDown(roles.close);
      await c.read(competitionRolesProvider(competitionId).future);
      await c.read(sessionProvider.future);
      await c.read(clubForfeitsProvider(key).future);
      return (keeper, tab);
    }

    Future<void> comeBack(ProviderContainer c) async {
      final back = c.listen(clubForfeitsProvider(key), (_, _) {});
      addTearDown(back.close);
      await c.read(clubForfeitsProvider(key).future);
    }

    test(
      'changer de sous-onglet puis revenir ne relit pas les places',
      () async {
        final c = container();
        final (keeper, tab) = await openTab(c);
        tab.close();
        await pumpEventQueue();
        reads.clear();

        await comeBack(c);

        expect(reads, isEmpty);
        expect(keeper.isOpen, isTrue);
      },
    );

    test("un envoi en vol le reste au retour : pas de second envoi", () async {
      final c = container();
      final (_, tab) = await openTab(c);
      final sent = Completer<void>();
      holdSends(sent);
      final first = notifier(c).setForfeit(101, forfeit: true);
      await pumpEventQueue();
      tab.close();
      await pumpEventQueue();

      await comeBack(c);

      expect(of(current(c), 101).sending, ForfeitSending.sending);
      expect(
        await notifier(c).setForfeit(101, forfeit: false),
        ForfeitOutcome.busy,
      );
      sent.complete();
      await first;
      verify(
        () => engagements.setForfeit(any(), forfeit: any(named: 'forfeit')),
      ).called(1);
    });

    test('la note « envoyé à » survit au retour', () async {
      lanes[2817] = null;
      final c = container();
      final (_, tab) = await openTab(c);
      await notifier(c).setForfeit(101, forfeit: true);
      tab.close();
      await pumpEventQueue();

      await comeBack(c);

      expect(of(current(c), 101).lastSent?.forfeit, isTrue);
    });

    test('fermé avec la page : le fournisseur est jeté', () async {
      final c = container();
      final (keeper, tab) = await openTab(c);
      tab.close();
      keeper.close();
      await pumpEventQueue();

      expect(keeper.isOpen, isFalse);
      expect(c.exists(clubForfeitsProvider(key)), isFalse);
    });
  });
}
