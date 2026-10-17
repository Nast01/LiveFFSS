import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/lane_assignment.dart';
import 'package:live_ffss_v2/domain/live.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/run_status.dart';

Heat heat(
  int id, {
  RunStatus status = RunStatus.finished,
  int? seriesId,
  DateTime? at,
  int number = 1,
  int raceId = 1,
  bool provisional = true,
}) => Heat(
  id: id,
  name: 'Série $id',
  number: number,
  status: status,
  plannedStart: at,
  raceId: raceId,
  seriesId: seriesId,
  resultsProvisional: provisional,
);

Meeting meeting(List<MeetingItem> items, {int id = 1, DateTime? day}) =>
    Meeting(
      id: id,
      name: 'M$id',
      day: day ?? DateTime(2026, 3, 27),
      items: items,
    );

MeetingItem item(int id, List<Heat> heats, {int? roundId}) =>
    MeetingItem(id: id, name: 'C$id', roundId: roundId, heats: heats);

LaneAssignment lane(
  int id,
  int number, {
  Performance? performance,
  bool forfeit = false,
  bool empty = false,
}) => LaneAssignment(
  id: id,
  lane: number,
  athletes: empty ? const [] : ['Nageur $id'],
  forfeit: forfeit,
  performance: performance,
);

Performance time(int hundredths) =>
    Performance(time: '${hundredths / 100}', timeHundredths: hundredths);

void main() {
  group('liveSelection', () {
    test('écarte une série terminée sans série FFSS', () {
      final selection = liveSelection([
        meeting([
          item(1, [
            heat(1, seriesId: null, at: DateTime(2026, 3, 27, 9)),
            heat(2, seriesId: 20, at: DateTime(2026, 3, 27, 9, 5)),
          ]),
        ]),
      ]);

      expect(selection.recent.map((e) => e.heat.id), [2]);
    });

    test('12 séries courues : 10 gardées, la plus récente en premier', () {
      final selection = liveSelection([
        meeting([
          item(1, [
            for (var i = 1; i <= 12; i++)
              heat(i, seriesId: 100 + i, at: DateTime(2026, 3, 27, 8, i)),
          ]),
        ]),
      ]);

      expect(selection.recent, hasLength(liveRecentLimit));
      expect(selection.recent.first.heat.id, 12);
      expect(selection.recent.last.heat.id, 3);
    });

    test('deux séries en cours : par heure croissante', () {
      final selection = liveSelection([
        meeting([
          item(1, [
            heat(
              1,
              status: RunStatus.inProgress,
              at: DateTime(2026, 3, 27, 9, 10),
            ),
            heat(
              2,
              status: RunStatus.marshalling,
              at: DateTime(2026, 3, 27, 9, 5),
            ),
            heat(3, status: RunStatus.waiting, at: DateTime(2026, 3, 27, 9)),
          ]),
        ]),
      ]);

      expect(selection.running.map((e) => e.heat.id), [2, 1]);
      expect(selection.recent, isEmpty);
    });

    test('deux jours : le lendemain 08:00 passe avant la veille 18:00', () {
      final selection = liveSelection([
        meeting(id: 1, [
          item(1, [heat(1, seriesId: 11, at: DateTime(2026, 3, 27, 18))]),
        ]),
        meeting(id: 2, day: DateTime(2026, 3, 28), [
          item(2, [heat(2, seriesId: 12, at: DateTime(2026, 3, 28, 8))]),
        ]),
      ]);

      expect(selection.recent.map((e) => e.heat.id), [2, 1]);
    });

    test('à égalité d\'heure, l\'ordre du programme est inversé', () {
      final at = DateTime(2026, 3, 27, 9);
      final selection = liveSelection([
        meeting([
          item(1, [
            heat(1, seriesId: 11, at: at),
            heat(2, seriesId: 12, at: at),
          ]),
        ]),
      ]);

      expect(selection.recent.map((e) => e.heat.id), [2, 1]);
    });

    test('sans heure, en fin ; l\'heure du créneau sert de repli', () {
      final selection = liveSelection([
        meeting([
          MeetingItem(
            id: 1,
            name: 'A',
            startTime: DateTime(2026, 3, 27, 7),
            heats: [heat(1, seriesId: 11)],
          ),
          item(2, [heat(2, seriesId: 12)]),
          item(3, [heat(3, seriesId: 13, at: DateTime(2026, 3, 27, 6))]),
        ]),
      ]);

      expect(selection.recent.map((e) => e.heat.id), [1, 3, 2]);
      expect(selection.recent.first.start, DateTime(2026, 3, 27, 7));
    });
  });

  group('isProvisional', () {
    test('non terminée : temporaire', () {
      expect(isProvisional(heat(1, status: RunStatus.inProgress)), isTrue);
      expect(
        isProvisional(heat(1, status: RunStatus.waiting, provisional: false)),
        isTrue,
      );
    });

    test('terminée : suit le libellé', () {
      expect(isProvisional(heat(1, provisional: true)), isTrue);
      expect(isProvisional(heat(1, provisional: false)), isFalse);
    });
  });

  group('hasPublishedResults', () {
    test('un temps', () {
      expect(
        hasPublishedResults([lane(1, 1, performance: time(5000))]),
        isTrue,
      );
    });

    test('une DQ', () {
      expect(
        hasPublishedResults([
          lane(1, 1, performance: const Performance(isDisqualified: true)),
        ]),
        isTrue,
      );
    });

    test('un forfait', () {
      expect(hasPublishedResults([lane(1, 1, forfeit: true)]), isTrue);
    });

    test('statut OK sans temps : faux', () {
      expect(
        hasPublishedResults([
          lane(1, 1, performance: const Performance(statusLabel: 'OK')),
          lane(2, 2),
        ]),
        isFalse,
      );
    });
  });

  test('resultOrder : places, ex aequo, puis les autres par couloir', () {
    final ordered = resultOrder([
      lane(1, 1, performance: const Performance(isDisqualified: true)),
      lane(2, 2, performance: time(5100)),
      lane(3, 3),
      lane(4, 4, performance: time(5000)),
      lane(5, 5, empty: true),
      lane(6, 6, performance: time(5100)),
    ]);

    expect(ordered.map((l) => l.id), [4, 2, 6, 1, 3]);
  });

  group('nextScheduled', () {
    test('la première série en attente dans l\'ordre du programme', () {
      final next = nextScheduled([
        meeting([
          item(1, [
            heat(1),
            heat(2, status: RunStatus.waiting),
            heat(3, status: RunStatus.waiting),
          ]),
        ]),
      ]);

      expect(next?.heat.id, 2);
      expect(next?.item.id, 1);
      expect(next?.meeting.id, 1);
    });

    test('aucune : nul', () {
      expect(
        nextScheduled([
          meeting([
            item(1, [heat(1)]),
          ]),
        ]),
        isNull,
      );
    });
  });

  test('heatPosition : rang parmi le même tour sur deux créneaux', () {
    final meetings = [
      meeting([
        item(1, [heat(1, number: 1), heat(2, number: 2)], roundId: 100),
        item(2, [heat(5, number: 1, raceId: 2)], roundId: 200),
        item(3, [heat(3, number: 3), heat(4, number: 4)], roundId: 100),
      ]),
    ];
    final entry = LiveEntry(
      meeting: meetings.first,
      item: meetings.first.items[2],
      heat: meetings.first.items[2].heats.first,
    );

    final position = heatPosition(meetings, entry);

    expect(position.position, 3);
    expect(position.total, 4);
  });
}
