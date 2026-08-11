import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/module/competitions/controllers/race_structure_controller.dart';
import 'package:live_ffss/app/presentation/modules/programme/programme_formatting.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';
import 'package:live_ffss/app/presentation/shared/loading_indicator.dart';
import 'package:live_ffss/app/routes/app_pages.dart';

class RaceStructureView extends GetView<RaceStructureController> {
  const RaceStructureView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const LoadingIndicator();
      }
      if (!controller.hasStructure) {
        return EmptyState(
            icon: Icons.account_tree_outlined,
            title: 'no_structure_defined'.tr);
      }
      final tab = controller.selectedTab;
      if (tab == null) {
        return EmptyState(
            icon: Icons.account_tree_outlined,
            title: 'no_structure_defined'.tr);
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _RoundBar(),
          Expanded(child: _RoundPane(tab: tab)),
        ],
      );
    });
  }
}

/// The round menu bar: one pill per category × round, scrolling sideways when
/// the race carries more than a screenful.
class _RoundBar extends StatelessWidget {
  const _RoundBar();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RaceStructureController>();
    return Obx(() {
      final tabs = controller.tabs;
      final selected = controller.selectedTabIndex.value;
      // On a single-category race the category is the same on every pill, so
      // repeating it there says nothing — the round alone identifies the tab.
      final withCategory = controller.showCategoryHeaders;
      return SizedBox(
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: AppSpacing.pageHorizontal,
          itemCount: tabs.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (_, i) {
            final tab = tabs[i];
            final active = i == selected;
            final label = withCategory
                ? '${tab.categoryLabel} · ${tab.type.labelKey.tr}'
                : tab.type.labelKey.tr;
            return GestureDetector(
              onTap: () => controller.selectTab(i),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.surface,
                  borderRadius: AppRadius.pillRadius,
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  label,
                  style: AppTypography.caption.copyWith(
                      fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                      color: active ? Colors.white : AppColors.textPrimary),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

/// What the selected pill opens: the chain recap of its category, the draw
/// action, then the races of that one round.
class _RoundPane extends StatelessWidget {
  const _RoundPane({required this.tab});
  final RoundTab tab;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RaceStructureController>();
    final structure = tab.structure;
    final level = tab.level;
    return ListView(
      padding: AppSpacing.pageAll,
      children: [
        _ChainRecap(
          structure: structure,
          engaged: controller.entryCountFor(structure.categoryId),
        ),
        _DrawHeatsButton(structure: structure, roundType: level.type),
        _RoundBanner(structure: structure, level: level),
        if (level.races.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text('no_races_in_round'.tr,
                style: AppTypography.caption, textAlign: TextAlign.center),
          )
        else
          for (final r in level.races)
            _CourseTile(structure: structure, level: level, race: r),
      ],
    );
  }
}

/// The whole chain of the selected category, so the structure stays readable
/// while only one of its rounds is on screen.
class _ChainRecap extends StatelessWidget {
  const _ChainRecap({required this.structure, required this.engaged});
  final EventStructure structure;
  final int engaged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${structure.categoryLabel} · $engaged ${'engaged'.tr}',
              style: AppTypography.subtitle),
          const SizedBox(height: 2),
          Text(structure.chainSummary, style: AppTypography.caption),
        ],
      ),
    );
  }
}

class _DrawHeatsButton extends StatelessWidget {
  const _DrawHeatsButton({required this.structure, required this.roundType});
  final EventStructure structure;
  final RoundType roundType;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RaceStructureController>();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          icon: const Icon(Icons.shuffle, size: 18),
          label: Text('heat_draw_action'.tr),
          onPressed: () async {
            await Get.toNamed<void>(Routes.heatDraw, arguments: {
              'race': controller.race.value,
              'competition': controller.competition.value,
              'categoryId': structure.categoryId,
              'categoryLabel': structure.categoryLabel,
              // Opens the draw on the round being shown rather than on the
              // first one of the structure.
              'roundType': roundType,
            });
            // The draw writes into the programme, so the structure shown here
            // is stale on the way back.
            final race = controller.race.value;
            final competition = controller.competition.value;
            if (race != null && competition != null) {
              await controller.load(race, competition);
            }
          },
        ),
      ),
    );
  }
}

class _RoundBanner extends StatelessWidget {
  const _RoundBanner({required this.structure, required this.level});
  final EventStructure structure;
  final RoundLevel level;

  @override
  Widget build(BuildContext context) {
    final accent = level.type == RoundType.finale
        ? AppColors.statusFinished
        : AppColors.primary;
    final info = <String>[
      '${structure.spotsForLevel(level)} ${'spots_per_race'.tr}',
      if (level.qualifiersPerRace > 0)
        '${level.qualifiersPerRace} ${'qualifiers_per_race'.tr}',
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, AppSpacing.sm, 0, AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(AppRadius.sm)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(level.type.labelKey.tr,
              style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const Spacer(),
          Flexible(
            child: Text(info.join(' · '),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption),
          ),
        ],
      ),
    );
  }
}

class _CourseTile extends StatelessWidget {
  const _CourseTile({
    required this.structure,
    required this.level,
    required this.race,
  });
  final EventStructure structure;
  final RoundLevel level;
  final ProgrammeRace race;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RaceStructureController>();
    final accent = level.type == RoundType.finale
        ? AppColors.statusFinished
        : AppColors.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadius.mdRadius,
        elevation: 1,
        child: InkWell(
          borderRadius: AppRadius.mdRadius,
          onTap: () => Get.toNamed<void>(Routes.raceCourse, arguments: {
            'race': controller.race.value,
            'competition': controller.competition.value,
            'categoryId': structure.categoryId,
            'categoryLabel': structure.categoryLabel,
            'roundType': level.type,
            'raceNumber': race.number,
            'programmeRaceId': race.id,
          }),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: AppRadius.smRadius,
                  ),
                  child: Text('${race.number}',
                      style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w800, color: accent)),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${level.type.labelKey.tr} ${race.number}',
                          style: AppTypography.body
                              .copyWith(color: AppColors.textPrimary)),
                      if (race.athleteIds.isNotEmpty)
                        Text(
                          '${race.athleteIds.length} ${'athletes_lower'.tr}',
                          style: AppTypography.caption,
                        ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
