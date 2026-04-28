# Batch 5 — Slot + Meeting + Run + Result Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate the full Meeting → Slot → Run → LiveResult → Result data tree to typed domain models. Refactor `SlotController` for constructor injection and clean error handling. Replace the Batch 4a `MeetingRepository` transitional shim with a real implementation. Expose `ResultRepository` and the four slot-mutation methods as a clean seam — internally they throw `UnimplementedError` because the FFSS backend endpoints aren't documented (matches the legacy stubbed state). Update `ProgramView`'s slot rendering and `SlotView` to use new types.

**Architecture:** Per design spec §6-9. Same three-layer pragmatic pattern. Many leaf domains (Discipline, RaceFormatConfiguration, Heat, Entry, Result) get migrated for type completeness even though they're not directly displayed — they're embedded in the structures that are.

**Tech Stack:** freezed + json_serializable + build_runner, mocktail. No new deps.

---

## Notes & deviations from spec

1. **Combines Batch 4b + Batch 5** from the original spec. After Batch 4a, the remaining work for Meeting+Slot+Run+Result is too entangled to split further: Meeting embeds Slot embeds Run, and Run is consumed by SlotController. Doing them as one large batch is cleaner.

2. **Live-results endpoint is a phantom.** The legacy `_apiService.getRunResults(runId)` has never existed on `ApiService`. The legacy `SlotController._loadRunResultsFromApi` was a TODO stub. The four mutation methods (`_saveBeachRankings`, `_saveSwimmingTimes`, `withdrawAthlete`, plus a placeholder loader) all had `const success = false` no-op bodies. **This batch maintains that brokenness behind a clean seam** — `ResultRepository.getRunResults`, `updateBeachRankings`, `updateSwimmingTimes`, `withdrawAthlete` all throw `UnimplementedError` with a documented TODO. The next batch (or a separate "wire up live results" feature batch) implements them once backend endpoints are confirmed.

3. **No view split for slot_view.dart.** The spec mentions splitting it into widgets/. At 742 LOC it's the biggest view in the codebase, but a pure mechanical split that doesn't change behavior. Deferred to Batch 6 or a later cleanup pass.

4. **`SlotController` keeps some legacy patterns.** The discipline cleanup (no `Get.snackbar`, no `Get.dialog`, no `.tr` in controller) is partial here — the four mutation methods are intentionally wrapped with the legacy snackbar pattern because they're meant to be wired up later. Replacing them with `Rxn<UiMessage>` ahead of time would just add complexity without benefit. **Marked with `// TODO(batch-6):` comments inline.**

5. **Heat / Entry domains migrated but unused (still).** They're referenced from `Result.heat`, `Result.entry`, `LiveResult.entry` — so they need to exist as domain types. But no controller fetches them directly via a repository. Their getters are exposed but the repos themselves are tiny / not registered. Batch 6 demolition decides whether to keep them.

6. **Run status string-based discipline detection unchanged.** SlotController's `isBeachDiscipline` / `isSwimmingDiscipline` still string-matches `'côtier'`/`'beach'`/`'eau-plate'`. Replacing with a `Discipline` enum on `RaceFormatDetail` is a pure refactor that doesn't unlock anything; deferred.

7. **`Heat.fromJson` had a bug** — the legacy code reads `json["resultats"]` into a local `final results` then never uses it (line 23). The freezed DTO simply doesn't include `resultats`. Bug structurally eliminated.

---

## Domain hierarchy (target)

```
Meeting
  ├── slots: List<Slot>
  │     ├── raceFormatDetail: RaceFormatDetail?
  │     │     └── raceFormatConfiguration: RaceFormatConfiguration  // sometimes
  │     │           ├── discipline: Discipline
  │     │           └── categories: List<Category>            (Batch 3b type)
  │     └── runs: List<Run>
  │           ├── heat: Heat?
  │           └── liveResults: List<LiveResult>               // populated separately
  │                 ├── entry: Entry?
  │                 │     ├── category: Category              (Batch 3b)
  │                 │     └── athletes: List<Athlete>         (Batch 3b)
  │                 └── result: Result?
  │                       ├── heat: Heat
  │                       ├── entry: Entry
  │                       └── athletes: List<Athlete>         (Batch 3b)
  └── (date, beginHour, endHour, etc.)
```

For brevity, **leaf types not directly used by any view** (Heat, Entry, Result, Discipline, RaceFormatConfiguration) get minimal domain definitions — just enough for the JSON to round-trip and for embedded references to type-check.

---

## File map (new files)

**Domain models:**
- `lib/app/domain/models/discipline.dart`
- `lib/app/domain/models/race_format_configuration.dart`
- `lib/app/domain/models/race_format_detail.dart`
- `lib/app/domain/models/heat.dart`
- `lib/app/domain/models/entry.dart`
- `lib/app/domain/models/result.dart`
- `lib/app/domain/models/live_result.dart`
- `lib/app/domain/models/run.dart` (with `RunStatus` enum)
- `lib/app/domain/models/slot.dart`
- `lib/app/domain/models/meeting.dart`

**DTOs (one per domain, same shape):**
- `lib/app/data/dtos/discipline_dto.dart`
- `lib/app/data/dtos/race_format_configuration_dto.dart`
- `lib/app/data/dtos/race_format_detail_dto.dart`
- `lib/app/data/dtos/heat_dto.dart`
- `lib/app/data/dtos/entry_dto.dart`
- `lib/app/data/dtos/result_dto.dart`
- `lib/app/data/dtos/live_result_dto.dart`
- `lib/app/data/dtos/run_dto.dart`
- `lib/app/data/dtos/slot_dto.dart`
- `lib/app/data/dtos/meeting_dto.dart`

**Mappers (one per domain):**
- `lib/app/data/mappers/discipline_mapper.dart`
- `lib/app/data/mappers/race_format_configuration_mapper.dart`
- `lib/app/data/mappers/race_format_detail_mapper.dart`
- `lib/app/data/mappers/heat_mapper.dart`
- `lib/app/data/mappers/entry_mapper.dart`
- `lib/app/data/mappers/result_mapper.dart`
- `lib/app/data/mappers/live_result_mapper.dart`
- `lib/app/data/mappers/run_mapper.dart`
- `lib/app/data/mappers/slot_mapper.dart`
- `lib/app/data/mappers/meeting_mapper.dart`

**Data sources / repositories:**
- `lib/app/data/datasources/meeting_remote_datasource.dart`
- `lib/app/data/datasources/result_remote_datasource.dart` (UnimplementedError-throwing for now)
- `lib/app/data/repositories/meeting_repository.dart` — REWRITE (replaces 4a shim)
- `lib/app/data/repositories/result_repository.dart`

**Presentation:**
- `lib/app/presentation/modules/program/slot_formatting.dart` — extension on Slot/Run for view consumption (formattedBeginTime, runs count helpers, etc.)
- `lib/app/presentation/modules/slot/run_formatting.dart` — extension on Run (timeRange, formattedDuration, localizedStatus)

