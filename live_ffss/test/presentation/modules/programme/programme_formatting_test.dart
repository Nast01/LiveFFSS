import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/translations/app_translations.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
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
}
