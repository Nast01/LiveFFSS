import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/features/results/athlete_providers.dart';
import 'package:live_ffss_v2/features/results/results_formatting.dart';
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
              _RaceTile(key: ValueKey(race.entry.entryId), race: race),
          ],
          if (split.toRun.isNotEmpty) ...[
            section(l10n.athleteToRun),
            // La clé garde la recherche de série de chaque engagement quand
            // la liste change après un rafraîchissement.
            for (final race in split.toRun)
              _RaceTile(
                key: ValueKey(race.entry.entryId),
                race: race,
                finder: _LaneFinder(
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

class _RaceTile extends StatelessWidget {
  const _RaceTile({super.key, required this.race, this.finder});

  final AthleteRace race;

  /// « Trouver sa série », pour une course à courir.
  final Widget? finder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final row = race.row;
    final detail = race.unavailable
        ? l10n.athleteRaceUnavailable
        : athleteRaceDetail(race, l10n);
    final finder = this.finder;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 48,
              child: Text(
                athleteRaceTime(race),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    athleteRaceTitle(race.event, l10n),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (detail.isNotEmpty)
                    Text(
                      detail,
                      style: TextStyle(
                        fontSize: 12,
                        color: race.unavailable
                            ? AppColors.red
                            : AppColors.textSecondary,
                      ),
                    ),
                  ?finder,
                ],
              ),
            ),
            if (row != null) ...[
              const SizedBox(width: 8),
              ResultText(label: resultLabel(row.result)),
            ],
          ],
        ),
      ),
    );
  }
}

/// « Trouver sa série » : la lecture des places ne part qu'à la demande,
/// elle coûte une requête par place.
class _LaneFinder extends ConsumerStatefulWidget {
  const _LaneFinder({required this.competitionId, required this.race});

  final int competitionId;
  final AthleteRace race;

  @override
  ConsumerState<_LaneFinder> createState() => _LaneFinderState();
}

class _LaneFinderState extends ConsumerState<_LaneFinder> {
  bool _asked = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (!_asked) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          icon: const Icon(Icons.search, size: 18),
          label: Text(l10n.athleteFindHeat),
          onPressed: () => setState(() => _asked = true),
        ),
      );
    }
    final provider = laneFinderProvider((
      competitionId: widget.competitionId,
      eventId: widget.race.event.id,
      entryId: widget.race.entry.entryId,
    ));
    final found = ref.watch(provider);
    const style = TextStyle(fontWeight: FontWeight.w600, color: AppColors.navy);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: switch (found) {
        AsyncData(:final value) => Text(
          value == null ? l10n.athleteNotPlaced : laneFoundLabel(value, l10n),
          style: style,
        ),
        AsyncError() => Row(
          children: [
            Expanded(
              child: Text(
                l10n.athleteFindError,
                style: const TextStyle(fontSize: 12, color: AppColors.red),
              ),
            ),
            TextButton(
              onPressed: () => ref.invalidate(provider),
              child: Text(l10n.retry),
            ),
          ],
        ),
        _ => const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      },
    );
  }
}
