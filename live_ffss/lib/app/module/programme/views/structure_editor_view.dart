import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/module/programme/controllers/structure_editor_controller.dart';
import 'package:live_ffss/app/module/programme/views/structure_bracket.dart';
import 'package:live_ffss/app/presentation/modules/programme/programme_formatting.dart';

class StructureEditorView extends StatefulWidget {
  const StructureEditorView({super.key});

  @override
  State<StructureEditorView> createState() => _StructureEditorViewState();
}

class _StructureEditorViewState extends State<StructureEditorView> {
  final _controller = Get.find<StructureEditorController>();
  bool _showBracket = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Obx(() {
          final s = _controller.structure.value;
          return Text(
            s == null ? '' : '${s.raceLabel} · ${s.categoryLabel}',
            style: AppTypography.title.copyWith(color: Colors.white, fontSize: 16),
          );
        }),
        actions: [
          TextButton(
            onPressed: () => setState(() => _showBracket = !_showBracket),
            child: Text('view_bracket'.tr,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Obx(() {
        final s = _controller.structure.value;
        if (s == null) return const SizedBox.shrink();
        if (_showBracket) return StructureBracket(levels: s.levels);
        return ListView(
          padding: AppSpacing.pageAll,
          children: [
            Row(
              children: [
                Text('${s.spotsPerRace} ${'spots_per_race'.tr}',
                    style: AppTypography.caption),
                const Spacer(),
                TextButton(
                  onPressed: _controller.proposeDefault,
                  child: Text('propose_structure'.tr),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            for (var i = 0; i < s.levels.length; i++)
              _LevelCard(index: i, level: s.levels[i]),
            const SizedBox(height: AppSpacing.sm),
            _AddLevelButton(controller: _controller),
          ],
        );
      }),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.index, required this.level});

  final int index;
  final RoundLevel level;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StructureEditorController>();
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(level.type.labelKey.tr.toUpperCase(),
                    style: AppTypography.body
                        .copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => controller.removeLevel(index),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _Stepper(
                    label: 'races_count'.tr,
                    value: level.races.length,
                    onChanged: (v) => controller.setRaceCount(index, v),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _Stepper(
                    label: 'qualifiers_per_race'.tr,
                    value: level.qualifiersPerRace,
                    onChanged: (v) => controller.setQualifiers(index, v),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.caption),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: value > 0 ? () => onChanged(value - 1) : null,
            ),
            Text('$value', style: AppTypography.body),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => onChanged(value + 1),
            ),
          ],
        ),
      ],
    );
  }
}

class _AddLevelButton extends StatelessWidget {
  const _AddLevelButton({required this.controller});

  final StructureEditorController controller;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<RoundType>(
      onSelected: controller.addLevel,
      itemBuilder: (_) => [
        for (final type in const [
          RoundType.serie,
          RoundType.quart,
          RoundType.demi,
          RoundType.finale,
        ])
          PopupMenuItem(value: type, child: Text(type.labelKey.tr)),
      ],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add, color: AppColors.primary),
          const SizedBox(width: AppSpacing.xs),
          Text('add_level'.tr,
              style: AppTypography.body.copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }
}
