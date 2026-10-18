import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/data/ffss/dtos/deroulement_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/epreuve_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/reunion_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/serie_results_dto.dart';
import 'package:live_ffss_v2/data/ffss/mappers/deroulement_mapper.dart';
import 'package:live_ffss_v2/data/ffss/mappers/reunion_mapper.dart';
import 'package:live_ffss_v2/data/ffss/mappers/results_mapper.dart';
import 'package:live_ffss_v2/domain/event_ranking.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/gender.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/run_status.dart';
import 'package:live_ffss_v2/domain/series_link.dart';

import '../support/fixtures.dart';

const _event = CompetitionEvent(
  id: 1,
  disciplineId: 24,
  disciplineName: '200m Obstacles',
  gender: Gender.female,
  categoryId: 13,
  categoryName: 'Cadet',
  teamSize: 1,
);

var _nextId = 1;

/// [entry] est aussi l'id de résultat par défaut : l'ordre des ex æquo en
/// dépend.
EventResult _r(
  int entry, {
  int? time,
  int status = 0,
  String complement = '',
  int? id,
}) => EventResult(
  id: id ?? entry,
  entryId: entry,
  eventId: 1,
  categoryName: 'Cadet',
  status: status,
  time: time,
  complement: complement,
);

LinkedSeries _s(
  EventRound round,
  int number,
  List<EventResult> results, {
  RunStatus status = RunStatus.finished,
  bool provisional = false,
}) {
  final id = _nextId++;
  return LinkedSeries(
    series: EventSeries(
      id: id,
      eventId: 1,
      number: number,
      name: 'S$number',
      results: results,
    ),
    heat: Heat(
      id: id,
      name: 'S$number',
      number: number,
      status: status,
      resultsProvisional: provisional,
    ),
    round: round,
  );
}

List<(int, int?, int)> _table(EventRanking ranking) => [
  for (final row in ranking.rows) (row.result.entryId, row.rank, row.points),
];

/// Seize nageurs en séries, de 1 (le plus rapide) à 16.
List<LinkedSeries> _sixteenHeats() => [
  _s(EventRound.heats, 1, [
    for (var e = 1; e <= 16; e += 2) _r(e, time: 6000 + e),
  ]),
  _s(EventRound.heats, 2, [
    for (var e = 2; e <= 16; e += 2) _r(e, time: 6000 + e),
  ]),
];

