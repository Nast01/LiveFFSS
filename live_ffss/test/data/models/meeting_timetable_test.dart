import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/meeting_timetable.dart';
import 'package:live_ffss/app/domain/models/run.dart';
import 'package:live_ffss/app/domain/models/slot.dart';

/// Les horaires d'un Slot/Run arrivent d'un `HH:mm` nu et atterrissent sur
/// 1970-01-01 — c'est exactement la forme que le mapper produit, donc celle
/// que ces tests doivent utiliser.
DateTime hm(int hour, int minute) => DateTime(1970, 1, 1, hour, minute);

Run run(int id, int beginH, int beginM, int endH, int endM) => Run(
      id: id,
      name: 'c$id',
      label: '',
      fullLabel: '',
      status: RunStatus.waiting,
      statusLabel: '',
      site: 'Plage',
      beginTime: hm(beginH, beginM),
      endTime: hm(endH, endM),
    );

Slot slot(int id, int beginH, int beginM, int endH, int endM,
        {List<Run> runs = const []}) =>
    Slot(
      id: id,
      name: 's$id',
      beginHour: hm(beginH, beginM),
      endHour: hm(endH, endM),
      runs: runs,
    );

void main() {
  group('layOut', () {
    test('an empty réunion ends at its own start', () {
      final table = layOut(const [], 8 * 60);

      expect(table.items, isEmpty);
      expect(table.endMinutes, 8 * 60);
    });

    test('lays manual items back to back from the start, keeping durations',
        () {
      final table = layOut([
        slot(1, 9, 0, 9, 10), // 10 min
        slot(2, 14, 0, 14, 30), // 30 min
      ], 8 * 60);

      expect(table.items[0].beginMinutes, 8 * 60);
      expect(table.items[0].endMinutes, 8 * 60 + 10);
      expect(table.items[1].beginMinutes, 8 * 60 + 10);
      expect(table.items[1].endMinutes, 8 * 60 + 40);
      expect(table.endMinutes, 8 * 60 + 40);
    });

    test(
        'a créneau carrying courses lasts the sum of its courses, not its '
        'own span', () {
      // Étendue propre de 60 min, mais deux courses de 10 : c'est 20 qui
      // compte, sinon la place d'une course supprimée resterait réservée.
      final table = layOut([
        slot(1, 9, 0, 10, 0, runs: [
          run(11, 9, 0, 9, 10),
          run(12, 9, 10, 9, 20),
        ]),
      ], 8 * 60);

      expect(table.items.single.endMinutes, 8 * 60 + 20);
      expect(table.endMinutes, 8 * 60 + 20);
    });

    test('courses ride with their créneau, back to back', () {
      final table = layOut([
        slot(1, 9, 0, 9, 10, runs: [run(11, 9, 0, 9, 10)]),
        slot(2, 10, 0, 10, 30, runs: [
          run(21, 10, 0, 10, 10),
          run(22, 10, 10, 10, 30),
        ]),
      ], 8 * 60);

      expect(table.items[1].runs[0].beginMinutes, 8 * 60 + 10);
      expect(table.items[1].runs[0].endMinutes, 8 * 60 + 20);
      expect(table.items[1].runs[1].beginMinutes, 8 * 60 + 20);
      expect(table.items[1].runs[1].endMinutes, 8 * 60 + 40);
    });

    test('courses are laid in running order, whatever the payload order', () {
      final table = layOut([
        slot(1, 9, 0, 9, 30, runs: [
          run(22, 9, 10, 9, 30), // le plus tardif d'abord
          run(21, 9, 0, 9, 10),
        ]),
      ], 8 * 60);

      expect(table.items.single.runs.map((r) => r.runId), [21, 22]);
    });

    test('the order given is the order laid out — reordering is repacking', () {
      final a = slot(1, 9, 0, 9, 10);
      final b = slot(2, 14, 0, 14, 30);

      final table = layOut([b, a], 8 * 60);

      expect(table.items.map((i) => i.slotId), [2, 1]);
      expect(table.items[0].endMinutes, 8 * 60 + 30);
    });
  });

  group('moves', () {
    test('returns nothing when FFSS already holds the target times', () {
      final slots = [slot(1, 8, 0, 8, 10)];

      expect(moves(slots, layOut(slots, 8 * 60)), isEmpty);
    });

    test('returns only the items whose times changed', () {
      // Le premier est déjà en place ; seul le second a glissé.
      final slots = [
        slot(1, 8, 0, 8, 10),
        slot(2, 9, 0, 9, 30),
      ];

      final result = moves(slots, layOut(slots, 8 * 60));

      expect(result.length, 1);
      expect(result.single.slotId, 2);
      expect(result.single.runId, isNull);
      expect(result.single.beginMinutes, 8 * 60 + 10);
      expect(result.single.endMinutes, 8 * 60 + 40);
    });

    test('reports a moved course separately from its créneau', () {
      final slots = [
        slot(1, 9, 0, 9, 10, runs: [run(11, 9, 0, 9, 10)]),
      ];

      final result = moves(slots, layOut(slots, 8 * 60));

      expect(result.length, 2);
      expect(result[0].slotId, 1);
      expect(result[0].runId, isNull);
      expect(result[1].slotId, 1);
      expect(result[1].runId, 11);
      expect(result[1].beginMinutes, 8 * 60);
    });

    test('a course whose end alone changed is still reported', () {
      // Même début, fin différente : un raccourcissement ne doit pas passer
      // inaperçu.
      final slots = [
        slot(1, 8, 0, 8, 20, runs: [run(11, 8, 0, 8, 20)]),
      ];
      final target = layOut([
        slot(1, 8, 0, 8, 10, runs: [run(11, 8, 0, 8, 10)]),
      ], 8 * 60);

      final result = moves(slots, target);

      expect(result.map((m) => m.runId), containsAll(<int?>[null, 11]));
    });

    test('ignores a target item FFSS does not hold', () {
      final target = layOut([slot(99, 8, 0, 8, 10)], 8 * 60);

      expect(moves(const [], target), isEmpty);
    });
  });

  test('minutesOf ignores the calendar date', () {
    expect(minutesOf(DateTime(1970, 1, 1, 8, 30)), 8 * 60 + 30);
    expect(minutesOf(DateTime(2026, 9, 12, 8, 30)), 8 * 60 + 30);
  });
}
