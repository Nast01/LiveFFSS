import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/presentation/modules/competitions/race_formatting.dart';

/// One selectable value of a criterion: what rows are matched on, and how to
/// name it in the selection sheet.
///
/// [label] is left empty for a [Gender], whose name is a translated word the
/// controller producing these has no business resolving — [FilterChipBar]
/// translates it at render.
class FilterOption {
  const FilterOption(this.value, this.label);

  final Object value;
  final String label;
}

/// One criterion the bar offers: its name, its values, and the state and
/// callbacks that let the bar read and change what is ticked.
class FilterCriterion {
  const FilterCriterion({
    required this.labelKey,
    required this.options,
    required this.selectedCount,
    required this.isSelected,
    required this.onToggle,
    required this.onClear,
  });

  /// Translation key naming the criterion — `filter_gender` and the like.
  final String labelKey;
  final List<FilterOption> options;
  final int selectedCount;
  final bool Function(Object value) isSelected;
  final void Function(Object value) onToggle;
  final VoidCallback onClear;
}

/// A row of chips, one per criterion, each opening a multi-select sheet.
///
/// Shared by the Structure overview and the events list: both narrow a long
/// list by the same four criteria, and keeping two near-identical bars in step
/// by hand is how they drift apart.
///
/// Everything reactive is read by the caller before building this — the bar
/// itself holds no state, so a caller wraps it in its own `Obx`.
class FilterChipBar extends StatelessWidget {
  const FilterChipBar({
    super.key,
    required this.criteria,
    required this.visibleCount,
    required this.totalCount,
    required this.hasActiveFilters,
    required this.onClearAll,
  });

  final List<FilterCriterion> criteria;
  final int visibleCount;
  final int totalCount;
  final bool hasActiveFilters;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
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
                for (final criterion in criteria) ...[
                  _CriterionChip(criterion: criterion),
                  const SizedBox(width: AppSpacing.sm),
                ],
              ],
            ),
          ),
          if (hasActiveFilters)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm, AppSpacing.xs, AppSpacing.sm, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'filter_visible_count'.trParams(
                        {'visible': '$visibleCount', 'total': '$totalCount'}),
                    style: AppTypography.caption,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  GestureDetector(
                    onTap: onClearAll,
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
  }
}

/// Names one selectable value. Every criterion but the gender carries a server
/// label, which is shown as-is; a gender is an enum translated here.
String _optionLabel(FilterOption option) {
  final value = option.value;
  return value is Gender ? value.label : option.label;
}

class _CriterionChip extends StatelessWidget {
  const _CriterionChip({required this.criterion});

  final FilterCriterion criterion;

  @override
  Widget build(BuildContext context) {
    final options = criterion.options;
    final count = criterion.selectedCount;
    final active = count > 0;
    // One ticked value reads better by name than as a count — "Genre · 1"
    // tells the operator nothing they cannot already see.
    final label = switch (count) {
      0 => criterion.labelKey.tr,
      1 =>
        _optionLabel(options.firstWhere((o) => criterion.isSelected(o.value))),
      _ => '${criterion.labelKey.tr} · $count',
    };
    return InkWell(
      borderRadius: AppRadius.pillRadius,
      onTap: options.isEmpty ? null : () => _openSheet(context, criterion),
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
                onTap: criterion.onClear,
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
  }
}

/// Opened from the view, with its own [context] — controllers in this codebase
/// never reach for `Get.dialog`.
void _openSheet(BuildContext context, FilterCriterion criterion) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (_) => _FilterSheet(criterion: criterion),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.criterion});

  final FilterCriterion criterion;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  @override
  Widget build(BuildContext context) {
    final criterion = widget.criterion;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(criterion.labelKey.tr,
                      style: AppTypography.subtitle),
                ),
                TextButton(
                  onPressed: () {
                    criterion.onClear();
                    setState(() {});
                  },
                  child: Text('filter_clear'.tr),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final option in criterion.options)
                  FilterChip(
                    label: Text(_optionLabel(option)),
                    selected: criterion.isSelected(option.value),
                    // The sheet keeps its own frame: the caller's `Obx` sits in
                    // the page behind and does not rebuild what floats above it.
                    onSelected: (_) {
                      criterion.onToggle(option.value);
                      setState(() {});
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
