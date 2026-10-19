import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/app_host.dart';
import 'package:live_ffss_v2/core/config/app_environment.dart';
import 'package:live_ffss_v2/core/l10n/app_locale.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/core/router/app_router.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/core/theme/app_theme.dart';
import 'package:live_ffss_v2/features/officiel/outbox_service.dart';
import 'package:live_ffss_v2/features/reminders/reminders_providers.dart';
import 'package:live_ffss_v2/features/settings/app_language.dart';
import 'package:live_ffss_v2/features/settings/server_switch.dart';

/// La racine : un conteneur par serveur ([AppContainerHost]). Changer de
/// serveur remonte toute l'app sur un conteneur neuf ; l'ancien n'est jeté
/// qu'après l'image où ses écrans disparaissent, qui l'écoutent encore.
class AppRoot extends StatefulWidget {
  const AppRoot({super.key, required this.environment});

  final AppEnvironment environment;

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  late final AppContainerHost _host = AppContainerHost(
    environment: widget.environment,
    disposeOld: (old) =>
        WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose()),
  );

  @override
  void initState() {
    super.initState();
    _host.addListener(_restart);
  }

  void _restart() => setState(() {});

  @override
  void dispose() {
    _host
      ..removeListener(_restart)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => UncontrolledProviderScope(
    // Une clé par conteneur : rien de l'arbre de l'autre serveur ne survit.
    key: ObjectKey(_host.container),
    container: _host.container,
    child: const LiveFfssApp(),
  );
}

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
      builder: (context, child) => _ServerBanner(child: child),
    );
  }
}

/// Un bandeau permanent hors production, au-dessus de toutes les pages :
/// une saisie faite sur la recette ne compte pas.
class _ServerBanner extends ConsumerWidget {
  const _ServerBanner({required this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = child ?? const SizedBox.shrink();
    final text = serverBanner(
      ref.watch(appConfigProvider).environment,
      AppLocalizations.of(context),
    );
    if (text == null) return page;
    return Column(
      children: [
        Material(
          color: AppColors.yellow,
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
        // Le bandeau occupe déjà la barre d'état : les pages ne la réservent
        // pas une seconde fois.
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: page,
          ),
        ),
      ],
    );
  }
}
