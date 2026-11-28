import 'package:flutter/material.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/programme_events.dart';
import 'package:live_ffss_v2/features/programme/programme_formatting.dart';
import 'package:live_ffss_v2/features/programme/widgets/event_card.dart';

/// Une réunion : son en-tête, qui la replie, puis une carte par épreuve et
/// une ligne discrète par créneau sans course.
class MeetingCard extends StatelessWidget {
  const MeetingCard({
    super.key,
    required this.meeting,
    required this.programme,
    required this.expanded,
    required this.finished,
    required this.onToggle,
    required this.onOpen,
    this.focusEventKey,
    this.focusKey,
  });

  final Meeting meeting;

  /// Tout le programme : le parcours d'une épreuve passe par d'autres
  /// réunions.
  final Programme programme;
  final bool expanded;
  final bool finished;

  /// Reçoit l'état affiché au moment du toucher.
  final void Function(bool expanded) onToggle;
  final void Function(MeetingItem item) onOpen;

  /// L'épreuve sur laquelle la vue s'ouvre, et la clé qui permet d'y
  /// défiler.
  final String? focusEventKey;
  final GlobalKey? focusKey;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final range = timeRangeLabel(meeting.startTime, meeting.endTime);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => onToggle(expanded),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
            child: Row(
              children: [
                Icon(
                  expanded ? Icons.expand_more : Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    meeting.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                      color: AppColors.navy,
                    ),
                  ),
                ),
                Text(
                  expanded
                      ? range
                      : meetingCollapsedLabel(
                          meeting,
                          programme,
                          l10n,
                          finished: finished,
                        ),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: finished && !expanded
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: finished && !expanded
                        ? AppColors.coastalText
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (expanded)
          for (final entry in meetingEntries(meeting, programme))
            switch (entry) {
              EventEntry(:final event) => Padding(
                key: event.key == focusEventKey ? focusKey : null,
                padding: const EdgeInsets.only(bottom: 8),
                child: EventCard(
                  event: event,
                  day: meeting.day,
                  onOpen: onOpen,
                ),
              ),
              PauseEntry(:final item) => _PauseRow(item: item),
            },
      ],
    );
  }
}

/// Un créneau sans course (échauffement, pause) : son heure, son nom et sa
/// durée, sans carte.
class _PauseRow extends StatelessWidget {
  const _PauseRow({required this.item});

  final MeetingItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final duration = itemDuration(item);
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 2, 6, 10),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(
              timeLabel(item.startTime),
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ),
          Expanded(
            child: Text(
              [
                item.name,
                if (duration != null) durationLabel(duration, l10n),
              ].join(' · '),
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}
