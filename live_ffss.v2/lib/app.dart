import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/l10n/app_locale.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/router/app_router.dart';
import 'package:live_ffss_v2/core/theme/app_theme.dart';
import 'package:live_ffss_v2/features/officiel/outbox_service.dart';
import 'package:live_ffss_v2/features/reminders/reminders_providers.dart';
import 'package:live_ffss_v2/features/settings/app_language.dart';

class LiveFfssApp extends ConsumerWidget {
  const LiveFfssApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Écoutée sans être regardée : la file d'envoi (et la session qu'elle
    // suit) démarre au lancement, sans reconstruire l'app à chaque envoi.
    ref.listen(outboxProvider, (_, _) {});
    // De même, les rappels se replanifient au lancement et suivent la
    // compétition des onglets.
    ref.listen(activeRemindersProvider, (_, _) {});
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: buildAppTheme(),
      routerConfig: ref.watch(routerProvider),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      // Nulle pour « Langue du téléphone » : la résolution ci-dessous décide.
      locale: ref.watch(appLanguageProvider).value?.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localeListResolutionCallback: resolveAppLocale,
      debugShowCheckedModeBanner: false,
    );
  }
}
