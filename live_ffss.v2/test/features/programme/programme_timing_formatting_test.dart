import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/features/programme/programme_formatting.dart';

void main() {
  final fr = lookupAppLocalizations(const Locale('fr'));

  group('durationLabel', () {
    test('moins d\'une heure : en minutes', () {
      expect(durationLabel(const Duration(minutes: 40), fr), '≈ 40 min');
      expect(durationLabel(const Duration(minutes: 5), fr), '≈ 5 min');
    });

    test('une heure ou plus : heures et minutes sur deux chiffres', () {
      expect(durationLabel(const Duration(minutes: 75), fr), '≈ 1 h 15');
      expect(durationLabel(const Duration(minutes: 125), fr), '≈ 2 h 05');
    });

    test('heures pleines : sans minutes', () {
      expect(durationLabel(const Duration(hours: 1), fr), '≈ 1 h');
    });
  });

  test('endTimeLabel : la fin précédée d\'une flèche, vide sans fin', () {
    expect(endTimeLabel(DateTime(2026, 3, 27, 8, 40)), '→ 08:40');
    expect(endTimeLabel(null), '');
  });

  test('meetingSummaryLabel : créneaux et épreuves, au pluriel ou non', () {
    expect(
      meetingSummaryLabel((items: 33, events: 28), fr),
      '33 créneaux · 28 épreuves',
    );
    expect(
      meetingSummaryLabel((items: 1, events: 1), fr),
      '1 créneau · 1 épreuve',
    );
    expect(meetingSummaryLabel((items: 2, events: 0), fr), '2 créneaux');
  });
}
