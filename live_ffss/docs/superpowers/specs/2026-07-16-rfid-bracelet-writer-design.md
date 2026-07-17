# RFID Bracelet Writer — Design

**Date:** 2026-07-16
**Status:** Approved (pending spec review)

## Goal

Let a volunteer provision RFID bracelets for a competition: from the
competition detail screen, open a dedicated screen, search the competition's
athletes, pick one, and write their identity to an NFC bracelet.

The payload is a single NDEF Text record containing
`<licenseeNumber>;<lastName>` — e.g. `123456;DUPONT`.

## Context

An RFID story already exists in the codebase, half-built:

- `RaceDetailController.scanRfid()` is an empty placeholder with a
  `// TODO(rfid)` marker (`race_detail_controller.dart:274-276`).
- The Entries tab has a "Scanner un bracelet" button that shows
  "Scan RFID bientôt disponible" (`race_detail_entries_view.dart:43-45`).
- Translation keys `scan_bracelet` and `rfid_coming_soon` exist in both
  locales.

That is the **read** side: scan a bracelet to mark attendance. This spec
builds the **write** side that provisions the bracelet the scanner will
later consume. The two halves share one contract: the payload format.

Nothing else exists. There is no NFC dependency in `pubspec.yaml` and no
NFC configuration in `android/` or `ios/`.

The athlete data needed is already reachable without new endpoints:
`ClubRepository.getClubs(competitionId)` returns `Club`s each carrying their
`athletes`, and `ClubMapper` populates a lightweight `club` back-reference on
every athlete (`club_mapper.dart:24`) holding `id`, `name`, `shortName`, and
`logoUrl`.

## Decisions taken during brainstorming

| Question | Decision | Rationale |
|---|---|---|
| Where does the entry point live? | Competition detail header, not race detail | The data displayed and the athlete list are competition-scoped |
| A "Paramètres" recap page? | **Dropped** | The header already shows name, date range, location, and organizer logo — the page would only have duplicated it |
| Payload fields | `licenseeNumber;lastName` only | Originally `nom;prénom;club;date de naissance;numéro de licence`; cut to reduce PII on a losable object and because attendance only needs the licence number |
| Birth date | **Moot** — field removed | `Athlete` only carries `int year`, never a full date. Dropping the field removed the blocker |
| Platforms | Android now, iOS behind an abstraction | Field devices are mostly Android; iOS needs a paid Core NFC entitlement |
| Encoding | NDEF Text (well-known `T`, UTF-8) | Readable by any standard NFC reader (e.g. NFC Tools), which makes a mis-written bracelet diagnosable without the app |
| Search scope | Free text over last name, first name, licence number, club name | Matches the existing Clubs-pill search behaviour |

## Architecture

### RFID layer — `lib/app/core/rfid/`

A hardware capability behind an interface, sitting beside `core/network/`
for the same reason: an external dependency the app talks to through a seam.

```dart
abstract class RfidWriter {
  bool get isSupported;
  Future<void> write(String payload);
  Future<void> cancel();
}
```

`cancel()` is not optional polish. Without it the *Annuler* button cannot keep
its promise: the NFC session stays open with its tag callback live, and the
**next** bracelet presented gets silently written with the cancelled athlete's
payload. `write()` also never completes on its own if no bracelet is ever
presented — `startSession` returns as soon as reader mode is on, it does not
wait for a tag — so `cancel()` is the only thing that releases it.

- `NfcRfidWriterImpl` — the Android path via `nfc_manager`:
  `NdefAndroid.from(tag)` → check `isWritable` → `writeNdefMessage`.
- `UnsupportedRfidWriter` — `isSupported => false`; `write` throws
  `RfidException`. This is the iOS/web/desktop stub, following the same
  pattern as `RankingRemoteDataSourceImpl`.

Selection happens in `InitialBinding` using
`defaultTargetPlatform == TargetPlatform.android && !kIsWeb` from
`package:flutter/foundation.dart`.

**Not** `Platform.isAndroid` from `dart:io` — that throws on web, and `web/`
is a declared target of this project.

