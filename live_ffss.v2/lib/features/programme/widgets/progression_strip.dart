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

/// Le déroulement de l'épreuve, avec l'étape du créneau ouvert en jaune.
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
    final columns = progressionColumns(progression);
    final qualification = qualificationText(stage, l10n);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          if (expanded) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < columns.length; i++) ...[
                    if (i > 0)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '›',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    Column(
                      children: [
                        for (final box in columns[i])
                          _StageBox(
                            stage: box,
                            current: box.id == stage.id,
                            onTap: () => _open(context, ref, box),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (qualification != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Text(
                  qualification,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  void _open(BuildContext context, WidgetRef ref, Stage target) {
    if (target.id == stage.id) return;
    final meetings = ref.read(programmeProvider(competitionId)).value?.meetings;
    if (meetings == null) return;
    final items = itemsOfStage(meetings, target.id);
    switch (items.length) {
      case 0:
        return;
      case 1:
        context.push(Routes.programmeItem(competitionId, items.single.id));
      default:
        showModalBottomSheet<void>(
          context: context,
          builder: (sheet) => _ItemChoice(
            items: items,
            onSelect: (item) {
              Navigator.of(sheet).pop();
              context.push(Routes.programmeItem(competitionId, item.id));
            },
          ),
        );
    }
  }
}

class _StageBox extends StatelessWidget {
  const _StageBox({
    required this.stage,
    required this.current,
    required this.onTap,
  });

  final Stage stage;
  final bool current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Material(
      color: current ? AppColors.yellow : AppColors.dateBox,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stage.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: current ? FontWeight.w700 : FontWeight.w500,
                  color: AppColors.navy,
                ),
              ),
              if (stage.heatCount > 0 && stage.placesPerHeat > 0)
                Text(
                  stageFormat(stage),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _ItemChoice extends StatelessWidget {
  const _ItemChoice({required this.items, required this.onSelect});

  final List<MeetingItem> items;
  final ValueChanged<MeetingItem> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.chooseFinal,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
          for (final item in items)
            ListTile(
              title: Text(item.name),
              trailing: Text(timeLabel(item.startTime)),
              onTap: () => onSelect(item),
            ),
        ],
      ),
    );
  }
}
