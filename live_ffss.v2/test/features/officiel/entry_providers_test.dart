import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/repositories/meeting_repository.dart';
import 'package:live_ffss_v2/data/repositories/result_repository.dart';
import 'package:live_ffss_v2/domain/account.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/lane_assignment.dart';
import 'package:live_ffss_v2/domain/manual_timing.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/outbox.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/race_result.dart';
import 'package:live_ffss_v2/domain/run_status.dart';
import 'package:live_ffss_v2/features/auth/competition_roles.dart';
import 'package:live_ffss_v2/features/auth/session.dart';
import 'package:live_ffss_v2/features/officiel/entry_providers.dart';
import 'package:live_ffss_v2/features/officiel/entry_view.dart';
import 'package:live_ffss_v2/features/officiel/outbox_service.dart';
import 'package:live_ffss_v2/features/programme/programme_providers.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/in_memory_local_store.dart';

/// Un stockage qui refuse d'écrire.
class _FailingStore extends InMemoryLocalStore {
  @override
  Future<void> write(String key, String value) async =>
      throw const UnknownException('stockage');
}

class _MockMeetingRepository extends Mock implements MeetingRepository {}

class _MockResultRepository extends Mock implements ResultRepository {}

class _FakeSession extends SessionNotifier {
  _FakeSession(this._account);

  final Account? _account;

  @override
  Future<Account?> build() async => _account;
}

typedef _Added = ({int placeId, int seriesId, int entryId, int? resultId});

/// La file d'envoi sans envoi : ce que la saisie y met, et l'échec voulu.
class _FakeOutbox extends OutboxService {
  final List<({_Added where, ResultChange change})> added = [];
  AppException? failure;
  bool queueOnFailure = true;

  @override
  List<OutboxOperation> build() => const [];

  @override
  Future<void> add({
    required int competitionId,
    required int placeId,
    required int seriesId,
    required int entryId,
    int? resultId,
    required ResultChange change,
  }) async {
    final error = failure;
    if (error is AuthException) throw error;
    added.add((
      where: (
        placeId: placeId,
        seriesId: seriesId,
        entryId: entryId,
        resultId: resultId,
      ),
      change: change,
    ));
    state = enqueue(
      state,
      OutboxOperation(
        id: '${added.length}',
        account: 'DUPONT Jean',
        competitionId: competitionId,
        placeId: placeId,
        seriesId: seriesId,
        entryId: entryId,
        resultId: resultId,
        change: change,
      ),
    );
    if (error != null) throw error;
  }
}

const _competition = 1416;

Heat _heat(int id, {int number = 1, List<int> places = const []}) => Heat(
  id: id,
  name: 'Série $number',
  number: number,
  status: RunStatus.inProgress,
  raceId: 1,
  raceName: '100m',
  seriesId: id * 10,
  placeIds: places,
);

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
          roundId: 100,
          heats: [
            _heat(1, places: [11, 12]),
            _heat(2, number: 2, places: [21]),
            _heat(3, number: 3, places: [31]),
          ],
        ),
      ],
    ),
  ],
);

LaneAssignment _lane(int id, int number) => LaneAssignment(
  id: id,
  lane: number,
  athletes: ['Nageur $id'],
  entryId: id + 100,
  resultId: id + 900,
);

