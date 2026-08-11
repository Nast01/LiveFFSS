import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/module/programme/controllers/structure_editor_controller.dart';
import 'package:live_ffss/app/module/programme/views/structure_bracket.dart';
import 'package:live_ffss/app/presentation/modules/programme/programme_formatting.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';

class StructureEditorView extends StatefulWidget {
  const StructureEditorView({super.key});

  @override
  State<StructureEditorView> createState() => _StructureEditorViewState();
}

class _StructureEditorViewState extends State<StructureEditorView> {
  final _controller = Get.find<StructureEditorController>();
  bool _showBracket = false;
  late final Worker _messageWorker;

  @override
  void initState() {
    super.initState();
    _messageWorker = ever<UiMessage?>(_controller.message, (m) {
      if (m == null || !mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(m.translationKey.tr),
        backgroundColor:
            m is UiMessageError ? AppColors.statusError : AppColors.primary,
      ));
    });
  }

  @override
  void dispose() {
    _messageWorker.dispose();
    super.dispose();
  }

  /// Re-importing throws away the authored rounds, so it states exactly what is
  /// lost before doing it.
  Future<void> _confirmReimport() async {
    final levels = _controller.structure.value?.levels ?? const [];
    final drawn = levels.fold<int>(
        0,
        (sum, l) =>
            sum + l.races.fold<int>(0, (s, r) => s + r.athleteIds.length));
    final body = [
      'round_reimport_body'.trParams({'rounds': '${levels.length}'}),
      if (drawn > 0) 'round_delete_body_drawn'.trParams({'athletes': '$drawn'}),
    ].join('\n\n');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('round_reimport_title'.tr),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('confirm'.tr),
          ),
        ],
      ),
    );
    if (confirmed == true) _controller.reimportFromServer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        // "Paddle Board · Messieurs · Minime" does not fit one line on a phone.
        // Two lines plus a taller bar shows it in full; the bracket toggle is
        // an icon rather than a label so it steals no width from the title.
        toolbarHeight: 72,
        titleSpacing: 0,
        title: Obx(() {
          final s = _controller.structure.value;
          return Text(
            s == null
                ? ''
                : structureTitle(
                    raceLabel: s.raceLabel,
                    gender: _controller.gender,
                    categoryLabel: s.categoryLabel,
                  ),
            style: AppTypography.title.copyWith(
              color: Colors.white,
              fontSize: 15,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
          );
        }),
        actions: [
          // Only shown when FFSS actually declares rounds — otherwise there is
          // nothing to re-import and the icon would just eat title width.
          if (_controller.hasServerRounds)
            IconButton(
              onPressed: _confirmReimport,
              tooltip: 'round_reimport'.tr,
              icon: const Icon(Icons.cloud_download_outlined),
            ),
          IconButton(
            onPressed: () => setState(() => _showBracket = !_showBracket),
            tooltip: 'view_bracket'.tr,
            icon: Icon(_showBracket
                ? Icons.list_alt_outlined
                : Icons.account_tree_outlined),
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
                Text('${s.spotsPerRace} ${'spots_per_race_default'.tr}',
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

/// Deleting a round drops its races and any heats drawn into them, and — when
/// the round came from FFSS — removes it from the federation server as well.
/// Neither can be undone, hence the confirmation.
Future<void> _confirmRemoveLevel(
  BuildContext context,
  StructureEditorController controller,
  int index,
  RoundLevel level,
) async {
  final drawnAthletes =
      level.races.fold<int>(0, (sum, r) => sum + r.athleteIds.length);
  final body = [
    'round_delete_body'.trParams({'races': '${level.races.length}'}),
    if (drawnAthletes > 0)
      'round_delete_body_drawn'.trParams({'athletes': '$drawnAthletes'}),
    if (level.serverId > 0) 'round_delete_body_server'.tr,
  ].join('\n\n');

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(
          'round_delete_title'.trParams({'round': level.type.labelKey.tr})),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text('cancel'.tr),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: TextButton.styleFrom(foregroundColor: AppColors.statusError),
          child: Text('delete'.tr),
        ),
      ],
    ),
  );
  if (confirmed == true) await controller.removeLevel(index);
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
                // Greyed out rather than refused with a message: the hierarchy
                // is série < quart < demi < finale, and a dead arrow states it
                // without any copy to read.
                _MoveButton(
                  icon: Icons.arrow_upward,
                  tooltipKey: 'move_up',
                  index: index,
                  delta: -1,
                ),
                _MoveButton(
                  icon: Icons.arrow_downward,
                  tooltipKey: 'move_down',
                  index: index,
                  delta: 1,
                ),
                Obx(() => IconButton(
                      icon: controller.isDeletingLevel.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.delete_outline),
                      color: AppColors.statusError,
                      // A round backed by FFSS is deleted server-side first,
                      // so the button must not be re-armed mid-call.
                      onPressed: controller.isDeletingLevel.value
                          ? null
                          : () => _confirmRemoveLevel(
                                context,
                                controller,
                                index,
                                level,
                              ),
                    )),
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
            // Per round: FFSS runs a semi at 18 feeding a final at 16.
            _Stepper(
              label: 'spots_per_race'.tr,
              value: controller.structure.value == null
                  ? level.spotsPerRace
                  : controller.structure.value!.spotsForLevel(level),
              onChanged: (v) => controller.setLevelSpotsPerRace(index, v),
            ),
          ],
        ),
      ),
    );
  }
}

/// One reorder arrow. Compact so the label, both arrows and the delete button
/// still fit one line on a phone.
class _MoveButton extends StatelessWidget {
  const _MoveButton({
    required this.icon,
    required this.tooltipKey,
    required this.index,
    required this.delta,
  });

  final IconData icon;
  final String tooltipKey;
  final int index;
  final int delta;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StructureEditorController>();
    return Obx(() {
      final allowed = controller.canMoveLevel(index, delta);
      return IconButton(
        icon: Icon(icon),
        iconSize: 20,
        visualDensity: VisualDensity.compact,
        tooltip: tooltipKey.tr,
        color: AppColors.primary,
        onPressed: allowed ? () => controller.moveLevel(index, delta) : null,
      );
    });
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
