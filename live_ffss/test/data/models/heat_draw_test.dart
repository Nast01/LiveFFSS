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
    int spotsPerRace = 8,
    int seed = 1,
  }) =>
      drawHeats(
        present: present,
        spotsPerRace: spotsPerRace,
        random: Random(seed),
      );

  group('drawHeats sizing', () {
    test('uses ceil(present / spotsPerRace) heats', () {
      expect(draw(athletes(8)), hasLength(1));
      expect(draw(athletes(9)), hasLength(2));
      expect(draw(athletes(24)), hasLength(3));
      expect(draw(athletes(25)), hasLength(4));
    });

    test('balances the heats rather than filling them to the brim', () {
      // 17 over spots of 8 gives 6/6/5, not 8/8/1.
      final sizes = draw(athletes(17)).map((h) => h.length).toList()..sort();
      expect(sizes, [5, 6, 6]);
    });

    test('heat sizes never differ by more than one', () {
      for (var count = 1; count <= 40; count++) {
        final sizes = draw(athletes(count)).map((h) => h.length).toList();
        expect(sizes.reduce(max) - sizes.reduce(min), lessThanOrEqualTo(1),
            reason: 'unbalanced for $count athletes');
      }
    });

    test('places every athlete exactly once', () {
      final drawn = draw(athletes(23)).expand((h) => h).map((a) => a.id);

      expect(drawn.toSet(), hasLength(23));
      expect(drawn, hasLength(23));
    });

    test('no athlete present yields no heat', () {
      expect(draw(const []), isEmpty);
    });

    test('fewer athletes than spots still yields a single heat', () {
      expect(draw(athletes(3)), hasLength(1));
      expect(draw(athletes(3)).single, hasLength(3));
    });

    test('a non-positive spotsPerRace falls back to one heat', () {
      expect(draw(athletes(5), spotsPerRace: 0).single, hasLength(5));
    });
  });

  group('drawHeats club balancing', () {
    test('spreads a club across the heats instead of grouping it', () {
      // 4 clubs of 6 over 3 heats of 8: each club should land 2 per heat.
      final present = athletes(24, club: (i) => (i - 1) ~/ 6 + 1);

      final heats = draw(present, spotsPerRace: 8);

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

      final heats = draw(present, spotsPerRace: 5);

      expect(heats.map((h) => h.length), [5, 5]);
    });

    test('athletes with no club are not balanced as if they shared one', () {
      // 12 unaffiliated athletes over 3 heats: they must simply spread evenly,
      // not pile into one heat because they all carry clubId 0.
      final heats = draw(athletes(12), spotsPerRace: 4);

      expect(heats.map((h) => h.length), [4, 4, 4]);
    });

    test('mixes affiliated and unaffiliated athletes without losing any', () {
      final present = athletes(11, club: (i) => i.isEven ? 3 : 0);

      final heats = draw(present, spotsPerRace: 4);

      expect(heats.expand((h) => h).map((a) => a.id).toSet(), hasLength(11));
    });
  });

  group('drawHeats randomness', () {
    test('the same seed reproduces the same draw', () {
      final present = athletes(20, club: (i) => i % 4);

      final first = draw(present, seed: 42);
      final second = draw(present, seed: 42);

      expect(
        first.map((h) => h.map((a) => a.id).toList()),
        second.map((h) => h.map((a) => a.id).toList()),
      );
    });

    test('different seeds give different draws', () {
      final present = athletes(20, club: (i) => i % 4);

      final first =
          draw(present, seed: 1).map((h) => h.map((a) => a.id).toList());
      final second =
          draw(present, seed: 999).map((h) => h.map((a) => a.id).toList());

      expect(first, isNot(second));
    });
  });
}
