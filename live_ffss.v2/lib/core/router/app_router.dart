import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/features/home/all_competitions_page.dart';
import 'package:live_ffss_v2/features/home/home_page.dart';
import 'package:live_ffss_v2/features/live/live_page.dart';
import 'package:live_ffss_v2/features/my_space/athlete_space_page.dart';
import 'package:live_ffss_v2/features/my_space/club_page.dart';
import 'package:live_ffss_v2/features/my_space/competition_info_page.dart';
import 'package:live_ffss_v2/features/my_space/follows_page.dart';
import 'package:live_ffss_v2/features/my_space/my_space_page.dart';
import 'package:live_ffss_v2/features/my_space/official_space_page.dart';
import 'package:live_ffss_v2/features/my_space/officials_page.dart';
import 'package:live_ffss_v2/features/officiel/entry_page.dart';
import 'package:live_ffss_v2/features/programme/item_detail_page.dart';
import 'package:live_ffss_v2/features/programme/item_detail_providers.dart';
import 'package:live_ffss_v2/features/programme/programme_page.dart';
import 'package:live_ffss_v2/features/results/athlete_page.dart';
import 'package:live_ffss_v2/features/results/athlete_search_page.dart';
import 'package:live_ffss_v2/features/results/results_page.dart';
import 'package:live_ffss_v2/features/settings/start_tab.dart';
import 'package:live_ffss_v2/features/shell/app_shell.dart';

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

  /// La saisie d'un officiel, sous le créneau de l'onglet [branch] qui l'a
  /// ouverte : le retour ramène au créneau. [heatId] : la série à ouvrir,
  /// sinon la première du créneau.
  static String itemEntry(
    String branch,
    int competitionId,
    int itemId, {
    int? heatId,
  }) =>
      '$branch/competition/$competitionId/creneau/$itemId/saisie'
      '${heatId == null ? '' : '?serie=$heatId'}';
  static const results = '/resultats';

  /// La recherche d'un athlète et sa fiche, dans la branche des résultats :
  /// le retour y ramène.
  static String resultsSearch(int competitionId) =>
      '$results/competition/$competitionId/recherche';
  static String resultsAthlete(int competitionId, int participantId) =>
      '$results/competition/$competitionId/athlete/$participantId';
  static const mySpace = '/espace';

  /// Les pages de Mon espace, dans sa branche : le retour y ramène.
  static String _mySpaceOf(int competitionId) =>
      '$mySpace/competition/$competitionId';
  static String mySpaceInfos(int competitionId) =>
      '${_mySpaceOf(competitionId)}/infos';
  static String mySpaceOfficials(int competitionId) =>
      '${_mySpaceOf(competitionId)}/officiels';
  static String mySpaceFollows(int competitionId) =>
      '${_mySpaceOf(competitionId)}/suivis';
  static String mySpaceAthlete(int competitionId) =>
      '${_mySpaceOf(competitionId)}/athlete';
  static String mySpaceClub(int competitionId, int clubId) =>
      '${_mySpaceOf(competitionId)}/club/$clubId';
  static String mySpaceOfficial(int competitionId) =>
      '${_mySpaceOf(competitionId)}/officiel';

  /// Les pages de l'espace officiel lues à la demande.
  static String mySpaceHeatsToEnter(int competitionId) =>
      '${mySpaceOfficial(competitionId)}/a-saisir';
  static String mySpaceDecisions(int competitionId) =>
      '${mySpaceOfficial(competitionId)}/dq-forfaits';

  /// La fiche d'un athlète (lot 5) ouverte depuis Mon espace.
  static String mySpaceParticipant(int competitionId, int participantId) =>
      '${_mySpaceOf(competitionId)}/fiche/$participantId';
}

int? _competitionIdOf(Map<String, String> pathParameters) =>
    int.tryParse(pathParameters['competitionId'] ?? '');

/// L'athlète désigné par un lien, ou rien s'il est mal formé.
({int competitionId, int participantId})? athleteKey(
  Map<String, String> pathParameters,
) {
  final competitionId = _competitionIdOf(pathParameters);
  final participantId = int.tryParse(pathParameters['participantId'] ?? '');
  if (competitionId == null || participantId == null) return null;
  return (competitionId: competitionId, participantId: participantId);
}

