import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/router/app_router.dart';
import 'package:live_ffss_v2/domain/account.dart';
import 'package:live_ffss_v2/domain/competition_roles.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/domain/event_ranking.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/follows.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/manual_timing.dart';
import 'package:live_ffss_v2/domain/my_space.dart';
import 'package:live_ffss_v2/domain/now_running.dart';
import 'package:live_ffss_v2/domain/officials.dart';
import 'package:live_ffss_v2/domain/outbox.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/race_result.dart';
import 'package:live_ffss_v2/features/home/competition_formatting.dart';
import 'package:live_ffss_v2/features/my_space/my_space_providers.dart';
import 'package:live_ffss_v2/features/my_space/official_space_providers.dart';
import 'package:live_ffss_v2/features/officiel/entry_formatting.dart';
import 'package:live_ffss_v2/features/officiel/entry_view.dart';
import 'package:live_ffss_v2/features/programme/programme_formatting.dart';
import 'package:live_ffss_v2/features/results/athlete_providers.dart';
import 'package:live_ffss_v2/features/results/results_formatting.dart';
import 'package:live_ffss_v2/features/results/results_providers.dart';

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

/// L'athlète de l'espace athlète : celui de la carte Athlète, nul si le
/// compte n'est pas engagé.
Participant? spaceAthlete(MySpaceCards cards) {
  for (final card in cards.cards) {
    if (card is AthleteSpaceCard) return card.participant;
  }
  return null;
}

/// « Ma prochaine course · dans 2 h » ; sans heure prévue, le titre seul.
String nextRaceHeadline(
  AthleteRace race,
  DateTime now,
  AppLocalizations l10n,
) => [
  l10n.mySpaceNextRaceTitle,
  ?startsInLabel(race.plannedStart, now, l10n),
].join(' · ');

typedef NextRaceCells = ({String time, String series, String lane});

/// Les cases de la prochaine course. La série vient de « Trouver sa série »
/// ([found]), sinon de sa série déjà publiée ; la ligne, de [found] seul.
NextRaceCells nextRaceCells(AthleteRace race, LaneFound? found) {
  const none = '–';
  final time = athleteRaceTime(race);
  final heat = found?.heat ?? race.series?.heat;
  final series = heat == null
      ? none
      : heat.number > 0
      ? '${heat.number}'
      : heat.name.isEmpty
      ? none
      : heat.name;
  return (
    time: time.isEmpty ? none : time,
    series: series,
    lane: found == null ? none : '${found.lane}',
  );
}

({List<ClubRace> run, List<ClubRace> toRun}) splitClubRaces(
  List<ClubRace> races,
) => (
  run: [
    for (final race in races)
      if (!race.race.toRun) race,
  ],
  toRun: [
    for (final race in races)
      if (race.race.toRun) race,
  ],
);

/// Ses athlètes : un relais nomme ceux du club qui le courent.
String clubRaceTitle(ClubRace race) =>
    [for (final athlete in race.athletes) participantName(athlete)].join(', ');

/// « 100m Bouée tube · Dames · Cadet · Série 6 » : l'épreuve et, si elle est
/// connue, sa série.
String clubRaceLine(ClubRace race, AppLocalizations l10n) {
  final heatName = race.race.series?.heat.name ?? '';
  return [
    athleteRaceTitle(race.race.event, l10n),
    if (race.race.unavailable)
      l10n.athleteRaceUnavailable
    else if (heatName.isNotEmpty)
      heatName,
  ].join(' · ');
}

typedef ClubEventResults = ({CompetitionEvent event, List<ClubRace> races});

/// Les courues groupées par épreuve, dans l'ordre où elles viennent
/// ([clubRaces] les range par épreuve).
List<ClubEventResults> clubResultsByEvent(List<ClubRace> run) {
  final groups = <int, ClubEventResults>{};
  for (final race in run) {
    groups
        .putIfAbsent(
          race.race.event.id,
          () => (event: race.race.event, races: <ClubRace>[]),
        )
        .races
        .add(race);
  }
  return groups.values.toList();
}

/// Les forfaits du club tirés des résultats publiés ([isForfeit]).
List<ClubRace> clubForfeits(List<ClubRace> races) => [
  for (final race in races)
    if (race.race.row case final row? when isForfeit(row.result)) race,
];

