# RFID Bracelet Scan → Mark Present — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** In the race detail "Engagés" tab, "Scanner un bracelet" reads RFID bracelets continuously; each bracelet's licence is matched among the race's entries and that athlete's attendance is set to Présent, with a live log + counter in a bottom sheet.

**Architecture:** Extend the `RfidWriter` seam with a `Stream<String> readBracelets()` (continuous NFC read; the session stays open between tags). Two pure helpers — `decodeNdefText` (inverse of the existing encoder) and `parseBraceletLicence` — do the parsing. `RaceDetailController` (which owns `entries` + `attendance`) gains the scan flow; the Engagés view opens a scan sheet. No new dependency; Android-only NFC (an `UnsupportedRfidWriter` stub covers the rest).

**Tech Stack:** Flutter, GetX, nfc_manager 4.2.1, mocktail.

**Spec:** `docs/superpowers/specs/2026-07-21-rfid-bracelet-scan-attendance-design.md`

## Global Constraints

- **Dart/Flutter binaries are not on PATH.** Use `C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat` and `dart.bat`.
- **No codegen.** No new/changed `@freezed` models; do NOT run `build_runner`.
- **No new dependency.** `package:collection` is NOT a direct dep — do NOT `import 'package:collection/collection.dart'` / use `firstWhereOrNull`; match with a plain loop.
- **Analyzer is strict** (`strict-casts`, `strict-raw-types`); no `dynamic`; no analyzer ignores.
- **Controller discipline:** no `.tr` / `Get.snackbar` / `Get.dialog` / `Get.context!` / `BuildContext` in controllers; constructor injection only, no `Get.find()` in a controller body; catch `AppException`. Stream errors go to the `listen(onError:)` callback. The **view** owns the bottom sheet; the controller exposes reactive state (an outcome enum, never a `.tr` string).
- **The bracelet payload contract is `<licenseeNumber>;<lastName>`** (`braceletFieldSeparator = ';'`). The read side splits on `;` and takes field `[0]` as the licence, matched against `Athlete.licenseeNumber`.
- **AttendanceStatus = { waiting, present, absent }; "Présent" = `AttendanceStatus.present`; keyed by `athlete.id`.**
- **Git:** `git add <explicit paths>` only. Git root is the PARENT of the Flutter package (paths show as `live_ffss/...`). Branch: `feat/rfid-bracelet-writer`. The translation files are `live_ffss/lib/app/core/translations/fr_FR.dart` and `en_US.dart` (uppercase locale).

---

### Task 1: Pure helpers — decodeNdefText + parseBraceletLicence

**Files:**
- Modify: `lib/app/core/rfid/ndef_text_record.dart` (add `decodeNdefText`)
- Modify: `lib/app/core/rfid/bracelet_payload.dart` (add `parseBraceletLicence`)
- Test: `test/core/rfid/ndef_text_record_test.dart` (new), `test/core/rfid/bracelet_payload_test.dart` (new)

**Interfaces:**
- Produces:
  - `String? decodeNdefText(Uint8List payload)` — the text of an NDEF Text record payload (`[status][lang][utf8]`), or null if malformed. Inverse of `ndefTextPayload`.
  - `String parseBraceletLicence(String payload)` — the licence field (`split(';').first.trim()`).

- [ ] **Step 1: Write the failing tests**

Create `test/core/rfid/ndef_text_record_test.dart`:

```dart
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/rfid/ndef_text_record.dart';

void main() {
  test('decodeNdefText round-trips ndefTextPayload', () {
    expect(decodeNdefText(ndefTextPayload('123456;DUPONT')), '123456;DUPONT');
  });

  test('decodeNdefText handles a non-ASCII last name', () {
    expect(decodeNdefText(ndefTextPayload('99;CRÉPEAU')), '99;CRÉPEAU');
  });

  test('decodeNdefText returns null on an empty payload', () {
    expect(decodeNdefText(Uint8List(0)), isNull);
  });

  test('decodeNdefText returns null when the language length overruns', () {
    // status byte says a 63-byte language code, but only one more byte follows.
    expect(decodeNdefText(Uint8List.fromList([0x3F, 0x65])), isNull);
  });
}
```

