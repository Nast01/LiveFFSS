import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/router/app_router.dart';
import 'package:live_ffss_v2/domain/competition_roles.dart';
import 'package:live_ffss_v2/domain/event_ranking.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/follows.dart';
import 'package:live_ffss_v2/domain/gender.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/officials.dart';
import 'package:live_ffss_v2/domain/outbox.dart';
import 'package:live_ffss_v2/domain/race_result.dart';
import 'package:live_ffss_v2/domain/run_status.dart';
import 'package:live_ffss_v2/domain/series_link.dart';
import 'package:live_ffss_v2/features/my_space/my_space_formatting.dart';
import 'package:live_ffss_v2/features/my_space/my_space_providers.dart';
import 'package:live_ffss_v2/features/results/athlete_providers.dart';

import '../../support/competitions.dart';

const _participant = Participant(id: 7, firstName: 'Un', lastName: 'ATHLETE');

CompetitionEvent _event(int id, String name) => CompetitionEvent(
  id: id,
  disciplineId: id,
  disciplineName: name,
  gender: Gender.female,
  categoryId: 1,
  categoryName: 'Cadet',
  teamSize: 1,
);

AthleteRace _toRun(int id, String name, DateTime? start) => AthleteRace(
  event: _event(id, name),
  entry: ParticipantEntry(entryId: id, eventId: id, categoryName: 'Cadet'),
  plannedStart: start,
);

OutboxOperation _op(
  String id, {
  String account = 'DUPONT Jean',
  int competitionId = 1416,
  OutboxState state = OutboxState.rejected,
}) => OutboxOperation(
  id: id,
  account: account,
  competitionId: competitionId,
  placeId: 1,
  seriesId: 5,
  entryId: 3,
  change: const ResultChange(),
  state: state,
);

