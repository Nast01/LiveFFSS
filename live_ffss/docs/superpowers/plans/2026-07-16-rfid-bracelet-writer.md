# RFID Bracelet Writer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let a volunteer search a competition's athletes and write `<licenseeNumber>;<lastName>` to an NFC bracelet from the competition detail screen.

**Architecture:** A hardware seam (`RfidWriter`) in `core/rfid/` with an Android `nfc_manager` implementation and an unsupported stub for every other platform, selected in `InitialBinding`. A new `/rfid-writer` route in the `competitions` module holds the athlete search and the write flow. The payload format is a standalone pure function because it is the contract the future `scanRfid()` will parse.

**Tech Stack:** Flutter, GetX, freezed, `nfc_manager` (new), mocktail.

**Spec:** `docs/superpowers/specs/2026-07-16-rfid-bracelet-writer-design.md`

## Global Constraints

- **Dart/Flutter binaries are not on PATH.** Use `C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat` and `dart.bat`.
- **Analyzer is strict:** `strict-casts: true` and `strict-raw-types: true`. No `dynamic` coercions.
- **Controller discipline:** no `Get.snackbar`, no `Get.dialog`, no `.tr`, no `Get.context!`, no `BuildContext` params in controllers. Controllers hold translation keys; views translate.
- **Constructor injection only.** Never `Get.find()` inside a controller body.
- **Catch `AppException`**, never raw `Exception`.
- **No widget tests, no integration tests.** Logic layers only.
- **mocktail:** `class _MockX extends Mock implements X {}` — never `extends Fake`.
- **Payload format is exactly** `<licenseeNumber>;<lastName>` — no other fields.
- **Do NOT create translation keys `retry`, `cancel`, `no_athletes_found`** — they already exist and must be reused.
- **Do NOT reuse the key `done`** — it is the `CompetitionStatus.done` label (`'TERMINE'`, capitals).
- Every new file starts with imports using the `package:live_ffss/...` form, matching the codebase.

---

### Task 1: Bracelet payload contract

The pure function that defines what goes on a bracelet. Isolated because the future `scanRfid()` will read it to know what to parse.

**Files:**
- Create: `lib/app/core/rfid/bracelet_payload.dart`
- Test: `test/core/rfid/bracelet_payload_test.dart`

**Interfaces:**
- Consumes: `Athlete` from `lib/app/domain/models/athlete.dart`
- Produces: `String braceletPayload(Athlete athlete)`

- [ ] **Step 1: Write the failing test**

Create `test/core/rfid/bracelet_payload_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/rfid/bracelet_payload.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';

void main() {
  Athlete athlete({
    String licenseeNumber = '123456',
    String lastName = 'DUPONT',
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
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/core/rfid/bracelet_payload_test.dart
```

Expected: FAIL — `Target of URI doesn't exist: 'package:live_ffss/app/core/rfid/bracelet_payload.dart'`.

- [ ] **Step 3: Write minimal implementation**

Create `lib/app/core/rfid/bracelet_payload.dart`:

```dart
import 'package:live_ffss/app/domain/models/athlete.dart';

/// Field separator for the bracelet payload. The future attendance scanner
/// splits on this, so it must never appear inside a field.
const braceletFieldSeparator = ';';

/// The exact string written to an RFID bracelet: `<licenseeNumber>;<lastName>`.
///
/// This is the contract shared with the (not yet built) bracelet scanner —
/// change it here and the reader changes with it.
String braceletPayload(Athlete athlete) {
  final lastName =
      athlete.lastName.replaceAll(braceletFieldSeparator, ' ');
  return '${athlete.licenseeNumber}$braceletFieldSeparator$lastName';
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/core/rfid/bracelet_payload_test.dart
```

Expected: PASS — 4 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/app/core/rfid/bracelet_payload.dart test/core/rfid/bracelet_payload_test.dart
git commit -m "feat(rfid): add bracelet payload contract"
```

---

### Task 2: RfidWriter seam and RfidException

The abstraction plus the stub used on every non-Android platform. No plugin yet — this task must compile and pass without any NFC dependency.

**Files:**
- Modify: `lib/app/core/errors/app_exception.dart`
- Create: `lib/app/core/rfid/rfid_writer.dart`
- Test: `test/core/rfid/rfid_writer_test.dart`

**Interfaces:**
- Produces:
  - `class RfidException extends AppException` — `const RfidException(String message)`
  - `abstract class RfidWriter` — `bool get isSupported`, `Future<void> write(String payload)`
  - `class UnsupportedRfidWriter implements RfidWriter`

- [ ] **Step 1: Write the failing test**

Create `test/core/rfid/rfid_writer_test.dart`:

```dart
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
```

- [ ] **Step 2: Run test to verify it fails**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/core/rfid/rfid_writer_test.dart
```

Expected: FAIL — `rfid_writer.dart` does not exist.

- [ ] **Step 3: Add the exception arm**

In `lib/app/core/errors/app_exception.dart`, append after `UnknownException`:

```dart
class RfidException extends AppException {
  const RfidException(super.message);
}
```

- [ ] **Step 4: Write the seam**

Create `lib/app/core/rfid/rfid_writer.dart`:

```dart
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
```

- [ ] **Step 5: Run test to verify it passes**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/core/rfid/rfid_writer_test.dart
```

Expected: PASS — 3 tests.

- [ ] **Step 6: Commit**

```bash
git add lib/app/core/errors/app_exception.dart lib/app/core/rfid/rfid_writer.dart test/core/rfid/rfid_writer_test.dart
git commit -m "feat(rfid): add RfidWriter seam and RfidException"
```

---

### Task 3: NDEF text encoding

The bytes of a spec-compliant NDEF Text record. Split from the Android writer because this part is pure and testable, while the writer around it is not.

**Why this exists:** the `nfc_manager` README shows a "text record" whose payload is a bare `utf8.encode('Hello, NFC!')`. That is **not** a valid NDEF Text record. The NFC Forum Text record payload is `[status byte][language code][text]`, where the status byte holds the encoding in bit 7 (`0` = UTF-8) and the language-code length in bits 5–0. Following the README would produce a bracelet that third-party readers render as garbage — which defeats the reason we chose the Text format.

**Files:**
- Create: `lib/app/core/rfid/ndef_text_record.dart`
- Test: `test/core/rfid/ndef_text_record_test.dart`

**Interfaces:**
- Produces: `Uint8List ndefTextPayload(String text, {String languageCode = 'en'})`

- [ ] **Step 1: Write the failing test**

Create `test/core/rfid/ndef_text_record_test.dart`:

```dart
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
```

- [ ] **Step 2: Run test to verify it fails**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/core/rfid/ndef_text_record_test.dart
```

Expected: FAIL — `ndef_text_record.dart` does not exist.

- [ ] **Step 3: Write the implementation**

Create `lib/app/core/rfid/ndef_text_record.dart`:

```dart
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
```

- [ ] **Step 4: Run test to verify it passes**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/core/rfid/ndef_text_record_test.dart
```

Expected: PASS — 5 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/app/core/rfid/ndef_text_record.dart test/core/rfid/ndef_text_record_test.dart
git commit -m "feat(rfid): add spec-compliant NDEF text record encoding"
```

---

### Task 4: Android NFC writer

The adapter over `nfc_manager`. Not unit-tested — mocking it would test the plugin. Verified on a device in Task 9.

**Files:**
- Modify: `pubspec.yaml`
- Modify: `android/app/src/main/AndroidManifest.xml`
- Create: `lib/app/core/rfid/nfc_rfid_writer_impl.dart`

**Interfaces:**
- Consumes: `RfidWriter`, `RfidException` (Task 2); `ndefTextPayload` (Task 3)
- Produces: `class NfcRfidWriterImpl implements RfidWriter` — `const NfcRfidWriterImpl()`

- [ ] **Step 1: Add the dependency**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat pub add nfc_manager
```

Expected: `pubspec.yaml` gains `nfc_manager: ^<version>` under `dependencies`.

- [ ] **Step 2: Confirm the resolved version**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\dart.bat pub deps --style=list | grep -iE "nfc_manager|ndef_record"
```

Expected: `nfc_manager 4.2.1` and `ndef_record 1.4.2`.

**Step 4's code was verified against exactly these versions** by reading the
resolved package source. Three entry points live inside the single
`nfc_manager` package — there is no separate `nfc_manager_android` pub
package, and `nfc_manager.dart` does **not** re-export the record types:

| Import | Provides |
|---|---|
| `package:nfc_manager/nfc_manager.dart` | `NfcManager`, `NfcAvailability`, `NfcPollingOption`, `NfcTag` |
| `package:nfc_manager/nfc_manager_android.dart` | `NdefAndroid` (fields `maxSize`, `isWritable`; `from`, `writeNdefMessage`) |
| `package:nfc_manager/ndef_record.dart` | `NdefMessage`, `NdefRecord`, `TypeNameFormat` |

If `pub deps` reports a different version, **stop and escalate** rather than
adapting Step 4's code from memory — these symbol names were wrong once
already (see "Notes for the reviewer").

- [ ] **Step 3: Add the Android permission**

In `android/app/src/main/AndroidManifest.xml`, add as the first child of `<manifest>`, before `<application>`:

```xml
    <uses-permission android:name="android.permission.NFC"/>
```

- [ ] **Step 4: Write the implementation**

Create `lib/app/core/rfid/nfc_rfid_writer_impl.dart`. All three `nfc_manager`
entry points are needed — see the table in Step 2 for what each provides:

```dart
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
```

