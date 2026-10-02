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

  group('withoutCompetitor', () {
    test('removing renumbers everyone after', () {
      final after = withoutCompetitor(const [
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
      final after = withoutCompetitor(const [
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
          withoutCompetitor(const [
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

  group('withPlace', () {
    // La saisie manuelle : on tape un rang, l'athlète le prend.
    test('place un athlète non classé au rang demandé', () {
      expect(
        withPlace([
          [1],
          [2]
        ], 3, 3),
        [
          [1],
          [2],
          [3]
        ],
      );
    });

    // Partager un numéro, c'est déclarer un ex-aequo — la règle retenue avec
    // l'opérateur, et celle que le mode automatique applique déjà.
    test('un numéro déjà pris forme un ex-aequo', () {
      final order = withPlace([
        [1],
        [2],
        [3]
      ], 3, 2);

      expect(order, [
        [1],
        [2, 3]
      ]);
      expect(placesOf(order), {1: 1, 2: 2, 3: 2});
    });

    test('un athlète déjà classé quitte son ancien rang', () {
      final order = withPlace([
        [1],
        [2],
        [3]
      ], 1, 3);

      // La case qu'il libère reste vide : 2 et 3 gardent les numéros saisis.
      expect(order, [
        <int>[],
        [2],
        [3, 1]
      ]);
      expect(placesOf(order), {2: 2, 3: 3, 1: 3});
    });

    // Ce qui est tapé est ce qui reste : taper 5 pose 5, les cases 3 et 4
    // attendent ceux qui n'ont pas encore été saisis. Le plateau, lui, est
    // borné par l'appelant — le contrôleur ramène 99 au dernier concurrent.
    test('un rang au-delà des classés laisse les cases vides derrière lui', () {
      final order = withPlace([
        [1],
        [2]
      ], 3, 5);

      expect(order, [
        [1],
        [2],
        <int>[],
        <int>[],
        [3]
      ]);
      expect(placesOf(order), {1: 1, 2: 2, 3: 5});
    });

    test('poser une place ne renumérote personne d autre', () {
      final order = withPlace(
        withPlace(withPlace(const [], 1, 1), 2, 5),
        3,
        3,
      );

      expect(placesOf(order), {1: 1, 2: 5, 3: 3});
    });

    test('un rang inférieur à 1 ne change rien', () {
      const order = [
        [1],
        [2]
      ];

      expect(withPlace(order, 3, 0), order);
    });

    // Même garantie que les autres fonctions du fichier : jamais l'argument.
    test('rend toujours une liste neuve, même sans effet', () {
      const order = [
        [1]
      ];

      expect(identical(withPlace(order, 2, 0), order), isFalse);
    });
  });

  group('placesOf sur une grille trouée', () {
    test('une case vide garde son numéro à celui qui suit', () {
      expect(
          placesOf(const [
            [10],
            [],
            [12],
          ]),
          {10: 1, 12: 3});
    });

    test('un ex-aequo consomme toujours les places qu il occupe', () {
      // La case 2 dit « deuxième », l'ex-aequo dit « troisième » : la règle
      // fédérale l'emporte, on ne peut pas être deuxième derrière deux premiers.
      expect(
          placesOf(const [
            [10, 11],
            [12],
          ]),
          {10: 1, 11: 1, 12: 3});
    });
  });

  group('rankingOf', () {
    test('tasse les cases vides pour la fédération', () {
      expect(
          rankingOf(const [
            [10],
            [],
            [12],
          ]),
          {10: 1, 12: 2});
    });

    test('garde la règle de l ex-aequo', () {
      expect(
          rankingOf(const [
            [10, 11],
            [12],
          ]),
          {10: 1, 11: 1, 12: 3});
    });

    test('sur une course sans trou, c est placesOf mot pour mot', () {
      const order = [
        [10, 11],
        [12],
        [13],
      ];

      expect(rankingOf(order), placesOf(order));
    });
  });

  group('withoutPlace', () {
    test('vide la case sans faire remonter les suivants', () {
      final after = withoutPlace(const [
        [10],
        [11],
        [12],
      ], 10);

      expect(after, [
        <int>[],
        [11],
        [12],
      ]);
      expect(placesOf(after), {11: 2, 12: 3});
    });

    test('les cases vides de la fin ne sont pas gardées', () {
      expect(
          withoutPlace(const [
            [10],
            [11],
          ], 11),
          [
            [10],
          ]);
    });

    test('vider une case d un ex-aequo rend sa place à celui qui suit', () {
      // L'ex-aequo ne consomme plus la deuxième place : 12 retrouve le numéro
      // de sa case, celui qui avait été saisi pour lui.
      final after = withoutPlace(const [
        [10, 11],
        [12],
      ], 11);

      expect(placesOf(after), {10: 1, 12: 2});
    });
  });

  group('la grille trouée et les autres fonctions', () {
    test('nextPlace vise le premier trou', () {
      expect(
          nextPlace(const [
            [10],
            [],
            [12],
          ]),
          2);
    });

    test('withFinisher comble le premier trou', () {
      expect(
          withFinisher(const [
            [10],
            [],
            [12],
          ], 11, tied: false),
          [
            [10],
            [11],
            [12],
          ]);
    });

    test('withFinisher se lie au dernier groupe occupé', () {
      expect(
          withFinisher(const [
            [10],
            [],
            [12],
          ], 11, tied: true),
          [
            [10],
            <int>[],
            [12, 11],
          ]);
    });

    test('withoutCompetitor referme sa case et garde les autres trous', () {
      final after = withoutCompetitor(const [
        [10],
        [],
        [12],
        [13],
      ], 12);

      expect(after, [
        [10],
        <int>[],
        [13],
      ]);
      expect(placesOf(after), {10: 1, 13: 3});
    });

    test('withoutLastFinisher reprend le dernier posé, trou ou pas', () {
      expect(
          withoutLastFinisher(const [
            [10],
            [],
            [12],
          ]),
          [
            [10],
          ]);
    });

    test('withoutLastFinisher sur une grille sans personne ne jette pas', () {
      expect(withoutLastFinisher(const [[], []]), isEmpty);
    });
  });
}
