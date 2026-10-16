import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/data/ffss/dtos/evenement_dto.dart';
import 'package:live_ffss_v2/data/ffss/mappers/evenement_mapper.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/domain/discipline.dart';

CompetitionSummary? map(Map<String, dynamic> json) =>
    EvenementDto.fromJson(json).toDomain();

Map<String, dynamic> evenement([Map<String, dynamic> overrides = const {}]) => {
  'Id': 1453,
  'Nom': 'Championnats de France N1 2026',
  'Debut': '2026-03-27',
  'Fin': '2026-03-29',
  'Specialite': 2,
  'specialiteLabel': 'Eau plate',
  'Lieu': 'Montpellier',
  'Organisme': {'NomOrga': 'FFSS', 'label': 'Fédération'},
  ...overrides,
};

void main() {
  test('une compétition complète', () {
    expect(
      map(evenement()),
      CompetitionSummary(
        id: 1453,
        name: 'Championnats de France N1 2026',
        startDate: DateTime(2026, 3, 27),
        endDate: DateTime(2026, 3, 29),
        disciplines: const {Discipline.flatWater},
        organizer: 'FFSS',
        location: 'Montpellier',
      ),
    );
  });

  group('spécialité (règle de ParseEventDisciplines dans V3)', () {
    test('1 côtier, 2 eau plate, 3 mixte', () {
      expect(map(evenement({'Specialite': 1}))?.disciplines, {
        Discipline.coastal,
      });
      expect(map(evenement({'Specialite': 2}))?.disciplines, {
        Discipline.flatWater,
      });
      expect(map(evenement({'Specialite': 3}))?.disciplines, {
        Discipline.flatWater,
        Discipline.coastal,
      });
    });

    test('servie en chaîne', () {
      expect(map(evenement({'Specialite': '1'}))?.disciplines, {
        Discipline.coastal,
      });
    });

    test('sans code, le libellé fait foi', () {
      expect(
        map(
          evenement({'Specialite': null, 'specialiteLabel': 'Côtier'}),
        )?.disciplines,
        {Discipline.coastal},
      );
      expect(
        map(
          evenement({'Specialite': null, 'specialiteLabel': 'Mixte'}),
        )?.disciplines,
        {Discipline.flatWater, Discipline.coastal},
      );
      expect(
        map(
          evenement({'Specialite': null, 'specialiteLabel': null}),
        )?.disciplines,
        {Discipline.flatWater},
      );
    });
  });

  group('dates', () {
    test('fin absente : la compétition dure un jour', () {
      expect(map(evenement({'Fin': null}))?.endDate, DateTime(2026, 3, 27));
    });

    test('fin antérieure au début : ramenée au début, comme V3', () {
      expect(
        map(evenement({'Fin': '2026-03-20'}))?.endDate,
        DateTime(2026, 3, 27),
      );
    });

    test('début absent ou illisible : écartée', () {
      expect(map(evenement({'Debut': null})), isNull);
      expect(map(evenement({'Debut': 'bientôt'})), isNull);
    });
  });

  group('robustesse', () {
    test('Id servi en chaîne', () {
      expect(map(evenement({'Id': '1453'}))?.id, 1453);
    });

    test('sans Id ou sans nom : écartée', () {
      expect(map(evenement({'Id': null})), isNull);
      expect(map(evenement({'Nom': '  '})), isNull);
    });

    test('Organisme servi en tableau vide (PHP) : pas d\'organisateur', () {
      expect(map(evenement({'Organisme': <Object>[]}))?.organizer, isNull);
    });

    test('Organisme sans NomOrga : son label', () {
      expect(
        map(
          evenement({
            'Organisme': {'label': 'CD 13 FFSS'},
          }),
        )?.organizer,
        'CD 13 FFSS',
      );
    });

    test('Lieu vide : pas de lieu', () {
      expect(map(evenement({'Lieu': ' '}))?.location, isNull);
    });
  });
}
