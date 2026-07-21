# RFID Bracelet Scan → Mark Present — Design

**Date:** 2026-07-21
**Status:** Approved (pending spec review)
**Branch:** `feat/rfid-bracelet-writer`

## Goal

In the race detail "Engagés" (entries) tab, the "Scanner un bracelet" button
(currently a `rfid_coming_soon` snackbar stub) reads RFID bracelets, parses the
licence number, matches the athlete among the race's entries, and sets their
attendance to **Présent**. Scanning is **continuous**: the sheet stays open and
each bracelet tapped marks its athlete present, until the operator closes it.

The existing RFID **write** feature is unchanged; this adds a **read** capability
to the same NFC seam.

## Decisions taken during brainstorming

| Question | Decision |
|---|---|
| Single vs continuous scan | **Continuous.** One open NFC session reads bracelet after bracelet; each marks its athlete present with a running log + counter; the operator closes when done. Matches marshalling a stack of bracelets. Android (the NFC session stays open between reads). |
| Extend the seam vs a separate reader | **Extend the existing `RfidWriter` seam** with a stream-based read (additive; no rename → zero churn on the shipped write code; one NFC-device seam). |
| Scan scope | **This race's entries only.** A bracelet whose athlete is not entered in the current race reports "non engagé". |

## Context (verified)

- The scan button is `_ScanButton` in `race_detail_entries_view.dart`; its
  `onPressed` calls `controller.scanRfid()` (an empty stub) then shows a
  `rfid_coming_soon` snackbar.
- Attendance lives on `RaceDetailController`: `RxMap<int, AttendanceStatus>
  attendance` keyed by `athlete.id`; `AttendanceStatus { waiting, present,
  absent }` — **"Présent" = `AttendanceStatus.present`**; set via
  `attendance[athlete.id] = ...` or `setAttendance(athlete, status)`. Athletes
  are reached via `entries.expand((e) => e.athletes)`; matched on
  `Athlete.licenseeNumber` (a `String`).
- The bracelet payload written to a chip is `licenseeNumber;lastName`
  (`braceletFieldSeparator = ';'`, `braceletPayload(Athlete)` in
  `bracelet_payload.dart`), encoded as an NDEF well-known Text record
  (`ndefTextPayload(text)` in `ndef_text_record.dart`, layout
  `[status][lang][utf8]`). There is currently **no decode** function.
- The RFID seam `RfidWriter` (`lib/app/core/rfid/rfid_writer.dart`) has
  `bool isSupported`, `Future<void> write(String)`, `Future<void> cancel()`.
  Impls: `NfcRfidWriterImpl` (Android, nfc_manager 4.2.1) and
  `UnsupportedRfidWriter` (everything else). Registered in `initial_binding.dart`.
- `RaceDetailController` is NOT currently injected with `RfidWriter` — it takes
  `(RaceRepository, ClubRepository)`.
- nfc_manager read pattern: `NfcManager.instance.startSession(pollingOptions:
  {NfcPollingOption.iso14443}, onDiscovered: (tag) { final ndef =
  NdefAndroid.from(tag); final msg = ndef?.cachedNdefMessage; ... })`; the
  session stays open until `stopSession()`. The NFC permission + `uses-feature`
  are already in the manifest; reader mode needs no manifest change.

## Architecture

### Component layout

```
lib/app/core/rfid/
├─ rfid_writer.dart                  ← MODIFY (add readBracelets() to interface + UnsupportedRfidWriter)
├─ nfc_rfid_writer_impl.dart         ← MODIFY (implement readBracelets())
├─ ndef_text_record.dart            ← MODIFY (add decodeNdefText)
└─ bracelet_payload.dart            ← MODIFY (add parseBraceletLicence)
lib/app/module/competitions/
├─ controllers/race_detail_controller.dart   ← MODIFY (inject RfidWriter; scan state + startScan/stopScan; replace scanRfid stub)
├─ bindings/race_detail_binding.dart         ← MODIFY (pass RfidWriter)
└─ views/race_detail_entries_view.dart       ← MODIFY (gate the scan button; open the scan sheet; add _ScanSheet)
lib/app/core/translations/fr_FR.dart, en_US.dart  ← MODIFY (read keys)
```