`nfc_manager` v4 has no unified write API: Android goes through
`NdefAndroid` / `writeNdefMessage` / `isWritable`, iOS through `NdefIos` /
`writeNdef` / `status == NdefStatusIos.readWrite`. The write path forks per
platform regardless, which is part of why the abstraction earns its keep.

### Error type

`RfidException extends AppException` added to the sealed family in
`core/errors/app_exception.dart`. Controllers already catch `AppException`
by convention, so no new rule to remember.

### Payload — a pure function

`lib/app/core/rfid/bracelet_payload.dart`:

```dart
String braceletPayload(Athlete athlete) => ...
```

Returns `'${athlete.licenseeNumber};${athlete.lastName}'`, with any `;`
inside the last name neutralised (replaced with a space) so the separator
stays unambiguous.

Isolated as its own function because it is the contract shared with the
future `scanRfid()`: when the attendance scanner parses a bracelet, this
function is what tells it what to expect.

### Screen — inside the `competitions` module

No new module. The screen is competition-scoped and opens from competition
detail, exactly like `race_detail`.

## Components

### New files

- `lib/app/core/rfid/rfid_writer.dart` — the `RfidWriter` abstraction plus
  `UnsupportedRfidWriter`.
- `lib/app/core/rfid/nfc_rfid_writer_impl.dart` — the Android `nfc_manager`
  adapter.
- `lib/app/core/rfid/bracelet_payload.dart` — the pure payload function.
- `lib/app/core/rfid/ndef_text_record.dart` — `Uint8List ndefTextPayload(String
  text, {String languageCode = 'en'})`, the bytes of an NFC Forum well-known
  Text record: `[status byte][language code][UTF-8 text]`. Split out because it
  is pure and testable while the plugin adapter around it is not. The plugin's
  README shows a bare `utf8.encode(text)` as a Text payload, which omits the
  header and renders as garbage in third-party readers — being readable by a
  generic NFC app is the whole reason this format was chosen, so the header is
  not optional.
- `lib/app/module/competitions/controllers/rfid_writer_controller.dart`
- `lib/app/module/competitions/views/rfid_writer_view.dart`
- `lib/app/module/competitions/bindings/rfid_writer_binding.dart` —
  registers `RfidWriterController` only.

### Modified files

- `pubspec.yaml` — add `nfc_manager`.
- `android/app/src/main/AndroidManifest.xml` — add
  `<uses-permission android:name="android.permission.NFC"/>`.
- `lib/app/core/errors/app_exception.dart` — add the `RfidException` arm.
- `lib/app/core/di/initial_binding.dart` — register `RfidWriter` (permanent),
  choosing impl vs stub by platform.
- `lib/app/routes/app_pages.dart` — add `Routes.rfidWriter = '/rfid-writer'`
  and its `GetPage` with `RfidWriterBinding`. `Get.arguments` carries the
  `Competition`.
- `lib/app/module/competitions/bindings/competition_detail_binding.dart` —
  pass `RfidWriter` into `CompetitionDetailController`.
- `lib/app/module/competitions/controllers/competition_detail_controller.dart`
  — take `RfidWriter` as a second constructor arg; expose
  `bool get canWriteBracelets => _rfidWriter.isSupported`.
- `lib/app/module/competitions/views/competition_detail_view.dart` — add the
  NFC `IconButton` to `_CompetitionDetailHeader`'s top row.
- `lib/app/core/translations/en_US.dart` + `fr_FR.dart` — new keys (table
  below).

## Controller

```dart
class RfidWriterController extends GetxController {
  RfidWriterController(this._clubRepo, this._rfidWriter);
  // ...
}
```

State:

- `Rxn<Competition> competition` — from `Get.arguments` in `onInit`.
- `RxList<Athlete> allAthletes` — clubs' `athletes` flattened, deduplicated
  by athlete id (first occurrence wins; clubs are iterated in the order the
  repository returns them), sorted by last name then first name.
