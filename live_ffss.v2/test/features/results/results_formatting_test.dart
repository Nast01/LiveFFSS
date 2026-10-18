import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/domain/discipline.dart';
import 'package:live_ffss_v2/domain/event_ranking.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/gender.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/run_status.dart';
import 'package:live_ffss_v2/domain/series_link.dart';
import 'package:live_ffss_v2/domain/standings.dart';
import 'package:live_ffss_v2/features/results/athlete_providers.dart';
import 'package:live_ffss_v2/features/results/results_formatting.dart';
import 'package:live_ffss_v2/features/results/results_providers.dart';

CompetitionEvent event(
  int id, {
  int disciplineId = 24,
  String disciplineName = '200m Obstacles',
  Gender gender = Gender.female,
  String category = 'Cadet',
  int teamSize = 1,
}) => CompetitionEvent(
  id: id,
  disciplineId: disciplineId,
  disciplineName: disciplineName,
  gender: gender,
  categoryId: id,
  categoryName: category,
  teamSize: teamSize,
  discipline: Discipline.flatWater,
);

EventResult result({
  int id = 1,
  int status = 0,
  int? time,
  String complement = '',
  String club = 'Club A',
  List<String> athletes = const ['ATHLETE Un'],
}) => EventResult(
  id: id,
  entryId: id,
  eventId: 1,
  categoryName: 'Cadet',
  status: status,
  time: time,
  complement: complement,
  club: club,
  athletes: [
    for (final (i, name) in athletes.indexed)
      ResultAthlete(id: 100 + i, name: name),
  ],
);

Heat heat({
  int number = 4,
  String name = 'Série 4',
  RunStatus status = RunStatus.finished,
  bool provisional = true,
}) => Heat(
  id: number,
  name: name,
  number: number,
  status: status,
  resultsProvisional: provisional,
);

LinkedSeries linked({Heat? course, List<EventResult> results = const []}) =>
    LinkedSeries(
      series: EventSeries(
        id: 1,
        eventId: 1,
        number: 4,
        name: 'Série 4',
        start: DateTime(2026, 3, 28, 9, 12),
        results: results,
      ),
      heat: course ?? heat(),
      round: EventRound.heats,
    );

RankingRow row(EventResult r, {int? rank, Heat? course}) => RankingRow(
  result: r,
  rank: rank,
  points: 0,
  qualification: Qualification.none,
  series: linked(course: course, results: [r]),
);

EventRanking ranking({
  bool provisional = true,
  String category = 'Cadet',
  List<RankingRow> rows = const [],
}) => EventRanking(
  event: event(1, category: category),
  rows: rows,
  finishedSeries: 3,
  totalSeries: 5,
  provisional: provisional,
);

ClubStanding club(int rank, String name, int points, [int? gap]) =>
    ClubStanding(rank: rank, club: name, points: points, gapToPrevious: gap);

LicenseeStanding licensee(
  int id, {
  Gender gender = Gender.female,
  String category = 'Cadet',
}) => LicenseeStanding(
  rank: 1,
  athleteId: id,
  name: 'ATHLETE $id',
  club: 'Club A',
  gender: gender,
  categoryName: category,
  points: 10,
  races: 2,
);

Participant participant({
  String first = 'N081',
  String last = 'ATHLETE',
  String club = 'Biarritz',
  List<String> categories = const ['Cadet'],
}) => Participant(
  id: 1,
  firstName: first,
  lastName: last,
  club: club,
  entries: [
    for (final (i, category) in categories.indexed)
      ParticipantEntry(entryId: i, eventId: i, categoryName: category),
  ],
);

