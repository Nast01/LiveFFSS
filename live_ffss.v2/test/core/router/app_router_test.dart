import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
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

    test("les pages de l'espace officiel et sa saisie, sous Mon espace", () {
      expect(
        Routes.mySpaceHeatsToEnter(1416),
        '/espace/competition/1416/officiel/a-saisir',
      );
      expect(
        Routes.mySpaceDecisions(1416),
        '/espace/competition/1416/officiel/dq-forfaits',
      );
      expect(
        Routes.itemEntry(Routes.mySpace, 1416, 7, heatId: 3),
        '/espace/competition/1416/creneau/7/saisie?serie=3',
      );
      // Un créneau illisible sous Mon espace y retombe.
      expect(
        itemRedirect({'competitionId': '1416', 'itemId': 'x'}, Routes.mySpace),
        Routes.mySpace,
      );
    });

    test('le routeur sert ces pages et retombe sur Mon espace', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final router = container.read(routerProvider);
      for (final (location, page) in [
        (Routes.mySpaceOfficial(1416), 'competition/:competitionId/officiel'),
        (
          Routes.mySpaceHeatsToEnter(1416),
          'competition/:competitionId/officiel/a-saisir',
        ),
        (
          Routes.mySpaceDecisions(1416),
          'competition/:competitionId/officiel/dq-forfaits',
        ),
        (Routes.itemEntry(Routes.mySpace, 1416, 7, heatId: 3), 'saisie'),
      ]) {
        final match = router.configuration.findMatch(Uri.parse(location));
        expect(match.isError, isFalse, reason: location);
        expect(match.matches.first.route, isA<StatefulShellRoute>());
        final leaf = match.last.route;
        expect(leaf.path, page, reason: location);
      }
      final entry = router.configuration.findMatch(
        Uri.parse(Routes.itemEntry(Routes.mySpace, 1416, 7)),
      );
      final item = entry.matches
          .expand((m) => m is ShellRouteMatch ? m.matches : [m])
          .map((m) => m.route)
          .whereType<GoRoute>()
          .firstWhere(
            (r) => r.path == 'competition/:competitionId/creneau/:itemId',
          );
      expect(item.redirect, isNotNull);
      for (final location in [
        '/espace/competition/x/officiel',
        '/espace/competition/x/officiel/a-saisir',
        '/espace/competition/x/officiel/dq-forfaits',
      ]) {
        final match = router.configuration.findMatch(Uri.parse(location));
        final leaf = match.last.route;
        expect(
          mySpaceRedirect({'competitionId': 'x'}),
          Routes.mySpace,
          reason: location,
        );
        expect(leaf.redirect, isNotNull, reason: location);
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
  group("routes de l'espace admin", () {
    test('sous Mon espace', () {
      expect(Routes.admin, '/espace/admin');
      expect(Routes.adminNetworkLog, '/espace/admin/journal');
      expect(
        Routes.adminDecisions(1416),
        '/espace/admin/competition/1416/dq-forfaits',
      );
      expect(Routes.adminClubs(1416), '/espace/admin/competition/1416/clubs');
      expect(
        Routes.mySpaceClub(1416, 15, forfeits: true),
        '/espace/competition/1416/club/15?onglet=forfaits',
      );
    });

    test('le routeur sert ces pages sous la branche Mon espace', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final router = container.read(routerProvider);
      for (final (location, page) in [
        (Routes.admin, 'admin'),
        (Routes.adminNetworkLog, 'journal'),
        (Routes.adminDecisions(1416), 'competition/:competitionId/dq-forfaits'),
        (Routes.adminClubs(1416), 'competition/:competitionId/clubs'),
        (
          Routes.mySpaceClub(1416, 15, forfeits: true),
          'competition/:competitionId/club/:clubId',
        ),
      ]) {
        final match = router.configuration.findMatch(Uri.parse(location));
        expect(match.isError, isFalse, reason: location);
        expect(match.matches.first.route, isA<StatefulShellRoute>());
        expect(match.last.route.path, page, reason: location);
      }
      for (final location in [
        '/espace/admin/competition/x/dq-forfaits',
        '/espace/admin/competition/x/clubs',
      ]) {
        final match = router.configuration.findMatch(Uri.parse(location));
        expect(match.last.route.redirect, isNotNull, reason: location);
      }
    });

    test("un lien admin illisible retombe sur l'espace admin", () {
      expect(adminRedirect({'competitionId': '1416'}), isNull);
      expect(adminRedirect({'competitionId': 'x'}), Routes.admin);
      expect(adminRedirect({}), Routes.admin);
    });

    test("l'espace d'un club s'ouvre sur ses forfaits à la demande", () {
      expect(clubOpensOnForfeits({'onglet': 'forfaits'}), isTrue);
      expect(clubOpensOnForfeits({}), isFalse);
      expect(clubOpensOnForfeits({'onglet': 'planning'}), isFalse);
    });
  });
}
