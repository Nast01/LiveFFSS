import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/config/app_environment.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/domain/account.dart';
import 'package:live_ffss_v2/domain/outbox.dart';
import 'package:live_ffss_v2/features/auth/auth_formatting.dart';
import 'package:live_ffss_v2/features/settings/reminder_lead.dart';

/// Passe l'app sur [target]. Rien n'est effacé : chaque serveur garde sous
/// son préfixe jeton, compte, compétition active, suivis et file d'envoi.
/// Changer `appConfigProvider` reconstruit stockage, jeton, client HTTP,
/// session (reprise de celle enregistrée pour [target]) et ce qui en dépend ;
/// le routeur repart de l'onglet d'ouverture.
Future<void> switchServer(
  ProviderContainer container,
  AppEnvironment target,
) async {
  if (container.read(appConfigProvider).environment == target) return;
  // Les rappels viennent des suivis et du programme de ce serveur : ils
  // seraient faux sur l'autre. Replanifiés au retour.
  try {
    await container.read(reminderSchedulerProvider).cancelAll();
  } on AppException {
    // Un rappel resté planifié ne doit pas empêcher de changer de serveur.
  }
  await container.read(appConfigProvider.notifier).switchTo(target);
}

/// Les saisies du compte connecté qui ne partiront pas tant que l'app est
/// sur l'autre serveur : la confirmation le dit.
int serverSwitchUnsentCount(List<OutboxOperation> queue, Account? account) =>
    account == null ? 0 : unsentOperationCount(queue, account);

String serverLabel(AppEnvironment environment, AppLocalizations l10n) =>
    switch (environment) {
      AppEnvironment.production => l10n.serverProduction,
      AppEnvironment.development => l10n.serverStaging,
    };

/// Le bandeau permanent : nul en production.
String? serverBanner(AppEnvironment environment, AppLocalizations l10n) =>
    environment == AppEnvironment.production ? null : l10n.serverBanner;

String serverSwitchMessage(
  AppEnvironment target,
  int unsent,
  AppLocalizations l10n,
) => unsent == 0
    ? l10n.serverSwitchBody
    : '${l10n.serverSwitchBody}\n\n${l10n.serverSwitchUnsent(unsent)}';
