import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations_fr.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/core/router/app_router.dart';
import 'package:live_ffss_v2/data/ffss/dtos/deroulement_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/epreuve_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/reunion_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/serie_results_dto.dart';
import 'package:live_ffss_v2/data/ffss/mappers/deroulement_mapper.dart';
import 'package:live_ffss_v2/data/ffss/mappers/results_mapper.dart';
import 'package:live_ffss_v2/data/ffss/mappers/reunion_mapper.dart';
import 'package:live_ffss_v2/data/repositories/meeting_repository.dart';
import 'package:live_ffss_v2/data/repositories/result_repository.dart';
import 'package:live_ffss_v2/data/repositories/results_repository.dart';
import 'package:live_ffss_v2/domain/account.dart';
import 'package:live_ffss_v2/domain/event_ranking.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/gender.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/my_space.dart';
import 'package:live_ffss_v2/domain/now_running.dart';
import 'package:live_ffss_v2/domain/outbox.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/race_result.dart';
import 'package:live_ffss_v2/domain/run_status.dart';
import 'package:live_ffss_v2/domain/series_link.dart';
import 'package:live_ffss_v2/features/auth/session.dart';
import 'package:live_ffss_v2/features/my_space/my_space_formatting.dart';
import 'package:live_ffss_v2/features/my_space/official_space_providers.dart';
import 'package:live_ffss_v2/features/officiel/outbox_service.dart';
import 'package:live_ffss_v2/features/results/results_providers.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/fixtures.dart';

class _MockResultRepository extends Mock implements ResultRepository {}

class _MockResultsRepository extends Mock implements ResultsRepository {}

class _MockMeetingRepository extends Mock implements MeetingRepository {}

class _FakeSession extends SessionNotifier {
  _FakeSession(this._account);

  final Account? _account;

  @override
  Future<Account?> build() async => _account;
}

/// La file d'envoi sans envoi : celle que le test lui donne.
class _FakeOutbox extends OutboxService {
  _FakeOutbox(this._initial);

  final List<OutboxOperation> _initial;

  @override
  List<OutboxOperation> build() => _initial;

