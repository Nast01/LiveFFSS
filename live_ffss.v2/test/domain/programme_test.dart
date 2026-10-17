import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/data/ffss/dtos/deroulement_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/reunion_dto.dart';
import 'package:live_ffss_v2/data/ffss/mappers/deroulement_mapper.dart';
import 'package:live_ffss_v2/data/ffss/mappers/reunion_mapper.dart';
import 'package:live_ffss_v2/domain/gender.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/progression.dart';
import 'package:live_ffss_v2/domain/run_status.dart';

import '../support/fixtures.dart';

const _progression = Progression(
  id: 501,
  name: 'Épreuve',
  disciplineName: '200m Obstacles',
  gender: Gender.female,
  stages: [
    Stage(
      id: 142,
      order: 1,
      level: StageLevel.heats,
      name: 'Séries',
      qualification: QualificationMethod.none,
      heatCount: 2,
      placesPerHeat: 6,
    ),
  ],
);

Meeting _meeting({int? roundId, String raceName = ''}) => Meeting(
  id: 1,
  name: 'R',
  day: DateTime(2026, 3, 27),
  items: [
    MeetingItem(
      id: 10,
      name: 'C',
      roundId: roundId,
      heats: [
        Heat(
          id: 20,
          name: 'Série 1',
          number: 1,
          status: RunStatus.waiting,
          raceName: raceName,
        ),
      ],
    ),
  ],
);

Heat _heat(List<Meeting> meetings) => meetings.single.items.single.heats.single;

