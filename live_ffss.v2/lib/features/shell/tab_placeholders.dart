import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/router/app_router.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/features/shell/current_competition.dart';

/// Les onglets qui suivent la compétition active, avec le lot qui les livre.
enum CompetitionTab {
  programme(2),
  live(3),
  results(5);

  const CompetitionTab(this.lot);

  final int lot;

  String title(AppLocalizations l10n) => switch (this) {
    CompetitionTab.programme => l10n.tabProgramme,
    CompetitionTab.live => l10n.tabLive,
    CompetitionTab.results => l10n.tabResults,
  };
}

class CompetitionTabPlaceholder extends ConsumerWidget {
  const CompetitionTabPlaceholder({super.key, required this.tab});

  final CompetitionTab tab;

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
              tab.title(l10n),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: competition == null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.chooseCompetitionHint,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.go(Routes.home),
                      child: Text(l10n.chooseCompetition),
                    ),
                  ],
                )
              : Text(
                  l10n.availableInLot(tab.lot),
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
        ),
      ),
    );
  }
}

class MySpacePlaceholder extends StatelessWidget {
  const MySpacePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabMySpace)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.comingSoon,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.mySpaceComingSoon,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
