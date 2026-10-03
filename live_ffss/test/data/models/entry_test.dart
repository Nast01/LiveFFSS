import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/category.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/entry.dart';

void main() {
  Athlete athlete(int id, {Club? club}) => Athlete(
        id: id,
        licenseeNumber: 'L$id',
        firstName: 'A$id',
        lastName: 'B$id',
        gender: Gender.male,
        year: 2000,
        nationalityCode: '',
        nationality: '',
        isValid: true,
        clubId: 9,
        clubLabel: 'CLUB',
        club: club,
      );

  Entry entry(int id, List<Athlete> athletes) => Entry(
        id: id,
        category: const Category(id: 7, name: 'Junior'),
        status: 1,
        statusLabel: 'Engagé',
        athletes: athletes,
      );

  const nageurs = Club(id: 1, name: 'Les Nageurs');
  const sauveteurs = Club(id: 2, name: 'Les Sauveteurs');

  group('entriesWithClubs', () {
    test('pose le club de chaque athlete present dans l index', () {
      final patched = entriesWithClubs(
        [
          entry(10, [athlete(1), athlete(2)])
        ],
        const {1: nageurs, 2: sauveteurs},
      );

      expect(patched.single.athletes.map((a) => a.club?.name),
          ['Les Nageurs', 'Les Sauveteurs']);
    });

    test('un athlete absent de l index garde ce qu il avait', () {
      final patched = entriesWithClubs(
        [
          entry(10, [athlete(1, club: sauveteurs), athlete(2)])
        ],
        const {},
      );

      expect(patched.single.athletes.first.club, sauveteurs);
      expect(patched.single.athletes.last.club, isNull);
    });

    test('ne touche a rien d autre que le club', () {
      final patched = entriesWithClubs(
        [
          entry(10, [athlete(1)])
        ],
        const {1: nageurs},
      );

      expect(patched.single.id, 10);
      expect(patched.single.category.name, 'Junior');
      expect(patched.single.athletes.single.lastName, 'B1');
      expect(patched.single.athletes.single.clubLabel, 'CLUB');
    });

    test('une liste vide reste vide', () {
      expect(entriesWithClubs(const [], const {1: nageurs}), isEmpty);
    });
  });
}