- [ ] **Step 5: Verify it analyzes**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat analyze lib/app/core/rfid/
```

Expected: `No issues found!` — this is what confirms Step 2's import choice was right.

- [ ] **Step 6: Commit**

```bash
git add pubspec.yaml pubspec.lock android/app/src/main/AndroidManifest.xml lib/app/core/rfid/nfc_rfid_writer_impl.dart
git commit -m "feat(rfid): add Android NFC bracelet writer"
```

---

### Task 5: DI registration

**Files:**
- Modify: `lib/app/core/di/initial_binding.dart`

**Interfaces:**
- Consumes: `RfidWriter`, `UnsupportedRfidWriter` (Task 2); `NfcRfidWriterImpl` (Task 4)
- Produces: `Get.find<RfidWriter>()` available app-wide

- [ ] **Step 1: Add the imports**

In `lib/app/core/di/initial_binding.dart`, add:

```dart
import 'package:flutter/foundation.dart';
import 'package:live_ffss/app/core/rfid/nfc_rfid_writer_impl.dart';
import 'package:live_ffss/app/core/rfid/rfid_writer.dart';
```

- [ ] **Step 2: Register the writer**

Insert after the `// 3. HTTP` block and before `// 4. Auth data layer`:

```dart
    // 3b. RFID bracelet writer. Android-only; every other platform gets the
    // stub and the UI hides its entry point. `defaultTargetPlatform` rather
    // than dart:io's `Platform.isAndroid` — the latter throws on web, and web
    // is a declared target.
    Get.put<RfidWriter>(
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android
          ? const NfcRfidWriterImpl()
          : const UnsupportedRfidWriter(),
      permanent: true,
    );
```

- [ ] **Step 3: Verify it analyzes**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat analyze lib/app/core/di/
```

Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/app/core/di/initial_binding.dart
git commit -m "feat(rfid): register RfidWriter in InitialBinding"
```

---

### Task 6: Translation keys

**Files:**
- Modify: `lib/app/core/translations/fr_FR.dart`
- Modify: `lib/app/core/translations/en_US.dart`

**Interfaces:**
- Produces: keys `bracelets`, `write_bracelet`, `search_athlete`, `approach_bracelet`, `bracelet_written`, `bracelet_write_failed`, `bracelet_not_writable`, `bracelet_too_small`, `nfc_disabled`, `nfc_unsupported`, `finish`

- [ ] **Step 1: Add the French keys**

Append to the map in `lib/app/core/translations/fr_FR.dart`, before the closing `};`:

```dart
  'bracelets': 'Bracelets',
  'write_bracelet': 'Écrire un bracelet',
  'search_athlete': 'Rechercher un athlète',
  'approach_bracelet': 'Approchez le bracelet du téléphone',
  'bracelet_written': 'Bracelet écrit',
  'bracelet_write_failed': "Échec de l'écriture du bracelet",
  'bracelet_not_writable': "Ce bracelet n'est pas inscriptible",
  'bracelet_too_small': 'La mémoire de ce bracelet est trop petite',
  'nfc_disabled': 'Le NFC est désactivé',
  'nfc_unsupported': "Cet appareil ne peut pas écrire de bracelet",
  'finish': 'Terminé',
```

- [ ] **Step 2: Add the English keys**

Append to the map in `lib/app/core/translations/en_US.dart`, before the closing `};`:

```dart
  'bracelets': 'Bracelets',
  'write_bracelet': 'Write a bracelet',
  'search_athlete': 'Search for an athlete',
  'approach_bracelet': 'Hold the bracelet near the phone',
  'bracelet_written': 'Bracelet written',
  'bracelet_write_failed': 'Could not write the bracelet',
  'bracelet_not_writable': 'This bracelet is not writable',
  'bracelet_too_small': "This bracelet's memory is too small",
  'nfc_disabled': 'NFC is turned off',
  'nfc_unsupported': 'This device cannot write bracelets',
  'finish': 'Done',
```

- [ ] **Step 3: Verify no key was duplicated**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat analyze lib/app/core/translations/
```

Expected: `No issues found!` — a duplicate map key is an analyzer error, so this catches an accidental redefinition of `retry`, `cancel`, `done`, or `no_athletes_found`.

- [ ] **Step 4: Commit**

```bash
git add lib/app/core/translations/fr_FR.dart lib/app/core/translations/en_US.dart
git commit -m "feat(rfid): add bracelet writer translation keys"
```

---

### Task 7: RfidWriterController

**Files:**
- Create: `lib/app/module/competitions/controllers/rfid_writer_controller.dart`
- Test: `test/presentation/modules/competitions/controllers/rfid_writer_controller_test.dart`

**Interfaces:**
- Consumes: `ClubRepository`, `RfidWriter`, `braceletPayload`, `UiMessage`
- Produces:
  - `enum RfidWriteState { idle, waiting, success, error }`
  - `RfidWriterController(ClubRepository clubRepo, RfidWriter rfidWriter)`
  - `Future<void> loadAthletes(int competitionId)`
  - `void setSearchQuery(String value)`
  - `Future<void> writeBracelet(Athlete athlete)`
  - `void cancelWrite()`
  - `String payloadFor(Athlete athlete)`
  - fields: `competition`, `allAthletes`, `filteredAthletes`, `searchQuery`, `isLoading`, `hasError`, `selected`, `writeState`, `message`

- [ ] **Step 1: Write the failing test**

Create `test/presentation/modules/competitions/controllers/rfid_writer_controller_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/core/rfid/rfid_writer.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/module/competitions/controllers/rfid_writer_controller.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';
import 'package:mocktail/mocktail.dart';

