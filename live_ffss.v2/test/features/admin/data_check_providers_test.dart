import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/ffss/dtos/deroulement_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/epreuve_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/reunion_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/serie_results_dto.dart';
import 'package:live_ffss_v2/data/ffss/mappers/deroulement_mapper.dart';
import 'package:live_ffss_v2/data/ffss/mappers/reunion_mapper.dart';
import 'package:live_ffss_v2/data/ffss/mappers/results_mapper.dart';
import 'package:live_ffss_v2/data/repositories/meeting_repository.dart';
import 'package:live_ffss_v2/data/repositories/result_repository.dart';
import 'package:live_ffss_v2/data/repositories/results_repository.dart';
import 'package:live_ffss_v2/domain/account.dart';
import 'package:live_ffss_v2/domain/competition_roles.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/domain/discipline.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/gender.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/race_result.dart';
import 'package:live_ffss_v2/domain/run_status.dart';
import 'package:live_ffss_v2/features/admin/data_check_providers.dart';
import 'package:live_ffss_v2/features/auth/competition_roles.dart';
import 'package:live_ffss_v2/features/auth/session.dart';
import 'package:live_ffss_v2/features/results/athlete_providers.dart';
import 'package:live_ffss_v2/features/shell/space_competition.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/fixtures.dart';

class _MockResultsRepository extends Mock implements ResultsRepository {}

class _MockMeetingRepository extends Mock implements MeetingRepository {}

class _MockResultRepository extends Mock implements ResultRepository {}

class _FakeSession extends SessionNotifier {
  _FakeSession(this._account);

  final Account? _account;

  @override
  Future<Account?> build() async => _account;

  void set(Account? account) => state = AsyncData(account);
}

const _competition = 1416;
const _admin = Account(
  label: 'ORGANISME TEST',
  type: 'organisme',
  role: 'admin',
);
const _licensee = Account(label: 'ATHLETE Un', type: 'licencie', role: 'user');

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

List<CompetitionEvent> _fixtureEvents() => [
  for (final row in _rows('epreuves_1416'))
    ?EpreuveDto.fromJson(row).toDomain(),
];

List<EventSeries> _fixtureSeries(int eventId) => [
  for (final row in _rows('serie_epreuve_$eventId'))
    ?SerieResultsDto.fromJson(row).toDomain(),
];

CompetitionSummary _summary(Set<Discipline> disciplines) => CompetitionSummary(
  id: _competition,
  name: 'Championnat',
  startDate: DateTime(2026, 3, 27),
  endDate: DateTime(2026, 3, 29),
  disciplines: disciplines,
);

CompetitionEvent _event(
  int id, {
  Discipline? discipline = Discipline.flatWater,
}) => CompetitionEvent(
  id: id,
  disciplineId: id,
  disciplineName: 'Épreuve $id',
  gender: Gender.female,
  categoryId: 1,
  categoryName: 'Cadet',
  teamSize: 1,
  discipline: discipline,
);

Heat _heat(
  int id, {
  RunStatus status = RunStatus.finished,
  DateTime? plannedStart,
  bool timed = true,
  List<int> placeIds = const [],
}) => Heat(
  id: id,
  name: 'Série $id',
  number: id,
  status: status,
  plannedStart: plannedStart ?? (timed ? DateTime(2026, 3, 27, 8) : null),
  seriesId: 9000 + id,
  placeIds: placeIds,
);

Programme _programme(List<Heat> heats) => Programme(
  meetings: [
    Meeting(
      id: 1,
      name: 'Réunion 1',
      day: DateTime(2026, 3, 27),
      items: [MeetingItem(id: 10, name: 'Créneau', heats: heats)],
    ),
  ],
);

RaceResult _result(int entryId, {int status = 0, int? time}) =>
    RaceResult(seriesId: 0, entryId: entryId, status: status, time: time);

