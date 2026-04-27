import 'package:flutter/material.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.pillRadius,
      ),
      child: Text(label, style: AppTypography.badge),
    );
  }
}
