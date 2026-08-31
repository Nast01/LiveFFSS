import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/dtos/run_dto.dart';
import 'package:live_ffss/app/data/mappers/run_mapper.dart';
import 'package:live_ffss/app/domain/models/run.dart';

void main() {
  test('RunMapper parses begin/end times and status int', () {
    final dto = RunDto.fromJson(const {
      'id': 1,
      'Nom': 'Run 1',
      'label': 'L',
      'fullLabel': 'FL',
      'statut': 2,
      'statutLabel': 'In Progress',
      'site': 'Pool A',
      'debut': '10:00',
      'fin': '11:30',
    });
    final r = dto.toDomain();
    expect(r.id, 1);
    expect(r.status, RunStatus.inProgress);
    expect(r.beginTime.hour, 10);
    expect(r.endTime.hour, 11);
  });

  test('RunMapper handles unknown status code', () {
    final dto = RunDto.fromJson(const {
      'id': 1,
      'Nom': 'X',
      'label': 'X',
      'fullLabel': 'X',
      'statut': 99,
      'statutLabel': '',
      'site': '',
      'debut': '00:00',
      'fin': '00:00',
    });
    expect(dto.toDomain().status, RunStatus.unknown);
  });

  // FFSS construit le `fullLabel` d'une course en collant le libellé à
  // lui-même — payload réel, compétition 1451, course 20 :
  //   label     "Demie 1 - Surfski - Messieurs - Junior"
  //   fullLabel "Demie 1 - Surfski - Messieurs - Junior - Demie 1 - Surfski…"
  // Affiché tel quel, le nom de la course apparaît deux fois à l'écran.
  test('un fullLabel collé à lui-même retombe sur le libellé simple', () {
    final dto = RunDto.fromJson(const {
      'id': 20,
      'Nom': 'Demie 1 - Surfski - Messieurs - Junior',
      'label': 'Demie 1 - Surfski - Messieurs - Junior',
      'fullLabel': 'Demie 1 - Surfski - Messieurs - Junior - '
          'Demie 1 - Surfski - Messieurs - Junior',
      'statut': 0,
      'statutLabel': 'En attente',
      'site': 'OCEAN 1',
      'debut': '08:00',
      'fin': '08:10',
    });

    expect(dto.toDomain().fullLabel, 'Demie 1 - Surfski - Messieurs - Junior');
  });

  // Une partie porte un vrai fullLabel enrichi (« Surfski - Homme - Demi-finale
  // - Junior ») : seul le doublon exact doit être réduit.
  test('un fullLabel qui apporte du contexte est conservé', () {
    final dto = RunDto.fromJson(const {
      'id': 1,
      'Nom': 'Demie 1',
      'label': 'Demie 1',
      'fullLabel': 'Surfski - Homme - Demie 1',
      'statut': 0,
      'statutLabel': '',
      'site': '',
      'debut': '08:00',
      'fin': '08:10',
    });

    expect(dto.toDomain().fullLabel, 'Surfski - Homme - Demie 1');
  });

  // Payload réel d'une course (compétition 1451, course 20) : ses places
  // arrivent sous `places`, imbriquées dans la course elle-même. Rien à
  // aller chercher ailleurs quand la course vient du site.
  test('les places de la course deviennent ses couloirs', () {
    final run = RunDto.fromJson(const {
      'id': 20,
      'Nom': 'Demie 1',
      'label': 'Demie 1',
      'fullLabel': 'Demie 1',
      'statut': 0,
      'statutLabel': 'En attente',
      'site': 'OCEAN 1',
      'debut': '08:00',
      'fin': '08:10',
      'places': [
        {'id': 6, 'Numero': 1, 'label': 'Place 1'},
        {'id': 7, 'Numero': 2, 'label': 'Place 2'},
      ],
    }).toDomain();

    expect(run.lanes.map((l) => l.number), [1, 2]);
    expect(run.lanes.first.id, 6);
    expect(run.lanes.first.label, 'Place 1');
  });

  test('une course sans place a une liste vide, pas une erreur', () {
    final run = RunDto.fromJson(const {
      'id': 21,
      'Nom': 'Demie 2',
      'label': '',
      'fullLabel': '',
      'statut': 0,
      'statutLabel': '',
      'site': '',
      'debut': '08:10',
      'fin': '08:20',
    }).toDomain();

    expect(run.lanes, isEmpty);
  });
}
