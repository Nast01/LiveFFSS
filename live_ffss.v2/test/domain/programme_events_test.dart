import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/domain/gender.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/programme_events.dart';
import 'package:live_ffss_v2/domain/progression.dart';
import 'package:live_ffss_v2/domain/run_status.dart';

Stage _stage(int id, int order, StageLevel level, String name) => Stage(
  id: id,
  order: order,
  level: level,
  name: name,
  qualification: QualificationMethod.none,
  heatCount: 2,
  placesPerHeat: 8,
);

// 100m Obstacles Dames : séries, puis finales A et B (une colonne).
final _obstacles = Progression(
  id: 1,
  name: '100m Obstacles - Femme',
  disciplineName: '100m Obstacles',
  gender: Gender.female,
  categories: const ['Cadet', 'Junior'],
  stages: [
    _stage(11, 1, StageLevel.heats, 'Série - Cadet, Junior'),
    _stage(12, 2, StageLevel.finalStage, 'Finale B - Cadet'),
    _stage(13, 3, StageLevel.finalStage, 'Finale A - Cadet'),
  ],
);

// 50m Mannequin Palmes Dames : séries seulement.
final _palmes = Progression(
  id: 2,
  name: '50m Mannequin Palmes - Femme',
  disciplineName: '50m Mannequin Palmes',
  gender: Gender.female,
  stages: [_stage(21, 1, StageLevel.heats, 'Série')],
);

Heat _heat(int id, RunStatus status, {bool generated = true}) => Heat(
  id: id,
  name: 'Série $id',
  number: id,
  status: status,
  seriesId: generated ? 1000 + id : null,
);

MeetingItem _item(
  int id,
  int? roundId,
  List<Heat> heats, {
  DateTime? start,
  String name = 'Créneau',
}) => MeetingItem(
  id: id,
  name: name,
  roundId: roundId,
  startTime: start,
  heats: heats,
);

final _saturday = DateTime(2026, 3, 28);
final _sunday = DateTime(2026, 3, 29);
DateTime _at(DateTime day, int h, int m) =>
    DateTime(day.year, day.month, day.day, h, m);

