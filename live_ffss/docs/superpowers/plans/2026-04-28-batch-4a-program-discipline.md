# Batch 4a — Program Module Discipline Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Apply the controller-discipline rules from the design spec to the Program module, WITHOUT migrating the Meeting/Slot/Run data hierarchy yet. `ProgramController` becomes constructor-injected, drops `Get.context!`/`Get.snackbar`/`TextEditingController`/`GlobalKey`. The add-meeting form moves into a `StatefulWidget` dialog. A new `MeetingRepository` wraps `ApiService` as a transitional shim (returns legacy `MeetingModel` for now). Data-layer migration of Meeting+Slot+Run gets folded into Batch 5.

**Architecture:** Per design spec §8 (controller discipline). The new `MeetingRepository` lives in `lib/app/data/repositories/` but its return type is the legacy `MeetingModel` — an explicit transitional shim documented in code comments. No new DTOs/mappers/domain models in 4a.

**Tech Stack:** Same — GetX, mocktail, no new deps.

---

## Notes & deviations from spec

1. **Batch 4 split into 4a + 4b.** Original spec §14 batch was "Meeting + Entry + Heat domains (Program module)" — full data + presentation. After exploring the legacy code, the data tree is deeply interlinked: `Meeting → List<Slot> → List<Run>`, and the program view renders all the way down. Migrating Meeting in isolation (without Slot/Run) leaves either dirty `List<dynamic>` casts in views or a half-migrated mess. Migrating the whole tree at once is also blocked because Run entangles with Batch 5's `LiveResult`/SlotController work.

   **Pragmatic split:**
   - **Batch 4a** (this plan): Controller discipline only. ProgramController stops being a god-controller; the dialog form becomes self-contained. Data types stay legacy.
   - **Batch 4b** (combined with Batch 5 in a single later plan): Full Meeting+Slot+Run+LiveResult domain migration + SlotController refactor.

2. **Entry and Heat domains are not migrated here** (or in 4b). They're declared in `api_const.dart` and have stub `ApiService` methods, but **no controller in the codebase consumes them**. The `getEntries`/`getHeats` ApiService methods are dead code. Migrating them would just add unused DTOs/mappers/repos. They're flagged for outright deletion in Batch 6 (or whenever the rankings/entries feature is actually built).

3. **`MeetingRepository` is a transitional shim.** Its `Future<List<MeetingModel>> getMeetings(int)` signature returns a legacy type. This violates the design spec's "repositories return domain types" rule, but it's a tightly-scoped, documented exception that lets us deliver the discipline refactor without coupling to the data migration. Batch 4b will replace `MeetingModel` with a typed `Meeting` domain model and update the repository signature.

4. **`createMeeting`/`deleteMeeting` mutation paths preserved.** The spec mentions a "create meeting after delete date-picker context leak" — that's the `controller.selectDate` / `controller.selectTime` legacy methods reaching into `Get.context!`. Fixed here by moving the pickers into the dialog, where local `BuildContext` is available.

5. **No view-file split.** Spec §14 Batch 4 says "Split program_view.dart into widgets/." That's a 573 → many small files restructure. Deferred to a later cleanup pass — the discipline goals don't require it.

---

## File map

**Create:**
- `lib/app/data/repositories/meeting_repository.dart` — abstract + Impl that wraps `ApiService`, returns legacy `MeetingModel`
- `test/data/repositories/meeting_repository_test.dart` — verifies the wrapper forwards correctly
- `test/presentation/modules/program/controllers/program_controller_test.dart` — TDD for the refactored controller

**Modify (rewrite):**
- `lib/app/module/program/controllers/program_controller.dart` — constructor-inject `MeetingRepository`; drop `TextEditingController`/`GlobalKey`/`Get.context!`/`Get.snackbar`/`selectDate`/`selectTime`; expose form-input state as `Rx`-typed values; expose a `Rxn<UiMessage>` for snackbar dispatch from the view
- `lib/app/module/program/views/program_view.dart` — remove `Get.context!` reference at line 131; subscribe to controller's `Rxn<UiMessage>` and surface snackbars
- `lib/app/module/program/views/program_add_meeting_dialog.dart` — convert to `StatefulWidget`; own `TextEditingController`/`GlobalKey`; do `showDatePicker`/`showTimePicker` with local `context`
- `lib/app/module/program/bindings/program_binding.dart` — constructor-inject `MeetingRepository`
- `lib/app/core/di/initial_binding.dart` — register `MeetingRepository`

**Create (presentation, optional shared widget for `UiMessage`):**
- `lib/app/presentation/shared/ui_message.dart` — small sealed class for success/error snackbar payloads (so the view knows which kind to show)

---

## Key types

### `UiMessage`

