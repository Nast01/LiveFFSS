import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/router/app_router.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/progression.dart';
import 'package:live_ffss_v2/features/programme/item_detail_providers.dart';
import 'package:live_ffss_v2/features/programme/programme_formatting.dart';
import 'package:live_ffss_v2/features/programme/programme_providers.dart';
import 'package:live_ffss_v2/features/programme/widgets/status_badge.dart';

/// Le déroulement de l'épreuve en chronologie : une étape par ligne, avec ses
/// horaires et son état, l'étape du créneau ouvert surlignée.
class ProgressionStrip extends ConsumerWidget {
  const ProgressionStrip({
    super.key,
    required this.competitionId,
    required this.progression,
    required this.stage,
  });

  final int competitionId;
  final Progression progression;
  final Stage stage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final expanded = ref.watch(progressionExpandedProvider);
    final meetings = ref.watch(
      programmeProvider(competitionId).select((p) => p.value?.meetings),
    );

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: ref.read(progressionExpandedProvider.notifier).toggle,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: expanded
                        ? Text(
                            l10n.progressionToggle,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          )
                        : Text(
                            collapsedProgression(progression, l10n),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < progression.stages.length; i++)
                    _StageStep(
                      stage: progression.stages[i],
                      current: progression.stages[i].id == stage.id,
                      last: i == progression.stages.length - 1,
                      items: meetings == null
                          ? const []
                          : itemsOfStage(meetings, progression.stages[i].id),
                      onOpen: (item) => context.push(
                        Routes.programmeItem(competitionId, item.id),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Une étape de la chronologie. Une étape tenue en un seul créneau affiche
/// son jour et ses heures et s'ouvre d'un toucher ; une étape répartie sur
/// plusieurs créneaux (finales B et A) propose une pastille par créneau.
class _StageStep extends StatelessWidget {
  const _StageStep({
    required this.stage,
    required this.current,
    required this.last,
    required this.items,
    required this.onOpen,
  });

  final Stage stage;
  final bool current;
  final bool last;
  final List<MeetingItem> items;
  final ValueChanged<MeetingItem> onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final status = stageStatus(items);
    final categories = stageCategories(stage);
    final format = stage.heatCount > 0 && stage.placesPerHeat > 0
        ? stageFormat(stage)
        : '';
    final single = items.length == 1 ? items.single : null;
    final details = [
      format,
      if (single != null) stageScheduleLabel(single, locale),
    ].where((part) => part.isNotEmpty).join(' · ');
    final qualification = qualificationText(stage, l10n);

    final dotColor = current
        ? AppColors.yellow
        : status == ItemStatus.finished
        ? AppColors.coastalText
        : AppColors.surface;

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  [stage.level.label(l10n), ?categories].join(' · '),
                  style: TextStyle(
                    fontWeight: current ? FontWeight.w800 : FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
              ),
              StatusBadge(status: status),
            ],
          ),
          if (details.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                details,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          if (items.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final item in items)
                    ActionChip(
                      label: Text(itemChipLabel(item)),
                      labelStyle: const TextStyle(fontSize: 12),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: AppColors.dateBox,
                      side: const BorderSide(color: AppColors.border),
                      onPressed: () => onOpen(item),
                    ),
                ],
              ),
            ),
          if (qualification != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                qualification,
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );

    // La ligne de l'étape ouverte n'a rien à ouvrir ; une étape sans créneau
    // au programme non plus.
    final tappable = !current && single != null;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 20,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: current
                          ? AppColors.navy
                          : status == ItemStatus.finished
                          ? AppColors.coastalText
                          : AppColors.textSecondary,
                      width: 2,
                    ),
                  ),
                ),
                if (!last)
                  Expanded(child: Container(width: 2, color: AppColors.border)),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Material(
                color: current
                    ? AppColors.yellow.withValues(alpha: 0.18)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: tappable ? () => onOpen(single) : null,
                  child: content,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
