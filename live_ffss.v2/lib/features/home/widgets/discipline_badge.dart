import 'package:flutter/material.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/domain/discipline.dart';
import 'package:live_ffss_v2/features/home/competition_formatting.dart';

class DisciplineBadge extends StatelessWidget {
  const DisciplineBadge({super.key, required this.competition});

  final CompetitionSummary competition;

  @override
  Widget build(BuildContext context) {
    final coastalOnly =
        competition.disciplines.length == 1 &&
        competition.disciplines.contains(Discipline.coastal);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: coastalOnly
            ? AppColors.coastalBackground
            : AppColors.flatWaterBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          competition.disciplineLabel(AppLocalizations.of(context)),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: coastalOnly
                ? AppColors.coastalText
                : AppColors.flatWaterText,
          ),
        ),
      ),
    );
  }
}
