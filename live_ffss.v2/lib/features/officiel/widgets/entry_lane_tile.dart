import 'package:flutter/material.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/domain/race_result.dart';
import 'package:live_ffss_v2/features/officiel/entry_formatting.dart';
import 'package:live_ffss_v2/features/officiel/entry_view.dart';
import 'package:live_ffss_v2/features/officiel/widgets/send_state_line.dart';

/// Un couloir de la liste « Tous » : son temps manuel ou son statut, son état
/// d'envoi et ses actions.
class EntryLaneTile extends StatelessWidget {
  const EntryLaneTile({
    super.key,
    required this.lane,
    required this.unsaved,
    required this.onChronos,
    required this.onAction,
    required this.onRetry,
    required this.onDismiss,
  });

  final EntryLane lane;

  /// Des chiffres tapés pour ce couloir n'ont pas été enregistrés.
  final bool unsaved;
  final VoidCallback onChronos;
  final ValueChanged<EntryLaneAction> onAction;
  final ValueChanged<String> onRetry;
  final ValueChanged<String> onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final summary = entryLaneSummary(lane, l10n);
    final subtitle = laneSubtitle(lane.lane);
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '${lane.lane.lane}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        laneTitle(lane.lane),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                if (summary != null)
                  Text(
                    summary,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: lane.result.status == statusOk
                          ? AppColors.textPrimary
                          : AppColors.red,
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 28, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (unsaved)
                    Text(
                      l10n.entryUnsaved,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.red,
                      ),
                    ),
                  SendStateLine(
                    lane: lane,
                    onRetry: onRetry,
                    onDismiss: onDismiss,
                  ),
                  if (lane.editable)
                    Wrap(
                      spacing: 4,
                      children: [
                        TextButton(
                          onPressed: onChronos,
                          child: Text(l10n.entryChronos),
                        ),
                        for (final action in laneActions(lane))
                          TextButton(
                            onPressed: () => onAction(action),
                            child: Text(laneActionLabel(action, l10n)),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
