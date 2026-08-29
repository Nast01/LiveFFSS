import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/module/programme/controllers/programme_controller.dart';
import 'package:live_ffss/app/module/programme/controllers/structure_editor_controller.dart';
import 'package:live_ffss/app/module/programme/views/structure_filter_bar.dart';
import 'package:live_ffss/app/module/programme/views/structure_server_state.dart';
import 'package:live_ffss/app/presentation/modules/competitions/race_formatting.dart';
import 'package:live_ffss/app/presentation/modules/programme/programme_formatting.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';
import 'package:live_ffss/app/presentation/shared/error_state.dart';
import 'package:live_ffss/app/presentation/shared/loading_indicator.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';
import 'package:live_ffss/app/routes/app_pages.dart';

class StructureOverviewView extends StatefulWidget {
  const StructureOverviewView({super.key});

  @override
  State<StructureOverviewView> createState() => _StructureOverviewViewState();
}

class _StructureOverviewViewState extends State<StructureOverviewView> {
  late final ProgrammeController controller;
  late final Worker _messageWorker;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ProgrammeController>();
    _messageWorker = ever<UiMessage?>(controller.message, (m) {
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

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) return const LoadingIndicator();
      if (controller.hasError.value) {
        return ErrorState(
          message: 'error_occured'.tr,
          onRetry: () {
            final comp = controller.competition.value;
            if (comp != null) controller.load(comp);
          },
        );
      }
      if (controller.rows.isEmpty) {
        return EmptyState(
          icon: Icons.rule_folder_outlined,
          title: 'no_structures'.tr,
        );
      }
      final filtered = controller.hasActiveFilters;
      final visible = controller.visibleRows;
      return Stack(
        children: [
          _overview(context, filtered, visible),
          // One request per déroulement means a full programme is dozens of
          // round trips. The overlay both reports progress and stops a second
          // tap from starting a competing run.
          if (controller.isSubmitting.value) const _SubmitOverlay(),
        ],
      );
    });
  }

  Widget _overview(
    BuildContext context,
    bool filtered,
    List<OverviewRow> visible,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.xs,
            AppSpacing.sm,
            0,
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.generatableCount > 0
                      ? controller.generateAllDefaults
                      : null,
                  icon: const Icon(Icons.bolt),
                  label: Text(
                    filtered
                        ? 'generate_default_visible'.trParams(
                            {'count': '${controller.generatableCount}'})
                        : 'generate_default_all'.tr,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: controller.hasAnyStructure
                    ? () => _confirmDeleteAll(context, controller)
                    : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.statusError,
                ),
                icon: const Icon(Icons.delete_outline),
                label: Text(
                  filtered
                      ? 'delete_visible'
                          .trParams({'count': '${controller.deletableCount}'})
                      : 'delete_all'.tr,
                ),
              ),
            ],
          ),
        ),
        const StructureFilterBar(),
        const StructureServerState(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: controller.reload,
            child: visible.isEmpty
                ? _NoMatch(onReset: controller.clearFilters)
                : ListView.separated(
                    // Without this a short list cannot overscroll, so the
                    // pull gesture would never fire.
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.sm,
                      AppSpacing.xs,
                      AppSpacing.sm,
                      AppSpacing.lg,
                    ),
                    itemCount: visible.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (_, i) => _OverviewCard(row: visible[i]),
                  ),
          ),
        ),
      ],
    );
  }
}