void main() {
  late _MockResultsRepository results;
  late _MockMeetingRepository meetings;
  late _MockResultRepository result;
  late bool rolesFail;
  late List<String> roles;
  late bool participantsFail;
  late int participantsReads;
  late _FakeSession session;

  setUp(() {
    results = _MockResultsRepository();
    meetings = _MockMeetingRepository();
    result = _MockResultRepository();
    rolesFail = false;
    roles = const ['public'];
    participantsFail = false;
    participantsReads = 0;
    when(() => results.getEvents(any())).thenAnswer((_) async => const []);
    when(() => results.getEventSeries(any())).thenAnswer((_) async => const []);
    when(
      () => meetings.getProgramme(any()),
    ).thenAnswer((_) async => _programme(const []));
    when(() => meetings.getLanes(any())).thenAnswer(
      (invocation) async => {
        for (final id in invocation.positionalArguments.first as Iterable<int>)
          id: null,
      },
    );
    when(
      () => result.getHeatResults(any()),
    ).thenAnswer((_) async => {1: _result(1, time: 6000)});
  });

  ProviderContainer container({
    Account? account = _admin,
    Set<Discipline> disciplines = const {Discipline.flatWater},
    List<Override> overrides = const [],
  }) {
    session = _FakeSession(account);
    final c = ProviderContainer(
      overrides: [
        sessionProvider.overrideWith(() => session),
        resultsRepositoryProvider.overrideWithValue(results),
        meetingRepositoryProvider.overrideWithValue(meetings),
        resultRepositoryProvider.overrideWithValue(result),
        spaceCompetitionProvider.overrideWith(
          (ref, id) async => _summary(disciplines),
        ),
        competitionRolesProvider.overrideWith((ref, id) async {
          await ref.watch(sessionProvider.future);
          if (rolesFail) throw const NetworkException('hors ligne');
          return CompetitionRoles(roles: roles);
        }),
        participantsProvider.overrideWith((ref, id) async {
          participantsReads++;
          if (participantsFail) throw const NetworkException('hors ligne');
          return const <Participant>[];
        }),
        ...overrides,
      ],
      retry: noRetry,
    );
    addTearDown(c.dispose);
    return c;
  }

  Future<T> read<T>(ProviderContainer c, ProviderListenable<Future<T>> p) {
    final sub = c.listen(p, (_, _) {});
    addTearDown(sub.close);
    return sub.read();
  }

  /// Le contrôle ouvert, puis les étapes à la demande demandées.
  Future<DataCheck> checked(
    ProviderContainer c, {
    bool results = false,
    bool places = false,
  }) async {
    final provider = dataCheckProvider(_competition);
    final sub = c.listen(provider, (_, _) {});
    addTearDown(sub.close);
    await c.read(provider.future);
    final notifier = c.read(provider.notifier);
    if (results) await notifier.checkResults();
    if (places) await notifier.checkPlaces();
    return c.read(provider).requireValue;
  }

  List<DataIssue> ofKind(DataCheck check, DataIssueKind kind) => [
    for (final issue in check.issues)
      if (issue.kind == kind) issue,
  ];

  group('orphanSeries', () {
    test('36073 : les 12 séries d\'avril (Debut nul) sont orphelines, pas '
        'celles du programme', () {
      final series = _fixtureSeries(36073);
      final event = _fixtureEvents().firstWhere((e) => e.id == 36073);

      final orphans = orphanSeries(_fixtureProgramme(), event, series);

      final april = [
        for (final s in series)
          if (s.start == null) s.id,
      ];
      expect(april, hasLength(12));
      expect([for (final s in orphans) s.id], containsAll(april));
      expect([
        for (final s in orphans) s.id,
      ], isNot(anyOf(contains(94894), contains(94899))));
    });
  });

  group('dataCheckProvider', () {
    test(
      'fixtures 1416 : séries orphelines de 36073 signalées par épreuve',
      () async {
        when(
          () => results.getEvents(_competition),
        ).thenAnswer((_) async => _fixtureEvents());
        when(
          () => results.getEventSeries(36073),
        ).thenAnswer((_) async => _fixtureSeries(36073));
        when(
          () => meetings.getProgramme(_competition),
        ).thenAnswer((_) async => _fixtureProgramme());
        final c = container();

        final check = await read(c, dataCheckProvider(_competition).future);

        final orphans = ofKind(check, DataIssueKind.orphanSeries);
        // 22 séries, 2 rattachées à la réunion réduite : 12 d'avril, 8 de mars.
        expect(orphans, hasLength(20));
        expect(orphans.every((o) => o.event?.id == 36073), isTrue);
        expect(check.coastal, isFalse);
        // Toutes les épreuves eau plate sont lues.
        verify(() => results.getEventSeries(any())).called(60);
      },
    );

    test('épreuve sans spécialité : signalée, ses séries non lues', () async {
      when(
        () => results.getEvents(_competition),
      ).thenAnswer((_) async => [_event(1), _event(2, discipline: null)]);
      final c = container();

      final check = await read(c, dataCheckProvider(_competition).future);

      expect(
        [
          for (final i in ofKind(check, DataIssueKind.eventWithoutSpeciality))
            i.event?.id,
        ],
        [2],
      );
      verify(() => results.getEventSeries(1)).called(1);
      verifyNever(() => results.getEventSeries(2));
    });

    test(
      'épreuve côtière d\'une compétition mixte : ni lue ni signalée',
      () async {
        when(() => results.getEvents(_competition)).thenAnswer(
          (_) async => [_event(1), _event(2, discipline: Discipline.coastal)],
        );
        final c = container(
          disciplines: const {Discipline.flatWater, Discipline.coastal},
        );

        final check = await read(c, dataCheckProvider(_competition).future);

        expect(check.issues, isEmpty);
        verifyNever(() => results.getEventSeries(2));
      },
    );

    test('ouverture : ni résultats ni places lus, leur coût annoncé', () async {
      when(() => results.getEvents(_competition)).thenAnswer(
        (_) async => [_event(1), _event(2), _event(3, discipline: null)],
      );
      when(() => meetings.getProgramme(_competition)).thenAnswer(
        (_) async => _programme([
          _heat(1, placeIds: const [11, 12]),
          _heat(2, placeIds: const [21]),
          _heat(3, status: RunStatus.waiting, timed: false),
          _heat(4, status: RunStatus.waiting, placeIds: const [41, 42, 43]),
        ]),
      );
      final c = container();

      final check = await checked(c);

      verifyNever(() => result.getHeatResults(any()));
      verifyNever(() => meetings.getLanes(any()));
      expect(participantsReads, 0);
      expect(check.seriesReads, 2);
      expect(check.resultReads, 2);
      expect(check.placeReads, 6);
      expect(check.results, DataCheckStep.notRun);
      expect(check.places, DataCheckStep.notRun);
      expect(
        [
          for (final i in ofKind(check, DataIssueKind.raceWithoutTime))
            i.heat?.heat.id,
        ],
        [3],
      );
    });

    test('« Vérifier les résultats » : statut 3 et série terminée sans '
        'résultat, sans lire les places', () async {
      when(() => meetings.getProgramme(_competition)).thenAnswer(
        (_) async => _programme([
          _heat(1),
          _heat(2),
          _heat(3, status: RunStatus.waiting, timed: false),
        ]),
      );
      when(() => result.getHeatResults(9001)).thenAnswer(
        (_) async => {
          1: _result(1, time: 6000),
          2: _result(2, status: 3),
          3: _result(3, status: 3),
        },
      );
      // Ni temps ni décision du juge : rien de publié.
      when(
        () => result.getHeatResults(9002),
      ).thenAnswer((_) async => {1: _result(1), 2: _result(2, status: 3)});
      final c = container();

      final check = await checked(c, results: true);

      final status3 = ofKind(check, DataIssueKind.status3);
      expect(
        [for (final i in status3) (i.heat?.heat.id, i.count)],
        [(1, 2), (2, 1)],
      );
      expect(
        [
          for (final i in ofKind(check, DataIssueKind.finishedWithoutResult))
            i.heat?.heat.id,
        ],
        [2],
      );
      expect(check.results, DataCheckStep.done);
      expect(check.places, DataCheckStep.notRun);
      // Seules les séries terminées sont lues.
      verify(() => result.getHeatResults(any())).called(2);
      verifyNever(() => meetings.getLanes(any()));
    });

    test('« Vérifier les places » : les places non lues, en une demande '
        'au repository, qui en garde 6 en vol', () async {
      when(() => meetings.getProgramme(_competition)).thenAnswer(
        (_) async => _programme([
          _heat(1, placeIds: const [11]),
          _heat(4, status: RunStatus.waiting, placeIds: const [41, 42, 43]),
        ]),
      );
      when(
        () => meetings.getLanes(any()),
      ).thenAnswer((_) async => {11: null, 41: null});
      final c = container();

      final check = await checked(c, places: true);

      final places = ofKind(check, DataIssueKind.unreadablePlaces);
      expect([for (final i in places) (i.heat?.heat.id, i.count)], [(4, 2)]);
      expect(verify(() => meetings.getLanes(captureAny())).captured.single, [
        11,
        41,
        42,
        43,
      ]);
      verifyNever(() => result.getHeatResults(any()));
      expect(check.places, DataCheckStep.done);
    });

    test(
      'une DQ ou un forfait du juge, sans temps, est un résultat publié',
      () async {
        when(
          () => meetings.getProgramme(_competition),
        ).thenAnswer((_) async => _programme([_heat(1)]));
        when(
          () => result.getHeatResults(9001),
        ).thenAnswer((_) async => {1: _result(1, status: statusDisqualified)});
        final c = container();

        final check = await checked(c, results: true);

        expect(ofKind(check, DataIssueKind.finishedWithoutResult), isEmpty);
      },
    );

    test('compétition côtière : rien de lu', () async {
      final c = container(disciplines: const {Discipline.coastal});

      final check = await read(c, dataCheckProvider(_competition).future);

      expect(check.coastal, isTrue);
      expect(check.issues, isEmpty);
      verifyNever(() => results.getEvents(any()));
      verifyNever(() => meetings.getProgramme(any()));
      verifyNever(() => result.getHeatResults(any()));
      expect(participantsReads, 0);
    });

    test('compte non admin : refusé, rien de lu', () async {
      final c = container(account: _licensee);

      await expectLater(
        read(c, dataCheckProvider(_competition).future),
        throwsA(isA<AdminOnlyException>()),
      );
      verifyNever(() => results.getEvents(any()));
      verifyNever(() => meetings.getProgramme(any()));
      expect(participantsReads, 0);
    });

    test(
      'échecs partiels : chacun devient une ligne, le reste est lu',
      () async {
        when(
          () => results.getEvents(_competition),
        ).thenAnswer((_) async => [_event(1), _event(2), _event(3)]);
        when(
          () => results.getEventSeries(2),
        ).thenThrow(const NetworkException('hors ligne'));
        when(
          () => meetings.getProgramme(_competition),
        ).thenAnswer((_) async => _programme([_heat(1), _heat(2)]));
        when(
          () => result.getHeatResults(9001),
        ).thenThrow(const ApiException('500'));
        rolesFail = true;
        final c = container();

        final check = await checked(c, results: true);

        expect(
          [
            for (final i in ofKind(check, DataIssueKind.seriesFailed))
              i.event?.id,
          ],
          [2],
        );
        expect(
          [
            for (final i in ofKind(check, DataIssueKind.resultsFailed))
              i.heat?.heat.id,
          ],
          [1],
        );
        expect(ofKind(check, DataIssueKind.rolesFailed), hasLength(1));
        verify(() => results.getEventSeries(3)).called(1);
        verify(() => result.getHeatResults(9002)).called(1);
      },
    );

    test('participants : jamais lus par le contrôle, signalés seulement '
        "s'ils ont déjà échoué ailleurs", () async {
      final c = container();

      expect(
        ofKind(await checked(c), DataIssueKind.participantsFailed),
        isEmpty,
      );
      expect(participantsReads, 0);

      participantsFail = true;
      final participants = c.listen(
        participantsProvider(_competition),
        (_, _) {},
      );
      addTearDown(participants.close);
      await expectLater(
        c.read(participantsProvider(_competition).future),
        throwsA(isA<NetworkException>()),
      );
      await c.read(dataCheckProvider(_competition).notifier).refresh();

      expect(
        ofKind(
          c.read(dataCheckProvider(_competition)).requireValue,
          DataIssueKind.participantsFailed,
        ),
        hasLength(1),
      );
      // Le rafraîchissement du contrôle ne les relit pas non plus.
      expect(participantsReads, 1);
    });

    test(
      'épreuves et programme en échec : signalés, sans échec global',
      () async {
        when(
          () => results.getEvents(_competition),
        ).thenThrow(const NetworkException('hors ligne'));
        when(
          () => meetings.getProgramme(_competition),
        ).thenThrow(const NetworkException('hors ligne'));
        final c = container();

        final check = await read(c, dataCheckProvider(_competition).future);

        expect(ofKind(check, DataIssueKind.eventsFailed), hasLength(1));
        expect(ofKind(check, DataIssueKind.programmeFailed), hasLength(1));
        verifyNever(() => results.getEventSeries(any()));
        verifyNever(() => result.getHeatResults(any()));
      },
    );

    test('6 lectures au plus en vol', () async {
      when(
        () => results.getEvents(_competition),
      ).thenAnswer((_) async => [for (var i = 1; i <= 20; i++) _event(i)]);
      when(() => meetings.getProgramme(_competition)).thenAnswer(
        (_) async => _programme([for (var i = 1; i <= 20; i++) _heat(i)]),
      );
      var inFlight = 0;
      var maxInFlight = 0;
      Future<T> tracked<T>(T value) async {
        inFlight++;
        if (inFlight > maxInFlight) maxInFlight = inFlight;
        await Future<void>.delayed(const Duration(milliseconds: 1));
        inFlight--;
        return value;
      }

      when(
        () => results.getEventSeries(any()),
      ).thenAnswer((_) => tracked(const <EventSeries>[]));
      when(
        () => result.getHeatResults(any()),
      ).thenAnswer((_) => tracked({1: _result(1, time: 6000)}));
      final c = container();

      await checked(c);
      expect(maxInFlight, 6);
      verify(() => results.getEventSeries(any())).called(20);
      verifyNever(() => result.getHeatResults(any()));

      maxInFlight = 0;
      await c.read(dataCheckProvider(_competition).notifier).checkResults();

      expect(maxInFlight, 6);
      verify(() => result.getHeatResults(any())).called(20);
    });

    test('refresh : tout est relu', () async {
      when(
        () => results.getEvents(_competition),
      ).thenAnswer((_) async => [_event(1)]);
      final c = container();
      final sub = c.listen(dataCheckProvider(_competition), (_, _) {});
      addTearDown(sub.close);
      await c.read(dataCheckProvider(_competition).future);

      await c.read(dataCheckProvider(_competition).notifier).refresh();

      verify(() => results.getEvents(_competition)).called(2);
      verify(() => meetings.getProgramme(_competition)).called(2);
      verify(() => results.getEventSeries(1)).called(2);
    });

    test('une relecture des droits ne relance pas le contrôle', () async {
      roles = const ['public', 'admin'];
      final c = container(account: _licensee);
      final check = await checked(c);
      expect(check.coastal, isFalse);

      c.invalidate(competitionRolesProvider(_competition));
      await pumpEventQueue();

      expect(c.read(dataCheckProvider(_competition)).hasValue, isTrue);
      verify(() => results.getEvents(_competition)).called(1);
      verify(() => meetings.getProgramme(_competition)).called(1);
    });

    test('déconnexion : refusé aussitôt', () async {
      final c = container();
      await checked(c);

      session.set(null);

      // Sans attendre : la page montre le refus dès cette image.
      expect(
        c.read(dataCheckProvider(_competition)).error,
        isA<AdminOnlyException>(),
      );
    });

    test('chaque geste revérifie le droit : retiré, rien de lu', () async {
      roles = const ['public', 'admin'];
      when(() => meetings.getProgramme(_competition)).thenAnswer(
        (_) async => _programme([
          _heat(1, placeIds: const [11]),
        ]),
      );
      final c = container(account: _licensee);
      await checked(c);
      roles = const ['public'];
      c.invalidate(competitionRolesProvider(_competition));

      final notifier = c.read(dataCheckProvider(_competition).notifier);
      await notifier.checkResults();
      await notifier.checkPlaces();

      expect(
        c.read(dataCheckProvider(_competition)).error,
        isA<AdminOnlyException>(),
      );
      verifyNever(() => result.getHeatResults(any()));
      verifyNever(() => meetings.getLanes(any()));
    });
  });
}
