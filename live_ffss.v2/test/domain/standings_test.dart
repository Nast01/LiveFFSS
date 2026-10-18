import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/domain/event_ranking.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/gender.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/run_status.dart';
import 'package:live_ffss_v2/domain/series_link.dart';
import 'package:live_ffss_v2/domain/standings.dart';

var _id = 1;

const _series = LinkedSeries(
  series: EventSeries(id: 1, eventId: 1, number: 1, name: 'Série 1'),
  heat: Heat(id: 1, name: 'Série 1', number: 1, status: RunStatus.finished),
  round: EventRound.heats,
);

CompetitionEvent _event({
  int id = 1,
  int teamSize = 1,
  String category = 'Cadet',
}) => CompetitionEvent(
  id: id,
  disciplineId: 24,
  disciplineName: '200m Obstacles',
  gender: Gender.female,
  categoryId: 13,
  categoryName: category,
  teamSize: teamSize,
);

RankingRow _row({
  required String club,
  required int points,
  int? rank,
  int? athleteId,
  String name = 'A',
  Gender? gender = Gender.female,
}) {
  final id = _id++;
  return RankingRow(
    result: EventResult(
      id: id,
      entryId: id,
      eventId: 1,
      categoryName: 'Cadet',
      status: 0,
      club: club,
      athletes: [
        ResultAthlete(
          id: athleteId ?? id,
          name: name,
          gender: gender,
          club: club,
        ),
      ],
    ),
    rank: rank,
    points: points,
    qualification: Qualification.none,
    series: _series,
  );
}

EventRanking _ranking(CompetitionEvent event, List<RankingRow> rows) =>
    EventRanking(
      event: event,
      rows: rows,
      finishedSeries: 1,
      totalSeries: 1,
      provisional: true,
    );

