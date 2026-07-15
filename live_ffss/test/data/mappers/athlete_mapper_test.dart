import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/dtos/athlete_dto.dart';
import 'package:live_ffss/app/data/mappers/athlete_mapper.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';

void main() {
  group('AthleteMapper', () {
    test('maps a full AthleteDto to Athlete', () {
      const dto = AthleteDto(
        id: 7,
        licenseeNumber: '12345',
        firstName: 'Alice',
        lastName: 'Doe',
        gender: 'F',
        year: 2000,
        nationalityCode: 'FR',
        nationality: 'France',
        isValid: true,
        isLicensee: true,
        isGuest: false,
      );

      final a = dto.toDomain();

      expect(a.id, 7);
      expect(a.licenseeNumber, '12345');
      expect(a.firstName, 'Alice');
      expect(a.lastName, 'Doe');
      expect(a.gender, Gender.female);
      expect(a.year, 2000);
      expect(a.nationalityCode, 'FR');
      expect(a.nationality, 'France');
      expect(a.isValid, true);
      expect(a.isLicensee, true);
      expect(a.isGuest, false);
    });

    test('"M" maps to Gender.mixed (legacy convention)', () {
      const dto = AthleteDto(
        id: 1,
        licenseeNumber: '0',
        firstName: 'X',
        lastName: 'Y',
        gender: 'M',
        year: 0,
        nationalityCode: '',
        nationality: '',
        isValid: false,
      );

      expect(dto.toDomain().gender, Gender.mixed);
    });

    test('any other gender code maps to Gender.male (legacy default)', () {
      const dto = AthleteDto(
        id: 1,
        licenseeNumber: '0',
        firstName: 'X',
        lastName: 'Y',
        gender: 'H',
        year: 0,
        nationalityCode: '',
        nationality: '',
        isValid: false,
      );

      expect(dto.toDomain().gender, Gender.male);
    });

    test('maps engagement-scoped fields (performance, club, substitute)', () {
      const dto = AthleteDto(
        id: 7,
        firstName: 'Jean',
        lastName: 'Dupont',
        gender: 'M',
        year: 2001,
        performanceTime: 3421,
        performanceLabel: '34.21',
        clubId: 30,
        clubLabel: 'SC Marseille',
        isSubstitute: true,
      );

      final a = dto.toDomain();

      expect(a.performanceTime, 3421);
      expect(a.performanceLabel, '34.21');
      expect(a.clubId, 30);
      expect(a.clubLabel, 'SC Marseille');
      expect(a.isSubstitute, isTrue);
    });

    test('engagement fields default when absent (non-engagement endpoints)', () {
      const dto = AthleteDto(id: 1, firstName: 'A', lastName: 'B');

      final a = dto.toDomain();

      expect(a.performanceTime, 0);
      expect(a.performanceLabel, '');
      expect(a.clubLabel, '');
      expect(a.isSubstitute, isFalse);
    });

    test('JSON round-trip parses Annee as String into int', () {
      final dto = AthleteDto.fromJson(const {
        'Id': 42,
        'NumeroLicence': '99',
        'Prenom': 'A',
        'Nom': 'B',
        'Sexe': 'F',
        'Annee': '1995',
        'nationaliteCode': 'FR',
        'nationaliteLabel': 'France',
        'isValid': true,
      });

      expect(dto.year, 1995);
    });
  });
}
