import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/data/ffss/dtos/deroulement_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/epreuve_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/reunion_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/serie_results_dto.dart';
import 'package:live_ffss_v2/data/ffss/mappers/deroulement_mapper.dart';
import 'package:live_ffss_v2/data/ffss/mappers/reunion_mapper.dart';
import 'package:live_ffss_v2/data/ffss/mappers/results_mapper.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/gender.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/progression.dart';
import 'package:live_ffss_v2/domain/run_status.dart';
import 'package:live_ffss_v2/domain/series_link.dart';

import '../support/fixtures.dart';

List<Map<String, dynamic>> _rows(String name) =>
    (fixture(name)['data'] as List<dynamic>).cast<Map<String, dynamic>>();

Programme _fixtureProgramme() {
  final progressions = [
    for (final row in _rows('deroulement'))
      ?DeroulementDto.fromJson(row).toDomain(),
  ];
  final meetings = [
    for (final row in _rows('reunion')) ?ReunionDto.fromJson(row).toDomain(),
  ];
  return Programme(
    meetings: withRaces(meetings, progressions),
    progressions: progressions,
  );
}

CompetitionEvent _fixtureEvent(int id) => [
  for (final row in _rows('epreuves_1416'))
    ?EpreuveDto.fromJson(row).toDomain(),
].firstWhere((e) => e.id == id);

List<EventSeries> _fixtureSeries(int eventId) => [
  for (final row in _rows('serie_epreuve_$eventId'))
    ?SerieResultsDto.fromJson(row).toDomain(),
];

const _event = CompetitionEvent(
  id: 1,
  disciplineId: 24,
  disciplineName: '200m Obstacles',
  gender: Gender.female,
  categoryId: 13,
  categoryName: 'Cadet',
  teamSize: 1,
);

Stage _stage(int id, StageLevel level, String name) => Stage(
  id: id,
  order: id,
  level: level,
  name: name,
  qualification: QualificationMethod.none,
  heatCount: 2,
  placesPerHeat: 8,
);

final _progression = Progression(
  id: 501,
  name: '200m Obstacles Dames',
  disciplineId: 24,
  gender: Gender.female,
  categories: const ['Cadet', 'Junior'],
  stages: [
    _stage(142, StageLevel.heats, 'Série - Cadet, Junior'),
    _stage(143, StageLevel.finalStage, 'Finale - Cadet'),
    _stage(144, StageLevel.finalStage, 'Finale - Junior'),
  ],
);

DateTime _at(int hour, int minute, [int second = 0]) =>
    DateTime(2026, 3, 27, hour, minute, second);

Heat _heat(
  int id,
  String name,
  int number,
  DateTime? start, {
  RunStatus status = RunStatus.finished,
}) => Heat(
  id: id,
  name: name,
  number: number,
  status: status,
  plannedStart: start,
);

Programme _programme(List<MeetingItem> items) => Programme(
  meetings: [Meeting(id: 1, name: 'R', day: _at(0, 0), items: items)],
  progressions: [_progression],
);

EventSeries _series(int id, String name, int number, DateTime? start) =>
    EventSeries(id: id, eventId: 1, number: number, name: name, start: start);

