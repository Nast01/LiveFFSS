import 'package:flutter/material.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';

/// Le titre d'une section de Mon espace (« MES ESPACES SUR CETTE
/// COMPÉTITION »).
class MySpaceHeader extends StatelessWidget {
  const MySpaceHeader(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 20, 4, 6),
    child: Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        color: AppColors.textSecondary,
      ),
    ),
  );
}

/// Une carte blanche qui regroupe des lignes, séparées d'un filet.
class MySpaceBox extends StatelessWidget {
  const MySpaceBox({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    color: AppColors.surface,
    margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, child) in children.indexed) ...[
          if (i > 0) const Divider(height: 1, color: AppColors.border),
          child,
        ],
      ],
    ),
  );
}

enum BadgeTone { neutral, highlight, alert }

/// Une ligne de Mon espace : icône, titre, sous-titre, badge d'état ou
/// chevron quand elle s'ouvre.
class MySpaceRow extends StatelessWidget {
  const MySpaceRow({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.badge,
    this.badgeTone = BadgeTone.neutral,
    this.trailing,
    this.onTap,
  });

  final IconData? icon;
  final String title;
  final String? subtitle;
  final String? badge;
  final BadgeTone badgeTone;

  /// Remplace le chevron (une étoile, par exemple).
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    final badge = this.badge;
    final icon = this.icon;
    return ListTile(
      onTap: onTap,
      leading: icon == null
          ? null
          : Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.dateBox,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 20, color: AppColors.blue),
            ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: subtitle == null || subtitle.isEmpty
          ? null
          : Text(
              subtitle,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null) _Badge(text: badge, tone: badgeTone),
          if (trailing case final trailing?)
            trailing
          else if (onTap != null)
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.tone});

  final String text;
  final BadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (tone) {
      BadgeTone.neutral => (AppColors.dateBox, AppColors.blue),
      BadgeTone.highlight => (AppColors.yellow, AppColors.navy),
      BadgeTone.alert => (AppColors.red.withValues(alpha: 0.12), AppColors.red),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}
