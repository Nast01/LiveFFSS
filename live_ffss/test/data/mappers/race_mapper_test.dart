import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/dtos/category_dto.dart';
import 'package:live_ffss/app/data/dtos/race_dto.dart';
import 'package:live_ffss/app/data/mappers/race_mapper.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';

void main() {
  group('RaceMapper', () {
    test('maps a full RaceDto to Race', () {
      const dto = RaceDto(
        id: 12,
        disciplineId: 7,
        gender: 'F',
        isEligibleToNationalRecord: true,
        discipline: RaceDisciplineDto(
          name: '100m Surf',
          nameEnglish: '100m Surf Race',
          distance: 100,
          athletesPerTeam: 1,
          specialityId: 2,
          specialityLabel: 'Eau-plate',
        ),
        categories: [
          CategoryDto(id: 1, name: 'Senior', ageMin: 18, ageMax: 35),
        ],
      );

      final r = dto.toDomain();

      expect(r.id, 12);
      expect(r.name, '100m Surf');
      expect(r.nameEnglish, '100m Surf Race');
      expect(r.distance, 100);
      expect(r.gender, Gender.female);
      expect(r.athletesPerTeam, 1);
      expect(r.specialityId, 2);
      expect(r.specialityLabel, 'Eau-plate');
      expect(r.disciplineId, 7);
      expect(r.isEligibleToNationalRecord, true);
      expect(r.categories.length, 1);
      expect(r.categories.first.name, 'Senior');
    });

    test('handles missing distance/athletesPerTeam via defaults', () {
      final dto = RaceDto.fromJson(const {
        'Id': 1,
        'IdDiscipline': 1,
        'Genre': 'M',
        'discipline': {
          'Nom': 'X',
          'NomEn': 'X',
          'Specialite': 0,
          'specialiteLabel': '',
        },
      });

      final r = dto.toDomain();
      expect(r.distance, 0);
      expect(r.athletesPerTeam, 1);
      expect(r.categories, isEmpty);
    });
  });
}
