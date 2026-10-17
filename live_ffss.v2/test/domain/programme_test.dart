import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/domain/gender.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/progression.dart';
import 'package:live_ffss_v2/domain/run_status.dart';

const _progression = Progression(
  id: 501,
  name: 'Épreuve',
  disciplineName: '200m Obstacles',
  gender: Gender.female,
  stages: [
    Stage(
      id: 142,
      order: 1,
      level: StageLevel.heats,
      name: 'Séries',
      qualification: QualificationMethod.none,
      heatCount: 2,
      placesPerHeat: 6,
    ),
  ],
);

Meeting _meeting({int? roundId, String raceName = ''}) => Meeting(
  id: 1,
  name: 'R',
  day: DateTime(2026, 3, 27),
  items: [
    MeetingItem(
      id: 10,
      name: 'C',
      roundId: roundId,
      heats: [
        Heat(
          id: 20,
          name: 'Série 1',
          number: 1,
          status: RunStatus.waiting,
          raceName: raceName,
        ),
      ],
    ),
  ],
);

Heat _heat(List<Meeting> meetings) => meetings.single.items.single.heats.single;

void main() {
  test('withRaces donne nom, sexe et épreuve aux courses du déroulement', () {
    final heat = _heat(withRaces([_meeting(roundId: 142)], [_progression]));

    expect(heat.raceName, '200m Obstacles');
    expect(heat.gender, Gender.female);
    expect(heat.raceId, 501);
  });

  test('une course qui a déjà son épreuve la garde', () {
    final heat = _heat(
      withRaces([_meeting(roundId: 142, raceName: '50m')], [_progression]),
    );

    expect(heat.raceName, '50m');
    expect(heat.raceId, isNull);
  });

  test('un créneau sans partie reste sans épreuve', () {
    final heat = _heat(withRaces([_meeting()], [_progression]));

    expect(heat.raceName, '');
    expect(heat.raceId, isNull);
  });

  test('findItem et progressionOfStage', () {
    final programme = Programme(
      meetings: [_meeting(roundId: 142)],
      progressions: const [_progression],
    );

    final found = programme.findItem(10);
    expect(found?.meeting.id, 1);
    expect(found?.item.id, 10);
    expect(programme.findItem(99), isNull);
    expect(programme.progressionOfStage(142)?.id, 501);
    expect(programme.progressionOfStage(1), isNull);
  });
}
