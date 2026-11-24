import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/domain/heat_results.dart';
import 'package:live_ffss_v2/domain/lane_assignment.dart';
import 'package:live_ffss_v2/domain/manual_timing.dart';
import 'package:live_ffss_v2/domain/race_result.dart';

void main() {
  LaneAssignment lane({Performance? performance, bool? forfeit}) =>
      LaneAssignment(
        id: 11,
        lane: 2,
        athletes: const ['Alice'],
        entryId: 501,
        performance: performance,
        forfeit: forfeit,
      );

  RaceResult result({
    int status = statusOk,
    int? time,
    String complement = '',
    List<int?> chronos = const [null, null, null],
  }) => RaceResult(
    seriesId: 101,
    entryId: 501,
    status: status,
    time: time,
    complement: complement,
    chronos: chronos,
  );

  LaneAssignment completed(LaneAssignment lane, RaceResult result) =>
      withHeatResults([lane], {501: result}).single;

  group('withHeatResults', () {
    test('une DQ saisie dans l\'app se lit sur la série', () {
      final shown = completed(
        lane(),
        result(status: statusDisqualified, complement: ' 12 '),
      );
      expect(shown.performance?.isDisqualified, isTrue);
      expect(shown.performance?.statusLabel, 'DQ');
      expect(shown.performance?.disqualificationCode, '12');
    });

    test('un forfait saisi dans l\'app se lit sur la série', () {
      final shown = completed(
        lane(performance: const Performance(statusLabel: 'OK')),
        result(status: statusForfeit, complement: 'F'),
      );
      expect(shown.forfeit, isTrue);
      expect(shown.performance, isNull);
    });

    test('le temps du juge d\'un résultat non rattaché à la place', () {
      final shown = completed(lane(), result(time: 4486));
      expect(shown.performance?.time, '00\'44"86');
      expect(shown.performance?.timeHundredths, 4486);
    });

    test('un temps illisible ou un statut de repli ne montrent rien', () {
      expect(completed(lane(), result(time: unreadableJudgeTime)), lane());
      expect(completed(lane(), result(status: 3)), lane());
    });

    test('ce que la place dit déjà l\'emporte', () {
      final published = lane(
        performance: const Performance(time: '00\'30"00', timeHundredths: 3000),
      );
      expect(
        completed(published, result(status: statusDisqualified)),
        published,
      );
      final forfeit = lane(forfeit: true);
      expect(completed(forfeit, result(time: 4000)), forfeit);
    });

    test('une place sans engagement ou sans résultat reste telle quelle', () {
      const empty = LaneAssignment(id: 12, lane: 3, athletes: ['Bea']);
      expect(
        withHeatResults(
          [empty, lane()],
          {502: result(status: statusDisqualified)},
        ),
        [empty, lane()],
      );
    });
  });

  test('le temps manuel s\'efface dès que le temps du juge arrive', () {
    final chronos = result(chronos: [3100, 3200, null]);
    expect(
      manualTimesOfLanes(
        withHeatResults([lane()], {501: chronos}),
        chronosOf({501: chronos}),
      )[11]?.hundredths,
      3150,
    );
    final judged = chronos.copyWith(time: 3166);
    expect(
      manualTimesOfLanes(
        withHeatResults([lane()], {501: judged}),
        chronosOf({501: judged}),
      ),
      isEmpty,
    );
  });

  test('ffssTimeLabel : minutes et secondes sur deux chiffres', () {
    expect(ffssTimeLabel(4486), '00\'44"86');
    expect(ffssTimeLabel(12026), '02\'00"26');
    expect(ffssTimeLabel(5), '00\'00"05');
  });
}
