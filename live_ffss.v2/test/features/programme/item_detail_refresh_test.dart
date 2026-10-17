import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/lane_assignment.dart';
import 'package:live_ffss_v2/domain/run_status.dart';
import 'package:live_ffss_v2/features/programme/item_detail_refresh.dart';

void main() {
  final now = DateTime(2026, 3, 27, 10);

  Heat heat(int id, RunStatus status) =>
      Heat(id: id, name: 'Série $id', number: id, status: status);

  LaneAssignment lane(int id, String athlete) =>
      LaneAssignment(id: id, lane: id, athletes: [athlete]);

  group('heatsToRefresh', () {
    test('une course non terminée est toujours relue', () {
      expect(
        heatsToRefresh(
          [heat(1, RunStatus.inProgress), heat(2, RunStatus.waiting)],
          {},
          now,
        ),
        {1, 2},
      );
    });

    test('une course terminée jamais relue depuis sa fin est relue', () {
      expect(heatsToRefresh([heat(1, RunStatus.finished)], {}, now), {1});
    });

    test('une course terminée relue il y a 1 min ne l\'est pas', () {
      expect(
        heatsToRefresh(
          [heat(1, RunStatus.finished)],
          {1: now.subtract(const Duration(minutes: 1))},
          now,
        ),
        isEmpty,
      );
    });

    test('une course terminée relue il y a 2 min l\'est', () {
      expect(
        heatsToRefresh(
          [heat(1, RunStatus.finished)],
          {1: now.subtract(finishedHeatRefresh)},
          now,
        ),
        {1},
      );
    });
  });

  group('mergeLanes', () {
    test('une place relue prend la nouvelle valeur', () {
      expect(mergeLanes({1: lane(1, 'A')}, {1: lane(1, 'B')}, [1]), {
        1: lane(1, 'B'),
      });
    });

    test('une place en échec garde l\'ancienne valeur', () {
      expect(mergeLanes({1: lane(1, 'A')}, {}, [1]), {1: lane(1, 'A')});
    });

    test('une place devenue vide remplace l\'ancienne valeur', () {
      expect(mergeLanes({1: lane(1, 'A')}, {1: null}, [1]), {1: null});
    });

    test('une place non demandée reste intacte', () {
      expect(
        mergeLanes(
          {1: lane(1, 'A'), 2: lane(2, 'C')},
          {1: lane(1, 'B'), 2: lane(2, 'D')},
          [1],
        ),
        {1: lane(1, 'B'), 2: lane(2, 'C')},
      );
    });
  });
}
