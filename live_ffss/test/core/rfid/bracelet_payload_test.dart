import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/rfid/bracelet_payload.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';

void main() {
  Athlete athlete({
    String licenseeNumber = '123456',
    String lastName = 'DUPONT',
    int orderNumber = 0,
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
        orderNumber: orderNumber,
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

    test('writes the bib as a third field', () {
      expect(
        braceletPayload(
          athlete(licenseeNumber: 'L1', lastName: 'DUPONT', orderNumber: 12),
        ),
        'L1;DUPONT;12',
      );
    });

    test('keeps two fields when there is no bib', () {
      expect(
        braceletPayload(
          athlete(licenseeNumber: 'L1', lastName: 'DUPONT', orderNumber: 0),
        ),
        'L1;DUPONT',
      );
    });
  });

  group('parseBraceletLicence', () {
    test('extracts the licence from licence;lastName', () {
      expect(parseBraceletLicence('123456;DUPONT'), '123456');
    });

    test('returns the whole string when there is no separator', () {
      expect(parseBraceletLicence('123456'), '123456');
    });

    test('trims surrounding whitespace', () {
      expect(parseBraceletLicence(' 123456 ;X'), '123456');
    });
  });

  group('parseBraceletOrderNumber', () {
    test('reads the bib back from the third field', () {
      expect(parseBraceletOrderNumber('L1;DUPONT;12'), 12);
    });

    // A bracelet written before this version carries only two fields: it stays
    // readable, and raises no alert.
    test('a legacy two-field payload carries no bib', () {
      expect(parseBraceletOrderNumber('L1;DUPONT'), 0);
      expect(parseBraceletLicence('L1;DUPONT'), 'L1');
    });

    test('an unreadable third field means no bib', () {
      expect(parseBraceletOrderNumber('L1;DUPONT;A12'), 0);
    });
  });
}
