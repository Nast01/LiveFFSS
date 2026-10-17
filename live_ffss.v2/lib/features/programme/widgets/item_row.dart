import 'package:flutter/material.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/features/programme/programme_formatting.dart';
import 'package:live_ffss_v2/features/programme/widgets/status_badge.dart';

class ItemRow extends StatelessWidget {
  const ItemRow({super.key, required this.item, required this.onTap});

  final MeetingItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = itemStatus(item);
    // Un créneau sans course (une pause) n'a pas de détail à ouvrir.
    final enabled = status != ItemStatus.none;
    final end = endTimeLabel(item.endTime);
    final duration = itemDuration(item);
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeLabel(item.startTime),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (end.isNotEmpty)
                  Text(
                    end,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (duration != null)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.flatWaterBackground,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      durationLabel(duration, l10n),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.flatWaterText,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          StatusBadge(status: status),
          if (enabled) ...[
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ],
      ),
    );
    if (!enabled) return Opacity(opacity: 0.5, child: row);
    return InkWell(onTap: onTap, child: row);
  }
}