void main() {
  final fr = lookupAppLocalizations(const Locale('fr'));
  final en = lookupAppLocalizations(const Locale('en'));
  final now = DateTime(2026, 3, 27, 7);

  setUpAll(initializeDateFormatting);

  group('cartes', () {
    const club = MySpaceCard.club(ClubRef(id: 15, label: 'Les Dauphins'));
    const official = MySpaceCard.official(
      OfficialRole(
        level: 'B',
        levelLabel: 'B - Juge de virage/obstacles',
        principal: false,
      ),
    );

    test('titres', () {
      expect(
        mySpaceCardTitle(const MySpaceCard.athlete(_participant), fr),
        'Athlète',
      );
      expect(mySpaceCardTitle(club, fr), 'Club · Les Dauphins');
      expect(mySpaceCardTitle(official, fr), 'Officiel');
      expect(mySpaceCardTitle(const MySpaceCard.admin(), fr), 'Admin');
      expect(mySpaceCardTitle(club, en), 'Club · Les Dauphins');
    });

    test("sous-titres : le niveau de l'officiel, juge principal en tête", () {
      expect(
        mySpaceCardSubtitle(const MySpaceCard.athlete(_participant), fr),
        'Planning, résultats',
      );
      expect(mySpaceCardSubtitle(club, fr), 'Athlètes, planning, résultats');
      expect(mySpaceCardSubtitle(official, fr), 'B - Juge de virage/obstacles');
      expect(
        mySpaceCardSubtitle(
          const MySpaceCard.official(
            OfficialRole(level: 'A', levelLabel: 'A - x', principal: true),
          ),
          fr,
        ),
        'Juge principal',
      );
      expect(
        mySpaceCardSubtitle(const MySpaceCard.official(null), fr),
        'Saisies, séries à saisir',
      );
      expect(
        mySpaceCardSubtitle(const MySpaceCard.admin(), fr),
        "L'espace de n'importe quel club",
      );
    });

    test('chaque carte ouvre son espace, dans la branche Mon espace', () {
      expect(
        mySpaceCardRoute(const MySpaceCard.athlete(_participant), 1416),
        Routes.mySpaceAthlete(1416),
      );
      expect(mySpaceCardRoute(club, 1416), Routes.mySpaceClub(1416, 15));
      expect(mySpaceCardRoute(official, 1416), Routes.mySpaceOfficial(1416));
      // L'admin choisit son club dans la liste des clubs des infos.
      expect(
        mySpaceCardRoute(const MySpaceCard.admin(), 1416),
        Routes.mySpaceInfos(1416),
      );
    });
  });

  group('prochaine course', () {
    test('la plus tôt des courses à courir, celles sans heure en dernier', () {
      final later = _toRun(1, '200m Obstacles', DateTime(2026, 3, 27, 14));
      final sooner = _toRun(2, '100m Bouée tube', DateTime(2026, 3, 27, 9));
      final unknown = _toRun(3, '50m Mannequin', null);

      expect(nextRace([unknown, later, sooner]), sooner);
      expect(nextRace([unknown]), unknown);
      expect(nextRace(const []), isNull);
    });

    test('une course courue ne compte pas', () {
      const result = EventResult(
        id: 1,
        entryId: 1,
        eventId: 1,
        categoryName: 'Cadet',
        status: 0,
        time: 6234,
      );
      final run = _toRun(1, '200m Obstacles', DateTime(2026, 3, 27, 8))
          .copyWith(
            row: const RankingRow(
              result: result,
              points: 0,
              qualification: Qualification.none,
              series: LinkedSeries(
                series: EventSeries(
                  id: 1,
                  eventId: 1,
                  number: 4,
                  name: 'Série 4',
                  results: [result],
                ),
                heat: Heat(
                  id: 4,
                  name: 'Série 4',
                  number: 4,
                  status: RunStatus.finished,
                ),
                round: EventRound.heats,
              ),
            ),
          );
      final later = _toRun(2, '100m Bouée tube', DateTime(2026, 3, 27, 9));

      expect(nextRace([run, later]), later);
      expect(nextRace([run]), isNull);
    });

    test('« dans 2 h », « dans 25 min », « maintenant »', () {
      expect(startsInLabel(DateTime(2026, 3, 27, 9, 4), now, fr), 'dans 2 h');
      expect(
        startsInLabel(DateTime(2026, 3, 27, 7, 25), now, fr),
        'dans 25 min',
      );
      expect(
        startsInLabel(DateTime(2026, 3, 27, 7, 0, 30), now, fr),
        'dans 1 min',
      );
      expect(startsInLabel(now, now, fr), 'maintenant');
      // Une course en retard sur son heure prévue reste imminente.
      expect(startsInLabel(DateTime(2026, 3, 27, 6), now, fr), 'maintenant');
      expect(startsInLabel(DateTime(2026, 3, 27, 9), now, en), 'in 2 h');
      expect(startsInLabel(null, now, fr), isNull);
    });

    test('au-delà de 24 h : le jour et l\'heure', () {
      expect(
        startsInLabel(DateTime(2026, 3, 28, 8, 58), now, fr),
        'sam. 08:58',
      );
    });

    test('badge de la carte Athlète', () {
      expect(athleteBadge(null, now, fr), isNull);
      expect(athleteBadge(const [], now, fr), isNull);
      expect(
        athleteBadge([_toRun(1, 'x', DateTime(2026, 3, 27, 9))], now, fr),
        'dans 2 h',
      );
    });

    test("ligne d'un athlète suivi", () {
      const athlete = FollowedAthlete(
        participantId: 7,
        name: 'Un ATHLETE',
        club: 'Club A',
      );
      final event = _event(1, '100m Bouée tube');
      expect(
        followedAthleteLine(athlete, {
          7: (event: event, start: DateTime(2026, 3, 27, 8, 58)),
        }, fr),
        'Prochaine : 08:58 · 100m Bouée tube',
      );
      expect(
        followedAthleteLine(athlete, {7: (event: event, start: null)}, fr),
        'Prochaine : 100m Bouée tube',
      );
      expect(
        followedAthleteLine(athlete, const {7: null}, fr),
        'Aucune course à venir',
      );
      // Programme en lecture ou illisible : son club.
      expect(followedAthleteLine(athlete, null, fr), 'Club A');
      // Suivi enregistré sans ses épreuves : son club aussi.
      expect(followedAthleteLine(athlete, const {}, fr), 'Club A');
    });
  });

  group('saisies refusées', () {
    test('celles du compte connecté, sur la compétition', () {
      final queue = [
        _op('a'),
        _op('b', account: ' dupont jean '),
        _op('c', state: OutboxState.pending),
        _op('d', account: 'MARTIN Paul'),
        _op('e', competitionId: 1453),
      ];

      expect(rejectedEntries(queue, 'DUPONT Jean', 1416), 2);
      expect(rejectedEntries(queue, null, 1416), 0);
      expect(officialBadge(queue, 'DUPONT Jean', 1416, fr), '2 refusées');
      expect(officialBadge([_op('a')], 'DUPONT Jean', 1416, fr), '1 refusée');
      expect(officialBadge(queue, 'DUPONT Jean', 1416, en), '2 rejected');
      expect(officialBadge(const [], 'DUPONT Jean', 1416, fr), isNull);
    });
  });

  group('suivis', () {
    test('« 3 athlètes · 1 club », sans le morceau vide', () {
      FollowedAthlete athlete(int id) =>
          FollowedAthlete(participantId: id, name: 'A $id');
      const club = FollowedClub(id: 15, label: 'Club');

      expect(
        followsSummary(
          Follows(
            athletes: [athlete(1), athlete(2), athlete(3)],
            clubs: [club],
          ),
          fr,
        ),
        '3 athlètes · 1 club',
      );
      expect(followsSummary(Follows(athletes: [athlete(1)]), fr), '1 athlète');
      expect(followsSummary(const Follows(clubs: [club]), en), '1 club');
      expect(followsSummary(const Follows(), fr), 'Aucun suivi');
    });
  });

  group('officiels', () {
    test('libellé des groupes', () {
      expect(officialGroupLabel(null, fr), 'Juge principal');
      expect(officialGroupLabel('B', fr), 'Niveau B');
      expect(officialGroupLabel('', fr), 'Niveau non renseigné');
      expect(officialGroupLabel('', en), 'Level not given');
    });

    test('jours et club', () {
      const official = CompetitionOfficial(
        id: 1,
        name: 'OFFICIEL O001',
        level: 'C',
        principal: false,
        days: [3],
        daysLabel: 'Jour 3',
        club: 'TOULON',
      );
      expect(officialDetail(official), 'Jour 3 · TOULON');
      expect(
        officialDetail(official.copyWith(daysLabel: '', club: 'TOULON')),
        'TOULON',
      );
    });
  });

  group('infos de la compétition', () {
    final summary = competition(
      1416,
      start: DateTime(2026, 3, 27),
      end: DateTime(2026, 3, 29),
    );

    test('le lieu, sinon le nom', () {
      expect(
        competitionPlace(summary.copyWith(location: 'Dunkerque')),
        'Dunkerque',
      );
      expect(competitionPlace(summary.copyWith(location: ' ')), summary.name);
      expect(competitionPlace(summary), summary.name);
    });

    test('dates et spécialité', () {
      expect(
        competitionDatesLine(summary, fr),
        '27 – 29 mars 2026 · Eau plate',
      );
    });

    test('nombres d\'athlètes, de clubs, d\'épreuves', () {
      final info = CompetitionInfo(
        competition: summary,
        athletes: 346,
        clubs: [(id: 15, label: 'Club', athletes: 12)],
        events: 60,
      );
      expect(
        competitionCountsLine(info, fr),
        '346 athlètes · 1 club · 60 épreuves',
      );
      expect(
        competitionCountsLine(info, en),
        '346 athletes · 1 club · 60 events',
      );
      expect(clubAthletesLabel(12, fr), '12 athlètes');
    });
  });

  group('section des espaces', () {
    const club = MySpaceCard.club(ClubRef(id: 15, label: 'Les Dauphins'));
    const cards = MySpaceCards(cards: [club]);

    test('les cartes lues', () {
      expect(
        spacesView(loading: false, failed: false, cards: cards),
        const SpacesShown(cards),
      );
    });

    test('aucun espace', () {
      expect(
        spacesView(
          loading: false,
          failed: false,
          cards: const MySpaceCards(cards: []),
        ),
        const SpacesNone(),
      );
    });

    test('un premier chargement', () {
      expect(
        spacesView(loading: true, failed: false, cards: null),
        const SpacesLoading(),
      );
    });

    test("une relecture (changement de compte) : jamais l'ancien compte", () {
      expect(
        spacesView(loading: true, failed: false, cards: cards),
        const SpacesLoading(),
      );
    });

    test("un échec, même avec d'anciennes cartes", () {
      expect(
        spacesView(loading: false, failed: true, cards: null),
        const SpacesFailed(),
      );
      expect(
        spacesView(loading: false, failed: true, cards: cards),
        const SpacesFailed(),
      );
    });

    test(
      "participants illisibles : les autres cartes, et l'athlète à relire",
      () {
        const partial = MySpaceCards(cards: [club], athleteUnknown: true);
        expect(
          spacesView(loading: false, failed: false, cards: partial),
          const SpacesShown(partial),
        );
        // Rien d'autre que l'athlète inconnu : on le dit quand même.
        const alone = MySpaceCards(cards: [], athleteUnknown: true);
        expect(
          spacesView(loading: false, failed: false, cards: alone),
          const SpacesShown(alone),
        );
      },
    );
  });

  group('résumé des suivis', () {
    test('une lecture en échec ne dit pas « aucun suivi »', () {
      expect(followsSummaryOf(null, failed: true, fr), isNull);
      expect(followsSummaryOf(null, failed: false, fr), '');
      expect(
        followsSummaryOf(const Follows(), failed: false, fr),
        'Aucun suivi',
      );
      // Une valeur déjà lue reste montrée.
      expect(
        followsSummaryOf(
          const Follows(clubs: [FollowedClub(id: 1, label: 'C')]),
          failed: true,
          fr,
        ),
        '1 club',
      );
    });
  });
}
