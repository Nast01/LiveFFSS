import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/router/app_router.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/domain/discipline.dart';
import 'package:live_ffss_v2/domain/live.dart';
import 'package:live_ffss_v2/features/live/live_formatting.dart';
import 'package:live_ffss_v2/features/live/live_providers.dart';
import 'package:live_ffss_v2/features/live/widgets/live_heat_card.dart';
import 'package:live_ffss_v2/features/shell/choose_competition_prompt.dart';
import 'package:live_ffss_v2/features/shell/current_competition.dart';

class LivePage extends ConsumerWidget {
  const LivePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final competition = ref.watch(currentCompetitionProvider);

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
              l10n.liveTitle,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      body: competition == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: ChooseCompetitionPrompt(),
              ),
            )
          : !competition.disciplines.contains(Discipline.flatWater)
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
          : _LiveBody(competitionId: competition.id),
    );
  }
}

class _LiveBody extends ConsumerWidget {
  const _LiveBody({required this.competitionId});

  final int competitionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final provider = liveProvider(competitionId);
    ref.listen(provider, (previous, next) {
      // Un rafraîchissement en échec garde le direct affiché.
      if (next.hasError && next.hasValue && !next.isLoading) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.refreshFailed)));
      }
    });
    final live = ref.watch(provider);
    final value = live.value;

    if (value == null) {
      if (live.hasError) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.liveLoadError, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(provider),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        );
      }
      return const Center(child: CircularProgressIndicator());
    }

    Widget card(LiveEntry entry) => LiveHeatCard(
      entry: entry,
      position: heatPosition(value.meetings, entry),
      lanes: value.lanesOf(entry.heat),
      onOpen: () =>
          context.go(Routes.programmeItem(competitionId, entry.item.id)),
    );

    Widget section(String title) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
    );

    final next = nextScheduled(value.meetings);
    final empty = value.running.isEmpty && value.recent.isEmpty;

    return RefreshIndicator(
      onRefresh: () => _refresh(ref),
      child: ListView(
        // Toujours défilable : sans cela, le geste de rafraîchissement ne
        // part pas sur un direct plus court que l'écran.
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          top: 12,
          bottom: 16 + MediaQuery.of(context).viewPadding.bottom,
        ),
        children: [
          if (value.running.isNotEmpty) ...[
            section(l10n.liveRunning),
            for (final entry in value.running) card(entry),
          ],
          if (value.recent.isNotEmpty) ...[
            section(l10n.liveRecent),
            for (final entry in value.recent) card(entry),
          ],
          if (empty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 0),
              child: Column(
                children: [
                  Text(
                    l10n.liveNothingYet,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  if (next != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.liveNext(
                        [
                          liveCardTitle(next, l10n),
                          liveCardSubtitle(
                            next,
                            heatPosition(value.meetings, next),
                            l10n,
                          ),
                        ].where((part) => part.isNotEmpty).join(' · '),
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: OutlinedButton(
              onPressed: () => context.go(Routes.programme),
              child: Text(l10n.liveSeeProgramme),
            ),
          ),
        ],
      ),
    );
  }

  /// Relit tout : le juge principal peut corriger une série validée.
  Future<void> _refresh(WidgetRef ref) async {
    try {
      await ref.read(liveProvider(competitionId).notifier).refresh();
    } on AppException {
      // Signalé par le `ref.listen` de build, qui garde le direct affiché.
    }
  }
}