/// Covers the list while déroulements are being pushed to FFSS, and says how
/// far along the run is — dozens of round trips otherwise look like a freeze.
class _SubmitOverlay extends StatelessWidget {
  const _SubmitOverlay();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProgrammeController>();
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.35),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.mdRadius,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: AppSpacing.md),
                Text('race_format_creating'.tr, style: AppTypography.body),
                Obx(() {
                  final total = controller.submitTotal.value;
                  if (total == 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      '${controller.submitDone.value} / $total',
                      style: AppTypography.caption,
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shown when the filters hide every row. Scrollable so the pull-to-refresh
/// wrapping it still fires, and it carries the way out of the filters — a dead
/// end whose only escape is the chips above it reads as a broken list.
class _NoMatch extends StatelessWidget {
  const _NoMatch({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      children: [
        EmptyState(
          icon: Icons.filter_alt_off_outlined,
          title: 'no_structures_for_filters'.tr,
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: TextButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.filter_alt_off_outlined),
            label: Text('reset_filters'.tr),
          ),
        ),
      ],
    );
  }
}

/// Deleting a structure also destroys the heats drawn into its races, so both
/// entry points confirm first. Returns true when the operator went through.
Future<bool> _confirm(
  BuildContext context, {
  required String title,
  required String body,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
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
  return confirmed == true;
}

Future<void> _confirmDeleteAll(
  BuildContext context,
  ProgrammeController controller,
) async {
  // Under a filter the action no longer means "everything", so the wording
  // says how many rows it takes and that the hidden ones are spared.
  final count = '${controller.deletableCount}';
  final ok = await _confirm(
    context,
    title: controller.hasActiveFilters
        ? 'delete_visible_structures_title'.trParams({'count': count})
        : 'delete_all_structures_title'.tr,
    body: controller.hasActiveFilters
        ? 'delete_visible_structures_body'.trParams({'count': count})
        : 'delete_structures_body'.tr,
  );
  if (ok) await controller.deleteAllStructures();
}

/// Says whether FFSS holds a déroulement for this épreuve × category, and how
/// many rounds it declares. A row without one carries the action to create it.
class _RaceFormatBadge extends StatelessWidget {
  const _RaceFormatBadge({required this.row});

  final OverviewRow row;

  @override
  Widget build(BuildContext context) {
    final format = row.raceFormat;
    if (format == null) {
      return _Chip(
        icon: Icons.cloud_off_outlined,
        color: AppColors.statusWaiting,
        label: 'race_format_absent'.tr,
        onTap: () => _confirmCreateOne(context, row),
      );
    }
    final rounds = format.details.length;
    return _Chip(
      icon: Icons.cloud_done_outlined,
      color: AppColors.statusFinished,
      label: rounds == 0
          ? 'race_format_present_no_round'.tr
          : 'race_format_present'.trParams({'count': '$rounds'}),
    );
  }
}

Future<void> _confirmCreateOne(BuildContext context, OverviewRow row) async {
  final controller = Get.find<ProgrammeController>();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('race_format_create_title'.tr),
      content: Text('race_format_create_one_body'.trParams({
        'race': row.raceLabel,
        'gender': row.gender.label,
      })),
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
  if (confirmed == true) await controller.createRaceFormatFor(row);
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.color,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: AppTypography.caption.copyWith(color: color),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(Icons.add_circle_outline, size: 13, color: color),
            ],
          ],
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.row});

  final OverviewRow row;

  @override
  Widget build(BuildContext context) {
    final structure = row.structure;
    final summary = _summaryFor(structure);
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: () => Get.toNamed<void>(
          Routes.structureEditor,
          arguments: StructureEditorArgs(
            competitionId:
                Get.find<ProgrammeController>().competition.value!.id,
            raceId: row.raceId,
            categoryId: row.categoryId,
            raceLabel: row.raceLabel,
            categoryLabel: row.categoryLabel,
            entryCount: row.entryCount,
            gender: row.gender,
            defaultSpotsPerRace: row.defaultSpotsPerRace,
            serverDetails: row.raceFormat?.details ?? const [],
          ),
        ),
        title: Text(
          structureTitle(
            raceLabel: row.raceLabel,
            gender: row.gender,
            categoryLabel: row.categoryLabel,
          ),
          style: AppTypography.body,
          // Adding the gender pushed titles like "Paddle Board · Messieurs ·
          // Minime" past one line on a phone.
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${row.entryCount} ${'engaged'.tr} · $summary',
              style: AppTypography.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            _RaceFormatBadge(row: row),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (structure != null)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: AppColors.statusError,
                tooltip: 'delete_structure_title'.tr,
                onPressed: () async {
                  final ok = await _confirm(
                    context,
                    title: 'delete_structure_title'.tr,
                    body: 'delete_structures_body'.tr,
                  );
                  if (ok) {
                    await Get.find<ProgrammeController>()
                        .deleteStructure(row.raceId, row.categoryId);
                  }
                },
              ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  String _summaryFor(EventStructure? structure) {
    if (structure == null || !structure.isDefined) return 'not_defined'.tr;
    final chain = structure.chain;
    if (chain.length == 1 && chain.single == RoundType.finale) {
      return 'direct_final'.tr;
    }
    return chain.map((t) => t.labelKey.tr).join(' → ');
  }
}
