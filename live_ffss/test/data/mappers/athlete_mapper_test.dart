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

    test('engagement fields default when absent (non-engagement endpoints)',
        () {
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

  group('AthleteMapper licensee number', () {
    test('a guest athlete is identified by idInvite', () {
      const dto = AthleteDto(
        id: 1,
        licenseeNumber: '',
        firstName: 'A',
        lastName: 'B',
        isGuest: true,
        guestId: 'INV-42',
      );

      expect(dto.toDomain().licenseeNumber, 'INV-42');
    });

    test('a licensee keeps NumeroLicence even when idInvite is present', () {
      const dto = AthleteDto(
        id: 1,
        licenseeNumber: '12345',
        firstName: 'A',
        lastName: 'B',
        isLicensee: true,
        guestId: 'INV-42',
      );

      expect(dto.toDomain().licenseeNumber, '12345');
    });

    test('a guest with no idInvite falls back to NumeroLicence', () {
      const dto = AthleteDto(
        id: 1,
        licenseeNumber: '12345',
        firstName: 'A',
        lastName: 'B',
        isGuest: true,
      );

      expect(dto.toDomain().licenseeNumber, '12345');
    });

    test('idInvite is read whether the API sends it as int or String', () {
      final asInt = AthleteDto.fromJson(const {
        'Id': 1,
        'Prenom': 'A',
        'Nom': 'B',
        'isInvite': true,
        'idInvite': 4711,
      });
      final asString = AthleteDto.fromJson(const {
        'Id': 1,
        'Prenom': 'A',
        'Nom': 'B',
        'isInvite': true,
        'idInvite': '4711',
      });

      expect(asInt.toDomain().licenseeNumber, '4711');
      expect(asString.toDomain().licenseeNumber, '4711');
    });
  });

  group('nationality code normalization', () {
    test('CHE is rewritten to the sport code SUI', () {
      const dto = AthleteDto(
        id: 1,
        firstName: 'A',
        lastName: 'B',
        nationalityCode: 'CHE',
        nationality: 'Suisse',
      );

      final a = dto.toDomain();

      expect(a.nationalityCode, 'SUI');
      // Only the code is remapped — the label is passed through untouched.
      expect(a.nationality, 'Suisse');
    });

    test('any other code is passed through', () {
      expect(normalizeNationalityCode('FRA'), 'FRA');
      expect(normalizeNationalityCode(''), '');
    });
  });
}
