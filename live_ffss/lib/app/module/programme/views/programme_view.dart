import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/module/programme/controllers/programme_controller.dart';
import 'package:live_ffss/app/module/programme/views/structure_overview_view.dart';
import 'package:live_ffss/app/presentation/shared/home_wave.dart';

class ProgrammeView extends GetView<ProgrammeController> {
  const ProgrammeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _ProgrammeHeader(),
            const HomeWave(),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: Obx(() => IndexedStack(
                    index: controller.currentTabIndex.value,
                    children: const [
                      StructureOverviewView(),
                      _SchedulePlaceholder(),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgrammeHeader extends GetView<ProgrammeController> {
  const _ProgrammeHeader();

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
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: Get.back,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Obx(() => Text(
                      controller.competition.value?.name ?? '',
                      style: AppTypography.title
                          .copyWith(color: Colors.white, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: AppSpacing.pageHorizontal,
            child: Row(
              children: [
                _Pill(label: 'structure'.tr, index: 0),
                const SizedBox(width: AppSpacing.sm),
                _Pill(label: 'programme'.tr, index: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends GetView<ProgrammeController> {
  const _Pill({required this.label, required this.index});

  final String label;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final active = controller.currentTabIndex.value == index;
      return GestureDetector(
        onTap: () => controller.changeTab(index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
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

// Plan B replaces this with the scheduling view.
class _SchedulePlaceholder extends StatelessWidget {
  const _SchedulePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('programme'.tr, style: AppTypography.subtitle),
    );
  }
}
