import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/router/app_router.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/domain/discipline.dart';
import 'package:live_ffss_v2/features/results/widgets/choice_chips_row.dart';
import 'package:live_ffss_v2/features/results/widgets/events_view.dart';
import 'package:live_ffss_v2/features/results/widgets/standings_view.dart';
import 'package:live_ffss_v2/features/shell/choose_competition_prompt.dart';
import 'package:live_ffss_v2/features/shell/current_competition.dart';

enum _ResultsTab { events, standings }

class ResultsPage extends ConsumerStatefulWidget {
  const ResultsPage({super.key});

  @override
  ConsumerState<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends ConsumerState<ResultsPage> {
  // Le bouton passe par l'indicateur du geste : même rond de chargement, et
  // un appui pendant un rafraîchissement n'en lance pas un second.
  final _refreshKey = GlobalKey<RefreshIndicatorState>();
  _ResultsTab _tab = _ResultsTab.events;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final competition = ref.watch(currentCompetitionProvider);
    final flatWater =
        competition != null &&
        competition.disciplines.contains(Discipline.flatWater);

    final tabs = ChoiceChipsRow<_ResultsTab>(
      options: _ResultsTab.values,
      selected: _tab,
      label: (tab) => switch (tab) {
        _ResultsTab.events => l10n.resultsEvents,
        _ResultsTab.standings => l10n.resultsStandings,
      },
      onSelect: (tab) => setState(() => _tab = tab),
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (competition != null)
              Text(
                competition.name,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            Text(
              l10n.tabResults,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          if (flatWater) ...[
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: l10n.resultsSearch,
              onPressed: () => context.go(Routes.resultsSearch(competition.id)),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: l10n.resultsRefresh,
              // Sans liste (premier chargement, échec), l'indicateur n'est pas
              // monté : rien ne part, et l'échec a son « Réessayer ».
              onPressed: () => _refreshKey.currentState?.show(),
            ),
          ],
        ],
      ),
      body: competition == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: ChooseCompetitionPrompt(),
              ),
            )
          : !flatWater
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l10n.coastalComingSoon,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          : switch (_tab) {
              _ResultsTab.events => EventsView(
                competitionId: competition.id,
                refreshKey: _refreshKey,
                tabs: tabs,
              ),
              _ResultsTab.standings => StandingsView(
                competitionId: competition.id,
                refreshKey: _refreshKey,
                tabs: tabs,
              ),
            },
    );
  }
}
