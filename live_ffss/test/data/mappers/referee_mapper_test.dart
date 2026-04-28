import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/dtos/referee_dto.dart';
import 'package:live_ffss/app/data/mappers/referee_mapper.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';

void main() {
  group('RefereeMapper', () {
    test('maps a full RefereeDto to Referee', () {
      const dto = RefereeDto(
        id: 11,
        licenseeNumber: '999',
        firstName: 'Bob',
        lastName: 'Lee',
        gender: 'M',
        year: 1980,
        level: 'A',
        levelMax: 'A+',
        nationalityCode: 'FR',
        nationality: 'France',
        isValid: true,
        isPrincipal: true,
        availabilities: [1, 2, 3],
      );

      final r = dto.toDomain();

      expect(r.id, 11);
      expect(r.firstName, 'Bob');
      expect(r.gender, Gender.mixed);
      expect(r.year, 1980);
      expect(r.level, 'A');
      expect(r.levelMax, 'A+');
      expect(r.isPrincipal, true);
      expect(r.availabilities, [1, 2, 3]);
    });

    test('availabilities parses string entries to ints', () {
      final dto = RefereeDto.fromJson(const {
        'Id': 1,
        'NumeroLicence': '0',
        'Prenom': 'X',
        'Nom': 'Y',
        'Sexe': 'F',
        'Annee': 1990,
        'nationaliteCode': '',
        'nationaliteLabel': '',
        'isValid': true,
        'Jours': ['1', '2', '7'],
      });

      expect(dto.toDomain().availabilities, [1, 2, 7]);
    });

    test('missing optional fields use defaults', () {
      final dto = RefereeDto.fromJson(const {
        'NumeroLicence': '0',
        'Prenom': 'X',
        'Nom': 'Y',
        'Sexe': 'F',
        'Annee': 0,
        'nationaliteCode': '',
        'nationaliteLabel': '',
        'isValid': false,
      });

      final r = dto.toDomain();
      expect(r.id, 0);
      expect(r.level, '');
      expect(r.levelMax, '');
      expect(r.isPrincipal, false);
      expect(r.availabilities, isEmpty);
    });
  });
}
