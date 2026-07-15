import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/heat.dart';
import 'package:live_ffss/app/domain/models/result.dart';
import 'package:live_ffss/app/module/competitions/controllers/race_detail_controller.dart';
import 'package:live_ffss/app/presentation/modules/competitions/heat_formatting.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';
import 'package:live_ffss/app/presentation/shared/error_state.dart';
import 'package:live_ffss/app/presentation/shared/loading_indicator.dart';

const Color _headerSlate = Color(0xFF2B3D4F);
const Color _laneYellow = Color(0xFFF4C44A);

class RaceDetailHeatsView extends GetView<RaceDetailController> {
  const RaceDetailHeatsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const LoadingIndicator();
      }
      if (controller.error.value != null) {
        return ErrorState(
          message: 'error_occured'.tr,
          onRetry: () => controller.loadHeats(initial: true),
        );
      }
      if (controller.heats.isEmpty) {
        return EmptyState(
          icon: Icons.timer_outlined,
          title: 'no_heats_yet'.tr,
        );
      }
      return RefreshIndicator(
        onRefresh: () => controller.loadHeats(initial: true),
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.lg,
          ),
          itemCount: controller.heats.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (_, i) => _HeatCard(heat: controller.heats[i]),
        ),
      );
    });
  }
}

class _HeatCard extends StatelessWidget {
  const _HeatCard({required this.heat});

  final Heat heat;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeatHeader(heat: heat),
          for (var i = 0; i < heat.results.length; i++) ...[
            _LaneRow(
              lane: i + 1,
              result: heat.results[i],
            ),
            if (i < heat.results.length - 1) const _DashedDivider(),
          ],
        ],
      ),
    );
  }
}

class _HeatHeader extends StatelessWidget {
  const _HeatHeader({required this.heat});

  final Heat heat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: const BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _NumberBadge(
            top: '${heat.number}',
            bottom: 'heat'.tr,
            color: _headerSlate,
            textColor: Colors.white,
            width: 44,
            height: 44,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  heat.titleLabel,
                  style: AppTypography.title.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  heat.subtitleLabel,
                  style: AppTypography.caption.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _StatusBadge(heat: heat),
        ],
      ),
    );
  }
}

class _LaneRow extends StatelessWidget {
  const _LaneRow({required this.lane, required this.result});

  final int lane;
  final Result result;

  @override
  Widget build(BuildContext context) {
    final athletes = result.athletes;
    final primary = athletes.isNotEmpty ? athletes.first : null;
    final athleteName = primary == null
        ? ''
        : '${primary.firstName} ${primary.lastName}'.trim().toUpperCase();
    final clubLabel = primary?.club?.name ?? '';
    final birthYearLabel = primary?.year.toString() ?? '';

    final timeLabel = result.timeLabel.isNotEmpty
        ? result.timeLabel
        : (result.entry?.entryTimeLabel ?? '');
    final timeTypeLabel = (result.complementLabel?.isNotEmpty == true)
        ? result.complementLabel!
        : 'entry_time'.tr;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _NumberBadge(
            top: '$lane',
            bottom: 'lane'.tr,
            color: _laneYellow,
            textColor: AppColors.textPrimary,
            width: 40,
            height: 40,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  athleteName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (birthYearLabel.isNotEmpty) ...[
                      Text(
                        birthYearLabel,
                        style:
                            AppTypography.caption.copyWith(fontSize: 12),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                    ],
                    if (clubLabel.isNotEmpty) ...[
                      const Icon(
                        Icons.groups_outlined,
                        size: 14,
                        color: AppColors.statusWaiting,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: Text(
                          clubLabel,
                          style:
                              AppTypography.caption.copyWith(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (result.rank > 0) ...[
            const SizedBox(width: AppSpacing.sm),
            _NumberBadge(
              top: '${result.rank}',
              bottom: 'rank'.tr,
              color: _headerSlate,
              textColor: Colors.white,
              width: 40,
              height: 40,
            ),
          ],
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timeLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                timeTypeLabel,
                style: AppTypography.caption.copyWith(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NumberBadge extends StatelessWidget {
  const _NumberBadge({
    required this.top,
    required this.bottom,
    required this.color,
    required this.textColor,
    required this.width,
    required this.height,
  });

  final String top;
  final String bottom;
  final Color color;
  final Color textColor;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.smRadius,
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            top,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              height: 1.1,
            ),
          ),
          Text(
            bottom,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.85),
              fontSize: 9,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.heat});

  final Heat heat;

  @override
  Widget build(BuildContext context) {
    final color = switch (heat.liveStatus) {
      HeatLiveStatus.live => AppColors.statusError,
      HeatLiveStatus.official => AppColors.statusFinished,
      HeatLiveStatus.unofficial => _headerSlate,
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.pillRadius,
      ),
      child: Text(
        heat.statusBadgeLabel,
        style: AppTypography.badge.copyWith(fontSize: 11),
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: CustomPaint(
        size: const Size(double.infinity, 1),
        painter: _DashedLinePainter(),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 4.0;
    const dashGap = 4.0;
    final paint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
