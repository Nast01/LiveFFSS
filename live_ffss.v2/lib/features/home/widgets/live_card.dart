import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/core/router/app_router.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/domain/now_running.dart';
import 'package:live_ffss_v2/features/home/competition_formatting.dart';
import 'package:live_ffss_v2/features/home/now_running_provider.dart';
import 'package:live_ffss_v2/features/shell/open_competition.dart';

class LiveCard extends ConsumerWidget {
  const LiveCard({super.key, required this.competition});

  final CompetitionSummary competition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final today = ref.watch(clockProvider)();
    final day = competition.dayOfCompetition(today);
    // En échec, la ligne disparaît simplement : la carte reste utile sans elle.
    final now = ref.watch(nowRunningProvider(competition.id)).value;
    final place = [
      ?competition.location,
      competition.dateRangeLabel(locale),
    ].join(' · ');

    return Material(
      color: AppColors.navy,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openCompetition(context, ref, competition),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: Text(
                        '● ${l10n.liveBadge}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      [
                        competition.disciplineLabel(l10n),
                        if (day != null)
                          l10n.dayOfTotal(day.current, day.total),
                      ].join(' · '),
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                competition.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                place,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
              if (now != null) ...[
                const Spacer(),
                _NowRunningTile(competition: competition, now: now),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NowRunningTile extends ConsumerWidget {
  const _NowRunningTile({required this.competition, required this.now});

  final CompetitionSummary competition;
  final NowRunning now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: AppColors.navyRaised,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () =>
            openCompetition(context, ref, competition, route: Routes.live),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      now.kind == NowRunningKind.now
                          ? l10n.nowRunning
                          : l10n.nextUp,
                      style: const TextStyle(
                        color: AppColors.yellow,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      heatLine(now, l10n),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