/// Un lien de recherche ou de fiche mal formé retombe sur les résultats ; nul
/// pour un lien lisible.
String? searchRedirect(Map<String, String> pathParameters) =>
    _competitionIdOf(pathParameters) == null ? Routes.results : null;

/// [fallback] : l'onglet qui porte la fiche.
String? athleteRedirect(
  Map<String, String> pathParameters, {
  String fallback = Routes.results,
}) => athleteKey(pathParameters) == null ? fallback : null;

/// Un lien de Mon espace mal formé retombe sur Mon espace ; nul pour un lien
/// lisible.
String? mySpaceRedirect(Map<String, String> pathParameters) =>
    _competitionIdOf(pathParameters) == null ? Routes.mySpace : null;

/// Le club désigné par un lien, ou rien s'il est mal formé.
({int competitionId, int clubId})? clubKey(Map<String, String> pathParameters) {
  final competitionId = _competitionIdOf(pathParameters);
  final clubId = int.tryParse(pathParameters['clubId'] ?? '');
  if (competitionId == null || clubId == null) return null;
  return (competitionId: competitionId, clubId: clubId);
}

String? clubRedirect(Map<String, String> pathParameters) =>
    clubKey(pathParameters) == null ? Routes.mySpace : null;

String startTabLocation(StartTab tab) => switch (tab) {
  StartTab.home => Routes.home,
  StartTab.programme => Routes.programme,
  StartTab.live => Routes.live,
  StartTab.results => Routes.results,
};

/// Seule l'ouverture sur l'accueil prend l'onglet choisi : un lien direct
/// garde sa page.
String? startTabRedirect(String location, StartTab tab) =>
    location == Routes.home && tab != StartTab.home
    ? startTabLocation(tab)
    : null;

/// Applique l'onglet d'ouverture au premier affichage seulement : revenir
/// plus tard sur l'accueil ne doit pas renvoyer ailleurs. Le routeur est
/// construit avant que la préférence soit lue ; une redirection qui l'attend
/// évite de le reconstruire (et de perdre la pile des onglets) une fois lue.
class LaunchRedirect {
  LaunchRedirect(this._startTab);

  final Future<StartTab> Function() _startTab;
  bool _done = false;

  FutureOr<String?> call(String location) {
    if (_done) return null;
    _done = true;
    return _startTab().then(
      (tab) => startTabRedirect(location, tab),
      // Toute erreur, pas seulement une `AppException` : une préférence
      // illisible ne doit jamais empêcher l'application de s'ouvrir, et
      // l'accueil est un repli sans risque.
      onError: (Object _) => null,
    );
  }
}

/// Le créneau désigné par un lien, ou rien s'il est mal formé : un lien venu
/// d'ailleurs (partagé, tapé) ne doit pas faire planter la page.
ItemKey? programmeItemKey(Map<String, String> pathParameters) {
  final competitionId = int.tryParse(pathParameters['competitionId'] ?? '');
  final itemId = int.tryParse(pathParameters['itemId'] ?? '');
  if (competitionId == null || itemId == null) return null;
  return (competitionId: competitionId, itemId: itemId);
}

/// La série demandée par un lien de saisie ; nulle si absente ou illisible,
/// la saisie ouvre alors la première du créneau.
int? entryHeatId(Map<String, String> queryParameters) =>
    int.tryParse(queryParameters['serie'] ?? '');

/// Un lien de créneau mal formé retombe sur l'onglet qui le porte
/// ([fallback]) ; nul pour un lien lisible.
String? itemRedirect(Map<String, String> pathParameters, String fallback) =>
    programmeItemKey(pathParameters) == null ? fallback : null;

