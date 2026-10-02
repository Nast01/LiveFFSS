import 'package:flutter/material.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';

/// La place qu'un engagement occupe dans sa course — le couloir, compté à
/// partir de 1.
///
/// Partagé par le tirage et l'onglet Séries : les deux écrans montrent la même
/// suite de couloirs, celle de `ProgrammeRace.entryIds`, et doivent donc la
/// numéroter pareil. Un badge propre à chaque écran les aurait laissés diverger
/// en silence.
class LaneNumberBadge extends StatelessWidget {
  const LaneNumberBadge({super.key, required this.lane});

  final int lane;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: AppRadius.smRadius,
      ),
      child: Text(
        '$lane',
        style: AppTypography.caption
            .copyWith(fontWeight: FontWeight.w800, color: AppColors.primary),
      ),
    );
  }
}
