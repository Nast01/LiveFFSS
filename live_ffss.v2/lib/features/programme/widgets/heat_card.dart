import 'package:flutter/material.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/lane_assignment.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/features/programme/programme_formatting.dart';
import 'package:live_ffss_v2/features/programme/widgets/lane_row.dart';
import 'package:live_ffss_v2/features/programme/widgets/status_badge.dart';

class HeatCard extends StatelessWidget {
  const HeatCard({super.key, required this.heat, required this.lanes});

  final Heat heat;
  final List<LaneAssignment> lanes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    [
                      heat.name,
                      timeLabel(heat.plannedStart),
                    ].where((p) => p.isNotEmpty).join(' · '),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                StatusBadge(status: heatStatus(heat)),
              ],
            ),
          ),
          if (lanes.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Text(
                l10n.noLanes,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            )
          else
            for (final lane in lanes) LaneRow(lane: lane),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
