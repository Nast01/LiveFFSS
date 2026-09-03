import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/category.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/entry.dart';
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

  /// Un engagement d'un seul athlète — le cas des épreuves individuelles, où
  /// l'id de l'engagement est calqué sur celui de l'athlète pour que les
  /// assertions se lisent d'un coup d'œil.
  Entry entry(int id, {int clubId = 0, int teamSize = 1}) => Entry(
        id: id,
        category: const Category(id: 1, name: 'Cat'),
        status: 1,
        statusLabel: '',
        organisme: clubId > 0 ? Club(id: clubId, name: 'Club $clubId') : null,
        athletes: [
          for (var i = 0; i < teamSize; i++)
            athlete(id * 100 + i, clubId: clubId),
        ],
      );

  List<Entry> entries(int count, {int Function(int)? club}) => [
        for (var i = 1; i <= count; i++) entry(i, clubId: club?.call(i) ?? 0),
      ];

  List<List<Entry>> draw(
    List<Entry> present, {
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
      expect(draw(entries(20), raceCount: 3), hasLength(3));
      expect(draw(entries(20), raceCount: 5), hasLength(5));
    });

    test('balances the heats rather than filling them to the brim', () {
      // 17 over 3 heats gives 6/6/5, not 8/8/1.
      final sizes = draw(entries(17), raceCount: 3)
          .map((h) => h.length)
          .toList()
        ..sort();
      expect(sizes, [5, 6, 6]);
    });

    test('heat sizes never differ by more than one', () {
      for (var count = 1; count <= 40; count++) {
        final sizes = draw(entries(count), raceCount: (count / 8).ceil())
            .map((h) => h.length)
            .toList();
        expect(sizes.reduce(max) - sizes.reduce(min), lessThanOrEqualTo(1),
            reason: 'unbalanced for $count entries');
      }
    });

    test('places every entry exactly once', () {
      final drawn =
          draw(entries(23), raceCount: 3).expand((h) => h).map((e) => e.id);

      expect(drawn.toSet(), hasLength(23));
      expect(drawn, hasLength(23));
    });

    test('no entry present yields no heat', () {
      expect(draw(const [], raceCount: 3), isEmpty);
    });

    test('a field smaller than one heat still fills a single heat', () {
      expect(draw(entries(3), raceCount: 1).single, hasLength(3));
    });

    test('a non-positive race count yields no heat', () {
      expect(draw(entries(5), raceCount: 0), isEmpty);
    });
  });

  group('drawHeats sur les relais', () {
    // Une place FFSS porte un engagement : l'équipe entière tient sur une
    // ligne, comme sur le site fédéral. Tirer athlète par athlète éparpillait
    // une équipe de quatre sur quatre lignes — voire sur plusieurs séries.
    test('une équipe de quatre occupe une seule ligne', () {
      final teams = [
        entry(1, clubId: 1, teamSize: 4),
        entry(2, clubId: 2, teamSize: 4),
        entry(3, clubId: 3, teamSize: 4),
      ];

      final heats = draw(teams, raceCount: 1);

      expect(heats.single, hasLength(3));
      expect(heats.single.map((e) => e.athletes.length), everyElement(4));
    });

    test('les équipes se répartissent comme des concurrents, pas des têtes',
        () {
      // 6 équipes sur 2 séries : 3 et 3, quelle que soit leur taille.
      final teams = [
        for (var i = 1; i <= 6; i++) entry(i, clubId: i, teamSize: 4),
      ];

      final heats = draw(teams, raceCount: 2);

      expect(heats.map((h) => h.length), [3, 3]);
    });
  });

  group('drawHeats club balancing', () {
    test('spreads a club across the heats instead of grouping it', () {
      // 4 clubs of 6 over 3 heats of 8: each club should land 2 per heat.
      final present = entries(24, club: (i) => (i - 1) ~/ 6 + 1);

      final heats = draw(present, raceCount: 3);

      for (final heat in heats) {
        final perClub = <int, int>{};
        for (final e in heat) {
          perClub[entryClubId(e)] = (perClub[entryClubId(e)] ?? 0) + 1;
        }
        expect(perClub.values, everyElement(2));
      }
    });

    test('a club larger than the heat count still spreads as evenly as it can',
        () {
      // One club of 10 over 2 heats: 5 and 5.
      final present = entries(10, club: (_) => 7);

      final heats = draw(present, raceCount: 2);

      expect(heats.map((h) => h.length), [5, 5]);
    });

    test('entries with no club are not balanced as if they shared one', () {
      // 12 unaffiliated entries over 3 heats: they must simply spread evenly,
      // not pile into one heat because they all carry club 0.
      final heats = draw(entries(12), raceCount: 3);

      expect(heats.map((h) => h.length), [4, 4, 4]);
    });

    test('mixes affiliated and unaffiliated entries without losing any', () {
      final present = entries(11, club: (i) => i.isEven ? 3 : 0);

      final heats = draw(present, raceCount: 3);

      expect(heats.expand((h) => h).map((e) => e.id).toSet(), hasLength(11));
    });

    // Le club d'un engagement sans organisme est celui de ses athlètes — le
    // cas des engagements aplatit depuis le club, qui ne portent que clubId.
    test('un engagement sans organisme prend le club de ses athlètes', () {
      final e = Entry(
        id: 1,
        category: const Category(id: 1, name: 'Cat'),
        status: 1,
        statusLabel: '',
        athletes: [athlete(10, clubId: 42)],
      );

      expect(entryClubId(e), 42);
    });
  });

  group('drawHeats randomness', () {
    test('the same seed reproduces the same draw', () {
      final present = entries(20, club: (i) => i % 4);

      final first = draw(present, raceCount: 3, seed: 42);
      final second = draw(present, raceCount: 3, seed: 42);

      expect(
        first.map((h) => h.map((e) => e.id).toList()),
        second.map((h) => h.map((e) => e.id).toList()),
      );
    });

    test('different seeds give different draws', () {
      final present = entries(20, club: (i) => i % 4);

      final first = draw(present, raceCount: 3, seed: 1)
          .map((h) => h.map((e) => e.id).toList());
      final second = draw(present, raceCount: 3, seed: 999)
          .map((h) => h.map((e) => e.id).toList());

      expect(first, isNot(second));
    });
  });
}
