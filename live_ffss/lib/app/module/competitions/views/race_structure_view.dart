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
      final showHeaders = controller.showCategoryHeaders;
      final children = <Widget>[];
      for (final s in controller.structures) {
        if (s.levels.isEmpty) continue;
        if (showHeaders) {
          children.add(_CategoryHeader(
              label: s.categoryLabel,
              engaged: controller.entryCountFor(s.categoryId)));
        }
        for (final level in s.levels) {
          children.add(_RoundHeader(structure: s, level: level));
          for (final r in level.races) {
            children.add(_CourseTile(structure: s, level: level, race: r));
          }
        }
      }
      return ListView(padding: AppSpacing.pageAll, children: children);
    });
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.label, required this.engaged});
  final String label;
  final int engaged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, AppSpacing.sm, 0, AppSpacing.xs),
      child: Row(
        children: [
          Text(label, style: AppTypography.subtitle),
          const SizedBox(width: AppSpacing.sm),
          Text('· $engaged ${'engaged'.tr}', style: AppTypography.caption),
        ],
      ),
    );
  }
}

class _RoundHeader extends StatelessWidget {
  const _RoundHeader({required this.structure, required this.level});
  final EventStructure structure;
  final RoundLevel level;

  @override
  Widget build(BuildContext context) {
    final accent = level.type == RoundType.finale
        ? AppColors.statusFinished
        : AppColors.primary;
    final info = <String>[
      '${structure.spotsPerRace} ${'spots_per_race'.tr}',
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
                  child: Text('${level.type.labelKey.tr} ${race.number}',
                      style: AppTypography.body
                          .copyWith(color: AppColors.textPrimary)),
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
