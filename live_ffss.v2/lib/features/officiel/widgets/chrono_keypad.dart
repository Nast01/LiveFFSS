import 'package:flutter/material.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';

/// Le pavé numérique de la saisie : des chiffres seulement, pour taper vite
/// sans clavier du téléphone qui couvre l'écran.
class ChronoKeypad extends StatelessWidget {
  const ChronoKeypad({
    super.key,
    required this.onDigit,
    required this.onErase,
    required this.onClear,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onErase;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget key(Widget child, VoidCallback onPressed, {String? tooltip}) =>
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: SizedBox(
              height: 52,
              child: Tooltip(
                message: tooltip ?? '',
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.navy,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: onPressed,
                  child: child,
                ),
              ),
            ),
          ),
        );
    Widget digit(String d) => key(
      Text(
        d,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
      ),
      () => onDigit(d),
    );

    return Column(
      children: [
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Row(children: [for (final d in row) digit(d)]),
        Row(
          children: [
            key(Text(l10n.entryClear), onClear),
            digit('0'),
            key(
              const Icon(Icons.backspace_outlined),
              onErase,
              tooltip: l10n.entryErase,
            ),
          ],
        ),
      ],
    );
  }
}
