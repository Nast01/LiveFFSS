import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/category.dart';
import 'package:live_ffss/app/domain/models/competitor.dart';
import 'package:live_ffss/app/domain/models/entry.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';

void main() {
  Athlete athlete(int id) => Athlete(
        id: id,
        licenseeNumber: 'L$id',
        firstName: 'A$id',
        lastName: 'B$id',
        gender: Gender.female,
        year: 2000,
        nationalityCode: '',
        nationality: '',
        isValid: true,
      );

  Entry entry(int id, List<int> athleteIds) => Entry(
        id: id,
        category: const Category(id: 1, name: 'Senior'),
        status: 1,
        statusLabel: 'Engagé',
        athletes: [for (final a in athleteIds) athlete(a)],
      );

  group('competitorsOf', () {
    test('rend les engagements dans l ordre des couloirs', () {
      const race = ProgrammeRace(
        id: 7,
        number: 1,
        entryIds: [20, 10],
        athleteIds: [201, 202, 101, 102],
      );

      final competitors = competitorsOf(
        race,
        entries: {
          10: entry(10, [101, 102]),
          20: entry(20, [201, 202])
        },
        athletes: const {},
      );

      expect([for (final c in competitors) c.id], [20, 10]);
      expect(competitors.first.athletes.length, 2);
    });

    test('un engagement que les engages ne portent plus est saute', () {
      const race = ProgrammeRace(id: 7, number: 1, entryIds: [10, 99]);

      final competitors = competitorsOf(
        race,
        entries: {
          10: entry(10, [101])
        },
        athletes: const {},
      );

      expect([for (final c in competitors) c.id], [10]);
    });

    // Un tirage anterieur au champ `entryIds` : chaque athlete devient son
    // propre engagement, et porte son id — ce qui garde lisible le classement
    // deja saisi sur cette course.
    test('sans entryIds, chaque athlete est son propre engagement', () {
      const race = ProgrammeRace(id: 7, number: 1, athleteIds: [101, 102]);

      final competitors = competitorsOf(
        race,
        entries: const {},
        athletes: {101: athlete(101), 102: athlete(102)},
      );

      expect([for (final c in competitors) c.id], [101, 102]);
      expect(competitors.first.athletes.single.id, 101);
    });
  });

  group('isCompetitorOrder', () {
    test('un ordre vide est valide', () {
      expect(
          isCompetitorOrder(const [], [
            entry(10, [101])
          ]),
          isTrue);
    });

    test('un ordre d engagements est reconnu', () {
      expect(
        isCompetitorOrder(const [
          [10],
          [20]
        ], [
          entry(10, [101]),
          entry(20, [201])
        ]),
        isTrue,
      );
    });

    test('un ordre d athletes de relais est rejete', () {
      expect(
        isCompetitorOrder(const [
          [101],
          [102]
        ], [
          entry(10, [101, 102])
        ]),
        isFalse,
      );
    });

    test('un ordre partiellement etranger est rejete en entier', () {
      expect(
        isCompetitorOrder(const [
          [10, 101]
        ], [
          entry(10, [101])
        ]),
        isFalse,
      );
    });
  });
}
