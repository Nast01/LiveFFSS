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
import 'package:live_ffss_v2/domain/my_space.dart';
import 'package:live_ffss_v2/domain/officials.dart';
import 'package:live_ffss_v2/domain/outbox.dart';
import 'package:live_ffss_v2/domain/race_result.dart';
import 'package:live_ffss_v2/domain/run_status.dart';
import 'package:live_ffss_v2/domain/series_link.dart';
import 'package:live_ffss_v2/domain/standings.dart';
import 'package:live_ffss_v2/features/my_space/club_forfeits_providers.dart';
import 'package:live_ffss_v2/features/my_space/my_space_formatting.dart';
import 'package:live_ffss_v2/features/my_space/my_space_providers.dart';
import 'package:live_ffss_v2/features/results/athlete_providers.dart';
import 'package:live_ffss_v2/features/results/results_formatting.dart';
import 'package:live_ffss_v2/features/results/results_providers.dart';

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
        "346 athlètes · 1 club · 60 épreuves d'eau plate",
      );
      expect(
        competitionCountsLine(info, en),
        '346 athletes · 1 club · 60 flat-water events',
      );
      expect(clubAthletesLabel(12, fr), '12 athlètes');
    });

    test('côtier seul : pas de nombre d\'épreuves', () {
      final info = CompetitionInfo(
        competition: summary,
        athletes: 120,
        clubs: [(id: 15, label: 'Club', athletes: 12)],
        events: 0,
      );
      expect(competitionCountsLine(info, fr), '120 athlètes · 1 club');
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

  group('espace athlète', () {
    test("l'athlète des cartes, nul sans carte Athlète", () {
      expect(
        spaceAthlete(
          const MySpaceCards(
            cards: [MySpaceCard.admin(), MySpaceCard.athlete(_participant)],
          ),
        ),
        _participant,
      );
      expect(
        spaceAthlete(const MySpaceCards(cards: [MySpaceCard.admin()])),
        isNull,
      );
    });

    test('la page : fiche, Réessayer ou pas engagé', () {
      const shown = MySpaceCards(cards: [MySpaceCard.athlete(_participant)]);
      expect(athleteSpaceView(const SpacesShown(shown)), (
        body: AthleteSpaceBody.card,
        athlete: _participant,
      ));
      expect(athleteSpaceView(const SpacesLoading()), (
        body: AthleteSpaceBody.loading,
        athlete: null,
      ));
      expect(athleteSpaceView(const SpacesFailed()), (
        body: AthleteSpaceBody.retry,
        athlete: null,
      ));
      expect(athleteSpaceView(const SpacesNone()), (
        body: AthleteSpaceBody.notEntered,
        athlete: null,
      ));
      // Participants illisibles : on ne sait pas, Réessayer.
      expect(
        athleteSpaceView(
          const SpacesShown(MySpaceCards(cards: [], athleteUnknown: true)),
        ),
        (body: AthleteSpaceBody.retry, athlete: null),
      );
      expect(
        athleteSpaceView(
          const SpacesShown(MySpaceCards(cards: [MySpaceCard.admin()])),
        ),
        (body: AthleteSpaceBody.notEntered, athlete: null),
      );
    });

    test(
      '« Trouver sa série » une fois : pas sur la tuile de la prochaine',
      () {
        final next = _toRun(1, 'x', DateTime(2026, 3, 27, 9));
        final later = _toRun(2, 'y', DateTime(2026, 3, 27, 10));
        expect(showsLaneFinder(next, next), isFalse);
        expect(showsLaneFinder(later, next), isTrue);
        expect(showsLaneFinder(later, null), isTrue);
      },
    );

    test('titre de la prochaine course : quand elle part', () {
      expect(
        nextRaceHeadline(_toRun(1, 'x', DateTime(2026, 3, 27, 9, 4)), now, fr),
        'Ma prochaine course · dans 2 h',
      );
      expect(
        nextRaceHeadline(_toRun(1, 'x', null), now, fr),
        'Ma prochaine course',
      );
      expect(nextRaceHeadline(_toRun(1, 'x', null), now, en), 'My next race');
    });

    test('heure, série et ligne : « Trouver sa série » les complète', () {
      final race = _toRun(1, 'x', DateTime(2026, 3, 27, 8, 58));
      expect(nextRaceCells(race, null), (
        time: '08:58',
        series: '–',
        lane: '–',
      ));
      const heat = Heat(
        id: 4,
        name: 'Série 6',
        number: 6,
        status: RunStatus.waiting,
      );
      expect(nextRaceCells(race, const LaneFound(heat: heat, lane: 4)), (
        time: '08:58',
        series: '6',
        lane: '4',
      ));
      // Sa série déjà publiée : connue sans chercher.
      final published = race.copyWith(
        series: const LinkedSeries(
          series: EventSeries(id: 1, eventId: 1, number: 6, name: 'Série 6'),
          heat: heat,
          round: EventRound.heats,
        ),
      );
      expect(nextRaceCells(published, null).series, '6');
      expect(nextRaceCells(_toRun(1, 'x', null), null).time, '–');
    });
  });

  group('espace club', () {
    final race = _toRun(1, '100m Bouée tube', DateTime(2026, 3, 27, 8, 58));
    const other = Participant(id: 8, firstName: 'Deux', lastName: 'ATHLETE');

    test('titre : ses athlètes ; ligne : épreuve et série', () {
      final relay = ClubRace(athletes: const [_participant, other], race: race);
      expect(clubRaceTitle(relay), 'Un ATHLETE, Deux ATHLETE');
      expect(
        clubRaceLine(ClubRace(athletes: const [_participant], race: race), fr),
        '100m Bouée tube · Dames · Cadet',
      );
      final withSeries = race.copyWith(
        series: const LinkedSeries(
          series: EventSeries(id: 1, eventId: 1, number: 6, name: 'Série 6'),
          heat: Heat(
            id: 4,
            name: 'Série 6',
            number: 6,
            status: RunStatus.waiting,
          ),
          round: EventRound.heats,
        ),
      );
      expect(
        clubRaceLine(
          ClubRace(athletes: const [_participant], race: withSeries),
          fr,
        ),
        '100m Bouée tube · Dames · Cadet · Série 6',
      );
      expect(
        clubRaceLine(
          ClubRace(
            athletes: const [_participant],
            race: race.copyWith(unavailable: true),
          ),
          fr,
        ),
        '100m Bouée tube · Dames · Cadet · '
        'Résultats illisibles pour cette épreuve',
      );
    });

    test('résultats groupés par épreuve, dans leur ordre', () {
      final a = ClubRace(athletes: const [_participant], race: race);
      final b = ClubRace(athletes: const [other], race: race);
      final c = ClubRace(
        athletes: const [other],
        race: _toRun(2, '200m Obstacles', null),
      );

      final groups = clubResultsByEvent([a, b, c]);

      expect(groups.map((g) => g.event.id), [1, 2]);
      expect(groups.first.races, [a, b]);
      expect(groups.last.races, [c]);
    });

    test('titre : le libellé des engagés, sinon des rôles, sinon « Club »', () {
      const club = ClubInfo(id: 15, label: 'Les Dauphins', athletes: []);
      const roles = CompetitionRoles(
        roles: ['public', 'referent_sportif'],
        refereeClubs: [ClubRef(id: 15, label: 'Dauphins (rôle)')],
      );
      expect(clubTitle(club, roles, 15, fr), 'Les Dauphins');
      expect(
        clubTitle(
          const ClubInfo(id: 15, label: '', athletes: []),
          roles,
          15,
          fr,
        ),
        'Dauphins (rôle)',
      );
      expect(clubTitle(null, null, 15, fr), 'Club');
      expect(clubTitle(null, roles, 16, fr), 'Club');
    });

    test('la page : chargement, échec, sans athlète, ou le club', () {
      const empty = ClubInfo(id: 15, label: 'C', athletes: []);
      const full = ClubInfo(id: 15, label: 'C', athletes: [_participant]);
      expect(clubBody(null, failed: false), ClubBody.loading);
      expect(clubBody(null, failed: true), ClubBody.failed);
      expect(clubBody(empty, failed: false), ClubBody.noAthlete);
      // Une relecture en échec garde le club affiché.
      expect(clubBody(full, failed: true), ClubBody.shown);
    });

    test('le chiffre des forfaits : « – » tant que le planning se lit', () {
      expect(forfeitsFigure(null), '–');
      expect(forfeitsFigure(const []), '0');
      expect(
        forfeitsFigure([
          ClubRace(athletes: const [_participant], race: race),
        ]),
        '1',
      );
    });

    test('forfaits : sans mention de lot', () {
      expect(
        fr.mySpaceForfeitsDeadline(10),
        "Déclarer ou annuler un forfait jusqu'à 10 min avant la course",
      );
      expect(
        en.mySpaceForfeitsDeadline(10),
        'Declare or cancel a withdrawal up to 10 min before the race',
      );
    });

    test('étiquette RÉFÉRENT / ADMIN, interrupteurs pour eux seuls', () {
      expect(clubRoleTag(ClubRole.referee, fr), 'RÉFÉRENT');
      expect(clubRoleTag(ClubRole.admin, fr), 'ADMIN');
      expect(clubRoleTag(ClubRole.none, fr), isNull);
      expect(canManageForfeits(ClubRole.referee), isTrue);
      expect(canManageForfeits(ClubRole.admin), isTrue);
      expect(canManageForfeits(ClubRole.none), isFalse);
    });

    group('rang provisoire du club', () {
      final standings = Standings(
        clubs: const [
          ClubStanding(rank: 1, club: 'Club A', points: 40),
          ClubStanding(rank: 2, club: 'Les Dauphins', points: 30),
        ],
        licensees: const [],
        finishedSeries: 1,
        totalSeries: 2,
        failedEvents: 0,
        computedAt: now,
      );

      test('compétition côtière : pas de rang, rien à calculer', () {
        expect(
          clubRankView(
            asked: true,
            failed: false,
            standings: null,
            club: 'x',
            coastal: true,
          ),
          const RankShown(null),
        );
      });

      test('pas encore calculé : « Calculer »', () {
        expect(
          clubRankView(asked: false, failed: false, standings: null, club: 'x'),
          const RankNotComputed(),
        );
      });

      test('en calcul, en échec', () {
        expect(
          clubRankView(asked: true, failed: false, standings: null, club: 'x'),
          const RankComputing(),
        );
        expect(
          clubRankView(asked: true, failed: true, standings: null, club: 'x'),
          const RankFailed(),
        );
      });

      test('calculé : son rang par libellé, ou rien', () {
        expect(
          clubRankView(
            asked: true,
            failed: false,
            standings: standings,
            club: ' Les Dauphins ',
          ),
          const RankShown(2),
        );
        expect(
          clubRankView(
            asked: true,
            failed: false,
            standings: standings,
            club: 'Inconnu',
          ),
          const RankShown(null),
        );
        // Une relecture en échec garde le calcul précédent.
        expect(
          clubRankView(
            asked: true,
            failed: true,
            standings: standings,
            club: 'Club A',
          ),
          const RankShown(1),
        );
        expect(clubRankLabel(const RankShown(2), fr), '2e');
        expect(clubRankLabel(const RankShown(1), en), '1st');
        expect(clubRankLabel(const RankShown(null), fr), '–');
      });
    });
  });

  group('forfaits du club', () {
    final event = _event(36073, '200m Obstacles');
    final relayEvent = _event(36075, '4x50m Obstacles').copyWith(teamSize: 4);
    const heat = Heat(
      id: 479,
      name: 'Série 2',
      number: 2,
      status: RunStatus.waiting,
    );
    final placed = ClubForfeit(
      entryId: 101,
      event: event,
      athletes: const ['Un ATHLETE'],
      heat: heat,
      lane: 4,
      forfeit: false,
      deadline: DateTime(2026, 3, 27, 7, 50),
    );

    test("ligne d'un athlète placé : épreuve, série et couloir", () {
      final label = clubForfeitLabel(placed, 'CLUB Test', fr);
      expect(label.title, 'Un ATHLETE');
      expect(
        label.subtitle,
        '${athleteRaceTitle(event, fr)} · Série 2 · couloir 4',
      );
      expect(
        clubForfeitLabel(placed, 'CLUB Test', en).subtitle,
        endsWith('Heat 2 · lane 4'),
      );
    });

    test("ligne d'un relais : le club, puis ses relayeurs", () {
      final relay = ClubForfeit(
        entryId: 200,
        event: relayEvent,
        athletes: const ['Un ATHLETE', 'Deux ATHLETE'],
        forfeit: false,
      );
      final label = clubForfeitLabel(relay, 'CLUB Test', fr);
      expect(label.title, 'CLUB Test');
      expect(
        label.subtitle,
        'Un ATHLETE, Deux ATHLETE · ${athleteRaceTitle(relayEvent, fr)}'
        ' · pas encore placé',
      );
    });

    test('place illisible : état inconnu', () {
      final unknown = ClubForfeit(
        entryId: 1,
        event: event,
        athletes: const ['Un ATHLETE'],
      );
      expect(
        clubForfeitLabel(unknown, '', fr).subtitle,
        endsWith('état inconnu (place illisible)'),
      );
    });

    test("état de l'interrupteur", () {
      final before = DateTime(2026, 3, 27, 7, 49);
      final at = DateTime(2026, 3, 27, 7, 50);
      expect(
        forfeitSwitch(placed, canManage: false, now: before),
        ForfeitSwitch.hidden,
      );
      expect(
        forfeitSwitch(placed, canManage: true, now: before),
        ForfeitSwitch.active,
      );
      expect(
        forfeitSwitch(placed, canManage: true, now: at),
        ForfeitSwitch.locked,
      );
      expect(
        forfeitSwitch(
          placed.copyWith(sending: ForfeitSending.sending),
          canManage: true,
          now: before,
        ),
        ForfeitSwitch.sending,
      );
      expect(
        forfeitSwitch(
          placed.copyWith(forfeit: null),
          canManage: true,
          now: before,
        ),
        ForfeitSwitch.unknown,
      );
      // Sans échéance connue, rien ne verrouille.
      expect(
        forfeitSwitch(
          placed.copyWith(deadline: null),
          canManage: true,
          now: at,
        ),
        ForfeitSwitch.active,
      );
    });

    test('message de résultat', () {
      expect(forfeitOutcomeMessage(ForfeitOutcome.done, fr), isNull);
      expect(
        forfeitOutcomeMessage(ForfeitOutcome.locked, fr),
        'Trop tard : moins de 10 min avant la course',
      );
      expect(
        forfeitOutcomeMessage(ForfeitOutcome.notAllowed, fr),
        fr.mySpaceForfeitNotAllowed,
      );
      expect(
        forfeitOutcomeMessage(ForfeitOutcome.failed, en),
        en.mySpaceForfeitFailed,
      );
    });
  });
}
