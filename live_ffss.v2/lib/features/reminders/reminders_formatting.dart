import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/notifications/reminder_scheduler.dart';
import 'package:live_ffss_v2/domain/my_space.dart';
import 'package:live_ffss_v2/features/programme/programme_formatting.dart';
import 'package:live_ffss_v2/features/reminders/reminders_providers.dart';
import 'package:live_ffss_v2/features/results/results_formatting.dart';

/// L'id du rappel d'un athlète sur une épreuve. Pris au participant, pas à
/// l'engagement : un suivi garde ses engagements et ses épreuves sans les
/// apparier. Calculé, pas haché : `Object.hash` change d'un lancement à
/// l'autre. Sur 31 bits, comme les ids de notification Android.
int reminderId(int participantId, int eventId) =>
    (participantId * 100003 + eventId) % 0x7fffffff;

/// Les rappels des [races], [lead] avant leur départ, ceux encore à venir ;
/// triés par heure puis id, pour qu'un même calcul donne une même liste.
List<Reminder> remindersFor(
  List<UpcomingRace> races,
  ReminderLead lead,
  DateTime now,
  AppLocalizations l10n,
) {
  final before = lead.before;
  if (before == null) return const [];
  final reminders = [
    for (final race in races)
      if (reminderAt(race.start, before, now) case final at?)
        Reminder(
          id: reminderId(race.participantId, race.event.id),
          at: at,
          title: l10n.reminderTitle(race.name, lead.minutes),
          body: l10n.reminderBody(
            athleteRaceTitle(race.event, l10n),
            timeLabel(race.start),
          ),
        ),
  ];
  reminders.sort((a, b) {
    final byTime = a.at.compareTo(b.at);
    return byTime != 0 ? byTime : a.id.compareTo(b.id);
  });
  return reminders;
}

String reminderLeadLabel(ReminderLead lead, AppLocalizations l10n) =>
    lead == ReminderLead.off
    ? l10n.reminderLeadOff
    : l10n.reminderLeadMinutes(lead.minutes);
