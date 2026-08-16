import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/heat_draw.dart';

void main() {
  Athlete athlete(int id, {int clubId = 0}) => Athlete(
        id: id,
        licenseeNumber: 'L$id',
        firstName: 'A$id',
        lastName: 'B$id',
        gender: Gender.female,
        year: 2000,
        nationalityCode: '',
        nationality: '',
        isValid: true,
        clubId: clubId,
      );

  List<Athlete> athletes(int count, {int Function(int)? club}) => [
        for (var i = 1; i <= count; i++) athlete(i, clubId: club?.call(i) ?? 0),
      ];

  List<List<Athlete>> draw(
    List<Athlete> present, {
    int raceCount = 1,
    int seed = 1,
  }) =>
      drawHeats(
        present: present,
        raceCount: raceCount,
        random: Random(seed),
      );

  group('drawHeats sizing', () {
    test('draws exactly the number of heats it is given', () {
      expect(draw(athletes(20), raceCount: 3), hasLength(3));
      expect(draw(athletes(20), raceCount: 5), hasLength(5));
    });

    test('balances the heats rather than filling them to the brim', () {
      // 17 over 3 heats gives 6/6/5, not 8/8/1.
      final sizes = draw(athletes(17), raceCount: 3)
          .map((h) => h.length)
          .toList()
        ..sort();
      expect(sizes, [5, 6, 6]);
    });

    test('heat sizes never differ by more than one', () {
      for (var count = 1; count <= 40; count++) {
        final sizes = draw(athletes(count), raceCount: (count / 8).ceil())
            .map((h) => h.length)
            .toList();
        expect(sizes.reduce(max) - sizes.reduce(min), lessThanOrEqualTo(1),
            reason: 'unbalanced for $count athletes');
      }
    });

    test('places every athlete exactly once', () {
      final drawn =
          draw(athletes(23), raceCount: 3).expand((h) => h).map((a) => a.id);

      expect(drawn.toSet(), hasLength(23));
      expect(drawn, hasLength(23));
    });

    test('no athlete present yields no heat', () {
      expect(draw(const [], raceCount: 3), isEmpty);
    });

    test('a field smaller than one heat still fills a single heat', () {
      expect(draw(athletes(3), raceCount: 1).single, hasLength(3));
    });

    test('a non-positive race count yields no heat', () {
      expect(draw(athletes(5), raceCount: 0), isEmpty);
    });
  });

  group('drawHeats club balancing', () {
    test('spreads a club across the heats instead of grouping it', () {
      // 4 clubs of 6 over 3 heats of 8: each club should land 2 per heat.
      final present = athletes(24, club: (i) => (i - 1) ~/ 6 + 1);

      final heats = draw(present, raceCount: 3);

      for (final heat in heats) {
        final perClub = <int, int>{};
        for (final a in heat) {
          perClub[a.clubId] = (perClub[a.clubId] ?? 0) + 1;
        }
        expect(perClub.values, everyElement(2));
      }
    });

    test('a club larger than the heat count still spreads as evenly as it can',
        () {
      // One club of 10 over 2 heats: 5 and 5.
      final present = athletes(10, club: (_) => 7);

      final heats = draw(present, raceCount: 2);

      expect(heats.map((h) => h.length), [5, 5]);
    });

    test('athletes with no club are not balanced as if they shared one', () {
      // 12 unaffiliated athletes over 3 heats: they must simply spread evenly,
      // not pile into one heat because they all carry clubId 0.
      final heats = draw(athletes(12), raceCount: 3);

      expect(heats.map((h) => h.length), [4, 4, 4]);
    });

    test('mixes affiliated and unaffiliated athletes without losing any', () {
      final present = athletes(11, club: (i) => i.isEven ? 3 : 0);

      final heats = draw(present, raceCount: 3);

      expect(heats.expand((h) => h).map((a) => a.id).toSet(), hasLength(11));
    });
  });

  group('drawHeats randomness', () {
    test('the same seed reproduces the same draw', () {
      final present = athletes(20, club: (i) => i % 4);

      final first = draw(present, raceCount: 3, seed: 42);
      final second = draw(present, raceCount: 3, seed: 42);

      expect(
        first.map((h) => h.map((a) => a.id).toList()),
        second.map((h) => h.map((a) => a.id).toList()),
      );
    });

    test('different seeds give different draws', () {
      final present = athletes(20, club: (i) => i % 4);

      final first = draw(present, raceCount: 3, seed: 1)
          .map((h) => h.map((a) => a.id).toList());
      final second = draw(present, raceCount: 3, seed: 999)
          .map((h) => h.map((a) => a.id).toList());

      expect(first, isNot(second));
    });
  });
}