void main() {
  late _MockMeetingRepository meetings;
  late _MockResultRepository results;
  late InMemoryLocalStore local;
  late _FakeOutbox outbox;
  late Map<int, RaceResult> heatResults;
  late DateTime now;

  setUpAll(() => registerFallbackValue(<int>[]));

  setUp(() {
    meetings = _MockMeetingRepository();
    results = _MockResultRepository();
    local = InMemoryLocalStore();
    outbox = _FakeOutbox();
    heatResults = {};
    now = DateTime(2026, 10, 18, 10);
    when(
      () => meetings.getProgramme(_competition),
    ).thenAnswer((_) async => _programme());
    when(() => meetings.getLanes(any())).thenAnswer((invocation) async {
      final ids = invocation.positionalArguments.single as Iterable<int>;
      return {for (final id in ids) id: _lane(id, id % 10)};
    });
    when(
      () => results.getHeatResults(any()),
    ).thenAnswer((_) async => heatResults);
  });

  ProviderContainer container({
    Account? account = const Account(label: 'DUPONT Jean'),
    List<Override> overrides = const [],
  }) {
    final c = ProviderContainer(
      overrides: [
        meetingRepositoryProvider.overrideWithValue(meetings),
        resultRepositoryProvider.overrideWithValue(results),
        localStoreProvider.overrideWithValue(local),
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

  const key = (competitionId: _competition, itemId: 7, heatId: 1);
  const heatKey = (competitionId: _competition, heatId: 1);

  /// Les couloirs de la série 1, une fois lus.
  Future<List<EntryLane>> lanesOf(ProviderContainer c) async {
    c.listen(entryLanesProvider(heatKey), (_, _) {});
    c.listen(entryEditorProvider(key), (_, _) {});
    c.listen(entryNavigatorProvider(key), (_, _) {});
    await c.read(entryHeatProvider(heatKey).future);
    return c.read(entryLanesProvider(heatKey)).value!;
  }

  group('entryAccess', () {
    test('en attente des rôles, puis ouverte aux seuls officiels', () async {
      final roles = Completer<List<String>>();
      final c = container(
        overrides: [
          competitionRolesProvider.overrideWith((ref, id) => roles.future),
        ],
      );
      c.listen(entryAccessProvider(_competition), (_, _) {});
      expect(c.read(entryAccessProvider(_competition)), EntryAccess.checking);

      roles.complete(['public', 'officiel']);
      await c.read(competitionRolesProvider(_competition).future);
      expect(c.read(entryAccessProvider(_competition)), EntryAccess.allowed);
    });

    test('une relecture des rôles garde la saisie ouverte', () async {
      var reads = 0;
      final second = Completer<List<String>>();
      final c = container(
        overrides: [
          competitionRolesProvider.overrideWith(
            (ref, id) =>
                ++reads == 1 ? Future.value(['officiel']) : second.future,
          ),
        ],
      );
      c.listen(entryAccessProvider(_competition), (_, _) {});
      await c.read(competitionRolesProvider(_competition).future);
      expect(c.read(entryAccessProvider(_competition)), EntryAccess.allowed);

      c.invalidate(competitionRolesProvider(_competition));
      expect(c.read(entryAccessProvider(_competition)), EntryAccess.allowed);

      second.complete(['public']);
      await c.read(competitionRolesProvider(_competition).future);
      expect(c.read(entryAccessProvider(_competition)), EntryAccess.denied);
    });

    test('un licencié n\'y entre pas', () async {
      final c = container(
        overrides: [
          competitionRolesProvider.overrideWith(
            (ref, id) async => ['public', 'licencie'],
          ),
        ],
      );
      c.listen(entryAccessProvider(_competition), (_, _) {});
      await c.read(competitionRolesProvider(_competition).future);
      expect(c.read(entryAccessProvider(_competition)), EntryAccess.denied);
    });

    test('rôles illisibles sans session : refus, rien à vérifier', () async {
      final c = container(
        account: null,
        overrides: [
          competitionRolesProvider.overrideWith(
            (ref, id) async => throw const NetworkException('hors ligne'),
          ),
        ],
      );
      c.listen(entryAccessProvider(_competition), (_, _) {});
      await expectLater(
        c.read(competitionRolesProvider(_competition).future),
        throwsA(isA<NetworkException>()),
      );
      expect(c.read(entryAccessProvider(_competition)), EntryAccess.denied);
    });

    test('le rafraîchissement de la série relit des rôles en échec', () async {
      var reads = 0;
      final c = container(
        overrides: [
          competitionRolesProvider.overrideWith((ref, id) async {
            if (++reads == 1) throw const NetworkException('hors ligne');
            return ['officiel'];
          }),
        ],
      );
      c.listen(entryAccessProvider(_competition), (_, _) {});
      c.listen(entryHeatProvider(heatKey), (_, _) {});
      await c.read(entryHeatProvider(heatKey).future);
      await expectLater(
        c.read(competitionRolesProvider(_competition).future),
        throwsA(isA<NetworkException>()),
      );
      expect(c.read(entryAccessProvider(_competition)), EntryAccess.unverified);

      await c.read(entryHeatProvider(heatKey).notifier).refresh();
      await c.read(competitionRolesProvider(_competition).future);

      expect(reads, 2);
      expect(c.read(entryAccessProvider(_competition)), EntryAccess.allowed);

      // Des rôles lus ne sont pas relus.
      await c.read(entryHeatProvider(heatKey).notifier).refresh();
      expect(reads, 2);
    });
  });

  group('filtre de couloir', () {
    test('« Tous » par défaut, puis le couloir choisi, gardé sur l\'appareil '
        'par compétition', () async {
      final c = container();
      c.listen(entryLaneFilterProvider(_competition), (_, _) {});
      expect(
        await c.read(entryLaneFilterProvider(_competition).future),
        isNull,
      );

      await c.read(entryLaneFilterProvider(_competition).notifier).select(3);
      expect(local.values['entry_lane_filter_1416'], '3');

      final relaunched = container();
      expect(
        await relaunched.read(entryLaneFilterProvider(_competition).future),
        3,
      );
      expect(
        await relaunched.read(entryLaneFilterProvider(1500).future),
        isNull,
      );
    });

    test(
      'revenir à « Tous » l\'efface ; une valeur illisible vaut « Tous »',
      () async {
        local.values['entry_lane_filter_1416'] = '3';
        final c = container();
        c.listen(entryLaneFilterProvider(_competition), (_, _) {});
        await c.read(entryLaneFilterProvider(_competition).future);
        await c
            .read(entryLaneFilterProvider(_competition).notifier)
            .select(null);
        expect(local.values, isEmpty);

        local.values['entry_lane_filter_1416'] = 'x';
        expect(
          await container().read(entryLaneFilterProvider(_competition).future),
          isNull,
        );
      },
    );
  });

  group('filtre de couloir, stockage en échec', () {
    test('le choix vaut quand même, sans erreur', () async {
      local = _FailingStore();
      final c = container();
      c.listen(entryLaneFilterProvider(_competition), (_, _) {});
      await c.read(entryLaneFilterProvider(_competition).future);

      await c.read(entryLaneFilterProvider(_competition).notifier).select(3);

      expect(c.read(entryLaneFilterProvider(_competition)).value, 3);
    });
  });

  group('navigation', () {
    test('‹ › parcourt les séries ; faux aux bords', () async {
      final c = container();
      c.listen(entryNavigatorProvider(key), (_, _) {});
      await c.read(programmeProvider(_competition).future);
      int? current() =>
          c.read(entryNavigatorProvider(key)).value?.entry.heat.id;
      final editor = c.read(entryEditorProvider(key).notifier);

      expect(current(), 1);
      expect(editor.previousHeat(), isFalse);
      expect(editor.nextHeat(), isTrue);
      expect(editor.nextHeat(), isTrue);
      expect(current(), 3);
      expect(c.read(entryNavigatorProvider(key)).value?.position, (
        position: 3,
        total: 3,
      ));
      expect(editor.nextHeat(), isFalse);
      expect(editor.previousHeat(), isTrue);
      expect(current(), 2);
    });

    test('la série choisie survit à la relecture du programme', () {
      fakeAsync((async) {
        final c = container();
        c.listen(entryNavigatorProvider(key), (_, _) {});
        async.flushMicrotasks();
        c.read(entryEditorProvider(key).notifier).nextHeat();

        async.elapse(const Duration(seconds: 31));
        async.flushMicrotasks();

        verify(() => meetings.getProgramme(_competition)).called(2);
        expect(c.read(entryNavigatorProvider(key)).value?.entry.heat.id, 2);
      });
    });

    test('changer de série remet le pavé au premier chrono', () async {
      final c = container();
      final lanes = await lanesOf(c);
      final editor = c.read(entryEditorProvider(key).notifier)
        ..openLane(11)
        ..selectField(2)
        ..typeDigit(lanes.first, '4');

      editor.nextHeat();

      final state = c.read(entryEditorProvider(key));
      expect(state.field, 0);
      expect(state.replaceNext, isTrue);
      expect(state.openPlaceId, isNull);
    });
  });

  group('série lue', () {
    test('places et résultats ; le temps du juge passe en lecture seule '
        'à la relecture', () {
      fakeAsync((async) {
        heatResults = {
          111: const RaceResult(
            id: 911,
            seriesId: 10,
            entryId: 111,
            chronos: [4321, null, null],
          ),
        };
        final c = container();
        c.listen(entryLanesProvider(heatKey), (_, _) {});
        async.flushMicrotasks();
        verify(() => results.getHeatResults(10)).called(1);
        var lanes = c.read(entryLanesProvider(heatKey)).value!;
        expect([for (final l in lanes) l.lane.lane], [1, 2]);
        expect(lanes.first.result.chronos, [4321, null, null]);
        expect(lanes.first.editable, isTrue);

        heatResults = {
          111: const RaceResult(
            id: 911,
            seriesId: 10,
            entryId: 111,
            time: 4400,
          ),
        };
        async.elapse(entryRefresh);
        async.flushMicrotasks();

        lanes = c.read(entryLanesProvider(heatKey)).value!;
        expect(lanes.first.validatedByJudge, isTrue);
        expect(lanes.first.editable, isFalse);
      });
    });

    test('une relecture en échec garde la série affichée', () {
      fakeAsync((async) {
        final c = container();
        c.listen(entryHeatProvider(heatKey), (_, _) {});
        async.flushMicrotasks();

        when(
          () => results.getHeatResults(any()),
        ).thenThrow(const NetworkException('hors ligne'));
        async.elapse(entryRefresh);
        async.flushMicrotasks();

        final state = c.read(entryHeatProvider(heatKey));
        expect(state.hasError, isTrue);
        expect(state.value?.heat.id, 1);
      });
    });

    test('une série absente du programme : introuvable', () async {
      final c = container();
      const missing = (competitionId: _competition, heatId: 99);
      c.listen(entryHeatProvider(missing), (_, _) {});
      await expectLater(
        c.read(entryHeatProvider(missing).future),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('saisie', () {
    test('les chiffres tapés, le temps manuel en direct', () async {
      final c = container();
      final lane = (await lanesOf(c)).first;
      final editor = c.read(entryEditorProvider(key).notifier);

      for (final d in ['4', '3', '2', '1']) {
        editor.typeDigit(lane, d);
      }
      editor
        ..selectField(1)
        ..typeDigit(lane, '4')
        ..typeDigit(lane, '4')
        ..typeDigit(lane, '0')
        ..typeDigit(lane, '0')
        ..eraseDigit(lane)
        ..typeDigit(lane, '1');

      final digits = c.read(entryEditorProvider(key)).drafts[11]!;
      expect(digits, ['4321', '4401', '']);
      expect(draftManualTime(digits), (
        hundredths: 4361,
        rule: ManualTimeRule.average,
      ));
    });

    test('« Enregistrer et passer » met en file puis passe à la série '
        'suivante, sans attendre le réseau', () async {
      final c = container();
      final lane = (await lanesOf(c)).first;
      final editor = c.read(entryEditorProvider(key).notifier);
      editor
        ..typeDigit(lane, '5')
        ..typeDigit(lane, '0')
        ..typeDigit(lane, '1')
        ..typeDigit(lane, '2');

      final result = await editor.saveAndNext(lane);

      expect(result, (outcome: EntrySaveOutcome.saved, moved: true));
      expect(outbox.added.single.where, (
        placeId: 11,
        seriesId: 10,
        entryId: 111,
        resultId: 911,
      ));
      expect(
        outbox.added.single.change,
        const ResultChange(chronos: [5012, null, null]),
      );
      expect(c.read(entryEditorProvider(key)).drafts, isEmpty);
      expect(c.read(entryNavigatorProvider(key)).value?.entry.heat.id, 2);
      // La saisie en attente s'affiche par-dessus le site.
      final shown = c.read(entryLanesProvider(heatKey)).value!.first;
      expect(shown.result.chronos, [5012, null, null]);
      expect(shown.sendState, EntrySendState.pending);
    });

    test('après un enregistrement sans changer de série, le chiffre suivant '
        'remplace', () async {
      const lastKey = (competitionId: _competition, itemId: 7, heatId: 3);
      const lastHeat = (competitionId: _competition, heatId: 3);
      final c = container();
      c.listen(entryLanesProvider(lastHeat), (_, _) {});
      c.listen(entryEditorProvider(lastKey), (_, _) {});
      c.listen(entryNavigatorProvider(lastKey), (_, _) {});
      await c.read(entryHeatProvider(lastHeat).future);
      var lane = c.read(entryLanesProvider(lastHeat)).value!.single;
      final editor = c.read(entryEditorProvider(lastKey).notifier)
        ..typeDigit(lane, '5')
        ..typeDigit(lane, '0');

      expect(await editor.saveAndNext(lane), (
        outcome: EntrySaveOutcome.saved,
        moved: false,
      ));
      lane = c.read(entryLanesProvider(lastHeat)).value!.single;
      editor.typeDigit(lane, '7');

      expect(c.read(entryEditorProvider(lastKey)).drafts[31], ['7', '', '']);
    });

    test('rien de changé : rien en file, mais on passe', () async {
      final c = container();
      final lane = (await lanesOf(c)).first;

      final result = await c
          .read(entryEditorProvider(key).notifier)
          .saveAndNext(lane);

      expect(result, (outcome: EntrySaveOutcome.unchanged, moved: true));
      expect(outbox.added, isEmpty);
    });

    test('un chrono invalide bloque l\'enregistrement et la série', () async {
      final c = container();
      final lane = (await lanesOf(c)).first;
      final editor = c.read(entryEditorProvider(key).notifier);
      for (final d in ['6', '0', '0', '0']) {
        editor.typeDigit(lane, d);
      }

      final result = await editor.saveAndNext(lane);

      expect(result, (outcome: EntrySaveOutcome.invalid, moved: false));
      expect(outbox.added, isEmpty);
      expect(c.read(entryNavigatorProvider(key)).value?.entry.heat.id, 1);
    });

    test('vider un chrono le met en file vide', () async {
      heatResults = {
        111: const RaceResult(
          id: 911,
          seriesId: 10,
          entryId: 111,
          chronos: [4321, 4400, null],
        ),
      };
      final c = container();
      final lane = (await lanesOf(c)).first;
      final editor = c.read(entryEditorProvider(key).notifier)
        ..selectField(1)
        ..clearField(lane);

      expect(await editor.saveChronos(lane), EntrySaveOutcome.saved);
      expect(
        outbox.added.single.change,
        const ResultChange(chronos: [4321, null, null]),
      );
    });

    test('déconnecté : rien en file, les chiffres restent', () async {
      outbox.failure = const AuthException('non connecté');
      final c = container();
      final lane = (await lanesOf(c)).first;
      final editor = c.read(entryEditorProvider(key).notifier)
        ..typeDigit(lane, '5');

      final result = await editor.saveAndNext(lane);

      expect(result, (outcome: EntrySaveOutcome.notConnected, moved: false));
      expect(c.read(entryEditorProvider(key)).drafts[11], ['5', '', '']);
    });

    test(
      'pas enregistrée sur l\'appareil : en file quand même, on passe',
      () async {
        outbox.failure = const UnknownException('stockage');
        final c = container();
        final lane = (await lanesOf(c)).first;
        final editor = c.read(entryEditorProvider(key).notifier)
          ..typeDigit(lane, '5');

        final result = await editor.saveAndNext(lane);

        expect(result, (outcome: EntrySaveOutcome.notPersisted, moved: true));
        expect(outbox.added, hasLength(1));
        expect(c.read(entryEditorProvider(key)).drafts, isEmpty);
      },
    );

    test('validé par le juge : ni chiffres ni envoi', () async {
      heatResults = {
        111: const RaceResult(id: 911, seriesId: 10, entryId: 111, time: 4400),
      };
      final c = container();
      final lane = (await lanesOf(c)).first;
      final editor = c.read(entryEditorProvider(key).notifier)
        ..typeDigit(lane, '5');

      expect(c.read(entryEditorProvider(key)).drafts, isEmpty);
      expect(await editor.forfeit(lane), EntrySaveOutcome.readOnly);
      expect(outbox.added, isEmpty);
      // Rien à enregistrer : la série suivante quand même.
      expect(await editor.saveAndNext(lane), (
        outcome: EntrySaveOutcome.readOnly,
        moved: true,
      ));
    });

    test('DQ avec son code, forfait, annulation : en file', () async {
      final c = container();
      final lane = (await lanesOf(c)).first;
      final editor = c.read(entryEditorProvider(key).notifier);

      expect(await editor.disqualify(lane, '  '), EntrySaveOutcome.missingCode);
      expect(await editor.disqualify(lane, ' 12 '), EntrySaveOutcome.saved);
      expect(await editor.forfeit(lane), EntrySaveOutcome.saved);
      expect(await editor.cancelMark(lane), EntrySaveOutcome.saved);

      expect(
        [for (final a in outbox.added) a.change],
        [
          const ResultChange(mark: ResultMark.disqualified, code: '12'),
          const ResultChange(mark: ResultMark.forfeit),
          const ResultChange(mark: ResultMark.ok),
        ],
      );
    });

    test('depuis « Tous » : enregistrer ramène à la liste', () async {
      final c = container();
      final lane = (await lanesOf(c)).first;
      final editor = c.read(entryEditorProvider(key).notifier)
        ..openLane(11)
        ..typeDigit(lane, '5');

      expect(await editor.saveAndClose(lane), EntrySaveOutcome.saved);
      expect(c.read(entryEditorProvider(key)).openPlaceId, isNull);
      expect(c.read(entryNavigatorProvider(key)).value?.entry.heat.id, 1);
    });
  });
}
