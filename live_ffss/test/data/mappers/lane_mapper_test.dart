import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/dtos/lane_dto.dart';
import 'package:live_ffss/app/data/mappers/lane_mapper.dart';

void main() {
  // Payload relevé en production le 2026-09-01 (compétition 1451, course 20).
  // La documentation fédérale annonce `Place.Id`, `Place.Engagement`,
  // `Place.Resultat` et un `Numero` de type String : les quatre sont faux.
  test('une place telle que FFSS la renvoie vraiment', () {
    final lane = LaneDto.fromJson(const {
      'id': 6,
      'Numero': 1,
      'label': 'Place 1',
      'fullLabel': 'Place 1 - Place 1',
      'engagement': null,
      'resultat': null,
      'athletes': null,
    }).toDomain();

    expect(lane.id, 6);
    expect(lane.number, 1);
    expect(lane.label, 'Place 1');
    expect(lane.entry, isNull);
    expect(lane.result, isNull);
  });

  // Dans l'arbre `reunion`, `athletes` vaut `null` ; sur le point de terminaison
  // de détail, c'est `[]`. Ni l'un ni l'autre ne doit faire tomber le parsing.
  test('une place sans athlète ni engagement se lit sans erreur', () {
    expect(
      () => LaneDto.fromJson(const {'id': 5, 'Numero': 1}).toDomain(),
      returnsNormally,
    );
  });

  test('un numéro absent retombe sur zéro plutôt que de faire tomber la liste',
      () {
    expect(LaneDto.fromJson(const {'id': 5}).toDomain().number, 0);
  });
}