```dart
sealed class UiMessage {
  const UiMessage(this.translationKey);
  final String translationKey;
}

class UiMessageSuccess extends UiMessage {
  const UiMessageSuccess(super.translationKey);
}

class UiMessageError extends UiMessage {
  const UiMessageError(super.translationKey);
}
```

The controller emits `UiMessage` instances; the view watches `controller.message` with `ever()` and renders a `Get.snackbar` with the appropriate styling. This is the spec's recommended pattern (§8).

### `MeetingRepository` (transitional shim)

```dart
abstract class MeetingRepository {
  /// Returns legacy MeetingModel — domain migration deferred to Batch 4b/5.
  Future<List<MeetingModel>> getMeetings(int competitionId);
  Future<bool?> createMeeting(MeetingModel meeting, int competitionId);
  Future<bool> deleteMeeting(int meetingId);
}

class MeetingRepositoryImpl implements MeetingRepository {
  MeetingRepositoryImpl(this._api);
  final ApiService _api;

  @override
  Future<List<MeetingModel>> getMeetings(int competitionId) =>
      _api.getMeetings(competitionId);

  @override
  Future<bool?> createMeeting(MeetingModel meeting, int competitionId) =>
      _api.createMeeting(meeting, competitionId);

  @override
  Future<bool> deleteMeeting(int meetingId) => _api.deleteMeeting(meetingId);
}
```

### Refactored `ProgramController`

```dart
class ProgramController extends GetxController {
  ProgramController(this._meetingRepo);
  final MeetingRepository _meetingRepo;

  final Rxn<CompetitionModel> competition = Rxn<CompetitionModel>();
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxBool isCreatingMeeting = false.obs;
  final RxList<MeetingModel> meetings = <MeetingModel>[].obs;
  final Rxn<UiMessage> message = Rxn<UiMessage>();

  void setCompetition(CompetitionModel? c) { ... }
  Future<void> loadMeetings() async { ... }
  Future<bool> submitMeeting({
    required String name,
    required String description,
    required DateTime date,
    required TimeOfDay beginTime,
    required TimeOfDay endTime,
  }) async { ... }
  Future<void> deleteMeeting(MeetingModel m) async { ... }

  // GONE: nameController, descriptionController, selectedDate, beginTime, endTime,
  //       formKey, selectDate, selectTime, onAddMeetingPressed, resetForm
  // (those move to the dialog)
}
```

`competition.value` stays as legacy `CompetitionModel` because that's what `CompetitionDetailController.changeTab` passes via `programController.setCompetition(competition)` — and `CompetitionDetailController.competition` is the new domain `Competition` from Batch 3a. Wait, that's a type mismatch...

Let me check: in Batch 3a, `CompetitionDetailController` switched to `Rxn<Competition>` (new domain). But `competition_detail_view.dart:91` does `_buildProgramView(competition)` passing the domain Competition. Then `_buildProgramView` calls `programController.setCompetition(competition)`.

Currently `ProgramController.setCompetition` takes `CompetitionModel?` (legacy). After Batch 3a's merge, this is broken — passing `Competition` to a `CompetitionModel?` param won't compile.

Let me check the actual current state of competition_detail_view.dart `_buildProgramView`:

Looking at the code I already have: `_buildProgramView(competition)` takes `dynamic`. Then inside it does `programController.setCompetition(competition)`. So it relies on duck-typing.

Actually no, with the legacy ProgramController taking `CompetitionModel?`, `setCompetition(competition)` where `competition: Competition` would fail to compile. Yet the project compiled at end of Batch 3b... Let me check.

Actually `Get.find<ProgramController>()` returns the program_controller, which is whatever was registered. In Batch 3b, ProgramController wasn't touched — it still has its legacy signature. The view's `_buildProgramView(competition)` passes `dynamic` (no type annotation on `competition` in the method signature), and Dart's runtime would attempt the call.

Wait, looking at Batch 3a's spec — was this issue addressed? Let me re-read.

OK I don't have time to chase this. Pragmatic: in this batch, change `ProgramController.setCompetition` to take `dynamic` (or `Object`) and do an internal cast — temporarily. Document it. Batch 4b/5 will clean up.

Actually, simpler: ProgramController's `competition` field becomes `Rxn<Competition>` (the domain type from Batch 3a). The legacy `CompetitionModel` reference is replaced with `Competition`. This is a one-line type swap in the controller. The view's `_buildProgramView` then becomes well-typed.

But `loadMeetings()` calls `_apiService.getMeetings(competition.value?.id ?? 0)` which works with whatever type has `.id` — both legacy and new Competition have `id: int`. So this still works.

Net: `competition: Rxn<Competition>` (new type) in the refactored controller. Easy.

---

## Task 1: Add `UiMessage` shared widget

**Files:**
- Create: `lib/app/presentation/shared/ui_message.dart`

