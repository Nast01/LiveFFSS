import 'dart:convert';
import 'dart:typed_data';

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

  group('decodeNdefText', () {
    test('round-trips ndefTextPayload', () {
      expect(decodeNdefText(ndefTextPayload('123456;DUPONT')), '123456;DUPONT');
    });

    test('handles a non-ASCII last name', () {
      expect(decodeNdefText(ndefTextPayload('99;CRÉPEAU')), '99;CRÉPEAU');
    });

    test('returns null on an empty payload', () {
      expect(decodeNdefText(Uint8List(0)), isNull);
    });

    test('returns null when the language length overruns', () {
      // status byte says a 63-byte language code, but only one more byte follows.
      expect(decodeNdefText(Uint8List.fromList([0x3F, 0x65])), isNull);
    });
  });
}