- `RxList<Athlete> filteredAthletes`
- `RxString searchQuery`
- `RxBool isLoading` / `RxBool hasError`
- `Rxn<Athlete> selected`
- `Rx<RfidWriteState> writeState` — `idle` / `waiting` / `success` / `error`
- `Rxn<UiMessage> message`

Search matches, case-insensitively, any of: last name, first name, licence
number, `club?.name`.

No `Get.snackbar`, no `.tr`, no `Get.dialog` in the controller — per the
controller-discipline rules. The bottom sheet is driven by the view via an
`ever()` on `writeState`.

## UI

### Entry point

An `IconButton(Icons.nfc)` in `_CompetitionDetailHeader`'s top row, between
the `Spacer()` and the favorites star, inside the existing `Obx`. When
`canWriteBracelets` is false the icon is simply not built — on
iOS/web/desktop the bar looks exactly as it does today, with no gap and no
greyed-out button that would need explaining.

Tapping it: `Get.toNamed(Routes.rfidWriter, arguments: competition)`.

### RfidWriterView

Same visual skeleton as the rest of the module (`AppColors.primary` banner,
`HomeWave`, `AppColors.surfaceMuted` background).

```
┌──────────────────────────────────────┐
│  ←   Bracelets                       │
│      Championnat de France 2026      │
│  ┌────────────────────────────────┐  │
│  │ 🔍 Rechercher un athlète       │  │
│  └────────────────────────────────┘  │
├──────────────────────────────────────┤
│  DUPONT Jean            SC Nantes    │
│  123456                          ›   │
├──────────────────────────────────────┤
│  DURAND Marie           SN Rennes    │
│  123457                          ›   │
└──────────────────────────────────────┘
```

Each row shows name, club, and **licence number**. The licence number is
shown because it is what goes on the bracelet: if the wrong athlete is
written, the number is what makes it noticeable.

Body states, in priority order: `LoadingIndicator` → `ErrorState` (retry) →
`EmptyState(icon: Icons.person_search, title: 'no_athletes_found'.tr)` →
`ListView.separated`.

The search `TextEditingController` lives in the view, which is a
`StatefulWidget` — per the rule against view-scoped controllers in
controllers.

### Write sheet

Tapping an athlete opens a `showModalBottomSheet` driven by `writeState`:

- **`waiting`** — NFC icon, "Approchez le bracelet du téléphone", and the
  exact payload in monospace (`123456;DUPONT`). *Annuler* releases the NFC
  session via `cancel()`.
- **`success`** — green check, "Bracelet écrit", *Terminé* button. The sheet
  stays open until the user acts: auto-dismissing would leave doubt about
  what was just written, and volunteers write bracelets in a run while
  watching the screen.
- **`error`** — the message, plus *Réessayer* and *Annuler*.

## Error handling

| Case | Detection | Message key |
|---|---|---|
| Chip is not NDEF | `NdefAndroid.from(tag)` returns `null` | `bracelet_not_writable` |
| Chip is read-only | `isWritable == false` | `bracelet_not_writable` |
| Payload exceeds capacity | encoded NDEF message byte length > `maxSize`, checked before writing | `bracelet_too_small` |
| Write failed | plugin throws | `bracelet_write_failed` |
| NFC disabled in settings | session fails to start | `nfc_disabled` |

All are surfaced as `RfidException` carrying the key.

The capacity check happens **before** writing rather than letting the plugin
fail: on a very small chip a partial write would leave a half-provisioned
bracelet that still reads without error — precisely the bracelet that makes
attendance fail on race day with no visible cause.

The check compares **encoded bytes**, not `String.length`. `.length` counts
UTF-16 code units, so an accented last name ("MÜLLER") weighs more bytes than
characters and would slip past a naive check onto a chip too small to hold
it. Compare against the serialised NDEF message length — which also accounts
for record headers, not just the text — and let `maxSize` come from
`NdefAndroid`.

The NFC session is closed in a `finally`, including on cancellation. A
session left open blocks subsequent writes.

## Testing

