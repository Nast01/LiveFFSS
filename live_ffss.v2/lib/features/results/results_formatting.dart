import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/domain/athlete_search.dart';
import 'package:live_ffss_v2/domain/event_ranking.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/gender.dart';
import 'package:live_ffss_v2/domain/manual_timing.dart';
import 'package:live_ffss_v2/domain/standings.dart';
import 'package:live_ffss_v2/features/home/competition_formatting.dart';
import 'package:live_ffss_v2/features/programme/programme_formatting.dart';
import 'package:live_ffss_v2/features/results/athlete_providers.dart';
import 'package:live_ffss_v2/features/results/results_providers.dart';

/// Une entrée de la liste déroulante des épreuves : une discipline et un
/// genre ; ses [events] sont ses catégories, choisies en puces.
typedef EventGroup = ({
  int disciplineId,
  String disciplineName,
  Gender gender,
  List<CompetitionEvent> events,
});

/// FFSS publie une épreuve par catégorie : on les regroupe par discipline et
/// genre, dans l'ordre de la première de chaque groupe ([eventsProvider] les
/// sert dans l'ordre du programme).
List<EventGroup> eventGroups(List<CompetitionEvent> events) {
  final groups = <(int, Gender), List<CompetitionEvent>>{};
  for (final event in events) {
    groups.putIfAbsent((event.disciplineId, event.gender), () => []).add(event);
  }
  return [
    for (final MapEntry(key: (disciplineId, gender), value: members)
        in groups.entries)
      (
        disciplineId: disciplineId,
        disciplineName: members.first.disciplineName,
        gender: gender,
        events: members,
      ),
  ];
}

EventGroup? groupOfEvent(List<EventGroup> groups, int? eventId) {
  if (eventId == null) return null;
  for (final group in groups) {
    if (group.events.any((e) => e.id == eventId)) return group;
  }
  return null;
}

/// Passer d'une discipline à l'autre garde la catégorie suivie quand la
/// nouvelle l'a : on suit souvent sa catégorie d'une épreuve à l'autre.
CompetitionEvent eventInGroup(EventGroup group, String? categoryName) =>
    group.events.where((e) => e.categoryName == categoryName).firstOrNull ??
    group.events.first;

/// « 200m Obstacles · Dames ».
String eventGroupLabel(EventGroup group, AppLocalizations l10n) => [
  if (group.disciplineName.isNotEmpty) group.disciplineName,
  genderLabel(group.gender, l10n),
].join(' · ');

/// « CLASSEMENT PROVISOIRE · CADET », « CLASSEMENT · CADET ».
String rankingHeader(EventRanking ranking, AppLocalizations l10n) => [
  ranking.provisional
      ? l10n.resultsRankingProvisional
      : l10n.resultsRankingFinal,
  if (ranking.event.categoryName.isNotEmpty)
    ranking.event.categoryName.toUpperCase(),
].join(' · ');

/// « 3/5 séries » : séries terminées sur séries rattachées.
String seriesProgressLabel(int finished, int total, AppLocalizations l10n) =>
    l10n.resultsSeriesProgress(finished, total);

/// Une série publiée avant d'être courue porte ses engagés sans résultat : ils
/// ne sont pas encore au classement.
List<RankingRow> shownRows(EventRanking ranking) => [
  for (final row in ranking.rows)
    if (hasRun(row.result)) row,
];

String rankLabel(int? rank) => rank == null ? '' : '$rank';

typedef ResultLabel = ({String text, bool anomaly});

