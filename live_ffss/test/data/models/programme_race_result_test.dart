import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/course_penalty.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';

void main() {
  group('ProgrammeRace results', () {
    test('a race authored before results carries none', () {
      const race = ProgrammeRace(id: 1, number: 1);

      expect(race.finishOrder, isEmpty);
      expect(race.penalties, isEmpty);
    });

    test('a stored race round-trips its order and its penalties', () {
      const race = ProgrammeRace(
        id: 1,
        number: 1,
        athleteIds: [10, 11, 12],
        finishOrder: [
          [10],
          [11, 12],
        ],
        penalties: [
          CoursePenalty(
            athleteId: 12,
            kind: CoursePenaltyKind.disqualified,
            code: '4.7',
          ),
        ],
      );

      final restored = ProgrammeRace.fromJson(race.toJson());

      expect(restored.finishOrder, [
        [10],
        [11, 12],
      ]);
      expect(restored.penalties.single.athleteId, 12);
      expect(restored.penalties.single.kind, CoursePenaltyKind.disqualified);
      expect(restored.penalties.single.code, '4.7');
    });

    test('an unrecognised penalty kind degrades rather than throwing', () {
      // Forward compatibility with a kind a later build writes.
      final restored = CoursePenalty.fromJson(const {
        'athleteId': 12,
        'kind': 'something_else',
        'code': '',
      });

      expect(restored.kind, CoursePenaltyKind.unknown);
    });
  });
}
