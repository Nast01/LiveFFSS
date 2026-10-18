import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/router/app_router.dart';

void main() {
  group('programmeItemKey', () {
    test('un lien bien formé donne la compétition et le créneau', () {
      expect(programmeItemKey({'competitionId': '1453', 'itemId': '177'}), (
        competitionId: 1453,
        itemId: 177,
      ));
    });

    test('un lien mal formé ne donne rien', () {
      expect(
        programmeItemKey({'competitionId': 'abc', 'itemId': '177'}),
        isNull,
      );
      expect(programmeItemKey({'competitionId': '1453', 'itemId': ''}), isNull);
      expect(programmeItemKey({}), isNull);
    });
  });

  group('Routes.liveItem', () {
    test('le détail d\'un créneau reste dans la branche du Live', () {
      expect(Routes.liveItem(1453, 177), '/live/competition/1453/creneau/177');
      expect(Routes.liveItem(1453, 177), startsWith('${Routes.live}/'));
    });
  });

  group('itemRedirect', () {
    test('un lien bien formé reste où il est', () {
      expect(
        itemRedirect({'competitionId': '1453', 'itemId': '177'}, Routes.live),
        isNull,
      );
    });

    test('un lien mal formé retombe sur l\'onglet qui le porte', () {
      expect(
        itemRedirect({'competitionId': 'abc', 'itemId': '177'}, Routes.live),
        Routes.live,
      );
      expect(itemRedirect({}, Routes.programme), Routes.programme);
    });
  });

  group('Routes.itemEntry', () {
    test("la saisie sous le créneau de l'onglet qui l'ouvre", () {
      expect(
        Routes.itemEntry(Routes.live, 1453, 177, heatId: 9),
        '/live/competition/1453/creneau/177/saisie?serie=9',
      );
      expect(
        Routes.itemEntry(Routes.programme, 1453, 177),
        '/programme/competition/1453/creneau/177/saisie',
      );
    });

    test('la série du lien, ou aucune', () {
      expect(entryHeatId({'serie': '9'}), 9);
      expect(entryHeatId({'serie': 'x'}), isNull);
      expect(entryHeatId({}), isNull);
    });
  });

  group('routes des résultats', () {
    test('recherche et fiche restent dans la branche des résultats', () {
      expect(
        Routes.resultsSearch(1416),
        '/resultats/competition/1416/recherche',
      );
      expect(
        Routes.resultsAthlete(1416, 632821),
        '/resultats/competition/1416/athlete/632821',
      );
      expect(Routes.resultsSearch(1416), startsWith('${Routes.results}/'));
      expect(
        Routes.resultsAthlete(1416, 632821),
        startsWith('${Routes.results}/'),
      );
    });

    test('athleteKey lit la compétition et le participant', () {
      expect(athleteKey({'competitionId': '1416', 'participantId': '632821'}), (
        competitionId: 1416,
        participantId: 632821,
      ));
      expect(
        athleteKey({'competitionId': '1416', 'participantId': 'x'}),
        isNull,
      );
      expect(athleteKey({'participantId': '632821'}), isNull);
    });

    test('un lien de recherche illisible retombe sur les résultats', () {
      expect(searchRedirect({'competitionId': '1416'}), isNull);
      expect(searchRedirect({'competitionId': 'abc'}), Routes.results);
      expect(searchRedirect({}), Routes.results);
    });

    test("un lien de fiche illisible retombe sur les résultats", () {
      expect(
        athleteRedirect({'competitionId': '1416', 'participantId': '632821'}),
        isNull,
      );
      expect(
        athleteRedirect({'competitionId': '1416', 'participantId': ''}),
        Routes.results,
      );
      expect(
        athleteRedirect({'competitionId': 'x', 'participantId': '632821'}),
        Routes.results,
      );
    });

    test(
      'une fiche ailleurs que dans les résultats retombe sur son onglet',
      () {
        expect(
          athleteRedirect({'competitionId': 'x'}, fallback: Routes.mySpace),
          Routes.mySpace,
        );
      },
    );
  });

  group('routes de Mon espace', () {
    test('restent dans la branche Mon espace', () {
      expect(Routes.mySpaceInfos(1416), '/espace/competition/1416/infos');
      expect(
        Routes.mySpaceOfficials(1416),
        '/espace/competition/1416/officiels',
      );
      expect(Routes.mySpaceFollows(1416), '/espace/competition/1416/suivis');
      expect(Routes.mySpaceAthlete(1416), '/espace/competition/1416/athlete');
      expect(Routes.mySpaceClub(1416, 15), '/espace/competition/1416/club/15');
      expect(Routes.mySpaceOfficial(1416), '/espace/competition/1416/officiel');
      expect(
        Routes.mySpaceParticipant(1416, 632821),
        '/espace/competition/1416/fiche/632821',
      );
      for (final route in [
        Routes.mySpaceInfos(1416),
        Routes.mySpaceClub(1416, 15),
        Routes.mySpaceParticipant(1416, 1),
      ]) {
        expect(route, startsWith('${Routes.mySpace}/'));
      }
    });

    test('un lien illisible retombe sur Mon espace', () {
      expect(mySpaceRedirect({'competitionId': '1416'}), isNull);
      expect(mySpaceRedirect({'competitionId': 'abc'}), Routes.mySpace);
      expect(mySpaceRedirect({}), Routes.mySpace);
    });

    test('club : la compétition et le club', () {
      expect(clubKey({'competitionId': '1416', 'clubId': '15'}), (
        competitionId: 1416,
        clubId: 15,
      ));
      expect(clubKey({'competitionId': '1416', 'clubId': 'x'}), isNull);
      expect(clubRedirect({'competitionId': '1416', 'clubId': '15'}), isNull);
      expect(clubRedirect({'competitionId': '1416'}), Routes.mySpace);
    });
  });
}
