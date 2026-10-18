import 'package:flutter/material.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';

/// Le repère « Suivi » d'une ligne qui concerne un athlète ou un club suivi.
class FollowedMark extends StatelessWidget {
  const FollowedMark({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: AppColors.yellow,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star, size: 11, color: AppColors.navy),
        const SizedBox(width: 2),
        Text(
          AppLocalizations.of(context).followedMark,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.navy,
          ),
        ),
      ],
    ),
  );
}
