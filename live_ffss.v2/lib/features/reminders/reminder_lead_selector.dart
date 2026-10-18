import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/features/reminders/reminders_formatting.dart';
import 'package:live_ffss_v2/features/settings/reminder_lead.dart';

/// Le délai des rappels avant une course ; dit pourquoi ils se sont
/// désactivés si les notifications ont été refusées.
class ReminderLeadSelector extends ConsumerWidget {
  const ReminderLeadSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final current = ref.watch(reminderLeadProvider).value;
    final denied = ref.watch(reminderPermissionDeniedProvider);
    final hint = reminderPermissionHint(
      lead: current,
      permitted: ref.watch(reminderPermissionProvider).value,
      denied: denied,
      l10n: l10n,
    );
    return Card(
      color: AppColors.surface,
      child: RadioGroup<ReminderLead>(
        groupValue: current,
        onChanged: (lead) {
          if (lead != null) {
            ref.read(reminderLeadProvider.notifier).select(lead);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.reminderLeadTitle,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.reminderLeadSubtitle,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            if (hint != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(hint),
              ),
            for (final lead in ReminderLead.values)
              RadioListTile<ReminderLead>(
                value: lead,
                title: Text(reminderLeadLabel(lead, l10n)),
              ),
          ],
        ),
      ),
    );
  }
}
