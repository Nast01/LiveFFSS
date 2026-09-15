import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/entry.dart';
import 'package:live_ffss/app/presentation/modules/competitions/athlete_formatting.dart';
import 'package:live_ffss/app/presentation/modules/competitions/entry_formatting.dart';
import 'package:live_ffss/app/presentation/shared/club_avatar.dart';

/// Un engagement, sur une ligne : ce que tous les écrans de compétiteurs
/// montrent.
///
/// Un relais est une équipe derrière un club, dépliable sur ses athlètes ; un
/// engagement individuel rend la même ligne sans chevron ni athlètes. Les
/// écrans n'ont ni le même contenu à gauche ni le même à droite — d'où les
/// slots plutôt que quatre variantes.
class EntryGroupTile extends StatelessWidget {
  const EntryGroupTile({
    super.key,
    required this.entry,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.expanded = false,
    this.onToggle,
    this.onTap,
    this.onLongPress,
    this.athleteTrailing,
    this.onSubstitute,
    this.highlight = false,
    this.avatarSize = 32,
  });

  final Entry entry;
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;

  final bool expanded;

  /// Null pour un engagement individuel : il n'y a rien à déplier.
  final VoidCallback? onToggle;

  final VoidCallback? onTap;
  final ValueChanged<Offset>? onLongPress;

  /// Ce que l'écran accroche à droite de chaque athlète déplié — un statut de
  /// présence, rien du tout.
  final Widget? Function(Athlete athlete)? athleteTrailing;

  /// Le bouton « remplacer un membre ». Absent, le bouton ne s'affiche pas.
  final void Function(Entry entry, Athlete athlete)? onSubstitute;

  final bool highlight;
  final double avatarSize;

  bool get _isTeam => isTeamEntry(entry);

  @override
  Widget build(BuildContext context) {
    final head = Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.sm),
          ],
          ClubAvatar(
            club: entryClub(entry),
            size: avatarSize,
            shape: ClubAvatarShape.circle,
            fallbackLabel: title,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.body
                      .copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                  // Le titre d'une équipe est le nom de son club, et c'est ce
                  // nom que l'opérateur cherche du regard pour la reconnaître :
                  // il s'enroule autant qu'il faut plutôt que d'être coupé. Un
                  // engagement individuel, lui, est titré par un nom de
                  // personne, court, et garde sa ligne unique.
                  maxLines: _isTeam ? null : 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle?.isNotEmpty == true)
                  Text(
                    subtitle!,
                    style: AppTypography.caption.copyWith(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
          if (_isTeam && onToggle != null)
            IconButton(
              onPressed: onToggle,
              icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
              color: AppColors.textMuted,
              visualDensity: VisualDensity.compact,
              tooltip: 'athletes'.tr,
            ),
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: highlight ? AppColors.primarySurface : null,
        borderRadius: AppRadius.mdRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onLongPressStart: onLongPress == null
                ? null
                : (d) => onLongPress!(d.globalPosition),
            child: Material(
              type: MaterialType.transparency,
              borderRadius: AppRadius.mdRadius,
              child: InkWell(
                onTap: onTap,
                borderRadius: AppRadius.mdRadius,
                child: head,
              ),
            ),
          ),
          if (_isTeam && expanded)
            for (final athlete in entry.athletes)
              _AthleteLine(
                entry: entry,
                athlete: athlete,
                trailing: athleteTrailing?.call(athlete),
                onSubstitute: onSubstitute,
              ),
        ],
      ),
    );
  }
}

class _AthleteLine extends StatelessWidget {
  const _AthleteLine({
    required this.entry,
    required this.athlete,
    required this.trailing,
    required this.onSubstitute,
  });

  final Entry entry;
  final Athlete athlete;
  final Widget? trailing;
  final void Function(Entry entry, Athlete athlete)? onSubstitute;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 2, AppSpacing.sm, AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              athlete.displayName,
              style: AppTypography.caption.copyWith(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailing != null) trailing!,
          if (onSubstitute != null)
            IconButton(
              onPressed: () => onSubstitute!(entry, athlete),
              icon: const Icon(Icons.swap_horizontal_circle_outlined),
              iconSize: 20,
              color: AppColors.textMuted,
              visualDensity: VisualDensity.compact,
              tooltip: 'relay_substitute'.tr,
            ),
        ],
      ),
    );
  }
}
