import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/features/settings/app_language.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final current = ref.watch(appLanguageProvider).value ?? AppLanguage.system;
    return Card(
      color: AppColors.surface,
      child: RadioGroup<AppLanguage>(
        groupValue: current,
        onChanged: (language) {
          if (language != null) {
            ref.read(appLanguageProvider.notifier).select(language);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                l10n.languageTitle,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            for (final language in AppLanguage.values)
              RadioListTile<AppLanguage>(
                value: language,
                title: Text(switch (language) {
                  AppLanguage.system => l10n.languageSystem,
                  AppLanguage.french => l10n.languageFrench,
                  AppLanguage.english => l10n.languageEnglish,
                }),
              ),
          ],
        ),
      ),
    );
  }
}