/// Le détail d'un créneau, sous l'onglet qui l'a ouvert, et sa saisie.
GoRoute _itemRoute({required String fallback}) => GoRoute(
  path: 'competition/:competitionId/creneau/:itemId',
  redirect: (context, state) => itemRedirect(state.pathParameters, fallback),
  builder: (context, state) {
    final key = programmeItemKey(state.pathParameters)!;
    return ItemDetailPage(
      competitionId: key.competitionId,
      itemId: key.itemId,
      branch: fallback,
    );
  },
  routes: [
    GoRoute(
      path: 'saisie',
      builder: (context, state) {
        final key = programmeItemKey(state.pathParameters)!;
        return EntryPage(
          competitionId: key.competitionId,
          itemId: key.itemId,
          heatId: entryHeatId(state.uri.queryParameters),
          branch: fallback,
        );
      },
    ),
  ],
);

/// Une branche par onglet : chacune garde sa propre pile, donc sa position
/// quand on passe d'un onglet à l'autre.
///
/// Un nouveau routeur à chaque changement de serveur : les pages ouvertes,
/// dans tous les onglets, portent des ids de l'autre serveur. L'app repart de
/// l'onglet d'ouverture.
final routerProvider = Provider<GoRouter>((ref) {
  ref.watch(appConfigProvider);
  final launch = LaunchRedirect(() => ref.read(startTabProvider.future));
  return GoRouter(
    initialLocation: Routes.home,
    redirect: (context, state) => launch(state.uri.path),
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
                builder: (context, state) => const ResultsPage(),
                routes: [
                  GoRoute(
                    path: 'competition/:competitionId/recherche',
                    redirect: (context, state) =>
                        searchRedirect(state.pathParameters),
                    builder: (context, state) => AthleteSearchPage(
                      competitionId: _competitionIdOf(state.pathParameters)!,
                    ),
                  ),
                  GoRoute(
                    path: 'competition/:competitionId/athlete/:participantId',
                    redirect: (context, state) =>
                        athleteRedirect(state.pathParameters),
                    builder: (context, state) {
                      final key = athleteKey(state.pathParameters)!;
                      return AthletePage(
                        competitionId: key.competitionId,
                        participantId: key.participantId,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.mySpace,
                builder: (context, state) => const MySpacePage(),
                routes: _mySpaceRoutes,
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// Une page de Mon espace sur une compétition : `competition/:competitionId/`
/// suivi de [path].
GoRoute _mySpaceRoute(String path, Widget Function(int competitionId) page) =>
    GoRoute(
      path: 'competition/:competitionId/$path',
      redirect: (context, state) => mySpaceRedirect(state.pathParameters),
      builder: (context, state) =>
          page(_competitionIdOf(state.pathParameters)!),
    );

final _mySpaceRoutes = [
  _mySpaceRoute('infos', (id) => CompetitionInfoPage(competitionId: id)),
  _mySpaceRoute('officiels', (id) => OfficialsPage(competitionId: id)),
  _mySpaceRoute('suivis', (id) => FollowsPage(competitionId: id)),
  _mySpaceRoute('athlete', (id) => AthleteSpacePage(competitionId: id)),
  _mySpaceRoute('officiel', (id) => OfficialSpacePage(competitionId: id)),
  _mySpaceRoute(
    'officiel/a-saisir',
    (id) => HeatsToEnterPage(competitionId: id),
  ),
  _mySpaceRoute(
    'officiel/dq-forfaits',
    (id) => OfficialDecisionsPage(competitionId: id),
  ),
  // La saisie ouverte depuis l'espace officiel, sous son créneau : dans la
  // branche de Mon espace, le retour y ramène.
  _itemRoute(fallback: Routes.mySpace),
  GoRoute(
    path: 'competition/:competitionId/club/:clubId',
    redirect: (context, state) => clubRedirect(state.pathParameters),
    builder: (context, state) {
      final key = clubKey(state.pathParameters)!;
      return ClubPage(competitionId: key.competitionId, clubId: key.clubId);
    },
  ),
  GoRoute(
    path: 'competition/:competitionId/fiche/:participantId',
    redirect: (context, state) =>
        athleteRedirect(state.pathParameters, fallback: Routes.mySpace),
    builder: (context, state) {
      final key = athleteKey(state.pathParameters)!;
      return AthletePage(
        competitionId: key.competitionId,
        participantId: key.participantId,
      );
    },
  ),
];
