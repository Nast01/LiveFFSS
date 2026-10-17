import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/domain/lane_assignment.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/progression.dart';
import 'package:live_ffss_v2/features/programme/programme_formatting.dart';

Stage stage(
  int id,
  StageLevel level, {
  String name = 'Étape',
  QualificationMethod qualification = QualificationMethod.none,
  int heatCount = 1,
  int placesPerHeat = 8,
  int? qualifyingPlaces,
}) => Stage(
  id: id,
  order: id,
  level: level,
  name: name,
  qualification: qualification,
  heatCount: heatCount,
  placesPerHeat: placesPerHeat,
  qualifyingPlaces: qualifyingPlaces,
);

void main() {
  final l10n = lookupAppLocalizations(const Locale('fr'));
  setUpAll(() => initializeDateFormatting('fr'));

  test('ItemStatus.label', () {
    expect(ItemStatus.live.label(l10n), 'EN DIRECT');
    expect(ItemStatus.finished.label(l10n), 'Terminé');
    expect(ItemStatus.seriesPending.label(l10n), 'Séries à venir');
    expect(ItemStatus.upcoming.label(l10n), 'À venir');
    expect(ItemStatus.none.label(l10n), '');
  });

  test('stageFormat', () {
    expect(stageFormat(stage(1, StageLevel.heats, heatCount: 10)), '10 × 8');
  });

  group('qualificationText', () {
    test('par étape', () {
      final s = stage(
        1,
        StageLevel.heats,
        qualification: QualificationMethod.byStage,
      );
      expect(
        qualificationText(s, l10n),
        'Classement au temps, toutes séries confondues',
      );
    });

    test('par course avec places', () {
      final s = stage(
        1,
        StageLevel.heats,
        qualification: QualificationMethod.byHeat,
        qualifyingPlaces: 2,
      );
      expect(qualificationText(s, l10n), 'Les 2 premiers de chaque série');
    });

    test('par course sans places', () {
      final s = stage(
        1,
        StageLevel.heats,
        qualification: QualificationMethod.byHeat,
      );
      expect(qualificationText(s, l10n), 'Qualification par série');
    });

    test('aucune qualification', () {
      expect(qualificationText(stage(1, StageLevel.heats), l10n), isNull);
    });
  });

  group('collapsedProgression', () {
    const heatsName = 'Série - Cadet, Junior, Seniors et Masters';

    test('noms réels : le niveau, pas le nom publié', () {
      final p = Progression(
        id: 1,
        name: 'p',
        stages: [
          stage(1, StageLevel.heats, name: heatsName, heatCount: 14),
          stage(2, StageLevel.finalStage, name: 'Finale - Cadet'),
          stage(3, StageLevel.finalStage, name: 'Finale - Junior'),
          stage(4, StageLevel.finalStage, name: 'Finale - Seniors'),
        ],
      );
      expect(collapsedProgression(p, l10n), 'Séries 14 × 8 › 3 finales');
    });

    test('première colonne de deux étapes : séries additionnées', () {
      final p = Progression(
        id: 1,
        name: 'p',
        stages: [
          stage(1, StageLevel.heats, name: heatsName, heatCount: 10),
          stage(2, StageLevel.heats, name: 'Série - Minimes', heatCount: 4),
          stage(3, StageLevel.finalStage),
          stage(4, StageLevel.finalStage),
        ],
      );
      expect(collapsedProgression(p, l10n), 'Séries 14 × 8 › 2 finales');
    });

    test('une seule finale suivante', () {
      final p = Progression(
        id: 1,
        name: 'p',
        stages: [
          stage(1, StageLevel.heats, heatCount: 4),
          stage(2, StageLevel.finalStage),
        ],
      );
      expect(collapsedProgression(p, l10n), 'Séries 4 × 8 › 1 finale');
    });

    test('une seule étape suivante qui n est pas une finale', () {
      final p = Progression(
        id: 1,
        name: 'p',
        stages: [
          stage(1, StageLevel.heats, heatCount: 4),
          stage(2, StageLevel.semiFinal),
        ],
      );
      expect(collapsedProgression(p, l10n), 'Séries 4 × 8 › 1 étape');
    });

    test('étapes qui ne sont pas toutes des finales', () {
      final p = Progression(
        id: 1,
        name: 'p',
        stages: [
          stage(1, StageLevel.heats, heatCount: 4),
          stage(2, StageLevel.semiFinal),
          stage(3, StageLevel.finalStage),
        ],
      );
      expect(collapsedProgression(p, l10n), 'Séries 4 × 8 › 2 étapes');
    });

    test('une seule étape', () {
      final p = Progression(
        id: 1,
        name: 'p',
        stages: [stage(1, StageLevel.finalStage, name: 'Finale - Cadet')],
      );
      expect(collapsedProgression(p, l10n), 'Finale 1 × 8');
    });

    test('sans étape', () {
      expect(
        collapsedProgression(const Progression(id: 1, name: 'p'), l10n),
        '',
      );
    });
  });

  group('rankText', () {
    LaneAssignment lane({String? category, String? rank}) => LaneAssignment(
      id: 1,
      lane: 1,
      category: category,
      performance: rank == null ? null : Performance(rankLabel: rank),
    );

    test('rang et catégorie', () {
      expect(rankText(lane(rank: '1er', category: 'Cadet')), '1er · Cadet');
    });

    test('rang seul', () {
      expect(rankText(lane(rank: '1er')), '1er');
      expect(rankText(lane(rank: '1er', category: '')), '1er');
    });

    test('sans rang', () {
      expect(rankText(lane(category: 'Cadet')), isNull);
      expect(rankText(lane(rank: '')), isNull);
    });
  });

  group('opensStage', () {
    final heats = stage(1, StageLevel.heats);
    final finalA = stage(2, StageLevel.finalStage);
    final finalB = stage(3, StageLevel.finalStage);
    final meetings = [
      Meeting(
        id: 1,
        name: 'R1',
        day: DateTime(2026, 3, 27),
        items: const [
          MeetingItem(id: 10, name: 'Séries', roundId: 1),
          MeetingItem(id: 11, name: 'Finale A', roundId: 2),
        ],
      ),
    ];

    test('une étape avec un créneau au programme se touche', () {
      expect(opensStage(meetings, finalA, current: heats), isTrue);
    });

    test('une étape sans créneau, ou celle déjà ouverte, non', () {
      expect(opensStage(meetings, finalB, current: heats), isFalse);
      expect(opensStage(meetings, heats, current: heats), isFalse);
    });

    test('programme pas encore chargé : rien ne se touche', () {
      expect(opensStage(null, finalA, current: heats), isFalse);
    });
  });

  group('performanceText', () {
    String? text(Performance? performance, {bool forfeit = false}) =>
        performanceText(
          LaneAssignment(
            id: 1,
            lane: 1,
            forfeit: forfeit,
            performance: performance,
          ),
          l10n,
        );

    test('le temps quand le statut est OK ou absent', () {
      expect(text(const Performance(time: '0:42.10')), '0:42.10');
      expect(
        text(const Performance(time: '0:42.10', statusLabel: 'OK')),
        '0:42.10',
      );
    });

    test('le statut publié sinon', () {
      expect(
        text(const Performance(time: '0:42.10', statusLabel: 'DSQ')),
        'DSQ',
      );
    });

    test('rien sans performance ni temps', () {
      expect(text(null), isNull);
      expect(text(const Performance()), isNull);
      expect(text(const Performance(time: ' ')), isNull);
    });

    test('forfait sans résultat publié : « Forfait »', () {
      expect(text(null, forfeit: true), 'Forfait');
      expect(text(const Performance(), forfeit: true), 'Forfait');
    });

    test('forfait avec un résultat publié : le résultat', () {
      expect(text(const Performance(statusLabel: 'DNS'), forfeit: true), 'DNS');
    });
  });

  test('itemBreadcrumb', () {
    final meeting = Meeting(
      id: 1,
      name: 'Réunion 2 - Finales',
      day: DateTime(2026, 3, 28),
    );
    expect(
      itemBreadcrumb(meeting, l10n, 'fr'),
      'Programme · sam. 28 · Réunion 2 - Finales',
    );
  });

  test('timeRangeLabel', () {
    expect(
      timeRangeLabel(
        DateTime(2026, 3, 27, 6, 45),
        DateTime(2026, 3, 27, 13, 45),
      ),
      '06:45 – 13:45',
    );
    expect(timeRangeLabel(DateTime(2026, 3, 27, 6, 45), null), '06:45');
    expect(timeRangeLabel(null, null), '');
  });
}
