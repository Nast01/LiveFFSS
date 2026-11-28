import 'package:flutter/material.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/programme_events.dart';
import 'package:live_ffss_v2/domain/run_status.dart';
import 'package:live_ffss_v2/features/programme/programme_formatting.dart';

/// Une épreuve d'une réunion : son nom, son parcours (séries, finales) et
/// l'avancement de ses séries. L'épreuve en cours porte la bordure marine et
/// le liseré jaune ; une épreuve courue s'estompe.
class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.day,
    required this.onOpen,
  });

  final ProgrammeEvent event;

  /// Le jour de la réunion : un tour d'un autre jour en porte la mention.
  final DateTime day;
  final void Function(MeetingItem item) onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final live = event.status == ItemStatus.live;
    final target = eventTarget(event.items);
    final subtitle = eventSubtitle(event, l10n);

    final content = Padding(
      padding: EdgeInsets.fromLTRB(live ? 18 : 14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _Badge(badge: eventBadge(event, l10n)),
            ],
          ),
          if (event.steps.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Wrap(
                spacing: 4,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (final (index, step) in event.steps.indexed) ...[
                    if (index > 0)
                      const Text(
                        '→',
                        style: TextStyle(color: AppColors.muted, fontSize: 12),
                      ),
                    _StepChip(
                      label: stepLabel(step, l10n),
                      detail: stepDetail(step, day, locale, l10n),
                      status: step.status,
                      onTap: switch (eventTarget(step.items)) {
                        final item? => () => onOpen(item),
                        null => null,
                      },
                    ),
                  ],
                ],
              ),
            ),
          if (showsHeatDots(event))
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: _HeatDots(
                heats: event.heats,
                label: heatDotsLabel(event, l10n),
              ),
            ),
        ],
      ),
    );

    final card = Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: live ? AppColors.navy : AppColors.border),
        boxShadow: live
            ? const [
                BoxShadow(
                  color: Color(0x1F13285E),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: target == null ? null : () => onOpen(target),
          child: Stack(
            children: [
              content,
              if (live)
                const Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: SizedBox(
                    width: 5,
                    child: ColoredBox(color: AppColors.yellow),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    return event.status == ItemStatus.finished
        ? Opacity(opacity: 0.72, child: card)
        : card;
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.badge});

  final ({EventBadgeKind kind, String label}) badge;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (badge.kind) {
      EventBadgeKind.live => (
        AppColors.liveSoftBackground,
        AppColors.liveSoftText,
      ),
      EventBadgeKind.done => (
        AppColors.coastalBackground,
        AppColors.coastalText,
      ),
      EventBadgeKind.next => (
        AppColors.flatWaterBackground,
        AppColors.flatWaterText,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge.kind == EventBadgeKind.live)
            Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.only(right: 5),
              decoration: const BoxDecoration(
                color: AppColors.red,
                shape: BoxShape.circle,
              ),
            ),
          Text(
            badge.label,
            style: TextStyle(
              color: foreground,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepChip extends StatelessWidget {
  const _StepChip({
    required this.label,
    required this.detail,
    required this.status,
    required this.onTap,
  });

  final String label;
  final String detail;
  final ItemStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (background, foreground, secondary) = switch (status) {
      ItemStatus.live => (AppColors.navy, Colors.white, Colors.white70),
      ItemStatus.finished => (
        AppColors.coastalBackground,
        AppColors.coastalText,
        AppColors.coastalText,
      ),
      _ => (AppColors.dateBox, AppColors.textPrimary, AppColors.textSecondary),
    };
    return Semantics(
      button: onTap != null,
      label: l10n.programmeStepSemantics(label, detail),
      excludeSemantics: true,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: foreground,
                  ),
                ),
                Text(detail, style: TextStyle(fontSize: 11, color: secondary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeatDots extends StatelessWidget {
  const _HeatDots({required this.heats, required this.label});

  final List<Heat> heats;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Flexible(
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            for (final heat in heats)
              Container(
                width: 16,
                height: 6,
                decoration: BoxDecoration(
                  color: switch (heat.status) {
                    RunStatus.finished => AppColors.coastalText,
                    RunStatus.inProgress ||
                    RunStatus.marshalling => AppColors.navy,
                    RunStatus.waiting => AppColors.border,
                  },
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(width: 8),
      Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
    ],
  );
}
