import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/features/home/competition_formatting.dart';
import 'package:live_ffss_v2/features/home/favorites.dart';
import 'package:live_ffss_v2/features/home/widgets/discipline_badge.dart';
import 'package:live_ffss_v2/features/shell/open_competition.dart';

/// Une ligne de liste : case date, nom, organisateur, badge, étoile.
class CompetitionRow extends ConsumerWidget {
  const CompetitionRow({super.key, required this.competition});

  final CompetitionSummary competition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final isFavorite =
        ref.watch(favoritesProvider).value?.contains(competition.id) ?? false;
    return InkWell(
      onTap: () => openCompetition(context, ref, competition),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
        child: Row(
          children: [
            Container(
              width: 56,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.dateBox,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    shortDayLabel(competition.startDate),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    monthLabel(competition.startDate, locale),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    competition.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (competition.organizer case final organizer?)
                    Text(
                      organizer,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            DisciplineBadge(competition: competition),
            IconButton(
              tooltip: isFavorite ? l10n.removeFavorite : l10n.addFavorite,
              onPressed: () =>
                  ref.read(favoritesProvider.notifier).toggle(competition.id),
              icon: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: isFavorite ? AppColors.yellow : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
