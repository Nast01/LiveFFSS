import 'package:flutter/material.dart';
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
    final status = itemStatus(item);
    // Un créneau sans course (une pause) n'a pas de détail à ouvrir.
    final enabled = status != ItemStatus.none;
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              timeLabel(item.startTime),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
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