void main() {
  test('withRaces donne nom, sexe et épreuve aux courses du déroulement', () {
    final heat = _heat(withRaces([_meeting(roundId: 142)], [_progression]));

    expect(heat.raceName, '200m Obstacles');
    expect(heat.gender, Gender.female);
    expect(heat.raceId, 501);
  });

  test('une course qui a déjà son épreuve la garde', () {
    final heat = _heat(
      withRaces([_meeting(roundId: 142, raceName: '50m')], [_progression]),
    );

    expect(heat.raceName, '50m');
    expect(heat.raceId, isNull);
  });

  test('un créneau sans partie reste sans épreuve', () {
    final heat = _heat(withRaces([_meeting()], [_progression]));

    expect(heat.raceName, '');
    expect(heat.raceId, isNull);
  });

  test('findItem et progressionOfStage', () {
    final programme = Programme(
      meetings: [_meeting(roundId: 142)],
      progressions: const [_progression],
    );

    final found = programme.findItem(10);
    expect(found?.meeting.id, 1);
    expect(found?.item.id, 10);
    expect(programme.findItem(99), isNull);
    expect(programme.progressionOfStage(142)?.id, 501);
    expect(programme.progressionOfStage(1), isNull);
  });

  group('programmeDays', () {
    test('les jours de la fixture réunion', () {
      final meetings = [
        for (final json in fixture('reunion')['data'] as List<dynamic>)
          ReunionDto.fromJson(json as Map<String, dynamic>).toDomain()!,
      ];

      expect(programmeDays(meetings), [DateTime(2026, 3, 27)]);
    });

    test('distincts, croissants, à minuit', () {
      final days = programmeDays([
        Meeting(id: 1, name: 'a', day: DateTime(2026, 3, 29, 8)),
        Meeting(id: 2, name: 'b', day: DateTime(2026, 3, 27)),
        Meeting(id: 3, name: 'c', day: DateTime(2026, 3, 29, 15)),
      ]);

      expect(days, [DateTime(2026, 3, 27), DateTime(2026, 3, 29)]);
    });
  });

  group('initialDay', () {
    final days = [DateTime(2026, 3, 27), DateTime(2026, 3, 28)];

    test('aujourd\'hui s\'il fait partie des jours', () {
      expect(
        initialDay(days, DateTime(2026, 3, 28, 14)),
        DateTime(2026, 3, 28),
      );
    });

    test('le premier jour si aujourd\'hui le précède', () {
      expect(initialDay(days, DateTime(2026, 3, 1)), DateTime(2026, 3, 27));
    });

    test('le dernier jour si aujourd\'hui est passé', () {
      expect(initialDay(days, DateTime(2026, 4, 1)), DateTime(2026, 3, 28));
    });

    test('nul sans jour', () {
      expect(initialDay(const [], DateTime(2026, 3, 27)), isNull);
    });
  });

  group('itemStatus', () {
    Heat heat(RunStatus status, {int? seriesId}) =>
        Heat(id: 1, name: 'h', number: 1, status: status, seriesId: seriesId);
    MeetingItem item(List<Heat> heats) =>
        MeetingItem(id: 1, name: 'c', heats: heats);

    test('none sans course', () {
      expect(itemStatus(item(const [])), ItemStatus.none);
    });

    test('live si une course est en cours ou en appel', () {
      expect(
        itemStatus(
          item([heat(RunStatus.finished), heat(RunStatus.inProgress)]),
        ),
        ItemStatus.live,
      );
      expect(itemStatus(item([heat(RunStatus.marshalling)])), ItemStatus.live);
    });

    test('finished si toutes sont terminées', () {
      expect(
        itemStatus(item([heat(RunStatus.finished), heat(RunStatus.finished)])),
        ItemStatus.finished,
      );
    });

    test('seriesPending si aucune n\'a de série', () {
      expect(
        itemStatus(item([heat(RunStatus.waiting)])),
        ItemStatus.seriesPending,
      );
    });

    test('upcoming sinon', () {
      expect(
        itemStatus(item([heat(RunStatus.waiting, seriesId: 5)])),
        ItemStatus.upcoming,
      );
    });
  });

  group('progressionColumns', () {
    Progression fromFixture(int index) => DeroulementDto.fromJson(
      (fixture('deroulement')['data'] as List<dynamic>)[index]
          as Map<String, dynamic>,
    ).toDomain()!;

    test('501 : les séries, puis les trois finales ensemble', () {
      final columns = progressionColumns(fromFixture(0));

      expect(columns, hasLength(2));
      expect(columns[0].map((s) => s.name), [
        'Série - Cadet, Junior, Seniors et Masters',
      ]);
      expect(columns[1].map((s) => s.name), [
        'Finale - Cadet',
        'Finale - Junior',
        'Finale - Seniors et Masters',
      ]);
    });

    test('502 : une seule colonne', () {
      final columns = progressionColumns(fromFixture(1));

      expect(columns, hasLength(1));
      expect(columns.single.single.name, 'Série - Youth');
    });

    test('séries, demi, finale : trois colonnes, selon l\'ordre', () {
      Stage stage(int id, int order, StageLevel level) => Stage(
        id: id,
        order: order,
        level: level,
        name: 's$id',
        qualification: QualificationMethod.none,
        heatCount: 1,
        placesPerHeat: 8,
      );
      final columns = progressionColumns(
        Progression(
          id: 1,
          name: 'p',
          stages: [
            stage(3, 3, StageLevel.finalStage),
            stage(1, 1, StageLevel.heats),
            stage(2, 2, StageLevel.semiFinal),
          ],
        ),
      );

      expect(
        [for (final c in columns) c.map((s) => s.id).toList()],
        [
          [1],
          [2],
          [3],
        ],
      );
    });
  });

  group('itemsOfStage', () {
    test('les créneaux de la partie, dans l\'ordre du programme', () {
      MeetingItem item(int id, int? roundId) =>
          MeetingItem(id: id, name: 'c$id', roundId: roundId);
      final meetings = [
        Meeting(
          id: 1,
          name: 'm1',
          day: DateTime(2026, 3, 27),
          items: [item(1, 9), item(2, 7)],
        ),
        Meeting(
          id: 2,
          name: 'm2',
          day: DateTime(2026, 3, 28),
          items: [item(3, 7), item(4, null)],
        ),
      ];

      expect(itemsOfStage(meetings, 7).map((i) => i.id), [2, 3]);
      expect(itemsOfStage(meetings, 1), isEmpty);
    });
  });

  group('qualificationRule', () {
    Stage stage(QualificationMethod method) => Stage(
      id: 1,
      order: 1,
      level: StageLevel.heats,
      name: 's',
      qualification: method,
      heatCount: 2,
      placesPerHeat: 8,
      qualifyingPlaces: 3,
    );

    test('par partie', () {
      expect(qualificationRule(stage(QualificationMethod.byStage)), (
        kind: QualificationRuleKind.byStage,
        places: 3,
      ));
    });

    test('par course', () {
      expect(qualificationRule(stage(QualificationMethod.byHeat)), (
        kind: QualificationRuleKind.byHeat,
        places: 3,
      ));
    });

    test('sans qualification', () {
      expect(qualificationRule(stage(QualificationMethod.none)), isNull);
    });
  });
}