Per CLAUDE.md: logic layers only, no widget tests.

- `test/core/rfid/bracelet_payload_test.dart` — nominal case; empty last
  name; last name containing `;` (must be neutralised); accents preserved
  through UTF-8.
- `test/presentation/modules/competitions/controllers/rfid_writer_controller_test.dart`
  — mock `ClubRepository` + `RfidWriter`. Covers: flatten/dedupe/sort of
  athletes; filtering across all four fields; load failure (`AppException` →
  `hasError`); `writeState` transitions on success and on `RfidException`.
- `test/presentation/modules/competitions/controllers/competition_detail_controller_test.dart`
  — **new file**. `CompetitionDetailController` has no test today (the only
  competition controller without one). Since this spec changes its
  constructor, add the test: `canWriteBracelets` in both directions, plus
  `toggleFavorite` delegating to `UserPreferencesService`.

`NfcRfidWriterImpl` is **not** unit-tested. It is a thin adapter over
`nfc_manager`; mocking it would test the plugin, not our code. It is
verified on an Android device with a real bracelet.

## New dependency

`nfc_manager`. The project rule is to justify every new dependency: NFC is
unreachable without a native plugin, and this is the best-documented package
in the space. It brings the Android `NFC` permission with it.

## Out of scope

- **Reading bracelets.** `RaceDetailController.scanRfid()` stays a stub. This
  spec only guarantees the format it will one day parse.
- **iOS.** The `UnsupportedRfidWriter` stub covers it. Enabling iOS later
  needs: the Core NFC entitlement (paid Apple Developer account),
  `NFCReaderUsageDescription` in `Info.plist`, an `NdefIos` write path, and
  very likely a bump of `IPHONEOS_DEPLOYMENT_TARGET`, currently **12.0**.
- **A competition settings/recap page.** Dropped as redundant with the header.
- **Batch writing** (queueing several athletes for one session).
- **Reading back a bracelet to verify it** after writing.
- **Locking bracelets read-only** (`makeReadOnly` is permanent; not wanted for
  reusable bracelets).

## Translation keys

### New keys

Add to both `en_US.dart` and `fr_FR.dart`:

| Key | English | French |
|---|---|---|
| `bracelets` | Bracelets | Bracelets |
| `write_bracelet` | Write a bracelet | Écrire un bracelet |
| `search_athlete` | Search for an athlete | Rechercher un athlète |
| `approach_bracelet` | Hold the bracelet near the phone | Approchez le bracelet du téléphone |
| `bracelet_written` | Bracelet written | Bracelet écrit |
| `bracelet_write_failed` | Could not write the bracelet | Échec de l'écriture du bracelet |
| `bracelet_not_writable` | This bracelet is not writable | Ce bracelet n'est pas inscriptible |
| `bracelet_too_small` | This bracelet's memory is too small | La mémoire de ce bracelet est trop petite |
| `nfc_disabled` | NFC is turned off | Le NFC est désactivé |
| `nfc_unsupported` | This device cannot write bracelets | Cet appareil ne peut pas écrire de bracelet |
| `bracelet_write_cancelled` | Write cancelled | Écriture annulée |
| `finish` | Done | Terminé |

`nfc_unsupported` is what `UnsupportedRfidWriter` throws. The UI hides the
entry point on those platforms, so it should never surface — it exists so
that a wiring mistake produces a readable message instead of a raw exception.

### Existing keys to reuse — do not redefine

- `retry` → "Réessayer" (already used by `ErrorState`)
- `cancel` → "Annuler"
- `no_athletes_found` → "Aucun athlète trouvé" (already used by `slot_view`)

### Do NOT reuse `done`

`'done'` already exists but is the **`CompetitionStatus.done` label** —
`'TERMINE'` / `'DONE'`, in capitals, consumed by
`competition_formatting.dart:68`. Reusing it for the success button would
render "TERMINE" and couple two unrelated concepts. Hence the new `finish`
key above.

`scan_bracelet` and `rfid_coming_soon` are untouched — they belong to the
scan path, which stays a stub.
