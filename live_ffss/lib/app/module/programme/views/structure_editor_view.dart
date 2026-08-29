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
import 'package:live_ffss/app/routes/app_pages.dart';

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
        content: Text(m.text),
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
        return Stack(
          children: [
            Column(
              children: [
                Expanded(child: _rounds(s)),
                _PushBar(levelCount: s.levels.length),
              ],
            ),
            if (_controller.isPushing.value) const _PushOverlay(),
          ],
        );
      }),
    );
  }

  Widget _rounds(EventStructure s) {
    return ListView(
      padding: AppSpacing.pageAll,
      children: [
        _SummaryStrip(spotsPerRace: s.spotsPerRace),
        const SizedBox(height: AppSpacing.sm),
        for (var i = 0; i < s.levels.length; i++)
          _LevelCard(index: i, level: s.levels[i]),
        const SizedBox(height: AppSpacing.sm),
        _AddLevelButton(controller: _controller),
      ],
    );
  }
}

/// Entries, of which the ones that will actually start, and the default race
/// size. The gap between the two counts is what decides how many heats a round
/// really needs, so both are shown rather than the roster alone.
class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({required this.spotsPerRace});

  final int spotsPerRace;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StructureEditorController>();
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${controller.entryCount} ${'engaged_count'.tr} · '
                '${controller.eligibleCount} ${'eligible_athletes'.tr}',
                style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
              ),
              Text('$spotsPerRace ${'spots_per_race_default'.tr}',
                  style: AppTypography.caption),
            ],
          ),
        ),
        TextButton(
          onPressed: controller.proposeDefault,
          child: Text('propose_structure'.tr),
        ),
      ],
    );
  }
}

/// Value edits stay on the device; this is what carries them to FFSS. It sends
/// every round on screen, creating those FFSS does not hold and updating the
/// rest, so there is nothing to remember about what changed.
class _PushBar extends StatelessWidget {
  const _PushBar({required this.levelCount});

  final int levelCount;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StructureEditorController>();
    if (levelCount == 0) return const SizedBox.shrink();
    // Signed out the push cannot succeed, so the bar offers the way to fix
    // that instead of an action that only fails at the far end.
    if (!controller.canWriteToFfss) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: () => Get.toNamed<void>(Routes.login),
              icon: const Icon(Icons.lock_outline),
              label: Text('race_format_login_title'.tr),
            ),
          ),
        ),
      );
    }
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: controller.isPushing.value ? null : controller.pushAll,
            icon: const Icon(Icons.cloud_upload_outlined),
            // Creating the déroulement is part of the same tap when there is
            // none, so the label says it rather than surprising the operator.
            label: Text(
              (controller.hasRaceFormat
                      ? 'round_push'
                      : 'round_push_and_create')
                  .trParams({'count': '$levelCount'}),
            ),
          ),
        ),
      ),
    );
  }
}

class _PushOverlay extends StatelessWidget {
  const _PushOverlay();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StructureEditorController>();
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.35),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: AppSpacing.md),
                Text('round_pushing'.tr, style: AppTypography.body),
                Obx(() {
                  final total = controller.pushTotal.value;
                  if (total == 0) return const SizedBox.shrink();
                  return Text('${controller.pushDone.value} / $total',
                      style: AppTypography.caption);
                }),
              ],
            ),
          ),
        ),
      ),
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
  if (confirmed != true) return;

  final outcome = await controller.removeLevel(index);
  if (outcome != LevelRemoval.serverRefused || !context.mounted) return;

  // FFSS would not drop its copy — most often because the partie is already
  // gone from there. Without this the round would sit in the editor for good,
  // undeletable. The operator decides, because on a mere transport failure the
  // partie is still alive on the server.
  final dropAnyway = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('round_delete_local_title'.tr),
      content: Text('round_delete_local_body'.tr),
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
  if (dropAnyway == true) controller.removeLevelLocally(index);
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
                const SizedBox(width: AppSpacing.sm),
                // Says at a glance whether FFSS holds this round. Without it
                // the only way to know is to push and read the snackbar.
                Tooltip(
                  message: level.serverId > 0
                      ? 'round_on_server'.tr
                      : 'round_not_on_server'.tr,
                  child: Icon(
                    level.serverId > 0
                        ? Icons.cloud_done_outlined
                        : Icons.cloud_off_outlined,
                    size: 16,
                    color: level.serverId > 0
                        ? AppColors.statusFinished
                        : AppColors.textMuted,
                  ),
                ),
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
            const SizedBox(height: AppSpacing.sm),
            _QualificationField(index: index, level: level),
          ],
        ),
      ),
    );
  }
}

/// The FFSS qualification logic of a round. The codes are the API's own; a
/// round importing one this app does not list keeps it and shows it raw rather
/// than being silently rewritten to a default on the next push.
class _QualificationField extends StatelessWidget {
  const _QualificationField({required this.index, required this.level});

  final int index;
  final RoundLevel level;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StructureEditorController>();
    final known = qualificationLabelKeys.keys.toList();
    final codes = [
      ...known,
      if (!known.contains(level.qualificationMethod)) level.qualificationMethod,
    ];
    return Row(
      children: [
        Text('qualification'.tr, style: AppTypography.caption),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: level.qualificationMethod,
            isDense: true,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 8),
              border: OutlineInputBorder(),
            ),
            items: [
              for (final code in codes)
                DropdownMenuItem(
                  value: code,
                  child: Text(
                    qualificationLabelKeys[code]?.tr ?? code,
                    style: AppTypography.caption,
                  ),
                ),
            ],
            onChanged: (code) {
              if (code != null) controller.setQualificationMethod(index, code);
            },
          ),
        ),
      ],
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
