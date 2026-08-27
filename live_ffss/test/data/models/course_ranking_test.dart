import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/course_ranking.dart';

void main() {
  group('placesOf', () {
    test('nobody has finished, nobody has a place', () {
      expect(placesOf(const []), isEmpty);
    });

    test('numbers a plain order one by one', () {
      expect(
          placesOf(const [
            [10],
            [11],
            [12],
          ]),
          {10: 1, 11: 2, 12: 3});
    });

    test('a tie consumes the places it occupies', () {
      // Two firsts, no second: the next athlete is third.
      expect(
          placesOf(const [
            [10, 11],
            [12],
          ]),
          {10: 1, 11: 1, 12: 3});
    });

    test('a tie of three pushes the next to fourth', () {
      expect(
          placesOf(const [
            [10, 11, 12],
            [13],
          ]),
          {10: 1, 11: 1, 12: 1, 13: 4});
    });
  });

  group('nextPlace', () {
    test('an untouched race starts at one', () {
      expect(nextPlace(const []), 1);
    });

    test('follows the athletes already placed, not the groups', () {
      expect(
          nextPlace(const [
            [10, 11],
          ]),
          3);
    });
  });

  group('withFinisher', () {
    test('appends a new group by default', () {
      expect(
          withFinisher(const [
            [10],
          ], 11, tied: false),
          [
            [10],
            [11],
          ]);
    });

    test('a tie joins the last group instead of opening one', () {
      expect(
          withFinisher(const [
            [10],
          ], 11, tied: true),
          [
            [10, 11],
          ]);
    });

    test('the first finisher opens a group even when tied is set', () {
      // There is nothing to tie to; the lock must not lose the athlete.
      expect(withFinisher(const [], 10, tied: true), [
        [10],
      ]);
    });

    test('an athlete already placed is not placed twice', () {
      expect(
          withFinisher(const [
            [10],
          ], 10, tied: false),
          [
            [10],
          ]);
    });

    test('the no-op path on an already-placed athlete returns a fresh list',
        () {
      // A caller that assigns the result straight back into the RxList it
      // read this from must not have that RxList's value alias itself — which
      // is exactly what handing back the argument unchanged would do.
      const before = [
        [10],
      ];

      final after = withFinisher(before, 10, tied: false);

      expect(identical(after, before), isFalse);
    });
  });

  group('withoutAthlete', () {
    test('removing renumbers everyone after', () {
      final after = withoutAthlete(const [
        [10],
        [11],
        [12],
      ], 11);

      expect(after, [
        [10],
        [12],
      ]);
      expect(placesOf(after), {10: 1, 12: 2});
    });

    test('removing one of a tie leaves the other in place', () {
      final after = withoutAthlete(const [
        [10, 11],
        [12],
      ], 11);

      expect(after, [
        [10],
        [12],
      ]);
      expect(placesOf(after), {10: 1, 12: 2});
    });

    test('an athlete who never finished changes nothing', () {
      expect(
          withoutAthlete(const [
            [10],
          ], 99),
          [
            [10],
          ]);
    });
  });

  group('withoutLastFinisher', () {
    test('takes back the last athlete entered', () {
      expect(
          withoutLastFinisher(const [
            [10],
            [11],
          ]),
          [
            [10],
          ]);
    });

    test('takes back only the last of a tie, keeping the group', () {
      expect(
          withoutLastFinisher(const [
            [10, 11],
          ]),
          [
            [10],
          ]);
    });

    test('an untouched race has nothing to take back', () {
      expect(withoutLastFinisher(const []), isEmpty);
    });

    test('the no-op path on an empty order returns a fresh list', () {
      const before = <List<int>>[];

      final after = withoutLastFinisher(before);

      expect(identical(after, before), isFalse);
    });
  });
}
