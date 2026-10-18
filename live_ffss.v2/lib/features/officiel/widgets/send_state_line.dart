import 'package:flutter/material.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/features/officiel/entry_formatting.dart';
import 'package:live_ffss_v2/features/officiel/entry_view.dart';

/// Où en est le couloir : validé par le juge, ou l'état de sa dernière
/// saisie, et pour un refus sa raison avec « Réessayer » et « Ignorer ».
class SendStateLine extends StatelessWidget {
  const SendStateLine({
    super.key,
    required this.lane,
    required this.onRetry,
    required this.onDismiss,
  });

  final EntryLane lane;
  final ValueChanged<String> onRetry;
  final ValueChanged<String> onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rejected = lane.rejected;
    final (text, color) = lane.validatedByJudge
        ? (l10n.entryValidatedByJudge, AppColors.coastalText)
        : switch (lane.sendState) {
            EntrySendState.pending => (l10n.entryPending, AppColors.navy),
            EntrySendState.sent => (l10n.entrySent, AppColors.coastalText),
            _ => (null, AppColors.textSecondary),
          };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (text != null)
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        if (rejected != null) ...[
          Text(
            l10n.entryRejected(rejectionReason(rejected, l10n)),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.red,
            ),
          ),
          Wrap(
            spacing: 8,
            children: [
              if (canRetryRejection(rejected))
                TextButton(
                  onPressed: () => onRetry(rejected.id),
                  child: Text(l10n.retry),
                ),
              TextButton(
                onPressed: () => onDismiss(rejected.id),
                child: Text(l10n.entryDismiss),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