**Tests (new):**
- `test/data/mappers/run_mapper_test.dart`
- `test/data/mappers/heat_mapper_test.dart`
- `test/data/mappers/meeting_mapper_test.dart` (covers slot+run nested mapping)
- `test/data/repositories/meeting_repository_test.dart` — REWRITE (replaces 4a shim test)
- `test/data/repositories/result_repository_test.dart`
- `test/presentation/modules/slot/controllers/slot_controller_test.dart`

---

## Key types and contracts

### `RunStatus` enum

```dart
enum RunStatus { waiting, marshalling, inProgress, finished, unknown }

extension RunStatusFromInt on int {
  RunStatus toRunStatus() => switch (this) {
        0 => RunStatus.waiting,
        1 => RunStatus.marshalling,
        2 => RunStatus.inProgress,
        3 => RunStatus.finished,
        _ => RunStatus.unknown,
      };
}
```

### `Run` (domain)

```dart
@freezed
class Run with _$Run {
  const factory Run({
    required int id,
    required String name,
    required String label,
    required String fullLabel,
    required RunStatus status,
    required String statusLabel,
    required String site,
    required DateTime beginTime,
    required DateTime endTime,
    Heat? heat,
    @Default(<LiveResult>[]) List<LiveResult> liveResults,
  }) = _Run;

  factory Run.fromJson(Map<String, dynamic> json) => _$RunFromJson(json);
}
```

### `Slot` (domain)

```dart
@freezed
class Slot with _$Slot {
  const factory Slot({
    required int id,
    required String name,
    required DateTime beginHour,
    required DateTime endHour,
    RaceFormatDetail? raceFormatDetail,
    @Default(<Run>[]) List<Run> runs,
  }) = _Slot;

  factory Slot.fromJson(Map<String, dynamic> json) => _$SlotFromJson(json);
}
```

### `Meeting` (domain) — replaces 4a's legacy `MeetingModel`

```dart
@freezed
class Meeting with _$Meeting {
  const factory Meeting({
    required int id,
    required String name,
    required String description,
    required DateTime date,
    required DateTime beginHour,
    required DateTime endHour,
    @Default(<Slot>[]) List<Slot> slots,
  }) = _Meeting;

  factory Meeting.fromJson(Map<String, dynamic> json) => _$MeetingFromJson(json);
}
```

### `MeetingRepository` (real, replaces shim)

```dart
abstract class MeetingRepository {
  Future<List<Meeting>> getMeetings(int competitionId);
  Future<bool?> createMeeting({
    required Meeting meeting,
    required int competitionId,
  });
  Future<bool> deleteMeeting(int meetingId);
}
```

`createMeeting` takes named params (cleaner than passing a fully-constructed Meeting with id=0 just for the create call). The Impl converts to the form params the API expects.

### `ResultRepository`

```dart
abstract class ResultRepository {
  Future<List<LiveResult>> getRunResults(int runId);
  Future<bool> updateBeachRankings(int runId, Map<int, int> rankings);
  Future<bool> updateSwimmingTimes(int runId, Map<int, List<String>> times);
  Future<bool> withdrawAthlete({required int athleteId, required int runId});
}

class ResultRepositoryImpl implements ResultRepository {
  ResultRepositoryImpl(this._dataSource);
  final ResultRemoteDataSource _dataSource;

  @override
  Future<List<LiveResult>> getRunResults(int runId) async {
    // TODO(post-batch-6): wire to FFSS backend once endpoint is documented.
    // Legacy code called _apiService.getRunResults() which never existed.
    throw UnimplementedError('getRunResults: backend endpoint not wired');
  }

  @override
  Future<bool> updateBeachRankings(int runId, Map<int, int> rankings) {
    throw UnimplementedError('updateBeachRankings: backend endpoint not wired');
  }

  @override
  Future<bool> updateSwimmingTimes(int runId, Map<int, List<String>> times) {
    throw UnimplementedError('updateSwimmingTimes: backend endpoint not wired');
  }

  @override
  Future<bool> withdrawAthlete({required int athleteId, required int runId}) {
    throw UnimplementedError('withdrawAthlete: backend endpoint not wired');
  }
}
```

### Refactored `SlotController` (essentials)

```dart
class SlotController extends GetxController
    with GetSingleTickerProviderStateMixin {
  SlotController(this._results);
  final ResultRepository _results;

  late TabController tabController;
  final Rxn<Slot> slot = Rxn<Slot>();
  final RxBool isLoading = false.obs;
  final Rxn<AppException> error = Rxn<AppException>();
  final RxInt currentRunIndex = 0.obs;
  final RxInt currentBottomTabIndex = 0.obs;

  // Keyed by runId (was: keyed by list-index — fragile, spec bug #8)
  final RxMap<int, List<LiveResult>> runResults = <int, List<LiveResult>>{}.obs;
  final RxList<Athlete> allAthletes = <Athlete>[].obs;

  final RxBool isUpdatingResults = false.obs;
  final RxBool isWithdrawingAthlete = false.obs;
  final RxMap<int, int> beachRankings = <int, int>{}.obs;
  final RxMap<int, List<String>> swimmingTimes = <int, List<String>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is Slot && arg.runs.isNotEmpty) {
      slot.value = arg;
      tabController = TabController(length: arg.runs.length, vsync: this);
      _loadAllRunResults();
    }
  }

  Future<void> _loadAllRunResults() async {
    final s = slot.value;
    if (s == null) return;
    try {
      isLoading.value = true;
      error.value = null;
      for (final run in s.runs) {
        try {
          runResults[run.id] = await _results.getRunResults(run.id);
        } on UnimplementedError {
          runResults[run.id] = const [];
        } on AppException catch (e) {
          error.value = e;
          runResults[run.id] = const [];
        }
      }
      _refreshAthletes();
    } finally {
      isLoading.value = false;
    }
  }

  void _refreshAthletes() { /* unchanged logic — collect athletes from runResults */ }

  // ... discipline checks (string-matching, unchanged for now)
  // ... saveResults / withdrawAthlete delegate to ResultRepository (which throws UnimplementedError)
}
```

The legacy `Get.snackbar`/`Get.dialog`/`.tr` calls in the controller's mutation methods stay for now, with `// TODO(batch-6):` comments. They're called from view-driven flows (BeachRankingDialog, SwimTimeDialog) that are themselves dead code today. Cleaning them up in this batch adds churn without functional benefit.

---

## Tasks (15 total)

