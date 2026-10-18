import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:live_ffss_v2/features/home/all_competitions_page.dart';
import 'package:live_ffss_v2/features/home/home_page.dart';
import 'package:live_ffss_v2/features/live/live_page.dart';
import 'package:live_ffss_v2/features/my_space/my_space_page.dart';
import 'package:live_ffss_v2/features/programme/item_detail_page.dart';
import 'package:live_ffss_v2/features/programme/item_detail_providers.dart';
import 'package:live_ffss_v2/features/programme/programme_page.dart';
import 'package:live_ffss_v2/features/shell/app_shell.dart';
import 'package:live_ffss_v2/features/shell/tab_placeholders.dart';

abstract final class Routes {
  static const home = '/';
  static const allCompetitions = '/competitions';
  static const programme = '/programme';
  static String programmeItem(int competitionId, int itemId) =>
      '$programme/competition/$competitionId/creneau/$itemId';
  static const live = '/live';

  /// Le détail d'un créneau ouvert depuis le Live : dans la branche du Live,
  /// le retour y ramène au lieu de laisser dans l'onglet Programme.
  static String liveItem(int competitionId, int itemId) =>
      '$live/competition/$competitionId/creneau/$itemId';
  static const results = '/resultats';
  static const mySpace = '/espace';
}

/// Le créneau désigné par un lien, ou rien s'il est mal formé : un lien venu
/// d'ailleurs (partagé, tapé) ne doit pas faire planter la page.
ItemKey? programmeItemKey(Map<String, String> pathParameters) {
  final competitionId = int.tryParse(pathParameters['competitionId'] ?? '');
  final itemId = int.tryParse(pathParameters['itemId'] ?? '');
  if (competitionId == null || itemId == null) return null;
  return (competitionId: competitionId, itemId: itemId);
}

/// Un lien de créneau mal formé retombe sur l'onglet qui le porte
/// ([fallback]) ; nul pour un lien lisible.
String? itemRedirect(Map<String, String> pathParameters, String fallback) =>
    programmeItemKey(pathParameters) == null ? fallback : null;

/// Le détail d'un créneau, sous l'onglet qui l'a ouvert.
GoRoute _itemRoute({required String fallback}) => GoRoute(
  path: 'competition/:competitionId/creneau/:itemId',
  redirect: (context, state) => itemRedirect(state.pathParameters, fallback),
  builder: (context, state) {
    final key = programmeItemKey(state.pathParameters)!;
    return ItemDetailPage(competitionId: key.competitionId, itemId: key.itemId);
  },
);

/// Une branche par onglet : chacune garde sa propre pile, donc sa position
/// quand on passe d'un onglet à l'autre.
final routerProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: Routes.home,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (context, state) => const HomePage(),
                routes: [
                  GoRoute(
                    path: 'competitions',
                    builder: (context, state) => const AllCompetitionsPage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.programme,
                builder: (context, state) => const ProgrammePage(),
                routes: [_itemRoute(fallback: Routes.programme)],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.live,
                builder: (context, state) => const LivePage(),
                routes: [_itemRoute(fallback: Routes.live)],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.results,
                builder: (context, state) => const CompetitionTabPlaceholder(
                  tab: CompetitionTab.results,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.mySpace,
                builder: (context, state) => const MySpacePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  ),
);
