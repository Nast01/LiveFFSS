import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/lane_assignment.dart';
import 'package:live_ffss_v2/domain/manual_timing.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/outbox.dart';
import 'package:live_ffss_v2/domain/race_result.dart';
import 'package:live_ffss_v2/domain/run_status.dart';
import 'package:live_ffss_v2/features/officiel/entry_view.dart';

const _heat = Heat(
  id: 1,
  name: 'Série 1',
  number: 1,
  status: RunStatus.inProgress,
  seriesId: 5,
  placeIds: [11, 12],
);

LaneAssignment _lane(
  int id,
  int number, {
  int? resultId,
  int? entryId,
  Performance? performance,
  bool forfeit = false,
}) => LaneAssignment(
  id: id,
  lane: number,
  athletes: ['Nageur $id'],
  resultId: resultId,
  entryId: entryId ?? id + 100,
  performance: performance,
  forfeit: forfeit,
);

OutboxOperation _op(
  String id, {
  int placeId = 11,
  String account = 'DUPONT Jean',
  OutboxState state = OutboxState.pending,
  ResultChange change = const ResultChange(chronos: [5000, null, null]),
  DateTime? sentAt,
}) => OutboxOperation(
  id: id,
  account: account,
  competitionId: 1416,
  placeId: placeId,
  seriesId: 5,
  entryId: placeId + 100,
  change: change,
  state: state,
  sentAt: sentAt,
);

EntryLane _entry({
  int status = 0,
  List<int?> chronos = const [null, null, null],
  bool editable = true,
}) => EntryLane(
  lane: _lane(11, 1),
  result: RaceResult(
    seriesId: 5,
    entryId: 111,
    status: status,
    chronos: chronos,
  ),
  editable: editable,
);

