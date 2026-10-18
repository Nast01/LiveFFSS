import 'package:flutter/material.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';

/// Une rangée de puces à choix unique, défilable, comme les jours du
/// programme (`DayTabs`).
class ChoiceChipsRow<T> extends StatelessWidget {
  const ChoiceChipsRow({
    super.key,
    required this.options,
    required this.selected,
    required this.label,
    required this.onSelect,
  });

  final List<T> options;
  final T? selected;
  final String Function(T option) label;
  final void Function(T option) onSelect;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 40,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: options.length,
      separatorBuilder: (context, index) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final option = options[index];
        final isSelected = option == selected;
        return ChoiceChip(
          label: Text(label(option)),
          selected: isSelected,
          onSelected: (_) => onSelect(option),
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
