import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/features/my_space/my_space_formatting.dart';
import 'package:live_ffss_v2/features/my_space/my_space_providers.dart';
import 'package:live_ffss_v2/features/results/athlete_providers.dart';
import 'package:live_ffss_v2/features/results/results_formatting.dart';
import 'package:live_ffss_v2/features/results/widgets/athlete_race_tile.dart';
import 'package:live_ffss_v2/features/results/widgets/choice_chips_row.dart';
import 'package:live_ffss_v2/features/results/widgets/results_messages.dart';
import 'package:live_ffss_v2/features/shell/current_competition.dart';

enum _AthleteTab { planning, results }

/// L'espace du licencié connecté : sa fiche d'athlète (lot 5), sa prochaine
/// course en grand, son planning et ses résultats.
class AthleteSpacePage extends ConsumerStatefulWidget {
  const AthleteSpacePage({super.key, required this.competitionId});

  final int competitionId;

  @override
  ConsumerState<AthleteSpacePage> createState() => _AthleteSpacePageState();
}

class _AthleteSpacePageState extends ConsumerState<AthleteSpacePage> {
  // Le bouton passe par l'indicateur du geste : même rond de chargement, et
  // un appui pendant un rafraîchissement n'en lance pas un second.
  final _refreshKey = GlobalKey<RefreshIndicatorState>();
  var _tab = _AthleteTab.planning;

  @override
  void initState() {
    super.initState();
    activateFromLink(ref, widget.competitionId);
  }

  ProviderContainer get _container =>
      ProviderScope.containerOf(context, listen: false);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cards = ref.watch(mySpaceCardsProvider(widget.competitionId));
    final view = athleteSpaceView(
      spacesView(
        loading: cards.isLoading,
        failed: cards.hasError,
        cards: cards.value,
      ),
    );
    final shown = view.athlete;
    final body = switch (view.body) {
      AthleteSpaceBody.loading => const Center(
        child: CircularProgressIndicator(),
      ),
      AthleteSpaceBody.retry => ResultsMessage(
        text: l10n.mySpaceAthleteUnknown,
        onRetry: () => retryMySpaceCards(_container, widget.competitionId),
      ),
      AthleteSpaceBody.notEntered => ResultsMessage(
        text: l10n.mySpaceNotEngaged,
      ),
      AthleteSpaceBody.card => _card(shown!, l10n),
    };
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.mySpaceAthleteSpaceTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.resultsRefresh,
            // Sans fiche, l'indicateur n'est pas monté ; l'échec a son
            // « Réessayer ».
            onPressed:
                shown == null ||
                    ref.watch(athleteCardProvider(_keyOf(shown))).value == null
                ? null
                : () => _refreshKey.currentState?.show(),
          ),
        ],
      ),
      body: body,
    );
  }

  AthleteKey _keyOf(Participant athlete) =>
      (competitionId: widget.competitionId, participantId: athlete.id);

  Widget _card(Participant athlete, AppLocalizations l10n) {
    final key = _keyOf(athlete);
    final provider = athleteCardProvider(key);
    ref.listen(provider, (previous, next) {
      // Un rafraîchissement en échec garde la fiche affichée.
      if (next.hasError && next.hasValue && !next.isLoading) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.refreshFailed)));
      }
    });
    final card = ref.watch(provider);
    final races = card.value;
    if (races == null) {
      final error = card.error;
      return error == null
          ? const Center(child: CircularProgressIndicator())
          : error is NotFoundException
          ? ResultsMessage(text: l10n.mySpaceNotEngaged)
          : ResultsMessage(
              text: l10n.athleteLoadError,
              onRetry: () => retryAthleteCard(_container, key),
            );
    }

    final split = splitRaces(races);
    final next = nextRace(races);
    final now = ref.watch(clockProvider)();
    final shown = _tab == _AthleteTab.planning ? split.toRun : split.run;
    return RefreshIndicator(
      key: _refreshKey,
      onRefresh: () => refreshAthleteCard(_container, key),
      child: ListView(
        // Toujours défilable : sans cela, le geste de rafraîchissement ne
        // part pas sur une fiche plus courte que l'écran.
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          top: 8,
          bottom: 16 + MediaQuery.of(context).viewPadding.bottom,
        ),
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.navy,
              foregroundColor: Colors.white,
              child: Text(participantInitials(athlete)),
            ),
            title: Text(
              participantName(athlete),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(participantSubtitle(athlete)),
          ),
          if (next != null)
            _NextRaceCard(
              // Une autre prochaine course repart sans recherche de série.
              key: ValueKey(next.entry.entryId),
              competitionId: widget.competitionId,
              race: next,
              headline: nextRaceHeadline(next, now, l10n),
            ),
          const SizedBox(height: 12),
          ChoiceChipsRow<_AthleteTab>(
            options: _AthleteTab.values,
            selected: _tab,
            label: (tab) => switch (tab) {
              _AthleteTab.planning => l10n.mySpaceMyPlanning,
              _AthleteTab.results => l10n.mySpaceMyResults,
            },
            onSelect: (tab) => setState(() => _tab = tab),
          ),
          const SizedBox(height: 12),
          if (shown.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Text(
                _tab == _AthleteTab.planning
                    ? l10n.mySpaceNoNextRace
                    : l10n.mySpaceNoRaceRun,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          // La clé garde la recherche de série de chaque engagement quand la
          // liste change après un rafraîchissement.
          for (final race in shown)
            AthleteRaceTile(
              key: ValueKey(race.entry.entryId),
              race: race,
              finder: showsLaneFinder(race, next)
                  ? LaneFinderButton(
                      competitionId: widget.competitionId,
                      race: race,
                    )
                  : null,
            ),
        ],
      ),
    );
  }
}