void main() {
  final l10n = lookupAppLocalizations(const Locale('fr'));

  group('eventGroups', () {
    final events = [
      event(1),
      event(2, category: 'Junior'),
      event(3, disciplineId: 46, disciplineName: '4 X 50m Sauvetage'),
      event(4, gender: Gender.male),
      event(5, category: 'Senior'),
    ];

    test('une entrée par discipline · genre, dans l\'ordre des épreuves', () {
      final groups = eventGroups(events);
      expect(
        [for (final g in groups) eventGroupLabel(g, l10n)],
        [
          '200m Obstacles · Dames',
          '4 X 50m Sauvetage · Dames',
          '200m Obstacles · Messieurs',
        ],
      );
      expect(
        [for (final e in groups.first.events) e.categoryName],
        ['Cadet', 'Junior', 'Senior'],
      );
    });

    test('groupOfEvent retrouve le groupe de l\'épreuve choisie', () {
      final groups = eventGroups(events);
      expect(groupOfEvent(groups, 4), same(groups[2]));
      expect(groupOfEvent(groups, 99), isNull);
      expect(groupOfEvent(groups, null), isNull);
    });

    test('changer de discipline garde la catégorie si elle y est', () {
      final groups = eventGroups(events);
      expect(eventInGroup(groups.first, 'Junior').id, 2);
      expect(eventInGroup(groups[1], 'Junior').id, 3);
      expect(eventInGroup(groups[1], null).id, 3);
    });
  });

  group('rankingHeader', () {
    test('provisoire ou définitif, avec la catégorie en capitales', () {
      expect(rankingHeader(ranking(), l10n), 'CLASSEMENT PROVISOIRE · CADET');
      expect(
        rankingHeader(ranking(provisional: false), l10n),
        'CLASSEMENT · CADET',
      );
    });

    test('sans catégorie, pas de point', () {
      expect(
        rankingHeader(ranking(category: ''), l10n),
        'CLASSEMENT PROVISOIRE',
      );
    });
  });

  test('seriesProgressLabel', () {
    expect(seriesProgressLabel(3, 5, l10n), '3/5 séries');
  });

  test('shownRows écarte les engagés qui n\'ont pas encore couru', () {
    final ran = row(result(id: 1, time: 6234), rank: 1);
    final dq = row(result(id: 2, status: 1, complement: '12'));
    final waiting = row(result(id: 3));
    expect(shownRows(ranking(rows: [ran, waiting, dq])), [ran, dq]);
  });

  test('rankLabel', () {
    expect(rankLabel(3), '3');
    expect(rankLabel(null), '');
  });

  group('resultLabel', () {
    test('un temps', () {
      expect(resultLabel(result(time: 6234)), (
        text: '1\'02"34',
        anomaly: false,
      ));
    });

    test('une DQ porte son code, en anomalie', () {
      expect(resultLabel(result(status: 1, complement: '12')), (
        text: 'DQ 12',
        anomaly: true,
      ));
      expect(resultLabel(result(status: 1)), (text: 'DQ', anomaly: true));
      expect(resultLabel(result(status: 1, complement: 'DQ')), (
        text: 'DQ',
        anomaly: true,
      ));
    });

    test('forfait, forfait pour la finale, hors temps', () {
      expect(resultLabel(result(status: 2, complement: 'F')), (
        text: 'F',
        anomaly: true,
      ));
      expect(resultLabel(result(status: 2)), (text: 'F', anomaly: true));
      expect(resultLabel(result(status: 2, complement: 'FF')), (
        text: 'FF',
        anomaly: true,
      ));
      expect(resultLabel(result(complement: 'HT')), (
        text: 'HT',
        anomaly: true,
      ));
    });

    test('un forfait pour la finale garde son temps de série', () {
      expect(resultLabel(result(time: 6234, complement: 'FF')), (
        text: '1\'02"34 FF',
        anomaly: false,
      ));
    });

    test('un code de DQ resté après annulation n\'est pas montré', () {
      expect(resultLabel(result(time: 6234, complement: '12')), (
        text: '1\'02"34',
        anomaly: false,
      ));
    });

    test('rien de connu : un tiret', () {
      expect(resultLabel(result(status: 3)), (text: '–', anomaly: false));
    });
  });

  test('qualificationBadge', () {
    expect(qualificationBadge(Qualification.finalA), 'FA');
    expect(qualificationBadge(Qualification.finalB), 'FB');
    expect(qualificationBadge(Qualification.none), isNull);
  });

  group('resultNames', () {
    test('individuel : l\'athlète, puis son club', () {
      expect(resultNames(result(), relay: false), (
        title: 'ATHLETE Un',
        subtitle: 'Club A',
      ));
    });

    test('relais : le club, puis ses relayeurs', () {
      expect(
        resultNames(
          result(athletes: ['ATHLETE Un', 'ATHLETE Deux']),
          relay: true,
        ),
        (title: 'Club A', subtitle: 'ATHLETE Un, ATHLETE Deux'),
      );
    });
  });

  group('classements', () {
    final standings = Standings(
      clubs: [club(1, 'A', 50), club(2, 'B', 40, 10)],
      licensees: const [],
      finishedSeries: 12,
      totalSeries: 40,
      failedEvents: 0,
      computedAt: DateTime(2026, 3, 28, 14, 5),
    );

    test('standingsFooter', () {
      expect(
        standingsFooter(standings, l10n),
        'Provisoire · 12 / 40 séries terminées · calculé à 14:05',
      );
    });

    test('standingsIncompleteLabel : seulement si des épreuves manquent', () {
      expect(standingsIncompleteLabel(standings, l10n), isNull);
      expect(
        standingsIncompleteLabel(standings.copyWith(failedEvents: 1), l10n),
        '1 épreuve n\'a pu être lue : classement incomplet',
      );
      expect(
        standingsIncompleteLabel(standings.copyWith(failedEvents: 3), l10n),
        '3 épreuves n\'ont pu être lues : classement incomplet',
      );
    });

    test('gapLabel', () {
      expect(gapLabel(5, l10n), 'Écart au précédent −5');
      expect(gapLabel(null, l10n), '');
      expect(gapLabel(0, l10n), '');
    });

    test('splitPodium : trois premiers, puis les autres', () {
      final clubs = [for (var i = 1; i <= 5; i++) club(i, 'C$i', 60 - i)];
      final split = splitPodium(clubs);
      expect([for (final c in split.podium) c.club], ['C1', 'C2', 'C3']);
      expect([for (final c in split.rest) c.club], ['C4', 'C5']);
      expect(splitPodium([clubs.first]).rest, isEmpty);
    });
  });

  group('licenciés', () {
    final all = [
      licensee(1),
      licensee(2, category: 'Junior'),
      licensee(3, gender: Gender.male, category: 'Senior'),
      licensee(4, category: 'Cadet'),
    ];

    test('les sexes et catégories présents, dans l\'ordre', () {
      expect(licenseeGenders(all), [Gender.female, Gender.male]);
      expect(licenseeCategories(all, Gender.female), ['Cadet', 'Junior']);
      expect(licenseeCategories(all, Gender.male), ['Senior']);
    });

    test('licenseesOf filtre par sexe et catégorie', () {
      expect(
        [for (final l in licenseesOf(all, Gender.female, 'Cadet')) l.athleteId],
        [1, 4],
      );
    });

    test('chosenOrFirst', () {
      expect(chosenOrFirst(['a', 'b'], 'b'), 'b');
      expect(chosenOrFirst(['a', 'b'], 'c'), 'a');
      expect(chosenOrFirst(['a', 'b'], null), 'a');
      expect(chosenOrFirst(<String>[], 'a'), isNull);
    });
  });

  group('recherche', () {
    test('nom, initiales, club · catégories', () {
      final p = participant(categories: ['Cadet', 'Open', 'Cadet']);
      expect(participantName(p), 'N081 ATHLETE');
      expect(participantInitials(p), 'NA');
      expect(participantSubtitle(p), 'Biarritz · Cadet, Open');
    });

    test('queryTooShort : moins de deux lettres, espaces exclus', () {
      expect(queryTooShort(''), isTrue);
      expect(queryTooShort(' a '), isTrue);
      expect(queryTooShort('ab'), isFalse);
    });

    test('sans club ni prénom', () {
      final p = participant(first: '', club: '', categories: []);
      expect(participantName(p), 'ATHLETE');
      expect(participantInitials(p), 'A');
      expect(participantSubtitle(p), '');
    });
  });

  group('fiche d\'un athlète', () {
    final e = event(1);
    const entry = ParticipantEntry(
      entryId: 1,
      eventId: 1,
      categoryName: 'Cadet',
    );

    test('athleteRaceTitle', () {
      expect(athleteRaceTitle(e, l10n), '200m Obstacles · Dames · Cadet');
    });

    test('courue : série, place dans la série, rang dans l\'épreuve', () {
      final r = row(result(time: 6234), rank: 5);
      final race = AthleteRace(
        event: e,
        entry: entry,
        series: r.series,
        row: r,
        heatPlace: 2,
      );
      expect(
        athleteRaceDetail(race, l10n),
        'Série 4 · 2e de la série · 5e de l\'épreuve (provisoire)',
      );
      expect(athleteRaceTime(race), '09:12');
    });

    test('courue, série validée : rang sans réserve', () {
      final r = row(
        result(time: 6234),
        rank: 1,
        course: heat(provisional: false),
      );
      final race = AthleteRace(
        event: e,
        entry: entry,
        series: r.series,
        row: r,
        heatPlace: 1,
      );
      expect(
        athleteRaceDetail(race, l10n),
        'Série 4 · 1er de la série · 1er de l\'épreuve',
      );
    });

    test('DQ : ni place ni rang', () {
      final r = row(result(status: 1, complement: '12'));
      final race = AthleteRace(
        event: e,
        entry: entry,
        series: r.series,
        row: r,
      );
      expect(athleteRaceDetail(race, l10n), 'Série 4');
    });

    test('à courir : l\'heure prévue', () {
      final race = AthleteRace(
        event: e,
        entry: entry,
        plannedStart: DateTime(2026, 3, 28, 15, 30),
      );
      expect(athleteRaceTime(race), '15:30');
      expect(athleteRaceDetail(race, l10n), '');
    });

    test('laneFoundLabel', () {
      expect(
        laneFoundLabel(LaneFound(heat: heat(number: 3), lane: 5), l10n),
        'Série 3 · ligne 5',
      );
      expect(
        laneFoundLabel(
          LaneFound(heat: heat(number: 0, name: 'Finale A'), lane: 2),
          l10n,
        ),
        'Finale A · ligne 2',
      );
    });
  });
}
