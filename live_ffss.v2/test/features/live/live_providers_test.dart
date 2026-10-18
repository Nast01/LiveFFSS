import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/repositories/meeting_repository.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/lane_assignment.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/run_status.dart';
import 'package:live_ffss_v2/features/auth/competition_roles.dart';
import 'package:live_ffss_v2/features/live/live_providers.dart';
import 'package:mocktail/mocktail.dart';

class _MockMeetingRepository extends Mock implements MeetingRepository {}

void main() {
  const competitionId = 1453;
  final day = DateTime(2026, 3, 27);

  late _MockMeetingRepository repository;
  late List<Heat> heats;
  late Map<int, LaneAssignment?> lanes;
  late List<Set<int>> laneRequests;

  Heat heat(
    int id,
    RunStatus status,
    List<int> placeIds, {
    bool provisional = true,
  }) => Heat(
    id: id,
    name: 'Série $id',
    number: id,
    status: status,
    placeIds: placeIds,
    seriesId: 100 + id,
    plannedStart: day.add(Duration(hours: 9, minutes: id)),
    resultsProvisional: provisional,
  );

  // Course 1 en cours, course 2 terminée et validée, course 3 en attente :
  // seules les deux premières sont au Live.
  List<Heat> defaultHeats({bool secondProvisional = false}) => [
    heat(1, RunStatus.inProgress, [11, 12]),
    heat(2, RunStatus.finished, [21, 22], provisional: secondProvisional),
    heat(3, RunStatus.waiting, [31]),
  ];

  Programme programme() => Programme(
    meetings: [
      Meeting(
        id: 1,
        name: 'R1',
        day: day,
        items: [MeetingItem(id: 10, name: '100 m bouée tube', heats: heats)],
      ),
    ],
  );

  LaneAssignment lane(int id, int number, String athlete) =>
      LaneAssignment(id: id, lane: number, athletes: [athlete]);

  late int roleReads;

  // Les rôles échouent à la première lecture, puis donnent un officiel.
  ProviderContainer container() => ProviderContainer(
    overrides: [
      meetingRepositoryProvider.overrideWithValue(repository),
      competitionRolesProvider.overrideWith((ref, id) async {
        if (++roleReads == 1) throw const NetworkException('hors ligne');
        return ['officiel'];
      }),
    ],
    retry: noRetry,
  );

  ProviderSubscription<AsyncValue<LiveView>> listen(ProviderContainer c) =>
      c.listen(liveProvider(competitionId), (_, _) {});

  LiveView view(ProviderContainer c) =>
      c.read(liveProvider(competitionId)).value!;

  setUpAll(() {
    registerFallbackValue(<int>[]);
  });

  setUp(() {
    repository = _MockMeetingRepository();
    heats = defaultHeats();
    lanes = {
      11: lane(11, 2, 'Alice'),
      12: lane(12, 1, 'Bea'),
      21: lane(21, 1, 'Chloé'),
      22: null,
      31: lane(31, 1, 'Diane'),
    };
    laneRequests = [];
    roleReads = 0;
    when(
      () => repository.getProgramme(any()),
    ).thenAnswer((_) async => programme());
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

  test('le rafraîchissement manuel relit des rôles en échec, '
      'pas la minuterie', () {
    fakeAsync((async) {
      final c = container();
      listen(c);
      c.listen(canEnterProvider(competitionId), (_, _) {});
      async.flushMicrotasks();
      expect(roleReads, 1);
      expect(c.read(competitionRolesProvider(competitionId)).hasError, isTrue);

      async.elapse(liveRefresh);
      async.flushMicrotasks();
      expect(roleReads, 1);

      c.read(liveProvider(competitionId).notifier).refresh();
      async.elapse(Duration.zero);
      expect(roleReads, 2);
      expect(c.read(canEnterProvider(competitionId)), isTrue);

      c.dispose();
    });
  });

  test('premier chargement : programme puis places des courses du Live', () {
    fakeAsync((async) {
      final c = container();
      listen(c);
      async.flushMicrotasks();

      verify(() => repository.getProgramme(competitionId)).called(1);
      expect(laneRequests, [
        {11, 12},
        {21, 22},
      ]);
      final live = view(c);
      expect(live.meetings.single.id, 1);
      expect(live.running.map((e) => e.heat.id), [1]);
      expect(live.recent.map((e) => e.heat.id), [2]);
      expect(live.lanesOf(heats[0]).map((l) => l.athletes.single), [
        'Bea',
        'Alice',
      ]);
      expect(live.lanesOf(heats[1]).map((l) => l.id), [21]);

      c.dispose();
    });
  });

  group('premier affichage avant les places', () {
    late List<Completer<Map<int, LaneAssignment?>>> pending;

    setUp(() {
      pending = [];
      when(() => repository.getLanes(any())).thenAnswer((invocation) {
        laneRequests.add(
          (invocation.positionalArguments.first as Iterable<int>).toSet(),
        );
        final completer = Completer<Map<int, LaneAssignment?>>();
        pending.add(completer);
        return completer.future;
      });
    });

    Map<int, LaneAssignment?> answer(Iterable<int> ids) => {
      for (final id in ids) id: lanes[id],
    };

    test('les séries sans places, puis les places : en cours d\'abord', () {
      fakeAsync((async) {
        final c = container();
        listen(c);
        async.flushMicrotasks();

        final first = view(c);
        expect(first.running.map((e) => e.heat.id), [1]);
        expect(first.recent.map((e) => e.heat.id), [2]);
        expect(first.lanes, isEmpty);
        expect(first.lanesReadFor(heats[0]), isFalse);
        expect(laneRequests, [
          {11, 12},
        ]);

        pending[0].complete(answer([11, 12]));
        async.flushMicrotasks();
        expect(view(c).lanesOf(heats[0]).map((l) => l.athletes.single), [
          'Bea',
          'Alice',
        ]);
        expect(view(c).lanesReadFor(heats[1]), isFalse);
        expect(laneRequests, [
          {11, 12},
          {21, 22},
        ]);

        pending[1].complete(answer([21, 22]));
        async.flushMicrotasks();
        expect(view(c).lanesOf(heats[1]).map((l) => l.id), [21]);
        expect(view(c).lanesReadFor(heats[1]), isTrue);

        c.dispose();
      });
    });

    test('la minuterie attend la fin de la lecture des places', () {
      fakeAsync((async) {
        final c = container();
        listen(c);
        async.flushMicrotasks();
        clearInteractions(repository);

        async.elapse(liveRefresh);
        async.flushMicrotasks();
        verifyNever(() => repository.getProgramme(any()));

        pending[0].complete(answer([11, 12]));
        async.flushMicrotasks();
        pending[1].complete(answer([21, 22]));
        async.flushMicrotasks();
        async.elapse(liveRefresh);
        async.flushMicrotasks();
        verify(() => repository.getProgramme(competitionId)).called(1);

        c.dispose();
      });
    });

    test('refresh attend la fin de la lecture des places', () {
      fakeAsync((async) {
        final c = container();
        listen(c);
        async.flushMicrotasks();
        clearInteractions(repository);

        c.read(liveProvider(competitionId).notifier).refresh();
        async.flushMicrotasks();
        verifyNever(() => repository.getProgramme(any()));

        pending[0].complete(answer([11, 12]));
        async.flushMicrotasks();
        pending[1].complete(answer([21, 22]));
        async.flushMicrotasks();
        verify(() => repository.getProgramme(competitionId)).called(1);

        c.dispose();
      });
    });

    test('page fermée pendant la lecture des places : la suite n\'est pas '
        'lue', () {
      fakeAsync((async) {
        final c = container();
        final subscription = listen(c);
        async.flushMicrotasks();

        subscription.close();
        async.elapse(Duration.zero);
        expect(c.exists(liveProvider(competitionId)), isFalse);

        pending[0].complete(answer([11, 12]));
        async.flushMicrotasks();
        expect(laneRequests, [
          {11, 12},
        ]);

        c.dispose();
      });
    });
  });

  test('relu toutes les 60 s', () {
    fakeAsync((async) {
      final c = container();
      listen(c);
      async.flushMicrotasks();
      clearInteractions(repository);

      async.elapse(liveRefresh - const Duration(seconds: 1));
      async.flushMicrotasks();
      verifyNever(() => repository.getProgramme(any()));

      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();
      verify(() => repository.getProgramme(competitionId)).called(1);

      async.elapse(liveRefresh);
      async.flushMicrotasks();
      verify(() => repository.getProgramme(competitionId)).called(1);

      c.dispose();
    });
  });

  test('plus personne n\'écoute : la minuterie s\'arrête', () {
    fakeAsync((async) {
      final c = container();
      final subscription = listen(c);
      async.flushMicrotasks();
      clearInteractions(repository);

      subscription.close();
      async.flushMicrotasks();
      async.elapse(liveRefresh * 3);
      async.flushMicrotasks();

      verifyNever(() => repository.getProgramme(any()));
      verifyNever(() => repository.getLanes(any()));

      c.dispose();
    });
  });

  test('une course validée n\'est pas relue au tour suivant, mais l\'est par '
      'refresh, avec sa nouvelle valeur', () {
    fakeAsync((async) {
      final c = container();
      listen(c);
      async.flushMicrotasks();

      // Le juge principal corrige la course validée.
      lanes[21] = lane(21, 1, 'Chloé corrigée');
      laneRequests.clear();
      async.elapse(liveRefresh);
      async.flushMicrotasks();

      expect(laneRequests, [
        {11, 12},
      ]);
      expect(view(c).lanesOf(heats[1]).single.athletes.single, 'Chloé');

      laneRequests.clear();
      c.read(liveProvider(competitionId).notifier).refresh();
      async.flushMicrotasks();

      expect(laneRequests, [
        {11, 12, 21, 22},
      ]);
      expect(
        view(c).lanesOf(heats[1]).single.athletes.single,
        'Chloé corrigée',
      );

      c.dispose();
    });
  });

  test('au tour de minuterie, seules les places des séries en cours sont '
      'relues : une dernière série temporaire ne l\'est pas', () {
    fakeAsync((async) {
      heats = defaultHeats(secondProvisional: true);
      final c = container();
      listen(c);
      async.flushMicrotasks();

      lanes[21] = lane(21, 1, 'Chloé corrigée');
      for (var i = 0; i < 2; i++) {
        laneRequests.clear();
        async.elapse(liveRefresh);
        async.flushMicrotasks();
        expect(laneRequests, [
          {11, 12},
        ]);
      }
      expect(view(c).lanesOf(heats[1]).single.athletes.single, 'Chloé');

      c.dispose();
    });
  });

  test('une série qui vient de se terminer est relue une fois au tour '
      'suivant, puis plus du tout', () {
    fakeAsync((async) {
      final c = container();
      listen(c);
      async.flushMicrotasks();

      heats = [
        heats[0].copyWith(status: RunStatus.finished),
        heats[1],
        heats[2],
      ];
      lanes[11] = lane(11, 2, 'Alice finale');
      laneRequests.clear();
      async.elapse(liveRefresh);
      async.flushMicrotasks();
      expect(laneRequests, [
        {11, 12},
      ]);
      expect(view(c).running, isEmpty);
      expect(view(c).lanesOf(heats[0]).map((l) => l.athletes.single), [
        'Bea',
        'Alice finale',
      ]);

      laneRequests.clear();
      for (var i = 0; i < 2; i++) {
        async.elapse(liveRefresh);
        async.flushMicrotasks();
      }
      expect(laneRequests, isEmpty);

      c.dispose();
    });
  });

  test('une série affichée dont aucune place n\'a été lue est relue au tour '
      'suivant', () {
    fakeAsync((async) {
      lanes
        ..remove(21)
        ..remove(22);
      final c = container();
      listen(c);
      async.flushMicrotasks();
      expect(view(c).lanesReadFor(heats[1]), isFalse);

      lanes
        ..[21] = lane(21, 1, 'Chloé')
        ..[22] = null;
      laneRequests.clear();
      async.elapse(liveRefresh);
      async.flushMicrotasks();
      expect(laneRequests, [
        {11, 12, 21, 22},
      ]);
      expect(view(c).lanesReadFor(heats[1]), isTrue);
      expect(view(c).lanesOf(heats[1]).single.athletes.single, 'Chloé');

      laneRequests.clear();
      async.elapse(liveRefresh);
      async.flushMicrotasks();
      expect(laneRequests, [
        {11, 12},
      ]);

      c.dispose();
    });
  });

  test('une série qui se termine après un tour en cours est relue une fois '
      'au tour suivant, puis plus du tout', () {
    fakeAsync((async) {
      final c = container();
      listen(c);
      async.flushMicrotasks();

      laneRequests.clear();
      async.elapse(liveRefresh);
      async.flushMicrotasks();
      expect(laneRequests, [
        {11, 12},
      ]);

      heats = [
        heats[0].copyWith(status: RunStatus.finished),
        heats[1],
        heats[2],
      ];
      lanes[11] = lane(11, 2, 'Alice finale');
      laneRequests.clear();
      async.elapse(liveRefresh);
      async.flushMicrotasks();
      expect(laneRequests, [
        {11, 12},
      ]);
      expect(view(c).lanesOf(heats[0]).map((l) => l.athletes.single), [
        'Bea',
        'Alice finale',
      ]);

      laneRequests.clear();
      for (var i = 0; i < 2; i++) {
        async.elapse(liveRefresh);
        async.flushMicrotasks();
      }
      expect(laneRequests, isEmpty);

      c.dispose();
    });
  });

  test(
    'une série validée dont une place a échoué est relue au tour suivant',
    () {
      fakeAsync((async) {
        lanes.remove(22);
        final c = container();
        listen(c);
        async.flushMicrotasks();

        lanes[22] = null;
        laneRequests.clear();
        async.elapse(liveRefresh);
        async.flushMicrotasks();
        expect(laneRequests, [
          {11, 12, 21, 22},
        ]);

        laneRequests.clear();
        async.elapse(liveRefresh);
        async.flushMicrotasks();
        expect(laneRequests, [
          {11, 12},
        ]);

        c.dispose();
      });
    },
  );

  test('une place en échec garde son nageur', () {
    fakeAsync((async) {
      final c = container();
      listen(c);
      async.flushMicrotasks();

      lanes.remove(11);
      lanes[12] = lane(12, 1, 'Bea2');
      async.elapse(liveRefresh);
      async.flushMicrotasks();

      expect(view(c).lanesOf(heats[0]).map((l) => l.athletes.single), [
        'Bea2',
        'Alice',
      ]);

      c.dispose();
    });
  });

  test('programme en échec au rafraîchissement : le Live est gardé', () {
    fakeAsync((async) {
      final c = container();
      listen(c);
      async.flushMicrotasks();

      when(
        () => repository.getProgramme(any()),
      ).thenAnswer((_) async => throw const NetworkException('hors ligne'));
      async.elapse(liveRefresh);
      async.flushMicrotasks();

      final state = c.read(liveProvider(competitionId));
      expect(state.hasValue && state.hasError, isTrue);
      expect(state.value!.running.map((e) => e.heat.id), [1]);

      c.dispose();
    });
  });

  test('premier chargement en échec : la minuterie fait un nouvel essai', () {
    fakeAsync((async) {
      when(
        () => repository.getProgramme(any()),
      ).thenAnswer((_) async => throw const NetworkException('hors ligne'));
      final c = container();
      listen(c);
      async.flushMicrotasks();
      expect(c.read(liveProvider(competitionId)).hasError, isTrue);

      when(
        () => repository.getProgramme(any()),
      ).thenAnswer((_) async => programme());
      async.elapse(liveRefresh);
      async.flushMicrotasks();

      final state = c.read(liveProvider(competitionId));
      expect(state.hasError, isFalse);
      expect(state.value!.running.map((e) => e.heat.id), [1]);

      c.dispose();
    });
  });

  test('refresh après un premier chargement en échec recharge le Live', () {
    fakeAsync((async) {
      when(
        () => repository.getProgramme(any()),
      ).thenAnswer((_) async => throw const NetworkException('hors ligne'));
      final c = container();
      listen(c);
      async.flushMicrotasks();

      when(
        () => repository.getProgramme(any()),
      ).thenAnswer((_) async => programme());
      c.read(liveProvider(competitionId).notifier).refresh();
      async.flushMicrotasks();

      expect(view(c).recent.map((e) => e.heat.id), [2]);

      c.dispose();
    });
  });

  test('un tour ne chevauche pas un refresh en cours', () {
    fakeAsync((async) {
      final c = container();
      listen(c);
      async.flushMicrotasks();
      clearInteractions(repository);

      final pending = Completer<Programme>();
      when(
        () => repository.getProgramme(any()),
      ).thenAnswer((_) => pending.future);
      c.read(liveProvider(competitionId).notifier).refresh();
      async.flushMicrotasks();
      async.elapse(liveRefresh);
      async.flushMicrotasks();
      verify(() => repository.getProgramme(competitionId)).called(1);

      pending.complete(programme());
      async.flushMicrotasks();
      c.dispose();
    });
  });

  test('la page fermée pendant la relecture des places : rien ne casse', () {
    fakeAsync((async) {
      final c = container();
      final subscription = listen(c);
      async.flushMicrotasks();

      final pending = Completer<Map<int, LaneAssignment?>>();
      when(() => repository.getLanes(any())).thenAnswer((_) => pending.future);
      async.elapse(liveRefresh);
      async.flushMicrotasks();

      clearInteractions(repository);
      subscription.close();
      // Riverpod libère un fournisseur `autoDispose` sur un `Timer` nul, pas
      // sur une microtâche.
      async.elapse(Duration.zero);
      expect(c.exists(liveProvider(competitionId)), isFalse);

      pending.complete({21: lane(21, 1, 'Chloé tardive')});
      async.flushMicrotasks();
      async.elapse(liveRefresh * 2);
      async.flushMicrotasks();

      verifyNever(() => repository.getProgramme(any()));
      verifyNever(() => repository.getLanes(any()));
      c.dispose();
    });
  });

  test('la page fermée pendant la relecture du programme : rien ne casse', () {
    fakeAsync((async) {
      final c = container();
      final subscription = listen(c);
      async.flushMicrotasks();

      final pending = Completer<Programme>();
      when(
        () => repository.getProgramme(any()),
      ).thenAnswer((_) => pending.future);
      async.elapse(liveRefresh);
      async.flushMicrotasks();

      clearInteractions(repository);
      subscription.close();
      async.elapse(Duration.zero);
      expect(c.exists(liveProvider(competitionId)), isFalse);

      pending.complete(programme());
      async.flushMicrotasks();

      // Les places ne seraient montrées à personne.
      verifyNever(() => repository.getLanes(any()));
      c.dispose();
    });
  });

  test('une série terminée qui reçoit une nouvelle place n\'est relue que '
      'par refresh', () {
    fakeAsync((async) {
      final c = container();
      listen(c);
      async.flushMicrotasks();

      heats = [
        heats[0],
        heats[1].copyWith(placeIds: [21, 22, 23]),
        heats[2],
      ];
      lanes[23] = lane(23, 3, 'Emma');
      laneRequests.clear();
      async.elapse(liveRefresh);
      async.flushMicrotasks();
      expect(laneRequests, [
        {11, 12},
      ]);

      laneRequests.clear();
      c.read(liveProvider(competitionId).notifier).refresh();
      async.flushMicrotasks();
      expect(laneRequests, [
        {11, 12, 21, 22, 23},
      ]);
      expect(view(c).lanesOf(heats[1]).map((l) => l.athletes.single), [
        'Chloé',
        'Emma',
      ]);

      c.dispose();
    });
  });

  test('une course sortie du Live puis revenue est relue', () {
    fakeAsync((async) {
      final c = container();
      listen(c);
      async.flushMicrotasks();

      final validated = heats[1];
      heats = [
        heats[0],
        validated.copyWith(status: RunStatus.waiting),
        heats[2],
      ];
      laneRequests.clear();
      async.elapse(liveRefresh);
      async.flushMicrotasks();
      expect(laneRequests, [
        {11, 12},
      ]);
      expect(view(c).recent, isEmpty);
      expect(view(c).lanes.keys, isNot(contains(21)));

      heats = [heats[0], validated, heats[2]];
      lanes[21] = lane(21, 1, 'Chloé 2');
      laneRequests.clear();
      async.elapse(liveRefresh);
      async.flushMicrotasks();

      expect(laneRequests, [
        {11, 12, 21, 22},
      ]);
      expect(view(c).lanesOf(validated).single.athletes.single, 'Chloé 2');

      c.dispose();
    });
  });

  test(
    'refresh en attente derrière la minuterie, page fermée : sans erreur',
    () {
      fakeAsync((async) {
        final c = container();
        listen(c);
        async.flushMicrotasks();

        final pending = Completer<Programme>();
        when(
          () => repository.getProgramme(any()),
        ).thenAnswer((_) => pending.future);
        async.elapse(liveRefresh);
        async.flushMicrotasks();

        var completed = false;
        Object? failure;
        c
            .read(liveProvider(competitionId).notifier)
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
        pending.complete(programme());
        async.flushMicrotasks();

        expect(failure, isNull);
        expect(completed, isTrue);
      });
    },
  );

  test('page fermée pendant le premier chargement : sans erreur', () {
    fakeAsync((async) {
      final pending = Completer<Programme>();
      when(
        () => repository.getProgramme(any()),
      ).thenAnswer((_) => pending.future);
      final c = container();
      listen(c);
      async.flushMicrotasks();

      c.dispose();
      pending.complete(programme());
      async.flushMicrotasks();
      async.elapse(liveRefresh);
      verifyNever(() => repository.getLanes(any()));
    });
  });
}