String? clubRoleTag(ClubRole role, AppLocalizations l10n) => switch (role) {
  ClubRole.referee => l10n.mySpaceRefereeTag,
  ClubRole.admin => l10n.mySpaceAdminTag,
  ClubRole.none => null,
};

/// Le forfait se déclarera au lot 6b : ses interrupteurs, inactifs, ne se
/// montrent qu'à ceux qui pourront s'en servir.
bool canManageForfeits(ClubRole role) => role != ClubRole.none;

/// Le rang provisoire du club dans les chiffres de son espace.
sealed class ClubRankView {
  const ClubRankView();
}

/// Les classements des clubs (une lecture par épreuve) ne sont pas encore
/// calculés : « Calculer ».
final class RankNotComputed extends ClubRankView {
  const RankNotComputed();

  @override
  bool operator ==(Object other) => other is RankNotComputed;

  @override
  int get hashCode => 0;
}

final class RankComputing extends ClubRankView {
  const RankComputing();

  @override
  bool operator ==(Object other) => other is RankComputing;

  @override
  int get hashCode => 1;
}

final class RankFailed extends ClubRankView {
  const RankFailed();

  @override
  bool operator ==(Object other) => other is RankFailed;

  @override
  int get hashCode => 2;
}

/// [rank] nul : le club n'a pas de points.
final class RankShown extends ClubRankView {
  const RankShown(this.rank);

  final int? rank;

  @override
  bool operator ==(Object other) => other is RankShown && other.rank == rank;

  @override
  int get hashCode => rank.hashCode;
}

/// [asked] : les classements sont calculés ou demandés (l'onglet Résultats
/// les a, ou « Calculer » a été touché). Un calcul déjà fait reste montré,
/// même pendant une relecture ou après son échec. Le classement des clubs se
/// fait par libellé (`clubStandings`). Une compétition côtière n'a pas de
/// classement : « – », sans « Calculer ».
ClubRankView clubRankView({
  required bool asked,
  required bool failed,
  required Standings? standings,
  required String club,
  bool coastal = false,
}) {
  if (coastal) return const RankShown(null);
  if (standings != null) {
    final wanted = club.trim();
    return RankShown(
      standings.clubs.where((c) => c.club.trim() == wanted).firstOrNull?.rank,
    );
  }
  if (!asked) return const RankNotComputed();
  return failed ? const RankFailed() : const RankComputing();
}

/// « 6e », « 6th » ; « – » sans rang.
String clubRankLabel(RankShown view, AppLocalizations l10n) {
  final rank = view.rank;
  return rank == null ? '–' : ordinal(rank, l10n.localeName);
}

/// Le libellé de ses engagés, sinon celui que donnent les rôles du référent
/// (un club sans engagé), sinon « Club ».
String clubTitle(
  ClubInfo? club,
  CompetitionRoles? roles,
  int clubId,
  AppLocalizations l10n,
) {
  final label = club?.label.trim() ?? '';
  if (label.isNotEmpty) return label;
  final referee = roles?.refereeClubs.where((c) => c.id == clubId).firstOrNull;
  final refereeLabel = referee?.label.trim() ?? '';
  return refereeLabel.isNotEmpty ? refereeLabel : l10n.mySpaceClubFallback;
}

enum AthleteSpaceBody { loading, retry, notEntered, card }

typedef AthleteSpaceView = ({AthleteSpaceBody body, Participant? athlete});

/// Ce que montre l'espace athlète d'après les cartes du compte : la fiche de
/// son athlète, « Réessayer » si les rôles ou les participants n'ont pu être
/// lus (on ne sait pas s'il est engagé), sinon « pas engagé ».
AthleteSpaceView athleteSpaceView(SpacesView view) => switch (view) {
  SpacesLoading() => (body: AthleteSpaceBody.loading, athlete: null),
  SpacesFailed() => (body: AthleteSpaceBody.retry, athlete: null),
  SpacesNone() => (body: AthleteSpaceBody.notEntered, athlete: null),
  SpacesShown(:final cards) => switch (spaceAthlete(cards)) {
    final athlete? => (body: AthleteSpaceBody.card, athlete: athlete),
    null when cards.athleteUnknown => (
      body: AthleteSpaceBody.retry,
      athlete: null,
    ),
    null => (body: AthleteSpaceBody.notEntered, athlete: null),
  },
};

/// La prochaine course a sa recherche de série dans sa carte en grand : sa
/// tuile du planning n'en montre pas une seconde.
bool showsLaneFinder(AthleteRace race, AthleteRace? next) =>
    race.toRun && race.entry.entryId != next?.entry.entryId;

