import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/config/app_environment.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/domain/account.dart';
import 'package:live_ffss_v2/domain/outbox.dart';
import 'package:live_ffss_v2/features/auth/auth_formatting.dart';
import 'package:live_ffss_v2/features/officiel/outbox_service.dart';
import 'package:live_ffss_v2/features/settings/reminder_lead.dart';

/// Ce qu'on laisse à une saisie en cours d'envoi pour répondre avant de
/// remonter l'app : au-delà de 3 requêtes de 30 s au pire, l'officiel
/// préfère réessayer que d'attendre.
const remountTimeout = Duration(seconds: 20);

/// Ce qui doit être réglé dans [container] avant de le remplacer par un
/// conteneur neuf : la saisie en vol, puis les rappels en cours de
/// planification. Faux si la saisie n'a pas répondu dans [timeout], et
/// l'app ne doit pas être remontée.
Future<bool> settleBeforeRemount(
  ProviderContainer container, {
  required Duration timeout,
}) async {
  final outbox = container.read(outboxProvider.notifier);
  if (!await outbox.holdForRemount(timeout: timeout)) return false;
  // Après la file : refusé, l'app continue et doit encore planifier. Un
  // appel à la plateforme resté pendu ne bloque pas le remontage pour
  // autant.
  await container
      .read(reminderPlanningProvider)
      .close()
      .timeout(timeout, onTimeout: () {});
  return true;
}

/// Passe l'app sur [target]. Rien n'est effacé : chaque serveur garde sous
/// son préfixe jeton, compte, compétition active, suivis et file d'envoi.
/// L'app repart d'un conteneur neuf (`AppContainerHost`) : session reprise
/// de celle enregistrée pour [target], routeur sur l'onglet d'ouverture.
/// Faux, rien n'a changé : une saisie en cours d'envoi n'a pas répondu dans
/// [timeout] ([settleBeforeRemount]).
Future<bool> switchServer(
  ProviderContainer container,
  AppEnvironment target, {
  Duration timeout = remountTimeout,
}) async {
  if (container.read(appConfigProvider).environment == target) return true;
  if (!await settleBeforeRemount(container, timeout: timeout)) return false;
  // Les rappels viennent des suivis et du programme de ce serveur : ils
  // seraient faux sur l'autre. La nouvelle app replanifie les siens.
  try {
    // Directement au planificateur : `settleBeforeRemount` a fermé le
    // passage des rappels de ce conteneur.
    await container.read(reminderSchedulerProvider).cancelAll();
  } on AppException {
    // Un rappel resté planifié ne doit pas empêcher de changer de serveur.
  }
  try {
    await container
        .read(globalStoreProvider)
        .write(AppEnvironment.environmentKey, target.name);
  } on AppException {
    // Changé pour cette exécution : le prochain lancement reviendra au
    // serveur d'avant.
  }
  container.read(serverRestartProvider)(target);
  return true;
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

String serverSwitchMessage(int unsent, AppLocalizations l10n) => unsent == 0
    ? l10n.serverSwitchBody
    : '${l10n.serverSwitchBody}\n\n${l10n.serverSwitchUnsent(unsent)}';
