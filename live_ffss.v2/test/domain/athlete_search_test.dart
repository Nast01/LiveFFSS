import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/domain/athlete_search.dart';
import 'package:live_ffss_v2/domain/event_results.dart';

Participant _p(int id, String firstName, String lastName) =>
    Participant(id: id, firstName: firstName, lastName: lastName);

void main() {
  group('foldForSearch', () {
    test('minuscules, sans accents', () {
      expect(foldForSearch('Élodie LÉGER'), 'elodie leger');
      expect(foldForSearch('Çà Ñoël'), 'ca noel');
    });
  });

  group('searchParticipants', () {
    final all = [
      _p(1, 'Élodie', 'Martin'),
      _p(2, 'Léa', 'Bernard'),
      _p(3, 'Hugo', 'Martin'),
      _p(4, 'Zoé', 'Abel'),
    ];

    List<int> ids(String query) => [
      for (final p in searchParticipants(all, query)) p.id,
    ];

    test('sans accent ni casse', () {
      expect(ids('elodie'), [1]);
      expect(ids('ÉLO'), [1]);
      expect(ids('lea'), [2]);
    });

    test('prénom nom et nom prénom', () {
      expect(ids('elodie martin'), [1]);
      expect(ids('martin elodie'), [1]);
      expect(ids('  Martin   Hugo '), [3]);
    });

    test('tri par nom puis prénom', () {
      expect(ids('martin'), [1, 3]);
      // « Zoé Abel » et « Élodie Martin » : au nom, pas à l'ordre d'arrivée.
      expect(ids('el'), [4, 1]);
    });

    test('moins de 2 caractères : vide', () {
      expect(ids(''), isEmpty);
      expect(ids(' h '), isEmpty);
      expect(ids('é'), isEmpty);
    });
  });
}
