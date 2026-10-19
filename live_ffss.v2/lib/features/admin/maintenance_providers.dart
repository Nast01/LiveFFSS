import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/config/app_config.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/network/network_log.dart';
import 'package:live_ffss_v2/core/notifications/reminder_scheduler.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/features/admin/admin_formatting.dart';
import 'package:live_ffss_v2/features/auth/admin.dart';
import 'package:live_ffss_v2/features/auth/session.dart';
import 'package:live_ffss_v2/features/follows/follows_providers.dart';
import 'package:live_ffss_v2/features/follows/reminder_records.dart';
import 'package:live_ffss_v2/features/officiel/entry_providers.dart';
import 'package:live_ffss_v2/features/officiel/outbox_service.dart';
import 'package:live_ffss_v2/features/reminders/reminders_providers.dart';
import 'package:live_ffss_v2/features/settings/reminder_lead.dart';
import 'package:live_ffss_v2/features/settings/server_switch.dart';
import 'package:live_ffss_v2/features/shell/space_competition.dart';

/// Les données que l'appareil garde pour la compétition [competitionId] :
/// suivis, séries connues, athlète du compte connecté, couloir suivi. Ni la
/// file d'envoi (des saisies non envoyées s'y perdraient) ni la session n'en
/// font partie.
List<String> competitionLocalKeys(int competitionId) => [
  FollowsNotifier.storageKeyOf(competitionId),
  KnownHeatsNotifier.storageKeyOf(competitionId),
  SelfAthleteNotifier.storageKeyOf(competitionId),
  EntryLaneFilterNotifier.storageKey(competitionId),
];

/// Les actions de maintenance partent d'un bouton, pas d'un fournisseur :
/// elles vérifient elles-mêmes le droit, comme [requireAdmin].
Future<void> _requireAdmin(
  ProviderContainer container,
  int competitionId,
) async {
  final access = container.listen(
    adminAccessProvider(competitionId).future,
    (_, _) {},
  );
  try {
    if (!await access.read()) throw const AdminOnlyException();
  } finally {
    access.close();
  }
}

/// Efface [competitionLocalKeys] et relit leurs fournisseurs, qui repartent
/// de rien (les rappels suivent les suivis). Faux si une clé n'a pu être
/// effacée : les autres le sont quand même.
Future<bool> clearCompetitionData(
  ProviderContainer container,
  int competitionId,
) async {
  await _requireAdmin(container, competitionId);
  final store = container.read(localStoreProvider);
  var cleared = true;
  for (final key in competitionLocalKeys(competitionId)) {
    try {
      await store.delete(key);
    } on AppException {
      cleared = false;
    }
  }
  container
    ..invalidate(followsProvider(competitionId))
    ..invalidate(knownHeatsProvider(competitionId))
    ..invalidate(selfAthleteProvider(competitionId))
    ..invalidate(entryLaneFilterProvider(competitionId));
  return cleared;
}

/// Relit tout : l'app repart d'un conteneur neuf sur le même serveur, comme
/// après un changement de serveur. Plus sûr qu'une liste de fournisseurs à
/// invalider, qu'un oubli laisserait sur une valeur périmée ; la page ouverte
/// revient à l'onglet d'ouverture. Rien de stocké n'est touché. Faux, rien
/// n'a changé : une saisie en cours d'envoi n'a pas répondu dans [timeout]
/// ([settleBeforeRemount]).
Future<bool> forceReload(
  ProviderContainer container,
  int competitionId, {
  Duration timeout = remountTimeout,
}) async {
  await _requireAdmin(container, competitionId);
  if (!await settleBeforeRemount(container, timeout: timeout)) return false;
  container.read(serverRestartProvider)(
    container.read(appConfigProvider).environment,
  );
  return true;
}

/// L'id de la notification de test : jamais celui d'un rappel, pris modulo
/// 0x7fffffff (`reminderId`).
const int testReminderId = 0x7fffffff;

enum TestNotificationOutcome { sent, unsupported, notPermitted, failed }

/// Montre une notification tout de suite, par le canal des rappels, sans
/// toucher aux rappels planifiés. Android seulement, et sans rien demander :
/// la permission se demande depuis le délai des rappels.
Future<TestNotificationOutcome> sendTestNotification(
  ProviderContainer container,
  int competitionId, {
  required String title,
  required String body,
}) async {
  await _requireAdmin(container, competitionId);
  if (!container.read(remindersSupportedProvider)) {
    return TestNotificationOutcome.unsupported;
  }
  final scheduler = container.read(reminderSchedulerProvider);
  try {
    if (!await scheduler.isPermitted()) {
      return TestNotificationOutcome.notPermitted;
    }
    await scheduler.show(
      Reminder(
        id: testReminderId,
        at: container.read(clockProvider)(),
        title: title,
        body: body,
      ),
    );
    return TestNotificationOutcome.sent;
  } on AppException {
    return TestNotificationOutcome.failed;
  }
}

/// Les rappels planifiés pour la compétition, tels que les rappels les ont
/// donnés au planificateur.
final plannedRemindersProvider = FutureProvider.autoDispose
    .family<List<Reminder>, int>((ref, competitionId) async {
      await requireAdmin(ref, competitionId);
      if (!ref.mounted) return const [];
      return ref.watch(remindersProvider(competitionId).future);
    });

/// Le rapport de diagnostic de la compétition ([diagnosticReport]).
final diagnosticReportProvider = FutureProvider.autoDispose.family<String, int>(
  (ref, competitionId) async {
    await requireAdmin(ref, competitionId);
    if (!ref.mounted) return '';
    String? name;
    try {
      name = (await ref.watch(
        spaceCompetitionProvider(competitionId).future,
      )).name;
    } on AppException {
      // Le rapport sert surtout quand tout va mal : l'id suffit.
      name = null;
    }
    if (!ref.mounted) return '';
    final account = ref.watch(sessionProvider).value;
    return diagnosticReport(
      version: appVersion,
      environment: ref.watch(appConfigProvider).environment,
      competitionId: competitionId,
      competitionName: name,
      accountAdmin: account?.isAdmin ?? false,
      queue: ref.watch(outboxProvider),
      log: ref.watch(networkLogProvider),
      now: ref.watch(clockProvider)(),
    );
  },
);
