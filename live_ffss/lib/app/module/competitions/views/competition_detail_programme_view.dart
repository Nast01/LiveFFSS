import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/const/format_const.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/domain/models/schedule_planner.dart';
import 'package:live_ffss/app/module/competitions/controllers/competition_detail_programme_controller.dart';
import 'package:live_ffss/app/presentation/modules/programme/programme_formatting.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';
import 'package:live_ffss/app/presentation/shared/loading_indicator.dart';
import 'package:live_ffss/app/routes/app_pages.dart';

class CompetitionDetailProgrammeView
    extends GetView<CompetitionDetailProgrammeController> {
  const CompetitionDetailProgrammeView({super.key});

  String _hhmm(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const LoadingIndicator();
      }
      if (controller.days.isEmpty || !controller.hasProgramme) {
        return EmptyState(icon: Icons.event_busy, title: 'no_programme'.tr);
      }
      return Column(
        children: [
          _DayChips(controller: controller),
          _SiteChips(controller: controller, hhmm: _hhmm),
          const SizedBox(height: AppSpacing.xs),
          Expanded(child: _ReadonlyTimeline(controller: controller)),
        ],
      );
    });
  }
}

class _DayChips extends StatelessWidget {
  const _DayChips({required this.controller});
  final CompetitionDetailProgrammeController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Obx(() {
        final selected = controller.selectedDayIndex.value;
        final days = controller.days;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: AppSpacing.pageHorizontal,
          itemCount: days.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (_, i) {
            final active = selected == i;
            return GestureDetector(
              onTap: () => controller.selectedDayIndex.value = i,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: active ? AppColors.statusWaiting : AppColors.surface,
                  borderRadius: AppRadius.pillRadius,
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  FormatConst.dateFormat.format(days[i]),
                  style: AppTypography.caption.copyWith(
                      color: active ? Colors.white : AppColors.textPrimary),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _SiteChips extends StatelessWidget {
  const _SiteChips({required this.controller, required this.hhmm});
  final CompetitionDetailProgrammeController controller;
  final String Function(int minutes) hhmm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.xs, AppSpacing.md, 0),
      child: Obx(() {
        final sites = controller.sites;
        final selectedId = controller.selectedSiteId.value;
        final day = controller.selectedDay;
        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: sites.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (_, i) {
                    final s = sites[i];
                    final active = selectedId == s.id;
                    return GestureDetector(
                      onTap: () => controller.selectedSiteId.value = s.id,
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: active ? AppColors.primary : AppColors.surface,
                          borderRadius: AppRadius.pillRadius,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          s.name,
                          style: AppTypography.caption.copyWith(
                              color: active
                                  ? Colors.white
                                  : AppColors.textPrimary),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (selectedId != null && day != null)
              Container(
                margin: const EdgeInsets.only(left: AppSpacing.sm),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: AppRadius.pillRadius,
                ),
                child: Text(
                  '${'starts_at'.tr} ${hhmm(controller.startMinutesFor(selectedId, day))}',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.primaryDark),
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _ReadonlyTimeline extends StatelessWidget {
  const _ReadonlyTimeline({required this.controller});
  final CompetitionDetailProgrammeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final siteId = controller.selectedSiteId.value;
      final day = controller.selectedDay;
      if (siteId == null || day == null) {
        return EmptyState(icon: Icons.schedule, title: 'no_placement_here'.tr);
      }
      final rows = controller.rowsFor(siteId, day);
      if (rows.isEmpty) {
        return EmptyState(icon: Icons.schedule, title: 'no_placement_here'.tr);
      }
      return ListView.separated(
        padding: AppSpacing.pageAll,
        itemCount: rows.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
        itemBuilder: (_, i) =>
            _ReadonlyCard(row: rows[i], controller: controller),
      );
    });
  }
}

class _ReadonlyCard extends StatelessWidget {
  const _ReadonlyCard({required this.row, required this.controller});
  final ScheduleRow row;
  final CompetitionDetailProgrammeController controller;

  @override
  Widget build(BuildContext context) {
    final b = row.block;
    final isManual = b.raceId == null;
    final accent = isManual
        ? AppColors.statusWaiting
        : (controller.roundOf(b.raceId!) == RoundType.finale
            ? AppColors.statusFinished
            : AppColors.primary);
    final label =
        isManual ? b.manualLabel : (controller.itemFor(b.raceId!)?.label ?? '');
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.mdRadius,
      elevation: 1,
      child: InkWell(
        borderRadius: AppRadius.mdRadius,
        onTap: isManual
            ? null
            : () {
                final race = controller.raceForBlock(b.raceId!);
                if (race != null) {
                  Get.toNamed<void>(Routes.raceDetail, arguments: {
                    'race': race,
                    'competition': controller.competition.value,
                  });
                }
              },
        child: Row(
          children: [
            Container(
              width: 5,
              height: 56,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(AppRadius.md)),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(children: [
                      Text(FormatConst.timeFormat.format(row.begin),
                          style: AppTypography.body.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark)),
                      const SizedBox(width: 6),
                      Text(
                          '→ ${FormatConst.timeFormat.format(row.end)} · ${b.durationMinutes} ${'min_short'.tr}',
                          style: AppTypography.caption),
                    ]),
                    Text(label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body),
                  ],
                ),
              ),
            ),
            if (!isManual)
              const Padding(
                padding: EdgeInsets.only(right: AppSpacing.sm),
                child: Icon(Icons.chevron_right, color: AppColors.textMuted),
              ),
          ],
        ),
      ),
    );
  }
}