- [ ] **Step 1: Create the file**

Create `lib/app/presentation/shared/ui_message.dart` with EXACTLY this content:

```dart
sealed class UiMessage {
  const UiMessage(this.translationKey);
  final String translationKey;
}

class UiMessageSuccess extends UiMessage {
  const UiMessageSuccess(super.translationKey);
}

class UiMessageError extends UiMessage {
  const UiMessageError(super.translationKey);
}
```

- [ ] **Step 2: Verify it compiles**

Run: `flutter analyze lib/app/presentation/shared/ui_message.dart`
Expected: `No issues found!`

(`flutter` may not be on bash PATH — fall back to `C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat` if needed.)

- [ ] **Step 3: Commit**

```bash
git add lib/app/presentation/shared/ui_message.dart
git commit -m "feat(shared): add UiMessage sealed class

Tiny payload type for controller -> view snackbar dispatch.
Replaces direct Get.snackbar calls in controllers (spec §8 rule)."
```

---

## Task 2: MeetingRepository transitional shim

**Files:**
- Create: `lib/app/data/repositories/meeting_repository.dart`
- Create: `test/data/repositories/meeting_repository_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/data/repositories/meeting_repository_test.dart` with EXACTLY this content:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/models/meeting_model.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:live_ffss/app/data/services/api_service.dart';
import 'package:mocktail/mocktail.dart';

class _MockApi extends Mock implements ApiService {}

class _FakeMeeting extends Fake implements MeetingModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeMeeting());
  });

  late _MockApi api;
  late MeetingRepository repo;

  setUp(() {
    api = _MockApi();
    repo = MeetingRepositoryImpl(api);
  });

  group('MeetingRepository', () {
    test('getMeetings forwards competitionId and returns list', () async {
      when(() => api.getMeetings(any())).thenAnswer((_) async => []);

      final list = await repo.getMeetings(42);

      expect(list, isEmpty);
      verify(() => api.getMeetings(42)).called(1);
    });

    test('createMeeting forwards meeting + competitionId', () async {
      final meeting = _FakeMeeting();
      when(() => api.createMeeting(any(), any())).thenAnswer((_) async => true);

      final result = await repo.createMeeting(meeting, 99);

      expect(result, true);
      verify(() => api.createMeeting(meeting, 99)).called(1);
    });

    test('deleteMeeting forwards meetingId', () async {
      when(() => api.deleteMeeting(any())).thenAnswer((_) async => true);

      final result = await repo.deleteMeeting(7);

      expect(result, true);
      verify(() => api.deleteMeeting(7)).called(1);
    });
  });
}
```

- [ ] **Step 2: Run, verify it fails**

Run: `flutter test test/data/repositories/meeting_repository_test.dart`
Expected: import error for `meeting_repository.dart`.

- [ ] **Step 3: Create the repository**

Create `lib/app/data/repositories/meeting_repository.dart` with EXACTLY this content:

```dart
import 'package:live_ffss/app/data/models/meeting_model.dart';
import 'package:live_ffss/app/data/services/api_service.dart';

/// Transitional shim around ApiService for the Program module.
///
/// Returns legacy [MeetingModel] — full domain migration of Meeting +
/// Slot + Run is bundled with Batch 5's slot work. This file goes away
/// when MeetingDto/Meeting domain land.
abstract class MeetingRepository {
  Future<List<MeetingModel>> getMeetings(int competitionId);
  Future<bool?> createMeeting(MeetingModel meeting, int competitionId);
  Future<bool> deleteMeeting(int meetingId);
}

class MeetingRepositoryImpl implements MeetingRepository {
  MeetingRepositoryImpl(this._api);

  final ApiService _api;

  @override
  Future<List<MeetingModel>> getMeetings(int competitionId) =>
      _api.getMeetings(competitionId);

  @override
  Future<bool?> createMeeting(MeetingModel meeting, int competitionId) =>
      _api.createMeeting(meeting, competitionId);

  @override
  Future<bool> deleteMeeting(int meetingId) => _api.deleteMeeting(meetingId);
}
```

- [ ] **Step 4: Run, verify pass**

Run: `flutter test test/data/repositories/meeting_repository_test.dart`
Expected: `All tests passed!` (3 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/app/data/repositories/meeting_repository.dart \
        test/data/repositories/meeting_repository_test.dart
git commit -m "feat(data): add MeetingRepository transitional shim

Wraps ApiService.getMeetings/createMeeting/deleteMeeting. Returns
legacy MeetingModel — full domain migration of Meeting+Slot+Run
gets bundled with Batch 5. This file is replaced when those land."
```

---

## Task 3: Refactor ProgramController (TDD)