/// Le temps, ou ce qui en tient lieu (`DQ 12`, `F`, `FF`, `HT`) ; [anomaly] :
/// à montrer en rouge, comme les statuts des places du programme. Codes de
/// V3 (`ResultPublisher`) : DQ = statut 1 et son code en complément, forfait
/// = statut 2, `FF` et `HT` en complément.
ResultLabel resultLabel(EventResult result) {
  final time = result.time;
  final complement = result.complement;
  if (result.status == 1) {
    // Le site met « DQ » en complément d'une DQ publiée sans code.
    final code = complement == 'DQ' ? '' : complement;
    return (text: code.isEmpty ? 'DQ' : 'DQ $code', anomaly: true);
  }
  if (complement == 'HT') return (text: 'HT', anomaly: true);
  if (complement == 'FF') {
    // Forfait pour la finale : classé en série à son temps.
    return time == null
        ? (text: 'FF', anomaly: true)
        : (text: '${hundredthsLabel(time)} FF', anomaly: false);
  }
  if (result.status == 2) return (text: 'F', anomaly: true);
  // Le complément d'un statut 0 peut être un code de DQ annulée, que le site
  // n'efface pas : il n'est pas montré.
  if (result.status == 0 && time != null) {
    return (text: hundredthsLabel(time), anomaly: false);
  }
  return (text: '–', anomaly: false);
}

String? qualificationBadge(Qualification qualification) =>
    switch (qualification) {
      Qualification.finalA => 'FA',
      Qualification.finalB => 'FB',
      Qualification.none => null,
    };

/// Un relais s'annonce sous le nom de son club, ses relayeurs dessous, comme
/// dans les séries du programme.
({String title, String subtitle}) resultNames(
  EventResult result, {
  required bool relay,
}) {
  final names = [for (final a in result.athletes) a.name].join(', ');
  return relay
      ? (title: result.club, subtitle: names)
      : (title: names, subtitle: result.club);
}

/// « Provisoire · 12 / 40 séries terminées · calculé à 14:05 » : calculés par
/// l'app, les classements ne sont jamais officiels.
String standingsFooter(Standings standings, AppLocalizations l10n) =>
    l10n.standingsFooter(
      standings.finishedSeries,
      standings.totalSeries,
      timeLabel(standings.computedAt),
    );

/// Nul quand toutes les épreuves ont été lues.
String? standingsIncompleteLabel(Standings standings, AppLocalizations l10n) =>
    standings.failedEvents == 0
    ? null
    : l10n.standingsIncomplete(standings.failedEvents);

/// Rien pour le premier, ni pour un ex æquo : son rang le dit déjà.
String gapLabel(int? gap, AppLocalizations l10n) =>
    gap == null || gap == 0 ? '' : l10n.standingsGap(gap);

({List<ClubStanding> podium, List<ClubStanding> rest}) splitPodium(
  List<ClubStanding> clubs,
) => (podium: clubs.take(3).toList(), rest: clubs.skip(3).toList());

List<Gender> licenseeGenders(List<LicenseeStanding> licensees) =>
    {for (final l in licensees) l.gender}.toList();

List<String> licenseeCategories(
  List<LicenseeStanding> licensees,
  Gender gender,
) => {
  for (final l in licensees)
    if (l.gender == gender) l.categoryName,
}.toList();

List<LicenseeStanding> licenseesOf(
  List<LicenseeStanding> licensees,
  Gender gender,
  String category,
) => [
  for (final l in licensees)
    if (l.gender == gender && l.categoryName == category) l,
];

/// Le choix gardé s'il est encore proposé, sinon le premier : après une
/// relecture, une puce choisie peut avoir disparu.
T? chosenOrFirst<T>(List<T> options, T? chosen) =>
    chosen != null && options.contains(chosen) ? chosen : options.firstOrNull;

/// Une requête trop courte ne trouve rien (`searchParticipants`) : la page
/// demande alors d'en taper plus plutôt que de dire « aucun athlète ».
bool queryTooShort(String query) => query.trim().length < minSearchLength;

String participantName(Participant participant) => [
  participant.firstName,
  participant.lastName,
].where((part) => part.isNotEmpty).join(' ');

String participantInitials(Participant participant) => [
  participant.firstName,
  participant.lastName,
].where((part) => part.isNotEmpty).map((part) => part[0]).join().toUpperCase();

/// « Biarritz · Cadet, Open » : le site ne publie pas de dossard.
String participantSubtitle(Participant participant) {
  final categories = {
    for (final entry in participant.entries)
      if (entry.categoryName.isNotEmpty) entry.categoryName,
  };
  return [
    if (participant.club.isNotEmpty) participant.club,
    if (categories.isNotEmpty) categories.join(', '),
  ].join(' · ');
}

