import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/presentation/modules/programme/programme_formatting.dart';

/// Read-only visual overview: levels as columns, races as nodes. Horizontal
/// scroll on mobile. Editing happens in the form, not here.
class StructureBracket extends StatelessWidget {
  const StructureBracket({required this.levels, super.key});

  final List<RoundLevel> levels;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: AppSpacing.pageAll,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < levels.length; i++) ...[
            _LevelColumn(level: levels[i]),
            if (i < levels.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Icon(Icons.arrow_forward, color: AppColors.textMuted),
              ),
          ],
        ],
      ),
    );
  }
}

class _LevelColumn extends StatelessWidget {
  const _LevelColumn({required this.level});

  final RoundLevel level;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(level.type.labelKey.tr.toUpperCase(),
            style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.xs),
        for (final race in level.races)
          Container(
            width: 120,
            margin: const EdgeInsets.only(bottom: AppSpacing.xs),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.smRadius,
              border: Border.all(color: AppColors.border),
            ),
            child: Text('${level.type.labelKey.tr} ${race.number}',
                style: AppTypography.caption),
          ),
      ],
    );
  }
}
