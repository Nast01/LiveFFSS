import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/features/settings/start_tab.dart';

/// L'onglet d'ouverture, appliqué au prochain lancement.
class StartTabSelector extends ConsumerWidget {
  const StartTabSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final current = ref.watch(startTabProvider).value ?? StartTab.home;
    return Card(
      color: AppColors.surface,
      child: RadioGroup<StartTab>(
        groupValue: current,
        onChanged: (tab) {
          if (tab != null) ref.read(startTabProvider.notifier).select(tab);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                l10n.startTabTitle,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            for (final tab in StartTab.values)
              RadioListTile<StartTab>(
                value: tab,
                title: Text(startTabLabel(tab, l10n)),
              ),
          ],
        ),
      ),
    );
  }
}
