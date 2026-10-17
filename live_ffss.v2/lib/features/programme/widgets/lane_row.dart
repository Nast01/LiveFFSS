import 'package:flutter/material.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/domain/lane_assignment.dart';
import 'package:live_ffss_v2/features/programme/programme_formatting.dart';

class LaneRow extends StatelessWidget {
  const LaneRow({super.key, required this.lane, this.place});

  final LaneAssignment lane;

  /// La place dans la série, calculée par [heatPlaces] ; nulle sans temps.
  final int? place;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final performance = lane.performance;
    final result = performanceText(lane, l10n);
    final place = this.place;
    final rank = place == null ? null : l10n.heatPlace('$place');
    // Un relais s'annonce sous le nom de son club ; ses relayeurs dessous.
    final title = lane.isRelay ? lane.club : lane.athletes.join(', ');
    final subtitle = lane.isRelay
        ? lane.athletes.join(', ')
        : [
            lane.club,
            lane.category,
          ].where((p) => p != null && p.isNotEmpty).join(' · ');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '${lane.lane}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
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
                if (performance != null &&
                    (performance.isRecord || performance.isNationalRecord))
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Wrap(
                      spacing: 4,
                      children: [
                        if (performance.isNationalRecord)
                          _RecordBadge(l10n.nationalRecordBadge),
                        if (performance.isRecord)
                          _RecordBadge(l10n.recordBadge),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (result != null || rank != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (result != null)
                  Text(
                    result,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      // Un forfait sans performance est une anomalie,
                      // comme un statut publié.
                      color: performance?.isOk ?? false
                          ? AppColors.textPrimary
                          : AppColors.red,
                    ),
                  ),
                if (rank != null)
                  Text(
                    rank,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navy,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _RecordBadge extends StatelessWidget {
  const _RecordBadge(this.label);

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
