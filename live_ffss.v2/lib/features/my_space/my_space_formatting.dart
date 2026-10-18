import 'package:intl/intl.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/router/app_router.dart';
import 'package:live_ffss_v2/domain/account.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/domain/follows.dart';
import 'package:live_ffss_v2/domain/my_space.dart';
import 'package:live_ffss_v2/domain/officials.dart';
import 'package:live_ffss_v2/domain/outbox.dart';
import 'package:live_ffss_v2/features/home/competition_formatting.dart';
import 'package:live_ffss_v2/features/my_space/my_space_providers.dart';
import 'package:live_ffss_v2/features/programme/programme_formatting.dart';
import 'package:live_ffss_v2/features/results/athlete_providers.dart';

String mySpaceCardTitle(MySpaceCard card, AppLocalizations l10n) =>
    switch (card) {
      AthleteSpaceCard() => l10n.mySpaceAthlete,
      ClubSpaceCard(:final club) => l10n.mySpaceClub(club.label),
      OfficialSpaceCard() => l10n.mySpaceOfficial,
      AdminSpaceCard() => l10n.mySpaceAdmin,
    };

/// Pour l'officiel, sa fonction (« B - Juge de virage/obstacles ») : c'est
/// ce qui le distingue d'un autre officiel.
String mySpaceCardSubtitle(MySpaceCard card, AppLocalizations l10n) =>
    switch (card) {
      AthleteSpaceCard() => l10n.mySpaceAthleteSubtitle,
      ClubSpaceCard() => l10n.mySpaceClubSubtitle,
      OfficialSpaceCard(:final role?) when role.principal =>
        l10n.mySpacePrincipalJudge,
      OfficialSpaceCard(:final role?) when role.levelLabel.isNotEmpty =>
        role.levelLabel,
      OfficialSpaceCard() => l10n.mySpaceOfficialSubtitle,
      AdminSpaceCard() => l10n.mySpaceAdminSubtitle,
    };

/// L'admin ouvre l'espace de n'importe quel club : il le choisit dans la liste
/// des clubs des infos de la compétition.
String mySpaceCardRoute(MySpaceCard card, int competitionId) => switch (card) {
  AthleteSpaceCard() => Routes.mySpaceAthlete(competitionId),
  ClubSpaceCard(:final club) => Routes.mySpaceClub(competitionId, club.id),
  OfficialSpaceCard() => Routes.mySpaceOfficial(competitionId),
  AdminSpaceCard() => Routes.mySpaceInfos(competitionId),
};

/// La prochaine course à courir : la plus tôt prévue, celles sans heure après.
/// Une course passée son heure sans résultat reste la prochaine : le
/// programme prend souvent du retard.
AthleteRace? nextRace(List<AthleteRace> races) {
  AthleteRace? next;
  for (final race in races) {
    if (!race.toRun) continue;
    final start = race.plannedStart;
    final best = next?.plannedStart;
    if (next == null ||
        (start != null && (best == null || start.isBefore(best)))) {
      next = race;
    }
  }
  return next;
}

/// « dans 25 min », « dans 2 h », « maintenant » ; au-delà d'un jour, le jour
/// et l'heure (« sam. 08:58 »).
String? startsInLabel(DateTime? start, DateTime now, AppLocalizations l10n) {
  if (start == null) return null;
  final wait = start.difference(now);
  if (wait <= Duration.zero) return l10n.mySpaceStartsNow;
  if (wait < const Duration(hours: 1)) {
    // Arrondi au-dessus : « dans 0 min » ne voudrait rien dire.
    final minutes = (wait.inSeconds + 59) ~/ 60;
    return l10n.mySpaceStartsInMinutes(minutes);
  }
  if (wait < const Duration(days: 1)) {
    return l10n.mySpaceStartsInHours(wait.inHours);
  }
  return DateFormat('EEE HH:mm', l10n.localeName).format(start);
}

/// Le badge de la carte Athlète : quand part sa prochaine course.
String? athleteBadge(
  List<AthleteRace>? races,
  DateTime now,
  AppLocalizations l10n,
) {
  if (races == null) return null;
  return startsInLabel(nextRace(races)?.plannedStart, now, l10n);
}

/// « Prochaine : 08:58 · 100m Bouée tube » ([races] : voir
/// `followedRacesProvider`) ; son club tant que le programme se lit, s'il n'a
/// pu l'être, ou pour un suivi enregistré sans ses épreuves.
String followedAthleteLine(
  FollowedAthlete athlete,
  Map<int, FollowedRace?>? races,
  AppLocalizations l10n,
) {
  if (races == null || !races.containsKey(athlete.participantId)) {
    return athlete.club;
  }
  final next = races[athlete.participantId];
  if (next == null) return l10n.mySpaceNoNextRace;
  return l10n.mySpaceNextRace(
    [
      timeLabel(next.start),
      next.event.disciplineName,
    ].where((part) => part.isNotEmpty).join(' · '),
  );
}

