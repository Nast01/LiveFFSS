import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/core/rfid/rfid_writer.dart';

void main() {
  group('UnsupportedRfidWriter', () {
    test('reports itself as unsupported', () {
      expect(const UnsupportedRfidWriter().isSupported, isFalse);
    });

    test('write throws RfidException', () {
      expect(
        () => const UnsupportedRfidWriter().write('123456;DUPONT'),
        throwsA(isA<RfidException>()),
      );
    });

    test('RfidException is an AppException so controllers catch it', () {
      expect(const RfidException('nfc_unsupported'), isA<AppException>());
    });
  });
}
