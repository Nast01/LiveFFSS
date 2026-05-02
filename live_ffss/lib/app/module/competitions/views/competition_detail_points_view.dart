import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/module/competitions/controllers/competition_detail_points_controller.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';
import 'package:live_ffss/app/presentation/shared/error_state.dart';
import 'package:live_ffss/app/presentation/shared/loading_indicator.dart';

class CompetitionDetailPointsView
    extends GetView<CompetitionDetailPointsController> {
  const CompetitionDetailPointsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.md),
        const _PointsPillsRow(),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const LoadingIndicator();
            }
            if (controller.hasError.value) {
              return ErrorState(
                message: 'error_occured'.tr,
                onRetry: controller.retry,
              );
            }
            return IndexedStack(
              index: controller.selectedPointsTab.value,
              children: const [
                _ClubsRankingTab(),
                _IndividualRankingTab(),
                _RelaisRankingTab(),
              ],
            );
          }),
        ),
      ],
    );
  }
}

class _PointsPillsRow extends GetView<CompetitionDetailPointsController> {
  const _PointsPillsRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.pageHorizontal,
      child: Row(
        children: [
          _PointsPill(label: 'clubs_ranking'.tr, index: 0),
          const SizedBox(width: AppSpacing.sm),
          _PointsPill(label: 'individual_ranking'.tr, index: 1),
          const SizedBox(width: AppSpacing.sm),
          _PointsPill(label: 'relais_ranking'.tr, index: 2),
        ],
      ),
    );
  }
}

class _PointsPill extends GetView<CompetitionDetailPointsController> {
  const _PointsPill({required this.label, required this.index});

  final String label;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final active = controller.selectedPointsTab.value == index;
      return GestureDetector(
        onTap: () => controller.setPointsTab(index),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.white,
            borderRadius: AppRadius.pillRadius,
            border: Border.all(color: AppColors.primary),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      );
    });
  }
}

class _ClubsRankingTab extends GetView<CompetitionDetailPointsController> {
  const _ClubsRankingTab();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.clubRankings;
      if (items.isEmpty) {
        return EmptyState(
          icon: Icons.emoji_events_outlined,
          title: 'no_rankings_yet'.tr,
        );
      }
      return ListView.separated(
        padding: AppSpacing.pageHorizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, i) {
          final r = items[i];
          return _RankingRow(
            position: r.position,
            primary: r.clubName,
            secondary: '',
            points: r.points,
          );
        },
      );
    });
  }
}

class _IndividualRankingTab
    extends GetView<CompetitionDetailPointsController> {
  const _IndividualRankingTab();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.individualRankings;
      if (items.isEmpty) {
        return EmptyState(
          icon: Icons.person_outline,
          title: 'no_individual_ranking_yet'.tr,
        );
      }
      return ListView.separated(
        padding: AppSpacing.pageHorizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, i) {
          final r = items[i];
          return _RankingRow(
            position: r.position,
            primary: '${r.athleteFirstName} ${r.athleteLastName}',
            secondary: r.clubName,
            points: r.points,
          );
        },
      );
    });
  }
}

class _RelaisRankingTab extends GetView<CompetitionDetailPointsController> {
  const _RelaisRankingTab();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.relayRankings;
      if (items.isEmpty) {
        return EmptyState(
          icon: Icons.groups_outlined,
          title: 'no_relais_ranking_yet'.tr,
        );
      }
      return ListView.separated(
        padding: AppSpacing.pageHorizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, i) {
          final r = items[i];
          return _RankingRow(
            position: r.position,
            primary: r.teamName,
            secondary: r.clubName,
            points: r.points,
          );
        },
      );
    });
  }
}

class _RankingRow extends StatelessWidget {
  const _RankingRow({
    required this.position,
    required this.primary,
    required this.secondary,
    required this.points,
  });

  final int position;
  final String primary;
  final String secondary;
  final int points;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: AppRadius.smRadius,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '$position',
              style: AppTypography.title.copyWith(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  primary,
                  style: AppTypography.title.copyWith(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (secondary.isNotEmpty)
                  Text(
                    secondary,
                    style: AppTypography.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '$points',
            style: AppTypography.title.copyWith(
              fontSize: 14,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
