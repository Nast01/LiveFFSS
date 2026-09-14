import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';
import 'package:live_ffss/app/domain/models/run.dart';
import 'package:live_ffss/app/domain/models/slot.dart';
import 'package:live_ffss/app/presentation/modules/programme/day_sections.dart';

DateTime hm(int h, int m) => DateTime(1970, 1, 1, h, m);

Run run(int id, String label, int bh, int bm, int eh, int em) => Run(
      id: id,
      name: 'c$id',
      label: label,
      fullLabel: label,
      status: RunStatus.waiting,
      statusLabel: '',
      site: 'Plage',
      beginTime: hm(bh, bm),
      endTime: hm(eh, em),
    );

Slot slot(int id, String name, int bh, int bm, int eh, int em,
        {List<Run> runs = const []}) =>
    Slot(
      id: id,
      name: name,
      beginHour: hm(bh, bm),
      endHour: hm(eh, em),
      runs: runs,
    );

Meeting meeting(List<Slot> slots) => Meeting(
      id: 1,
      name: 'Matin',
      description: 'Plage',
      date: DateTime(2026, 9, 12),
      beginHour: DateTime(2026, 9, 12, 8),
      endHour: DateTime(2026, 9, 12, 9),
      slots: slots,
    );

void main() {
  test('a null réunion has no item', () {
    expect(meetingItems(null), isEmpty);
  });

  test('a manual créneau is one item with no course', () {
    final items = meetingItems(meeting([slot(1, 'Accueil', 8, 0, 8, 10)]));

    expect(items.single.slotId, 1);
    expect(items.single.label, 'Accueil');
    expect(items.single.courses, isEmpty);
  });

  test('a round créneau carries its courses in running order', () {
    final items = meetingItems(meeting([
      slot(1, 'Séries', 8, 0, 8, 20, runs: [
        run(12, 'Série 2', 8, 10, 8, 20),
        run(11, 'Série 1', 8, 0, 8, 10),
      ]),
    ]));

    expect(items.single.courses.map((c) => c.runId), [11, 12]);
    expect(items.single.courses.first.label, 'Série 1');
  });

  test('items are ordered by their own start', () {
    final items = meetingItems(meeting([
      slot(2, 'Pause', 10, 0, 10, 30),
      slot(1, 'Accueil', 8, 0, 8, 10),
    ]));

    expect(items.map((i) => i.slotId), [1, 2]);
  });

  test('a course entry carries its own times, not its créneau\'s', () {
    final items = meetingItems(meeting([
      slot(1, 'Séries', 8, 0, 9, 0, runs: [run(11, 'Série 1', 8, 0, 8, 10)]),
    ]));

    expect(items.single.courses.single.begin, hm(8, 0));
    expect(items.single.courses.single.end, hm(8, 10));
  });
}