/// « 200m Obstacles · Dames · Cadet ».
String athleteRaceTitle(CompetitionEvent event, AppLocalizations l10n) => [
  if (event.disciplineName.isNotEmpty) event.disciplineName,
  genderLabel(event.gender, l10n),
  if (event.categoryName.isNotEmpty) event.categoryName,
].join(' · ');

/// L'heure de départ réelle d'une course courue, sinon l'heure prévue.
String athleteRaceTime(AthleteRace race) =>
    timeLabel(race.row == null ? race.plannedStart : race.series?.series.start);

/// « Série 4 · 2e de la série · 5e de l'épreuve (provisoire) » ; rien pour une
/// course à courir, dont la série se cherche (« Trouver sa série »).
String athleteRaceDetail(AthleteRace race, AppLocalizations l10n) {
  final row = race.row;
  final series = race.series;
  if (row == null || series == null) return '';
  final place = race.heatPlace;
  final rank = row.rank;
  String rankText(int n) =>
      ordinal(n, l10n.localeName, feminine: race.event.gender == Gender.female);
  return [
    if (series.heat.name.isNotEmpty) series.heat.name,
    if (place != null) l10n.athleteHeatPlace(rankText(place)),
    if (rank != null)
      series.provisional
          ? l10n.athleteEventRankProvisional(rankText(rank))
          : l10n.athleteEventRank(rankText(rank)),
  ].join(' · ');
}

/// « 1er » (« 1re » au féminin), « 2e » ; « 1st », « 2nd », « 3rd »,
/// « 11th »–« 13th », « 21st ». Une règle par langue : un message ICU ne
/// sait pas dire 21st sans lister chaque nombre.
String ordinal(int n, String localeName, {bool feminine = false}) {
  if (localeName.startsWith('en')) {
    final suffix = n % 100 >= 11 && n % 100 <= 13
        ? 'th'
        : switch (n % 10) {
            1 => 'st',
            2 => 'nd',
            3 => 'rd',
            _ => 'th',
          };
    return '$n$suffix';
  }
  if (n == 1) return feminine ? '1re' : '1er';
  return '${n}e';
}

({List<AthleteRace> run, List<AthleteRace> toRun}) splitRaces(
  List<AthleteRace> races,
) => (
  run: [
    for (final race in races)
      if (!race.toRun) race,
  ],
  toRun: [
    for (final race in races)
      if (race.toRun) race,
  ],
);

/// « Club A · 2 courses ».
String licenseeSubtitle(LicenseeStanding licensee, AppLocalizations l10n) => [
  if (licensee.club.isNotEmpty) licensee.club,
  l10n.standingsRaces(licensee.races),
].join(' · ');

/// Ce qu'ouvre le toucher d'une ligne de classement.
sealed class RowOpening {
  const RowOpening();
}

final class OpenNothing extends RowOpening {
  const OpenNothing();
}

final class OpenAthlete extends RowOpening {
  const OpenAthlete(this.athleteId);

  final int athleteId;
}

/// Un relais : on choisit lequel des relayeurs ouvrir.
final class PickAthlete extends RowOpening {
  const PickAthlete(this.athletes);

  final List<ResultAthlete> athletes;
}

RowOpening rowOpening(EventResult result) => switch (result.athletes) {
  [] => const OpenNothing(),
  [final athlete] => OpenAthlete(athlete.id),
  final athletes => PickAthlete(athletes),
};

Participant? participantById(List<Participant>? participants, int id) =>
    participants?.where((p) => p.id == id).firstOrNull;

/// « Série 3 · ligne 5 » ; une course sans numéro garde son nom.
String laneFoundLabel(LaneFound found, AppLocalizations l10n) => [
  found.heat.number > 0
      ? l10n.athleteSeries(found.heat.number)
      : found.heat.name,
  l10n.athleteLane(found.lane),
].join(' · ');
