import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/network/http_client.dart';
import 'package:live_ffss_v2/data/repositories/officials_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/fixtures.dart';

class _MockHttpClient extends Mock implements HttpClient {}

void main() {
  late _MockHttpClient http;
  late OfficialsRepositoryImpl repository;

  setUp(() {
    http = _MockHttpClient();
    repository = OfficialsRepositoryImpl(http);
  });

  test('lit les 60 officiels de la fixture de la recette', () async {
    when(
      () => http.get('competition/evenement/1416/officiels'),
    ).thenAnswer((_) async => fixture('officiels_1416'));

    final officials = await repository.getOfficials(1416);

    expect(officials, hasLength(60));
    expect(officials.where((o) => o.principal), hasLength(1));
    expect(officials.map((o) => o.level).toSet(), {'A', 'B', 'C'});
    final first = officials.first;
    expect(first.id, 20568);
    expect(first.name, 'OFFICIEL O001');
    expect(first.days, [3]);
    expect(first.daysLabel, 'Jour 3');
    expect(first.club, 'TOULON METROPOLE SAUVETAGE SECOURISME');
  });

  test('une ligne illisible est écartée seule', () async {
    when(() => http.get('competition/evenement/1416/officiels')).thenAnswer(
      (_) async => {
        'data': [
          {'Id': 1, 'Nom': 'A', 'Prenom': 'a', 'Niveau': 'B'},
          {'Id': 2, 'Nom': 123},
          'pas un objet',
          {'Nom': 'Sans id', 'Niveau': 'B'},
          {'Id': '3', 'Nom': 'C', 'Prenom': 'c', 'Niveau': 'C', 'Jours': 'x'},
        ],
      },
    );

    final officials = await repository.getOfficials(1416);

    expect(officials.map((o) => o.id), [1, 3]);
    expect(officials.last.days, isEmpty);
  });
}