enum ClubBody { loading, failed, noAthlete, shown }

/// Un club déjà lu reste montré pendant une relecture ou après son échec.
ClubBody clubBody(ClubInfo? club, {required bool failed}) {
  if (club == null) return failed ? ClubBody.failed : ClubBody.loading;
  return club.athletes.isEmpty ? ClubBody.noAthlete : ClubBody.shown;
}

/// « – » tant que le planning se lit : « 0 » dirait qu'il n'y en a pas.
String forfeitsFigure(List<ClubRace>? forfeits) =>
    forfeits == null ? '–' : '${forfeits.length}';

/// « 100m Bouée tube · Dames · Série 3 » ; le nom du créneau quand la série
/// n'a pas d'épreuve.
String officialHeatTitle(HeatInItem at, AppLocalizations l10n) {
  final heat = at.heat;
  return [
    if (heat.raceName.isNotEmpty) heat.raceName else at.item.name,
    if (heat.gender case final gender?) genderLabel(gender, l10n),
    if (heat.name.isNotEmpty) heat.name,
  ].where((part) => part.isNotEmpty).join(' · ');
}

/// La saisie de la série, dans la branche de Mon espace : le retour y
/// ramène.
String officialEntryRoute(int competitionId, HeatInItem at) => Routes.itemEntry(
  Routes.mySpace,
  competitionId,
  at.item.id,
  heatId: at.heat.id,
);

/// « Saisir » de l'accès rapide : la série de la carte en direct, si le
/// compte peut saisir et qu'elle a une série FFSS ; nul sinon.
String? quickEntryRoute(
  QuickAccess? access,
  int competitionId, {
  required bool canEnter,
}) {
  if (access == null || !canEnter || !canEnterHeat(access.current.heat)) {
    return null;
  }
  return officialEntryRoute(competitionId, (
    item: access.item,
    heat: access.current.heat,
  ));
}

/// Les saisies du compte connecté sur la compétition, par état.
final class MyEntries {
  const MyEntries({
    required this.rejected,
    required this.pending,
    required this.sent,
  });

  final List<OutboxOperation> rejected;
  final List<OutboxOperation> pending;
  final List<OutboxOperation> sent;

  bool get isEmpty => rejected.isEmpty && pending.isEmpty && sent.isEmpty;

  /// L'ordre de la page : refusées d'abord (elles attendent un geste), puis
  /// en attente, puis envoyées.
  List<OutboxOperation> get ordered => [...rejected, ...pending, ...sent];
}

/// Celles d'un autre compte ne le regardent pas ; une envoyée ne reste que
/// [sentRetention] (la file ne les oublie qu'à sa relecture).
MyEntries myEntries(
  List<OutboxOperation> queue,
  String? account,
  int competitionId,
  DateTime now,
) {
  final mine = [
    if (account != null)
      for (final op in queue)
        if (op.competitionId == competitionId &&
            isSameAccount(op.account, account))
          op,
  ];
  return MyEntries(
    rejected: [
      for (final op in mine)
        if (op.state == OutboxState.rejected) op,
    ],
    pending: [
      for (final op in mine)
        if (op.state == OutboxState.pending) op,
    ],
    sent: [
      for (final op in mine)
        if (op.state == OutboxState.sent &&
            op.sentAt != null &&
            now.difference(op.sentAt!) < sentRetention)
          op,
    ],
  );
}

/// Les DQ et forfaits du compte encore en file : pas encore dans les
/// classements lus.
List<OutboxOperation> queuedDecisions(
  List<OutboxOperation> queue,
  String? account,
  int competitionId,
) => [
  if (account != null)
    for (final op in queue)
      if (op.state == OutboxState.pending &&
          op.competitionId == competitionId &&
          isSameAccount(op.account, account) &&
          (op.change.mark == ResultMark.disqualified ||
              op.change.mark == ResultMark.forfeit))
        op,
];

