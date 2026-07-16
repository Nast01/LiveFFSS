import 'dart:convert';
import 'dart:typed_data';

/// Builds the payload of an NFC Forum well-known Text ('T') record.
///
/// Layout is `[status][language code][text]`: bit 7 of the status byte is the
/// encoding (0 = UTF-8) and bits 5-0 are the language-code length.
///
/// The plugin's README shows a bare `utf8.encode(text)` as a Text payload —
/// that skips this header and third-party readers render the result as
/// garbage. Being readable by a generic NFC app is why we picked this format,
/// so the header is not optional.
Uint8List ndefTextPayload(String text, {String languageCode = 'en'}) {
  final languageBytes = ascii.encode(languageCode);
  if (languageBytes.length > 0x3F) {
    throw ArgumentError.value(
      languageCode,
      'languageCode',
      'must fit in the 6 length bits of the status byte (max 63 bytes)',
    );
  }
  return Uint8List.fromList([
    languageBytes.length, // bit 7 stays clear → UTF-8
    ...languageBytes,
    ...utf8.encode(text),
  ]);
}
