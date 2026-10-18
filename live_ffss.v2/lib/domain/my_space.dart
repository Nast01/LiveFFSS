import 'package:live_ffss_v2/domain/competition_roles.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/follows.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/outbox.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/race_result.dart';
import 'package:live_ffss_v2/domain/run_status.dart';
import 'package:live_ffss_v2/domain/series_link.dart';

/// Le participant du licencié connecté ; nul sans licencié ou sans engagement.
Participant? participantOfLicensee(
  List<Participant> participants,
  int? licenseeId,
) {
  if (licenseeId == null) return null;
  for (final participant in participants) {
    if (participant.licenseeId == licenseeId) return participant;
  }
  return null;
}

/// Les participants du club [clubId], triés par nom puis prénom.
List<Participant> clubAthletes(List<Participant> participants, int clubId) {
  final athletes = [
    for (final participant in participants)
      if (participant.clubId == clubId) participant,
  ];
  athletes.sort((a, b) {
    final byLast = a.lastName.toLowerCase().compareTo(b.lastName.toLowerCase());
    return byLast != 0
        ? byLast
        : a.firstName.toLowerCase().compareTo(b.firstName.toLowerCase());
  });
  return athletes;
}

/// Ce que le compte est pour un club : son référent, ou l'admin, qui peut
/// ouvrir l'espace de n'importe quel club. Les deux pourront déclarer les
/// forfaits du club (lot 6b) ; les autres le consultent seulement.
enum ClubRole { referee, admin, none }

/// Référent d'abord : un admin référent d'un club y est d'abord son référent.
/// Sans rôles lus, rien : un droit ne se suppose pas.
ClubRole clubRole(CompetitionRoles? roles, int clubId) {
  if (roles == null) return ClubRole.none;
  if (roles.refereeClubs.any((club) => club.id == clubId)) {
    return ClubRole.referee;
  }
  return roles.isAdmin ? ClubRole.admin : ClubRole.none;
}

/// Un forfait publié : statut [statusForfeit] (codes de V3,
/// `ResultPublisher`), ou le
/// complément `F` ou `FF` (forfait pour la finale). Le site ne publie pas les
/// forfaits déclarés avant la course ailleurs que dans les places, lues une à
/// une : ils viendront au lot 6b.
bool isForfeit(EventResult result) =>
    result.status == statusForfeit ||
    result.complement == 'F' ||
    result.complement == 'FF';

/// Les clubs de la compétition, par `clubId` : un participant sans `clubId`
/// n'a pas de club à qui le rattacher. Le libellé est celui du premier
/// participant rencontré, FFSS n'en publiant pas d'autre.
List<({int id, String label, int athletes})> competitionClubs(
  List<Participant> participants,
) {
  final labels = <int, String>{};
  final counts = <int, int>{};
  for (final participant in participants) {
    final clubId = participant.clubId;
    if (clubId == null) continue;
    labels.putIfAbsent(clubId, () => participant.club);
    counts[clubId] = (counts[clubId] ?? 0) + 1;
  }
  final clubs = [
    for (final id in labels.keys)
      (id: id, label: labels[id]!, athletes: counts[id]!),
  ];
  clubs.sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
  return clubs;
}

/// Les séries terminées dont les places se lisent (elles ont une série FFSS),
/// dans l'ordre du programme.
List<Heat> heatsToCheck(Programme programme) => [
  for (final meeting in programme.meetings)
    for (final item in meeting.items)
      for (final heat in item.heats)
        if (heat.status == RunStatus.finished && heat.seriesId != null) heat,
];

/// Un engagement attend une saisie quand ni les chronométreurs (aucun
/// `TempsLive` > 0 dans [chronos]), ni le juge ([entryIdsWithPublishedTime]),
/// ni l'officiel (une saisie de [pending], propre à la série) n'ont rien posé.
/// Une saisie refusée n'a rien écrit : elle ne compte pas.
bool needsEntry(
  Map<int, List<int?>> chronos,
  Iterable<int> entryIdsWithPublishedTime,
  Iterable<OutboxOperation> pending,
) {
  final hasChrono = chronos.values.any(
    (times) => times.any((time) => time != null && time > 0),
  );
  final hasQueued = pending.any((op) => op.state != OutboxState.rejected);
  return !hasChrono && entryIdsWithPublishedTime.isEmpty && !hasQueued;
}

/// Quand rappeler un départ en [start], [before] à l'avance ; nul sans départ
/// ou si l'heure du rappel est déjà passée.
DateTime? reminderAt(DateTime? start, Duration before, DateTime now) {
  if (start == null) return null;
  final at = start.subtract(before);
  return at.isAfter(now) ? at : null;
}

/// La prochaine course d'un athlète suivi : une épreuve et son départ prévu.
typedef FollowedRace = ({CompetitionEvent event, DateTime? start});

/// Tirée du programme seul, sans ses classements : la plus tôt de ses
/// épreuves dont le tour séries n'est pas terminé, au départ prévu de sa
/// première course non terminée (celles sans heure après). Sa propre série
/// n'est pas connue sans les classements : l'heure est celle du tour. Nulle
/// si aucune ne reste à courir.
FollowedRace? followedNextRace(
  FollowedAthlete athlete,
  List<CompetitionEvent> events,
  Programme programme,
) {
  final eventsById = {for (final event in events) event.id: event};
  FollowedRace? next;
  for (final eventId in athlete.eventIds) {
    final event = eventsById[eventId];
    if (event == null) continue;
    final heat = heatsRoundOf(
      programme,
      event,
    ).where((h) => h.status != RunStatus.finished).firstOrNull;
    if (heat == null) continue;
    final start = heat.plannedStart;
    final best = next?.start;
    if (next == null ||
        (start != null && (best == null || start.isBefore(best)))) {
      next = (event: event, start: start);
    }
  }
  return next;
}
