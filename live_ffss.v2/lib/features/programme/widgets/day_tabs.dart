import 'package:flutter/material.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/features/programme/programme_formatting.dart';

class DayTabs extends StatelessWidget {
  const DayTabs({
    super.key,
    required this.days,
    required this.selected,
    required this.onSelect,
  });

  final List<DateTime> days;
  final DateTime? selected;
  final void Function(DateTime day) onSelect;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: days.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = day == selected;
          return ChoiceChip(
            label: Text(dayTabLabel(day, locale)),
            selected: isSelected,
            onSelected: (_) => onSelect(day),
            showCheckmark: false,
            selectedColor: AppColors.navy,
            backgroundColor: AppColors.surface,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          );
        },
      ),
    );
  }
}
