import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/router/app_router.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/domain/event_ranking.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/features/results/results_formatting.dart';
import 'package:live_ffss_v2/features/results/results_providers.dart';
import 'package:live_ffss_v2/features/results/widgets/choice_chips_row.dart';
import 'package:live_ffss_v2/features/results/widgets/results_messages.dart';

/// Le sous-onglet Épreuves : une épreuve (discipline · genre, puis
/// catégorie) et son classement.
class EventsView extends ConsumerWidget {
  const EventsView({
    super.key,
    required this.competitionId,
    required this.refreshKey,
    required this.tabs,
  });

  final int competitionId;
  final GlobalKey<RefreshIndicatorState> refreshKey;

  /// Les puces Épreuves / Classements, en tête de la liste.
  final Widget tabs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final provider = eventsProvider(competitionId);
    final events = ref.watch(provider);
    final value = events.value;
    if (value == null) {
      return TabsAbove(
        tabs: tabs,
        child: events.hasError
            ? ResultsMessage(
                text: l10n.resultsLoadError,
                onRetry: () => ref.read(provider.notifier).refresh(),
              )
            : const Center(child: CircularProgressIndicator()),
      );
    }

    final groups = eventGroups(value);
    final eventId = ref.watch(resultsSelectionProvider(competitionId)).eventId;
    final group = groupOfEvent(groups, eventId);
    final selection = ref.read(
      resultsSelectionProvider(competitionId).notifier,
    );
    final selected = group?.events.where((e) => e.id == eventId).firstOrNull;

    return RefreshIndicator(
      key: refreshKey,
      onRefresh: () => _refresh(ref, eventId),
      child: ListView(
        // Toujours défilable : sans cela, le geste de rafraîchissement ne
        // part pas sur une liste plus courte que l'écran.
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          top: 12,
          bottom: 16 + MediaQuery.of(context).viewPadding.bottom,
        ),
        children: [
          tabs,
          if (group == null || selected == null)
            Padding(
              padding: const EdgeInsets.only(top: 48),
              child: Text(
                l10n.resultsNoEvent,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: DropdownButton<int>(
                isExpanded: true,
                value: groups.indexOf(group),
                items: [
                  for (final (i, g) in groups.indexed)
                    DropdownMenuItem(
                      value: i,
                      child: Text(eventGroupLabel(g, l10n)),
                    ),
                ],
                onChanged: (i) {
                  if (i == null) return;
                  selection.select(
                    eventInGroup(groups[i], selected.categoryName).id,
                  );
                },
              ),
            ),
            if (group.events.length > 1)
              ChoiceChipsRow<CompetitionEvent>(
                options: group.events,
                selected: selected,
                label: (e) => e.categoryName,
                onSelect: (e) => selection.select(e.id),
              ),
            _RankingSection(competitionId: competitionId, eventId: selected.id),
          ],
        ],
      ),
    );
  }

  Future<void> _refresh(WidgetRef ref, int? eventId) async {
    try {
      await ref.read(eventsProvider(competitionId).notifier).refresh();
      if (eventId != null) {
        await ref.read(
          eventRankingProvider((
            competitionId: competitionId,
            eventId: eventId,
          )).future,
        );
      }
    } on AppException {
      // L'échec est dans l'état du classement, que la section montre.
    }
  }
}

class _RankingSection extends ConsumerWidget {
  const _RankingSection({required this.competitionId, required this.eventId});

  final int competitionId;
  final int eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final provider = eventRankingProvider((
      competitionId: competitionId,
      eventId: eventId,
    ));
    ref.listen(provider, (previous, next) {
      // Un rafraîchissement en échec garde le classement affiché.
      if (next.hasError && next.hasValue && !next.isLoading) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.refreshFailed)));
      }
    });
    final ranking = ref.watch(provider);
    final value = ranking.value;
    if (value == null) {
      if (ranking.hasError) {
        return ResultsMessage(
          text: l10n.resultsLoadError,
          onRetry: () => ref.invalidate(provider),
        );
      }
      return const Padding(
        padding: EdgeInsets.only(top: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final rows = shownRows(value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  rankingHeader(value, l10n),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Text(
                seriesProgressLabel(
                  value.finishedSeries,
                  value.totalSeries,
                  l10n,
                ),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (rows.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
            child: Text(
              l10n.liveWaitingResults,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          )
        else
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                for (final (i, row) in rows.indexed) ...[
                  if (i > 0) const Divider(height: 1),
                  _RankingRowTile(
                    row: row,
                    relay: value.event.isRelay,
                    onOpen: (athleteId) => context.go(
                      Routes.resultsAthlete(competitionId, athleteId),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _RankingRowTile extends StatelessWidget {
  const _RankingRowTile({
    required this.row,
    required this.relay,
    required this.onOpen,
  });

  final RankingRow row;
  final bool relay;
  final void Function(int athleteId) onOpen;

  @override
  Widget build(BuildContext context) {
    final names = resultNames(row.result, relay: relay);
    final badge = qualificationBadge(row.qualification);
    return InkWell(
      onTap: switch (rowOpening(row.result)) {
        OpenNothing() => null,
        OpenAthlete(:final athleteId) => () => onOpen(athleteId),
        PickAthlete(:final athletes) => () => _chooseAthlete(context, athletes),
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 28,
              child: Text(
                rankLabel(row.rank),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    names.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (names.subtitle.isNotEmpty)
                    Text(
                      names.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ResultText(label: resultLabel(row.result)),
                if (badge != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: QualificationBadge(badge),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Un relais : on choisit lequel des relayeurs ouvrir.
  void _chooseAthlete(BuildContext context, List<ResultAthlete> athletes) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final athlete in athletes)
              ListTile(
                title: Text(athlete.name),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  onOpen(athlete.id);
                },
              ),
          ],
        ),
      ),
    );
  }
}
