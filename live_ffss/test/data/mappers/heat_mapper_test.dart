import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/dtos/heat_dto.dart';
import 'package:live_ffss/app/data/mappers/heat_mapper.dart';

void main() {
  group('HeatMapper basic fields', () {
    test('maps with int Numero', () {
      final dto = HeatDto.fromJson(const {
        'Id': 1,
        'Nom': 'A',
        'Fini': false,
        'Numero': 3,
      });
      expect(dto.toDomain().number, 3);
    });

    test('maps with String Numero', () {
      final dto = HeatDto.fromJson(const {
        'Id': 1,
        'Nom': 'A',
        'Fini': true,
        'Numero': '7',
      });
      expect(dto.toDomain().number, 7);
    });
  });

  group('HeatMapper dates', () {
    test('parses Debut / Fin / UpdatedAt in FFSS format Y-m-d H:i:s', () {
      final dto = HeatDto.fromJson(const {
        'Id': 1,
        'Nom': 'S1',
        'Fini': true,
        'Numero': 1,
        'Debut': '2026-05-15 18:07:00',
        'Fin': '2026-05-15 18:12:30',
        'UpdatedAt': '2026-05-15 18:13:00',
      });
      final heat = dto.toDomain();
      expect(heat.startDate, DateTime(2026, 5, 15, 18, 7));
      expect(heat.endDate, DateTime(2026, 5, 15, 18, 12, 30));
      expect(heat.updatedAt, DateTime(2026, 5, 15, 18, 13));
    });

    test('null/empty dates map to null', () {
      final dto = HeatDto.fromJson(const {
        'Id': 1,
        'Nom': 'S1',
        'Fini': false,
        'Numero': 1,
        'Debut': '',
        'Fin': null,
      });
      final heat = dto.toDomain();
      expect(heat.startDate, isNull);
      expect(heat.endDate, isNull);
      expect(heat.updatedAt, isNull);
    });

    test('malformed date maps to null without throwing', () {
      final dto = HeatDto.fromJson(const {
        'Id': 1,
        'Nom': 'S1',
        'Fini': false,
        'Numero': 1,
        'Debut': 'not-a-date',
      });
      expect(dto.toDomain().startDate, isNull);
    });
  });

  group('HeatMapper nested results', () {
    test('clears parent heat back-ref on each result to break the cycle', () {
      final dto = HeatDto.fromJson(const {
        'Id': 10,
        'Nom': 'Série 1',
        'Fini': false,
        'Numero': 1,
        'resultats': [
          {
            'Id': 'r1',
            'isValid': true,
            'Statut': 1,
            'statutLabel': 'OK',
            'Rang': 1,
            'Temps': 5500,
            'tempsLabel': '0:55.00',
          },
        ],
      });
      final heat = dto.toDomain();
      expect(heat.results, hasLength(1));
      // Parent ref must be null — otherwise we'd carry a Heat <-> Result cycle.
      expect(heat.results.first.heat, isNull);
    });

    test('defaults to empty results list when absent', () {
      final dto = HeatDto.fromJson(const {
        'Id': 10,
        'Nom': 'Série 1',
        'Fini': false,
        'Numero': 1,
      });
      expect(dto.toDomain().results, isEmpty);
    });
  });
}
