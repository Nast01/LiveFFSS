import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/const/format_const.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/module/competitions/controllers/competition_detail_programme_controller.dart';
import 'package:live_ffss/app/presentation/modules/programme/day_sections.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';
import 'package:live_ffss/app/presentation/shared/error_state.dart';
import 'package:live_ffss/app/presentation/shared/gender_badge.dart';
import 'package:live_ffss/app/presentation/shared/loading_indicator.dart';
import 'package:live_ffss/app/routes/app_pages.dart';

class CompetitionDetailProgrammeView
    extends GetView<CompetitionDetailProgrammeController> {
  const CompetitionDetailProgrammeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const LoadingIndicator();
      }
      if (controller.hasError.value) {
        return ErrorState(
          message: 'error_loading_programme'.tr,
          onRetry: () {
            final comp = controller.competition.value;
            if (comp != null) controller.load(comp);
          },
        );
      }
      if (controller.days.isEmpty || !controller.hasProgramme) {
        return EmptyState(icon: Icons.event_busy, title: 'no_programme'.tr);
      }
      return Column(
        children: [
          _DayChips(controller: controller),
          _SiteChips(controller: controller),
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
  const _SiteChips({required this.controller});
  final CompetitionDetailProgrammeController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.xs, AppSpacing.md, 0),
      child: Obx(() {
        final day = controller.selectedDay;
        if (day == null) return const SizedBox.shrink();
        final names = controller.siteNamesFor(day);
        // A day running on a single site needs no picker — the chip would be
        // the only choice on offer.
        if (names.length < 2) return const SizedBox.shrink();
        final active = controller.activeSiteFor(day);
        return SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: names.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (_, i) {
              final name = names[i];
              final isActive = active == name;
              return GestureDetector(
                onTap: () => controller.selectedSite.value = name,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.surface,
                    borderRadius: AppRadius.pillRadius,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    name,
                    style: AppTypography.caption.copyWith(
                        color: isActive ? Colors.white : AppColors.textPrimary),
                  ),
                ),
              );
            },
          ),
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
      final day = controller.selectedDay;
      if (day == null) {
        return EmptyState(icon: Icons.schedule, title: 'no_placement_here'.tr);
      }
      final sections = controller.visibleSectionsFor(day);
      if (sections.isEmpty) {
        return EmptyState(icon: Icons.schedule, title: 'no_placement_here'.tr);
      }
      return ListView(
        padding: AppSpacing.pageAll,
        children: [
          for (final section in sections)
            _SectionView(section: section, controller: controller),
        ],
      );
    });
  }
}

class _SectionView extends StatelessWidget {
  const _SectionView({required this.section, required this.controller});
  final DaySection section;
  final CompetitionDetailProgrammeController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The manual bucket carries no title of its own — naming it is a
          // display concern, kept out of the shared [daySections] helper.
          Text(section.isManual ? 'schedule_manual_items'.tr : section.title,
              style: AppTypography.body.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.xs),
          for (final entry in section.items)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: _ReadonlyCard(entry: entry, controller: controller),
            ),
        ],
      ),
    );
  }
}

class _ReadonlyCard extends StatelessWidget {
  const _ReadonlyCard({required this.entry, required this.controller});
  final DayEntry entry;
  final CompetitionDetailProgrammeController controller;

  @override
  Widget build(BuildContext context) {
    final runId = entry.runId;
    final race = runId == null ? null : controller.raceForRun(runId);
    final accent = runId == null ? AppColors.statusWaiting : AppColors.primary;
    final minutes = entry.end.difference(entry.begin).inMinutes;
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.mdRadius,
      elevation: 1,
      child: InkWell(
        borderRadius: AppRadius.mdRadius,
        onTap: race == null
            ? null
            : () => Get.toNamed<void>(Routes.raceDetail, arguments: {
                  'race': race,
                  'competition': controller.competition.value,
                }),
        // The label wraps, so the card has no height of its own to know up
        // front: IntrinsicHeight is what lets the accent strip run the full
        // height whatever the label costs.
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 5,
                constraints: const BoxConstraints(minHeight: 56),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(children: [
                        Text(FormatConst.timeFormat.format(entry.begin),
                            style: AppTypography.body.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark)),
                        const SizedBox(width: 6),
                        Text(
                            '→ ${FormatConst.timeFormat.format(entry.end)} · $minutes ${'min_short'.tr}',
                            style: AppTypography.caption),
                      ]),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (race != null) ...[
                            GenderBadge(gender: race.gender, size: 18),
                            const SizedBox(width: 6),
                          ],
                          // Wraps rather than ellipsing: the tail of the label
                          // is what tells two races of an épreuve apart.
                          Expanded(
                            child: Text(entry.label, style: AppTypography.body),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (race != null)
                const Padding(
                  padding: EdgeInsets.only(right: AppSpacing.sm),
                  child: Center(
                    child:
                        Icon(Icons.chevron_right, color: AppColors.textMuted),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
