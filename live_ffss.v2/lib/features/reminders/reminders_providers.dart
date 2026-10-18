import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/notifications/reminder_scheduler.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/domain/my_space.dart';
import 'package:live_ffss_v2/features/follows/follows_providers.dart';
import 'package:live_ffss_v2/features/my_space/my_space_providers.dart';
import 'package:live_ffss_v2/features/programme/programme_providers.dart';
import 'package:live_ffss_v2/features/reminders/reminders_formatting.dart';
import 'package:live_ffss_v2/features/results/results_providers.dart';
import 'package:live_ffss_v2/features/settings/app_language.dart';
import 'package:live_ffss_v2/features/shell/current_competition.dart';

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
      bool granted;
      try {
        granted = await ref.read(reminderSchedulerProvider).requestPermission();
      } on AppException {
        granted = false;
      }
      if (!ref.mounted) return;
      if (!granted) return deny();
    }
    ref.read(reminderPermissionDeniedProvider.notifier).set(denied: false);
    await _save(lead);
  }

  /// La permission a été refusée : désactivé, et enregistré tel, pour ne pas
  /// redemander à chaque lancement.
  Future<void> deny() async {
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

/// Les rappels planifiés pour une compétition : ses athlètes suivis et le
/// licencié connecté, s'il y est engagé (pas tous les athlètes d'un club
/// suivi). Calculés au lancement, puis quand le programme, les suivis ou le
/// délai changent ; le planificateur n'est appelé que si la liste change.
final remindersProvider = AsyncNotifierProvider.autoDispose
    .family<RemindersNotifier, List<Reminder>, int>(RemindersNotifier.new);

class RemindersNotifier extends AsyncNotifier<List<Reminder>> {
  RemindersNotifier(this.competitionId);

  final int competitionId;

  /// Ce que le planificateur a reçu en dernier, gardé d'une reconstruction à
  /// l'autre ; nul avant la première fois, pour que le lancement replanifie
  /// toujours.
  List<Reminder>? _scheduled;

  @override
  Future<List<Reminder>> build() async {
    try {
      return await _plan();
    } on AppException {
      // Hors ligne : les rappels déjà planifiés restent, plutôt que d'être
      // effacés faute de pouvoir les recalculer.
      return _scheduled ?? const [];
    }
  }

  Future<List<Reminder>> _plan() async {
    // Tout ce qui sert de `ref` est pris avant la première attente.
    final scheduler = ref.watch(reminderSchedulerProvider);
    final now = ref.watch(clockProvider);
    // Les relectures du programme par un écran qui le suit, sans le garder
    // en vie pour les rappels seuls.
    final seen = ref.watch(lastProgrammeProvider(competitionId));
    final lead = await ref.watch(reminderLeadProvider.future);
    if (!ref.mounted) return const [];
    if (lead == ReminderLead.off) return _apply(scheduler, const []);

    final competition = await ref.watch(
      spaceCompetitionProvider(competitionId).future,
    );
    if (!ref.mounted) return const [];
    // Sans eau plate, pas d'heure de départ que l'app sache lire.
    if (isCoastalOnly(competition)) return _apply(scheduler, const []);

    // Lues ensemble ; celles qu'on n'attend pas encore ne doivent pas
    // remonter leur échec comme non traité.
    final followsRead = ref.watch(followsProvider(competitionId).future);
    final cardsRead = ref.watch(mySpaceCardsProvider(competitionId).future)
      ..ignore();
    final eventsRead = ref.watch(eventsProvider(competitionId).future)
      ..ignore();
    final programmeRead = ref.watch(
      resultsProgrammeProvider(competitionId).future,
    )..ignore();
    final languageRead = ref.watch(appLanguageProvider.future)..ignore();
    final follows = await followsRead;
    final cards = await cardsRead;
    final events = await eventsRead;
    final programme = seen ?? await programmeRead;
    AppLanguage language;
    try {
      language = await languageRead;
    } on AppException {
      language = AppLanguage.system;
    }
    if (!ref.mounted) return const [];
    // Engagement inconnu : ses rappels ne sont pas effacés pour autant.
    if (cards.athleteUnknown) return _scheduled ?? const [];

    final athletes = <RemindedAthlete>[
      // Le connecté d'abord : ses engagements sont lus, pas gardés.
      for (final card in cards.cards)
        if (card case AthleteSpaceCard(:final participant))
          (
            participantId: participant.id,
            name: [
              participant.firstName,
              participant.lastName,
            ].where((part) => part.isNotEmpty).join(' '),
            eventIds: [for (final entry in participant.entries) entry.eventId],
          ),
      for (final athlete in follows.athletes)
        (
          participantId: athlete.participantId,
          name: athlete.name,
          eventIds: athlete.eventIds,
        ),
    ];
    return _apply(
      scheduler,
      remindersFor(
        upcomingRaces(athletes, events, programme),
        lead,
        now(),
        appLocalizationsFor(language, PlatformDispatcher.instance.locales),
      ),
    );
  }

  /// Le planificateur n'est appelé que si la liste a changé : une relecture
  /// identique du programme ne replanifie rien.
  Future<List<Reminder>> _apply(
    ReminderScheduler scheduler,
    List<Reminder> reminders,
  ) async {
    final scheduled = _scheduled;
    if (scheduled != null && listEquals(scheduled, reminders)) {
      return reminders;
    }
    if (reminders.isEmpty) {
      await scheduler.cancelAll();
    } else {
      // Demandée au premier rappel à planifier : le délai est actif par
      // défaut. Déjà accordée, elle ne demande rien.
      final granted = await scheduler.requestPermission();
      if (!ref.mounted) return const [];
      if (!granted) {
        await ref.read(reminderLeadProvider.notifier).deny();
        return const [];
      }
      await scheduler.replaceAll(reminders);
    }
    _scheduled = reminders;
    return reminders;
  }
}

/// Les rappels de la compétition des onglets, sur Android seulement :
/// l'app l'écoute dès le lancement. Changer de compétition remplace les
/// rappels de l'autre.
final activeRemindersProvider = Provider<void>((ref) {
  if (!ref.watch(remindersSupportedProvider)) return;
  final competitionId = ref.watch(
    currentCompetitionProvider.select((competition) => competition?.id),
  );
  if (competitionId != null) ref.watch(remindersProvider(competitionId));
});
