import 'package:flutter/material.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    this.message,
    this.compact = false,
    this.size = 20,
    this.color,
  });

  final String? message;
  final bool compact;

  /// Côté du carré que prend la forme compacte. Un spinner glissé dans le slot
  /// d'icône d'un bouton doit tenir la place de l'icône qu'il remplace, et
  /// celle-ci n'a pas la même taille d'un bouton à l'autre.
  final double size;

  /// Couleur du trait, pour un spinner posé sur un fond plein où la couleur
  /// d'accent par défaut ne se détacherait pas.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(strokeWidth: 2, color: color),
      );
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: color),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              message!,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
