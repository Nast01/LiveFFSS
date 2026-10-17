import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/data/ffss/dtos/deroulement_dto.dart';
import 'package:live_ffss_v2/data/ffss/mappers/deroulement_mapper.dart';
import 'package:live_ffss_v2/domain/gender.dart';
import 'package:live_ffss_v2/domain/progression.dart';

import '../../../support/fixtures.dart';

void main() {
  test('le 200 m obstacles Femme : séries puis trois finales', () {
    final json =
        (fixture('deroulement')['data'] as List<dynamic>)[0]
            as Map<String, dynamic>;

    final progression = DeroulementDto.fromJson(json).toDomain()!;

    expect(progression.id, 501);
    expect(progression.disciplineName, '200m Obstacles');
    expect(progression.gender, Gender.female);
    expect(progression.stages, hasLength(4));
    final heats = progression.stages[0];
    expect(heats.level, StageLevel.heats);
    expect(heats.qualification, QualificationMethod.byStage);
    expect(heats.heatCount, 10);
    expect(heats.placesPerHeat, 8);
    expect(heats.qualifyingPlaces, isNull);
    expect(progression.stages[1].name, 'Finale - Cadet');
    expect(progression.stages[1].level, StageLevel.finalStage);
    expect(progression.stageById(144)?.name, 'Finale - Junior');
    expect(progression.stageById(999), isNull);
  });

  test('le déroulement imbriqué dans un créneau se lit aussi', () {
    final data = fixture('creneau_177')['data'] as Map<String, dynamic>;
    final partie = data['partie'] as Map<String, dynamic>;

    final progression = DeroulementDto.fromJson(
      partie['deroulement'] as Map<String, dynamic>,
    ).toDomain()!;

    expect(progression.disciplineName, '200m Obstacles');
    expect(progression.gender, Gender.female);
    expect(progression.stages, hasLength(4));
  });

  test('une partie sans id est écartée, pas le déroulement', () {
    final progression = DeroulementDto.fromJson({
      'Id': 1,
      'parties': [
        {'ordre': 1, 'niveau': 'heat'},
        {'id': 2, 'ordre': 2, 'niveau': 'final'},
      ],
    }).toDomain()!;

    expect(progression.stages.map((s) => s.id), [2]);
  });

  test('un déroulement sans id est écarté', () {
    expect(DeroulementDto.fromJson({'label': 'x'}).toDomain(), isNull);
  });

  test('étapes triées par ordre même servies dans le désordre', () {
    final progression = DeroulementDto.fromJson({
      'Id': 1,
      'parties': [
        {'id': 12, 'ordre': 2, 'niveau': 'final'},
        {'id': 11, 'ordre': 1, 'niveau': 'heat'},
      ],
    }).toDomain()!;

    expect(progression.stages.map((s) => s.id), [11, 12]);
  });
}
