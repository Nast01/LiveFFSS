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

  group('heatName', () {
    // Le niveau seul quand il n'y a rien à distinguer, le rang dès qu'il y a
    // plusieurs courses : « Série 2 » ne veut rien dire s'il n'y en a qu'une.
    test('un tour à une seule course porte le niveau nu', () {
      expect(heatName(RoundType.serie, 0, 1), 'Série');
      expect(heatName(RoundType.demi, 0, 1), 'Demie');
      expect(heatName(RoundType.quart, 0, 1), 'Quart');
    });

    test('plusieurs courses sont numérotées à partir de 1', () {
      expect(heatName(RoundType.serie, 0, 3), 'Série 1');
      expect(heatName(RoundType.serie, 2, 3), 'Série 3');
      expect(heatName(RoundType.demi, 1, 2), 'Demie 2');
    });

    // Les finales se lisent en lettres, et la lettre reste même seule : une
    // « Finale A » annonce qu'une B peut exister, ce que « Finale » tait.
    test('une finale porte une lettre, même unique', () {
      expect(heatName(RoundType.finale, 0, 1), 'Finale A');
      expect(heatName(RoundType.finale, 0, 2), 'Finale A');
      expect(heatName(RoundType.finale, 1, 2), 'Finale B');
      expect(heatName(RoundType.finale, 2, 3), 'Finale C');
    });

    // Au-delà de Z on repart sur un rang chiffré plutôt que d'inventer AA :
    // aucune compétition ne court 27 finales, mais rien ne doit sortir vide.
    test('au-delà de la vingt-sixième finale, le rang reprend la main', () {
      expect(heatName(RoundType.finale, 25, 30), 'Finale Z');
      expect(heatName(RoundType.finale, 26, 30), 'Finale 27');
    });

    test('un niveau inconnu reste nommable', () {
      expect(heatName(RoundType.unknown, 0, 2), 'Tour 1');
    });
  });
}
