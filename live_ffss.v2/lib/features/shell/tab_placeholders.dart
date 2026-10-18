import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/features/shell/choose_competition_prompt.dart';
import 'package:live_ffss_v2/features/shell/current_competition.dart';

/// Les onglets qui suivent la compétition active, avec le lot qui les livre.
enum CompetitionTab {
  results(5);

  const CompetitionTab(this.lot);

  final int lot;

  String title(AppLocalizations l10n) => switch (this) {
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
              ? const ChooseCompetitionPrompt()
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