void main() {
  group('fixtures de la recette 1416', () {
    final programme = _fixtureProgramme();

    test('36073 (Cadet) : les séries du programme, sans celles d\'avril', () {
      final linked = linkSeries(
        programme,
        _fixtureEvent(36073),
        _fixtureSeries(36073),
      );
      // La réunion réduite ne garde que les courses 479 et 480 du créneau 177.
      expect(
        [for (final l in linked) (l.series.id, l.heat.id, l.round)],
        unorderedEquals([
          (94894, 479, EventRound.heats),
          (94899, 480, EventRound.heats),
        ]),
      );
      for (final l in linked) {
        expect(l.series.number, l.heat.number);
        expect(l.series.start, isNotNull);
        expect(l.finished, isTrue);
        expect(l.provisional, isTrue);
      }
    });

    test('36074 (Junior, absente de la réunion) : mêmes courses par numéro '
        'et heure', () {
      final linked = linkSeries(
        programme,
        _fixtureEvent(36074),
        _fixtureSeries(36074),
      );
      // Pas de série 1 Junior publiée : seule la série 2 trouve sa course.
      expect(
        [for (final l in linked) (l.series.id, l.heat.id, l.round)],
        [(94900, 480, EventRound.heats)],
      );
    });

    test('une épreuve sans déroulement : rien de rattaché', () {
      expect(
        linkSeries(
          programme,
          _event.copyWith(disciplineId: 999),
          _fixtureSeries(36073),
        ),
        isEmpty,
      );
    });
  });

  group('règles', () {
    test('finale A et finale B reconnues au nom de la course', () {
      final programme = _programme([
        MeetingItem(
          id: 1,
          name: 'Finale A',
          roundId: 143,
          heats: [_heat(10, 'Finale A - Cadet', 0, _at(17, 37))],
        ),
        MeetingItem(
          id: 2,
          name: 'Finale B',
          roundId: 143,
          heats: [_heat(11, 'Finale B - Cadet', 0, _at(17, 30))],
        ),
      ]);
      final linked = linkSeries(programme, _event, [
        _series(1, 'Finale A - Cadet', 1, _at(17, 38)),
        _series(2, 'Finale B - Cadet', 1, _at(17, 31)),
      ]);
      expect(
        [for (final l in linked) (l.series.id, l.heat.id, l.round)],
        unorderedEquals([
          (1, 10, EventRound.finalA),
          (2, 11, EventRound.finalB),
        ]),
      );
    });

    test('la finale d\'une autre catégorie n\'est pas candidate', () {
      final programme = _programme([
        MeetingItem(
          id: 1,
          name: 'Finale A Junior',
          roundId: 144,
          heats: [_heat(10, 'Finale A - Junior', 0, _at(17, 40))],
        ),
      ]);
      expect(
        linkSeries(programme, _event, [
          _series(1, 'Finale A - Cadet', 1, _at(17, 40)),
        ]),
        isEmpty,
      );
    });

    test('une série ne se rattache pas à une finale, ni l\'inverse', () {
      final programme = _programme([
        MeetingItem(
          id: 1,
          name: 'Séries',
          roundId: 142,
          heats: [_heat(10, 'Série 1', 1, _at(8, 0))],
        ),
      ]);
      expect(
        linkSeries(programme, _event, [
          _series(1, 'Finale A - Cadet', 1, _at(8, 0)),
        ]),
        isEmpty,
      );
    });

    test('5 min d\'écart : rattachée ; 6 min : non rattachée', () {
      final programme = _programme([
        MeetingItem(
          id: 1,
          name: 'Séries',
          roundId: 142,
          heats: [
            _heat(10, 'Série 1', 1, _at(8, 0)),
            _heat(11, 'Série 2', 2, _at(8, 10)),
          ],
        ),
      ]);
      final linked = linkSeries(programme, _event, [
        _series(1, 'Série 1', 1, _at(8, 5)),
        _series(2, 'Série 2', 2, _at(8, 16)),
      ]);
      expect([for (final l in linked) l.series.id], [1]);
    });

    test('série sans heure de début : ignorée', () {
      final programme = _programme([
        MeetingItem(
          id: 1,
          name: 'Séries',
          roundId: 142,
          heats: [_heat(10, 'Série 1', 1, _at(8, 0))],
        ),
      ]);
      expect(
        linkSeries(programme, _event, [_series(1, 'Série 1', 1, null)]),
        isEmpty,
      );
    });

    test('course sans heure prévue : numéro seul, en séries seulement', () {
      final programme = _programme([
        MeetingItem(
          id: 1,
          name: 'Séries',
          roundId: 142,
          heats: [_heat(10, 'Série 1', 1, null)],
        ),
        MeetingItem(
          id: 2,
          name: 'Finale A',
          roundId: 143,
          heats: [_heat(11, 'Finale A - Cadet', 0, null)],
        ),
      ]);
      final linked = linkSeries(programme, _event, [
        _series(1, 'Série 1', 1, _at(12, 0)),
        _series(2, 'Finale A - Cadet', 1, _at(17, 0)),
      ]);
      expect([for (final l in linked) (l.series.id, l.heat.id)], [(1, 10)]);
    });

    test('une course ne prend qu\'une série de l\'épreuve', () {
      final programme = _programme([
        MeetingItem(
          id: 1,
          name: 'Séries',
          roundId: 142,
          heats: [_heat(10, 'Série 1', 1, _at(8, 0))],
        ),
      ]);
      final linked = linkSeries(programme, _event, [
        _series(1, 'Série 1', 1, _at(8, 3)),
        _series(2, 'Série 1', 1, _at(8, 1)),
      ]);
      expect([for (final l in linked) l.series.id], [2]);
    });

    test('état : celui de la course', () {
      final programme = _programme([
        MeetingItem(
          id: 1,
          name: 'Séries',
          roundId: 142,
          heats: [
            _heat(10, 'Série 1', 1, _at(8, 0), status: RunStatus.inProgress),
            _heat(
              11,
              'Série 2',
              2,
              _at(8, 4),
            ).copyWith(resultsProvisional: false),
          ],
        ),
      ]);
      final linked = linkSeries(programme, _event, [
        _series(1, 'Série 1', 1, _at(8, 0)),
        _series(2, 'Série 2', 2, _at(8, 4)),
      ]);
      expect(
        [for (final l in linked) (l.series.id, l.finished, l.provisional)],
        [(1, false, true), (2, true, false)],
      );
    });
  });
}
