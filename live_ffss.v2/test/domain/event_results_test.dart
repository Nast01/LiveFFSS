import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/data/ffss/dtos/deroulement_dto.dart';
import 'package:live_ffss_v2/data/ffss/mappers/deroulement_mapper.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/gender.dart';

import '../support/fixtures.dart';

CompetitionEvent event(int id, Gender gender, String category) =>
    CompetitionEvent(
      id: id,
      disciplineId: 24,
      disciplineName: '200m Obstacles',
      gender: gender,
      categoryId: 1,
      categoryName: category,
      teamSize: 1,
    );

void main() {
  final progressions = [
    for (final row in fixture('deroulement')['data'] as List<dynamic>)
      ?DeroulementDto.fromJson(row as Map<String, dynamic>).toDomain(),
  ];

  test(
    'une épreuve est reliée au déroulement de sa discipline et de son genre',
    () {
      expect(
        progressionOfEvent(
          progressions,
          event(36073, Gender.female, 'Cadet'),
        )?.id,
        501,
      );
      expect(
        progressionOfEvent(
          progressions,
          event(36074, Gender.female, 'Junior'),
        )?.id,
        501,
      );
    },
  );

  test('catégorie absente ou autre genre : aucun déroulement', () {
    expect(
      progressionOfEvent(progressions, event(1, Gender.female, 'Youth')),
      isNull,
    );
    expect(
      progressionOfEvent(progressions, event(2, Gender.male, 'Cadet')),
      isNull,
    );
  });

  test('un relais se reconnaît à sa taille d\'équipe', () {
    expect(event(1, Gender.male, 'Open').isRelay, isFalse);
    expect(event(1, Gender.male, 'Open').copyWith(teamSize: 4).isRelay, isTrue);
  });
}
