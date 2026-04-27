import 'package:flutter/material.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: AppTypography.title),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
