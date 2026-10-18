import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/repositories/meeting_repository.dart';
import 'package:live_ffss_v2/data/repositories/result_repository.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/lane_assignment.dart';
import 'package:live_ffss_v2/domain/manual_timing.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/progression.dart';
import 'package:live_ffss_v2/domain/run_status.dart';
import 'package:live_ffss_v2/features/auth/competition_roles.dart';
import 'package:live_ffss_v2/features/programme/item_detail_providers.dart';
import 'package:live_ffss_v2/features/programme/programme_providers.dart';
import 'package:mocktail/mocktail.dart';

class _MockMeetingRepository extends Mock implements MeetingRepository {}

class _MockResultRepository extends Mock implements ResultRepository {}

/// Les droits d'un officiel, que les tests font arriver ou partir.
final _canEnterFlag = NotifierProvider<_CanEnterFlag, bool>(_CanEnterFlag.new);

class _CanEnterFlag extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

void main() {
  const key = (competitionId: 1453, itemId: 10);
  final day = DateTime(2026, 3, 27);
  final now = DateTime(2026, 3, 27, 10);

  const stage = Stage(
    id: 100,
    order: 1,
    level: StageLevel.heats,
    name: 'Séries',
    qualification: QualificationMethod.byStage,
    heatCount: 2,
    placesPerHeat: 2,
    qualifyingPlaces: 8,
  );
  const progression = Progression(
    id: 7,
    name: '100 m bouée tube',
    stages: [stage],
  );

  late _MockMeetingRepository repository;
  late _MockResultRepository results;
  var canEnter = false;
  late MeetingItem item;
  late Map<int, LaneAssignment?> lanes;
  late List<Set<int>> laneRequests;

  Heat heat(
    int id,
    RunStatus status,
    List<int> placeIds, {
    bool generated = true,
  }) => Heat(
    id: id,
    name: 'Série $id',
    number: id,
    status: status,
    placeIds: placeIds,
    seriesId: generated ? 100 + id : null,
  );

  MeetingItem itemWith(RunStatus first, RunStatus second) => MeetingItem(
    id: 10,
    name: '100 m bouée tube',
    roundId: 100,
    heats: [
      heat(1, first, [11, 12]),
      heat(2, second, [21, 22]),
    ],
  );

  LaneAssignment lane(int id, int number, String athlete) =>
      LaneAssignment(id: id, lane: number, athletes: [athlete]);

  Programme programme() => Programme(
    meetings: [
      Meeting(
        id: 1,
        name: 'R1',
        day: day,
        items: [const MeetingItem(id: 10, name: '100 m bouée tube')],
      ),
    ],
    progressions: [progression],
  );

  // L'heure suit le temps simulé : la relecture des courses terminées en
  // dépend.
  ProviderContainer container([FakeAsync? async]) => ProviderContainer(
    overrides: [
      meetingRepositoryProvider.overrideWithValue(repository),
      resultRepositoryProvider.overrideWithValue(results),
      canEnterProvider.overrideWith((ref, _) => ref.watch(_canEnterFlag)),
      clockProvider.overrideWithValue(
        () => now.add(async?.elapsed ?? Duration.zero),
      ),
    ],
    retry: noRetry,
  )..read(_canEnterFlag.notifier).set(canEnter);

  setUpAll(() {
    registerFallbackValue(DateTime(2000));
    registerFallbackValue(<int>[]);
  });

  setUp(() {
    repository = _MockMeetingRepository();
    results = _MockResultRepository();
    canEnter = false;
    when(() => results.getHeatChronos(any())).thenAnswer((_) async => {});
    item = itemWith(RunStatus.inProgress, RunStatus.waiting);
    lanes = {
      11: lane(11, 2, 'Alice'),
      12: lane(12, 1, 'Bea'),
      21: lane(21, 1, 'Chloé'),
      22: null,
    };
    laneRequests = [];
    when(
      () => repository.getProgramme(any()),
    ).thenAnswer((_) async => programme());
    when(
      () => repository.getMeetingItem(any(), day: any(named: 'day')),
    ).thenAnswer((_) async => item);
    when(() => repository.getLanes(any())).thenAnswer((invocation) async {
      final ids = (invocation.positionalArguments.first as Iterable<int>)
          .toSet();
      laneRequests.add(ids);
      return {
        for (final id in ids)
          if (lanes.containsKey(id)) id: lanes[id],
      };
    });
  });

  test('premier chargement : créneau puis toutes ses places', () {
    fakeAsync((async) {
      final c = container(async);
      c.listen(meetingItemDetailProvider(key), (_, _) {});
      async.flushMicrotasks();

      verify(() => repository.getMeetingItem(10, day: day)).called(1);
      expect(laneRequests, [
        {11, 12, 21, 22},
      ]);
      final detail = c.read(meetingItemDetailProvider(key)).value!;
      expect(detail.meeting.id, 1);
      expect(detail.item, item);
      expect(detail.progression, progression);
      expect(detail.stage, stage);
      expect(detail.lanesOf(item.heats[0]).map((l) => l.athletes.single), [
        'Bea',
        'Alice',
      ]);
      expect(detail.lanesOf(item.heats[1]).map((l) => l.id), [21]);

      c.dispose();
    });
  });

  test(
    'toutes les places en échec au premier chargement : détail affiché sans nageurs',
    () {
      fakeAsync((async) {
        lanes = {};
        final c = container(async);
        c.listen(meetingItemDetailProvider(key), (_, _) {});
        async.flushMicrotasks();

        final state = c.read(meetingItemDetailProvider(key));
        expect(state.hasError, isFalse);
        expect(state.value!.lanesOf(item.heats[0]), isEmpty);
        expect(state.value!.lanesOf(item.heats[1]), isEmpty);

        c.dispose();
      });
    },
  );

  test(
    'au tour suivant, seules les places des courses non terminées sont relues',
    () {
      fakeAsync((async) {
        item = itemWith(RunStatus.inProgress, RunStatus.finished);
        final c = container(async);
        c.listen(meetingItemDetailProvider(key), (_, _) {});
        async.flushMicrotasks();
        laneRequests.clear();

        async.elapse(itemDetailRefresh);
        async.flushMicrotasks();

        verify(() => repository.getMeetingItem(10, day: day)).called(2);
        expect(laneRequests, [
          {11, 12},
        ]);

        c.dispose();
      });
    },
  );

  test(
    'une course qui passe à Terminé est relue une fois, puis toutes les 2 minutes',
    () {
      fakeAsync((async) {
        final c = container(async);
        c.listen(meetingItemDetailProvider(key), (_, _) {});
        async.flushMicrotasks();

        item = itemWith(RunStatus.finished, RunStatus.waiting);
        laneRequests.clear();
        // 30 s : la course 1 vient de finir, relue une fois.
        async.elapse(itemDetailRefresh);
        async.flushMicrotasks();
        expect(laneRequests.last, {11, 12, 21, 22});

        // 60, 90 et 120 s : moins de 2 minutes depuis cette lecture.
        for (var i = 0; i < 3; i++) {
          laneRequests.clear();
          async.elapse(itemDetailRefresh);
          async.flushMicrotasks();
          expect(laneRequests, [
            {21, 22},
          ]);
        }

        // 150 s : 2 minutes après la lecture de fin.
        laneRequests.clear();
        async.elapse(itemDetailRefresh);
        async.flushMicrotasks();
        expect(laneRequests, [
          {11, 12, 21, 22},
        ]);

        c.dispose();
      });
    },
  );

  test('une place en échec au rafraîchissement garde son nageur', () {
    fakeAsync((async) {
      final c = container(async);
      c.listen(meetingItemDetailProvider(key), (_, _) {});
      async.flushMicrotasks();

      lanes = {12: lane(12, 1, 'Bea2'), 21: lane(21, 1, 'Chloé'), 22: null};
      laneRequests.clear();
      async.elapse(itemDetailRefresh);
      async.flushMicrotasks();

      verify(() => repository.getMeetingItem(10, day: day)).called(2);
      expect(laneRequests, [
        {11, 12, 21, 22},
      ]);
      final detail = c.read(meetingItemDetailProvider(key)).value!;
      expect(detail.lanesOf(item.heats[0]).map((l) => l.athletes.single), [
        'Bea2',
        'Alice',
      ]);

      c.dispose();
    });
  });

  test('un rafraîchissement en échec garde le détail', () {
    fakeAsync((async) {
      final c = container(async);
      c.listen(meetingItemDetailProvider(key), (_, _) {});
      async.flushMicrotasks();

      when(
        () => repository.getMeetingItem(any(), day: any(named: 'day')),
      ).thenAnswer((_) async => throw const NetworkException('hors ligne'));
      async.elapse(itemDetailRefresh);
      async.flushMicrotasks();

      final state = c.read(meetingItemDetailProvider(key));
      expect(state.hasError, isTrue);
      expect(state.value?.item, item);

      c.dispose();
    });
  });

  test('programme pas encore chargé : le détail l\'attend', () {
    fakeAsync((async) {
      final pending = Completer<Programme>();
      when(
        () => repository.getProgramme(any()),
      ).thenAnswer((_) => pending.future);
      final c = container(async);
      c.listen(meetingItemDetailProvider(key), (_, _) {});
      async.flushMicrotasks();

      expect(c.read(meetingItemDetailProvider(key)).isLoading, isTrue);
      verifyNever(
        () => repository.getMeetingItem(any(), day: any(named: 'day')),
      );

      pending.complete(programme());
      async.flushMicrotasks();

      expect(c.read(meetingItemDetailProvider(key)).value?.item, item);

      c.dispose();
    });
  });

  test('créneau absent du programme : erreur', () {
    fakeAsync((async) {
      final c = container(async);
      const missing = (competitionId: 1453, itemId: 99);
      c.listen(meetingItemDetailProvider(missing), (_, _) {});
      async.flushMicrotasks();

      expect(
        c.read(meetingItemDetailProvider(missing)).error,
        isA<NotFoundException>(),
      );
      verifyNever(
        () => repository.getMeetingItem(any(), day: any(named: 'day')),
      );

      c.dispose();
    });
  });

  test('créneau illisible : erreur', () {
    fakeAsync((async) {
      when(
        () => repository.getMeetingItem(any(), day: any(named: 'day')),
      ).thenAnswer((_) async => null);
      final c = container(async);
      c.listen(meetingItemDetailProvider(key), (_, _) {});
      async.flushMicrotasks();

      expect(
        c.read(meetingItemDetailProvider(key)).error,
        isA<NotFoundException>(),
      );

      c.dispose();
    });
  });

  test('refresh relit tout', () {
    fakeAsync((async) {
      item = itemWith(RunStatus.finished, RunStatus.finished);
      final c = container(async);
      c.listen(meetingItemDetailProvider(key), (_, _) {});
      async.flushMicrotasks();
      laneRequests.clear();

      c.read(meetingItemDetailProvider(key).notifier).refresh();
      async.flushMicrotasks();

      verify(() => repository.getMeetingItem(10, day: day)).called(2);
      expect(laneRequests, [
        {11, 12, 21, 22},
      ]);

      c.dispose();
    });
  });

  test('refresh après un premier chargement en échec recharge le détail', () {
    fakeAsync((async) {
      when(
        () => repository.getMeetingItem(any(), day: any(named: 'day')),
      ).thenAnswer((_) async => throw const NetworkException('hors ligne'));
      final c = container(async);
      c.listen(meetingItemDetailProvider(key), (_, _) {});
      async.flushMicrotasks();
      expect(c.read(meetingItemDetailProvider(key)).hasValue, isFalse);

      when(
        () => repository.getMeetingItem(any(), day: any(named: 'day')),
      ).thenAnswer((_) async => item);
      c.read(meetingItemDetailProvider(key).notifier).refresh();
      async.flushMicrotasks();

      expect(c.read(meetingItemDetailProvider(key)).value?.item, item);

      c.dispose();
    });
  });

  test('la page fermée pendant la relecture du créneau : rien ne casse', () {
    fakeAsync((async) {
      final c = container(async);
      final subscription = c.listen(meetingItemDetailProvider(key), (_, _) {});
      async.flushMicrotasks();

      final pending = Completer<MeetingItem?>();
      when(
        () => repository.getMeetingItem(any(), day: any(named: 'day')),
      ).thenAnswer((_) => pending.future);
      async.elapse(itemDetailRefresh);
      async.flushMicrotasks();

      clearInteractions(repository);
      subscription.close();
      // Riverpod libère un fournisseur `autoDispose` sur un `Timer` nul, pas
      // sur une microtâche.
      async.elapse(Duration.zero);
      expect(c.exists(meetingItemDetailProvider(key)), isFalse);

      pending.complete(item);
      async.flushMicrotasks();
      async.elapse(itemDetailRefresh * 2);
      async.flushMicrotasks();

      // Ni les places du créneau, ni un nouveau tour : la page est fermée.
      verifyNever(() => repository.getLanes(any()));
      verifyNever(
        () => repository.getMeetingItem(any(), day: any(named: 'day')),
      );
      c.dispose();
    });
  });

  test('la page fermée pendant la relecture des places : rien ne casse', () {
    fakeAsync((async) {
      final c = container(async);
      final subscription = c.listen(meetingItemDetailProvider(key), (_, _) {});
      async.flushMicrotasks();

      final pending = Completer<Map<int, LaneAssignment?>>();
      when(() => repository.getLanes(any())).thenAnswer((_) => pending.future);
      async.elapse(itemDetailRefresh);
      async.flushMicrotasks();

      subscription.close();
      async.elapse(Duration.zero);
      expect(c.exists(meetingItemDetailProvider(key)), isFalse);

      pending.complete({11: lane(11, 2, 'Alice tardive')});
      async.flushMicrotasks();
      c.dispose();
    });
  });

  test(
    'refresh en attente derrière la minuterie, page fermée : sans erreur',
    () {
      fakeAsync((async) {
        final c = container(async);
        c.listen(meetingItemDetailProvider(key), (_, _) {});
        async.flushMicrotasks();

        final pending = Completer<MeetingItem?>();
        when(
          () => repository.getMeetingItem(any(), day: any(named: 'day')),
        ).thenAnswer((_) => pending.future);
        async.elapse(itemDetailRefresh);
        async.flushMicrotasks();

        var completed = false;
        Object? failure;
        c
            .read(meetingItemDetailProvider(key).notifier)
            .refresh()
            .then(
              (_) => completed = true,
              onError: (Object e) {
                failure = e;
                return false;
              },
            );
        async.flushMicrotasks();
        expect(completed, isFalse);

        c.dispose();
        pending.complete(item);
        async.flushMicrotasks();

        expect(failure, isNull);
        expect(completed, isTrue);
      });
    },
  );

  test('premier chargement en échec : la minuterie fait un nouvel essai', () {
    fakeAsync((async) {
      when(
        () => repository.getMeetingItem(any(), day: any(named: 'day')),
      ).thenAnswer((_) async => throw const NetworkException('hors ligne'));
      final c = container(async);
      c.listen(meetingItemDetailProvider(key), (_, _) {});
      async.flushMicrotasks();
      expect(c.read(meetingItemDetailProvider(key)).hasError, isTrue);

      when(
        () => repository.getMeetingItem(any(), day: any(named: 'day')),
      ).thenAnswer((_) async => item);
      async.elapse(itemDetailRefresh);
      async.flushMicrotasks();

      final state = c.read(meetingItemDetailProvider(key));
      expect(state.hasError, isFalse);
      expect(state.value?.item, item);

      c.dispose();
    });
  });

  test('refresh après un programme en échec relit le programme', () {
    fakeAsync((async) {
      when(
        () => repository.getProgramme(any()),
      ).thenAnswer((_) async => throw const NetworkException('hors ligne'));
      final c = container(async);
      c.listen(meetingItemDetailProvider(key), (_, _) {});
      async.flushMicrotasks();
      expect(c.read(meetingItemDetailProvider(key)).hasError, isTrue);

      when(
        () => repository.getProgramme(any()),
      ).thenAnswer((_) async => programme());
      c.read(meetingItemDetailProvider(key).notifier).refresh();
      async.flushMicrotasks();

      expect(c.read(meetingItemDetailProvider(key)).value?.item, item);

      c.dispose();
    });
  });

  test('deux refresh simultanés ne lancent pas deux lectures à la fois', () {
    fakeAsync((async) {
      final c = container(async);
      c.listen(meetingItemDetailProvider(key), (_, _) {});
      async.flushMicrotasks();
      clearInteractions(repository);

      final first = Completer<MeetingItem?>();
      when(
        () => repository.getMeetingItem(any(), day: any(named: 'day')),
      ).thenAnswer((_) => first.future);
      final notifier = c.read(meetingItemDetailProvider(key).notifier);
      notifier.refresh();
      notifier.refresh();
      async.flushMicrotasks();
      verify(() => repository.getMeetingItem(10, day: day)).called(1);

      when(
        () => repository.getMeetingItem(any(), day: any(named: 'day')),
      ).thenAnswer((_) async => item);
      first.complete(item);
      async.flushMicrotasks();
      verify(() => repository.getMeetingItem(10, day: day)).called(1);

      c.dispose();
    });
  });

  test('programme en échec mais gardé en mémoire : le détail s\'ouvre', () {
    fakeAsync((async) {
      final c = container(async);
      c.listen(programmeProvider(key.competitionId), (_, _) {});
      async.flushMicrotasks();
      when(
        () => repository.getProgramme(any()),
      ).thenAnswer((_) async => throw const NetworkException('hors ligne'));
      async.elapse(programmeRefresh);
      async.flushMicrotasks();
      final programmeState = c.read(programmeProvider(key.competitionId));
      expect(programmeState.hasError && programmeState.hasValue, isTrue);

      c.listen(meetingItemDetailProvider(key), (_, _) {});
      async.flushMicrotasks();

      final state = c.read(meetingItemDetailProvider(key));
      expect(state.hasError, isFalse);
      expect(state.value?.item, item);

      c.dispose();
    });
  });

  test('programme en cours de relecture : le détail ne l\'attend pas', () {
    fakeAsync((async) {
      final c = container(async);
      c.listen(programmeProvider(key.competitionId), (_, _) {});
      async.flushMicrotasks();
      final pending = Completer<Programme>();
      when(
        () => repository.getProgramme(any()),
      ).thenAnswer((_) => pending.future);
      async.elapse(programmeRefresh);
      async.flushMicrotasks();
      expect(c.read(programmeProvider(key.competitionId)).isLoading, isTrue);

      c.listen(meetingItemDetailProvider(key), (_, _) {});
      async.flushMicrotasks();

      expect(c.read(meetingItemDetailProvider(key)).value?.item, item);

      pending.complete(programme());
      c.dispose();
    });
  });

  test('les places d\'une course sans série ne sont jamais lues', () {
    fakeAsync((async) {
      item = MeetingItem(
        id: 10,
        name: '100 m bouée tube',
        roundId: 100,
        heats: [
          heat(1, RunStatus.inProgress, [11, 12]),
          heat(2, RunStatus.waiting, [21, 22], generated: false),
        ],
      );
      final c = container(async);
      c.listen(meetingItemDetailProvider(key), (_, _) {});
      async.flushMicrotasks();
      expect(laneRequests, [
        {11, 12},
      ]);

      laneRequests.clear();
      async.elapse(itemDetailRefresh);
      async.flushMicrotasks();
      expect(laneRequests, [
        {11, 12},
      ]);

      laneRequests.clear();
      c.read(meetingItemDetailProvider(key).notifier).refresh();
      async.flushMicrotasks();
      expect(laneRequests, [
        {11, 12},
      ]);

      c.dispose();
    });
  });

  test(
    'une course terminée dont une place a échoué est relue au tour suivant',
    () {
      fakeAsync((async) {
        item = itemWith(RunStatus.finished, RunStatus.waiting);
        lanes.remove(12);
        final c = container(async);
        c.listen(meetingItemDetailProvider(key), (_, _) {});
        async.flushMicrotasks();

        laneRequests.clear();
        async.elapse(itemDetailRefresh);
        async.flushMicrotasks();
        expect(laneRequests, [
          {11, 12, 21, 22},
        ]);

        c.dispose();
      });
    },
  );

  test('le déroulement est replié au départ et se déplie', () {
    final c = container();
    addTearDown(c.dispose);

    expect(c.read(progressionExpandedProvider), isFalse);
    c.read(progressionExpandedProvider.notifier).toggle();
    expect(c.read(progressionExpandedProvider), isTrue);
  });

  group('temps manuel', () {
    // Série 1 : Alice (engagement 501) sans temps, Bea (502) avec un temps
    // publié. Les chronos des deux existent.
    void setUpManual() {
      lanes = {
        11: const LaneAssignment(
          id: 11,
          lane: 2,
          athletes: ['Alice'],
          entryId: 501,
        ),
        12: const LaneAssignment(
          id: 12,
          lane: 1,
          athletes: ['Bea'],
          entryId: 502,
          performance: Performance(time: '30"00', timeHundredths: 3000),
        ),
        21: lane(21, 1, 'Chloé'),
        22: null,
      };
      when(() => results.getHeatChronos(101)).thenAnswer(
        (_) async => {
          501: [3100, 3200, null],
          502: [2900, null, null],
        },
      );
    }

    test('un spectateur ne déclenche aucun appel aux chronos', () {
      fakeAsync((async) {
        setUpManual();
        final c = container(async);
        c.listen(meetingItemDetailProvider(key), (_, _) {});
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 90));

        verifyNever(() => results.getHeatChronos(any()));
        final detail = c.read(meetingItemDetailProvider(key)).value!;
        expect(detail.chronos, isEmpty);
        expect(detail.manualTimesOf(item.heats[0]), isEmpty);

        c.dispose();
      });
    });

    test(
      'un officiel voit le temps manuel des places sans temps seulement',
      () {
        fakeAsync((async) {
          setUpManual();
          canEnter = true;
          final c = container(async);
          c.listen(meetingItemDetailProvider(key), (_, _) {});
          async.flushMicrotasks();

          final times = c
              .read(meetingItemDetailProvider(key))
              .value!
              .manualTimesOf(item.heats[0]);
          expect(times.keys, [11]);
          expect(times[11]!.hundredths, 3150);
          expect(times[11]!.rule, ManualTimeRule.average);

          c.dispose();
        });
      },
    );

    test('les chronos suivent la cadence des places des courses en cours', () {
      fakeAsync((async) {
        setUpManual();
        item = itemWith(RunStatus.inProgress, RunStatus.finished);
        canEnter = true;
        final c = container(async);
        c.listen(meetingItemDetailProvider(key), (_, _) {});
        async.flushMicrotasks();
        clearInteractions(results);

        async.elapse(itemDetailRefresh);
        async.flushMicrotasks();

        verify(() => results.getHeatChronos(101)).called(1);
        verifyNever(() => results.getHeatChronos(102));

        c.dispose();
      });
    });

    test('un échec des chronos ne fait pas échouer le détail', () {
      fakeAsync((async) {
        setUpManual();
        canEnter = true;
        when(
          () => results.getHeatChronos(any()),
        ).thenThrow(const NetworkException('hors ligne'));
        final c = container(async);
        c.listen(meetingItemDetailProvider(key), (_, _) {});
        async.flushMicrotasks();

        final state = c.read(meetingItemDetailProvider(key));
        expect(state.hasError, isFalse);
        expect(state.value!.manualTimesOf(item.heats[0]), isEmpty);
        expect(state.value!.lanesOf(item.heats[0]), hasLength(2));

        c.dispose();
      });
    });

    test('droit perdu pendant le premier chargement : aucun temps manuel', () {
      fakeAsync((async) {
        setUpManual();
        canEnter = true;
        final pending = Completer<Map<int, List<int?>>>();
        when(
          () => results.getHeatChronos(any()),
        ).thenAnswer((_) => pending.future);
        final c = container(async);
        c.listen(meetingItemDetailProvider(key), (_, _) {});
        async.flushMicrotasks();

        // Les places sont déjà affichées, les chronos pas encore revenus.
        expect(c.read(meetingItemDetailProvider(key)).hasValue, isTrue);
        c.read(_canEnterFlag.notifier).set(false);
        pending.complete({
          501: [3100, 3200, null],
        });
        async.flushMicrotasks();

        final detail = c.read(meetingItemDetailProvider(key)).value!;
        expect(detail.chronos, isEmpty);
        expect(detail.manualTimesOf(item.heats[0]), isEmpty);

        c.dispose();
      });
    });

    test('droits arrivés après le chargement : chronos lus et montrés', () {
      fakeAsync((async) {
        setUpManual();
        final c = container(async);
        c.listen(meetingItemDetailProvider(key), (_, _) {});
        async.flushMicrotasks();
        verifyNever(() => results.getHeatChronos(any()));

        c.read(_canEnterFlag.notifier).set(true);
        async.flushMicrotasks();
        async.elapse(const Duration(milliseconds: 1));

        final detail = c.read(meetingItemDetailProvider(key)).value!;
        expect(detail.manualTimesOf(item.heats[0]).keys, [11]);

        c.dispose();
      });
    });

    test('droits perdus : chronos effacés aussitôt', () {
      fakeAsync((async) {
        setUpManual();
        canEnter = true;
        final c = container(async);
        c.listen(meetingItemDetailProvider(key), (_, _) {});
        async.flushMicrotasks();
        expect(
          c.read(meetingItemDetailProvider(key)).value!.chronos,
          isNotEmpty,
        );

        c.read(_canEnterFlag.notifier).set(false);

        expect(c.read(meetingItemDetailProvider(key)).value!.chronos, isEmpty);

        c.dispose();
      });
    });

    test('les séries se lisent en parallèle, 6 au plus à la fois', () {
      fakeAsync((async) {
        setUpManual();
        canEnter = true;
        item = MeetingItem(
          id: 10,
          name: '100 m bouée tube',
          roundId: 100,
          heats: [
            for (var i = 1; i <= 8; i++) heat(i, RunStatus.waiting, [i * 10]),
          ],
        );
        var inFlight = 0;
        var peak = 0;
        when(() => results.getHeatChronos(any())).thenAnswer((_) async {
          inFlight++;
          if (inFlight > peak) peak = inFlight;
          await Future<void>.delayed(const Duration(seconds: 1));
          inFlight--;
          return {};
        });
        final c = container(async);
        c.listen(meetingItemDetailProvider(key), (_, _) {});
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 5));

        verify(() => results.getHeatChronos(any())).called(8);
        expect(peak, maxConcurrentChronos);

        c.dispose();
      });
    });
  });
}