void main() {
  final readAt = DateTime(2026, 10, 18, 10);

  group('pavé', () {
    test('le premier chiffre après le choix du champ remplace', () {
      expect(typeChronoDigit('5012', '4', replace: true), '4');
      expect(typeChronoDigit('4', '3', replace: false), '43');
    });

    test('au plus six chiffres', () {
      expect(typeChronoDigit('123456', '7', replace: false), '123456');
    });

    test('effacer retire le dernier chiffre', () {
      expect(eraseChronoDigit('432'), '43');
      expect(eraseChronoDigit(''), '');
    });

    test('un chrono redonne les chiffres qui le tapent', () {
      expect(chronoDigitsOf(4321), '4321');
      expect(chronoDigitsOf(6234), '10234');
      expect(parseChronoDigits(chronoDigitsOf(6234)), 6234);
      expect(chronoDigitsOf(null), '');
      expect(chronoDigitsOf(0), '');
    });

    test(
      'secondes au-delà de 59 : invalide ; vide ou zéro : pas de chrono',
      () {
        expect(isChronoInvalid('6000'), isTrue);
        expect(isChronoInvalid(''), isFalse);
        expect(chronoValue(''), isNull);
        expect(chronoValue('000'), isNull);
        expect(draftChronos(['4321', '', '6000']), isNull);
        expect(draftChronos(['4321', '', '4400']), [4321, null, 4400]);
      },
    );
  });

  group('brouillon', () {
    test('sans brouillon, les champs montrent les chronos actuels', () {
      final lane = _entry(chronos: [4321, null, 6234]);
      expect(laneDigits(lane, null), ['4321', '', '10234']);
      expect(laneDigits(lane, ['1', '', '']), ['1', '', '']);
    });

    test('non enregistré tant qu\'il change les chronos', () {
      final lane = _entry(chronos: [4321, null, null]);
      expect(hasUnsavedDraft(lane, null), isFalse);
      expect(hasUnsavedDraft(lane, ['4321', '', '']), isFalse);
      expect(hasUnsavedDraft(lane, ['4321', '4400', '']), isTrue);
      expect(hasUnsavedDraft(lane, ['4321', '6000', '']), isTrue);
    });
  });

  group('entryLanes', () {
    List<EntryLane> lanes({
      List<LaneAssignment>? places,
      Map<int, RaceResult> results = const {},
      List<OutboxOperation> queue = const [],
      String? account = 'DUPONT Jean',
    }) => entryLanes(
      heat: _heat,
      lanes: places ?? [_lane(11, 1, resultId: 900)],
      results: results,
      queue: queue,
      account: account,
      readAt: readAt,
    );

    test('le résultat lu dans la série, sinon ce que la place publie', () {
      const read = RaceResult(
        id: 900,
        seriesId: 5,
        entryId: 111,
        chronos: [4321, null, null],
      );
      expect(lanes(results: {111: read}).single.result, read);

      final fromPlace = lanes(
        places: [
          _lane(
            11,
            1,
            resultId: 900,
            performance: const Performance(
              isDisqualified: true,
              disqualificationCode: '12',
            ),
          ),
        ],
      ).single.result;
      expect(fromPlace.id, 900);
      expect(fromPlace.status, statusDisqualified);
      expect(fromPlace.complement, '12');
    });

    test('un temps du juge : lecture seule', () {
      final lane = lanes(
        results: {111: const RaceResult(seriesId: 5, entryId: 111, time: 4500)},
      ).single;
      expect(lane.validatedByJudge, isTrue);
      expect(lane.editable, isFalse);
      expect(laneActions(lane), isEmpty);
    });

    test('sans engagement, rien ne peut partir', () {
      final lane = lanes(
        places: [
          const LaneAssignment(id: 11, lane: 1, athletes: ['A']),
        ],
      ).single;
      expect(lane.editable, isFalse);
    });

    test('une saisie en attente s\'affiche par-dessus le site', () {
      final lane = lanes(
        results: {
          111: const RaceResult(
            seriesId: 5,
            entryId: 111,
            chronos: [4000, 4100, null],
          ),
        },
        queue: [
          _op('a', change: const ResultChange(chronos: [5000, null, null])),
          _op('b', change: const ResultChange(mark: ResultMark.forfeit)),
        ],
      ).single;
      expect(lane.result.chronos, [5000, null, null]);
      expect(lane.result.status, statusForfeit);
      expect(lane.sendState, EntrySendState.pending);
    });

    test('envoyée après la lecture : par-dessus ; avant : déjà lue', () {
      final after = _op(
        'a',
        state: OutboxState.sent,
        sentAt: readAt.add(const Duration(seconds: 1)),
      );
      final before = _op(
        'a',
        state: OutboxState.sent,
        sentAt: readAt.subtract(const Duration(seconds: 1)),
      );
      expect(lanes(queue: [after]).single.result.chronos, [5000, null, null]);
      expect(lanes(queue: [before]).single.result.chronos, [null, null, null]);
      expect(lanes(queue: [before]).single.sendState, EntrySendState.sent);
    });

    test('refusée : pas appliquée, et gardée pour réessayer ou écarter', () {
      final rejected = _op('a', state: OutboxState.rejected);
      final lane = lanes(queue: [rejected]).single;
      expect(lane.result.chronos, [null, null, null]);
      expect(lane.sendState, EntrySendState.rejected);
      expect(lane.rejected, rejected);

      final retyped = lanes(queue: [rejected, _op('b')]).single;
      expect(retyped.sendState, EntrySendState.pending);
      expect(retyped.rejected, rejected);
    });

    test(
      'les saisies d\'un autre compte ou d\'une autre place ne comptent pas',
      () {
        final lane = lanes(
          queue: [
            _op('a', account: 'MARTIN Paul'),
            _op('b', placeId: 12),
          ],
        ).single;
        expect(lane.sendState, EntrySendState.none);
        expect(
          lanes(queue: [_op('a')], account: null).single.sendState,
          EntrySendState.none,
        );
      },
    );
  });

  group('laneActions', () {
    test('OK : DQ ou forfait ; DQ : changer le code ou annuler', () {
      expect(laneActions(_entry()), [
        EntryLaneAction.disqualify,
        EntryLaneAction.forfeit,
      ]);
      expect(laneActions(_entry(status: statusDisqualified)), [
        EntryLaneAction.editDisqualification,
        EntryLaneAction.cancelDisqualification,
      ]);
      expect(laneActions(_entry(status: statusForfeit)), [
        EntryLaneAction.cancelForfeit,
      ]);
      expect(laneActions(_entry(editable: false)), isEmpty);
    });
  });

  group('entryCursor', () {
    Heat heat(int id, {int? seriesId, int number = 1}) => Heat(
      id: id,
      name: 'Série $id',
      number: number,
      status: RunStatus.waiting,
      raceId: 1,
      seriesId: seriesId,
    );
    final meetings = [
      Meeting(
        id: 1,
        name: 'R1',
        day: DateTime(2026, 10, 18),
        items: [
          MeetingItem(
            id: 10,
            name: 'C10',
            roundId: 100,
            heats: [heat(1, seriesId: 1), heat(2, seriesId: 2, number: 2)],
          ),
          MeetingItem(id: 20, name: 'C20', roundId: 200, heats: [heat(3)]),
        ],
      ),
    ];

    test('la série demandée, sa place et ses voisines', () {
      final cursor = entryCursor(meetings, itemId: 10, heatId: 2)!;
      expect(cursor.entry.heat.id, 2);
      expect(cursor.position, (position: 2, total: 2));
      expect(cursor.previous?.heat.id, 1);
      expect(cursor.next, isNull);
    });

    test('sans série demandée : la première saisissable du créneau', () {
      expect(entryCursor(meetings, itemId: 10)!.entry.heat.id, 1);
      expect(entryCursor(meetings, itemId: 10, heatId: 3)!.entry.heat.id, 1);
      expect(entryCursor(meetings, itemId: 20), isNull);
    });
  });

  group('entryFocus', () {
    final first = EntryLane(
      lane: _lane(11, 1),
      result: const RaceResult(seriesId: 5, entryId: 111),
    );
    final third = EntryLane(
      lane: _lane(13, 3),
      result: const RaceResult(seriesId: 5, entryId: 113),
    );

    test('le couloir du filtre, ou son absence de la série', () {
      expect(entryFocus([first, third], filter: 3, openPlaceId: null), (
        mode: EntryMode.lane,
        lane: third,
      ));
      expect(entryFocus([first, third], filter: 2, openPlaceId: 11), (
        mode: EntryMode.emptyLane,
        lane: null,
      ));
    });

    test('« Tous » : la liste, ou le couloir ouvert depuis elle', () {
      expect(entryFocus([first, third], filter: null, openPlaceId: null), (
        mode: EntryMode.list,
        lane: null,
      ));
      expect(entryFocus([first, third], filter: null, openPlaceId: 11), (
        mode: EntryMode.lane,
        lane: first,
      ));
      // Un couloir ouvert dans une autre série : retour à la liste.
      expect(
        entryFocus([first, third], filter: null, openPlaceId: 99).mode,
        EntryMode.list,
      );
    });

    test('le filtre va de 1 au dernier couloir, choix compris', () {
      expect(laneFilterOptions([first, third], null), [1, 2, 3]);
      expect(laneFilterOptions([first], 4), [1, 2, 3, 4]);
    });
  });
}