### The seam — stream-based continuous read

`RfidWriter` gains:

```dart
/// Opens a continuous NFC read session. Emits the raw NDEF-text payload of each
/// bracelet tapped (`licenseeNumber;lastName`). A tag with no readable text
/// record delivers an [RfidException] error event WITHOUT closing the stream —
/// the session keeps polling. Cancelling the subscription stops the session.
Stream<String> readBracelets();
```

- `UnsupportedRfidWriter.readBracelets()` → `Stream<String>.error(const
  RfidException('nfc_unsupported'))`.
- `NfcRfidWriterImpl.readBracelets()`:
  - `checkAvailability()` first (reuse the write path's mapping):
    `NfcAvailability.disabled` → the returned stream errors `nfc_disabled`;
    not `enabled` → `nfc_unsupported`. (A stream that errors and closes.)
  - Otherwise a `StreamController<String>` whose `onListen` starts
    `NfcManager.instance.startSession(pollingOptions: {NfcPollingOption.iso14443},
    onDiscovered: ...)` and whose `onCancel` calls `stopSession()` (in a
    `try/catch(_)`). In `onDiscovered`: `NdefAndroid.from(tag)` → the cached
    message → find the record with `typeNameFormat == TypeNameFormat.wellKnown`
    and `type` == `[0x54]` ('T') → `decodeNdefText(record.payload)`:
    - non-null → `controller.add(text)`;
    - null / no such record → `controller.addError(const
      RfidException('bracelet_unreadable'))` (session stays open).

### Pure helpers (testable)

- `ndef_text_record.dart` — add:
  ```dart
  /// Decodes an NDEF Text record payload (`[status][lang][utf8 text]`) back to
  /// its text, or null if malformed. Inverse of [ndefTextPayload].
  String? decodeNdefText(Uint8List payload) {
    if (payload.isEmpty) return null;
    final status = payload[0];
    final langLen = status & 0x3F;
    if (1 + langLen > payload.length) return null;
    try {
      return utf8.decode(payload.sublist(1 + langLen));
    } catch (_) {
      return null;
    }
  }
  ```
- `bracelet_payload.dart` — add:
  ```dart
  /// The licence number carried by a bracelet payload (`<licence>;<lastName>`).
  String parseBraceletLicence(String payload) =>
      payload.split(braceletFieldSeparator).first.trim();
  ```

### RaceDetailController — the scan flow

`RaceDetailController` is injected with `RfidWriter` (constructor +
`RaceDetailBinding`).

- New types (in the controller file):
  ```dart
  enum ScanOutcome { present, notEntered, unreadable }
  class ScanResult {
    const ScanResult(this.label, this.outcome);
    final String label;         // "DUPONT Jean" or "licence 123" or ''
    final ScanOutcome outcome;
  }
  ```
- State: `RxBool isScanning`, `RxList<ScanResult> scanLog`, `RxInt presentCount`,
  and a private `StreamSubscription<String>? _scanSub`.
- `bool get canScanBracelets => _rfid.isSupported`.
- `startScan()`: guards re-entrancy (`isScanning`), clears `scanLog`/`presentCount`,
  sets `isScanning = true`, and subscribes:
  ```dart
  _scanSub = _rfid.readBracelets().listen(
    _onScanPayload,
    onError: (Object e) {
      // A per-tag unreadable, a fatal nfc_disabled, or nfc_unsupported — the
      // RfidException's message IS the translation key; store it so the sheet
      // shows the right line. `unreadable` outcome ⇒ the view translates label.
      final key = e is RfidException ? e.message : 'bracelet_unreadable';
      scanLog.insert(0, ScanResult(key, ScanOutcome.unreadable));
    },
  );
  ```
  `_onScanPayload(String payload)` — matched with a plain loop (no
  `package:collection`):
  ```dart
  final licence = parseBraceletLicence(payload);
  Athlete? match;
  for (final e in entries) {
    for (final a in e.athletes) {
      if (a.licenseeNumber == licence) { match = a; break; }
    }
    if (match != null) break;
  }
  if (match == null) {
    scanLog.insert(0, ScanResult(licence, ScanOutcome.notEntered));
    return;
  }
  attendance[match.id] = AttendanceStatus.present;
  scanLog.insert(0, ScanResult('${match.lastName} ${match.firstName}', ScanOutcome.present));
  presentCount.value++;
  ```
- `stopScan()`: `_scanSub?.cancel(); _scanSub = null; isScanning = false;`.
- `onClose`: also cancels `_scanSub` (defensive) alongside the existing
  `_pollTimer` cancellation.
- The `scanRfid()` stub is removed; nothing else calls it.

Controller discipline: no `.tr` / `Get.snackbar` / `Get.dialog` / `Get.context!`
/ `BuildContext`; catches nothing to swallow (stream errors go to `onError`);
the view owns the sheet. The scan errors carry translation keys but the
controller stores an outcome enum, not a `.tr` string — the view maps outcome →
label/colour.

### The Engagés view — the scan sheet

- `_ScanButton` is shown only when `controller.canScanBracelets` (mirrors the
  write entry point gated on `canWriteBracelets`); on a non-NFC device it is
  hidden (manual chip tap/long-press still works).
- `onPressed`: `controller.startScan()` then opens a modal bottom sheet:
  ```dart
  showModalBottomSheet<void>(context: context, backgroundColor: AppColors.surface,
    builder: (_) => const _ScanSheet(),
  ).whenComplete(controller.stopScan);
  ```
  Unlike the write sheet, this one is dismissible (closing = done); the
  `whenComplete` stops the NFC session however it closes.
- `_ScanSheet` (an `Obx`) shows: an `Icons.nfc` header + `'approach_bracelets'.tr`;
  a `'present_count'` line with `controller.presentCount.value`; a bounded
  scrollable list of `controller.scanLog` rows — each row's text and colour from
  the outcome: `present` → `label` ("NOM Prénom") + `statusFinished` green;
  `notEntered` → `label` + " · " + `'not_entered'.tr` + `statusWaiting` orange;
  `unreadable` → `label.tr` (the row's label IS the `RfidException` key, e.g.
  `nfc_disabled` / `nfc_unsupported` / `bracelet_unreadable`) + `statusError` red;
  and a
  `'scan_done'`/`finish` `TextButton` → `Get.back`.

Reactivity: the sheet's `Obx` reads `presentCount.value` and `scanLog` in the
builder body.

## Error / empty handling

- NFC disabled/unsupported → the stream errors immediately; the sheet shows the
  error (via an `unreadable`-style row or a dedicated state). On a device with no
  NFC hardware the button is hidden, so this path is the "NFC turned off" case.
- Bracelet with no readable text record → an `unreadable` row; the session keeps
  polling for the next bracelet.
- Scanned athlete not in this race's entries → a `notEntered` row; attendance
  untouched.
- Re-scanning an already-present athlete → stays present (idempotent); a new
  `present` row is still logged.
- Pull-to-refresh / heats poll do NOT clear `attendance` (existing behavior), so
  scanned presences survive a refresh.

## Testing (per CLAUDE.md — logic layers, mocktail, no widget tests)

- **Pure helpers:** `decodeNdefText` round-trips with `ndefTextPayload` (incl. a
  non-ASCII last name) and returns null on a truncated/empty payload;
  `parseBraceletLicence` extracts the licence from `licence;lastName` and from a
  bare licence.
- **`RaceDetailController`** (mock `RfidWriter` whose `readBracelets()` returns a
  test-driven `StreamController<String>.stream`): feeding a payload whose licence
  matches an entry's athlete sets that athlete present + logs a `present` result +
  increments `presentCount`; an unknown licence logs `notEntered` and leaves
  attendance unchanged; a stream error logs `unreadable`; `stopScan` cancels the
  subscription (a subsequent emitted event is ignored); `canScanBracelets`
  reflects `isSupported`.
- The NDEF session/hardware orchestration in `NfcRfidWriterImpl.readBracelets()`
  is device-verified (like the write impl), not unit-tested.

## Out of scope

- Reading while writing (mutually exclusive; the seam is used for one at a time).
- Cross-race / competition-wide attendance.
- Persisting attendance to the FFSS backend (stays in memory, as today).
- iOS (the NFC impl is Android-gated; `UnsupportedRfidWriter` covers the rest).
- Verifying the last name from the payload (the licence is the match key; the
  last name is display-only on the chip).
