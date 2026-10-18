import 'package:flutter/material.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/domain/manual_timing.dart';
import 'package:live_ffss_v2/features/officiel/entry_view.dart';

/// Un des trois chronos d'un couloir, `mm'ss"cc` : les séparateurs se placent
/// seuls, l'officiel ne tape que des chiffres.
class ChronoField extends StatelessWidget {
  const ChronoField({
    super.key,
    required this.number,
    required this.digits,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  /// 1, 2 ou 3.
  final int number;
  final String digits;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final invalid = isChronoInvalid(digits);
    final border = invalid
        ? AppColors.red
        : selected && enabled
        ? AppColors.blue
        : AppColors.border;
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: enabled ? AppColors.surface : AppColors.dateBox,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border, width: selected ? 2 : 1),
        ),
        child: Column(
          children: [
            Text(
              l10n.entryChrono(number),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              child: Text(
                digits.isEmpty ? '–' : chronoDigitsLabel(digits),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: invalid ? AppColors.red : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
