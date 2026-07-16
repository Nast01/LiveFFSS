import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/rfid/ndef_text_record.dart';

void main() {
  group('ndefTextPayload', () {
    test('prefixes a UTF-8 status byte and the language code', () {
      final bytes = ndefTextPayload('A');
      // 0x02 = UTF-8 (bit 7 clear) + language code length 2.
      expect(bytes, [0x02, 0x65, 0x6E, 0x41]); // 0x65 0x6E = 'en', 0x41 = 'A'
    });

    test('encodes the text as UTF-8, not latin-1', () {
      final bytes = ndefTextPayload('É');
      expect(bytes.sublist(3), utf8.encode('É'));
      expect(bytes.sublist(3), [0xC3, 0x89]);
    });

    test('honours a different language code and its length', () {
      final bytes = ndefTextPayload('A', languageCode: 'fra');
      expect(bytes.first, 0x03);
      expect(bytes.sublist(1, 4), [0x66, 0x72, 0x61]); // 'fra'
    });

    test('carries the full bracelet payload verbatim after the header', () {
      final bytes = ndefTextPayload('123456;DUPONT');
      expect(utf8.decode(bytes.sublist(3)), '123456;DUPONT');
    });

    test('rejects a language code too long for the status byte', () {
      expect(
        () => ndefTextPayload('A', languageCode: 'x' * 64),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