/// Les saisies refusées du compte connecté sur la compétition : celles d'un
/// autre compte ne le regardent pas.
int rejectedEntries(
  List<OutboxOperation> queue,
  String? account,
  int competitionId,
) {
  if (account == null) return 0;
  return queue
      .where(
        (op) =>
            op.state == OutboxState.rejected &&
            op.competitionId == competitionId &&
            isSameAccount(op.account, account),
      )
      .length;
}

/// Le badge de la carte Officiel : « 2 refusées », rien sans refus.
String? officialBadge(
  List<OutboxOperation> queue,
  String? account,
  int competitionId,
  AppLocalizations l10n,
) {
  final count = rejectedEntries(queue, account, competitionId);
  return count == 0 ? null : l10n.mySpaceRejected(count);
}

/// Le sous-titre de « Mes suivis » : nul pour une lecture en échec (la page
/// dit l'erreur, pas « aucun suivi »), vide pendant la première lecture.
String? followsSummaryOf(
  Follows? follows,
  AppLocalizations l10n, {
  required bool failed,
}) {
  if (follows != null) return followsSummary(follows, l10n);
  return failed ? null : '';
}

/// « 3 athlètes · 1 club », sans le morceau vide.
String followsSummary(Follows follows, AppLocalizations l10n) {
  final athletes = follows.athletes.length;
  final clubs = follows.clubs.length;
  if (athletes == 0 && clubs == 0) return l10n.mySpaceNoFollow;
  return [
    if (athletes > 0) l10n.mySpaceAthleteCount(athletes),
    if (clubs > 0) l10n.mySpaceClubCount(clubs),
  ].join(' · ');
}

/// Le titre d'un groupe de [groupOfficials] : nul pour le juge principal,
/// vide pour un niveau que le site ne donne pas.
String officialGroupLabel(String? label, AppLocalizations l10n) =>
    switch (label) {
      null => l10n.mySpacePrincipalJudge,
      '' => l10n.mySpaceOfficialLevelUnknown,
      final level => l10n.mySpaceOfficialLevel(level),
    };

/// « Jour 3 · TOULON », sans le morceau vide.
String officialDetail(CompetitionOfficial official) => [
  official.daysLabel,
  official.club,
].where((part) => part.trim().isNotEmpty).join(' · ');

/// Le lieu, sinon le nom : la première ligne des infos ne reste pas vide.
String competitionPlace(CompetitionSummary competition) {
  final location = competition.location?.trim() ?? '';
  return location.isEmpty ? competition.name : location;
}

/// « 27 – 29 mars 2026 · Eau plate ».
String competitionDatesLine(
  CompetitionSummary competition,
  AppLocalizations l10n,
) => [
  competition.dateRangeLabel(l10n.localeName),
  competition.disciplineLabel(l10n),
].join(' · ');

/// « 346 athlètes · 46 clubs · 60 épreuves ».
String competitionCountsLine(CompetitionInfo info, AppLocalizations l10n) => [
  l10n.mySpaceAthleteCount(info.athletes),
  l10n.mySpaceClubCount(info.clubs.length),
  l10n.mySpaceEventCount(info.events),
].join(' · ');

String clubAthletesLabel(int count, AppLocalizations l10n) =>
    l10n.mySpaceAthleteCount(count);

/// Ce que montre la section des espaces du compte.
sealed class SpacesView {
  const SpacesView();
}

final class SpacesLoading extends SpacesView {
  const SpacesLoading();

  @override
  bool operator ==(Object other) => other is SpacesLoading;

  @override
  int get hashCode => 0;
}

/// Les rôles n'ont pu être lus : « Réessayer ».
final class SpacesFailed extends SpacesView {
  const SpacesFailed();

  @override
  bool operator ==(Object other) => other is SpacesFailed;

  @override
  int get hashCode => 1;
}

/// Le compte n'a aucun espace sur la compétition.
final class SpacesNone extends SpacesView {
  const SpacesNone();

  @override
  bool operator ==(Object other) => other is SpacesNone;

  @override
  int get hashCode => 2;
}

final class SpacesShown extends SpacesView {
  const SpacesShown(this.cards);

  final MySpaceCards cards;

  @override
  bool operator ==(Object other) =>
      other is SpacesShown && other.cards == cards;

  @override
  int get hashCode => cards.hashCode;
}

/// Une relecture (changement de compte) ou un échec ne montre jamais les
/// cartes précédentes : ce seraient celles d'un autre compte. Une carte
/// Athlète inconnue (participants illisibles) se montre même seule, pour
/// qu'on puisse la relire.
SpacesView spacesView({
  required bool loading,
  required bool failed,
  required MySpaceCards? cards,
}) {
  if (loading) return const SpacesLoading();
  if (failed) return const SpacesFailed();
  if (cards == null) return const SpacesLoading();
  if (cards.cards.isEmpty && !cards.athleteUnknown) return const SpacesNone();
  return SpacesShown(cards);
}
