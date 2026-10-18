import 'package:flutter/material.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';

/// Un message centré, avec « Réessayer » quand [onRetry] est donné.
class ResultsMessage extends StatelessWidget {
  const ResultsMessage({super.key, required this.text, this.onRetry});

  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final onRetry = this.onRetry;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onRetry,
                child: Text(AppLocalizations.of(context).retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Les puces des sous-onglets au-dessus d'un chargement ou d'un échec : on
/// doit pouvoir changer de sous-onglet sans attendre des classements longs à
/// calculer.
class TabsAbove extends StatelessWidget {
  const TabsAbove({super.key, required this.tabs, required this.child});

  final Widget tabs;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const SizedBox(height: 12),
      tabs,
      Expanded(child: child),
    ],
  );
}

/// Le temps ou le statut d'un résultat, en rouge pour une anomalie (DQ,
/// forfait, hors temps), comme les places du programme.
class ResultText extends StatelessWidget {
  const ResultText({super.key, required this.label});

  final ({String text, bool anomaly}) label;

  @override
  Widget build(BuildContext context) => Text(
    label.text,
    style: TextStyle(
      fontWeight: FontWeight.w700,
      color: label.anomaly ? AppColors.red : AppColors.textPrimary,
    ),
  );
}

class QualificationBadge extends StatelessWidget {
  const QualificationBadge(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: AppColors.yellow,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.navy,
      ),
    ),
  );
}
