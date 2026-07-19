import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/module/competitions/controllers/race_detail_controller.dart';
import 'package:live_ffss/app/module/competitions/views/race_detail_entries_view.dart';
import 'package:live_ffss/app/module/competitions/views/race_structure_view.dart';
import 'package:live_ffss/app/module/competitions/views/race_detail_summary_view.dart';
import 'package:live_ffss/app/presentation/modules/competitions/race_formatting.dart';
import 'package:live_ffss/app/presentation/shared/home_wave.dart';

class RaceDetailView extends GetView<RaceDetailController> {
  const RaceDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          final race = controller.race.value;
          if (race == null) {
            return Center(
              child: Text('no_race_selected'.tr, style: AppTypography.subtitle),
            );
          }
          return Column(
            children: [
              const _RaceDetailHeader(),
              const HomeWave(),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: Obx(() => IndexedStack(
                      index: controller.currentTabIndex.value,
                      children: const [
                        RaceDetailEntriesView(),
                        RaceStructureView(),
                        RaceDetailSummaryView(),
                      ],
                    )),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _RaceDetailHeader extends GetView<RaceDetailController> {
  const _RaceDetailHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xs,
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.md,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: Get.back,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Obx(() {
                  final race = controller.race.value;
                  final competition = controller.competition.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (competition != null)
                        Text(
                          competition.name,
                          style: AppTypography.body.copyWith(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      Text(
                        race?.label ?? '',
                        style: AppTypography.title.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(width: AppSpacing.sm),
              const _LiveBadge(),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: AppSpacing.pageHorizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _HeaderTab(label: 'entries'.tr, index: 0),
                _HeaderTab(label: 'heats'.tr, index: 1),
                _HeaderTab(label: 'summary'.tr, index: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.statusError,
        borderRadius: AppRadius.pillRadius,
      ),
      child: Text('live'.tr,
          style: AppTypography.badge.copyWith(fontSize: 11)),
    );
  }
}

class _HeaderTab extends GetView<RaceDetailController> {
  const _HeaderTab({required this.label, required this.index});

  final String label;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final active = controller.currentTabIndex.value == index;
      return GestureDetector(
        onTap: () => controller.changeTab(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.statusWaiting : Colors.transparent,
            borderRadius: AppRadius.pillRadius,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? AppColors.textPrimary : Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      );
    });
  }
}
