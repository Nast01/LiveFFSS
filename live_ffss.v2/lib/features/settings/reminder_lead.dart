import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/notifications/reminder_scheduler.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/features/settings/app_language.dart';

/// Combien de temps avant une course le téléphone la rappelle.
enum ReminderLead {
  off(0),
  five(5),
  fifteen(15),
  thirty(30);

  const ReminderLead(this.minutes);

  final int minutes;

  /// Nul : pas de rappel.
  Duration? get before => this == off ? null : Duration(minutes: minutes);

  /// La valeur enregistrée.
  String get code => '$minutes';

  /// Rien d'enregistré, ou une valeur inconnue : 15 min, le défaut de la
  /// spec.
  static ReminderLead fromCode(String? code) {
    for (final lead in values) {
      if (lead.code == code) return lead;
    }
    return fifteen;
  }
}

/// Le passage obligé des rappels vers le planificateur, un par conteneur :
/// le remontage l'arrête ([ReminderPlanning.close]).
final reminderPlanningProvider = Provider<ReminderPlanning>(
  (ref) => ReminderPlanning(),
);

/// Hors Android, un planificateur sans effet. Le canal porte le nom de la
/// langue de l'app : il se recrée quand elle change.
final reminderSchedulerProvider = Provider<ReminderScheduler>((ref) {
  if (!ref.watch(remindersSupportedProvider)) {
    return const NoReminderScheduler();
  }
  final language = ref.watch(appLanguageProvider).value ?? AppLanguage.system;
  return LocalNotificationsScheduler(
    FlutterLocalNotificationsPlugin(),
    channelName: appLocalizationsFor(
      language,
      PlatformDispatcher.instance.locales,
    ).reminderChannelName,
  );
});

/// Les notifications sont-elles permises ? Lu sans rien demander : la
/// demande ne part que d'un geste ([ReminderLeadNotifier.select],
/// `toggleAthleteFollow`).
class ReminderPermissionNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    try {
      return await ref.watch(reminderSchedulerProvider).isPermitted();
    } on AppException {
      return false;
    }
  }

  /// Sur un geste de l'utilisateur seulement.
  Future<bool> request() async {
    bool granted;
    try {
      granted = await ref.read(reminderSchedulerProvider).requestPermission();
    } on AppException {
      granted = false;
    }
    state = AsyncData(granted);
    return granted;
  }
}

final reminderPermissionProvider =
    AsyncNotifierProvider<ReminderPermissionNotifier, bool>(
      ReminderPermissionNotifier.new,
    );

class ReminderLeadNotifier extends AsyncNotifier<ReminderLead> {
  /// Clé globale (`AppEnvironment.globalKeys`) : comme la langue, une
  /// préférence d'interface qui ne vient pas du serveur.
  static const storageKey = 'reminder_lead';

  @override
  Future<ReminderLead> build() async {
    try {
      return ReminderLead.fromCode(
        await ref.watch(localStoreProvider).read(storageKey),
      );
    } on AppException {
      return ReminderLead.fifteen;
    }
  }

  /// Activer demande la permission des notifications : refusée, les rappels
  /// restent désactivés et la page le dit.
  Future<void> select(ReminderLead lead) async {
    if (lead != ReminderLead.off) {
      final granted = await ref
          .read(reminderPermissionProvider.notifier)
          .request();
      if (!ref.mounted) return;
      if (!granted) return _deny();
    }
    ref.read(reminderPermissionDeniedProvider.notifier).set(denied: false);
    await _save(lead);
  }

  /// Suivre un athlète, rappels actifs : la permission est demandée si elle
  /// manque, comme au choix du délai.
  Future<void> ensurePermission() async {
    final lead = await future;
    if (!ref.mounted || lead == ReminderLead.off) return;
    final permission = ref.read(reminderPermissionProvider.notifier);
    if (await ref.read(reminderPermissionProvider.future)) return;
    if (!ref.mounted) return;
    if (!await permission.request() && ref.mounted) await _deny();
  }

  /// Refusée sur un geste : désactivé, et enregistré tel, pour ne pas
  /// redemander.
  Future<void> _deny() async {
    ref.read(reminderPermissionDeniedProvider.notifier).set(denied: true);
    await _save(ReminderLead.off);
  }

  /// L'état d'abord : un stockage en panne garde le choix jusqu'à la
  /// fermeture de l'app.
  Future<void> _save(ReminderLead lead) async {
    state = AsyncData(lead);
    final store = ref.read(localStoreProvider);
    try {
      if (lead == ReminderLead.fifteen) {
        await store.delete(storageKey);
      } else {
        await store.write(storageKey, lead.code);
      }
    } on AppException {
      // Choix gardé en mémoire.
    }
  }
}

final reminderLeadProvider =
    AsyncNotifierProvider<ReminderLeadNotifier, ReminderLead>(
      ReminderLeadNotifier.new,
    );

/// Vrai après un refus des notifications, jusqu'au prochain choix : la page
/// dit pourquoi les rappels se sont désactivés.
class ReminderPermissionDenied extends Notifier<bool> {
  @override
  bool build() => false;

  void set({required bool denied}) => state = denied;
}

final reminderPermissionDeniedProvider =
    NotifierProvider<ReminderPermissionDenied, bool>(
      ReminderPermissionDenied.new,
    );