void main() {
  test('barème de V3, 0 au-delà', () {
    expect(pointScale, [
      20,
      18,
      16,
      14,
      13,
      12,
      11,
      10,
      8,
      7,
      6,
      5,
      4,
      3,
      2,
      1,
    ]);
    expect(pointsFor(1), 20);
    expect(pointsFor(16), 1);
    expect(pointsFor(17), 0);
    expect(pointsFor(0), 0);
  });

  group('sans finale', () {
    test('au temps, toutes séries ; ex æquo 1, 2, 2, 4', () {
      final ranking = rankEvent(_event, [
        _s(EventRound.heats, 1, [_r(1, time: 3000), _r(3, time: 3100)]),
        _s(EventRound.heats, 2, [_r(2, time: 3100), _r(4, time: 3200)]),
      ]);
      // Ex æquo : la série 1 d'abord.
      expect(_table(ranking), [(1, 1, 20), (3, 2, 18), (2, 2, 18), (4, 4, 14)]);
      expect(ranking.rows.map((r) => r.seriesNumber), [1, 1, 2, 2]);
    });

    test('ex æquo d\'une même série : par id de résultat', () {
      final ranking = rankEvent(_event, [
        _s(EventRound.heats, 1, [
          _r(1, time: 3000, id: 9),
          _r(2, time: 3000, id: 5),
        ]),
      ]);
      expect(_table(ranking), [(2, 1, 20), (1, 1, 20)]);
    });

    test('non classés en bas : FF sans temps, HT, DQ, F, autres', () {
      final ranking = rankEvent(_event, [
        _s(EventRound.heats, 1, [
          _r(1, status: 3),
          _r(2, status: 2, complement: 'F'),
          _r(3, status: 1, complement: '12'),
          _r(4, time: 3500, complement: 'HT'),
          _r(5, complement: 'FF'),
          _r(6, time: 4000),
          _r(7),
        ]),
      ]);
      expect(_table(ranking), [
        (6, 1, 20),
        (5, null, 0),
        (4, null, 0),
        (3, null, 0),
        (2, null, 0),
        (1, null, 0),
        (7, null, 0),
      ]);
    });

    test('un FF avec temps est classé, sans qualification', () {
      final ranking = rankEvent(_event, [
        _s(EventRound.heats, 1, [
          _r(1, time: 3000, complement: 'FF'),
          _r(2, time: 3100, complement: 'QFA'),
        ]),
      ]);
      expect(_table(ranking), [(1, 1, 20), (2, 2, 18)]);
      expect(ranking.rows.first.qualification, Qualification.none);
    });
  });

  group('finales A et B', () {
    test('A 1-8, B 9-16, le reste au temps des séries, séries à 0', () {
      final heats = _sixteenHeats();
      heats.add(
        _s(EventRound.heats, 3, [_r(17, time: 6017), _r(18, time: 6018)]),
      );
      final ranking = rankEvent(_event, [
        ...heats,
        // Finale B : l'ordre s'inverse.
        _s(EventRound.finalB, 0, [
          for (var e = 9; e <= 16; e++) _r(e, time: 7000 - e),
        ]),
        _s(EventRound.finalA, 0, [
          for (var e = 1; e <= 8; e++) _r(e, time: 5000 + e),
        ]),
      ]);
      expect(_table(ranking), [
        for (var e = 1; e <= 8; e++) (e, e, pointsFor(e)),
        for (var e = 16; e >= 9; e--) (e, 25 - e, pointsFor(25 - e)),
        (17, 17, 0),
        (18, 18, 0),
      ]);
      expect(ranking.rows.first.qualification, Qualification.finalA);
      expect(ranking.rows.first.round, EventRound.finalA);
      expect(ranking.rows[8].qualification, Qualification.finalB);
    });

    test('avant les finales, les séries ne marquent rien', () {
      final ranking = rankEvent(_event, [
        _s(EventRound.heats, 1, [
          _r(1, time: 3000, complement: 'QFA'),
          _r(2, time: 3100, complement: 'QFB'),
          _r(3, time: 3200),
        ]),
        _s(EventRound.finalA, 0, const [], status: RunStatus.waiting),
        _s(EventRound.finalB, 0, const [], status: RunStatus.waiting),
      ]);
      expect(_table(ranking), [(1, 1, 0), (2, 2, 0), (3, 3, 0)]);
      expect(ranking.rows.map((r) => r.qualification), [
        Qualification.finalA,
        Qualification.finalB,
        Qualification.none,
      ]);
    });

    test('un DQ en finale prend la dernière place de sa finale', () {
      final ranking = rankEvent(_event, [
        ..._sixteenHeats(),
        _s(EventRound.finalA, 0, [
          _r(1, status: 1, complement: '12'),
          for (var e = 2; e <= 8; e++) _r(e, time: 5000 + e),
        ]),
        _s(EventRound.finalB, 0, [
          _r(9, status: 1, complement: '12'),
          for (var e = 10; e <= 16; e++) _r(e, time: 5000 + e),
        ]),
      ]);
      final byEntry = {for (final row in ranking.rows) row.result.entryId: row};
      expect(byEntry[1]!.rank, 8);
      expect(byEntry[1]!.points, 10);
      expect(byEntry[8]!.rank, 7);
      expect(byEntry[9]!.rank, 16);
      expect(byEntry[9]!.points, 1);
      expect(ranking.rows.length, 16);
    });
  });

  group('finale A seule', () {
    test('les non-finalistes prennent 9-16 au temps des séries', () {
      final ranking = rankEvent(_event, [
        ..._sixteenHeats(),
        _s(EventRound.finalA, 0, [
          for (var e = 1; e <= 8; e++) _r(e, time: 5000 + e),
        ]),
      ]);
      expect(_table(ranking), [
        for (var e = 1; e <= 16; e++) (e, e, pointsFor(e)),
      ]);
    });

    test('avant la finale : les qualifiés attendent, les autres marquent', () {
      final ranking = rankEvent(_event, [
        _s(EventRound.heats, 1, [
          _r(1, time: 3000, complement: 'QFA'),
          _r(2, time: 3100, complement: 'FF'),
          _r(3, time: 3200),
          _r(4, status: 1, complement: '12'),
        ]),
        _s(EventRound.finalA, 0, const [], status: RunStatus.waiting),
      ]);
      // Le classement reste celui des séries ; le FF ne se qualifie pas.
      expect(_table(ranking), [
        (1, 1, 0),
        (2, 2, pointsFor(9)),
        (3, 3, pointsFor(10)),
        (4, null, 0),
      ]);
    });
  });

  test('qualification : QFA de la série, sinon présence en finale', () {
    final ranking = rankEvent(_event, [
      _s(EventRound.heats, 1, [
        _r(1, time: 3000, complement: 'QFA'),
        _r(2, time: 3100),
      ]),
      _s(EventRound.finalA, 0, [
        _r(2, time: 2900),
      ], status: RunStatus.inProgress),
    ]);
    final byEntry = {for (final row in ranking.rows) row.result.entryId: row};
    expect(byEntry[1]!.qualification, Qualification.finalA);
    expect(byEntry[1]!.round, EventRound.heats);
    expect(byEntry[2]!.qualification, Qualification.finalA);
    expect(byEntry[2]!.round, EventRound.finalA);
  });

  test('séries terminées, total et provisoire', () {
    final done = _s(EventRound.heats, 1, [_r(1, time: 3000)]);
    final running = _s(EventRound.heats, 2, [
      _r(2, time: 3000),
    ], status: RunStatus.inProgress);
    final ranking = rankEvent(_event, [done, running]);
    expect(ranking.finishedSeries, 1);
    expect(ranking.totalSeries, 2);
    expect(ranking.provisional, isTrue);
    expect(rankEvent(_event, [done]).provisional, isFalse);
    expect(
      rankEvent(_event, [
        _s(EventRound.heats, 1, const [], provisional: true),
      ]).provisional,
      isTrue,
    );
    final empty = rankEvent(_event, const []);
    expect(empty.provisional, isTrue);
    expect(empty.rows, isEmpty);
    expect(empty.totalSeries, 0);
  });

  group('heatPlace', () {
    final heat = [
      _r(1, time: 3000),
      _r(2, time: 3100),
      _r(3, time: 3100),
      _r(4, time: 3200, complement: 'FF'),
      _r(5, time: 2000, complement: 'HT'),
      _r(6, status: 1, time: 1000),
    ];

    test('place au temps, ex æquo et FF classé', () {
      expect([for (final r in heat.take(4)) heatPlace(r, heat)], [1, 2, 2, 4]);
    });

    test('HT et DQ sans place', () {
      expect(heatPlace(heat[4], heat), isNull);
      expect(heatPlace(heat[5], heat), isNull);
    });
  });

  test('fixture 36073 rattachée : aucun doublon d\'engagement', () {
    List<Map<String, dynamic>> rows(String name) =>
        (fixture(name)['data'] as List<dynamic>).cast<Map<String, dynamic>>();
    final progressions = [
      for (final row in rows('deroulement'))
        ?DeroulementDto.fromJson(row).toDomain(),
    ];
    final meetings = [
      for (final row in rows('reunion')) ?ReunionDto.fromJson(row).toDomain(),
    ];
    final programme = Programme(
      meetings: withRaces(meetings, progressions),
      progressions: progressions,
    );
    final event = [
      for (final row in rows('epreuves_1416'))
        ?EpreuveDto.fromJson(row).toDomain(),
    ].firstWhere((e) => e.id == 36073);
    final series = [
      for (final row in rows('serie_epreuve_36073'))
        ?SerieResultsDto.fromJson(row).toDomain(),
    ];
    final linked = linkSeries(programme, event, series);
    final ranking = rankEvent(event, linked);

    final entries = [for (final row in ranking.rows) row.result.entryId];
    expect(entries, isNotEmpty);
    expect(entries.toSet().length, entries.length);
    expect(ranking.totalSeries, linked.length);
    expect(
      ranking.rows.length,
      {
        for (final one in linked)
          for (final r in one.series.results) r.entryId,
      }.length,
    );
    // Rangs croissants, classés d'abord.
    final ranks = [for (final row in ranking.rows) ?row.rank];
    expect(ranks, [...ranks]..sort());
    expect(ranking.rows.first.rank, 1);
  });
}
