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

  ProviderContainer container() => ProviderContainer(
    overrides: [meetingRepositoryProvider.overrideWithValue(repository)],
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

  test('premier chargement : programme puis places des courses du Live', () {
    fakeAsync((async) {
      final c = container();
      listen(c);
      async.flushMicrotasks();

      verify(() => repository.getProgramme(competitionId)).called(1);
      expect(laneRequests, [
        {11, 12, 21, 22},
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

  test('une course redevenue temporaire est relue à chaque tour', () {
    fakeAsync((async) {
      final c = container();
      listen(c);
      async.flushMicrotasks();

      heats = defaultHeats(secondProvisional: true);
      for (var i = 0; i < 2; i++) {
        laneRequests.clear();
        async.elapse(liveRefresh);
        async.flushMicrotasks();
        expect(laneRequests, [
          {11, 12, 21, 22},
        ]);
      }

      // Validée de nouveau : lue une fois à ce tour (déjà fait), puis plus.
      heats = defaultHeats();
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
  });

  test(
    'une course validée dont une place a échoué est relue au tour suivant',
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

  test('la page fermée pendant une relecture : rien ne casse', () {
    fakeAsync((async) {
      final c = container();
      final subscription = listen(c);
      async.flushMicrotasks();

      final pending = Completer<Map<int, LaneAssignment?>>();
      when(() => repository.getLanes(any())).thenAnswer((_) => pending.future);
      async.elapse(liveRefresh);
      async.flushMicrotasks();

      subscription.close();
      async.flushMicrotasks();
      pending.complete(const {});
      async.flushMicrotasks();
      async.elapse(liveRefresh);
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