**Files:**
- Modify (rewrite): `lib/app/module/program/controllers/program_controller.dart`
- Create: `test/presentation/modules/program/controllers/program_controller_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/presentation/modules/program/controllers/program_controller_test.dart` with EXACTLY this content:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/models/meeting_model.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/module/program/controllers/program_controller.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements MeetingRepository {}

class _FakeMeeting extends Fake implements MeetingModel {}

Competition makeCompetition(int id) => Competition(
      id: id,
      name: 'C$id',
      statusCode: 0,
      statusLabel: '',
      speciality: 0,
      specialityLabel: '',
      typeWater: '',
      typePool: '',
      typeChrono: '',
      isEligibleToNationalRecord: false,
      numberOfLanes: 0,
      organizer: 'X',
      hasBegun: false,
      hasResult: false,
      hasPassed: false,
      level: 0,
      levelLabel: '',
      organizerClub: const Club(id: 1, name: 'X'),
    );

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeMeeting());
  });

  late _MockRepo repo;
  late ProgramController controller;

  setUp(() {
    repo = _MockRepo();
    controller = ProgramController(repo);
  });

  group('ProgramController.setCompetition', () {
    test('null competition clears meetings', () {
      controller.meetings.value = [_FakeMeeting()];
      controller.setCompetition(null);
      expect(controller.competition.value, isNull);
      expect(controller.meetings, isEmpty);
    });

    test('non-null competition triggers loadMeetings', () async {
      when(() => repo.getMeetings(any())).thenAnswer((_) async => []);

      controller.setCompetition(makeCompetition(42));
      // Allow the async loadMeetings to complete.
      await Future<void>.delayed(Duration.zero);

      expect(controller.competition.value?.id, 42);
      verify(() => repo.getMeetings(42)).called(1);
    });
  });

  group('ProgramController.loadMeetings', () {
    test('on success: stores result and clears flags', () async {
      controller.competition.value = makeCompetition(99);
      when(() => repo.getMeetings(any())).thenAnswer((_) async => []);

      await controller.loadMeetings();

      expect(controller.isLoading.value, false);
      expect(controller.hasError.value, false);
    });

    test('on exception sets hasError', () async {
      controller.competition.value = makeCompetition(99);
      when(() => repo.getMeetings(any())).thenThrow(Exception('boom'));

      await controller.loadMeetings();

      expect(controller.hasError.value, true);
      expect(controller.isLoading.value, false);
    });
  });

  group('ProgramController.submitMeeting', () {
    test('on success: emits UiMessageSuccess and reloads', () async {
      controller.competition.value = makeCompetition(99);
      when(() => repo.createMeeting(any(), any())).thenAnswer((_) async => true);
      when(() => repo.getMeetings(any())).thenAnswer((_) async => []);

      final ok = await controller.submitMeeting(
        name: 'N',
        description: 'D',
        date: DateTime(2026, 5, 1),
        beginTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 12, minute: 0),
      );

      expect(ok, isTrue);
      expect(controller.message.value, isA<UiMessageSuccess>());
      expect(controller.message.value?.translationKey,
          'meeting_created_successfully');
      verify(() => repo.createMeeting(any(), 99)).called(1);
    });

    test('end before begin: emits UiMessageError, returns false, no API call',
        () async {
      controller.competition.value = makeCompetition(99);

      final ok = await controller.submitMeeting(
        name: 'N',
        description: 'D',
        date: DateTime(2026, 5, 1),
        beginTime: const TimeOfDay(hour: 12, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 0),
      );

      expect(ok, isFalse);
      expect(controller.message.value, isA<UiMessageError>());
      expect(controller.message.value?.translationKey,
          'end_time_must_be_after_begin_time');
      verifyNever(() => repo.createMeeting(any(), any()));
    });

    test('on exception: emits UiMessageError', () async {
      controller.competition.value = makeCompetition(99);
      when(() => repo.createMeeting(any(), any())).thenThrow(Exception('x'));

      final ok = await controller.submitMeeting(
        name: 'N',
        description: 'D',
        date: DateTime(2026, 5, 1),
        beginTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 12, minute: 0),
      );

      expect(ok, isFalse);
      expect(controller.message.value, isA<UiMessageError>());
    });
  });

  group('ProgramController.deleteMeeting', () {
    test('on success: removes from list and emits UiMessageSuccess', () async {
      controller.competition.value = makeCompetition(99);
      final m = _FakeMeeting();
      when(() => m.id).thenReturn(7);
      controller.meetings.value = [m];
      when(() => repo.deleteMeeting(any())).thenAnswer((_) async => true);

      await controller.deleteMeeting(m);

      expect(controller.meetings, isEmpty);
      expect(controller.message.value, isA<UiMessageSuccess>());
    });

    test('on exception: emits UiMessageError, list unchanged', () async {
      controller.competition.value = makeCompetition(99);
      final m = _FakeMeeting();
      when(() => m.id).thenReturn(7);
      controller.meetings.value = [m];
      when(() => repo.deleteMeeting(any())).thenThrow(Exception('boom'));

      await controller.deleteMeeting(m);

      expect(controller.meetings.length, 1);
      expect(controller.message.value, isA<UiMessageError>());
    });
  });
}
```

- [ ] **Step 2: Run, verify it fails**

Run: `flutter test test/presentation/modules/program/controllers/program_controller_test.dart`
Expected: import / type errors against the legacy ProgramController.

(`flutter` may not be on bash PATH — fall back to the .bat if needed.)

- [ ] **Step 3: Rewrite ProgramController**

REPLACE `lib/app/module/program/controllers/program_controller.dart` with EXACTLY this content:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/data/models/meeting_model.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';

class ProgramController extends GetxController {
  ProgramController(this._meetingRepo);

  final MeetingRepository _meetingRepo;

  final Rxn<Competition> competition = Rxn<Competition>();
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxBool isCreatingMeeting = false.obs;
  final RxList<MeetingModel> meetings = <MeetingModel>[].obs;
  final Rxn<UiMessage> message = Rxn<UiMessage>();

  void setCompetition(Competition? newCompetition) {
    competition.value = newCompetition;
    if (newCompetition != null) {
      loadMeetings();
    } else {
      meetings.clear();
    }
  }

  Future<void> loadMeetings() async {
    final id = competition.value?.id;
    if (id == null) return;
    try {
      isLoading.value = true;
      hasError.value = false;

      final loaded = await _meetingRepo.getMeetings(id);
      loaded.sort((a, b) {
        final dateCmp = a.date.compareTo(b.date);
        if (dateCmp != 0) return dateCmp;
        return a.beginHour.compareTo(b.beginHour);
      });
      meetings.value = loaded;
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> submitMeeting({
    required String name,
    required String description,
    required DateTime date,
    required TimeOfDay beginTime,
    required TimeOfDay endTime,
  }) async {
    final competitionId = competition.value?.id;
    if (competitionId == null) return false;

    final beginDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      beginTime.hour,
      beginTime.minute,
    );
    final endDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      endTime.hour,
      endTime.minute,
    );

    if (endDateTime.isBefore(beginDateTime)) {
      message.value = const UiMessageError('end_time_must_be_after_begin_time');
      return false;
    }

    try {
      isCreatingMeeting.value = true;
      final meeting = MeetingModel(
        id: 0,
        name: name.trim(),
        description: description.trim(),
        date: date,
        beginHour: beginDateTime,
        endHour: endDateTime,
      );
      await _meetingRepo.createMeeting(meeting, competitionId);
      message.value = const UiMessageSuccess('meeting_created_successfully');
      await loadMeetings();
      return true;
    } catch (_) {
      message.value = const UiMessageError('failed_to_create_meeting');
      return false;
    } finally {
      isCreatingMeeting.value = false;
    }
  }

  Future<void> deleteMeeting(MeetingModel meeting) async {
    if (competition.value == null) return;
    try {
      final success = await _meetingRepo.deleteMeeting(meeting.id);
      if (success) {
        meetings.remove(meeting);
        message.value = const UiMessageSuccess('meeting_deleted_successfully');
      } else {
        message.value = const UiMessageError('failed_to_delete_meeting');
      }
    } catch (_) {
      message.value = const UiMessageError('failed_to_delete_meeting');
    }
  }

  int get totalSlotsCount =>
      meetings.isNotEmpty ? meetings.first.slots.length : 0;
}
```

