import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/domain/lane_assignment.dart';

LaneAssignment lane(
  int lane, {
  int? time,
  String? status,
  bool disqualified = false,
  bool noResult = false,
}) => LaneAssignment(
  id: 100 + lane,
  lane: lane,
  athletes: ['Nageur $lane'],
  performance: noResult
      ? null
      : Performance(
          timeHundredths: time,
          statusLabel: status,
          isDisqualified: disqualified,
        ),
);

void main() {
  test('la place dans la série, du meilleur temps au moins bon', () {
    final places = heatPlaces([
      lane(1, time: 2768),
      lane(2, time: 1676),
      lane(3, time: 1924),
      lane(4, time: 1843),
    ]);

    expect(places, {102: 1, 104: 2, 103: 3, 101: 4});
  });

  test('ex aequo : même place, la suivante est sautée', () {
    final places = heatPlaces([
      lane(1, time: 1676),
      lane(2, time: 1843),
      lane(3, time: 1843),
      lane(4, time: 1924),
    ]);

    expect(places, {101: 1, 102: 2, 103: 2, 104: 4});
  });

  test('sans temps, disqualifié ou statut anormal : pas de place', () {
    final places = heatPlaces([
      lane(1, time: 1676),
      lane(2),
      lane(3, time: 1500, disqualified: true),
      lane(4, time: 1400, status: 'F'),
      lane(5, noResult: true),
      lane(6, time: 1800, status: 'OK'),
    ]);

    expect(places, {101: 1, 106: 2});
  });

  test('aucun temps publié : aucune place', () {
    expect(heatPlaces([lane(1), lane(2)]), isEmpty);
  });
}
