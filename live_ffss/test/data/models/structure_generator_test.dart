import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/race_format_detail.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/domain/models/structure_generator.dart';

void main() {
  group('seriesCount', () {
    test('rounds up to fill the last série', () {
      expect(seriesCount(20, 8), 3); // 8 + 8 + 4
      expect(seriesCount(16, 8), 2);
      expect(seriesCount(17, 8), 3);
    });

    test('is zero for no entries', () {
      expect(seriesCount(0, 8), 0);
    });
  });

  group('proposeLevels', () {
    test('few enough entries → a single finale', () {
      expect(proposeLevels(entryCount: 6, spotsPerRace: 8),
          [(type: RoundType.finale, raceCount: 1)]);
    });

    test('exactly one race worth → a single finale', () {
      expect(proposeLevels(entryCount: 8, spotsPerRace: 8),
          [(type: RoundType.finale, raceCount: 1)]);
    });

    test('more than one race worth → séries then finale', () {
      expect(proposeLevels(entryCount: 20, spotsPerRace: 8), [
        (type: RoundType.serie, raceCount: 3),
        (type: RoundType.finale, raceCount: 1),
      ]);
    });

    test('no entries → an empty proposal', () {
      expect(proposeLevels(entryCount: 0, spotsPerRace: 8), isEmpty);
    });
  });

  group('buildDefaultLevels', () {
    test('allocates a unique id per race across all levels', () {
      var counter = 0;
      final levels = buildDefaultLevels(
        entryCount: 20,
        spotsPerRace: 8,
        allocateId: () => ++counter,
      );
      final ids = levels.expand((l) => l.races).map((r) => r.id).toList();
      expect(ids.toSet().length, ids.length);
      expect(ids, [1, 2, 3, 4]); // 3 séries + 1 finale
    });

    test('opt2 wires every race to all races of the previous level', () {
      var counter = 0;
      final levels = buildDefaultLevels(
        entryCount: 20,
        spotsPerRace: 8,
        allocateId: () => ++counter,
      );
      final serieIds = levels[0].races.map((r) => r.id).toList();
      final finale = levels[1].races.single;
      expect(finale.sourceRaceIds, serieIds);
    });

    test('the first level has no source races', () {
      var counter = 0;
      final levels = buildDefaultLevels(
        entryCount: 20,
        spotsPerRace: 8,
        allocateId: () => ++counter,
      );
      for (final race in levels.first.races) {
        expect(race.sourceRaceIds, isEmpty);
      }
    });

    test('no entries → no levels, allocateId never called', () {
      var calls = 0;
      final levels = buildDefaultLevels(
        entryCount: 0,
        spotsPerRace: 8,
        allocateId: () => ++calls,
      );
      expect(levels, isEmpty);
      expect(calls, 0);
    });
  });

  group('buildLevelsFromDetails', () {
    RaceFormatDetail detail({
      required int id,
      required int order,
      required String level,
      required int numberOfRun,
      required int spotsPerRace,
      int qualifyingSpots = 0,
    }) =>
        RaceFormatDetail(
          id: id,
          order: order,
          label: level,
          fullLabel: level,
          levelLabel: level,
          level: level,
          numberOfRun: numberOfRun,
          qualificationMethod: 'none',
          qualificationMethodLabel: 'N/A',
          spotsPerRace: spotsPerRace,
          qualifyingSpots: qualifyingSpots,
        );

    /// The Paddle Board Femme Minime déroulement as FFSS returns it.
    List<RaceFormatDetail> paddleBoard() => [
          detail(
              id: 32,
              order: 1,
              level: 'semi',
              numberOfRun: 2,
              spotsPerRace: 18),
          detail(
              id: 33,
              order: 2,
              level: 'final',
              numberOfRun: 1,
              spotsPerRace: 16,
              qualifyingSpots: 8),
        ];

    test('reproduces the server rounds field for field', () {
      var counter = 0;
      final levels = buildLevelsFromDetails(
        details: paddleBoard(),
        allocateId: () => ++counter,
      );

      expect(levels.map((l) => l.type), [RoundType.demi, RoundType.finale]);
      expect(levels.map((l) => l.races.length), [2, 1]);
      expect(levels.map((l) => l.spotsPerRace), [18, 16]);
      expect(levels.map((l) => l.qualifiersPerRace), [0, 8]);
    });

    test('takes the rounds in the server order, not the array order', () {
      var counter = 0;
      final levels = buildLevelsFromDetails(
        details: paddleBoard().reversed.toList(),
        allocateId: () => ++counter,
      );

      expect(levels.map((l) => l.type), [RoundType.demi, RoundType.finale]);
    });

    test('wires each round to every race of the previous one', () {
      var counter = 0;
      final levels = buildLevelsFromDetails(
        details: paddleBoard(),
        allocateId: () => ++counter,
      );

      final semiIds = levels[0].races.map((r) => r.id).toList();
      expect(levels[0].races.every((r) => r.sourceRaceIds.isEmpty), isTrue);
      expect(levels[1].races.single.sourceRaceIds, semiIds);
    });

    test('allocates a unique id per race', () {
      var counter = 0;
      final ids = buildLevelsFromDetails(
        details: paddleBoard(),
        allocateId: () => ++counter,
      ).expand((l) => l.races).map((r) => r.id).toList();

      expect(ids, [1, 2, 3]);
    });

    test('an unrecognised niveau is kept, not dropped', () {
      var counter = 0;
      final levels = buildLevelsFromDetails(
        details: [
          detail(
              id: 1,
              order: 1,
              level: 'repechage',
              numberOfRun: 1,
              spotsPerRace: 12),
        ],
        allocateId: () => ++counter,
      );

      expect(levels.single.type, RoundType.unknown);
      expect(levels.single.spotsPerRace, 12);
    });

    test('a round declaring no race still exists, empty', () {
      var counter = 0;
      final levels = buildLevelsFromDetails(
        details: [
          detail(
              id: 1, order: 1, level: 'final', numberOfRun: 0, spotsPerRace: 8),
        ],
        allocateId: () => ++counter,
      );

      expect(levels.single.races, isEmpty);
      expect(counter, 0);
    });

    test('no parties → no levels, allocateId never called', () {
      var calls = 0;
      final levels = buildLevelsFromDetails(
        details: const [],
        allocateId: () => ++calls,
      );

      expect(levels, isEmpty);
      expect(calls, 0);
    });
  });

  group('defaultsForRound', () {
    test('a quart runs 4 races qualifying 8 each', () {
      expect(defaultsForRound(RoundType.quart),
          (raceCount: 4, qualifiersPerRace: 8));
    });

    test('a demi runs 2 races qualifying 8 each', () {
      expect(defaultsForRound(RoundType.demi),
          (raceCount: 2, qualifiersPerRace: 8));
    });

    test('a finale runs a single race and qualifies nobody', () {
      expect(defaultsForRound(RoundType.finale),
          (raceCount: 1, qualifiersPerRace: 0));
    });

    test('a série has no default count — it follows the entry count', () {
      expect(defaultsForRound(RoundType.serie),
          (raceCount: 0, qualifiersPerRace: 0));
    });

    test('an unrecognised round gets nothing', () {
      expect(defaultsForRound(RoundType.unknown),
          (raceCount: 0, qualifiersPerRace: 0));
    });
  });

  group('buildLevelsFromDetails carries the qualification logic', () {
    RaceFormatDetail detail(String method) => RaceFormatDetail(
          id: 32,
          order: 1,
          label: 'Demi',
          fullLabel: 'Demi',
          levelLabel: 'Demi',
          level: 'semi',
          numberOfRun: 2,
          qualificationMethod: method,
          qualificationMethodLabel: '',
          spotsPerRace: 18,
          qualifyingSpots: 2,
        );

    test('an imported round keeps the code FFSS gave it', () {
      var next = 1;
      final levels = buildLevelsFromDetails(
        details: [detail('course')],
        allocateId: () => next++,
      );

      // Flattening this to a default would write the wrong logic back on the
      // next update.
      expect(levels.single.qualificationMethod, 'course');
    });

    test('a code this app does not know is carried, not dropped', () {
      var next = 1;
      final levels = buildLevelsFromDetails(
        details: [detail('une-logique-inventee')],
        allocateId: () => next++,
      );

      expect(levels.single.qualificationMethod, 'une-logique-inventee');
    });
  });

  group('realignServerIds', () {
    RaceFormatDetail detail(int id, String level, {int order = 1}) =>
        RaceFormatDetail(
          id: id,
          order: order,
          label: '',
          fullLabel: '',
          levelLabel: '',
          level: level,
          numberOfRun: 1,
          qualificationMethod: 'none',
          qualificationMethodLabel: '',
          spotsPerRace: 8,
          qualifyingSpots: 0,
        );

    // Un déroulement supprimé puis recréé côté FFSS laisse la structure locale
    // pointant des parties disparues. Rien ne relie plus les tours aux
    // créneaux : la vue Séries d'un second appareil reste muette, sans erreur.
    test('adopte les ids du serveur pour les tours périmés', () {
      final levels = realignServerIds(
        levels: const [
          RoundLevel(type: RoundType.serie, serverId: 39),
          RoundLevel(type: RoundType.finale, serverId: 40),
        ],
        details: [detail(63, 'heat'), detail(64, 'final', order: 2)],
      );

      expect(levels!.map((l) => l.serverId), [63, 64]);
    });

    test('rien à faire quand les ids concordent déjà', () {
      expect(
        realignServerIds(
          levels: const [RoundLevel(type: RoundType.serie, serverId: 63)],
          details: [detail(63, 'heat')],
        ),
        isNull,
      );
    });

    test('un tour jamais envoyé adopte la partie de son niveau', () {
      final levels = realignServerIds(
        levels: const [RoundLevel(type: RoundType.serie)],
        details: [detail(63, 'heat')],
      );

      expect(levels!.single.serverId, 63);
    });

    // Deux tours du même niveau se répartissent dans l'ordre, pas tous sur la
    // première partie trouvée.
    test('deux tours de même niveau prennent des parties distinctes', () {
      final levels = realignServerIds(
        levels: const [
          RoundLevel(type: RoundType.serie, serverId: 1),
          RoundLevel(type: RoundType.serie, serverId: 2),
        ],
        details: [detail(63, 'heat'), detail(64, 'heat', order: 2)],
      );

      expect(levels!.map((l) => l.serverId), [63, 64]);
    });

    // Le serveur ne déclare pas ce tour : mieux vaut le laisser sans lien que
    // de l'accrocher à la partie d'un autre niveau.
    test('un tour sans équivalent serveur perd son lien', () {
      final levels = realignServerIds(
        levels: const [
          RoundLevel(type: RoundType.serie, serverId: 39),
          RoundLevel(type: RoundType.quart, serverId: 40),
        ],
        details: [detail(63, 'heat')],
      );

      expect(levels!.map((l) => l.serverId), [63, 0]);
    });

    test('sans partie déclarée, on ne touche à rien', () {
      expect(
        realignServerIds(
          levels: const [RoundLevel(type: RoundType.serie, serverId: 39)],
          details: const [],
        ),
        isNull,
      );
    });
  });
}