Key changes vs legacy:
- `MeetingRepository` constructor injection.
- `competition` is `Rxn<Competition>` (new domain) instead of `Rxn<CompetitionModel>`.
- All `TextEditingController`/`GlobalKey`/`selectedDate`/`beginTime`/`endTime`/`formKey` REMOVED.
- `selectDate`/`selectTime` REMOVED (those used `Get.context!`).
- `Get.snackbar` REMOVED — replaced with `message.value = UiMessage*(...)`.
- `submitMeeting(...)` is the new method (was `createMeeting(...)`); takes form values as parameters.
- No more `resetForm` or `onAddMeetingPressed` (form state lives in the dialog).

- [ ] **Step 4: Run, verify pass**

Run: `flutter test test/presentation/modules/program/controllers/program_controller_test.dart`
Expected: `All tests passed!` (9 tests).

If `flutter test` fails to compile because the program view + dialog still reference legacy controller fields (`controller.formKey`, `controller.nameController`, etc.), that's expected — those get fixed in Tasks 4 and 5. Only the specific test file should run for now.

- [ ] **Step 5: Commit**

```dart
git add lib/app/module/program/controllers/program_controller.dart \
        test/presentation/modules/program/controllers/program_controller_test.dart
git commit -m "refactor(program): controller is a pure state machine

Constructor-injects MeetingRepository. Drops TextEditingController/
GlobalKey/selectDate/selectTime/Get.snackbar/Get.context!/onAddMeetingPressed/
resetForm — form state and pickers move to the dialog (next commit).
Snackbar dispatch goes through Rxn<UiMessage>. competition: Rxn<Competition>
matches the new domain model from Batch 3a."
```

