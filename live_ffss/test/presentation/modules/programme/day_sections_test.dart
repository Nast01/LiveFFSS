import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';
import 'package:live_ffss/app/domain/models/run.dart';
import 'package:live_ffss/app/domain/models/slot.dart';
import 'package:live_ffss/app/presentation/modules/programme/day_sections.dart';

void main() {
  group('daySections', () {
    // A Slot's/Run's HH:mm is parsed onto 1970-01-01 by the mappers — the day
    // itself lives on Meeting.date. Fixtures mirror that, so a test can never
    // pass on a comparison the real payload would fail.
    DateTime hhmm(String value) {
      final parts = value.split(':');
      return DateTime(1970, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
    }

    Run course(
      int id, {
      required String site,
      required String begin,
      required String end,
      String label = 'Série 1',
    }) =>
        Run(
          id: id,
          name: label,
          label: label,
          fullLabel: label,
          status: RunStatus.waiting,
          statusLabel: '',
          site: site,
          beginTime: hhmm(begin),
          endTime: hhmm(end),
        );

    Slot slot(
      int id, {
      required String name,
      required String begin,
      required String end,
      List<Run> runs = const [],
    }) =>
        Slot(
          id: id,
          name: name,
          beginHour: hhmm(begin),
          endHour: hhmm(end),
          runs: runs,
        );

    Meeting meeting(List<Slot> slots) => Meeting(
          id: 78,
          name: 'Réunion',
          description: '',
          date: DateTime(2026, 9, 12),
          beginHour: DateTime(2026, 9, 12, 8),
          endHour: DateTime(2026, 9, 12, 18),
          slots: slots,
        );

    test('groups courses into one section per site', () {
      final sections = daySections(meeting([
        slot(1, name: 'Séries', begin: '08:00', end: '08:20', runs: [
          course(10, site: 'OCEAN 1', begin: '08:00', end: '08:10'),
          course(11, site: 'OCEAN 2', begin: '08:10', end: '08:20'),
        ]),
      ]));

      expect(sections.map((s) => s.title), ['OCEAN 1', 'OCEAN 2']);
      expect(sections.every((s) => s.items.length == 1), isTrue);
      expect(sections.first.items.single.runId, 10);
    });

    test('puts course-less créneaux in their own untitled manual section', () {
      final sections = daySections(meeting([
        slot(1, name: 'Séries', begin: '08:00', end: '08:10', runs: [
          course(10, site: 'OCEAN 1', begin: '08:00', end: '08:10'),
        ]),
        slot(2, name: 'Pause déjeuner', begin: '12:00', end: '13:00'),
      ]));

      final manual = sections.singleWhere((s) => s.isManual);
      // The title is left to the view: naming this bucket needs a translation,
      // which would tie this pure function to GetX.
      expect(manual.title, isEmpty);
      expect(manual.items.single.label, 'Pause déjeuner');
      expect(manual.items.single.slotId, 2);
      expect(manual.items.single.runId, isNull);
    });

    test('orders sections by their earliest item, not by site name', () {
      // ALPHA is met first in the payload but runs last. Insertion order must
      // not decide the layout, or the day reads out of sequence.
      final sections = daySections(meeting([
        slot(1, name: 'Séries', begin: '08:00', end: '10:00', runs: [
          course(11, site: 'ALPHA', begin: '09:00', end: '09:10'),
          course(10, site: 'ZODIAC', begin: '08:00', end: '08:10'),
        ]),
      ]));

      expect(sections.map((s) => s.title), ['ZODIAC', 'ALPHA']);
    });

    test('orders the items inside a section by start time', () {
      // Two créneaux feeding the same site out of order — FFSS returns
      // créneaux in its own order, which is not the running order.
      final sections = daySections(meeting([
        slot(2, name: 'Finales', begin: '11:00', end: '11:10', runs: [
          course(21, site: 'OCEAN 1', begin: '11:00', end: '11:10'),
        ]),
        slot(1, name: 'Séries', begin: '08:00', end: '08:10', runs: [
          course(20, site: 'OCEAN 1', begin: '08:00', end: '08:10'),
        ]),
      ]));

      expect(sections.single.items.map((i) => i.runId), [20, 21]);
    });

    test('returns nothing when the day has no réunion', () {
      expect(daySections(null), isEmpty);
    });
  });

  group('meetingItems', () {
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
  });
}
