import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/router/app_router.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';

/// Ce que montre un onglet de compétition tant qu'aucune n'est ouverte.
class ChooseCompetitionPrompt extends StatelessWidget {
  const ChooseCompetitionPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
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
    );
  }
}
