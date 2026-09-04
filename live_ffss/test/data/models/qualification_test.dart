import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/qualification.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';

void main() {
  // « Par course » : chaque course qualifie ses N premiers, quel que soit le
  // niveau des autres. C'est la logique des demies d'une même finale.
  group('par course', () {
    test('prend les N premiers de chaque course', () {
      final qualified = qualifiedEntries(
        rankedByRace: const [
          [101, 102, 103, 104],
          [201, 202, 203],
        ],
        method: 'course',
        spots: 2,
      );

      expect(qualified, [101, 102, 201, 202]);
    });

    test('une course plus courte que le quota donne ce qu elle a', () {
      final qualified = qualifiedEntries(
        rankedByRace: const [
          [101],
          [201, 202, 203],
        ],
        method: 'course',
        spots: 2,
      );

      expect(qualified, [101, 201, 202]);
    });
  });

  // « Par partie » : les N meilleurs du tour, toutes courses confondues. Sans
  // chronos comparables, le seul ordre honnête est le rang — tous les
  // premiers, puis tous les deuxièmes, jusqu'à remplir le quota.
  group('par partie', () {
    test('prend les N meilleurs rangs, courses confondues', () {
      final qualified = qualifiedEntries(
        rankedByRace: const [
          [101, 102, 103],
          [201, 202, 203],
        ],
        method: 'partie',
        spots: 3,
      );

      expect(qualified, [101, 201, 102]);
    });

    test('le quota s arrête net, même au milieu d un rang', () {
      final qualified = qualifiedEntries(
        rankedByRace: const [
          [101, 102],
          [201, 202],
          [301, 302],
        ],
        method: 'partie',
        spots: 4,
      );

      expect(qualified, [101, 201, 301, 102]);
    });

    test('un quota plus large que le plateau prend tout le monde', () {
      final qualified = qualifiedEntries(
        rankedByRace: const [
          [101],
          [201, 202],
        ],
        method: 'partie',
        spots: 99,
      );

      expect(qualified, [101, 201, 202]);
    });
  });

  group('aucune qualification', () {
    test('la logique « N/A » ne qualifie personne', () {
      expect(
        qualifiedEntries(
          rankedByRace: const [
            [101, 102]
          ],
          method: qualificationNone,
          spots: 2,
        ),
        isEmpty,
      );
    });

    // Un tour qui déclare zéro place qualificative est un tour terminal :
    // qualifier quand même inventerait une suite que personne n'a demandée.
    test('zéro place qualificative ne qualifie personne', () {
      expect(
        qualifiedEntries(
          rankedByRace: const [
            [101, 102]
          ],
          method: 'course',
          spots: 0,
        ),
        isEmpty,
      );
    });

    test('une logique inconnue ne qualifie personne plutôt que d inventer', () {
      expect(
        qualifiedEntries(
          rankedByRace: const [
            [101, 102]
          ],
          method: 'au-chrono',
          spots: 2,
        ),
        isEmpty,
      );
    });

    test('sans classement, rien ne sort', () {
      expect(
        qualifiedEntries(rankedByRace: const [], method: 'course', spots: 4),
        isEmpty,
      );
    });
  });
}
