import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/now_running.dart';
import 'package:live_ffss_v2/domain/run_status.dart';

Heat heat(
  int id, {
  required int number,
  required RunStatus status,
  required String at,
  int raceId = 1,
}) {
  final parts = at.split(':');
  return Heat(
    id: id,
    name: 'Série $number',
    number: number,
    status: status,
    plannedStart: DateTime(
      2026,
      3,
      27,
      int.parse(parts[0]),
      int.parse(parts[1]),
    ),
    raceId: raceId,
    raceName: '200 m Obstacles',
  );
}

Meeting meeting(List<MeetingItem> items) => Meeting(
  id: 1,
  name: 'Eau Plate 1 – Séries',
  day: DateTime(2026, 3, 27),
  items: items,
);

void main() {
  test('programme vide : rien à afficher', () {
    expect(nowRunning(const []), isNull);
    expect(nowRunning([meeting(const [])]), isNull);
  });

  test('une série en cours : MAINTENANT, avec son rang dans le tour', () {
    final result = nowRunning([
      meeting([
        MeetingItem(
          id: 10,
          name: '200 m Obstacles D',
          roundId: 100,
          heats: [
            heat(1, number: 1, status: RunStatus.finished, at: '06:45'),
            heat(2, number: 2, status: RunStatus.inProgress, at: '06:48'),
            heat(3, number: 3, status: RunStatus.waiting, at: '06:51'),
          ],
        ),
      ]),
    ]);

    expect(result?.heat.id, 2);
    expect(result?.kind, NowRunningKind.now);
    expect(result?.position, 2);
    expect(result?.total, 3);
  });

  test('plusieurs séries en cours : la dernière partie', () {
    final result = nowRunning([
      meeting([
        MeetingItem(
          id: 10,
          name: 'D',
          roundId: 100,
          heats: [
            heat(1, number: 1, status: RunStatus.inProgress, at: '06:45'),
            heat(2, number: 2, status: RunStatus.inProgress, at: '06:48'),
          ],
        ),
      ]),
    ]);

    expect(result?.heat.id, 2);
  });

  test('aucune série en cours : la prochaine, libellée À SUIVRE', () {
    final result = nowRunning([
      meeting([
        MeetingItem(
          id: 10,
          name: 'D',
          roundId: 100,
          heats: [
            heat(1, number: 1, status: RunStatus.finished, at: '06:45'),
            heat(3, number: 3, status: RunStatus.waiting, at: '06:51'),
            heat(2, number: 2, status: RunStatus.marshalling, at: '06:48'),
          ],
        ),
      ]),
    ]);

    expect(result?.heat.id, 2);
    expect(result?.kind, NowRunningKind.next);
  });

  test('tout est terminé : rien à afficher', () {
    expect(
      nowRunning([
        meeting([
          MeetingItem(
            id: 10,
            name: 'D',
            heats: [
              heat(1, number: 1, status: RunStatus.finished, at: '06:45'),
            ],
          ),
        ]),
      ]),
      isNull,
    );
  });

  test(
    'le rang compte les séries du même tour réparties sur deux créneaux',
    () {
      final result = nowRunning([
        meeting([
          MeetingItem(
            id: 10,
            name: 'D (1)',
            roundId: 100,
            heats: [
              heat(1, number: 1, status: RunStatus.finished, at: '06:45'),
              heat(2, number: 2, status: RunStatus.finished, at: '06:48'),
            ],
          ),
          MeetingItem(
            id: 11,
            name: 'M',
            roundId: 200,
            heats: [
              heat(
                5,
                number: 1,
                status: RunStatus.waiting,
                at: '07:19',
                raceId: 2,
              ),
            ],
          ),
          MeetingItem(
            id: 12,
            name: 'D (2)',
            roundId: 100,
            heats: [
              heat(3, number: 3, status: RunStatus.inProgress, at: '06:51'),
              heat(4, number: 4, status: RunStatus.waiting, at: '06:54'),
            ],
          ),
        ]),
      ]);

      expect(result?.heat.id, 3);
      expect(result?.position, 3);
      expect(result?.total, 4);
    },
  );

  test('sans partie, les séries sont regroupées par créneau', () {
    final result = nowRunning([
      meeting([
        MeetingItem(
          id: 10,
          name: 'A',
          heats: [
            heat(1, number: 1, status: RunStatus.inProgress, at: '06:45'),
          ],
        ),
        MeetingItem(
          id: 11,
          name: 'B',
          heats: [heat(2, number: 2, status: RunStatus.waiting, at: '06:50')],
        ),
      ]),
    ]);

    expect(result?.total, 1);
  });

  test('une série sans heure prévue n\'empêche pas le calcul', () {
    final result = nowRunning([
      meeting([
        MeetingItem(
          id: 10,
          name: 'D',
          roundId: 100,
          heats: [
            const Heat(
              id: 1,
              name: 'Série 1',
              number: 1,
              status: RunStatus.waiting,
            ),
            heat(2, number: 2, status: RunStatus.waiting, at: '06:48'),
          ],
        ),
      ]),
    ]);

    expect(result?.heat.id, 2);
  });
}
