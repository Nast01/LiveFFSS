import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/module/programme/controllers/programme_controller.dart';
import 'package:live_ffss/app/presentation/modules/competitions/race_formatting.dart';

/// Names one selectable value. Every criterion but the gender carries a server
/// label, which is shown as-is; a gender is an enum the view translates.
String _optionLabel(FilterOption option) {
  final value = option.value;
  return value is Gender ? value.label : option.label;
}

String _criterionLabel(StructureFilter filter) => switch (filter) {
      StructureFilter.speciality => 'filter_speciality'.tr,
      StructureFilter.discipline => 'filter_discipline'.tr,
      StructureFilter.gender => 'filter_gender'.tr,
      StructureFilter.category => 'filter_category'.tr,
    };

/// The one-line filter bar above the structure list: a chip per criterion, the
/// visible/total count, and a way out of every filter at once.
class StructureFilterBar extends StatelessWidget {
  const StructureFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProgrammeController>();
    return Obx(() {
      final total = controller.rows.length;
      final visible = controller.visibleRows.length;
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Row(
                children: [
                  for (final filter in StructureFilter.values) ...[
                    _CriterionChip(filter: filter),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                ],
              ),
            ),
            if (controller.hasActiveFilters)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sm, AppSpacing.xs, AppSpacing.sm, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'filter_visible_count'
                          .trParams({'visible': '$visible', 'total': '$total'}),
                      style: AppTypography.caption,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    GestureDetector(
                      onTap: controller.clearFilters,
                      child: Text(
                        'reset_filters'.tr,
                        style: AppTypography.caption
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _CriterionChip extends StatelessWidget {
  const _CriterionChip({required this.filter});

  final StructureFilter filter;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProgrammeController>();
    return Obx(() {
      final options = controller.optionsFor(filter);
      final count = controller.selectedCount(filter);
      final active = count > 0;
      // One ticked value reads better by name than as a count — "Genre · 1"
      // tells the operator nothing they cannot already see.
      final label = switch (count) {
        0 => _criterionLabel(filter),
        1 => _optionLabel(
            options.firstWhere((o) => controller.isSelected(filter, o.value))),
        _ => '${_criterionLabel(filter)} · $count',
      };
      return InkWell(
        borderRadius: AppRadius.pillRadius,
        onTap: options.isEmpty ? null : () => _openSheet(context, filter),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.white,
            borderRadius: AppRadius.pillRadius,
            border: Border.all(
              color: options.isEmpty ? AppColors.border : AppColors.primary,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: active
                      ? Colors.white
                      : (options.isEmpty
                          ? AppColors.textMuted
                          : AppColors.primary),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 2),
              if (active)
                GestureDetector(
                  onTap: () => controller.clear(filter),
                  child: const Icon(Icons.close, size: 15, color: Colors.white),
                )
              else
                Icon(
                  Icons.expand_more,
                  size: 16,
                  color:
                      options.isEmpty ? AppColors.textMuted : AppColors.primary,
                ),
            ],
          ),
        ),
      );
    });
  }
}

/// Opened from the view, with its own [context] — controllers in this codebase
/// never reach for `Get.dialog`.
void _openSheet(BuildContext context, StructureFilter filter) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (_) => _FilterSheet(filter: filter),
  );
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet({required this.filter});

  final StructureFilter filter;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProgrammeController>();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Obx(() {
          final options = controller.optionsFor(filter);
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(_criterionLabel(filter),
                        style: AppTypography.subtitle),
                  ),
                  if (controller.selectedCount(filter) > 0)
                    TextButton(
                      onPressed: () => controller.clear(filter),
                      child: Text('filter_clear'.tr),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final option in options)
                    FilterChip(
                      label: Text(_optionLabel(option)),
                      selected: controller.isSelected(filter, option.value),
                      onSelected: (_) =>
                          controller.toggle(filter, option.value),
                    ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}
