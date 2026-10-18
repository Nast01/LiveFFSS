import 'package:flutter/material.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/lane_assignment.dart';
import 'package:live_ffss_v2/domain/live.dart';
import 'package:live_ffss_v2/features/live/live_formatting.dart';
import 'package:live_ffss_v2/features/programme/widgets/lane_row.dart';

/// Une série du Live : en-tête qui ouvre le créneau, puis départ ou résultats.
class LiveHeatCard extends StatelessWidget {
  const LiveHeatCard({
    super.key,
    required this.entry,
    required this.position,
    required this.lanes,
    required this.lanesRead,
    required this.onOpen,
    this.onEnter,
  });

  final LiveEntry entry;
  final ({int position, int total}) position;

  /// Les places occupées de la série, dans l'ordre des couloirs.
  final List<LaneAssignment> lanes;

  /// Une place au moins a été lue (`LiveView.lanesReadFor`).
  final bool lanesRead;
  final VoidCallback onOpen;

  /// « Saisir », pour un officiel de la compétition ; nul sinon.
  final VoidCallback? onEnter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final heat = entry.heat;
    final body = liveCardBody(heat, lanes, lanesRead: lanesRead);

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
                  if (onEnter case final onEnter?)
                    TextButton(
                      onPressed: onEnter,
                      child: Text(l10n.enterResults),
                    ),
                  _HeatBadge(heat: heat),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          if (body == LiveCardBody.loading)
            const LinearProgressIndicator(minHeight: 2),
          // Le départ d'une série qui se court : sans temps, les places ne
          // disent que qui nage où.
          if (body == LiveCardBody.startList)
            for (final lane in lanes) LaneRow(lane: lane),
          if (body == LiveCardBody.startList ||
              body == LiveCardBody.waitingResults)
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
          if (livePendingBanner(heat, body))
            Container(
              color: AppColors.yellow.withValues(alpha: 0.25),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                l10n.livePendingValidation,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.navy,
                ),
              ),
            ),
          if (body == LiveCardBody.results) ..._results(),
        ],
      ),
    );
  }

  /// `heatPlaces` calculé une fois pour l'ordre et pour l'affichage.
  List<Widget> _results() {
    final places = heatPlaces(lanes);
    return [
      for (final lane in resultOrder(lanes, places: places))
        LaneRow(lane: lane, place: places[lane.id]),
    ];
  }
}

class _HeatBadge extends StatelessWidget {
  const _HeatBadge({required this.heat});

  final Heat heat;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (label, background, foreground) = switch (liveBadge(heat)) {
      LiveBadge.live => (l10n.liveBadge, AppColors.red, Colors.white),
      LiveBadge.marshalling => (
        l10n.liveMarshalling,
        AppColors.dateBox,
        AppColors.textSecondary,
      ),
      LiveBadge.provisional => (
        l10n.liveProvisional,
        AppColors.yellow,
        AppColors.navy,
      ),
      LiveBadge.validated => (
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
