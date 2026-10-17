import 'package:flutter/material.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/lane_assignment.dart';
import 'package:live_ffss_v2/domain/live.dart';
import 'package:live_ffss_v2/domain/run_status.dart';
import 'package:live_ffss_v2/features/live/live_formatting.dart';
import 'package:live_ffss_v2/features/programme/widgets/lane_row.dart';

/// Une série du Live : en-tête qui ouvre le créneau, puis départ ou résultats.
class LiveHeatCard extends StatelessWidget {
  const LiveHeatCard({
    super.key,
    required this.entry,
    required this.position,
    required this.lanes,
    required this.onOpen,
  });

  final LiveEntry entry;
  final ({int position, int total}) position;

  /// Les places occupées de la série, dans l'ordre des couloirs.
  final List<LaneAssignment> lanes;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final heat = entry.heat;
    final published = hasPublishedResults(lanes);
    final places = heatPlaces(lanes);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onOpen,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          liveCardTitle(entry, l10n),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          liveCardSubtitle(entry, position, l10n),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _HeatBadge(heat: heat),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          if (!published) ...[
            // Le départ d'une série à venir ou en cours : sans temps, les
            // places ne disent que qui nage où.
            if (heat.status != RunStatus.finished)
              for (final lane in lanes) LaneRow(lane: lane),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                l10n.liveWaitingResults,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ] else ...[
            if (isProvisional(heat))
              Container(
                color: AppColors.yellow.withValues(alpha: 0.25),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Text(
                  l10n.livePendingValidation,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navy,
                  ),
                ),
              ),
            for (final lane in resultOrder(lanes))
              LaneRow(lane: lane, place: places[lane.id]),
          ],
        ],
      ),
    );
  }
}

class _HeatBadge extends StatelessWidget {
  const _HeatBadge({required this.heat});

  final Heat heat;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (label, background, foreground) = switch (heat.status) {
      RunStatus.inProgress => (l10n.liveBadge, AppColors.red, Colors.white),
      RunStatus.marshalling => (
        l10n.liveMarshalling,
        AppColors.dateBox,
        AppColors.textSecondary,
      ),
      _ when isProvisional(heat) => (
        l10n.liveProvisional,
        AppColors.yellow,
        AppColors.navy,
      ),
      _ => (
        l10n.liveValidated,
        AppColors.coastalBackground,
        AppColors.coastalText,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