Create `test/core/rfid/bracelet_payload_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/rfid/bracelet_payload.dart';

void main() {
  test('parseBraceletLicence extracts the licence from licence;lastName', () {
    expect(parseBraceletLicence('123456;DUPONT'), '123456');
  });

  test('parseBraceletLicence returns the whole string when there is no separator', () {
    expect(parseBraceletLicence('123456'), '123456');
  });

  test('parseBraceletLicence trims surrounding whitespace', () {
    expect(parseBraceletLicence(' 123456 ;X'), '123456');
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/core/rfid/ndef_text_record_test.dart test/core/rfid/bracelet_payload_test.dart
```

Expected: FAIL — `decodeNdefText` / `parseBraceletLicence` are not defined.

- [ ] **Step 3: Add the helpers**

Append to `lib/app/core/rfid/ndef_text_record.dart` (it already imports `dart:convert` and `dart:typed_data`):

```dart
/// Decodes an NDEF well-known Text ('T') record payload — `[status][language
/// code][text]` — back to its text, or null if malformed. Inverse of
/// [ndefTextPayload]. Assumes UTF-8 (the encoding we write); a UTF-16 payload
/// that fails `utf8.decode` returns null.
String? decodeNdefText(Uint8List payload) {
  if (payload.isEmpty) return null;
  final langLen = payload[0] & 0x3F;
  if (1 + langLen > payload.length) return null;
  try {
    return utf8.decode(payload.sublist(1 + langLen));
  } catch (_) {
    return null;
  }
}
```

Append to `lib/app/core/rfid/bracelet_payload.dart`:

```dart
/// The licence number carried by a bracelet payload (`<licence>;<lastName>`) —
/// the field the attendance scanner matches against [Athlete.licenseeNumber].
String parseBraceletLicence(String payload) =>
    payload.split(braceletFieldSeparator).first.trim();
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/core/rfid/ndef_text_record_test.dart test/core/rfid/bracelet_payload_test.dart
```

Expected: PASS — 7 tests.

- [ ] **Step 5: Commit**

```bash
git add live_ffss/lib/app/core/rfid/ndef_text_record.dart live_ffss/lib/app/core/rfid/bracelet_payload.dart live_ffss/test/core/rfid/ndef_text_record_test.dart live_ffss/test/core/rfid/bracelet_payload_test.dart
git commit -m "feat(rfid): add decodeNdefText + parseBraceletLicence helpers"
```

---

### Task 2: Extend the RFID seam with a continuous read stream

**Files:**
- Modify: `lib/app/core/rfid/rfid_writer.dart` (add `readBracelets()` to the interface + `UnsupportedRfidWriter`)
- Modify: `lib/app/core/rfid/nfc_rfid_writer_impl.dart` (implement `readBracelets()`)
- Test: `test/core/rfid/rfid_writer_test.dart` (add the unsupported-read case)

**Interfaces:**
- Consumes: `decodeNdefText` (Task 1), `RfidException`, nfc_manager API.
- Produces: `Stream<String> RfidWriter.readBracelets()` — emits each bracelet's raw NDEF-text payload; a tag with no readable text record delivers an `RfidException('bracelet_unreadable')` error event **without closing** the stream; cancelling the subscription stops the session.

- [ ] **Step 1: Write the failing test** (append to the existing file)

Add to `test/core/rfid/rfid_writer_test.dart` (inside its `main()`):

```dart
  test('UnsupportedRfidWriter.readBracelets emits an nfc_unsupported error', () {
    const writer = UnsupportedRfidWriter();
    expect(
      writer.readBracelets(),
      emitsError(
        isA<RfidException>()
            .having((e) => e.message, 'message', 'nfc_unsupported'),
      ),
    );
  });
```

(The file already imports `rfid_writer.dart` and `app_exception.dart`; if not, add
`import 'package:live_ffss/app/core/errors/app_exception.dart';`.)

- [ ] **Step 2: Run test to verify it fails**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/core/rfid/rfid_writer_test.dart
```

Expected: FAIL — `readBracelets` is not defined on `RfidWriter`/`UnsupportedRfidWriter`.

- [ ] **Step 3: Add `readBracelets()` to the interface + the unsupported stub**

In `lib/app/core/rfid/rfid_writer.dart`, add to the `RfidWriter` abstract class (after `write`, before `cancel`):

```dart
  /// Opens a continuous NFC read session and emits the raw NDEF-text payload
  /// (`<licenseeNumber>;<lastName>`) of each bracelet presented. A tag with no
  /// readable text record delivers an [RfidException] error event WITHOUT
  /// closing the stream — the session keeps polling. Cancelling the
  /// subscription stops the session.
  Stream<String> readBracelets();
```

and to `UnsupportedRfidWriter` (after its `write`):

```dart
  @override
  Stream<String> readBracelets() =>
      Stream<String>.error(const RfidException('nfc_unsupported'));
```

- [ ] **Step 4: Implement the read session in `NfcRfidWriterImpl`**

In `lib/app/core/rfid/nfc_rfid_writer_impl.dart`, add (the file already imports `dart:async`, `ndef_text_record.dart`, and the three nfc_manager barrels):

```dart
  @override
  Stream<String> readBracelets() {
    late StreamController<String> controller;
    controller = StreamController<String>(
      onListen: () async {
        try {
          final availability = await NfcManager.instance.checkAvailability();
          if (availability == NfcAvailability.disabled) {
            controller.addError(const RfidException('nfc_disabled'));
            await controller.close();
            return;
          }
          if (availability != NfcAvailability.enabled) {
            controller.addError(const RfidException('nfc_unsupported'));
            await controller.close();
            return;
          }
          await NfcManager.instance.startSession(
            pollingOptions: {NfcPollingOption.iso14443},
            onDiscovered: (tag) async {
              final text = _readBraceletText(tag);
              if (text == null) {
                // Unreadable tag: report it but keep the session open so the
                // next bracelet can still be read.
                controller.addError(const RfidException('bracelet_unreadable'));
              } else {
                controller.add(text);
              }
            },
          );
        } catch (_) {
          controller.addError(const RfidException('bracelet_unreadable'));
          await controller.close();
        }
      },
      onCancel: () async {
        try {
          await NfcManager.instance.stopSession();
        } catch (_) {}
      },
    );
    return controller.stream;
  }

  /// Reads the first well-known Text ('T') record of a discovered tag from its
  /// cached NDEF message, or null if there is none / it does not decode.
  String? _readBraceletText(NfcTag tag) {
    final ndef = NdefAndroid.from(tag);
    final message = ndef?.cachedNdefMessage;
    if (message == null) return null;
    for (final record in message.records) {
      if (record.typeNameFormat == TypeNameFormat.wellKnown &&
          record.type.length == 1 &&
          record.type[0] == 0x54) {
        return decodeNdefText(record.payload);
      }
    }
    return null;
  }
```

- [ ] **Step 5: Run the test + analyze the changed files**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/core/rfid/rfid_writer_test.dart
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat analyze lib/app/core/rfid/rfid_writer.dart lib/app/core/rfid/nfc_rfid_writer_impl.dart
```

Expected: test PASS; `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add live_ffss/lib/app/core/rfid/rfid_writer.dart live_ffss/lib/app/core/rfid/nfc_rfid_writer_impl.dart live_ffss/test/core/rfid/rfid_writer_test.dart
git commit -m "feat(rfid): add continuous read stream to the RFID seam"
```

---

### Task 3: RaceDetailController scan flow + binding + test

Injects `RfidWriter`, adds the scan state and `startScan`/`stopScan`, and matches licences to mark athletes present. Keeps the `scanRfid()` stub for now (the view still calls it until Task 4) so the tree compiles.

**Files:**
- Modify: `lib/app/module/competitions/controllers/race_detail_controller.dart`
- Modify: `lib/app/module/competitions/bindings/race_detail_binding.dart`
- Test: `test/presentation/modules/competitions/controllers/race_detail_controller_test.dart`

**Interfaces:**
- Consumes: `RfidWriter.readBracelets()` (Task 2), `parseBraceletLicence` (Task 1), `entries`, `attendance`, `AttendanceStatus`.
- Produces: `RaceDetailController(RaceRepository, ClubRepository, RfidWriter)`; `enum ScanOutcome { present, notEntered, unreadable }`; `class ScanResult { String label; ScanOutcome outcome; }`; fields `RxBool isScanning`, `RxList<ScanResult> scanLog`, `RxInt presentCount`; `bool get canScanBracelets`; `void startScan()`, `void stopScan()`.

- [ ] **Step 1: Write the failing tests**

In `test/presentation/modules/competitions/controllers/race_detail_controller_test.dart`, add imports at the top (if not already present): `dart:async`, `package:live_ffss/app/core/errors/app_exception.dart`, `package:live_ffss/app/core/rfid/rfid_writer.dart`, `package:live_ffss/app/domain/models/entry.dart`, `package:live_ffss/app/domain/models/category.dart`. Add the mock class next to the others:

```dart
class _MockRfidWriter extends Mock implements RfidWriter {}
```

Add a `late _MockRfidWriter rfidWriter;` to the top-level `late` declarations, and in the existing `setUp`, create it and pass it to the controller (replace the current 2-arg construction):

```dart
    rfidWriter = _MockRfidWriter();
    // existing raceRepo/clubRepo stubs stay ...
    controller = RaceDetailController(raceRepo, clubRepo, rfidWriter);
```

Add this new group (at the end of `main()`):

```dart
  group('startScan', () {
    late StreamController<String> scanStream;

    Athlete scanAthlete(int id, String lastName, String licence) => Athlete(
          id: id,
          licenseeNumber: licence,
          firstName: 'X',
          lastName: lastName,
          gender: Gender.female,
          year: 2000,
          nationalityCode: '',
          nationality: '',
          isValid: true,
        );

    Entry scanEntry(List<Athlete> athletes) => Entry(
          id: 1,
          category: const Category(id: 1, name: 'Senior'),
          status: 1,
          statusLabel: 'Engagé',
          athletes: athletes,
        );

    setUp(() {
      scanStream = StreamController<String>();
      when(() => rfidWriter.readBracelets())
          .thenAnswer((_) => scanStream.stream);
    });

    tearDown(() async {
      if (!scanStream.isClosed) await scanStream.close();
    });

    test('a matching bracelet marks the athlete present', () async {
      final jean = scanAthlete(1, 'DUPONT', '123');
      controller.entries.value = [scanEntry([jean])];
      controller.startScan();
      scanStream.add('123;DUPONT');
      await pumpEventQueue();
      expect(controller.attendanceOf(jean), AttendanceStatus.present);
      expect(controller.presentCount.value, 1);
      expect(controller.scanLog.first.outcome, ScanOutcome.present);
    });

    test('an unknown licence logs notEntered and leaves attendance', () async {
      final jean = scanAthlete(1, 'DUPONT', '123');
      controller.entries.value = [scanEntry([jean])];
      controller.startScan();
      scanStream.add('999;NOBODY');
      await pumpEventQueue();
      expect(controller.attendanceOf(jean), AttendanceStatus.waiting);
      expect(controller.scanLog.first.outcome, ScanOutcome.notEntered);
      expect(controller.presentCount.value, 0);
    });

    test('a stream error logs unreadable', () async {
      controller.startScan();
      scanStream.addError(const RfidException('bracelet_unreadable'));
      await pumpEventQueue();
      expect(controller.scanLog.first.outcome, ScanOutcome.unreadable);
      expect(controller.scanLog.first.label, 'bracelet_unreadable');
    });

    test('stopScan cancels the subscription; later events are ignored', () async {
      final jean = scanAthlete(1, 'DUPONT', '123');
      controller.entries.value = [scanEntry([jean])];
      controller.startScan();
      controller.stopScan();
      scanStream.add('123;DUPONT');
      await pumpEventQueue();
      expect(controller.attendanceOf(jean), AttendanceStatus.waiting);
      expect(controller.isScanning.value, isFalse);
    });

    test('canScanBracelets reflects the writer', () {
      when(() => rfidWriter.isSupported).thenReturn(true);
      expect(controller.canScanBracelets, isTrue);
    });
  });
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/presentation/modules/competitions/controllers/race_detail_controller_test.dart
```

Expected: FAIL — the constructor takes 2 args / `startScan`/`ScanOutcome` undefined.

- [ ] **Step 3: Wire `RfidWriter` + the scan flow into the controller**

In `lib/app/module/competitions/controllers/race_detail_controller.dart`:

Add imports:

```dart
import 'package:live_ffss/app/core/rfid/bracelet_payload.dart';
import 'package:live_ffss/app/core/rfid/rfid_writer.dart';
```

Change the constructor + add the field:

```dart
  RaceDetailController(this._raceRepo, this._clubRepo, this._rfidWriter);

  final RaceRepository _raceRepo;
  final ClubRepository _clubRepo;
  final RfidWriter _rfidWriter;
```

Add the scan state fields (next to the `attendance` / `sortMode` block):

```dart
  final RxBool isScanning = false.obs;
  final RxList<ScanResult> scanLog = <ScanResult>[].obs;
  final RxInt presentCount = 0.obs;
  StreamSubscription<String>? _scanSub;
```

Add the scan methods (place them next to `setAttendance`, and delete the old `scanRfid()` stub is **NOT** done here — leave it; Task 4 removes it):

```dart
  bool get canScanBracelets => _rfidWriter.isSupported;

  /// Starts a continuous bracelet-read session. Each scanned bracelet whose
  /// licence matches an engaged athlete sets that athlete present. Idempotent
  /// while already scanning.
  void startScan() {
    if (isScanning.value) return;
    scanLog.clear();
    presentCount.value = 0;
    isScanning.value = true;
    _scanSub = _rfidWriter.readBracelets().listen(
      _onScanPayload,
      onError: (Object e) {
        final key = e is RfidException ? e.message : 'bracelet_unreadable';
        scanLog.insert(0, ScanResult(key, ScanOutcome.unreadable));
      },
    );
  }

  void _onScanPayload(String payload) {
    final licence = parseBraceletLicence(payload);
    Athlete? match;
    for (final e in entries) {
      for (final a in e.athletes) {
        if (a.licenseeNumber == licence) {
          match = a;
          break;
        }
      }
      if (match != null) break;
    }
    if (match == null) {
      scanLog.insert(0, ScanResult(licence, ScanOutcome.notEntered));
      return;
    }
    attendance[match.id] = AttendanceStatus.present;
    scanLog.insert(
        0, ScanResult('${match.lastName} ${match.firstName}', ScanOutcome.present));
    presentCount.value++;
  }

  /// Stops the read session and releases the NFC hardware.
  void stopScan() {
    _scanSub?.cancel();
    _scanSub = null;
    isScanning.value = false;
  }
```

In `onClose`, cancel the scan subscription alongside the poll timer:

```dart
  @override
  void onClose() {
    _pollTimer?.cancel();
    _scanSub?.cancel();
    super.onClose();
  }
```

Add the scan types at the bottom of the file (next to the `AttendanceStatus` enum):

```dart
enum ScanOutcome { present, notEntered, unreadable }

/// One line in the scan log: a display label plus the outcome (which the view
/// maps to a colour / translation). For `unreadable` the label is the
/// `RfidException` message key (e.g. `nfc_disabled`, `bracelet_unreadable`).
class ScanResult {
  const ScanResult(this.label, this.outcome);

  final String label;
  final ScanOutcome outcome;
}
```

- [ ] **Step 4: Add `RfidWriter` to the binding**

In `lib/app/module/competitions/bindings/race_detail_binding.dart`, add the import and the third argument:

```dart
import 'package:live_ffss/app/core/rfid/rfid_writer.dart';
```

```dart
    Get.lazyPut<RaceDetailController>(
      () => RaceDetailController(
        Get.find<RaceRepository>(),
        Get.find<ClubRepository>(),
        Get.find<RfidWriter>(),
      ),
    );
```

- [ ] **Step 5: Run the test + analyze**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/presentation/modules/competitions/controllers/race_detail_controller_test.dart
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat analyze lib/app/module/competitions/controllers/race_detail_controller.dart lib/app/module/competitions/bindings/race_detail_binding.dart
```

Expected: the scan group (5 tests) + all existing tests PASS; `No issues found!` (the view still calls `scanRfid()`, which still exists — untouched here).

- [ ] **Step 6: Commit**

```bash
git add live_ffss/lib/app/module/competitions/controllers/race_detail_controller.dart live_ffss/lib/app/module/competitions/bindings/race_detail_binding.dart live_ffss/test/presentation/modules/competitions/controllers/race_detail_controller_test.dart
git commit -m "feat(rfid): drive bracelet scan → mark present in RaceDetailController"
```

---

### Task 4: The scan sheet in the Engagés view + translations

Gates the scan button on NFC support, opens a continuous-scan bottom sheet, and removes the now-dead `scanRfid()` stub + `rfid_coming_soon` snackbar. No unit tests (view) — analyze + full suite + device.

**Files:**
- Modify: `lib/app/module/competitions/views/race_detail_entries_view.dart`
- Modify: `lib/app/module/competitions/controllers/race_detail_controller.dart` (remove the dead `scanRfid()` stub)
- Modify: `lib/app/core/translations/fr_FR.dart`, `lib/app/core/translations/en_US.dart`

**Interfaces:**
- Consumes: `RaceDetailController` — `canScanBracelets`, `startScan`, `stopScan`, `scanLog`, `presentCount`, `ScanResult`, `ScanOutcome`; theme; translation keys.

- [ ] **Step 1: Add the translation keys**

In `lib/app/core/translations/fr_FR.dart`, add before the final `};`:

```dart
  'approach_bracelets': 'Approchez les bracelets à scanner',
  'present_count': 'présents',
  'not_entered': 'Non engagé',
  'bracelet_unreadable': 'Bracelet illisible',
```

In `lib/app/core/translations/en_US.dart`, add before the final `};`:

```dart
  'approach_bracelets': 'Hold each bracelet near the phone',
  'present_count': 'present',
  'not_entered': 'Not entered',
  'bracelet_unreadable': 'Unreadable bracelet',
```

(The "Done" button reuses the existing `finish` key — no new `scan_done` key.)

- [ ] **Step 2: Remove the dead stub from the controller**

In `lib/app/module/competitions/controllers/race_detail_controller.dart`, delete the `scanRfid()` stub (the view stops calling it in this task):

```dart
  // TODO(rfid): wire the NFC/RFID bracelet reader to resolve an athlete by
  // bracelet id and mark them present. Placeholder for now.
  void scanRfid() {}
```

- [ ] **Step 3: Rewire the scan button + add the scan sheet**

In `lib/app/module/competitions/views/race_detail_entries_view.dart`:

Replace the scan button block inside `build` (the `_ScanButton(onPressed: () { controller.scanRfid(); ScaffoldMessenger... })` and its trailing `SizedBox`) with a gated button that opens the sheet:

```dart
                if (controller.canScanBracelets) ...[
                  _ScanButton(onPressed: () => _openScanSheet(context)),
                  const SizedBox(height: AppSpacing.xs),
                ],
```

Add the `_openScanSheet` method to `RaceDetailEntriesView` (it is a `GetView<RaceDetailController>`, so `controller` is available):

```dart
  void _openScanSheet(BuildContext context) {
    controller.startScan();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (_) => const _ScanSheet(),
    ).whenComplete(controller.stopScan);
  }
```

Add the sheet + row widgets at the bottom of the file:

```dart
class _ScanSheet extends GetView<RaceDetailController> {
  const _ScanSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: AppSpacing.pageAll,
        child: Obx(() {
          final log = controller.scanLog;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.nfc, size: 56, color: AppColors.primary),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'approach_bracelets'.tr,
                style: AppTypography.subtitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${controller.presentCount.value} ${'present_count'.tr}',
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.statusFinished,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (log.isNotEmpty)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: log.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.xs),
                    itemBuilder: (_, i) => _ScanLogRow(result: log[i]),
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: Get.back<void>,
                child: Text('finish'.tr),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _ScanLogRow extends StatelessWidget {
  const _ScanLogRow({required this.result});

  final ScanResult result;

  @override
  Widget build(BuildContext context) {
    final (String text, Color color) = switch (result.outcome) {
      ScanOutcome.present => (result.label, AppColors.statusFinished),
      ScanOutcome.notEntered =>
        ('${result.label} · ${'not_entered'.tr}', AppColors.statusWaiting),
      // For unreadable rows the label IS the RfidException translation key.
      ScanOutcome.unreadable => (result.label.tr, AppColors.statusError),
    };
    return Row(
      children: [
        Icon(Icons.circle, size: 10, color: color),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppTypography.body,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Analyze + full suite**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat analyze
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test
```

Expected: analyze clean; full suite passes (prior 361 + 7 helper + 1 unsupported-read + 5 scan-controller = 374).

- [ ] **Step 5: Device smoke test (needs a human + an NTAG bracelet)**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat run
```

On an Android device: open a competition → a race → Engagés tab → "Scanner un bracelet" appears (hidden on a non-NFC device) → tap → the sheet shows "Approchez les bracelets" + a "0 présents" counter → present a written bracelet → the athlete's row flips to green "Présent", the counter increments, and a green log line appears; present an unknown/blank bracelet → an orange "non engagé" / red "illisible" line, session stays open → tap Terminé → the sheet closes and the NFC session releases.

- [ ] **Step 6: Commit**

```bash
git add live_ffss/lib/app/module/competitions/views/race_detail_entries_view.dart live_ffss/lib/app/module/competitions/controllers/race_detail_controller.dart live_ffss/lib/app/core/translations/fr_FR.dart live_ffss/lib/app/core/translations/en_US.dart
git commit -m "feat(rfid): scan bracelets in Engagés to mark athletes present"
```

---

## Notes for the reviewer

- **Compile order.** The `scanRfid()` stub is kept through Task 3 (the view still calls it) and removed in Task 4 in the same commit that stops calling it — the tree compiles and the suite passes after every task.
- **Continuous read.** `readBracelets()` is a `Stream`; per-tag unreadable is an `addError` that does NOT close the stream (session keeps polling), while a fatal availability failure errors and closes. The controller's `onError` stores the `RfidException` key so the sheet shows the right line (`nfc_disabled` vs `bracelet_unreadable`); the view `.tr`s that key only for `unreadable` rows.
- **No `package:collection`.** Licence matching is a plain nested loop over `entries.expand(...)` — `firstWhereOrNull` would need a new direct dependency.
- **Controller discipline.** The controller exposes `ScanResult`/`ScanOutcome` (no `.tr`); the view maps outcome → colour/label. The bottom sheet is opened by the view; `.whenComplete(controller.stopScan)` releases the NFC session on any close.
- **Idempotent.** Re-scanning a present athlete stays present and logs another `present` line. Attendance survives pull-to-refresh (existing behavior — not cleared on reload).
- **Device-only checks:** the NFC read session + the sheet flow need a real Android device with a written bracelet (Task 4 Step 5). The decode/parse logic is unit-tested.
