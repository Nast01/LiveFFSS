import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/features/results/athlete_providers.dart';
import 'package:live_ffss_v2/features/results/results_formatting.dart';
import 'package:live_ffss_v2/features/results/widgets/results_messages.dart';

/// Une épreuve de la fiche d'un athlète, partagée par la fiche et l'espace
/// athlète de Mon espace.
class AthleteRaceTile extends StatelessWidget {
  const AthleteRaceTile({super.key, required this.race, this.finder});

  final AthleteRace race;

  /// « Trouver sa série », pour une course à courir.
  final Widget? finder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final row = race.row;
    final detail = race.unavailable
        ? l10n.athleteRaceUnavailable
        : athleteRaceDetail(race, l10n);
    final finder = this.finder;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 48,
              child: Text(
                athleteRaceTime(race),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    athleteRaceTitle(race.event, l10n),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (detail.isNotEmpty)
                    Text(
                      detail,
                      style: TextStyle(
                        fontSize: 12,
                        color: race.unavailable
                            ? AppColors.red
                            : AppColors.textSecondary,
                      ),
                    ),
                  ?finder,
                ],
              ),
            ),
            if (row != null) ...[
              const SizedBox(width: 8),
              ResultText(label: resultLabel(row.result)),
            ],
          ],
        ),
      ),
    );
  }
}

/// « Trouver sa série » : la lecture des places ne part qu'à la demande,
/// elle coûte une requête par place.
class LaneFinderButton extends ConsumerStatefulWidget {
  const LaneFinderButton({
    super.key,
    required this.competitionId,
    required this.race,
  });

  final int competitionId;
  final AthleteRace race;

  @override
  ConsumerState<LaneFinderButton> createState() => _LaneFinderButtonState();
}

class _LaneFinderButtonState extends ConsumerState<LaneFinderButton> {
  bool _asked = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (!_asked) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          icon: const Icon(Icons.search, size: 18),
          label: Text(l10n.athleteFindHeat),
          onPressed: () => setState(() => _asked = true),
        ),
      );
    }
    final provider = laneFinderProvider((
      competitionId: widget.competitionId,
      eventId: widget.race.event.id,
      entryId: widget.race.entry.entryId,
      heatId: widget.race.series?.heat.id,
    ));
    final found = ref.watch(provider);
    const style = TextStyle(fontWeight: FontWeight.w600, color: AppColors.navy);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: switch (found) {
        AsyncData(:final value) => Text(
          value == null ? l10n.athleteNotPlaced : laneFoundLabel(value, l10n),
          style: style,
        ),
        AsyncError() => Row(
          children: [
            Expanded(
              child: Text(
                l10n.athleteFindError,
                style: const TextStyle(fontSize: 12, color: AppColors.red),
              ),
            ),
            TextButton(
              onPressed: () => ref.invalidate(provider),
              child: Text(l10n.retry),
            ),
          ],
        ),
        _ => const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      },
    );
  }
}