Task list below — each is a TDD-style commit boundary. Some leaf-domain tasks bundle multiple files because the test surface is small (e.g., Discipline + DisciplineMapper in one task because there's nothing complex to test).

### Task 1: Discipline + RaceFormatConfiguration + RaceFormatDetail domains

Three small leaf domains needed by Slot.raceFormatDetail. Single task because they're entangled (RaceFormatDetail.raceFormatConfiguration → Discipline + Categories).

**Files:**
- Create: 3 domain models, 3 DTOs, 3 mappers, 1 test (`race_format_detail_mapper_test.dart`)

**Domain content (all in `lib/app/domain/models/`):**

`discipline.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'discipline.freezed.dart';
part 'discipline.g.dart';

@freezed
class Discipline with _$Discipline {
  const factory Discipline({
    required String id,
    required String name,
    required int speciality,
    required String specialityLabel,
    @Default(0) int distance,
    @Default(0) int numberOfAthletes,
    @Default(false) bool isRelay,
    @Default(false) bool hasTime,
  }) = _Discipline;

  factory Discipline.fromJson(Map<String, dynamic> json) =>
      _$DisciplineFromJson(json);
}
```

`race_format_configuration.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/category.dart';
import 'package:live_ffss/app/domain/models/discipline.dart';

part 'race_format_configuration.freezed.dart';
part 'race_format_configuration.g.dart';

@freezed
class RaceFormatConfiguration with _$RaceFormatConfiguration {
  const factory RaceFormatConfiguration({
    required int id,
    required String label,
    required String fullLabel,
    required String gender,
    required String genderLabel,
    required Discipline discipline,
    @Default(<Category>[]) List<Category> categories,
  }) = _RaceFormatConfiguration;

  factory RaceFormatConfiguration.fromJson(Map<String, dynamic> json) =>
      _$RaceFormatConfigurationFromJson(json);
}
```

`race_format_detail.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'race_format_detail.freezed.dart';
part 'race_format_detail.g.dart';

@freezed
class RaceFormatDetail with _$RaceFormatDetail {
  const factory RaceFormatDetail({
    required int id,
    required int order,
    required String label,
    required String fullLabel,
    required String levelLabel,
    required String level,
    required int numberOfRun,
    required String qualificationMethod,
    required String qualificationMethodLabel,
    required int spotsPerRace,
    required int qualifyingSpots,
  }) = _RaceFormatDetail;

  factory RaceFormatDetail.fromJson(Map<String, dynamic> json) =>
      _$RaceFormatDetailFromJson(json);
}
```

**DTOs** mirror these exactly with `@JsonKey` mappings for the FFSS field names. Reference `lib/app/data/models/discipline_model.dart`, `race_format_configuration_model.dart`, `race_format_detail_model.dart` for the legacy field name conventions:

`discipline_dto.dart`:
```dart
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'discipline_dto.freezed.dart';
part 'discipline_dto.g.dart';

@freezed
class DisciplineDto with _$DisciplineDto {
  const factory DisciplineDto({
    @JsonKey(name: 'Id') required String id,
    @JsonKey(name: 'Nom') required String name,
    @JsonKey(name: 'specialite') required int speciality,
    @JsonKey(name: 'specialiteLabel') @Default('') String specialityLabel,
    @JsonKey(name: 'distance') @Default(0) int distance,
    @JsonKey(name: 'nbAthleteParEquipe') @Default(0) int numberOfAthletes,
    @JsonKey(name: 'isRelais') @Default(false) bool isRelay,
    @JsonKey(name: 'hasTemps') @Default(false) bool hasTime,
  }) = _DisciplineDto;

  factory DisciplineDto.fromJson(Map<String, dynamic> json) =>
      _$DisciplineDtoFromJson(json);
}
```

`race_format_configuration_dto.dart`:
```dart
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/data/dtos/category_dto.dart';
import 'package:live_ffss/app/data/dtos/discipline_dto.dart';

part 'race_format_configuration_dto.freezed.dart';
part 'race_format_configuration_dto.g.dart';

@freezed
class RaceFormatConfigurationDto with _$RaceFormatConfigurationDto {
  const factory RaceFormatConfigurationDto({
    @JsonKey(name: 'Id') required int id,
    @JsonKey(name: 'label') required String label,
    @JsonKey(name: 'fullLabel') required String fullLabel,
    @JsonKey(name: 'Genre') required String gender,
    @JsonKey(name: 'genreLabel') required String genderLabel,
    @JsonKey(name: 'Discipline') required DisciplineDto discipline,
    @JsonKey(name: 'categories', readValue: _readCategories)
    @Default(<CategoryDto>[]) List<CategoryDto> categories,
  }) = _RaceFormatConfigurationDto;

  factory RaceFormatConfigurationDto.fromJson(Map<String, dynamic> json) =>
      _$RaceFormatConfigurationDtoFromJson(json);
}

// FFSS quirk: categories arrive as [{categorie: {...}}, ...] not [{...}, ...]
Object? _readCategories(Map<dynamic, dynamic> map, String key) {
  final raw = map[key];
  if (raw is! List) return const <Map<String, dynamic>>[];
  return raw
      .whereType<Map<String, dynamic>>()
      .map((e) => e['categorie'])
      .whereType<Map<String, dynamic>>()
      .toList();
}
```

`race_format_detail_dto.dart`:
```dart
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'race_format_detail_dto.freezed.dart';
part 'race_format_detail_dto.g.dart';

@freezed
class RaceFormatDetailDto with _$RaceFormatDetailDto {
  const factory RaceFormatDetailDto({
    @JsonKey(name: 'id') required int id,
    @JsonKey(name: 'ordre') required int order,
    @JsonKey(name: 'label') required String label,
    @JsonKey(name: 'fullLabel') required String fullLabel,
    @JsonKey(name: 'niveauLabel') required String levelLabel,
    @JsonKey(name: 'niveau') required String level,
    @JsonKey(name: 'nbCourses') required int numberOfRun,
    @JsonKey(name: 'logiqueQualification') required String qualificationMethod,
    @JsonKey(name: 'logiqueQualificationLabel')
    required String qualificationMethodLabel,
    @JsonKey(name: 'nbPlaceParCourse') required int spotsPerRace,
    @JsonKey(name: 'nbPlaceQualificative') required int qualifyingSpots,
  }) = _RaceFormatDetailDto;

  factory RaceFormatDetailDto.fromJson(Map<String, dynamic> json) =>
      _$RaceFormatDetailDtoFromJson(json);
}
```

**Mappers** (3 files, simple `toDomain()` extensions):

`discipline_mapper.dart`:
```dart
import 'package:live_ffss/app/data/dtos/discipline_dto.dart';
import 'package:live_ffss/app/domain/models/discipline.dart';

extension DisciplineMapper on DisciplineDto {
  Discipline toDomain() => Discipline(
        id: id,
        name: name,
        speciality: speciality,
        specialityLabel: specialityLabel,
        distance: distance,
        numberOfAthletes: numberOfAthletes,
        isRelay: isRelay,
        hasTime: hasTime,
      );
}
```

`race_format_configuration_mapper.dart`:
```dart
import 'package:live_ffss/app/data/dtos/race_format_configuration_dto.dart';
import 'package:live_ffss/app/data/mappers/category_mapper.dart';
import 'package:live_ffss/app/data/mappers/discipline_mapper.dart';
import 'package:live_ffss/app/domain/models/race_format_configuration.dart';

extension RaceFormatConfigurationMapper on RaceFormatConfigurationDto {
  RaceFormatConfiguration toDomain() => RaceFormatConfiguration(
        id: id,
        label: label,
        fullLabel: fullLabel,
        gender: gender,
        genderLabel: genderLabel,
        discipline: discipline.toDomain(),
        categories: categories.map((c) => c.toDomain()).toList(),
      );
}
```

`race_format_detail_mapper.dart`:
```dart
import 'package:live_ffss/app/data/dtos/race_format_detail_dto.dart';
import 'package:live_ffss/app/domain/models/race_format_detail.dart';

extension RaceFormatDetailMapper on RaceFormatDetailDto {
  RaceFormatDetail toDomain() => RaceFormatDetail(
        id: id,
        order: order,
        label: label,
        fullLabel: fullLabel,
        levelLabel: levelLabel,
        level: level,
        numberOfRun: numberOfRun,
        qualificationMethod: qualificationMethod,
        qualificationMethodLabel: qualificationMethodLabel,
        spotsPerRace: spotsPerRace,
        qualifyingSpots: qualifyingSpots,
      );
}
```

**Test** (one focused test for `RaceFormatDetailMapper`):
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/dtos/race_format_detail_dto.dart';
import 'package:live_ffss/app/data/mappers/race_format_detail_mapper.dart';

void main() {
  test('RaceFormatDetailMapper maps full DTO', () {
    const dto = RaceFormatDetailDto(
      id: 1,
      order: 2,
      label: 'L',
      fullLabel: 'FL',
      levelLabel: 'NL',
      level: 'eau-plate',
      numberOfRun: 4,
      qualificationMethod: 'time',
      qualificationMethodLabel: 'TimeLabel',
      spotsPerRace: 8,
      qualifyingSpots: 2,
    );
    final d = dto.toDomain();
    expect(d.id, 1);
    expect(d.numberOfRun, 4);
    expect(d.level, 'eau-plate');
  });
}
```

**Steps:** Create files, run `dart run build_runner build --delete-conflicting-outputs`, run the test, commit.

```bash
git commit -m "feat(domain): add Discipline, RaceFormatConfiguration, RaceFormatDetail

Three leaf domains used by Slot.raceFormatDetail. RaceFormatConfiguration
unwraps the [{categorie: {...}}] shape into a flat List<Category> at the
DTO level via a readValue hook."
```

---

### Task 2: Heat domain + DTO + mapper

Fixes the legacy `Heat.fromJson` bug (reads `resultats` into a dead local) by simply not having a `resultats` field on the DTO.

**Files:** 3 (domain, DTO, mapper) + 1 test

`heat.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'heat.freezed.dart';
part 'heat.g.dart';

@freezed
class Heat with _$Heat {
  const factory Heat({
    required int id,
    required String name,
    required bool done,
    required int number,
  }) = _Heat;

  factory Heat.fromJson(Map<String, dynamic> json) => _$HeatFromJson(json);
}
```

`heat_dto.dart`:
```dart
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'heat_dto.freezed.dart';
part 'heat_dto.g.dart';

@freezed
class HeatDto with _$HeatDto {
  const factory HeatDto({
    @JsonKey(name: 'Id') required int id,
    @JsonKey(name: 'Nom') required String name,
    @JsonKey(name: 'Fini') required bool done,
    @JsonKey(name: 'Numero', readValue: _readNumber) required int number,
  }) = _HeatDto;

  factory HeatDto.fromJson(Map<String, dynamic> json) =>
      _$HeatDtoFromJson(json);
}

Object? _readNumber(Map<dynamic, dynamic> map, String key) {
  final raw = map[key];
  if (raw is String) return int.tryParse(raw) ?? 0;
  return raw;
}
```

`heat_mapper.dart`:
```dart
import 'package:live_ffss/app/data/dtos/heat_dto.dart';
import 'package:live_ffss/app/domain/models/heat.dart';

extension HeatMapper on HeatDto {
  Heat toDomain() => Heat(
        id: id,
        name: name,
        done: done,
        number: number,
      );
}
```

**Test** covers the int/String number quirk + the dead-resultats bug fix:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/dtos/heat_dto.dart';
import 'package:live_ffss/app/data/mappers/heat_mapper.dart';

void main() {
  test('HeatMapper maps with int Numero', () {
    final dto = HeatDto.fromJson(const {
      'Id': 1,
      'Nom': 'A',
      'Fini': false,
      'Numero': 3,
    });
    expect(dto.toDomain().number, 3);
  });

  test('HeatMapper maps with String Numero', () {
    final dto = HeatDto.fromJson(const {
      'Id': 1,
      'Nom': 'A',
      'Fini': true,
      'Numero': '7',
    });
    expect(dto.toDomain().number, 7);
  });
}
```

Commit msg:
```
feat(domain): add Heat domain + DTO + mapper

Fixes legacy bug where Heat.fromJson read resultats into a dead local.
The new DTO simply doesn't have a resultats field — Heat carries only
id/name/done/number. Numero coerces String->int via readValue hook.
```

---

### Task 3: Entry + Result + LiveResult domains

Tightly coupled (LiveResult embeds Entry + Result; Result embeds Heat + Entry + athletes). Single task because their tests are small.

**Files:** 3 domains + 3 DTOs + 3 mappers + 1 test (`live_result_mapper_test.dart`)

`entry.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/category.dart';

part 'entry.freezed.dart';
part 'entry.g.dart';

@freezed
class Entry with _$Entry {
  const factory Entry({
    required int id,
    required Category category,
    required int status,
    required String statusLabel,
    required int entryTime,
    required String entryTimeLabel,
    @Default(<Athlete>[]) List<Athlete> athletes,
  }) = _Entry;

  factory Entry.fromJson(Map<String, dynamic> json) => _$EntryFromJson(json);
}
```

`result.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/entry.dart';
import 'package:live_ffss/app/domain/models/heat.dart';

part 'result.freezed.dart';
part 'result.g.dart';

@freezed
class Result with _$Result {
  const factory Result({
    required String id,
    required bool isValid,
    required int status,
    required String statusLabel,
    @Default(false) bool isDisqualified,
    required int rank,
    required int time,
    required String timeLabel,
    String? complement,
    String? complementLabel,
    @Default('') String disqualificationCode,
    @Default('') String disqualificationComment,
    required Heat heat,
    required Entry entry,
    @Default(<Athlete>[]) List<Athlete> athletes,
    @Default(false) bool isRecord,
    @Default(false) bool isBestPerformance,
    @Default(false) bool isFranceRecord,
    @Default(0) int points,
    @Default(0) int liveTime1,
    @Default(0) int liveTime2,
    @Default(0) int liveTime3,
  }) = _Result;

  factory Result.fromJson(Map<String, dynamic> json) =>
      _$ResultFromJson(json);
}
```

`live_result.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/entry.dart';
import 'package:live_ffss/app/domain/models/result.dart';

part 'live_result.freezed.dart';
part 'live_result.g.dart';

@freezed
class LiveResult with _$LiveResult {
  const factory LiveResult({
    required int id,
    @Default('') String number,
    Entry? entry,
    Result? result,
  }) = _LiveResult;

  factory LiveResult.fromJson(Map<String, dynamic> json) =>
      _$LiveResultFromJson(json);
}

extension LiveResultX on LiveResult {
  int? get currentRank => result?.rank;
  int? get currentTime => result?.time;
  String? get currentTimeLabel => result?.timeLabel;
  bool get hasValidResult => result?.isValid == true;
  bool get isDisqualified => result?.isDisqualified == true;
}
```

**DTOs** mirror the FFSS field names (`engagement`, `Resultat`, `categorie`, etc.). For brevity, see legacy `entry_model.dart`, `result_model.dart`, `live_result_model.dart` for the field-name conventions and apply `@JsonKey(name: '...')` accordingly. Pattern is the same as Tasks 1-2.

**Mappers** are simple. `entry_mapper.dart` reuses `CategoryMapper` and `AthleteMapper`. `result_mapper.dart` reuses `HeatMapper`, `EntryMapper`, `AthleteMapper`. `live_result_mapper.dart` reuses `EntryMapper`, `ResultMapper`.

**Test** (`live_result_mapper_test.dart`):
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/dtos/live_result_dto.dart';
import 'package:live_ffss/app/data/mappers/live_result_mapper.dart';

void main() {
  test('LiveResultMapper handles null entry and result', () {
    const dto = LiveResultDto(id: 1, number: '5');
    final lr = dto.toDomain();
    expect(lr.id, 1);
    expect(lr.number, '5');
    expect(lr.entry, isNull);
    expect(lr.result, isNull);
    expect(lr.hasValidResult, isFalse);
    expect(lr.isDisqualified, isFalse);
  });
}
```

Commit msg:
```
feat(domain): add Entry, Result, LiveResult domains + mappers

Three coupled domains needed by SlotView's results list. LiveResultX
extension provides the helper getters (currentRank, isDisqualified,
etc.) that the legacy LiveResultModel had inline.
```

---

### Task 4: Run domain + DTO + mapper

**Files:** 1 domain + 1 DTO + 1 mapper + 1 test

`run.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/heat.dart';
import 'package:live_ffss/app/domain/models/live_result.dart';

part 'run.freezed.dart';
part 'run.g.dart';

enum RunStatus { waiting, marshalling, inProgress, finished, unknown }

@freezed
class Run with _$Run {
  const factory Run({
    required int id,
    required String name,
    required String label,
    required String fullLabel,
    required RunStatus status,
    required String statusLabel,
    required String site,
    required DateTime beginTime,
    required DateTime endTime,
    Heat? heat,
    @Default(<LiveResult>[]) List<LiveResult> liveResults,
  }) = _Run;

  factory Run.fromJson(Map<String, dynamic> json) => _$RunFromJson(json);
}

extension RunStatusX on int {
  RunStatus get asRunStatus => switch (this) {
        0 => RunStatus.waiting,
        1 => RunStatus.marshalling,
        2 => RunStatus.inProgress,
        3 => RunStatus.finished,
        _ => RunStatus.unknown,
      };
}
```

`run_dto.dart` — legacy keys are `id`, `Nom`, `label`, `fullLabel`, `statut` (int), `statutLabel`, `site`, `debut`, `fin`. Time fields are HH:mm strings, parsed in mapper. heat / liveResults likely embedded somewhere — defaults to empty.

`run_mapper.dart` — handles the HH:mm → DateTime parsing using a today-as-baseline DateTime (legacy used `FormatConst.timeFormat.parse` which gives a 1970-baseline DateTime; preserve that to avoid behavioral drift).

**Test:**
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/dtos/run_dto.dart';
import 'package:live_ffss/app/data/mappers/run_mapper.dart';
import 'package:live_ffss/app/domain/models/run.dart';

void main() {
  test('RunMapper parses begin/end times and status int', () {
    final dto = RunDto.fromJson(const {
      'id': 1,
      'Nom': 'Run 1',
      'label': 'L',
      'fullLabel': 'FL',
      'statut': 2,
      'statutLabel': 'In Progress',
      'site': 'Pool A',
      'debut': '10:00',
      'fin': '11:30',
    });
    final r = dto.toDomain();
    expect(r.id, 1);
    expect(r.status, RunStatus.inProgress);
    expect(r.beginTime.hour, 10);
    expect(r.endTime.hour, 11);
  });

  test('RunMapper handles unknown status code', () {
    final dto = RunDto.fromJson(const {
      'id': 1, 'Nom': 'X', 'label': 'X', 'fullLabel': 'X',
      'statut': 99, 'statutLabel': '', 'site': '',
      'debut': '00:00', 'fin': '00:00',
    });
    expect(dto.toDomain().status, RunStatus.unknown);
  });
}
```

Commit msg:
```
feat(domain): add Run domain + DTO + mapper + RunStatus enum

Replaces the legacy RunModel.statusColor/isWaiting/etc. inline status
logic with a typed RunStatus enum. RunStatusX extension converts the
FFSS integer status codes (0/1/2/3) at the mapper boundary.
```

---

### Task 5: Slot domain + DTO + mapper

**Files:** 1 domain + 1 DTO + 1 mapper

`slot.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/race_format_detail.dart';
import 'package:live_ffss/app/domain/models/run.dart';

part 'slot.freezed.dart';
part 'slot.g.dart';

@freezed
class Slot with _$Slot {
  const factory Slot({
    required int id,
    required String name,
    required DateTime beginHour,
    required DateTime endHour,
    RaceFormatDetail? raceFormatDetail,
    @Default(<Run>[]) List<Run> runs,
  }) = _Slot;

  factory Slot.fromJson(Map<String, dynamic> json) => _$SlotFromJson(json);
}
```

`slot_dto.dart` — legacy keys: `id`, `Nom`, `Debut`, `Fin`, `partie` (raceFormatDetail), `courses` (runs).

`slot_mapper.dart` — uses `RunMapper` and `RaceFormatDetailMapper`. Date parsing same pattern as Run.

No test (covered transitively via meeting_mapper_test.dart in Task 6).

Commit msg:
```
feat(domain): add Slot domain + DTO + mapper

Embeds typed List<Run> + RaceFormatDetail?. Begin/end hours parsed
from HH:mm strings, matching the legacy SlotModel behavior.
```

---

### Task 6: Meeting domain + DTO + mapper (with TDD)

Replaces the legacy `MeetingModel`. The 4a `MeetingRepository` shim still uses legacy `MeetingModel` — that gets switched in Task 7.

**Files:** 1 domain + 1 DTO + 1 mapper + 1 test

`meeting.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/slot.dart';

part 'meeting.freezed.dart';
part 'meeting.g.dart';

@freezed
class Meeting with _$Meeting {
  const factory Meeting({
    required int id,
    required String name,
    required String description,
    required DateTime date,
    required DateTime beginHour,
    required DateTime endHour,
    @Default(<Slot>[]) List<Slot> slots,
  }) = _Meeting;

  factory Meeting.fromJson(Map<String, dynamic> json) => _$MeetingFromJson(json);
}
```

`meeting_dto.dart` — legacy keys: `Id`, `Nom`, `Description`, `Jour` (date), `Debut`, `Fin`, `creneaus` (slots).

`meeting_mapper.dart` — combines date (Jour) with begin/end times to construct full DateTimes (legacy did this in `MeetingModel.fromJson`). Sorts slots by beginHour after mapping.

**Test** (covers the slot+run nested case end-to-end):
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/dtos/meeting_dto.dart';
import 'package:live_ffss/app/data/mappers/meeting_mapper.dart';

void main() {
  test('MeetingMapper composes date + times into full DateTimes', () {
    final dto = MeetingDto.fromJson(const {
      'Id': 1,
      'Nom': 'M',
      'Description': '',
      'Jour': '2026-05-01',
      'Debut': '10:00',
      'Fin': '12:00',
    });
    final m = dto.toDomain();
    expect(m.id, 1);
    expect(m.date, DateTime(2026, 5, 1));
    expect(m.beginHour, DateTime(2026, 5, 1, 10, 0));
    expect(m.endHour, DateTime(2026, 5, 1, 12, 0));
    expect(m.slots, isEmpty);
  });

  test('MeetingMapper parses embedded slots and sorts by begin time', () {
    final dto = MeetingDto.fromJson(const {
      'Id': 1,
      'Nom': 'M',
      'Description': '',
      'Jour': '2026-05-01',
      'Debut': '10:00',
      'Fin': '14:00',
      'creneaus': [
        {'id': 2, 'Nom': 'B', 'Debut': '12:00', 'Fin': '13:00'},
        {'id': 1, 'Nom': 'A', 'Debut': '10:30', 'Fin': '11:30'},
      ],
    });
    final m = dto.toDomain();
    expect(m.slots.length, 2);
    expect(m.slots.first.id, 1); // A first (10:30 < 12:00)
  });
}
```

Commit msg:
```
feat(domain): add Meeting domain + DTO + mapper

Replaces legacy MeetingModel. Combines Jour + Debut/Fin into full
DateTimes at the mapper layer. Sorts embedded slots by beginHour.
```

---

### Task 7: Real MeetingRepository — replaces 4a shim

**Files:**
- Modify (rewrite): `lib/app/data/repositories/meeting_repository.dart`
- Modify (rewrite): `test/data/repositories/meeting_repository_test.dart`
- Create: `lib/app/data/datasources/meeting_remote_datasource.dart`

**MeetingRemoteDataSource:**

```dart
import 'package:live_ffss/app/core/config/app_config.dart';
import 'package:live_ffss/app/core/network/http_client.dart';
import 'package:live_ffss/app/data/dtos/meeting_dto.dart';

abstract class MeetingRemoteDataSource {
  Future<List<MeetingDto>> getMeetings(int competitionId);
  Future<bool> createMeeting({
    required String name,
    required String description,
    required String dayIso,        // 'YYYY-MM-DD'
    required String beginTime,     // 'HH:mm'
    required String endTime,       // 'HH:mm'
    required int competitionId,
  });
  Future<bool> deleteMeeting(int meetingId);
}

class MeetingRemoteDataSourceImpl implements MeetingRemoteDataSource {
  MeetingRemoteDataSourceImpl(this._http);
  final HttpClient _http;

  @override
  Future<List<MeetingDto>> getMeetings(int competitionId) async {
    final endpoint = ApiEndpoints.replacePath(
      ApiEndpoints.meetingList,
      {'id': competitionId.toString()},
    );
    final body = await _http.get(endpoint);
    final list = (body['data'] as List?) ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(MeetingDto.fromJson)
        .toList();
  }

  @override
  Future<bool> createMeeting({
    required String name,
    required String description,
    required String dayIso,
    required String beginTime,
    required String endTime,
    required int competitionId,
  }) async {
    final endpoint = ApiEndpoints.replacePath(
      ApiEndpoints.meetingSubmit,
      {'competition': competitionId.toString()},
    );
    final body = await _http.post(endpoint, query: {
      'id': '',
      'nom': name,
      'description': description,
      'jour': dayIso,
      'debut': beginTime,
      'fin': endTime,
    });
    return body['success'] == true;
  }

  @override
  Future<bool> deleteMeeting(int meetingId) async {
    final endpoint = ApiEndpoints.replacePath(
      ApiEndpoints.meetingDelete,
      {'id': meetingId.toString()},
    );
    final body = await _http.post(endpoint);
    return body['success'] == true;
  }
}
```

**MeetingRepository (real):**

```dart
import 'package:intl/intl.dart';
import 'package:live_ffss/app/data/datasources/meeting_remote_datasource.dart';
import 'package:live_ffss/app/data/mappers/meeting_mapper.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';

abstract class MeetingRepository {
  Future<List<Meeting>> getMeetings(int competitionId);
  Future<bool> createMeeting({
    required String name,
    required String description,
    required DateTime date,
    required DateTime beginHour,
    required DateTime endHour,
    required int competitionId,
  });
  Future<bool> deleteMeeting(int meetingId);
}

class MeetingRepositoryImpl implements MeetingRepository {
  MeetingRepositoryImpl(this._dataSource);
  final MeetingRemoteDataSource _dataSource;

  @override
  Future<List<Meeting>> getMeetings(int competitionId) async {
    final dtos = await _dataSource.getMeetings(competitionId);
    return dtos.map((d) => d.toDomain()).toList();
  }

  @override
  Future<bool> createMeeting({
    required String name,
    required String description,
    required DateTime date,
    required DateTime beginHour,
    required DateTime endHour,
    required int competitionId,
  }) =>
      _dataSource.createMeeting(
        name: name,
        description: description,
        dayIso: DateFormat('yyyy-MM-dd').format(date),
        beginTime: DateFormat('HH:mm').format(beginHour),
        endTime: DateFormat('HH:mm').format(endHour),
        competitionId: competitionId,
      );

  @override
  Future<bool> deleteMeeting(int meetingId) =>
      _dataSource.deleteMeeting(meetingId);
}
```

This is a **breaking API change** to `MeetingRepository`:
- Returns `List<Meeting>` (domain) instead of `List<MeetingModel>` (legacy).
- `createMeeting` takes named params (no longer a Meeting object).

`ProgramController` was written in Batch 4a expecting the legacy shape. **It will need updating in Task 9.** Tests will fail until then. That's expected.

**Test rewrite:**

REPLACE `test/data/repositories/meeting_repository_test.dart` with a test against the new shape — mock `MeetingRemoteDataSource`, verify mapping orchestration.

Commit msg:
```
feat(data): MeetingRepository now returns typed Meeting domain

Replaces the Batch 4a shim. New MeetingRemoteDataSource calls the
HttpClient directly. createMeeting takes named params instead of a
constructed Meeting object. ProgramController will be updated in the
next commit (transient compile errors expected).
```

---

### Task 8: ResultRepository (UnimplementedError stubs) (TDD)

**Files:**
- Create: `lib/app/data/datasources/result_remote_datasource.dart`
- Create: `lib/app/data/repositories/result_repository.dart`
- Create: `test/data/repositories/result_repository_test.dart`

**ResultRemoteDataSource:**
```dart
import 'package:live_ffss/app/data/dtos/live_result_dto.dart';

abstract class ResultRemoteDataSource {
  Future<List<LiveResultDto>> getRunResults(int runId);
  Future<bool> updateBeachRankings(int runId, Map<int, int> rankings);
  Future<bool> updateSwimmingTimes(int runId, Map<int, List<String>> times);
  Future<bool> withdrawAthlete({required int athleteId, required int runId});
}

class ResultRemoteDataSourceImpl implements ResultRemoteDataSource {
  ResultRemoteDataSourceImpl();

  @override
  Future<List<LiveResultDto>> getRunResults(int runId) {
    throw UnimplementedError(
      'getRunResults: backend endpoint not documented. '
      'Legacy SlotController._loadRunResultsFromApi was a TODO stub. '
      'Wire when FFSS API surface is clarified.',
    );
  }

  @override
  Future<bool> updateBeachRankings(int runId, Map<int, int> rankings) {
    throw UnimplementedError('updateBeachRankings: backend endpoint TBD');
  }

  @override
  Future<bool> updateSwimmingTimes(int runId, Map<int, List<String>> times) {
    throw UnimplementedError('updateSwimmingTimes: backend endpoint TBD');
  }

  @override
  Future<bool> withdrawAthlete({required int athleteId, required int runId}) {
    throw UnimplementedError('withdrawAthlete: backend endpoint TBD');
  }
}
```

**ResultRepository:** Pure delegation to the data source — same UnimplementedError pass-through.

```dart
import 'package:live_ffss/app/data/datasources/result_remote_datasource.dart';
import 'package:live_ffss/app/data/mappers/live_result_mapper.dart';
import 'package:live_ffss/app/domain/models/live_result.dart';

abstract class ResultRepository {
  Future<List<LiveResult>> getRunResults(int runId);
  Future<bool> updateBeachRankings(int runId, Map<int, int> rankings);
  Future<bool> updateSwimmingTimes(int runId, Map<int, List<String>> times);
  Future<bool> withdrawAthlete({required int athleteId, required int runId});
}

class ResultRepositoryImpl implements ResultRepository {
  ResultRepositoryImpl(this._dataSource);
  final ResultRemoteDataSource _dataSource;

  @override
  Future<List<LiveResult>> getRunResults(int runId) async {
    final dtos = await _dataSource.getRunResults(runId);
    return dtos.map((d) => d.toDomain()).toList();
  }

  @override
  Future<bool> updateBeachRankings(int runId, Map<int, int> rankings) =>
      _dataSource.updateBeachRankings(runId, rankings);

  @override
  Future<bool> updateSwimmingTimes(int runId, Map<int, List<String>> times) =>
      _dataSource.updateSwimmingTimes(runId, times);

  @override
  Future<bool> withdrawAthlete({required int athleteId, required int runId}) =>
      _dataSource.withdrawAthlete(athleteId: athleteId, runId: runId);
}
```

**Test:**
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/datasources/result_remote_datasource.dart';
import 'package:live_ffss/app/data/repositories/result_repository.dart';

void main() {
  late ResultRepository repo;

  setUp(() {
    repo = ResultRepositoryImpl(ResultRemoteDataSourceImpl());
  });

  test('getRunResults throws UnimplementedError', () {
    expect(repo.getRunResults(1), throwsA(isA<UnimplementedError>()));
  });

  test('updateBeachRankings throws UnimplementedError', () {
    expect(repo.updateBeachRankings(1, {}),
        throwsA(isA<UnimplementedError>()));
  });

  test('updateSwimmingTimes throws UnimplementedError', () {
    expect(repo.updateSwimmingTimes(1, {}),
        throwsA(isA<UnimplementedError>()));
  });

  test('withdrawAthlete throws UnimplementedError', () {
    expect(repo.withdrawAthlete(athleteId: 1, runId: 1),
        throwsA(isA<UnimplementedError>()));
  });
}
```

Commit msg:
```
feat(data): add ResultRepository with UnimplementedError stubs

Four endpoint methods (getRunResults, updateBeachRankings,
updateSwimmingTimes, withdrawAthlete) all throw UnimplementedError
with documented TODOs — the FFSS backend endpoints aren't wired in
the legacy code either. SlotController catches UnimplementedError
gracefully (Task 9).
```

---

### Task 9: ProgramController — switch to new Meeting domain

**Files:**
- Modify: `lib/app/module/program/controllers/program_controller.dart` (the 4a one needs updating against the new MeetingRepository signature)
- Modify: `test/presentation/modules/program/controllers/program_controller_test.dart` (update fixtures to use new Meeting type)
- Modify: `lib/app/module/program/views/program_view.dart` (slot rendering uses new typed Slot.runs.length etc.)

**ProgramController changes:**
- `meetings: RxList<Meeting>` (was `RxList<MeetingModel>`)
- `submitMeeting` calls `_meetingRepo.createMeeting(name:, description:, date:, beginHour:, endHour:, competitionId:)` — passing form values directly
- `deleteMeeting(Meeting)` — type swap
- `totalSlotsCount` getter unchanged in shape

**Test updates:**
- `_FakeMeeting` → use real `Meeting` constructor with required fields
- Adjust the `submitMeeting` test expectations (the meta call to `repo.createMeeting` now has different param shape)

**ProgramView updates:**
- Imports: drop `data/models/meeting_model.dart` and `data/models/slot_model.dart`. Add `domain/models/meeting.dart`, `domain/models/slot.dart`.
- `_buildExpandableMeetingCard(BuildContext, Meeting, int)`
- `_buildSlotsSection(Meeting meeting)`
- `_buildSlotCard(Slot slot, int index)` — `slot.runs.length` works since `runs: List<Run>`. `slot.beginHour` etc. are typed DateTime.

Commit msg:
```
refactor(program): switch to typed Meeting/Slot domains

ProgramController.meetings is now RxList<Meeting>. submitMeeting
flattens form values into named MeetingRepository.createMeeting params.
ProgramView's slot rendering uses domain types directly.
```

---

### Task 10: SlotController refactor (TDD)

**Files:**
- Modify (rewrite): `lib/app/module/slot/controllers/slot_controller.dart`
- Create: `test/presentation/modules/slot/controllers/slot_controller_test.dart`

Full controller rewrite per the contract above. Key behaviors:
- Constructor-injects `ResultRepository`
- `slot: Rxn<Slot>` (was `Rxn<SlotModel>`)
- `runResults: RxMap<int, List<LiveResult>>` keyed by `runId` (spec bug #8 fix)
- `_loadAllRunResults` catches `UnimplementedError` gracefully (per-run empty list)
- Mutation methods (`saveResults`, `withdrawAthlete`) still wrap in try/catch + Get.snackbar with `// TODO(batch-6):` markers — they'll throw `UnimplementedError` from the repo but the snackbar shows a friendly error
- `isBeachDiscipline` / `isSwimmingDiscipline` still string-match (TODO marked)

Test stubs `ResultRepository`, verifies:
- onInit with valid Slot loads runResults
- runResults is keyed by runId, not index
- `UnimplementedError` from repo doesn't break the controller (sets empty list, doesn't throw)
- mutation methods set `isUpdatingResults`/`isWithdrawingAthlete` flags

---

### Task 11: SlotView updates

`SlotView` is 742 LOC — the largest view. **No structural split** in this batch. Just type swaps:

- `slot: Slot` (was `SlotModel`)
- `RunModel` → `Run`
- `LiveResultModel` → `LiveResult` (with `LiveResultX` extension for `currentRank`/etc.)
- `AthleteModel` → `Athlete`
- `slot.raceFormatDetailModel` → `slot.raceFormatDetail`
- `run.localizedStatus` is no longer a getter on Run — use a small inline switch or a `RunStatus`-based extension. Easiest: add a `RunStatusFormatting` extension that exposes `localizedStatus`/`statusColor`.

Commit msg:
```
refactor(slot): SlotView on new domain types

Swaps SlotModel/RunModel/LiveResultModel/AthleteModel for the new
domain types. localizedStatus moves to a presentation extension.
No structural split — that's a Batch 6 cleanup.
```

---

### Task 12: BeachRankingDialog + SwimTimeDialog updates

These are dead-code today (the SlotController's `_openBeachRankingDialog` and `_openSwimmingTimesDialog` have commented-out `Get.dialog` calls). Touch them only enough to compile against the new types — keep the dead-code state. Batch 6 either revives them with the actual feature or deletes them.

---

### Task 13: SlotBinding + InitialBinding wiring

**SlotBinding:**

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/data/repositories/result_repository.dart';
import '../controllers/slot_controller.dart';

class SlotBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SlotController>(
      () => SlotController(Get.find<ResultRepository>()),
    );
  }
}
```

**InitialBinding additions** — in `lib/app/core/di/initial_binding.dart`, ADD imports + registrations for:
- `MeetingRemoteDataSource` + `MeetingRepository` (replaces the 4a transitional shim block)
- `ResultRemoteDataSource` + `ResultRepository`

**Most importantly**, the existing transitional `Get.put<MeetingRepository>(MeetingRepositoryImpl(Get.find<ApiService>()))` line gets REPLACED with:
```dart
    Get.put<MeetingRemoteDataSource>(
      MeetingRemoteDataSourceImpl(Get.find<HttpClient>()),
      permanent: true,
    );
    Get.put<MeetingRepository>(
      MeetingRepositoryImpl(Get.find<MeetingRemoteDataSource>()),
      permanent: true,
    );
