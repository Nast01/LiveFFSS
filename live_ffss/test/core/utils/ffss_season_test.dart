import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/utils/ffss_season.dart';

void main() {
  group('seasonLabel', () {
    test('1er octobre ouvre la saison de son annee', () {
      expect(seasonLabel(DateTime(2025, 10, 1)), '2025-2026');
    });

    test('30 septembre appartient encore a la saison ouverte l annee d avant',
        () {
      expect(seasonLabel(DateTime(2026, 9, 30)), '2025-2026');
    });

    test('un jour de plein hiver reste dans la saison ouverte en octobre', () {
      expect(seasonLabel(DateTime(2026, 1, 15)), '2025-2026');
    });

    test('le 1er octobre suivant fait basculer la saison', () {
      expect(seasonLabel(DateTime(2026, 10, 1)), '2026-2027');
    });
  });

  group('seasonStart', () {
    test('rend le 1er octobre d ouverture, sans heure', () {
      expect(seasonStart(DateTime(2026, 5, 20, 14, 30)), DateTime(2025, 10, 1));
    });

    test('un 1er octobre est son propre debut de saison', () {
      expect(seasonStart(DateTime(2026, 10, 1)), DateTime(2026, 10, 1));
    });

    // 30 septembre et 1er octobre encadrent la bascule : un jour d'ecart, deux
    // saisons, et c'est la seule frontiere que ce calcul porte.
    test('la veille de la bascule ouvre encore la saison precedente', () {
      expect(seasonStart(DateTime(2026, 9, 30)), DateTime(2025, 10, 1));
    });
  });
}
