import 'package:flutter/material.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/features/programme/programme_formatting.dart';
import 'package:live_ffss_v2/features/programme/widgets/item_row.dart';

class MeetingCard extends StatelessWidget {
  const MeetingCard({super.key, required this.meeting, required this.onOpen});

  final Meeting meeting;
  final void Function(MeetingItem item) onOpen;

  @override
  Widget build(BuildContext context) {
    final range = timeRangeLabel(meeting.startTime, meeting.endTime);
    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    meeting.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (range.isNotEmpty)
                  Text(
                    range,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
          for (final item in meeting.items) ...[
            const Divider(height: 1, color: AppColors.border),
            ItemRow(item: item, onTap: () => onOpen(item)),
          ],
        ],
      ),
    );
  }
}
