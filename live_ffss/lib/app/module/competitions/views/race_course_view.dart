import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/module/competitions/controllers/race_course_controller.dart';
import 'package:live_ffss/app/presentation/modules/programme/programme_formatting.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';

class RaceCourseView extends GetView<RaceCourseController> {
  const RaceCourseView({super.key});

  @override
  Widget build(BuildContext context) {
    final raceName = controller.race.value?.name ?? '';
    final round = '${controller.roundType.labelKey.tr} ${controller.raceNumber}';
    final subtitle = controller.categoryLabel.isEmpty
        ? round
        : '${controller.categoryLabel} · $round';
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(raceName,
                style: AppTypography.title
                    .copyWith(color: Colors.white, fontSize: 16)),
            Text(subtitle,
                style: AppTypography.caption.copyWith(color: Colors.white70)),
          ],
        ),
      ),
      body: EmptyState(
          icon: Icons.timer_outlined, title: 'results_coming_soon'.tr),
    );
  }
}
