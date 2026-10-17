import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/domain/lane_assignment.dart';
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
    test('première colonne puis les finales suivantes', () {
      final p = Progression(
        id: 1,
        name: 'p',
        stages: [
          stage(1, StageLevel.heats, name: 'Séries', heatCount: 10),
          stage(2, StageLevel.finalStage),
          stage(3, StageLevel.finalStage),
          stage(4, StageLevel.finalStage),
        ],
      );
      expect(collapsedProgression(p, l10n), 'Séries 10 × 8 › 3 finales');
    });

    test('une seule finale suivante', () {
      final p = Progression(
        id: 1,
        name: 'p',
        stages: [
          stage(1, StageLevel.heats, name: 'Séries', heatCount: 4),
          stage(2, StageLevel.finalStage),
        ],
      );
      expect(collapsedProgression(p, l10n), 'Séries 4 × 8 › 1 finale');
    });

    test('étapes qui ne sont pas toutes des finales', () {
      final p = Progression(
        id: 1,
        name: 'p',
        stages: [
          stage(1, StageLevel.heats, name: 'Séries', heatCount: 4),
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
        stages: [stage(1, StageLevel.finalStage, name: 'Finale')],
      );
      expect(collapsedProgression(p, l10n), 'Finale 1 × 8');
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
}
