import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/module/programme/controllers/programme_controller.dart';
import 'package:live_ffss/app/presentation/shared/filter_chip_bar.dart';

String _criterionKey(StructureFilter filter) => switch (filter) {
      StructureFilter.speciality => 'filter_speciality',
      StructureFilter.discipline => 'filter_discipline',
      StructureFilter.gender => 'filter_gender',
      StructureFilter.category => 'filter_category',
    };

/// The structure overview's filter bar: one chip per criterion, the
/// visible/total count, and a way out of every filter at once.
///
/// The chips themselves live in [FilterChipBar], shared with the events list —
/// this only binds them to [ProgrammeController].
class StructureFilterBar extends StatelessWidget {
  const StructureFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProgrammeController>();
    return Obx(() => FilterChipBar(
          visibleCount: controller.visibleRows.length,
          totalCount: controller.rows.length,
          hasActiveFilters: controller.hasActiveFilters,
          onClearAll: controller.clearFilters,
          criteria: [
            for (final filter in StructureFilter.values)
              FilterCriterion(
                labelKey: _criterionKey(filter),
                options: controller.optionsFor(filter),
                selectedCount: controller.selectedCount(filter),
                isSelected: (value) => controller.isSelected(filter, value),
                onToggle: (value) => controller.toggle(filter, value),
                onClear: () => controller.clear(filter),
              ),
          ],
        ));
  }
}
