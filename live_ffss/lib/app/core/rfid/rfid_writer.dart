import 'package:live_ffss/app/core/errors/app_exception.dart';

/// Writes a text payload to an RFID/NFC bracelet.
///
/// Implementations are platform-specific; [InitialBinding] picks one.
abstract class RfidWriter {
  /// Whether this device can write bracelets at all. The UI hides its entry
  /// point when false — callers must not offer a write they cannot perform.
  bool get isSupported;

  /// Writes [payload] to the next bracelet presented to the device.
  ///
  /// Throws [RfidException] with a translation key as its message on any
  /// failure (unwritable chip, insufficient capacity, NFC turned off).
  Future<void> write(String payload);
}

/// The no-op implementation used on iOS, web, and desktop.
///
/// Mirrors `RankingRemoteDataSourceImpl`: a typed stub keeps the seam honest
/// until the real implementation lands. See the spec's "Out of scope" for
/// what enabling iOS requires.
class UnsupportedRfidWriter implements RfidWriter {
  const UnsupportedRfidWriter();

  @override
  bool get isSupported => false;

  @override
  Future<void> write(String payload) async =>
      throw const RfidException('nfc_unsupported');
}
