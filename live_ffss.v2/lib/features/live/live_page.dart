import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/router/app_router.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/domain/discipline.dart';
import 'package:live_ffss_v2/domain/follows.dart';
import 'package:live_ffss_v2/domain/live.dart';
import 'package:live_ffss_v2/features/auth/competition_roles.dart';
import 'package:live_ffss_v2/features/follows/follows_providers.dart';
import 'package:live_ffss_v2/features/live/live_formatting.dart';
import 'package:live_ffss_v2/features/live/live_providers.dart';
import 'package:live_ffss_v2/features/live/widgets/live_heat_card.dart';
import 'package:live_ffss_v2/features/officiel/entry_view.dart';
import 'package:live_ffss_v2/features/shell/choose_competition_prompt.dart';
import 'package:live_ffss_v2/features/shell/current_competition.dart';

class LivePage extends ConsumerStatefulWidget {
  const LivePage({super.key});

  @override
  ConsumerState<LivePage> createState() => _LivePageState();
}

class _LivePageState extends ConsumerState<LivePage> {
  // Le bouton passe par l'indicateur du geste : même rond de chargement, et
  // un appui pendant un rafraîchissement n'en lance pas un second.
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final competition = ref.watch(currentCompetitionProvider);
    final flatWater =
        competition != null &&
        competition.disciplines.contains(Discipline.flatWater);

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
        actions: [
          if (flatWater)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: l10n.liveRefresh,
              // Sans liste, `refresh` relancerait le premier chargement en
              // cours, et un échec a déjà son « Réessayer » dans la page.
              onPressed:
                  ref.watch(
                    liveProvider(competition.id).select((s) => s.hasValue),
                  )
                  ? () => _refreshKey.currentState?.show()
                  : null,
            ),
        ],
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
          : _LiveBody(competitionId: competition.id, refreshKey: _refreshKey),
    );
  }
}

class _LiveBody extends ConsumerWidget {
  const _LiveBody({required this.competitionId, required this.refreshKey});

  final int competitionId;
  final GlobalKey<RefreshIndicatorState> refreshKey;

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

    final canEnter = ref.watch(canEnterProvider(competitionId));
    final follows =
        ref.watch(followsProvider(competitionId)).value ?? const Follows();
    Widget card(LiveEntry entry) => LiveHeatCard(
      follows: follows,
      entry: entry,
      position: heatPosition(value.meetings, entry),
      lanes: value.lanesOf(entry.heat),
      lanesRead: value.lanesReadFor(entry.heat),
      onOpen: () => context.go(Routes.liveItem(competitionId, entry.item.id)),
      onEnter: canEnter && canEnterHeat(entry.heat)
          ? () => context.go(
              Routes.itemEntry(
                Routes.live,
                competitionId,
                entry.item.id,
                heatId: entry.heat.id,
              ),
            )
          : null,
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
      key: refreshKey,
      onRefresh: () => _refreshLive(ref, competitionId),
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
                      liveNextLabel(
                        next,
                        heatPosition(value.meetings, next),
                        l10n,
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
}

/// Relit tout : le juge principal peut corriger une série validée.
Future<void> _refreshLive(WidgetRef ref, int competitionId) async {
  try {
    await ref.read(liveProvider(competitionId).notifier).refresh();
  } on AppException {
    // Signalé par le `ref.listen` de `_LiveBody`, qui garde le direct affiché.
  }
}
