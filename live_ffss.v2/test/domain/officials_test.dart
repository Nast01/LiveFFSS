import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/domain/officials.dart';

CompetitionOfficial official(
  int id,
  String name, {
  String level = 'B',
  bool principal = false,
}) => CompetitionOfficial(
  id: id,
  name: name,
  level: level,
  principal: principal,
  days: const [1],
  daysLabel: 'Jour 1',
  club: 'Club',
);

void main() {
  test(
    'juge principal à part et en premier, puis A, B, C, puis les autres',
    () {
      final groups = groupOfficials([
        official(1, 'DURAND Zoe', level: 'C'),
        official(2, 'MARTIN Paul', level: 'A', principal: true),
        official(3, 'BERNARD Lea', level: 'B'),
        official(4, 'DUPONT Jean', level: 'A'),
        official(5, 'PETIT Luc', level: 'Z'),
        official(6, 'ABEL Eve', level: 'D'),
      ]);

      expect(groups.map((g) => g.label), [null, 'A', 'B', 'C', 'D', 'Z']);
      expect(groups.first.officials.map((o) => o.id), [2]);
      expect(groups[1].officials.map((o) => o.id), [4]);
    },
  );

  test(
    'dans un groupe, tri par nom sans tenir compte de la casse ni des accents',
    () {
      final groups = groupOfficials([
        official(1, 'Étienne Zed'),
        official(2, 'ABEL Eve'),
        official(3, 'bernard Lea'),
      ]);

      expect(groups.single.officials.map((o) => o.id), [2, 3, 1]);
    },
  );

  test('code de niveau en minuscule : regroupé avec sa majuscule', () {
    final groups = groupOfficials([
      official(1, 'A Un', level: 'b'),
      official(2, 'B Deux', level: 'B'),
    ]);

    expect(groups.map((g) => g.label), ['B']);
    expect(groups.single.officials, hasLength(2));
  });

  test('niveau vide : dernier groupe, après les codes inconnus', () {
    final groups = groupOfficials([
      official(1, 'ABEL Eve', level: ''),
      official(2, 'PETIT Luc', level: 'Z'),
      official(3, 'DURAND Zoe', level: 'C'),
    ]);

    expect(groups.map((g) => g.label), ['C', 'Z', '']);
  });

  test('même nom : départagés par identifiant', () {
    final groups = groupOfficials([
      official(9, 'DUPONT Jean'),
      official(3, 'DUPONT Jean'),
    ]);

    expect(groups.single.officials.map((o) => o.id), [3, 9]);
  });

  test('aucun officiel : aucun groupe', () {
    expect(groupOfficials(const []), isEmpty);
  });
}