class _MockClubRepo extends Mock implements ClubRepository {}

class _MockRfidWriter extends Mock implements RfidWriter {}

void main() {
  late _MockClubRepo repo;
  late _MockRfidWriter writer;
  late RfidWriterController controller;

  Athlete athlete(
    int id,
    String first,
    String last, {
    String licence = '',
    Club? club,
  }) =>
      Athlete(
        id: id,
        licenseeNumber: licence,
        firstName: first,
        lastName: last,
        gender: Gender.male,
        year: 2004,
        nationalityCode: 'FRA',
        nationality: 'France',
        isValid: true,
        club: club,
      );

  final nantes = const Club(id: 1, name: 'SC Nantes');
  final rennes = const Club(id: 2, name: 'SN Rennes');

  setUp(() {
    repo = _MockClubRepo();
    writer = _MockRfidWriter();
    controller = RfidWriterController(repo, writer);
  });

  group('loadAthletes', () {
    test('flattens every club athlete into one list', () async {
      when(() => repo.getClubs(1)).thenAnswer((_) async => [
            nantes.copyWith(athletes: [athlete(1, 'Jean', 'DUPONT')]),
            rennes.copyWith(athletes: [athlete(2, 'Marie', 'DURAND')]),
          ]);

      await controller.loadAthletes(1);

      expect(controller.allAthletes.length, 2);
      expect(controller.isLoading.value, isFalse);
      expect(controller.hasError.value, isFalse);
    });

    test('sorts by last name then first name', () async {
      when(() => repo.getClubs(1)).thenAnswer((_) async => [
            nantes.copyWith(athletes: [
              athlete(1, 'Zoe', 'DURAND'),
              athlete(2, 'Alice', 'DURAND'),
              athlete(3, 'Jean', 'DUPONT'),
            ]),
          ]);

      await controller.loadAthletes(1);

      expect(
        controller.allAthletes.map((a) => '${a.lastName} ${a.firstName}'),
        ['DUPONT Jean', 'DURAND Alice', 'DURAND Zoe'],
      );
    });

    test('deduplicates by athlete id, first occurrence wins', () async {
      when(() => repo.getClubs(1)).thenAnswer((_) async => [
            nantes.copyWith(athletes: [athlete(1, 'Jean', 'DUPONT')]),
            rennes.copyWith(athletes: [athlete(1, 'Jean', 'DUPONT')]),
          ]);

      await controller.loadAthletes(1);

      expect(controller.allAthletes.length, 1);
    });

    test('sets hasError when the repository throws an AppException', () async {
      when(() => repo.getClubs(1))
          .thenThrow(const NetworkException('offline'));

      await controller.loadAthletes(1);

      expect(controller.hasError.value, isTrue);
      expect(controller.isLoading.value, isFalse);
      expect(controller.allAthletes, isEmpty);
    });
  });

  group('setSearchQuery', () {
    setUp(() async {
      when(() => repo.getClubs(1)).thenAnswer((_) async => [
            nantes.copyWith(athletes: [
              athlete(1, 'Jean', 'DUPONT', licence: '123456', club: nantes),
            ]),
            rennes.copyWith(athletes: [
              athlete(2, 'Marie', 'DURAND', licence: '999888', club: rennes),
            ]),
          ]);
      await controller.loadAthletes(1);
    });

    test('matches on last name, case-insensitively', () {
      controller.setSearchQuery('dupont');
      expect(controller.filteredAthletes.single.id, 1);
    });

    test('matches on first name', () {
      controller.setSearchQuery('Marie');
      expect(controller.filteredAthletes.single.id, 2);
    });

    test('matches on licensee number', () {
      controller.setSearchQuery('999');
      expect(controller.filteredAthletes.single.id, 2);
    });

    test('matches on club name', () {
      controller.setSearchQuery('Nantes');
      expect(controller.filteredAthletes.single.id, 1);
    });

    test('an empty query restores the full list', () {
      controller.setSearchQuery('dupont');
      controller.setSearchQuery('  ');
      expect(controller.filteredAthletes.length, 2);
    });

    test('a query matching nothing yields an empty list', () {
      controller.setSearchQuery('zzz');
      expect(controller.filteredAthletes, isEmpty);
    });
  });

  group('writeBracelet', () {
    final jean = Athlete(
      id: 1,
      licenseeNumber: '123456',
      firstName: 'Jean',
      lastName: 'DUPONT',
      gender: Gender.male,
      year: 2004,
      nationalityCode: 'FRA',
      nationality: 'France',
      isValid: true,
    );

    test('writes the bracelet payload and reports success', () async {
      when(() => writer.write(any())).thenAnswer((_) async {});

      await controller.writeBracelet(jean);

      verify(() => writer.write('123456;DUPONT')).called(1);
      expect(controller.writeState.value, RfidWriteState.success);
      expect(controller.selected.value, jean);
      expect(controller.message.value, isA<UiMessageSuccess>());
    });

    test('surfaces an RfidException as an error state and message', () async {
      when(() => writer.write(any()))
          .thenThrow(const RfidException('bracelet_not_writable'));

      await controller.writeBracelet(jean);

      expect(controller.writeState.value, RfidWriteState.error);
      final message = controller.message.value;
      expect(message, isA<UiMessageError>());
      expect(message!.translationKey, 'bracelet_not_writable');
    });

    test('cancelWrite returns to idle and clears the selection', () async {
      when(() => writer.write(any())).thenAnswer((_) async {});
      await controller.writeBracelet(jean);

      controller.cancelWrite();

      expect(controller.writeState.value, RfidWriteState.idle);
      expect(controller.selected.value, isNull);
    });

    test('payloadFor exposes what will be written, for the UI preview', () {
      expect(controller.payloadFor(jean), '123456;DUPONT');
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/presentation/modules/competitions/controllers/rfid_writer_controller_test.dart
```

Expected: FAIL — `rfid_writer_controller.dart` does not exist.

- [ ] **Step 3: Write the controller**

Create `lib/app/module/competitions/controllers/rfid_writer_controller.dart`:

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/core/rfid/bracelet_payload.dart';
import 'package:live_ffss/app/core/rfid/rfid_writer.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';

enum RfidWriteState { idle, waiting, success, error }

class RfidWriterController extends GetxController {
  RfidWriterController(this._clubRepo, this._rfidWriter);

  final ClubRepository _clubRepo;
  final RfidWriter _rfidWriter;

  final Rxn<Competition> competition = Rxn<Competition>();
  final RxList<Athlete> allAthletes = <Athlete>[].obs;
  final RxList<Athlete> filteredAthletes = <Athlete>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final Rxn<Athlete> selected = Rxn<Athlete>();
  final Rx<RfidWriteState> writeState = RfidWriteState.idle.obs;
  final Rxn<UiMessage> message = Rxn<UiMessage>();

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is Competition) {
      competition.value = arg;
      loadAthletes(arg.id);
    } else {
      isLoading.value = false;
    }
  }

  Future<void> loadAthletes(int competitionId) async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final clubs = await _clubRepo.getClubs(competitionId);

      // Dedupe by id: the same athlete can surface under more than one club.
      // First occurrence wins, in repository order.
      final byId = <int, Athlete>{};
      for (final club in clubs) {
        for (final athlete in club.athletes) {
          byId.putIfAbsent(athlete.id, () => athlete);
        }
      }

      final sorted = byId.values.toList()
        ..sort((a, b) {
          final byLast =
              a.lastName.toLowerCase().compareTo(b.lastName.toLowerCase());
          if (byLast != 0) return byLast;
          return a.firstName.toLowerCase().compareTo(b.firstName.toLowerCase());
        });

      allAthletes.value = sorted;
      _applyFilter();
    } on AppException {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void setSearchQuery(String value) {
    searchQuery.value = value;
    _applyFilter();
  }

  void _applyFilter() {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) {
      filteredAthletes.value = List.from(allAthletes);
      return;
    }
    filteredAthletes.value = allAthletes.where((a) {
      return a.lastName.toLowerCase().contains(q) ||
          a.firstName.toLowerCase().contains(q) ||
          a.licenseeNumber.toLowerCase().contains(q) ||
          (a.club?.name.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  /// What [writeBracelet] will put on the chip. The sheet shows this so the
  /// volunteer can see the exact string before presenting a bracelet.
  String payloadFor(Athlete athlete) => braceletPayload(athlete);

  Future<void> writeBracelet(Athlete athlete) async {
    selected.value = athlete;
    writeState.value = RfidWriteState.waiting;
    message.value = null;
    try {
      await _rfidWriter.write(braceletPayload(athlete));
      writeState.value = RfidWriteState.success;
      message.value = const UiMessageSuccess('bracelet_written');
    } on AppException catch (e) {
      writeState.value = RfidWriteState.error;
      message.value = UiMessageError(e.message);
    }
  }

  void cancelWrite() {
    writeState.value = RfidWriteState.idle;
    selected.value = null;
    message.value = null;
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/presentation/modules/competitions/controllers/rfid_writer_controller_test.dart
```

Expected: PASS — 15 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/app/module/competitions/controllers/rfid_writer_controller.dart test/presentation/modules/competitions/controllers/rfid_writer_controller_test.dart
git commit -m "feat(rfid): add RfidWriterController with athlete search"
```

---

### Task 8: Route, binding, and RfidWriterView

**Files:**
- Create: `lib/app/module/competitions/bindings/rfid_writer_binding.dart`
- Create: `lib/app/module/competitions/views/rfid_writer_view.dart`
- Modify: `lib/app/routes/app_routes.dart`
- Modify: `lib/app/routes/app_pages.dart`

**Interfaces:**
- Consumes: `RfidWriterController`, `RfidWriteState`, `ClubRepository`, `RfidWriter`
- Produces: `Routes.rfidWriter` (`'/rfid-writer'`), `RfidWriterBinding`, `RfidWriterView`

- [ ] **Step 1: Write the binding**

Create `lib/app/module/competitions/bindings/rfid_writer_binding.dart`:

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/core/rfid/rfid_writer.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import '../controllers/rfid_writer_controller.dart';

class RfidWriterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RfidWriterController>(
      () => RfidWriterController(
        Get.find<ClubRepository>(),
        Get.find<RfidWriter>(),
      ),
    );
  }
}
```

- [ ] **Step 2: Add the route constant**

In `lib/app/routes/app_routes.dart`, add before the `// Add other routes here` comment:

```dart
  static const rfidWriter = '/rfid-writer';
```

- [ ] **Step 3: Register the page**

In `lib/app/routes/app_pages.dart`, add the imports:

```dart
import 'package:live_ffss/app/module/competitions/bindings/rfid_writer_binding.dart';
import 'package:live_ffss/app/module/competitions/views/rfid_writer_view.dart';
```

and add to the `routes` list, after the `raceDetail` page:

```dart
    GetPage(
      name: Routes.rfidWriter,
      page: () => const RfidWriterView(),
      binding: RfidWriterBinding(),
    ),
```

- [ ] **Step 4: Write the view**

Create `lib/app/module/competitions/views/rfid_writer_view.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/module/competitions/controllers/rfid_writer_controller.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';
import 'package:live_ffss/app/presentation/shared/error_state.dart';
import 'package:live_ffss/app/presentation/shared/home_wave.dart';
import 'package:live_ffss/app/presentation/shared/loading_indicator.dart';

class RfidWriterView extends StatefulWidget {
  const RfidWriterView({super.key});

  @override
  State<RfidWriterView> createState() => _RfidWriterViewState();
}

class _RfidWriterViewState extends State<RfidWriterView> {
  // Lives in the view, not the controller: it is scoped to this screen only.
  final _searchController = TextEditingController();
  final _controller = Get.find<RfidWriterController>();
  Worker? _writeStateWorker;

  @override
  void initState() {
    super.initState();
    // The sheet is opened by the view, never by the controller — controllers
    // must not call Get.dialog / showModalBottomSheet.
    _writeStateWorker = ever<RfidWriteState>(_controller.writeState, (state) {
      if (state == RfidWriteState.waiting && ModalRoute.of(context)?.isCurrent == true) {
        _openSheet();
      }
    });
  }

  @override
  void dispose() {
    _writeStateWorker?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openSheet() {
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: AppColors.surface,
      builder: (_) => const _WriteSheet(),
    ).whenComplete(_controller.cancelWrite);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(searchController: _searchController),
            const HomeWave(),
            const SizedBox(height: AppSpacing.sm),
            const Expanded(child: _AthleteList()),
          ],
        ),
      ),
    );
  }
}

class _Header extends GetView<RfidWriterController> {
  const _Header({required this.searchController});

  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xs,
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.md,
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: Get.back,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Obx(() {
                  final competition = controller.competition.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'bracelets'.tr,
                        style: AppTypography.title.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      if (competition != null)
                        Text(
                          competition.name,
                          style: AppTypography.body.copyWith(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: AppSpacing.pageHorizontal,
            child: TextField(
              controller: searchController,
              onChanged: controller.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'search_athlete'.tr,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.pillRadius,
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AthleteList extends GetView<RfidWriterController> {
  const _AthleteList();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const LoadingIndicator();
      }
      if (controller.hasError.value) {
        return ErrorState(
          message: 'error_occured'.tr,
          onRetry: () {
            final competition = controller.competition.value;
            if (competition != null) {
              controller.loadAthletes(competition.id);
            }
          },
        );
      }
      final athletes = controller.filteredAthletes;
      if (athletes.isEmpty) {
        return EmptyState(
          icon: Icons.person_search,
          title: 'no_athletes_found'.tr,
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm,
          AppSpacing.xs,
          AppSpacing.sm,
          AppSpacing.lg,
        ),
        itemCount: athletes.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, i) => _AthleteRow(athlete: athletes[i]),
      );
    });
  }
}

class _AthleteRow extends GetView<RfidWriterController> {
  const _AthleteRow({required this.athlete});

  final Athlete athlete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: () => controller.writeBracelet(athlete),
        title: Text(
          '${athlete.lastName} ${athlete.firstName}',
          style: AppTypography.body,
        ),
        // The licence number is what goes on the chip: showing it is how a
        // volunteer notices they picked the wrong athlete.
        subtitle: Text(athlete.licenseeNumber, style: AppTypography.caption),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (athlete.club != null)
              Text(athlete.club!.name, style: AppTypography.caption),
            const SizedBox(width: AppSpacing.xs),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class _WriteSheet extends GetView<RfidWriterController> {
  const _WriteSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.pageAll,
      child: Obx(() {
        final state = controller.writeState.value;
        final athlete = controller.selected.value;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            switch (state) {
              RfidWriteState.success => const Icon(
                  Icons.check_circle,
                  size: 64,
                  // The palette has no `statusSuccess`; `statusFinished` is
                  // its green (0xFF43A047).
                  color: AppColors.statusFinished,
                ),
              RfidWriteState.error => const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.statusError,
                ),
              _ => const Icon(Icons.nfc, size: 64, color: AppColors.primary),
            },
            const SizedBox(height: AppSpacing.md),
            Text(
              switch (state) {
                RfidWriteState.success => 'bracelet_written'.tr,
                RfidWriteState.error =>
                  (controller.message.value?.translationKey ??
                          'bracelet_write_failed')
                      .tr,
                _ => 'approach_bracelet'.tr,
              },
              style: AppTypography.subtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            if (athlete != null)
              Text(
                controller.payloadFor(athlete),
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (state == RfidWriteState.error && athlete != null)
                  TextButton(
                    onPressed: () => controller.writeBracelet(athlete),
                    child: Text('retry'.tr),
                  ),
                TextButton(
                  onPressed: Get.back<void>,
                  child: Text(
                    state == RfidWriteState.success
                        ? 'finish'.tr
                        : 'cancel'.tr,
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}
```

- [ ] **Step 5: Verify it analyzes**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat analyze lib/app/module/competitions/ lib/app/routes/
```

Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add lib/app/module/competitions/bindings/rfid_writer_binding.dart lib/app/module/competitions/views/rfid_writer_view.dart lib/app/routes/app_routes.dart lib/app/routes/app_pages.dart
git commit -m "feat(rfid): add bracelet writer screen and route"
```

---

### Task 9: Entry point in the competition detail header

**Files:**
- Modify: `lib/app/module/competitions/controllers/competition_detail_controller.dart`
- Modify: `lib/app/module/competitions/bindings/competition_detail_binding.dart`
- Modify: `lib/app/module/competitions/views/competition_detail_view.dart:82-93`
- Test: `test/presentation/modules/competitions/controllers/competition_detail_controller_test.dart` (**new file** — this controller has no test today)

**Interfaces:**
- Consumes: `RfidWriter` (Task 2), `Routes.rfidWriter` (Task 8)
- Produces: `CompetitionDetailController(UserPreferencesService prefs, RfidWriter rfidWriter)` with `bool get canWriteBracelets`

- [ ] **Step 1: Write the failing test**

Create `test/presentation/modules/competitions/controllers/competition_detail_controller_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/rfid/rfid_writer.dart';
import 'package:live_ffss/app/data/services/user_preferences_service.dart';
import 'package:live_ffss/app/module/competitions/controllers/competition_detail_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockPrefs extends Mock implements UserPreferencesService {}

class _MockRfidWriter extends Mock implements RfidWriter {}

void main() {
  late _MockPrefs prefs;
  late _MockRfidWriter writer;

  setUp(() {
    prefs = _MockPrefs();
    writer = _MockRfidWriter();
  });

  group('canWriteBracelets', () {
    test('is true when the writer is supported', () {
      when(() => writer.isSupported).thenReturn(true);
      final controller = CompetitionDetailController(prefs, writer);
      expect(controller.canWriteBracelets, isTrue);
    });

    test('is false when the writer is a stub', () {
      when(() => writer.isSupported).thenReturn(false);
      final controller = CompetitionDetailController(prefs, writer);
      expect(controller.canWriteBracelets, isFalse);
    });
  });

  group('favorites', () {
    test('favoriteIds is delegated to the preferences service', () {
      final ids = <int>{7}.obs;
      when(() => prefs.favoriteIds).thenReturn(ids);
      when(() => writer.isSupported).thenReturn(true);

      final controller = CompetitionDetailController(prefs, writer);

      expect(controller.favoriteIds, ids);
    });

    test('toggleFavorite is delegated to the preferences service', () async {
      when(() => prefs.toggleFavorite(7)).thenAnswer((_) async {});
      when(() => writer.isSupported).thenReturn(true);

      await CompetitionDetailController(prefs, writer).toggleFavorite(7);

      verify(() => prefs.toggleFavorite(7)).called(1);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/presentation/modules/competitions/controllers/competition_detail_controller_test.dart
```

Expected: FAIL — `CompetitionDetailController` takes one argument, not two.

- [ ] **Step 3: Update the controller**

In `lib/app/module/competitions/controllers/competition_detail_controller.dart`, add the import:

```dart
import 'package:live_ffss/app/core/rfid/rfid_writer.dart';
```

Change the constructor and fields:

```dart
class CompetitionDetailController extends GetxController {
  CompetitionDetailController(this._prefs, this._rfidWriter);

  final UserPreferencesService _prefs;
  final RfidWriter _rfidWriter;
```

and add next to the other getters:

```dart
  /// Whether this device can write RFID bracelets. The header hides its NFC
  /// button when false rather than showing a disabled control that would need
  /// explaining.
  bool get canWriteBracelets => _rfidWriter.isSupported;
```

- [ ] **Step 4: Update the binding**

In `lib/app/module/competitions/bindings/competition_detail_binding.dart`, add the import:

```dart
import 'package:live_ffss/app/core/rfid/rfid_writer.dart';
```

and change the registration:

```dart
    Get.lazyPut<CompetitionDetailController>(
      () => CompetitionDetailController(
        Get.find<UserPreferencesService>(),
        Get.find<RfidWriter>(),
      ),
    );
```

- [ ] **Step 5: Run test to verify it passes**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test test/presentation/modules/competitions/controllers/competition_detail_controller_test.dart
```

Expected: PASS — 4 tests.

- [ ] **Step 6: Add the button to the header**

In `lib/app/module/competitions/views/competition_detail_view.dart`, in `_CompetitionDetailHeader`'s first `Row` (currently `IconButton(back)` → `Spacer()` → `Obx(star)`), insert between the `Spacer()` and the star's `Obx`:

```dart
              if (controller.canWriteBracelets)
                IconButton(
                  icon: const Icon(Icons.nfc, color: Colors.white, size: 26),
                  tooltip: 'write_bracelet'.tr,
                  onPressed: () => Get.toNamed<void>(
                    Routes.rfidWriter,
                    arguments: competition,
                  ),
                ),
```

Add the import for the route constants:

```dart
import 'package:live_ffss/app/routes/app_pages.dart';
```

- [ ] **Step 7: Verify the whole suite and analyzer**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat analyze
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test
```

Expected: `No issues found!` and every test passing.

- [ ] **Step 8: Commit**

```bash
git add lib/app/module/competitions/controllers/competition_detail_controller.dart lib/app/module/competitions/bindings/competition_detail_binding.dart lib/app/module/competitions/views/competition_detail_view.dart test/presentation/modules/competitions/controllers/competition_detail_controller_test.dart
git commit -m "feat(rfid): add bracelet writer entry point to competition header"
```

---

### Task 10: Device verification

`NfcRfidWriterImpl` has no unit tests by design — this task is how it gets verified. It cannot be done by an agent; it needs a human, an Android phone, and a bracelet.

**Files:** none

- [ ] **Step 1: Run on a physical Android device**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat run -d <android-device-id>
```

- [ ] **Step 2: Walk the happy path**

Open any competition → confirm the NFC icon appears in the header → tap it → search an athlete by name, then by licence number, then by club → tap a row → confirm the sheet shows the exact payload → present a blank NTAG bracelet → confirm "Bracelet écrit".

- [ ] **Step 3: Verify the tag with a third-party reader**

Read the bracelet with NFC Tools (or any generic NFC reader). It must show a **Text** record whose content is exactly `123456;DUPONT`. Garbage or an unrecognised record type means `ndefTextPayload` is wrong — this check is the whole reason the Text format was chosen.

- [ ] **Step 4: Walk the failure paths**

- NFC turned off in Android settings → expect "Le NFC est désactivé".
- A read-only or non-NDEF tag → expect "Ce bracelet n'est pas inscriptible".
- Cancel the sheet mid-wait, then immediately write again → the second write must work. A failure here means the session was not stopped in `finally`.

- [ ] **Step 5: Confirm the button is hidden off-Android**

```bash
C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat run -d chrome
```

The NFC icon must not appear in the competition header, and nothing may throw.

---

## Notes for the reviewer

- **`nfc_manager` API — corrected after a first attempt.** Task 4 was originally written from the package's published docs and was **wrong in three ways**, caught when an implementer inspected the resolved source at v4.2.1 rather than trusting the plan:
  - `TypeNameFormat.nfcWellKnown` does not exist — the enum arm is `wellKnown`.
  - `NdefMessage.toByteData()` does not exist — the capacity check uses `NdefMessage.byteLength`, which already sums record headers.
  - There is no `nfc_manager_android` pub package. Three entry points live inside `nfc_manager` itself, and `nfc_manager.dart` does **not** re-export the record types.

  Step 2's table is now verified against the installed source. If `pub deps` shows anything other than `nfc_manager 4.2.1` / `ndef_record 1.4.2`, treat Step 4's code as unverified again and escalate rather than adapting it from memory.
- **The plugin README's text-record example is wrong.** It writes `utf8.encode(text)` as a Text payload with no status byte or language code. Task 3 exists precisely to not follow it.
- **iOS is deliberately unbuilt.** `UnsupportedRfidWriter` covers it. Enabling it later needs the Core NFC entitlement, `NFCReaderUsageDescription`, an `NdefIos` write path, and very likely an `IPHONEOS_DEPLOYMENT_TARGET` bump from the current 12.0.
