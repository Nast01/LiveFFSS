import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/data/ffss/dtos/place_dto.dart';
import 'package:live_ffss_v2/data/ffss/mappers/place_mapper.dart';

import '../../../support/fixtures.dart';

void main() {
  test('une place du 200 m obstacles : couloir, athlète, temps et rang', () {
    final json = fixture('place_2816')['data'] as Map<String, dynamic>;

    final place = PlaceDto.fromJson(json).toDomain()!;

    expect(place.id, 2816);
    expect(place.lane, 2);
    expect(place.athletes, ['ATHLETE Un']);
    expect(place.club, 'Biscarrosse Olympique Sauvetage et Secourisme');
    expect(place.category, 'Cadet');
    expect(place.isRelay, false);
    expect(place.forfeit, false);
    expect(place.isEmpty, false);
    expect(place.performance!.time, '02\'55"77');
    expect(place.performance!.timeHundredths, 17577);
    expect(place.performance!.isOk, true);
  });

  test('une place porte les ids du résultat et de l\'engagement', () {
    final json = fixture('place_2816')['data'] as Map<String, dynamic>;

    final place = PlaceDto.fromJson(json).toDomain()!;

    expect(place.resultId, 572548);
    expect(place.entryId, 566311);
  });

  test('une place sans engagement est vide, sans performance', () {
    final place = PlaceDto.fromJson({
      'id': 1,
      'Numero': 3,
      'engagement': null,
      'resultat': null,
    }).toDomain()!;

    expect(place.lane, 3);
    expect(place.isEmpty, true);
    expect(place.performance, isNull);
  });

  test('engagement servi en [] par PHP : place vide, pas d\'erreur', () {
    final place = PlaceDto.fromJson({
      'id': 1,
      'Numero': 3,
      'engagement': <dynamic>[],
      'resultat': <dynamic>[],
    }).toDomain()!;

    expect(place.isEmpty, true);
    expect(place.performance, isNull);
  });

  test('une place sans id ni numéro est écartée', () {
    expect(PlaceDto.fromJson({'label': 'x'}).toDomain(), isNull);
  });

  test('un résultat DQ', () {
    final place = PlaceDto.fromJson({
      'id': 1,
      'Numero': 4,
      'resultat': {'statutLabel': 'DQ', 'isDisqualifie': true},
    }).toDomain()!;

    expect(place.performance!.time, isNull);
    expect(place.performance!.isOk, false);
    expect(place.performance!.isDisqualified, true);
  });

  test(
    'une DQ : FFSS sert son code dans rangLabel (place 2903 de la recette)',
    () {
      final place = PlaceDto.fromJson({
        'id': 2903,
        'Numero': 5,
        'resultat': {
          'statutLabel': 'DQ',
          'tempsLabel': '',
          'rangLabel': '12',
          'performanceLabel': '12 - ',
          'isDisqualifie': true,
          'disqualificationCode': null,
        },
      }).toDomain()!;

      expect(place.performance!.disqualificationCode, '12');
    },
  );

  test("disqualificationCode, quand FFSS le sert, l'emporte", () {
    final place = PlaceDto.fromJson({
      'id': 1,
      'Numero': 4,
      'resultat': {
        'statutLabel': 'DQ',
        'rangLabel': '12',
        'isDisqualifie': true,
        'disqualificationCode': 'P7',
      },
    }).toDomain()!;

    expect(place.performance!.disqualificationCode, 'P7');
  });

  test("hors DQ, rangLabel n'est pas un code", () {
    final place = PlaceDto.fromJson({
      'id': 1,
      'Numero': 4,
      'resultat': {
        'statutLabel': 'OK',
        'tempsLabel': '02\'55"77',
        'rangLabel': '5ème',
      },
    }).toDomain()!;

    expect(place.performance!.disqualificationCode, isNull);
  });
}
