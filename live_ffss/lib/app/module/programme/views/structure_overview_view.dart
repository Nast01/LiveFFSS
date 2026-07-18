import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/module/programme/controllers/programme_controller.dart';
import 'package:live_ffss/app/presentation/modules/programme/programme_formatting.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';
import 'package:live_ffss/app/presentation/shared/error_state.dart';
import 'package:live_ffss/app/presentation/shared/loading_indicator.dart';

class StructureOverviewView extends GetView<ProgrammeController> {
  const StructureOverviewView({super.key});

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
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm,
          AppSpacing.xs,
          AppSpacing.sm,
          AppSpacing.lg,
        ),
        itemCount: controller.rows.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, i) => _OverviewCard(row: controller.rows[i]),
      );
    });
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.row});

  final OverviewRow row;

  @override
  Widget build(BuildContext context) {
    final structure = row.structure;
    final summary = structure == null || !structure.isDefined
        ? 'not_defined'.tr
        : structure.chain.map((t) => t.labelKey.tr).join(' → ');
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        // Task 10 wires onTap to open the structure editor.
        onTap: () {},
        title: Text(
          '${row.raceLabel} · ${row.categoryLabel}',
          style: AppTypography.body,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${row.entryCount} ${'engaged'.tr} · $summary',
          style: AppTypography.caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.textMuted),
      ),
    );
  }
}
