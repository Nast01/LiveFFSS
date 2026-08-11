import 'package:flutter/material.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/presentation/modules/competitions/race_formatting.dart';

/// The gender as a coloured letter. The letter carries the meaning on its own,
/// so the colour never has to be told apart to read the badge.
class GenderBadge extends StatelessWidget {
  const GenderBadge({required this.gender, this.size = 22, super.key});

  final Gender gender;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration:
          BoxDecoration(color: gender.badgeColor, shape: BoxShape.circle),
      child: Text(
        gender.shortLabel,
        style: AppTypography.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.5,
        ),
      ),
    );
  }
}
