import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
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
  return Programme(
    meetings: [
      for (final meeting in withRaces(meetings, progressions))
        meeting.copyWith(
          items: [
            for (final item in meeting.items)
              item.copyWith(
                heats: [
                  for (final heat in item.heats)
                    heat.copyWith(status: RunStatus.waiting),
                ],
              ),
          ],
        ),
    ],
    progressions: progressions,
  );
}

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
  final programme = _waitingProgramme();
  final events = [
    for (final row in _rows('epreuves_1416'))
      ?EpreuveDto.fromJson(row).toDomain(),
  ];

  // UN court 36073 (engagement 101) ; DEUX court 36074 (102) et, avec
  // TROIS, l'engagement 200 de 36075 : un seul engagement, une seule ligne.
  // QUATRE n'est pas du club ; l'épreuve 1 n'est pas une épreuve eau plate.
  final participants = [
    _athlete(1, 'UN', [(101, 36073), (900, 1)]),
    _athlete(2, 'DEUX', [(102, 36074), (200, 36075)]),
    _athlete(3, 'TROIS', [(200, 36075)]),
    _athlete(4, 'QUATRE', [(300, 36073)]).copyWith(clubId: 7),
  ];

  late _MockResultsRepository results;
  late _MockMeetingRepository meetings;
  late _MockEngagementRepository engagements;
  late Map<int, LaneAssignment?> lanes;
  late Set<int> failing;
  late List<int> reads;
  late int peak;
  var disciplines = {Discipline.flatWater};
  var now = DateTime(2026, 3, 27, 7);
  CompetitionRoles roles = const CompetitionRoles(
    roles: ['referent_sportif'],
    refereeClubs: [ClubRef(id: clubId, label: 'CLUB Test')],
  );
  Account? account = const Account(label: 'REFERENT Club');

  setUpAll(() => registerFallbackValue(<int>[]));

  setUp(() {
    disciplines = {Discipline.flatWater};
    now = DateTime(2026, 3, 27, 7);
    roles = const CompetitionRoles(
      roles: ['referent_sportif'],
      refereeClubs: [ClubRef(id: clubId, label: 'CLUB Test')],
    );
    account = const Account(label: 'REFERENT Club');
    results = _MockResultsRepository();
    meetings = _MockMeetingRepository();
    engagements = _MockEngagementRepository();
    lanes = {
      for (final id in [for (var i = 2816; i <= 2829; i++) i]) id: null,
      2817: _lane(2817, 2, 101),
      2823: _lane(2823, 2, 102, forfeit: true),
      2825: _lane(2825, 4, 200),
    };
    failing = {};
    reads = [];
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
  });

  ProviderContainer container({List<Override> overrides = const []}) {
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
        competitionRolesProvider.overrideWith((ref, id) async => roles),
        sessionProvider.overrideWith(() => _FakeSession(account)),
        clockProvider.overrideWithValue(() => now),
        ...overrides,
      ],
      retry: noRetry,
    );
    addTearDown(c.dispose);
    return c;
  }

  Future<List<ClubForfeit>> read(ProviderContainer c) async {
    final sub = c.listen(clubForfeitsProvider(key), (_, _) {});
    addTearDown(sub.close);
    // Les droits sont lus d'avance, comme la page qui les suit.
    await c.read(competitionRolesProvider(competitionId).future);
    await c.read(sessionProvider.future);
    return c.read(clubForfeitsProvider(key).future);
  }

  ClubForfeit of(List<ClubForfeit> list, int entryId) =>
      list.singleWhere((f) => f.entryId == entryId);

  List<ClubForfeit> current(ProviderContainer c) =>
      c.read(clubForfeitsProvider(key)).value!;

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
      expect(un.deadline, DateTime(2026, 3, 27, 7, 50));
      expect(un.sending, ForfeitSending.idle);

      expect(of(list, 102).forfeit, isTrue);
      expect(of(list, 102).deadline, DateTime(2026, 3, 27, 7, 54));
    });

    test('6 places au plus en vol, et la lecture s\'arrête quand chaque '
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
      expect(of(list, 101).forfeit, isFalse);
    });

    test('engagement absent de toutes les places lues : pas encore placé, '
        'échéance de la première course à courir du tour', () async {
      lanes.remove(2817);
      lanes[2817] = null;

      final list = await read(container());

      final un = of(list, 101);
      expect(un.heat, isNull);
      expect(un.lane, isNull);
      expect(un.forfeit, isFalse);
      expect(un.deadline, DateTime(2026, 3, 27, 7, 50));
    });

    test('compétition côtière : rien n\'est lu', () async {
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

      await c.read(clubForfeitsProvider(key).notifier).refresh();

      expect(reads, isNotEmpty);
      expect(of(current(c), 101).forfeit, isTrue);
    });
  });

  group('toggle', () {
    test(
      'déclare tout de suite, montre l\'envoi, puis relit la place',
      () async {
        final c = container();
        await read(c);
        final sent = Completer<void>();
        when(
          () => engagements.setForfeit(any(), forfeit: any(named: 'forfeit')),
        ).thenAnswer((_) => sent.future);
        reads.clear();
        lanes[2817] = _lane(2817, 2, 101, forfeit: true);

        final outcome = c.read(clubForfeitsProvider(key).notifier).toggle(101);
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

      final outcome = await c
          .read(clubForfeitsProvider(key).notifier)
          .toggle(102);

      expect(outcome, ForfeitOutcome.done);
      verify(() => engagements.setForfeit(102, forfeit: false)).called(1);
    });

    test('un échec rend l\'état précédent', () async {
      final c = container();
      await read(c);
      when(
        () => engagements.setForfeit(any(), forfeit: any(named: 'forfeit')),
      ).thenThrow(const AuthException('Invalid token'));

      final outcome = await c
          .read(clubForfeitsProvider(key).notifier)
          .toggle(101);

      expect(outcome, ForfeitOutcome.failed);
      expect(of(current(c), 101).forfeit, isFalse);
      expect(of(current(c), 101).sending, ForfeitSending.idle);
    });

    test('échéance passée l\'écran ouvert : refusé sans appel', () async {
      final c = container();
      await read(c);
      now = DateTime(2026, 3, 27, 7, 50);

      final outcome = await c
          .read(clubForfeitsProvider(key).notifier)
          .toggle(101);

      expect(outcome, ForfeitOutcome.locked);
      verifyNever(
        () => engagements.setForfeit(any(), forfeit: any(named: 'forfeit')),
      );
      expect(of(current(c), 101).forfeit, isFalse);
    });

    test('compte sans droit sur ce club : aucun appel', () async {
      roles = const CompetitionRoles(
        roles: ['referent_sportif'],
        refereeClubs: [ClubRef(id: 7, label: 'Autre')],
      );
      final c = container();
      await read(c);

      final outcome = await c
          .read(clubForfeitsProvider(key).notifier)
          .toggle(101);

      expect(outcome, ForfeitOutcome.notAllowed);
      verifyNever(
        () => engagements.setForfeit(any(), forfeit: any(named: 'forfeit')),
      );
    });

    test('sans session : aucun appel', () async {
      account = null;
      final c = container();
      await read(c);

      final outcome = await c
          .read(clubForfeitsProvider(key).notifier)
          .toggle(101);

      expect(outcome, ForfeitOutcome.notAllowed);
      verifyNever(
        () => engagements.setForfeit(any(), forfeit: any(named: 'forfeit')),
      );
    });

    test('l\'admin peut déclarer', () async {
      roles = const CompetitionRoles(roles: ['admin']);
      final c = container();
      await read(c);

      final outcome = await c
          .read(clubForfeitsProvider(key).notifier)
          .toggle(101);

      expect(outcome, ForfeitOutcome.done);
    });
  });
}