void main() {
  setUp(() => _id = 1);

  group('clubStandings', () {
    test('3 meilleurs individuels comptent par club et épreuve', () {
      final result = clubStandings([
        _ranking(_event(), [
          _row(club: 'A', points: 20, rank: 1),
          _row(club: 'A', points: 18, rank: 2),
          _row(club: 'A', points: 16, rank: 3),
          _row(club: 'A', points: 14, rank: 4),
        ]),
      ]);
      expect(result.single.points, 54);
    });

    test('1 relais compte', () {
      final result = clubStandings([
        _ranking(_event(teamSize: 4), [
          _row(club: 'A', points: 20, rank: 1),
          _row(club: 'A', points: 18, rank: 2),
        ]),
      ]);
      expect(result.single.points, 20);
    });

    test('total sur les épreuves, club à 0 point inclus', () {
      final result = clubStandings([
        _ranking(_event(), [
          _row(club: 'A', points: 20, rank: 1),
          _row(club: 'B', points: 0),
        ]),
        _ranking(_event(id: 2), [_row(club: 'A', points: 18, rank: 1)]),
      ]);
      expect(
        [for (final c in result) (c.club, c.points)],
        [('A', 38), ('B', 0)],
      );
    });

    test(
      'égalités 1, 1, 3, puis ordre alphabétique, et écart au précédent',
      () {
        final result = clubStandings([
          _ranking(_event(), [
            _row(club: 'C', points: 10, rank: 1),
            _row(club: 'B', points: 10, rank: 2),
            _row(club: 'D', points: 4, rank: 3),
          ]),
        ]);
        expect(
          [for (final c in result) (c.club, c.rank, c.gapToPrevious)],
          [('B', 1, null), ('C', 1, 0), ('D', 3, 6)],
        );
      },
    );

    test('le plafond vaut par club et par épreuve', () {
      final result = clubStandings([
        _ranking(_event(), [
          for (final p in [20, 18, 16]) _row(club: 'A', points: p),
          for (final p in [10, 8, 6, 4]) _row(club: 'B', points: p),
        ]),
        _ranking(_event(id: 2), [
          for (final p in [14, 13, 12]) _row(club: 'A', points: p),
        ]),
      ]);
      expect(
        [for (final c in result) (c.club, c.points)],
        [('A', 93), ('B', 24)],
      );
    });

    test('le tri précède le plafond, un non-classé ne passe pas devant', () {
      final result = clubStandings([
        _ranking(_event(), [
          _row(club: 'A', points: 14, rank: 4),
          _row(club: 'A', points: 0),
          _row(club: 'A', points: 20, rank: 1),
          _row(club: 'A', points: 16, rank: 3),
          _row(club: 'A', points: 18, rank: 2),
        ]),
      ]);
      expect(result.single.points, 54);
    });

    test('écart mesuré au club précédent, non au premier', () {
      final result = clubStandings([
        _ranking(_event(), [
          _row(club: 'C', points: 10),
          _row(club: 'D', points: 7),
          _row(club: 'E', points: 4),
        ]),
      ]);
      expect([for (final c in result) c.gapToPrevious], [null, 3, 3]);
    });

    test('les noms de club sont rognés', () {
      final result = clubStandings([
        _ranking(_event(), [
          _row(club: 'ABC', points: 10),
          _row(club: 'ABC ', points: 8),
        ]),
      ]);
      expect([for (final c in result) (c.club, c.points)], [('ABC', 18)]);
    });

    test('noms comparés sans casse ni accents', () {
      final result = clubStandings([
        _ranking(_event(), [
          _row(club: 'Zoe', points: 5),
          _row(club: 'Élodie', points: 5),
        ]),
      ]);
      expect([for (final c in result) c.club], ['Élodie', 'Zoe']);
    });
  });

  group('licenseeStandings', () {
    test('séparés par sexe et catégorie, relais exclus, égalités 1, 1, 3', () {
      final result = licenseeStandings([
        _ranking(_event(), [
          _row(club: 'A', points: 20, rank: 1, athleteId: 1, name: 'Zoe'),
          _row(club: 'A', points: 20, rank: 1, athleteId: 2, name: 'Ana'),
          _row(club: 'A', points: 5, rank: 5, athleteId: 3, name: 'Eve'),
          _row(
            club: 'A',
            points: 20,
            rank: 1,
            athleteId: 4,
            name: 'Max',
            gender: Gender.male,
          ),
        ]),
        _ranking(_event(id: 2), [
          _row(club: 'A', points: 18, rank: 2, athleteId: 1, name: 'Zoe'),
        ]),
        _ranking(_event(id: 3, category: 'Junior'), [
          _row(club: 'A', points: 16, rank: 3, athleteId: 1, name: 'Zoe'),
        ]),
        _ranking(_event(id: 4, teamSize: 4), [
          _row(club: 'A', points: 20, rank: 1, athleteId: 9, name: 'Relais'),
        ]),
        _ranking(_event(id: 5), [
          _row(club: 'A', points: 20, rank: 1, athleteId: 8, gender: null),
        ]),
      ]);
      final cadetF = [
        for (final l in result)
          if (l.gender == Gender.female && l.categoryName == 'Cadet')
            (l.name, l.rank, l.points, l.races),
      ];
      expect(cadetF, [('Zoe', 1, 38, 2), ('Ana', 2, 20, 1), ('Eve', 3, 5, 1)]);
      expect(
        result.where((l) => l.athleteId == 9 || l.athleteId == 8),
        isEmpty,
      );
      expect(result.where((l) => l.athleteId == 4).single.gender, Gender.male);
      expect(
        result.where((l) => l.athleteId == 1).map((l) => l.categoryName),
        unorderedEquals(['Cadet', 'Junior']),
      );
    });

    test('noms comparés sans casse ni accents', () {
      final result = licenseeStandings([
        _ranking(_event(), [
          _row(club: 'A', points: 5, athleteId: 1, name: 'Zoe'),
          _row(club: 'A', points: 5, athleteId: 2, name: 'Élodie'),
        ]),
      ]);
      expect([for (final l in result) l.name], ['Élodie', 'Zoe']);
    });

    test('égalité 1, 1, 3 puis nom', () {
      final result = licenseeStandings([
        _ranking(_event(), [
          _row(club: 'A', points: 10, rank: 1, athleteId: 1, name: 'Zoe'),
          _row(club: 'A', points: 10, rank: 1, athleteId: 2, name: 'Ana'),
          _row(club: 'A', points: 4, rank: 3, athleteId: 3, name: 'Eve'),
        ]),
      ]);
      expect(
        [for (final l in result) (l.name, l.rank)],
        [('Ana', 1), ('Zoe', 1), ('Eve', 3)],
      );
    });
  });
}