void main() {
  late Meeting saturday;
  late Meeting sunday;
  late Programme programme;

  setUp(() {
    saturday = Meeting(
      id: 1,
      name: 'Réunion 2',
      day: _saturday,
      items: [
        _item(100, null, const [], start: _at(_saturday, 14, 0)),
        _item(101, 11, [
          _heat(1, RunStatus.finished),
          _heat(2, RunStatus.inProgress),
        ], start: _at(_saturday, 14, 30)),
        _item(102, 21, [
          _heat(3, RunStatus.waiting),
          _heat(4, RunStatus.waiting),
        ], start: _at(_saturday, 15, 11)),
        _item(103, 11, [
          _heat(5, RunStatus.waiting),
        ], start: _at(_saturday, 15, 40)),
        _item(
          104,
          999,
          [_heat(6, RunStatus.waiting)],
          start: _at(_saturday, 16, 0),
          name: 'Course libre',
        ),
      ],
    );
    sunday = Meeting(
      id: 2,
      name: 'Réunion 3',
      day: _sunday,
      items: [
        _item(201, 12, [
          _heat(7, RunStatus.waiting, generated: false),
        ], start: _at(_sunday, 15, 0)),
        _item(202, 13, [
          _heat(8, RunStatus.waiting, generated: false),
        ], start: _at(_sunday, 15, 10)),
      ],
    );
    programme = Programme(
      meetings: [saturday, sunday],
      progressions: [_obstacles, _palmes],
    );
  });

  group('meetingEntries', () {
    test('une carte par épreuve, à la place de son premier créneau', () {
      final entries = meetingEntries(saturday, programme);

      expect(entries, hasLength(4));
      expect(entries[0], isA<PauseEntry>());
      expect((entries[0] as PauseEntry).item.id, 100);
      final obstacles = (entries[1] as EventEntry).event;
      expect(obstacles.key, 'p1');
      expect(obstacles.name, '100m Obstacles');
      expect(obstacles.gender, Gender.female);
      expect(obstacles.categories, ['Cadet', 'Junior']);
      // Les deux créneaux de séries de la réunion vont sur la même carte.
      expect(obstacles.items.map((i) => i.id), [101, 103]);
      expect((entries[2] as EventEntry).event.key, 'p2');
    });

    test('le parcours couvre tout le programme, finales comprises', () {
      final obstacles =
          (meetingEntries(saturday, programme)[1] as EventEntry).event;

      expect(obstacles.steps.map((s) => s.level), [
        StageLevel.heats,
        StageLevel.finalStage,
      ]);
      expect(obstacles.steps[0].status, ItemStatus.live);
      expect(obstacles.steps[1].stageCount, 2);
      expect(obstacles.steps[1].items.map((i) => i.id), [201, 202]);
      expect(obstacles.steps[1].start, _at(_sunday, 15, 0));
      expect(obstacles.steps[1].status, ItemStatus.seriesPending);
    });

    test('un créneau de course sans épreuve connue garde sa carte', () {
      final free = (meetingEntries(saturday, programme)[3] as EventEntry).event;

      expect(free.key, 'i104');
      expect(free.name, 'Course libre');
      expect(free.steps, isEmpty);
      expect(free.items.map((i) => i.id), [104]);
    });

    test('état de la carte : celui de ses créneaux dans la réunion', () {
      final entries = meetingEntries(saturday, programme);
      expect((entries[1] as EventEntry).event.status, ItemStatus.live);
      expect((entries[2] as EventEntry).event.status, ItemStatus.upcoming);
    });

    test('les séries de la carte, dans l\'ordre du programme', () {
      final obstacles =
          (meetingEntries(saturday, programme)[1] as EventEntry).event;
      expect(obstacles.heats.map((h) => h.id), [1, 2, 5]);
    });
  });

  group('eventTarget', () {
    test('le créneau en cours, sinon le premier à venir, sinon le premier', () {
      final live = _item(1, 11, [_heat(1, RunStatus.inProgress)]);
      final done = _item(2, 11, [_heat(2, RunStatus.finished)]);
      final next = _item(3, 11, [_heat(3, RunStatus.waiting)]);

      expect(eventTarget([done, next, live])?.id, 1);
      expect(eventTarget([done, next])?.id, 3);
      expect(eventTarget([done])?.id, 2);
      expect(eventTarget(const []), isNull);
    });
  });

  group('allStepsFinished', () {
    test('vrai quand chaque étape au programme est terminée', () {
      final obstacles =
          (meetingEntries(saturday, programme)[1] as EventEntry).event;
      expect(allStepsFinished(obstacles), isFalse);

      final done = ProgrammeEvent(
        key: 'p2',
        name: 'x',
        status: ItemStatus.finished,
        steps: [
          EventStep(
            level: StageLevel.heats,
            status: ItemStatus.finished,
            items: [
              _item(1, 21, [_heat(1, RunStatus.finished)]),
            ],
          ),
        ],
      );
      expect(allStepsFinished(done), isTrue);
    });

    test('une étape prévue sans créneau n\'est pas terminée', () {
      const pending = ProgrammeEvent(
        key: 'p1',
        name: 'x',
        status: ItemStatus.finished,
        steps: [
          EventStep(level: StageLevel.heats, status: ItemStatus.finished),
          EventStep(level: StageLevel.finalStage, status: ItemStatus.none),
        ],
      );
      expect(allStepsFinished(pending), isFalse);
    });
  });

  group('programmeFocus', () {
    test('l\'épreuve en cours d\'abord', () {
      final focus = programmeFocus([saturday], programme);
      expect(focus, (meetingId: 1, eventKey: 'p1'));
    });

    test('à défaut, la première épreuve qui n\'est pas terminée', () {
      final calm = saturday.copyWith(
        items: [
          _item(101, 11, [_heat(1, RunStatus.finished)]),
          _item(102, 21, [_heat(3, RunStatus.waiting)]),
        ],
      );
      expect(programmeFocus([calm], programme), (meetingId: 1, eventKey: 'p2'));
    });

    test('tout est couru : aucune', () {
      final done = saturday.copyWith(
        items: [
          _item(101, 11, [_heat(1, RunStatus.finished)]),
        ],
      );
      expect(programmeFocus([done], programme), isNull);
    });
  });

  group('openingFocus', () {
    test("aujourd'hui : l'épreuve en cours", () {
      expect(openingFocus(programme, _saturday, _at(_saturday, 14, 40)), (
        meetingId: 1,
        eventKey: 'p1',
      ));
    });

    test('un autre jour que celui affiché : en haut', () {
      expect(openingFocus(programme, _sunday, _at(_saturday, 14, 40)), isNull);
      expect(openingFocus(programme, null, _at(_saturday, 14, 40)), isNull);
    });
  });
}