  void set(List<OutboxOperation> queue) => state = queue;
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

const _competition = 1416;
const _account = 'DUPONT Jean';

Heat _heat(int id, RunStatus status, {int? seriesId}) => Heat(
  id: id,
  name: 'Série $id',
  number: id,
  status: status,
  raceName: '100m Bouée tube',
  gender: Gender.female,
  seriesId: seriesId,
);

/// Huit séries terminées (séries FFSS 101 à 108) dans deux créneaux, une
/// en cours et une sans série FFSS.
Programme _programme() => Programme(
  meetings: [
    Meeting(
      id: 1,
      name: 'R1',
      day: DateTime(2026, 10, 18),
      items: [
        MeetingItem(
          id: 7,
          name: 'C7',
          heats: [
            for (var i = 1; i <= 4; i++)
              _heat(i, RunStatus.finished, seriesId: 100 + i),
            _heat(20, RunStatus.finished),
          ],
        ),
        MeetingItem(
          id: 8,
          name: 'C8',
          heats: [
            for (var i = 5; i <= 8; i++)
              _heat(i, RunStatus.finished, seriesId: 100 + i),
            _heat(9, RunStatus.inProgress, seriesId: 109),
          ],
        ),
      ],
    ),
  ],
);

RaceResult _result(
  int seriesId,
  int entryId, {
  List<int?> chronos = const [null, null, null],
  int? time,
}) => RaceResult(
  seriesId: seriesId,
  entryId: entryId,
  chronos: chronos,
  time: time,
);

OutboxOperation _op(
  String id, {
  String account = _account,
  int competitionId = _competition,
  int seriesId = 101,
  int entryId = 1,
  OutboxState state = OutboxState.pending,
  ResultChange change = const ResultChange(chronos: [6234, null, null]),
  DateTime? sentAt,
  OutboxRejection? rejection,
}) => OutboxOperation(
  id: id,
  account: account,
  competitionId: competitionId,
  placeId: 1,
  seriesId: seriesId,
  entryId: entryId,
  change: change,
  state: state,
  sentAt: sentAt,
  rejection: rejection,
);

class _Reads {
  final ids = <int>[];
  var peak = 0;
}

void main() {
  final l10n = AppLocalizationsFr();
  final now = DateTime(2026, 10, 18, 12);

  late _MockResultRepository result;
  late _MockResultsRepository results;
  late _MockMeetingRepository meetings;
  late _FakeOutbox outbox;
  late Map<int, Map<int, RaceResult>> heatResults;

  final fixtureProgramme = _fixtureProgramme();
  final events = [
    for (final row in _rows('epreuves_1416'))
      ?EpreuveDto.fromJson(row).toDomain(),
  ];
  late Map<int, List<EventSeries>> series;

  setUp(() {
    result = _MockResultRepository();
    results = _MockResultsRepository();
    meetings = _MockMeetingRepository();
    outbox = _FakeOutbox(const []);
    heatResults = {};
    series = {
      for (final id in const [36073, 36074, 36087])
        id: [
          for (final row in _rows('serie_epreuve_$id'))
            ?SerieResultsDto.fromJson(row).toDomain(),
        ],
    };
    when(
      () => meetings.getProgramme(any()),
    ).thenAnswer((_) async => _programme());
    when(() => result.getHeatResults(any())).thenAnswer(
      (invocation) async =>
          heatResults[invocation.positionalArguments.first as int] ??
          const <int, RaceResult>{},
    );
    when(() => results.getEvents(any())).thenAnswer((_) async => events);
    when(() => results.getEventSeries(any())).thenAnswer(
      (invocation) async =>
          series[invocation.positionalArguments.first as int] ?? const [],
    );
  });

  ProviderContainer container({
    Account? account = const Account(label: _account),
    List<Override> overrides = const [],
  }) {
    final c = ProviderContainer(
      overrides: [
        resultRepositoryProvider.overrideWithValue(result),
        resultsRepositoryProvider.overrideWithValue(results),
        meetingRepositoryProvider.overrideWithValue(meetings),
        sessionProvider.overrideWith(() => _FakeSession(account)),
        outboxProvider.overrideWith(() => outbox),
        clockProvider.overrideWithValue(() => now),
        ...overrides,
      ],
      retry: noRetry,
    );
    addTearDown(c.dispose);
    return c;
  }

  /// Les séries à saisir, une fois lues.
  Future<HeatsToEnter> toEnter(ProviderContainer c) async {
    final sub = c.listen(heatsToEnterProvider(_competition), (_, _) {});
    addTearDown(sub.close);
    return c.read(heatsToEnterProvider(_competition).future);
  }

  group('heatsToEnterProvider', () {
    test('aucune série terminée : vide, sans lecture', () async {
      when(() => meetings.getProgramme(any())).thenAnswer(
        (_) async => Programme(
          meetings: [
            Meeting(
              id: 1,
              name: 'R1',
              day: DateTime(2026, 10, 18),
              items: [
                MeetingItem(
                  id: 7,
                  name: 'C7',
                  heats: [_heat(1, RunStatus.waiting, seriesId: 101)],
                ),
              ],
            ),
          ],
        ),
      );
      final c = container();

      final read = await toEnter(c);

      expect(read.heats, isEmpty);
      expect(read.unread, 0);
      verifyNever(() => result.getHeatResults(any()));
    });

    test('les séries terminées sans rien de saisi, avec leur créneau, dans '
        "l'ordre du programme", () async {
      final c = container();

      final read = await toEnter(c);

      expect(read.heats.map((h) => h.heat.id), [1, 2, 3, 4, 5, 6, 7, 8]);
      expect(read.heats.first.item.id, 7);
      expect(read.heats.last.item.id, 8);
      expect(read.unread, 0);
    });

    test('un chrono saisi : exclue ; un chrono nul ne compte pas', () async {
      heatResults[101] = {
        1: _result(101, 1, chronos: const [null, 6234, null]),
      };
      heatResults[102] = {
        2: _result(102, 2, chronos: const [0, null, null]),
      };
      final c = container();

      final ids = (await toEnter(c)).heats.map((h) => h.heat.id);

      expect(ids, isNot(contains(1)));
      expect(ids, contains(2));
    });

    test('un temps publié par le juge : exclue', () async {
      heatResults[103] = {3: _result(103, 3, time: 6234)};
      final c = container();

      expect(
        (await toEnter(c)).heats.map((h) => h.heat.id),
        isNot(contains(3)),
      );
    });

    test('une saisie en file du compte : exclue ; refusée, ou d\'un autre '
        'compte : non', () async {
      outbox = _FakeOutbox([
        _op('a', seriesId: 104),
        _op('b', seriesId: 105, state: OutboxState.rejected),
        _op('c', seriesId: 106, account: 'MARTIN Paul'),
        _op('d', seriesId: 107, state: OutboxState.sent, sentAt: now),
      ]);
      final c = container();

      final ids = (await toEnter(c)).heats.map((h) => h.heat.id);

      expect(ids, [1, 2, 3, 5, 6, 8]);
    });

    test('la file suit sans relire les séries', () async {
      final c = container();
      await toEnter(c);
      clearInteractions(result);

      outbox.set([_op('a', seriesId: 101)]);

      final read = await c.read(heatsToEnterProvider(_competition).future);
      expect(read.heats.map((h) => h.heat.id), isNot(contains(1)));
      verifyNever(() => result.getHeatResults(any()));
    });

    test('une lecture en échec : signalée, les autres restent', () async {
      when(
        () => result.getHeatResults(102),
      ).thenThrow(const NetworkException('hors ligne'));
      final c = container();

      final read = await toEnter(c);

      expect(read.unread, 1);
      expect(read.heats.map((h) => h.heat.id), [1, 3, 4, 5, 6, 7, 8]);
    });

    test('6 lectures au plus en vol, chaque série lue une fois', () async {
      final reads = _Reads();
      var inFlight = 0;
      when(() => result.getHeatResults(any())).thenAnswer((invocation) async {
        reads.ids.add(invocation.positionalArguments.first as int);
        inFlight++;
        if (inFlight > reads.peak) reads.peak = inFlight;
        await Future<void>.delayed(const Duration(milliseconds: 5));
        inFlight--;
        return const <int, RaceResult>{};
      });
      final c = container();

      await toEnter(c);

      expect(reads.peak, 6);
      expect(reads.ids, [for (var i = 101; i <= 108; i++) i]);
    });

    test('rafraîchir relit les séries', () async {
      final c = container();
      await toEnter(c);
      heatResults[101] = {1: _result(101, 1, time: 6234)};

      await refreshHeatsToEnter(c, _competition);

      final read = await c.read(heatsToEnterProvider(_competition).future);
      expect(read.heats.map((h) => h.heat.id), isNot(contains(1)));
      verify(() => result.getHeatResults(101)).called(2);
    });

    test('programme en échec : rafraîchir le relit', () async {
      when(
        () => meetings.getProgramme(any()),
      ).thenThrow(const NetworkException('hors ligne'));
      final c = container();
      await expectLater(toEnter(c), throwsA(isA<NetworkException>()));

      when(
        () => meetings.getProgramme(any()),
      ).thenAnswer((_) async => _programme());
      await refreshHeatsToEnter(c, _competition);

      expect((await toEnter(c)).heats, hasLength(8));
    });
  });

  group('officialDecisionsProvider', () {
    setUp(() {
      when(
        () => meetings.getProgramme(any()),
      ).thenAnswer((_) async => fixtureProgramme);
    });

    Future<OfficialDecisions> decisions(ProviderContainer c) {
      final sub = c.listen(officialDecisionsProvider(_competition), (_, _) {});
      addTearDown(sub.close);
      return c.read(officialDecisionsProvider(_competition).future);
    }

    _Reads countReads() {
      final reads = _Reads();
      var inFlight = 0;
      when(() => results.getEventSeries(any())).thenAnswer((invocation) async {
        final id = invocation.positionalArguments.first as int;
        reads.ids.add(id);
        inFlight++;
        if (inFlight > reads.peak) reads.peak = inFlight;
        await Future<void>.delayed(const Duration(milliseconds: 2));
        inFlight--;
        return series[id] ?? const [];
      });
      return reads;
    }

    /// Le classement de [eventId] sur ses séries de la fixture : le
    /// programme réduit de la fixture ne les porte pas toutes.
    Override ranked(int eventId) {
      final event = events.firstWhere((e) => e.id == eventId);
      return eventRankingProvider((
        competitionId: _competition,
        eventId: eventId,
      )).overrideWith(
        (ref) async => rankEvent(event, [
          for (final one in series[eventId]!)
            LinkedSeries(
              series: one,
              heat: Heat(
                id: one.id,
                name: one.name,
                number: one.number,
                status: RunStatus.finished,
              ),
              round: EventRound.heats,
            ),
        ]),
      );
    }

    test('DQ (avec code) et forfaits, par épreuve', () async {
      // Un forfait dans la première série de 36074.
      final first = series[36074]!.first;
      series[36074] = [
        first.copyWith(
          results: [
            first.results.first.copyWith(status: statusForfeit),
            ...first.results.skip(1),
          ],
        ),
        ...series[36074]!.skip(1),
      ];
      final c = container(overrides: [ranked(36074), ranked(36087)]);

      final read = await decisions(c);

      expect(read.unreadEvents, 0);
      expect(read.events.map((e) => e.event.id), [
        for (final e in events)
          if (e.id == 36074 || e.id == 36087) e.id,
      ]);
      final dq = read.events.firstWhere((e) => e.event.id == 36087).rows;
      expect(dq.single.result.status, statusDisqualified);
      expect(dq.single.result.complement, '53');
      final forfeit = read.events.firstWhere((e) => e.event.id == 36074).rows;
      expect(forfeit.single.result.entryId, first.results.first.entryId);
      expect(isForfeit(forfeit.single.result), isTrue);
      // Les engagements lus nomment les saisies en file.
      expect(read.entries[dq.single.result.entryId]?.event.id, 36087);
    });

    test('une épreuve en échec : comptée, les autres restent', () async {
      when(
        () => results.getEventSeries(36074),
      ).thenThrow(const NetworkException('hors ligne'));
      final c = container(overrides: [ranked(36087)]);

      final read = await decisions(c);

      expect(read.unreadEvents, 1);
      expect(read.events.map((e) => e.event.id), [36087]);
    });

    test('6 classements au plus en vol, chacun lu une fois', () async {
      final reads = countReads();
      final c = container();

      await decisions(c);

      expect(events.length, greaterThan(6));
      expect(reads.peak, lessThanOrEqualTo(6));
      expect(reads.ids.toSet(), {for (final e in events) e.id});
      expect(reads.ids, hasLength(reads.ids.toSet().length));
    });

    test(
      'le rafraîchissement des Épreuves ne relit pas les classements',
      () async {
        final c = container();
        final tab = c.listen(eventsProvider(_competition), (_, _) {});
        addTearDown(tab.close);
        final before = await decisions(c);
        final reads = countReads();

        await c.read(eventsProvider(_competition).notifier).refresh();
        await pumpEventQueue();

        expect(reads.ids, isEmpty);
        expect(c.read(officialDecisionsProvider(_competition)).value, before);
      },
    );

    test('rafraîchir relit chaque classement une fois, 6 au plus en vol, '
        "même celui que l'onglet Résultats garde", () async {
      final c = container();
      final tab = c.listen(
        eventRankingProvider((competitionId: _competition, eventId: 36087)),
        (_, _) {},
      );
      addTearDown(tab.close);
      await decisions(c);
      final reads = countReads();

      await refreshOfficialDecisions(c, _competition);

      expect(reads.peak, lessThanOrEqualTo(6));
      expect(reads.ids.toSet(), {for (final e in events) e.id});
      expect(reads.ids, hasLength(reads.ids.toSet().length));
    });
  });

  group('myEntries', () {
    test('du compte connecté et de la compétition, par état ; envoyées des '
        'dernières 24 h', () {
      final queue = [
        _op('rejected', state: OutboxState.rejected),
        _op('pending'),
        _op(
          'sent',
          state: OutboxState.sent,
          sentAt: now.subtract(const Duration(hours: 23)),
        ),
        _op(
          'old',
          state: OutboxState.sent,
          sentAt: now.subtract(const Duration(hours: 25)),
        ),
        _op('other account', account: 'MARTIN Paul'),
        _op('other competition', competitionId: 99),
        _op('same, other case', account: ' dupont jean '),
      ];

      final entries = myEntries(queue, _account, _competition, now);

      expect(entries.rejected.map((o) => o.id), ['rejected']);
      expect(entries.pending.map((o) => o.id), ['pending', 'same, other case']);
      expect(entries.sent.map((o) => o.id), ['sent']);
      expect(entries.isEmpty, isFalse);
    });

    test('sans compte : rien', () {
      final entries = myEntries([_op('a')], null, _competition, now);
      expect(entries.isEmpty, isTrue);
    });
  });

  group('queuedDecisions', () {
    test('les DQ et forfaits en attente du compte sur la compétition', () {
      const dq = ResultChange(mark: ResultMark.disqualified, code: '12');
      const forfeit = ResultChange(mark: ResultMark.forfeit);
      final queue = [
        _op('dq', change: dq),
        _op('forfeit', change: forfeit),
        _op('chronos'),
        _op('cleared', change: const ResultChange(mark: ResultMark.ok)),
        _op('sent', change: dq, state: OutboxState.sent, sentAt: now),
        _op('rejected', change: dq, state: OutboxState.rejected),
        _op('other', change: dq, account: 'MARTIN Paul'),
        _op('elsewhere', change: dq, competitionId: 99),
      ];

      expect(queuedDecisions(queue, _account, _competition).map((o) => o.id), [
        'dq',
        'forfeit',
      ]);
      expect(queuedDecisions(queue, null, _competition), isEmpty);
    });
  });

  group('libellés', () {
    final at = (
      item: const MeetingItem(id: 7, name: 'C7'),
      heat: _heat(3, RunStatus.finished, seriesId: 103),
    );

    test("titre d'une série : épreuve, genre, série ; sinon le créneau", () {
      expect(officialHeatTitle(at, l10n), '100m Bouée tube · Dames · Série 3');
      final bare = (
        item: at.item,
        heat: at.heat.copyWith(raceName: '', gender: null),
      );
      expect(officialHeatTitle(bare, l10n), 'C7 · Série 3');
    });

    test('la saisie de la série, sous Mon espace', () {
      expect(
        officialEntryRoute(_competition, at),
        Routes.itemEntry(Routes.mySpace, _competition, 7, heatId: 3),
      );
    });

    test('ce que change une saisie', () {
      expect(
        entryChangeLabel(const ResultChange(chronos: [6234, null, 6240]), l10n),
        '1\'02"34 · 1\'02"40',
      );
      expect(
        entryChangeLabel(const ResultChange(chronos: [null, null, null]), l10n),
        l10n.entryNoChrono,
      );
      expect(
        entryChangeLabel(
          const ResultChange(mark: ResultMark.disqualified, code: '12'),
          l10n,
        ),
        'DQ 12',
      );
      expect(
        entryChangeLabel(const ResultChange(mark: ResultMark.forfeit), l10n),
        l10n.forfeit,
      );
      expect(
        entryChangeLabel(const ResultChange(mark: ResultMark.ok), l10n),
        l10n.officialStatusCleared,
      );
    });

    test("l'état d'une saisie", () {
      expect(entryStateLabel(_op('a'), l10n), l10n.entryPending);
      expect(
        entryStateLabel(
          _op(
            'b',
            state: OutboxState.sent,
            sentAt: DateTime(2026, 10, 18, 10, 42),
          ),
          l10n,
        ),
        l10n.officialSentAt('10:42'),
      );
      expect(
        entryStateLabel(
          _op(
            'c',
            state: OutboxState.rejected,
            rejection: OutboxRejection.emptyPlace,
          ),
          l10n,
        ),
        l10n.entryRejected(l10n.entryRejectedEmptyPlace),
      );
    });

    test('le bouton Saisir : la série en cours, si le compte peut saisir', () {
      final access = (
        current: NowRunning(
          heat: at.heat,
          kind: NowRunningKind.now,
          position: 1,
          total: 1,
        ),
        item: at.item,
        following: null,
      );
      expect(
        quickEntryRoute(access, _competition, canEnter: true),
        officialEntryRoute(_competition, at),
      );
      expect(quickEntryRoute(access, _competition, canEnter: false), isNull);
      expect(quickEntryRoute(null, _competition, canEnter: true), isNull);
      final noSeries = (
        current: access.current.copyWith(
          heat: at.heat.copyWith(seriesId: null),
        ),
        item: at.item,
        following: null,
      );
      expect(quickEntryRoute(noSeries, _competition, canEnter: true), isNull);
    });
  });
}
