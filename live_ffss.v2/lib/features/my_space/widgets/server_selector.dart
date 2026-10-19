import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/config/app_environment.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/features/auth/session.dart';
import 'package:live_ffss_v2/features/officiel/outbox_service.dart';
import 'package:live_ffss_v2/features/settings/server_switch.dart';

/// Recette ou production, après confirmation. Montré dès qu'un admin s'est
/// connecté sur ce téléphone (`adminSeenProvider`), même déconnecté : il
/// faut pouvoir revenir à l'autre serveur sans compte.
class ServerSelector extends ConsumerWidget {
  const ServerSelector({super.key});

  Future<void> _select(
    BuildContext context,
    WidgetRef ref,
    AppEnvironment target,
  ) async {
    final l10n = AppLocalizations.of(context);
    // La file en mémoire est celle de ce serveur : ses saisies non envoyées
    // attendront le retour.
    final unsent = serverSwitchUnsentCount(
      ref.read(outboxProvider),
      ref.read(sessionProvider).value,
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.serverSwitchTitle(serverLabel(target, l10n))),
        content: Text(serverSwitchMessage(target, unsent, l10n)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.serverSwitchConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    // Pris avant : cette page est remplacée par le nouveau routeur.
    final container = ProviderScope.containerOf(context, listen: false);
    await switchServer(container, target);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final current = ref.watch(appConfigProvider).environment;
    return Card(
      color: AppColors.surface,
      child: RadioGroup<AppEnvironment>(
        groupValue: current,
        onChanged: (target) {
          if (target != null && target != current) {
            _select(context, ref, target);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                l10n.serverTitle,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            for (final environment in const [
              AppEnvironment.development,
              AppEnvironment.production,
            ])
              RadioListTile<AppEnvironment>(
                value: environment,
                title: Text(serverLabel(environment, l10n)),
              ),
          ],
        ),
      ),
    );
  }
}
