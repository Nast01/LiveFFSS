import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/rfid/bracelet_payload.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';

void main() {
  Athlete athlete({
    String licenseeNumber = '123456',
    String lastName = 'DUPONT',
  }) =>
      Athlete(
        id: 1,
        licenseeNumber: licenseeNumber,
        firstName: 'Jean',
        lastName: lastName,
        gender: Gender.male,
        year: 2004,
        nationalityCode: 'FRA',
        nationality: 'France',
        isValid: true,
      );

  group('braceletPayload', () {
    test('joins licensee number and last name with a semicolon', () {
      expect(braceletPayload(athlete()), '123456;DUPONT');
    });

    test('preserves accented characters', () {
      expect(
        braceletPayload(athlete(lastName: 'MÜLLER')),
        '123456;MÜLLER',
      );
    });

    test('neutralises a semicolon inside the last name', () {
      // Otherwise the reader would see three fields instead of two.
      expect(
        braceletPayload(athlete(lastName: 'DA;SILVA')),
        '123456;DA SILVA',
      );
    });

    test('handles an empty last name without dropping the separator', () {
      expect(braceletPayload(athlete(lastName: '')), '123456;');
    });
  });
}
