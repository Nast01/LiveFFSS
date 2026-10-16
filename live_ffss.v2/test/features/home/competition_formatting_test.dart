import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:live_ffss_v2/features/home/competition_formatting.dart';

import '../../support/competitions.dart';

void main() {
  setUpAll(() => initializeDateFormatting('fr'));

  group('dateRangeLabel', () {
    test('un seul jour', () {
      expect(
        competition(1, start: DateTime(2026, 3, 27)).dateRangeLabel('fr'),
        '27 mars 2026',
      );
    });

    test('même mois', () {
      expect(
        competition(
          1,
          start: DateTime(2026, 3, 27),
          end: DateTime(2026, 3, 29),
        ).dateRangeLabel('fr'),
        '27 – 29 mars 2026',
      );
    });

    test('deux mois de la même année', () {
      expect(
        competition(
          1,
          start: DateTime(2026, 3, 30),
          end: DateTime(2026, 4, 2),
        ).dateRangeLabel('fr'),
        '30 mars – 2 avr. 2026',
      );
    });

    test('à cheval sur deux années', () {
      expect(
        competition(
          1,
          start: DateTime(2026, 12, 30),
          end: DateTime(2027, 1, 2),
        ).dateRangeLabel('fr'),
        '30 déc. 2026 – 2 janv. 2027',
      );
    });
  });

  group('dayOfCompetition', () {
    final c = competition(
      1,
      start: DateTime(2026, 3, 27),
      end: DateTime(2026, 3, 29),
    );

    test('pendant la compétition : jour courant et nombre de jours', () {
      expect(c.dayOfCompetition(DateTime(2026, 3, 27, 18)), (
        current: 1,
        total: 3,
      ));
      expect(c.dayOfCompetition(DateTime(2026, 3, 29, 8)), (
        current: 3,
        total: 3,
      ));
    });

    test('hors de la compétition ou compétition d\'un jour : rien', () {
      expect(c.dayOfCompetition(DateTime(2026, 3, 30)), isNull);
      expect(
        competition(
          2,
          start: DateTime(2026, 3, 27),
        ).dayOfCompetition(DateTime(2026, 3, 27)),
        isNull,
      );
    });
  });

  test('libellés de la case date d\'une ligne', () {
    expect(shortDayLabel(DateTime(2026, 10, 18)), '18');
    expect(monthLabel(DateTime(2026, 10, 18), 'fr'), 'OCT.');
  });
}
