import 'package:flutter/material.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/club.dart';

enum ClubAvatarShape { rounded, circle }

/// The single way to show a club as an icon. Falls back in a fixed order:
/// club logo, then cap, then the first letter of the club name. Each image
/// step degrades to the next through [Image.network]'s errorBuilder, so a
/// broken or 404 URL never leaves an empty box.
///
/// Always use this instead of hand-rolling an `Image.network(club.logoUrl)`.
class ClubAvatar extends StatelessWidget {
  const ClubAvatar({
    super.key,
    required this.club,
    this.size = 48,
    this.shape = ClubAvatarShape.rounded,
    this.fallbackLabel = '',
  });

  final Club? club;
  final double size;
  final ClubAvatarShape shape;

  /// Source of the initial when [club] is unresolved or unnamed — typically
  /// the label carried by the athlete row before the club index is built.
  final String fallbackLabel;

  bool get _isCircle => shape == ClubAvatarShape.circle;

  @override
  Widget build(BuildContext context) {
    final urls = <String>[
      if (club?.logoUrl?.isNotEmpty == true) club!.logoUrl!,
      if (club?.capUrl?.isNotEmpty == true) club!.capUrl!,
    ];

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _isCircle ? AppColors.surface : AppColors.surfaceMuted,
        shape: _isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: _isCircle ? null : AppRadius.smRadius,
        border: _isCircle ? Border.all(color: AppColors.border) : null,
      ),
      child: _imageOrInitial(urls, 0),
    );
  }

  Widget _imageOrInitial(List<String> urls, int index) {
    if (index >= urls.length) return _initial();
    return Image.network(
      urls[index],
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _imageOrInitial(urls, index + 1),
      // Show the initial rather than an empty box while the image downloads.
      loadingBuilder: (_, child, progress) =>
          progress == null ? child : _initial(),
    );
  }

  Widget _initial() {
    final source = club?.name.isNotEmpty == true ? club!.name : fallbackLabel;
    return Center(
      child: Text(
        source.isNotEmpty ? source[0].toUpperCase() : '?',
        style: AppTypography.title.copyWith(
          color: AppColors.textPrimary,
          fontSize: size * 0.4,
        ),
      ),
    );
  }
}
