import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/dtos/lane_detail_dto.dart';
import 'package:live_ffss/app/data/mappers/lane_detail_mapper.dart';

void main() {
  // Payload relevé en production le 2026-09-03 (place 287, compétition 1451) :
  // contrairement à l'arbre `reunion` qui masque l'engagement, la route de
  // détail le renvoie — clés minuscules, qui ne sont PAS celles d'EntryDto.
  test('une place occupée livre son engagement et ses athlètes', () {
    final seat = LaneDetailDto.fromJson(const {
      'id': 287,
      'Numero': 1,
      'label': 'Place 1',
      'fullLabel': 'Place 1 - Place 1',
      'engagement': {
        'id': 590956,
        'label': 'COULAIS Clémentine / 90m Sprint Femme (Cadet)',
        'statut': 1,
        'statutLabel': 'Engagé',
        'clubLabel': 'BIDART OCEAN',
        'isForfait': false,
        'athletes': [
          {
            'Id': 661534,
            'idLicencie': 656346,
            'isLicencie': true,
            'idInvite': null,
            'isInvite': false,
            'label': 'COULAIS Clémentine',
            'clubLabel': 'BIDART OCEAN',
          },
        ],
      },
      'resultat': null,
      'athletes': [],
      'remplacants': [],
    }).toSeat();

    expect(seat, isNotNull);
    expect(seat!.laneId, 287);
    expect(seat.number, 1);
    expect(seat.entryId, 590956);
    expect(seat.athleteIds, [661534]);
  });

  // Une place par défaut n'assoit personne : elle ne fait pas un siège.
  test('une place libre ne produit aucun siège', () {
    final seat = LaneDetailDto.fromJson(const {
      'id': 288,
      'Numero': 2,
      'engagement': null,
    }).toSeat();

    expect(seat, isNull);
  });

  // L'arbre `reunion` sert `athletes: null` là où le détail sert `[]` : aucune
  // des deux formes ne doit faire tomber le parsing.
  test('un engagement sans athlètes se lit sans erreur', () {
    final seat = LaneDetailDto.fromJson(const {
      'id': 289,
      'Numero': 3,
      'engagement': {'id': 591040, 'athletes': null},
    }).toSeat();

    expect(seat!.entryId, 591040);
    expect(seat.athleteIds, isEmpty);
  });
}
