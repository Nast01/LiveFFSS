import 'package:flutter/material.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/presentation/modules/competitions/competition_formatting.dart';

/// Le carré qui identifie une compétition : le logo du club organisateur quand
/// il en a un, le pavé de date sinon.
///
/// Le pavé n'est pas qu'un repli : c'est aussi ce qui s'affiche pendant le
/// chargement du logo et si celui-ci échoue, pour que la vignette garde sa
/// place et sa taille au lieu de faire sauter la ligne.
///
/// Deux variantes, et pas d'autre : [CompetitionThumbnail.card] dans les
/// listes, [CompetitionThumbnail.header] en tête du détail, où le pavé se pose
/// sur le bandeau de couleur et prend donc un fond blanc et l'encre de marque.
class CompetitionThumbnail extends StatelessWidget {
  const CompetitionThumbnail.card({super.key, required this.competition})
      : size = 56,
        background = AppColors.surfaceMuted,
        foreground = AppColors.textPrimary,
        dayFontSize = 16;

  const CompetitionThumbnail.header({super.key, required this.competition})
      : size = 64,
        background = Colors.white,
        foreground = AppColors.primary,
        dayFontSize = 18;

  final Competition competition;
  final double size;
  final Color background;
  final Color foreground;
  final double dayFontSize;

  @override
  Widget build(BuildContext context) {
    final logoUrl = competition.organizerClub.logoUrl;
    if (logoUrl == null || logoUrl.isEmpty) return _dateBlock();
    return ClipRRect(
      borderRadius: AppRadius.smRadius,
      child: Image.network(
        logoUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _dateBlock(),
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : _dateBlock(),
      ),
    );
  }

  Widget _dateBlock() => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: background,
          borderRadius: AppRadius.smRadius,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              competition.formattedBeginDateMonth,
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.bold,
                color: foreground,
              ),
            ),
            Text(
              competition.formattedDayBeginDate,
              style: AppTypography.subtitle.copyWith(
                fontWeight: FontWeight.bold,
                color: foreground,
                fontSize: dayFontSize,
              ),
            ),
          ],
        ),
      );
}
