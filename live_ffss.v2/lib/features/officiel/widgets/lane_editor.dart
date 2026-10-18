import 'package:flutter/material.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/domain/manual_timing.dart';
import 'package:live_ffss_v2/domain/race_result.dart';
import 'package:live_ffss_v2/features/officiel/entry_formatting.dart';
import 'package:live_ffss_v2/features/officiel/entry_providers.dart';
import 'package:live_ffss_v2/features/officiel/entry_view.dart';
import 'package:live_ffss_v2/features/officiel/widgets/chrono_field.dart';
import 'package:live_ffss_v2/features/officiel/widgets/chrono_keypad.dart';
import 'package:live_ffss_v2/features/officiel/widgets/send_state_line.dart';

/// Un couloir en grand (maquette B) : ses trois chronos au pavé, le temps
/// manuel qu'ils donnent, son statut.
class LaneEditor extends StatelessWidget {
  const LaneEditor({
    super.key,
    required this.lane,
    required this.digits,
    required this.field,
    required this.unsaved,
    required this.onSelectField,
    required this.onDigit,
    required this.onErase,
    required this.onClear,
    required this.onAction,
    required this.onRetry,
    required this.onDismiss,
  });

  final EntryLane lane;

  /// Les trois champs affichés : tapés, sinon les chronos actuels.
  final List<String> digits;
  final int field;
  final bool unsaved;
  final ValueChanged<int> onSelectField;
  final ValueChanged<String> onDigit;
  final VoidCallback onErase;
  final VoidCallback onClear;
  final ValueChanged<EntryLaneAction> onAction;
  final ValueChanged<String> onRetry;
  final ValueChanged<String> onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final subtitle = laneSubtitle(lane.lane);
    final manual = draftManualTime(digits);
    final status = lane.result.status;
    final statusText = status == statusOk ? null : entryLaneSummary(lane, l10n);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.entryLane(lane.lane.lane),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            laneTitle(lane.lane),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          if (statusText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                statusText,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.red,
                ),
              ),
            ),
          const SizedBox(height: 4),
          SendStateLine(lane: lane, onRetry: onRetry, onDismiss: onDismiss),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < chronoCount; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: ChronoField(
                    number: i + 1,
                    digits: digits[i],
                    selected: field == i,
                    enabled: lane.editable,
                    onTap: () => onSelectField(i),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          if (digits.any(isChronoInvalid))
            Text(
              l10n.entryInvalidChrono,
              style: const TextStyle(color: AppColors.red),
            )
          else if (manual == null)
            Text(
              l10n.entryNoChrono,
              style: const TextStyle(color: AppColors.textSecondary),
            )
          else
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: l10n.entryManualTime(
                      hundredthsLabel(manual.hundredths),
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text:
                        ' · ${manualRuleLabel(manual.rule, l10n)}'
                        ' · ${l10n.entryNotFinal}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          if (unsaved)
            Text(
              l10n.entryUnsaved,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.red,
              ),
            ),
          if (lane.editable) ...[
            const SizedBox(height: 12),
            ChronoKeypad(onDigit: onDigit, onErase: onErase, onClear: onClear),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final action in laneActions(lane))
                  OutlinedButton(
                    onPressed: () => onAction(action),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.red,
                    ),
                    child: Text(laneActionLabel(action, l10n)),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