/// Ce que pose une saisie : ses chronos, sa DQ, son forfait.
String entryChangeLabel(ResultChange change, AppLocalizations l10n) {
  final chronos = change.chronos;
  return [
    if (chronos != null)
      switch ([
        for (final chrono in chronos)
          if (chrono != null && chrono > 0) hundredthsLabel(chrono),
      ]) {
        final times when times.isEmpty => l10n.entryNoChrono,
        final times => times.join(' · '),
      },
    switch (change.mark) {
      ResultMark.disqualified =>
        l10n.entryDisqualified(change.code?.trim() ?? '').trim(),
      ResultMark.forfeit => l10n.forfeit,
      ResultMark.ok => l10n.officialStatusCleared,
      null => '',
    },
  ].where((part) => part.isNotEmpty).join(' · ');
}

/// En attente, envoyée (et quand), ou refusée (et pourquoi).
String entryStateLabel(OutboxOperation op, AppLocalizations l10n) =>
    switch (op.state) {
      OutboxState.pending => l10n.entryPending,
      OutboxState.sent => l10n.officialSentAt(timeLabel(op.sentAt)),
      OutboxState.rejected => l10n.entryRejected(rejectionReason(op, l10n)),
    };

/// La série d'une saisie, pour la nommer et rouvrir sa saisie ; nulle si le
/// programme n'est pas lu ou ne la porte plus.
HeatInItem? entrySeries(Programme? programme, OutboxOperation op) =>
    programme == null
    ? null
    : findHeat(programme, (heat) => heat.seriesId == op.seriesId);

/// Une DQ ou un forfait en file : l'engagement s'il a été lu dans les
/// classements, sinon sa série.
String queuedDecisionTitle(
  OutboxOperation op,
  OfficialDecisions? decisions,
  Programme? programme,
  AppLocalizations l10n,
) {
  if (decisions?.entries[op.entryId] case final entry?) {
    return resultNames(entry.result, relay: entry.event.isRelay).title;
  }
  final at = entrySeries(programme, op);
  return at == null ? l10n.officialUnknownSeries : officialHeatTitle(at, l10n);
}

/// « 1'02"34 · En attente d'envoi ».
String myEntryLine(OutboxOperation op, AppLocalizations l10n) => [
  entryChangeLabel(op.change, l10n),
  entryStateLabel(op, l10n),
].where((part) => part.isNotEmpty).join(' · ');

/// « Suivante : Série 5 » ; son heure si la série n'a pas de nom.
String followingHeatLabel(Heat heat, AppLocalizations l10n) =>
    l10n.officialFollowing(
      heat.name.isEmpty ? timeLabel(heat.plannedStart) : heat.name,
    );

/// Ce qu'une page de Mon espace fait des résultats de sa compétition.
enum ResultsGate {
  /// La compétition se lit encore.
  waiting,

  /// Sans eau plate : « bientôt disponible », rien n'est lu.
  coastal,
  open,
}

/// Une compétition illisible ouvre les résultats : leurs lectures disent
/// leur propre échec, avec leur « Réessayer ».
ResultsGate resultsGate(AsyncValue<CompetitionSummary> competition) {
  final value = competition.value;
  if (value != null) {
    return isCoastalOnly(value) ? ResultsGate.coastal : ResultsGate.open;
  }
  return competition.hasError ? ResultsGate.open : ResultsGate.waiting;
}

/// « MAINTENANT » ou « À SUIVRE », comme la carte en direct.
String quickAccessKindLabel(QuickAccess access, AppLocalizations l10n) =>
    access.current.kind == NowRunningKind.now ? l10n.nowRunning : l10n.nextUp;

/// Le message de l'accès rapide à la place de la série : programme
/// illisible, ou plus rien à courir ; nul pendant la lecture ou avec une
/// série à montrer.
String? quickAccessNotice(
  AsyncValue<QuickAccess?> access,
  AppLocalizations l10n,
) {
  if (access.value != null) return null;
  if (access.hasError) return l10n.programmeLoadError;
  return access.isLoading ? null : l10n.officialNothingRunning;
}

/// Une DQ ou un forfait publié : le nom (le club pour un relais), puis le
/// reste et sa série.
({String title, String subtitle}) decisionNames(
  RankingRow row,
  CompetitionEvent event,
) {
  final names = resultNames(row.result, relay: event.isRelay);
  return (
    title: names.title,
    subtitle: [
      names.subtitle,
      row.series.heat.name,
    ].where((part) => part.isNotEmpty).join(' · '),
  );
}

/// Rien à montrer : ni DQ ni forfait publié, ni rien du compte en file.
bool decisionsEmpty(
  OfficialDecisions decisions,
  List<OutboxOperation> queued,
) => decisions.events.isEmpty && queued.isEmpty;
