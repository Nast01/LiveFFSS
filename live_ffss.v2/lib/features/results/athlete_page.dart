import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/features/follows/follows_providers.dart';
import 'package:live_ffss_v2/features/results/athlete_providers.dart';
import 'package:live_ffss_v2/features/results/results_formatting.dart';
import 'package:live_ffss_v2/features/results/widgets/athlete_race_tile.dart';
import 'package:live_ffss_v2/features/results/widgets/results_messages.dart';
import 'package:live_ffss_v2/features/shell/current_competition.dart';

class AthletePage extends ConsumerStatefulWidget {
  const AthletePage({
    super.key,
    required this.competitionId,
    required this.participantId,
  });

  final int competitionId;
  final int participantId;

  @override
  ConsumerState<AthletePage> createState() => _AthletePageState();
}

class _AthletePageState extends ConsumerState<AthletePage> {
  // Le bouton passe par l'indicateur du geste : même rond de chargement, et
  // un appui pendant un rafraîchissement n'en lance pas un second.
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    activateFromLink(ref, widget.competitionId);
  }

  AthleteKey get _key => (
    competitionId: widget.competitionId,
    participantId: widget.participantId,
  );

  ProviderContainer get _container =>
      ProviderScope.containerOf(context, listen: false);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = athleteCardProvider(_key);
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
    final participant = participantById(
      ref.watch(participantsProvider(widget.competitionId)).value,
      widget.participantId,
    );

    final followed =
        ref
            .watch(followsProvider(widget.competitionId))
            .value
            ?.followsAthlete(widget.participantId) ??
        false;

    final Widget body;
    if (races == null) {
      final error = card.error;
      body = error == null
          ? const Center(child: CircularProgressIndicator())
          : error is NotFoundException
          ? ResultsMessage(text: l10n.athleteNotFound)
          : ResultsMessage(
              text: l10n.athleteLoadError,
              onRetry: () => retryAthleteCard(_container, _key),
            );
    } else {
      body = _card(participant, races, l10n);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          participant == null ? l10n.tabResults : participantName(participant),
        ),
        actions: [
          // Sans participant, rien à suivre : la fiche ne s'est pas chargée.
          if (participant != null)
            IconButton(
              icon: Icon(followed ? Icons.star : Icons.star_border),
              tooltip: followed ? l10n.unfollowAthlete : l10n.followAthlete,
              onPressed: () => toggleAthleteFollow(
                ProviderScope.containerOf(context, listen: false),
                widget.competitionId,
                participant,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.resultsRefresh,
            // Sans fiche, l'indicateur n'est pas monté ; l'échec a son
            // « Réessayer ».
            onPressed: races == null
                ? null
                : () => _refreshKey.currentState?.show(),
          ),
        ],
      ),
      body: body,
    );
  }

  Widget _card(
    Participant? participant,
    List<AthleteRace> races,
    AppLocalizations l10n,
  ) {
    final split = splitRaces(races);

    Widget section(String title) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
    );

    return RefreshIndicator(
      key: _refreshKey,
      onRefresh: () => refreshAthleteCard(_container, _key),
      child: ListView(
        // Toujours défilable : sans cela, le geste de rafraîchissement ne
        // part pas sur une fiche plus courte que l'écran.
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          top: 12,
          bottom: 16 + MediaQuery.of(context).viewPadding.bottom,
        ),
        children: [
          if (participant != null)
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
                child: Text(participantInitials(participant)),
              ),
              title: Text(
                participantName(participant),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(participantSubtitle(participant)),
            ),
          if (races.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 48),
              child: Text(
                l10n.athleteNoRace,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          if (split.run.isNotEmpty) ...[
            section(l10n.athleteRun),
            for (final race in split.run)
              AthleteRaceTile(key: ValueKey(race.entry.entryId), race: race),
          ],
          if (split.toRun.isNotEmpty) ...[
            section(l10n.athleteToRun),
            // La clé garde la recherche de série de chaque engagement quand
            // la liste change après un rafraîchissement.
            for (final race in split.toRun)
              AthleteRaceTile(
                key: ValueKey(race.entry.entryId),
                race: race,
                finder: LaneFinderButton(
                  competitionId: widget.competitionId,
                  race: race,
                ),
              ),
          ],
        ],
      ),
    );
  }
}
