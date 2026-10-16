import 'package:flutter/material.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/features/home/widgets/competition_row.dart';

/// Une carte blanche titrée (« À venir », « Terminées récemment »).
class CompetitionSection extends StatelessWidget {
  const CompetitionSection({
    super.key,
    required this.title,
    required this.competitions,
    this.action,
  });

  final String title;
  final List<CompetitionSummary> competitions;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ?action,
              ],
            ),
          ),
          for (final (index, competition) in competitions.indexed) ...[
            if (index > 0) const Divider(height: 1, color: AppColors.border),
            CompetitionRow(competition: competition),
          ],
        ],
      ),
    );
  }
}