```

The `MeetingRepositoryImpl` now takes `MeetingRemoteDataSource` instead of `ApiService`.

---

### Task 14: Remove legacy ApiService dependency from runtime

After Task 13, `Get.find<ApiService>()` is no longer called by any controller (Slot was the last one). The `ApiService` instance still gets registered in `InitialBinding` for safety — Batch 6 will delete the registration along with the file.

Verification step:
- `grep -rn "Get.find<ApiService>" lib/app/module/` — should return ZERO matches.
- `grep -rn "import.*api_service.dart" lib/app/module/` — also ZERO.
- `flutter analyze` clean.
- `flutter test` green — ~125 tests.

If `slot_controller.dart` still imports api_service.dart from the legacy days (lib/app/data/services/api_service.dart), remove that import (the controller now uses ResultRepository).

---

### Task 15: Final verification

Same pattern as prior batches. Run:
- `flutter test` → all green (~130 tests cumulative).
- `flutter analyze` → zero errors. Pre-existing legacy infos may have shrunk (slot_controller's pre-existing warnings will be gone since the file is rewritten).
- `git log --oneline main..HEAD` → ~14-15 commits.
- Manual smoke test: home → competition → program → tap a meeting slot → slot view loads (with empty results, since the endpoint is unimplemented).

---

## Self-review

**Spec coverage** (against §14 "Batch 5 — Run + Result domains"):
- DTOs/mappers/datasources/repositories for Run, Result, LiveResult → Tasks 3, 4, 8 ✓
- Implement four stubbed methods → Task 8 (UnimplementedError stubs — endpoints not documented; spec §13 explicitly listed this as the open question) ✓
- Re-key `runResults` by `runId` → Task 10 ✓
- Split slot_view.dart into widgets → **DEFERRED** to Batch 6 (mechanical, doesn't change behavior)
- Replace beach/swim string-matching with Discipline enum → **DEFERRED** to Batch 6 (pure refactor; not blocking)

**Plus the deferred Batch 4b work covered here:**
- Meeting + Slot full domains → Tasks 5, 6 ✓
- Replace MeetingRepository shim → Task 7 ✓

**Placeholder scan:** None. All UnimplementedError stubs are documented at the seam — they're not "TODO" placeholders, they're explicit "endpoint unknown" markers that compile cleanly.

**Type consistency:**
- All new domain types use the same naming patterns (lowercase camelCase fields, exact match between domain and mapper output).
- `Run.status: RunStatus` enum used uniformly in domain, controller, view.
- `MeetingRepository.createMeeting` named params match the call site in `ProgramController.submitMeeting`.

---

## Done criteria for Batch 5

- ~14-15 commits on `refactor/batch-5-slot-meeting-results`.
- New: 10 domain models + 10 DTOs + 10 mappers + 2 datasources + 1 new repo + 2 mapper/repo tests + 1 slot controller test = ~37 new files.
- Modified: ProgramController, ProgramView, SlotController, SlotView, BeachRankingDialog, SwimTimeDialog, SlotBinding, InitialBinding, MeetingRepository (rewrite), MeetingRepository test (rewrite).
- `flutter analyze`: zero errors.
- `flutter test`: ~130 tests, all green.
- `Get.find<ApiService>()` ZERO matches in `lib/app/module/`.
- All controllers use proper repositories.
- Live results display shows empty state (legacy behavior preserved — endpoint not wired).
- Meeting create/delete flows work end-to-end via the new Meeting domain.
