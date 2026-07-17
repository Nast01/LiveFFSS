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
  NfcRfidWriterImpl();

  /// The in-flight write, so [cancel] can release it. `startSession` returns
  /// as soon as reader mode is on — it does not wait for a tag — so this
  /// completer is the only thing that ever ends a write.
  Completer<void>? _pending;

  @override
  bool get isSupported => true;

  @override
  Future<void> cancel() async {
    final pending = _pending;
    if (pending != null && !pending.isCompleted) {
      pending.completeError(const RfidException('bracelet_write_cancelled'));
    }
  }

  @override
  Future<void> write(String payload) async {
    final completer = Completer<void>();
    _pending = completer;

    // The plugin does not await this callback, so a second bracelet can fire
    // it again between the write finishing and the session actually closing.
    // `isCompleted` alone would not stop that second chip from being written.
    var written = false;

    // checkAvailability() and the NdefMessage construction are inside this
    // try too: a MissingPluginException/PlatformException from either would
    // otherwise escape as a raw non-AppException, which the controller's
    // `on AppException` catch does not match — leaving `writeState` stuck on
    // `waiting` ("Approchez le bracelet") with no way out but Annuler.
    // The session is stopped in `finally` — a session left open blocks every
    // later write AND keeps this callback live, so the next bracelet touched
    // would be silently written with this payload.
    try {
      final availability = await NfcManager.instance.checkAvailability();
      if (availability == NfcAvailability.disabled) {
        throw const RfidException('nfc_disabled');
      }
      if (availability != NfcAvailability.enabled) {
        throw const RfidException('nfc_unsupported');
      }

      final message = NdefMessage(records: [
        NdefRecord(
          typeNameFormat: TypeNameFormat.wellKnown,
          type: Uint8List.fromList([0x54]), // 'T' — well-known Text record
          identifier: Uint8List(0),
          payload: ndefTextPayload(payload),
        ),
      ]);

      await NfcManager.instance.startSession(
        pollingOptions: {NfcPollingOption.iso14443},
        onDiscovered: (tag) async {
          if (written) return;
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
            written = true;
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
      _pending = null;
      // A throwing `finally` would replace the in-flight exception, turning a
      // specific key like `bracelet_too_small` into a raw PlatformException
      // that the controller's `on AppException` catch would not even match.
      // Failing to close a session we are abandoning anyway is not worth
      // destroying the real error for.
      try {
        await NfcManager.instance.stopSession();
      } catch (_) {}
    }
  }
}
