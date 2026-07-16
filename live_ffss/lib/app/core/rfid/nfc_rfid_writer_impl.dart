import 'dart:async';
import 'dart:typed_data';

import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/core/rfid/ndef_text_record.dart';
import 'package:live_ffss/app/core/rfid/rfid_writer.dart';
import 'package:nfc_manager/ndef_record.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';

/// Android bracelet writer built on `nfc_manager`.
///
/// Not unit-tested: it is a thin adapter over the plugin, so a mocked test
/// would only assert that the plugin was called. Verified on a device with a
/// real bracelet.
class NfcRfidWriterImpl implements RfidWriter {
  const NfcRfidWriterImpl();

  @override
  bool get isSupported => true;

  @override
  Future<void> write(String payload) async {
    final availability = await NfcManager.instance.checkAvailability();
    if (availability != NfcAvailability.enabled) {
      throw const RfidException('nfc_disabled');
    }

    final message = NdefMessage(records: [
      NdefRecord(
        typeNameFormat: TypeNameFormat.wellKnown,
        type: Uint8List.fromList([0x54]), // 'T' — well-known Text record
        identifier: Uint8List(0),
        payload: ndefTextPayload(payload),
      ),
    ]);

    final completer = Completer<void>();

    // The session is stopped in `finally` — a session left open blocks every
    // later write.
    try {
      await NfcManager.instance.startSession(
        pollingOptions: {NfcPollingOption.iso14443},
        onDiscovered: (tag) async {
          try {
            final ndef = NdefAndroid.from(tag);
            if (ndef == null || !ndef.isWritable) {
              throw const RfidException('bracelet_not_writable');
            }
            // Compare encoded bytes, not String.length: `.length` counts
            // UTF-16 code units, so an accented name would slip past this
            // check onto a chip too small to hold it. byteLength also
            // accounts for record headers, not just the text.
            if (message.byteLength > ndef.maxSize) {
              throw const RfidException('bracelet_too_small');
            }
            await ndef.writeNdefMessage(message);
            if (!completer.isCompleted) completer.complete();
          } on RfidException catch (e) {
            if (!completer.isCompleted) completer.completeError(e);
          } catch (e) {
            if (!completer.isCompleted) {
              completer.completeError(
                const RfidException('bracelet_write_failed'),
              );
            }
          }
        },
      );
      await completer.future;
    } on AppException {
      rethrow;
    } catch (e) {
      throw const RfidException('bracelet_write_failed');
    } finally {
      await NfcManager.instance.stopSession();
    }
  }
}