---

## Task 4: Refactor AddMeetingDialog (StatefulWidget)

**Files:**
- Modify (rewrite): `lib/app/module/program/views/program_add_meeting_dialog.dart`

- [ ] **Step 1: Rewrite the dialog**

REPLACE `lib/app/module/program/views/program_add_meeting_dialog.dart` with EXACTLY this content:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/module/program/controllers/program_controller.dart';

class ProgramAddMeetingDialog extends StatefulWidget {
  const ProgramAddMeetingDialog({super.key});

  @override
  State<ProgramAddMeetingDialog> createState() =>
      _ProgramAddMeetingDialogState();
}

class _ProgramAddMeetingDialogState extends State<ProgramAddMeetingDialog> {
  final _controller = Get.find<ProgramController>();

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  late DateTime _selectedDate = DateTime.now();
  late TimeOfDay _beginTime = TimeOfDay.now();
  late TimeOfDay _endTime = TimeOfDay(
    hour: (DateTime.now().hour + 1) % 24,
    minute: DateTime.now().minute,
  );

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.blue,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(
    TimeOfDay current,
    void Function(TimeOfDay) onPicked,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: current,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.blue,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => onPicked(picked));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await _controller.submitMeeting(
      name: _nameController.text,
      description: _descriptionController.text,
      date: _selectedDate,
      beginTime: _beginTime,
      endTime: _endTime,
    );
    if (ok && mounted) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: Get.width * 0.9,
        constraints: BoxConstraints(maxHeight: Get.height * 0.8),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'add_meeting'.tr,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTextFormField(
                  controller: _nameController,
                  label: 'name'.tr,
                  hint: 'enter_name'.tr,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'name_required'.tr : null,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _descriptionController,
                  label: 'description'.tr,
                  hint: 'enter_description'.tr,
                  maxLines: 3,
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'description_required'.tr
                      : null,
                ),
                const SizedBox(height: 16),
                _buildDateField(),
                const SizedBox(height: 16),
                _buildTimeField(
                  label: 'begin_time'.tr,
                  current: _beginTime,
                  onPicked: (t) => _beginTime = t,
                ),
                const SizedBox(height: 16),
                _buildTimeField(
                  label: 'end_time'.tr,
                  current: _endTime,
                  onPicked: (t) => _endTime = t,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text('cancel'.tr,
                            style: const TextStyle(color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() => ElevatedButton(
                            onPressed: _controller.isCreatingMeeting.value
                                ? null
                                : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _controller.isCreatingMeeting.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              Colors.white),
                                    ),
                                  )
                                : Text('create'.tr),
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'date'.tr,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(fontSize: 16),
                ),
                const Icon(Icons.calendar_today, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField({
    required String label,
    required TimeOfDay current,
    required void Function(TimeOfDay) onPicked,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectTime(current, onPicked),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${current.hour.toString().padLeft(2, '0')}:${current.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 16),
                ),
                const Icon(Icons.access_time, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Verify**

Run: `flutter analyze lib/app/module/program/views/program_add_meeting_dialog.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/app/module/program/views/program_add_meeting_dialog.dart
git commit -m "refactor(program): AddMeetingDialog owns form state

StatefulWidget hosts TextEditingController/GlobalKey + the date/time
TimeOfDay state. showDatePicker/showTimePicker now use the dialog's
local BuildContext (was Get.context! in the controller). Calls
controller.submitMeeting with the form values."
```

---

## Task 5: ProgramView updates + UiMessage subscription

**Files:**
- Modify: `lib/app/module/program/views/program_view.dart` — drop `Get.context!`, watch `controller.message`, fix the FAB (`_onFloatingActionButtonPressed` was unused — make it work)

- [ ] **Step 1: Update the view**

The legacy view has these issues:
- Line 131: `Theme(data: Theme.of(Get.context!).copyWith(...))` — should use the local `BuildContext` parameter from `_buildExpandableMeetingCard`'s caller.
- The floatingActionButton is commented out and `_onFloatingActionButtonPressed` is dead code.
- No listener for the new `controller.message` Rxn.

Apply these changes manually to `lib/app/module/program/views/program_view.dart`:

**Change 1:** Add a `Worker` field for the message listener. Since `ProgramView` is a `GetView<ProgramController>` (StatelessWidget), we need to convert it to a `StatefulWidget` to manage the listener subscription's lifecycle.

REPLACE the entire opening `class ProgramView extends GetView<ProgramController>` block AND `Widget build(BuildContext context)` method shape — change to a StatefulWidget pattern:

```dart
class ProgramView extends StatefulWidget {
  const ProgramView({super.key});

  @override
  State<ProgramView> createState() => _ProgramViewState();
}

class _ProgramViewState extends State<ProgramView> {
  final ProgramController controller = Get.find<ProgramController>();
  Worker? _messageWorker;

  @override
  void initState() {
    super.initState();
    _messageWorker = ever<UiMessage?>(controller.message, (msg) {
      if (msg == null) return;
      Get.snackbar(
        msg is UiMessageSuccess ? 'success'.tr : 'error'.tr,
        msg.translationKey.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: msg is UiMessageSuccess ? Colors.green : Colors.red,
        colorText: Colors.white,
      );
    });
  }

  @override
  void dispose() {
    _messageWorker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ... (existing build body — unchanged except where noted below)
  }
```

ADD imports at the top of the file:
```dart
import 'package:live_ffss/app/presentation/shared/ui_message.dart';
```

**Change 2:** Inside the build body of `_ProgramViewState`, find any references to `controller` that came from the GetView superclass — they all still work since we have `final ProgramController controller = Get.find<ProgramController>();` as a State field. No further code change needed.

**Change 3:** Find this line (around legacy line 131 inside `_buildExpandableMeetingCard`):
```dart
data: Theme.of(Get.context!).copyWith(
```
REPLACE with:
```dart
data: Theme.of(context).copyWith(
```
(`context` is already the parameter to the surrounding method.)

If `_buildExpandableMeetingCard` doesn't take `context` as a parameter, ADD it. The method should be:
```dart
Widget _buildExpandableMeetingCard(BuildContext context, MeetingModel meeting, int index) {
```
And update the caller (around legacy line 91-93):
```dart
final meeting = controller.meetings[index];
return _buildExpandableMeetingCard(context, meeting, index);
```

**Change 4:** The dead `_onFloatingActionButtonPressed` and commented-out FAB. Either fully delete them, or wire the FAB back. If the goal is to allow add-meeting, wire it back. RESTORE the FAB by uncommenting and updating in the Scaffold:

Find the commented-out floatingActionButton block and REPLACE it with:
```dart
floatingActionButton: FloatingActionButton(
  onPressed: () {
    Get.dialog(
      const ProgramAddMeetingDialog(),
      barrierDismissible: false,
    );
  },
  backgroundColor: Colors.blue,
  foregroundColor: Colors.white,
  child: const Icon(Icons.add),
),
```

Remove the dead `_onFloatingActionButtonPressed` method body (no longer used — `controller.onAddMeetingPressed` and `resetForm` were removed from the controller; the dialog handles its own state init now).

Also remove the `_formatTime` method around line 502 if it's unused (analyzer will tell you). Same with any other helpers that are no longer called.

- [ ] **Step 2: Verify the program view compiles**

Run: `flutter analyze lib/app/module/program/views/program_view.dart`
Expected: zero errors. Pre-existing infos may stay; the `unused_element` warnings on `_onFloatingActionButtonPressed` and `_formatTime` should be gone (because we removed those methods).

- [ ] **Step 3: Commit**

```bash
git add lib/app/module/program/views/program_view.dart
git commit -m "refactor(program): ProgramView is a StatefulWidget; FAB rewired

Subscribes to controller.message via ever() and surfaces snackbars.
Drops Get.context! reference at the meeting-card Theme(). The
floating action button is back (dialog handles its own form state).
Dead helpers (_onFloatingActionButtonPressed, _formatTime) removed."
```

---

## Task 6: ProgramBinding + InitialBinding wiring

**Files:**
- Modify: `lib/app/module/program/bindings/program_binding.dart`
- Modify: `lib/app/core/di/initial_binding.dart`

- [ ] **Step 1: Update ProgramBinding**

REPLACE `lib/app/module/program/bindings/program_binding.dart` with EXACTLY this content:

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import '../controllers/program_controller.dart';

class ProgramBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProgramController>(
      () => ProgramController(Get.find<MeetingRepository>()),
    );
  }
}
```

If the existing binding has a `Get.lazyPut<ApiService>(...)` line, drop it — `ApiService` is a permanent singleton from `InitialBinding` (Batch 1).

- [ ] **Step 2: Add MeetingRepository to InitialBinding**

In `lib/app/core/di/initial_binding.dart`, ADD an import:
```dart
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
```

ADD a registration block after the Race registrations and BEFORE the transitional ApiService line:
```dart
    // 5d. Meeting data layer (transitional shim — wraps ApiService)
    Get.put<MeetingRepository>(
      MeetingRepositoryImpl(Get.find<ApiService>()),
      permanent: true,
    );
```

NB: This MUST come AFTER `Get.put<ApiService>(...)` because MeetingRepository depends on it. Re-order if necessary so that ApiService is registered before MeetingRepository. OR, put MeetingRepository AFTER the transitional ApiService line — that's also fine.

- [ ] **Step 3: Run analyzer + tests**

Run: `flutter analyze`
Expected: zero errors.

Run: `flutter test`
Expected: all tests pass — Batch 0 (44) + Batch 1 (15) + Batch 2 (0) + Batch 3a (16) + Batch 3b (17) + Batch 4a (12: 3 repo + 9 controller) = ~104 tests.

- [ ] **Step 4: Commit**

```bash
git add lib/app/module/program/bindings/program_binding.dart \
        lib/app/core/di/initial_binding.dart
git commit -m "feat(di): wire MeetingRepository in InitialBinding + ProgramBinding

ProgramBinding constructor-injects MeetingRepository.
InitialBinding registers MeetingRepositoryImpl (which wraps the
transitional ApiService until Batch 4b/5 brings the full Meeting
domain online)."
```

---

## Task 7: Final verification

- [ ] **Step 1: Run full test suite**

Run: `flutter test`
Expected: ~104 tests passing.

- [ ] **Step 2: Run analyzer**

Run: `flutter analyze`
Expected: zero errors.

- [ ] **Step 3: Confirm legacy ApiService is now ONLY in slot module**

Run: `grep -rn "Get.find<ApiService>()" lib/app/module/`
Expected: hits ONLY in `slot_controller.dart`. (ProgramController no longer uses it directly — it goes through MeetingRepository.)

- [ ] **Step 4: Confirm Get.context! is gone from ProgramController**

Run: `grep -n "Get.context" lib/app/module/program/`
Expected: zero matches in `controllers/`. The dialog uses local `context`. The view uses `BuildContext` parameters.

- [ ] **Step 5: Confirm git state**

- `git log --oneline main..HEAD` — ~7 commits.
- `git branch --show-current` — `refactor/batch-4a-program`.
- `git status` — clean (only `.claude/` untracked).
- `git diff main..HEAD --stat | tail -25` — total LOC change.

- [ ] **Step 6 (manual, by user): Smoke-test the program flow**

`flutter run`. Click through:
- Home → competition → Program tab → meetings list loads
- Tap "+" FAB → dialog appears with form
- Fill in name/description, pick a date and times, hit Create → success snackbar
- Reload list → new meeting visible
- Long-press / 3-dot menu → delete → success snackbar, list updates

---

## Self-review

**Spec coverage** (against §14 "Batch 4 — Meeting + Entry + Heat domains"):
- DTOs, mappers, datasources, repositories → **DEFERRED to Batch 4b/5** (this plan only does the controller refactor + transitional shim repository)
- TextEditingController/GlobalKey out of ProgramController → Task 3 ✓
- ProgramView becomes StatefulWidget OR small dedicated form widget → Task 5 (view) + Task 4 (dialog owns form) ✓
- Split program_view.dart into widgets/ → **DEFERRED** (not blocking, large mechanical work)
- Fix bug #X "create meeting after delete date-picker context leak" → Task 4 (selectDate/selectTime moved to dialog with local context) ✓
- Entry + Heat domains → **DEFERRED** (unused; flagged for deletion in Batch 6)

**Placeholder scan:** None. All deferrals documented at the top.

**Type consistency:**
- `MeetingRepository` constructor: `MeetingRepositoryImpl(this._api)` — same in Task 2 (impl + test) and Task 6 (binding). ✓
- `ProgramController` constructor: `ProgramController(this._meetingRepo)` — same in Task 3 (impl + test) and Task 6 (binding). ✓
- `competition: Rxn<Competition>` (NOT `CompetitionModel`) — used consistently in the controller and the test. ✓
- `UiMessage` sealed class with `UiMessageSuccess`/`UiMessageError` subtypes — used in Tasks 1, 3, 5. ✓

---

## Done criteria for Batch 4a

- ~7 commits on `refactor/batch-4a-program`.
- New: `MeetingRepository` + 1 small shared widget (`UiMessage`) + 2 test files (~12 new tests).
- Modified: `ProgramController`, `ProgramView`, `ProgramAddMeetingDialog`, `ProgramBinding`, `InitialBinding`.
- `flutter analyze`: zero errors.
- `flutter test`: ~104 tests, all green.
- Program flow works end-to-end.
- `Get.find<ApiService>()` now only in `slot_controller.dart`. Legacy `MeetingModel`/`SlotModel`/`RunModel` types still on disk (retired in Batch 5/6).
