import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/run_status.dart';

Heat heat(RunStatus status) =>
    Heat(id: status.index, name: 'Série', number: 1, status: status);

MeetingItem item(
  int id, {
  DateTime? start,
  DateTime? end,
  List<Heat> heats = const [],
}) => MeetingItem(
  id: id,
  name: 'C$id',
  startTime: start,
  endTime: end,
  heats: heats,
);

void main() {
  final day = DateTime(2026, 3, 27);
  DateTime at(int h, int m) => DateTime(2026, 3, 27, h, m);

  group('itemDuration', () {
    test('fin prévue moins début prévu', () {
      expect(
        itemDuration(item(1, start: at(8, 0), end: at(8, 40))),
        const Duration(minutes: 40),
      );
    });

    test('sans début ou sans fin : inconnue', () {
      expect(itemDuration(item(1, start: at(8, 0))), isNull);
      expect(itemDuration(item(1, end: at(8, 40))), isNull);
    });

    test('fin avant le début : inconnue plutôt que négative', () {
      expect(itemDuration(item(1, start: at(9, 0), end: at(8, 0))), isNull);
    });
  });

  group('meetingFinished', () {
    Meeting meeting(List<MeetingItem> items, {DateTime? end}) =>
        Meeting(id: 1, name: 'R', day: day, endTime: end, items: items);

    test('toutes les épreuves terminées : terminée', () {
      final m = meeting([
        item(1),
        item(2, heats: [heat(RunStatus.finished)]),
        item(3, heats: [heat(RunStatus.finished), heat(RunStatus.finished)]),
      ], end: at(18, 0));

      expect(meetingFinished(m, at(10, 0)), isTrue);
    });

    test('une épreuve pas terminée et l\'heure de fin pas passée : non', () {
      final m = meeting([
        item(2, heats: [heat(RunStatus.finished)]),
        item(3, heats: [heat(RunStatus.waiting)]),
      ], end: at(18, 0));

      expect(meetingFinished(m, at(10, 0)), isFalse);
    });

    test(
      'heure de fin passée : terminée, même avec des courses en attente',
      () {
        final m = meeting([
          item(3, heats: [heat(RunStatus.waiting)]),
        ], end: at(13, 45));

        expect(meetingFinished(m, at(13, 46)), isTrue);
      },
    );

    test('aucune épreuve et heure de fin inconnue : non', () {
      expect(meetingFinished(meeting([item(1)]), at(23, 0)), isFalse);
    });
  });

  test('meetingSummary compte créneaux et épreuves', () {
    final m = Meeting(
      id: 1,
      name: 'R',
      day: day,
      items: [
        item(1),
        item(2, heats: [heat(RunStatus.waiting)]),
        item(3, heats: [heat(RunStatus.finished)]),
      ],
    );

    expect(meetingSummary(m), (items: 3, events: 2));
  });
}
