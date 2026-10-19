import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/notifications/reminder_scheduler.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/domain/follows.dart';
import 'package:live_ffss_v2/domain/my_space.dart';
import 'package:live_ffss_v2/features/follows/follows_providers.dart';
import 'package:live_ffss_v2/features/follows/reminder_records.dart';
import 'package:live_ffss_v2/features/programme/programme_providers.dart';
import 'package:live_ffss_v2/features/reminders/reminders_formatting.dart';
import 'package:live_ffss_v2/features/results/results_providers.dart';
import 'package:live_ffss_v2/features/settings/app_language.dart';
import 'package:live_ffss_v2/features/settings/reminder_lead.dart';
import 'package:live_ffss_v2/features/shell/current_competition.dart';
import 'package:live_ffss_v2/features/shell/space_competition.dart';

/// Les rappels planifiés pour une compétition : ses athlètes suivis et le
/// licencié connecté (pas tous les athlètes d'un club suivi). Ils partent de
/// ce que l'appareil garde (suivis, athlète connecté, séries connues) : sans
/// personne, rien n'est lu. Recalculés quand le programme, les suivis, le
/// délai ou la permission changent ; le planificateur n'est appelé que si la
/// liste change.
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
    final permittedRead = ref.watch(reminderPermissionProvider.future)
      ..ignore();
    final lead = await ref.watch(reminderLeadProvider.future);
    if (!ref.mounted) return const [];
    if (lead == ReminderLead.off) return _apply(scheduler, const []);

    // Ce que l'appareil garde d'abord : sans athlète, aucune lecture.
    final followsRead = ref.watch(followsProvider(competitionId).future);
    final selfRead = ref.watch(selfAthleteProvider(competitionId).future)
      ..ignore();
    final heatsRead = ref.watch(knownHeatsProvider(competitionId).future)
      ..ignore();
    final follows = await followsRead;
    final self = await selfRead;
    final knownHeats = await heatsRead;
    if (!ref.mounted) return const [];
    final athletes = <FollowedAthlete>[
      // Le connecté d'abord : ses engagements sont ceux des participants.
      ?self,
      ...follows.athletes,
    ].where((athlete) => athlete.eventIds.isNotEmpty).toList();
    if (athletes.isEmpty) return _apply(scheduler, const []);

    final competition = await ref.watch(
      spaceCompetitionProvider(competitionId).future,
    );
    if (!ref.mounted) return const [];
    // Sans eau plate, pas d'heure de départ que l'app sache lire.
    if (isCoastalOnly(competition)) return _apply(scheduler, const []);

    // Lues ensemble ; celles qu'on n'attend pas encore ne doivent pas
    // remonter leur échec comme non traité.
    final eventsRead = ref.watch(eventsProvider(competitionId).future)
      ..ignore();
    final programmeRead = ref.watch(
      resultsProgrammeProvider(competitionId).future,
    )..ignore();
    final languageRead = ref.watch(appLanguageProvider.future)..ignore();
    final events = await eventsRead;
    final programme = seen ?? await programmeRead;
    AppLanguage language;
    try {
      language = await languageRead;
    } on AppException {
      language = AppLanguage.system;
    }
    final permitted = await permittedRead;
    if (!ref.mounted) return const [];

    return _apply(
      scheduler,
      remindersFor(
        upcomingRaces(athletes, events, programme, knownHeats: knownHeats),
        lead,
        now(),
        appLocalizationsFor(language, PlatformDispatcher.instance.locales),
      ),
      permitted: permitted,
    );
  }

  /// Le planificateur n'est appelé que si la liste a changé : une relecture
  /// identique du programme ne replanifie rien. Sans permission, rien n'est
  /// planifié ni demandé, et le réglage reste : la demande attend un geste.
  Future<List<Reminder>> _apply(
    ReminderScheduler scheduler,
    List<Reminder> reminders, {
    bool permitted = true,
  }) async {
    final scheduled = _scheduled;
    if (scheduled != null && listEquals(scheduled, reminders)) {
      return reminders;
    }
    if (reminders.isEmpty) {
      await scheduler.cancelAll();
    } else {
      if (!permitted) return const [];
      // Une lecture plus récente a pris la main : à elle de planifier.
      if (!ref.mounted) return const [];
      await scheduler.replaceAll(reminders);
    }
    if (!ref.mounted) return reminders;
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