/// La prochaine course en grand : heure, série, ligne. Série et ligne par
/// « Trouver sa série », à la demande : une requête par place.
class _NextRaceCard extends ConsumerStatefulWidget {
  const _NextRaceCard({
    super.key,
    required this.competitionId,
    required this.race,
    required this.headline,
  });

  final int competitionId;
  final AthleteRace race;
  final String headline;

  @override
  ConsumerState<_NextRaceCard> createState() => _NextRaceCardState();
}

class _NextRaceCardState extends ConsumerState<_NextRaceCard> {
  bool _asked = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final race = widget.race;
    final provider = laneFinderProvider((
      competitionId: widget.competitionId,
      eventId: race.event.id,
      entryId: race.entry.entryId,
      heatId: race.series?.heat.id,
    ));
    final found = _asked ? ref.watch(provider) : null;
    final cells = nextRaceCells(race, found?.value);
    const muted = TextStyle(color: Colors.white70, fontSize: 12);

    Widget cell(String label, String value) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: muted),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );

    final Widget? status = switch (found) {
      null => Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          style: TextButton.styleFrom(foregroundColor: AppColors.yellow),
          icon: const Icon(Icons.search, size: 18),
          label: Text(l10n.athleteFindHeat),
          onPressed: () => setState(() => _asked = true),
        ),
      ),
      AsyncData(:final value) =>
        value == null ? Text(l10n.athleteNotPlaced, style: muted) : null,
      AsyncError() => Row(
        children: [
          Expanded(child: Text(l10n.athleteFindError, style: muted)),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.yellow),
            onPressed: () => ref.invalidate(provider),
            child: Text(l10n.retry),
          ),
        ],
      ),
      _ => const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      ),
    };

    return Card(
      color: AppColors.navy,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.headline.toUpperCase(),
              style: const TextStyle(
                color: AppColors.yellow,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              athleteRaceTitle(race.event, l10n),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                cell(l10n.mySpaceCellTime, cells.time),
                cell(l10n.mySpaceCellSeries, cells.series),
                cell(l10n.mySpaceCellLane, cells.lane),
              ],
            ),
            if (status != null) ...[const SizedBox(height: 8), status],
          ],
        ),
      ),
    );
  }
}
