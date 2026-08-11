import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/translations/app_translations.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/presentation/modules/programme/programme_formatting.dart';

void main() {
  setUpAll(() {
    // structureTitle translates the gender, so a locale must be active.
    Get.addTranslations(AppTranslations().keys);
    Get.updateLocale(const Locale('fr', 'FR'));
  });

  group('structureTitle', () {
    test('reads discipline · gender · category', () {
      expect(
        structureTitle(
          raceLabel: 'Nage',
          gender: Gender.male,
          categoryLabel: 'Minime',
        ),
        'Nage · Messieurs · Minime',
      );
    });

    test('each gender gets its own wording', () {
      expect(
        structureTitle(
            raceLabel: 'Nage', gender: Gender.female, categoryLabel: 'Minime'),
        'Nage · Dames · Minime',
      );
      expect(
        structureTitle(
            raceLabel: 'Nage', gender: Gender.mixed, categoryLabel: 'Minime'),
        'Nage · Mixte · Minime',
      );
    });

    test('an unknown gender is left out rather than guessed', () {
      // The editor defaults to unknown when opened without a gender; printing
      // "Messieurs" there would state something the caller never said.
      expect(
        structureTitle(
            raceLabel: 'Nage', gender: Gender.unknown, categoryLabel: 'Minime'),
        'Nage · Minime',
      );
    });

    test('empty parts do not leave dangling separators', () {
      expect(
        structureTitle(
            raceLabel: 'Nage', gender: Gender.male, categoryLabel: ''),
        'Nage · Messieurs',
      );
      expect(
        structureTitle(
            raceLabel: '', gender: Gender.unknown, categoryLabel: ''),
        '',
      );
    });
  });

  group('chainSummary', () {
    EventStructure structure(List<RoundLevel> levels) => EventStructure(
          raceId: 1,
          categoryId: 7,
          raceLabel: 'Nage',
          categoryLabel: 'Minime',
          levels: levels,
        );

    test('reads the whole chain, round by round', () {
      final s = structure(const [
        RoundLevel(
          type: RoundType.serie,
          spotsPerRace: 8,
          qualifiersPerRace: 4,
          races: [
            ProgrammeRace(id: 1, number: 1),
            ProgrammeRace(id: 2, number: 2),
            ProgrammeRace(id: 3, number: 3),
          ],
        ),
        RoundLevel(
          type: RoundType.finale,
          spotsPerRace: 8,
          races: [ProgrammeRace(id: 4, number: 1)],
        ),
      ]);

      expect(s.chainSummary, '3 séries ×8 (4 qual.) → 1 finale ×8');
    });

    test('a round with no size of its own falls back to the default', () {
      final s = structure(const [
        RoundLevel(
          type: RoundType.finale,
          races: [ProgrammeRace(id: 1, number: 1)],
        ),
      ]).copyWith(spotsPerRace: 16);

      expect(s.chainSummary, '1 finale ×16');
    });

    test('a structure with no round reads empty', () {
      expect(structure(const []).chainSummary, '');
    });
  });
}
