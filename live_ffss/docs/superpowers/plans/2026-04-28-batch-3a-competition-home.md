# Batch 3a — Competition Domain + Home Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate the Competition domain end-to-end onto the Batch-0 infrastructure: typed `Competition` domain (with typed status enums) + freezed DTOs + mappers + per-domain `CompetitionRemoteDataSource` and `CompetitionRepository`. Refactor `HomeController` to constructor-inject `CompetitionRepository` and drop the legacy `ApiService`. Update `home_view.dart` to use the new types via a presentation-side formatting extension. Legacy `ApiService.getCompetitions(...)` becomes unused (still alive — Batch 3b/4/5 use it).

**Architecture:** Per design spec §6-9. Three-layer pragmatic split applied to Competition (with embedded basic Club). `home_view.dart` keeps its existing layout — only the source-of-truth for `Competition` data changes. View-side formatting (date strings, status enums → translated labels, status colors) moves to `lib/app/presentation/modules/home/competition_formatting.dart` as an extension.

**Tech Stack:** freezed + json_serializable + build_runner, mocktail (already installed since Batch 0). GetX for DI/state. No new dependencies.

---

## Notes & deviations from spec

1. **Batch 3 split into 3a + 3b.** Original spec §14 lists "Competition + Race + Club domains" as one batch. After exploring the legacy code, that batch is genuinely large (6 domain types, 3 datasources, 3 repositories, 2 controller refactors, view changes). I'm splitting it: this plan covers **Competition + Home** only. Batch 3b (separate plan) covers Race + Club expansion + Athletes/Referees/Categories + the two `CompetitionDetail*Controller`s.

2. **Club domain stays minimal in 3a.** Competition's `organizerClub` only carries `id/name/shortName/logoUrl/capUrl` from the FFSS API. Athletes/referees on the Club aren't populated until the dedicated `getClubs`/`getClubDetail` endpoints are called — that's Batch 3b. So the Club domain model in 3a has empty `athletes`/`referees` lists with `@Default([])` and Batch 3b expands the mapper.

3. **Computed status getters become typed enums.** Legacy `CompetitionModel.entryStatus` returns a translated `String` like `'open'.tr` and `competitionStatus` does the same. Plus there's a buggy line at `home_view.dart:245` (`competition.competitionStatus == 'EN COURS'`) that compares against a hardcoded literal that no translation produces — so the branch never fires. New design: domain returns `EntryStatus` and `CompetitionStatus` enums; formatting extension provides translated labels and Colors. The `'EN COURS'` bug becomes structurally impossible (we'll do `status == CompetitionStatus.onGoing`).

4. **`competition_formatting.dart` lives under `lib/app/presentation/modules/home/`** since it's currently only consumed by home_view. If/when CompetitionDetail also wants the formatters, Batch 3b can hoist it to `presentation/shared/` or `domain/` (debatable — formatting is presentation-y).

5. **Legacy `ApiService.getCompetitions` etc. stay alive** — `CompetitionDetailRacesController`, `CompetitionDetailClubsController`, `ProgramController`, and `SlotController` still call ApiService; they get migrated in Batches 3b/4/5. The `ApiService` registration in `InitialBinding` from Batch 1 stays for now.

6. **Lots of legacy date/Color computed-getter patterns are preserved** at the view level via the new extension. We're not redesigning the home page — only changing what type its data comes in as.

---

## File map

**Create (production):**
- `lib/app/domain/models/club.dart` — basic Club (5 fields + empty `athletes`/`referees` lists)
- `lib/app/domain/models/competition.dart` — Competition + `EntryStatus` + `CompetitionStatus` enums
- `lib/app/data/dtos/club_dto.dart` — `@JsonKey` mappings for the FFSS club shape
- `lib/app/data/dtos/competition_dto.dart` — full `@JsonKey` mapping for Competition + nested `Organisme: ClubDto`
- `lib/app/data/mappers/club_mapper.dart` — `ClubDto.toDomain()` extension
- `lib/app/data/mappers/competition_mapper.dart` — `CompetitionDto.toDomain()` extension (uses ClubMapper, parses dates, derives status enums)
- `lib/app/data/datasources/competition_remote_datasource.dart` — abstract + Impl
- `lib/app/data/repositories/competition_repository.dart` — REPLACES the legacy 1:1 wrapper
- `lib/app/presentation/modules/home/competition_formatting.dart` — extension on `Competition` for view consumption

**Tests:**
- `test/data/mappers/club_mapper_test.dart`
- `test/data/mappers/competition_mapper_test.dart`
- `test/data/repositories/competition_repository_test.dart`
- `test/presentation/modules/home/controllers/home_controller_test.dart`

**Modify:**
- `lib/app/core/di/initial_binding.dart` — add `CompetitionRemoteDataSource` + `CompetitionRepository` registrations
- `lib/app/module/home/bindings/home_binding.dart` — drop `Get.lazyPut<ApiService>(...)` (already a permanent singleton from `InitialBinding`); constructor-inject `CompetitionRepository` into `HomeController`
- `lib/app/module/home/controllers/home_controller.dart` — constructor-inject `CompetitionRepository`, drop direct `ApiService` use; expose typed `Competition` list
- `lib/app/module/home/views/home_view.dart` — switch import from `data/models/competition_model.dart` → `domain/models/competition.dart` + new formatting extension; replace the buggy `competitionStatus == 'EN COURS'` with `status == CompetitionStatus.onGoing`

**Not deleted in this batch:**
- `lib/app/data/models/competition_model.dart` — still used by `CompetitionDetailController` (which will switch in Batch 3b) and `ProgramController` (Batch 4)
- `lib/app/data/models/club_model.dart` — same. Both deleted in Batch 6.
- The legacy `lib/app/data/repositories/auth_repository.dart` was already replaced in Batch 1; the legacy `competition_repository.dart` (the 1:1 dead wrapper around ApiService) IS replaced here in Task 7.

---

## Key types and contracts

### `Club` (domain — basic)

```dart
@freezed
class Club with _$Club {
  const factory Club({
    required int id,
    required String name,
    String? shortName,
    String? logoUrl,
    String? capUrl,
    @Default([]) List<dynamic> athletes,   // placeholder until Batch 3b
    @Default([]) List<dynamic> referees,   // placeholder until Batch 3b
  }) = _Club;

  factory Club.fromJson(Map<String, dynamic> json) => _$ClubFromJson(json);
}
```

Why `List<dynamic>` for athletes/referees? Batch 3b adds the `Athlete`/`Referee` domain types and changes these to `List<Athlete>`/`List<Referee>`. Using `dynamic` for now keeps the model usable without forcing those types to exist. The Competition flow in 3a never reads them — they stay empty.

Helpers (extension, not on the freezed class):

```dart
extension ClubX on Club {
  bool get hasLogo => logoUrl?.isNotEmpty == true;
  bool get hasCap => capUrl?.isNotEmpty == true;
}
```

This goes in `club_mapper.dart` for now (small) — Batch 3b can move to its own file.

### `Competition` (domain)

```dart
@freezed
class Competition with _$Competition {
  const factory Competition({
    required int id,
    required String name,
    DateTime? beginDate,
    DateTime? endDate,
    DateTime? beginEntryLimitDate,
    DateTime? endEntryLimitDate,
    String? location,
    required int statusCode,
    required String statusLabel,
    String? description,
    required int speciality,
    required String specialityLabel,
    required String typeWater,
    required String typePool,
    required String typeChrono,
    required bool isEligibleToNationalRecord,
    required int numberOfLanes,
    required String organizer,
    required bool hasBegun,
    required bool hasResult,
    required bool hasPassed,
    required int level,
    required String levelLabel,
    required Club organizerClub,
    String? refereePrincipal,
  }) = _Competition;

  factory Competition.fromJson(Map<String, dynamic> json) =>
      _$CompetitionFromJson(json);
}

enum EntryStatus { open, closed, soon, unknown }
enum CompetitionStatus { coming, onGoing, done, unknown }
```

Computed status enums move to the formatting extension (Task 9):

```dart
extension CompetitionStatusX on Competition {
  EntryStatus get entryStatus { ... }
  CompetitionStatus get phase { ... }
}
```

`statusCode` (int) replaces the legacy `status` (int) field name to avoid confusion with the new `phase` enum getter.

### `ClubDto`

```dart
@freezed
class ClubDto with _$ClubDto {
  const factory ClubDto({
    @JsonKey(name: 'Id') required int id,
    @JsonKey(name: 'NomCompletOrga') required String name,
    @JsonKey(name: 'NomCourt') String? shortName,
    @JsonKey(name: 'logo') String? logoUrl,
    @JsonKey(name: 'bonnet') String? capUrl,
  }) = _ClubDto;

  factory ClubDto.fromJson(Map<String, dynamic> json) =>
      _$ClubDtoFromJson(json);
}
```

Athletes/referees are absent from this DTO in 3a — Batch 3b adds them.

### `CompetitionDto`

```dart
@freezed
class CompetitionDto with _$CompetitionDto {
  const factory CompetitionDto({
    @JsonKey(name: 'Id') required int id,
    @JsonKey(name: 'Nom') required String name,
    @JsonKey(name: 'Debut') String? beginDate,
    @JsonKey(name: 'Fin') String? endDate,
    @JsonKey(name: 'DebutEngagement') String? beginEntryLimitDate,
    @JsonKey(name: 'FinEngagement') String? endEntryLimitDate,
    @JsonKey(name: 'Lieu') String? location,
    @JsonKey(name: 'Statut') required int statusCode,
    @JsonKey(name: 'statutLabel') required String statusLabel,
    @JsonKey(name: 'Description') String? description,
    @JsonKey(name: 'Specialite') required int speciality,
    @JsonKey(name: 'specialiteLabel') required String specialityLabel,
    @JsonKey(name: 'water') required String typeWater,
    @JsonKey(name: 'bassin') required String typePool,
    @JsonKey(name: 'chronoLabel') required String typeChrono,
    required bool isEligibleToNationalRecord,
    @JsonKey(name: 'numberOfLanes') int? numberOfLanes,
    @JsonKey(name: 'Organisme') required CompetitionOrganismeDto organisme,
    required bool hasBegun,
    @JsonKey(name: 'hasResultat') required bool hasResult,
    required bool hasPassed,
    @JsonKey(name: 'Niveau') required int level,
    @JsonKey(name: 'niveauLabel') required String levelLabel,
    @JsonKey(name: 'JugePrincipal') String? refereePrincipal,
  }) = _CompetitionDto;

  factory CompetitionDto.fromJson(Map<String, dynamic> json) =>
      _$CompetitionDtoFromJson(json);
}

@freezed
class CompetitionOrganismeDto with _$CompetitionOrganismeDto {
  const factory CompetitionOrganismeDto({
    @JsonKey(name: 'Id') required int id,
    @JsonKey(name: 'NomOrga') required String organizerName,
    @JsonKey(name: 'NomCompletOrga') String? clubFullName,
    @JsonKey(name: 'NomCourt') String? shortName,
    @JsonKey(name: 'logo') String? logoUrl,
    @JsonKey(name: 'bonnet') String? capUrl,
  }) = _CompetitionOrganismeDto;

  factory CompetitionOrganismeDto.fromJson(Map<String, dynamic> json) =>
      _$CompetitionOrganismeDtoFromJson(json);
}
```

Why a separate `CompetitionOrganismeDto`? The legacy code reads `json['Organisme']['NomOrga']` for `organizer` (a string column) AND treats the same `Organisme` map as a Club via `ClubModel.fromJson(json["Organisme"])`. The `Organisme` JSON shape has BOTH `NomOrga` (organizer's name as a flat string) and `NomCompletOrga` (full club name). One DTO captures both views.

### `CompetitionRemoteDataSource`

```dart
abstract class CompetitionRemoteDataSource {
  Future<List<CompetitionDto>> getCompetitions({
    required String season,
    required String startDate,
    required CompetitionType type,
    required CompetitionVisibility visibility,
    required int page,
    required int pageSize,
  });
}
```

Drops `getAllCompetitions` (auto-paginate) and `getNext5` from the legacy ApiService — those were convenience wrappers that belong on the Repository, not the DataSource. Each call hits one endpoint with explicit pagination.

### `CompetitionRepository`

```dart
abstract class CompetitionRepository {
  Future<List<Competition>> getCompetitions({
    CompetitionType type = CompetitionType.mixte,
    CompetitionVisibility visibility = CompetitionVisibility.incoming,
    int pageSize = 10,
    int page = 1,
  });

  Future<List<Competition>> getAllCompetitions({
    CompetitionType type = CompetitionType.mixte,
    CompetitionVisibility visibility = CompetitionVisibility.incoming,
  });

  Future<List<Competition>> getNext5();
}
```

`getAllCompetitions` is the auto-paginated convenience method (HomeController calls it). `getNext5` calls `getCompetitions(pageSize: 5, page: 1)` and returns up to 5. The repository owns this orchestration.

Default season + startDate values match the legacy hardcoded `'2023-2024'` / `'2024-09-29'` for now — same data the app currently shows. Externalizing those is a separate concern (Batch 6 or app-config later).

### Refactored `HomeController`

```dart
class HomeController extends GetxController {
  HomeController(this._competitionRepo, this._userService, this._languageService);

  final CompetitionRepository _competitionRepo;
  final UserService _userService;
  final LanguageService _languageService;

  final RxList<Competition> competitions = <Competition>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxInt displayedItems = 3.obs;
  final Rx<HomeFilter> selectedFilter = HomeFilter.all.obs;

  // ... rest unchanged in shape, just the type swap

  Future<void> loadCompetitions() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      final loaded = await _competitionRepo.getAllCompetitions(
        type: CompetitionType.mixte,
        visibility: CompetitionVisibility.passed,
      );
      loaded.sort((a, b) {
        final dateComparison = (a.beginDate ?? DateTime(0))
            .compareTo(b.beginDate ?? DateTime(0));
        if (dateComparison != 0) return dateComparison;
        return a.name.compareTo(b.name);
      });
      competitions.value = loaded;
    } on AppException {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }
  // ...
}
```

Two side-cleanups:
- `selectedFilter` becomes typed `Rx<HomeFilter>` (enum: `all`, `coastal`, `pool`, `mixed`) instead of `RxString`. Replaces the buggy `selectedFilter.value = 'TOUS'` on logout (legacy line 111).
- The `Rx<bool> get isLoggedIn { if (...) return true.obs; ... }` getter that creates a fresh Rx every call gets replaced with a simple `bool get isLoggedIn => _userService.isLoggedIn;` (matches `UserService` post-Batch-1 API).

---

## Task 1: Club domain model (basic)

**Files:**
- Create: `lib/app/domain/models/club.dart`

- [ ] **Step 1: Create the file**

Create `lib/app/domain/models/club.dart` with EXACTLY this content:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'club.freezed.dart';
part 'club.g.dart';

@freezed
class Club with _$Club {
  const factory Club({
    required int id,
    required String name,
    String? shortName,
    String? logoUrl,
    String? capUrl,
    @Default(<dynamic>[]) List<dynamic> athletes,
    @Default(<dynamic>[]) List<dynamic> referees,
  }) = _Club;

  factory Club.fromJson(Map<String, dynamic> json) => _$ClubFromJson(json);
}
```

The `athletes`/`referees` placeholders exist so that Batch 3b can change them to typed lists without breaking Club's JSON serialization in the meantime.

- [ ] **Step 2: Generate freezed code**

Run: `dart run build_runner build --delete-conflicting-outputs`

(`dart` may not be on bash PATH — fall back to `C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\dart.bat` if needed.)

Expected: creates `club.freezed.dart` and `club.g.dart`.

- [ ] **Step 3: Verify**

Run: `flutter analyze lib/app/domain/models/club.dart`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/app/domain/models/club.dart \
        lib/app/domain/models/club.freezed.dart \
        lib/app/domain/models/club.g.dart
git commit -m "feat(domain): add minimal Club domain model

Five core fields (id/name/shortName/logoUrl/capUrl) + placeholder
athletes/referees lists. Batch 3b expands those to List<Athlete>/
List<Referee> when the domain types are introduced."
```

---

## Task 2: ClubDto (basic)

**Files:**
- Create: `lib/app/data/dtos/club_dto.dart`

- [ ] **Step 1: Create the file**

Create `lib/app/data/dtos/club_dto.dart` with EXACTLY this content:

```dart
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'club_dto.freezed.dart';
part 'club_dto.g.dart';

@freezed
class ClubDto with _$ClubDto {
  const factory ClubDto({
    @JsonKey(name: 'Id') required int id,
    @JsonKey(name: 'NomCompletOrga') required String name,
    @JsonKey(name: 'NomCourt') String? shortName,
    @JsonKey(name: 'logo') String? logoUrl,
    @JsonKey(name: 'bonnet') String? capUrl,
  }) = _ClubDto;

  factory ClubDto.fromJson(Map<String, dynamic> json) =>
      _$ClubDtoFromJson(json);
}
```

The `// ignore_for_file: invalid_annotation_target` line is a known idiom for `@JsonKey` annotations on freezed factory parameters (same as the AuthDto pattern from Batch 1).

- [ ] **Step 2: Generate code**

Run: `dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 3: Verify**

Run: `flutter analyze lib/app/data/dtos/`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/app/data/dtos/club_dto.dart \
        lib/app/data/dtos/club_dto.freezed.dart \
        lib/app/data/dtos/club_dto.g.dart
git commit -m "feat(data): add ClubDto

Maps the FFSS club JSON envelope (Id, NomCompletOrga, NomCourt,
logo, bonnet). Athletes/referees not modeled in 3a — Batch 3b
expands the DTO when the dedicated club endpoints are wired up."
```

---

## Task 3: ClubMapper (with TDD)

**Files:**
- Create: `lib/app/data/mappers/club_mapper.dart`
- Create: `test/data/mappers/club_mapper_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/data/mappers/club_mapper_test.dart` with EXACTLY this content:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/dtos/club_dto.dart';
import 'package:live_ffss/app/data/mappers/club_mapper.dart';
import 'package:live_ffss/app/domain/models/club.dart';

void main() {
  group('ClubMapper', () {
    test('maps a full ClubDto to Club', () {
      const dto = ClubDto(
        id: 42,
        name: 'CN Marseille',
        shortName: 'CNM',
        logoUrl: 'https://example.test/logo.png',
        capUrl: 'https://example.test/cap.png',
      );

      final club = dto.toDomain();

      expect(club.id, 42);
      expect(club.name, 'CN Marseille');
      expect(club.shortName, 'CNM');
      expect(club.logoUrl, 'https://example.test/logo.png');
      expect(club.capUrl, 'https://example.test/cap.png');
      expect(club.athletes, isEmpty);
      expect(club.referees, isEmpty);
    });

    test('maps a sparse ClubDto (only required fields)', () {
      const dto = ClubDto(id: 1, name: 'Bare Club');

      final club = dto.toDomain();

      expect(club.id, 1);
      expect(club.name, 'Bare Club');
      expect(club.shortName, isNull);
      expect(club.logoUrl, isNull);
      expect(club.capUrl, isNull);
    });
  });

  group('ClubX', () {
    test('hasLogo is true for non-empty logoUrl', () {
      const club = Club(id: 1, name: 'X', logoUrl: 'https://x');
      expect(club.hasLogo, isTrue);
    });

    test('hasLogo is false for null or empty logoUrl', () {
      expect(const Club(id: 1, name: 'X').hasLogo, isFalse);
      expect(const Club(id: 1, name: 'X', logoUrl: '').hasLogo, isFalse);
    });

    test('hasCap mirrors hasLogo for capUrl', () {
      expect(const Club(id: 1, name: 'X', capUrl: 'https://c').hasCap, isTrue);
      expect(const Club(id: 1, name: 'X').hasCap, isFalse);
    });
  });
}
```

- [ ] **Step 2: Run, verify it fails**

Run: `flutter test test/data/mappers/club_mapper_test.dart`
Expected: import error for `club_mapper.dart`.

- [ ] **Step 3: Create the mapper**

Create `lib/app/data/mappers/club_mapper.dart` with EXACTLY this content:

```dart
import 'package:live_ffss/app/data/dtos/club_dto.dart';
import 'package:live_ffss/app/domain/models/club.dart';

extension ClubMapper on ClubDto {
  Club toDomain() => Club(
        id: id,
        name: name,
        shortName: shortName,
        logoUrl: logoUrl,
        capUrl: capUrl,
      );
}

extension ClubX on Club {
  bool get hasLogo => logoUrl?.isNotEmpty == true;
  bool get hasCap => capUrl?.isNotEmpty == true;
}
```

- [ ] **Step 4: Run, verify pass**

Run: `flutter test test/data/mappers/club_mapper_test.dart`
Expected: `All tests passed!` (5 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/app/data/mappers/club_mapper.dart \
        test/data/mappers/club_mapper_test.dart
git commit -m "feat(data): add ClubMapper

ClubDto -> Club. Adds ClubX extension with hasLogo/hasCap helpers
to match the legacy ClubModel API."
```

---

## Task 4: Competition domain model

**Files:**
- Create: `lib/app/domain/models/competition.dart`

- [ ] **Step 1: Create the file**

Create `lib/app/domain/models/competition.dart` with EXACTLY this content:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/club.dart';

part 'competition.freezed.dart';
part 'competition.g.dart';

enum EntryStatus { open, closed, soon, unknown }

enum CompetitionStatus { coming, onGoing, done, unknown }

@freezed
class Competition with _$Competition {
  const factory Competition({
    required int id,
    required String name,
    DateTime? beginDate,
    DateTime? endDate,
    DateTime? beginEntryLimitDate,
    DateTime? endEntryLimitDate,
    String? location,
    required int statusCode,
    required String statusLabel,
    String? description,
    required int speciality,
    required String specialityLabel,
    required String typeWater,
    required String typePool,
    required String typeChrono,
    required bool isEligibleToNationalRecord,
    required int numberOfLanes,
    required String organizer,
    required bool hasBegun,
    required bool hasResult,
    required bool hasPassed,
    required int level,
    required String levelLabel,
    required Club organizerClub,
    String? refereePrincipal,
  }) = _Competition;

  factory Competition.fromJson(Map<String, dynamic> json) =>
      _$CompetitionFromJson(json);
}
```

`statusCode` (int) replaces the legacy field name `status` so it doesn't clash with the new `phase: CompetitionStatus` getter that comes via the formatting extension (Task 9).

- [ ] **Step 2: Generate code**

Run: `dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 3: Verify**

Run: `flutter analyze lib/app/domain/models/competition.dart`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/app/domain/models/competition.dart \
        lib/app/domain/models/competition.freezed.dart \
        lib/app/domain/models/competition.g.dart
git commit -m "feat(domain): add Competition domain model

24 raw fields + organizerClub + EntryStatus/CompetitionStatus enums.
Status-derivation getters and formatting helpers move to the
presentation extension (later task)."
```

---

## Task 5: CompetitionDto

**Files:**
- Create: `lib/app/data/dtos/competition_dto.dart`

- [ ] **Step 1: Create the file**

Create `lib/app/data/dtos/competition_dto.dart` with EXACTLY this content:

```dart
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'competition_dto.freezed.dart';
part 'competition_dto.g.dart';

@freezed
class CompetitionDto with _$CompetitionDto {
  const factory CompetitionDto({
    @JsonKey(name: 'Id') required int id,
    @JsonKey(name: 'Nom') required String name,
    @JsonKey(name: 'Debut') String? beginDate,
    @JsonKey(name: 'Fin') String? endDate,
    @JsonKey(name: 'DebutEngagement') String? beginEntryLimitDate,
    @JsonKey(name: 'FinEngagement') String? endEntryLimitDate,
    @JsonKey(name: 'Lieu') String? location,
    @JsonKey(name: 'Statut') required int statusCode,
    @JsonKey(name: 'statutLabel') required String statusLabel,
    @JsonKey(name: 'Description') String? description,
    @JsonKey(name: 'Specialite') required int speciality,
    @JsonKey(name: 'specialiteLabel') required String specialityLabel,
    @JsonKey(name: 'water') required String typeWater,
    @JsonKey(name: 'bassin') required String typePool,
    @JsonKey(name: 'chronoLabel') required String typeChrono,
    required bool isEligibleToNationalRecord,
    @JsonKey(name: 'numberOfLanes') int? numberOfLanes,
    @JsonKey(name: 'Organisme') required CompetitionOrganismeDto organisme,
    required bool hasBegun,
    @JsonKey(name: 'hasResultat') required bool hasResult,
    required bool hasPassed,
    @JsonKey(name: 'Niveau') required int level,
    @JsonKey(name: 'niveauLabel') required String levelLabel,
    @JsonKey(name: 'JugePrincipal') String? refereePrincipal,
  }) = _CompetitionDto;

  factory CompetitionDto.fromJson(Map<String, dynamic> json) =>
      _$CompetitionDtoFromJson(json);
}

@freezed
class CompetitionOrganismeDto with _$CompetitionOrganismeDto {
  const factory CompetitionOrganismeDto({
    @JsonKey(name: 'Id') required int id,
    @JsonKey(name: 'NomOrga') required String organizerName,
    @JsonKey(name: 'NomCompletOrga') String? clubFullName,
    @JsonKey(name: 'NomCourt') String? shortName,
    @JsonKey(name: 'logo') String? logoUrl,
    @JsonKey(name: 'bonnet') String? capUrl,
  }) = _CompetitionOrganismeDto;

  factory CompetitionOrganismeDto.fromJson(Map<String, dynamic> json) =>
      _$CompetitionOrganismeDtoFromJson(json);
}
```

`CompetitionOrganismeDto` is a dedicated DTO because the FFSS API's `Organisme` field carries BOTH a flat `NomOrga` (organizer label) and a `NomCompletOrga` (full club name) — distinguishing them avoids ambiguity in the mapper.

- [ ] **Step 2: Generate code**

Run: `dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 3: Verify**

Run: `flutter analyze lib/app/data/dtos/competition_dto.dart`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/app/data/dtos/competition_dto.dart \
        lib/app/data/dtos/competition_dto.freezed.dart \
        lib/app/data/dtos/competition_dto.g.dart
git commit -m "feat(data): add CompetitionDto + CompetitionOrganismeDto

Maps the 24 fields of the FFSS competition envelope. Organisme is a
separate DTO carrying the flat organizer label (NomOrga) plus the
club-shape fields (NomCompletOrga/logo/bonnet/etc.)."
```

---

## Task 6: CompetitionMapper (with TDD)

**Files:**
- Create: `lib/app/data/mappers/competition_mapper.dart`
- Create: `test/data/mappers/competition_mapper_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/data/mappers/competition_mapper_test.dart` with EXACTLY this content:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/dtos/competition_dto.dart';
import 'package:live_ffss/app/data/mappers/competition_mapper.dart';
import 'package:live_ffss/app/domain/models/competition.dart';

void main() {
  group('CompetitionMapper', () {
    test('maps a fully-populated CompetitionDto to Competition', () {
      const dto = CompetitionDto(
        id: 42,
        name: 'Coupe de France',
        beginDate: '2026-05-01T00:00:00.000Z',
        endDate: '2026-05-03T00:00:00.000Z',
        beginEntryLimitDate: '2026-04-01T00:00:00.000Z',
        endEntryLimitDate: '2026-04-25T00:00:00.000Z',
        location: 'Marseille',
        statusCode: 1,
        statusLabel: 'Open',
        description: 'Annual cup',
        speciality: 2,
        specialityLabel: 'Pool',
        typeWater: 'eau-plate',
        typePool: '50m',
        typeChrono: 'Electronic',
        isEligibleToNationalRecord: true,
        numberOfLanes: 8,
        organisme: CompetitionOrganismeDto(
          id: 7,
          organizerName: 'FFSS',
          clubFullName: 'CN Marseille',
          shortName: 'CNM',
          logoUrl: 'https://example.test/logo.png',
          capUrl: 'https://example.test/cap.png',
        ),
        hasBegun: false,
        hasResult: false,
        hasPassed: false,
        level: 3,
        levelLabel: 'National',
        refereePrincipal: 'Jean Dupont',
      );

      final c = dto.toDomain();

      expect(c.id, 42);
      expect(c.name, 'Coupe de France');
      expect(c.beginDate, DateTime.utc(2026, 5, 1));
      expect(c.endDate, DateTime.utc(2026, 5, 3));
      expect(c.beginEntryLimitDate, DateTime.utc(2026, 4, 1));
      expect(c.endEntryLimitDate, DateTime.utc(2026, 4, 25));
      expect(c.location, 'Marseille');
      expect(c.statusCode, 1);
      expect(c.statusLabel, 'Open');
      expect(c.organizer, 'FFSS');
      expect(c.organizerClub.id, 7);
      expect(c.organizerClub.name, 'CN Marseille');
      expect(c.organizerClub.shortName, 'CNM');
      expect(c.organizerClub.logoUrl, 'https://example.test/logo.png');
      expect(c.numberOfLanes, 8);
      expect(c.refereePrincipal, 'Jean Dupont');
    });

    test('handles null optional dates and missing numberOfLanes', () {
      const dto = CompetitionDto(
        id: 1,
        name: 'Sparse',
        beginDate: null,
        endDate: null,
        statusCode: 0,
        statusLabel: 'Pending',
        speciality: 0,
        specialityLabel: 'None',
        typeWater: '',
        typePool: '',
        typeChrono: '',
        isEligibleToNationalRecord: false,
        organisme: CompetitionOrganismeDto(id: 1, organizerName: 'X'),
        hasBegun: false,
        hasResult: false,
        hasPassed: false,
        level: 0,
        levelLabel: '',
      );

      final c = dto.toDomain();

      expect(c.beginDate, isNull);
      expect(c.endDate, isNull);
      expect(c.numberOfLanes, 0);
      expect(c.organizerClub.name, ''); // clubFullName is null -> empty string
      expect(c.refereePrincipal, isNull);
    });

    test('organizerClub.name uses clubFullName when present, otherwise empty',
        () {
      const dto = CompetitionDto(
        id: 1,
        name: 'X',
        statusCode: 0,
        statusLabel: '',
        speciality: 0,
        specialityLabel: '',
        typeWater: '',
        typePool: '',
        typeChrono: '',
        isEligibleToNationalRecord: false,
        organisme: CompetitionOrganismeDto(
          id: 1,
          organizerName: 'Org Label',
          clubFullName: 'Real Club Name',
        ),
        hasBegun: false,
        hasResult: false,
        hasPassed: false,
        level: 0,
        levelLabel: '',
      );

      final c = dto.toDomain();
      expect(c.organizerClub.name, 'Real Club Name');
    });
  });
}
```

- [ ] **Step 2: Run, verify it fails**

Run: `flutter test test/data/mappers/competition_mapper_test.dart`
Expected: import error for `competition_mapper.dart`.

- [ ] **Step 3: Create the mapper**

Create `lib/app/data/mappers/competition_mapper.dart` with EXACTLY this content:

```dart
import 'package:live_ffss/app/data/dtos/competition_dto.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/competition.dart';

extension CompetitionMapper on CompetitionDto {
  Competition toDomain() => Competition(
        id: id,
        name: name,
        beginDate: _parseDate(beginDate),
        endDate: _parseDate(endDate),
        beginEntryLimitDate: _parseDate(beginEntryLimitDate),
        endEntryLimitDate: _parseDate(endEntryLimitDate),
        location: location,
        statusCode: statusCode,
        statusLabel: statusLabel,
        description: description,
        speciality: speciality,
        specialityLabel: specialityLabel,
        typeWater: typeWater,
        typePool: typePool,
        typeChrono: typeChrono,
        isEligibleToNationalRecord: isEligibleToNationalRecord,
        numberOfLanes: numberOfLanes ?? 0,
        organizer: organisme.organizerName,
        hasBegun: hasBegun,
        hasResult: hasResult,
        hasPassed: hasPassed,
        level: level,
        levelLabel: levelLabel,
        organizerClub: organisme.toClub(),
        refereePrincipal: refereePrincipal,
      );
}

extension CompetitionOrganismeMapper on CompetitionOrganismeDto {
  Club toClub() => Club(
        id: id,
        name: clubFullName ?? '',
        shortName: shortName,
        logoUrl: logoUrl,
        capUrl: capUrl,
      );
}

DateTime? _parseDate(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  return DateTime.parse(raw);
}
```

`numberOfLanes ?? 0` matches the legacy default. `organizerClub.name` uses `clubFullName` if present, otherwise empty (Batch 3b can revisit if a smarter fallback is needed).

- [ ] **Step 4: Run, verify pass**

Run: `flutter test test/data/mappers/competition_mapper_test.dart`
Expected: `All tests passed!` (3 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/app/data/mappers/competition_mapper.dart \
        test/data/mappers/competition_mapper_test.dart
git commit -m "feat(data): add CompetitionMapper

CompetitionDto -> Competition + CompetitionOrganismeDto -> Club.
Date parsing centralised; numberOfLanes defaults to 0 to match legacy."
```

---

## Task 7: CompetitionRemoteDataSource + CompetitionRepository (with TDD)

**Files:**
- Create: `lib/app/data/datasources/competition_remote_datasource.dart`
- Modify (rewrite): `lib/app/data/repositories/competition_repository.dart` — REPLACES the legacy 1:1 wrapper
- Create: `test/data/repositories/competition_repository_test.dart`

- [ ] **Step 1: Create the data source**

Create `lib/app/data/datasources/competition_remote_datasource.dart` with EXACTLY this content:

```dart
import 'package:live_ffss/app/core/config/app_config.dart';
import 'package:live_ffss/app/core/enum/enum.dart';
import 'package:live_ffss/app/core/network/http_client.dart';
import 'package:live_ffss/app/data/dtos/competition_dto.dart';

abstract class CompetitionRemoteDataSource {
  Future<List<CompetitionDto>> getCompetitions({
    required String season,
    required String startDate,
    required CompetitionType type,
    required CompetitionVisibility visibility,
    required int page,
    required int pageSize,
  });
}

class CompetitionRemoteDataSourceImpl implements CompetitionRemoteDataSource {
  CompetitionRemoteDataSourceImpl(this._http);

  final HttpClient _http;

  @override
  Future<List<CompetitionDto>> getCompetitions({
    required String season,
    required String startDate,
    required CompetitionType type,
    required CompetitionVisibility visibility,
    required int page,
    required int pageSize,
  }) async {
    final body = await _http.get(
      ApiEndpoints.competitionList,
      query: {
        'saison': season,
        'debut': startDate,
        'type': type.index,
        'visibility': visibility.name,
        'length': pageSize,
        'start': pageSize * (page - 1),
        'order': 'DebutEngagement',
        'orderDirection': 'ASC',
      },
    );
    final list = (body['data'] as List?) ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(CompetitionDto.fromJson)
        .toList();
  }
}
```

- [ ] **Step 2: Verify the data source compiles**

Run: `flutter analyze lib/app/data/datasources/competition_remote_datasource.dart`
Expected: `No issues found!`

- [ ] **Step 3: Write the repository test (failing)**

Create `test/data/repositories/competition_repository_test.dart` with EXACTLY this content:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/enum/enum.dart';
import 'package:live_ffss/app/data/datasources/competition_remote_datasource.dart';
import 'package:live_ffss/app/data/dtos/competition_dto.dart';
import 'package:live_ffss/app/data/repositories/competition_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockDataSource extends Mock implements CompetitionRemoteDataSource {}

void main() {
  late _MockDataSource ds;
  late CompetitionRepository repo;

  CompetitionDto makeDto(int id, {String name = 'Comp'}) => CompetitionDto(
        id: id,
        name: name,
        statusCode: 0,
        statusLabel: '',
        speciality: 0,
        specialityLabel: '',
        typeWater: '',
        typePool: '',
        typeChrono: '',
        isEligibleToNationalRecord: false,
        organisme: const CompetitionOrganismeDto(id: 1, organizerName: 'X'),
        hasBegun: false,
        hasResult: false,
        hasPassed: false,
        level: 0,
        levelLabel: '',
      );

  setUp(() {
    ds = _MockDataSource();
    repo = CompetitionRepositoryImpl(ds);
  });

  group('CompetitionRepository.getCompetitions', () {
    test('forwards params and maps DTOs to domain', () async {
      when(() => ds.getCompetitions(
            season: any(named: 'season'),
            startDate: any(named: 'startDate'),
            type: any(named: 'type'),
            visibility: any(named: 'visibility'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => [makeDto(1), makeDto(2)]);

      final list = await repo.getCompetitions(
        type: CompetitionType.mixte,
        visibility: CompetitionVisibility.passed,
        page: 2,
        pageSize: 25,
      );

      expect(list.length, 2);
      expect(list.first.id, 1);
      verify(() => ds.getCompetitions(
            season: any(named: 'season'),
            startDate: any(named: 'startDate'),
            type: CompetitionType.mixte,
            visibility: CompetitionVisibility.passed,
            page: 2,
            pageSize: 25,
          )).called(1);
    });
  });

  group('CompetitionRepository.getAllCompetitions', () {
    test('paginates until a partial page is returned', () async {
      var calls = 0;
      when(() => ds.getCompetitions(
            season: any(named: 'season'),
            startDate: any(named: 'startDate'),
            type: any(named: 'type'),
            visibility: any(named: 'visibility'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((invocation) async {
        calls++;
        // Page 1: full, Page 2: full, Page 3: partial -> stop.
        if (calls == 1) return [makeDto(1), makeDto(2), makeDto(3)];
        if (calls == 2) return [makeDto(4), makeDto(5), makeDto(6)];
        return [makeDto(7)];
      });

      final list = await repo.getAllCompetitions();

      expect(list.length, 7);
      expect(list.map((c) => c.id), [1, 2, 3, 4, 5, 6, 7]);
      expect(calls, 3);
    });

    test('stops immediately on empty first page', () async {
      when(() => ds.getCompetitions(
            season: any(named: 'season'),
            startDate: any(named: 'startDate'),
            type: any(named: 'type'),
            visibility: any(named: 'visibility'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => []);

      final list = await repo.getAllCompetitions();
      expect(list, isEmpty);
    });
  });

  group('CompetitionRepository.getNext5', () {
    test('requests page 1, size 5, takes 5', () async {
      when(() => ds.getCompetitions(
            season: any(named: 'season'),
            startDate: any(named: 'startDate'),
            type: any(named: 'type'),
            visibility: any(named: 'visibility'),
            page: 1,
            pageSize: 5,
          )).thenAnswer(
          (_) async => List.generate(7, (i) => makeDto(i + 1)));

      final list = await repo.getNext5();
      expect(list.length, 5);
      expect(list.map((c) => c.id), [1, 2, 3, 4, 5]);
    });
  });
}
```

- [ ] **Step 4: Run the test, verify it fails**

Run: `flutter test test/data/repositories/competition_repository_test.dart`
Expected: import errors / type mismatches against the legacy CompetitionRepository (which has a different shape).

- [ ] **Step 5: Rewrite the repository**

REPLACE the entire content of `lib/app/data/repositories/competition_repository.dart` (currently a 1:1 wrapper around ApiService) with EXACTLY this content:

```dart
import 'package:live_ffss/app/core/enum/enum.dart';
import 'package:live_ffss/app/data/datasources/competition_remote_datasource.dart';
import 'package:live_ffss/app/data/mappers/competition_mapper.dart';
import 'package:live_ffss/app/domain/models/competition.dart';

abstract class CompetitionRepository {
  Future<List<Competition>> getCompetitions({
    CompetitionType type = CompetitionType.mixte,
    CompetitionVisibility visibility = CompetitionVisibility.incoming,
    int pageSize = 10,
    int page = 1,
  });

  Future<List<Competition>> getAllCompetitions({
    CompetitionType type = CompetitionType.mixte,
    CompetitionVisibility visibility = CompetitionVisibility.incoming,
  });

  Future<List<Competition>> getNext5();
}

class CompetitionRepositoryImpl implements CompetitionRepository {
  CompetitionRepositoryImpl(this._dataSource);

  static const _defaultSeason = '2023-2024';
  static const _defaultStartDate = '2024-09-29';
  static const _defaultPageSize = 10;

  final CompetitionRemoteDataSource _dataSource;

  @override
  Future<List<Competition>> getCompetitions({
    CompetitionType type = CompetitionType.mixte,
    CompetitionVisibility visibility = CompetitionVisibility.incoming,
    int pageSize = _defaultPageSize,
    int page = 1,
  }) async {
    final dtos = await _dataSource.getCompetitions(
      season: _defaultSeason,
      startDate: _defaultStartDate,
      type: type,
      visibility: visibility,
      page: page,
      pageSize: pageSize,
    );
    return dtos.map((d) => d.toDomain()).toList();
  }

  @override
  Future<List<Competition>> getAllCompetitions({
    CompetitionType type = CompetitionType.mixte,
    CompetitionVisibility visibility = CompetitionVisibility.incoming,
  }) async {
    final all = <Competition>[];
    var page = 1;
    while (true) {
      final batch = await getCompetitions(
        type: type,
        visibility: visibility,
        pageSize: _defaultPageSize,
        page: page,
      );
      if (batch.isEmpty) break;
      all.addAll(batch);
      if (batch.length < _defaultPageSize) break;
      page++;
    }
    return all;
  }

  @override
  Future<List<Competition>> getNext5() async {
    final batch = await getCompetitions(
      visibility: CompetitionVisibility.incoming,
      type: CompetitionType.mixte,
      pageSize: 5,
      page: 1,
    );
    return batch.take(5).toList();
  }
}
```

- [ ] **Step 6: Run all the tests**

Run: `flutter test test/data/repositories/competition_repository_test.dart`
Expected: `All tests passed!` (4 tests).

- [ ] **Step 7: Commit**

```bash
git add lib/app/data/datasources/competition_remote_datasource.dart \
        lib/app/data/repositories/competition_repository.dart \
        test/data/repositories/competition_repository_test.dart
git commit -m "feat(data): rewrite CompetitionRepository on the new infrastructure

Composes CompetitionRemoteDataSource (HttpClient-based). Repository
owns the auto-pagination loop and the getNext5 convenience method.
Default season/startDate match the legacy hardcoded values.
Replaces the dead 1:1 wrapper from before Batch 0."
```

---

## Task 8: CompetitionFormatting extension

**Files:**
- Create: `lib/app/presentation/modules/home/competition_formatting.dart`

- [ ] **Step 1: Create the extension file**

Create `lib/app/presentation/modules/home/competition_formatting.dart` with EXACTLY this content:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/domain/models/competition.dart';

extension CompetitionFormatting on Competition {
  String get formattedBeginDate =>
      beginDate == null ? '' : DateFormat('dd/MM/yyyy').format(beginDate!);

  String get formattedEndDate =>
      endDate == null ? '' : DateFormat('dd/MM/yyyy').format(endDate!);

  String get formattedDayBeginDate =>
      beginDate == null ? '' : DateFormat('dd').format(beginDate!);

  String get formattedBeginDateMonth => beginDate == null
      ? ''
      : DateFormat('MMM').format(beginDate!).toUpperCase();

  String get dayDateBeginDate {
    if (beginDate == null) return '';
    final day = DateFormat('EEE').format(beginDate!).toUpperCase();
    final date = DateFormat('dd').format(beginDate!);
    return '$day $date';
  }

  bool get hasRefereePrincipal =>
      refereePrincipal != null && refereePrincipal!.isNotEmpty;

  EntryStatus get entryStatus {
    final start = beginEntryLimitDate;
    final end = endEntryLimitDate;
    if (start == null || end == null) return EntryStatus.unknown;
    final now = DateTime.now();
    if (now.isAfter(start) && now.isBefore(end)) return EntryStatus.open;
    if (now.isAfter(start)) return EntryStatus.closed;
    return EntryStatus.soon;
  }

  CompetitionStatus get phase {
    if (beginDate == null || endDate == null) return CompetitionStatus.unknown;
    final now = DateTime.now();
    if (now.isAfter(beginDate!) && now.isBefore(endDate!)) {
      return CompetitionStatus.onGoing;
    }
    if (now.isAfter(endDate!)) return CompetitionStatus.done;
    return CompetitionStatus.coming;
  }

  String get entryStatusLabel => switch (entryStatus) {
        EntryStatus.open => 'open'.tr,
        EntryStatus.closed => 'closed'.tr,
        EntryStatus.soon => 'soon'.tr,
        EntryStatus.unknown => 'unknown'.tr,
      };

  Color get entryStatusColor => switch (entryStatus) {
        EntryStatus.open => AppColors.statusFinished, // green
        EntryStatus.closed => AppColors.statusError, // red
        EntryStatus.soon => AppColors.statusWaiting, // orange
        EntryStatus.unknown => AppColors.textMuted,
      };

  String get phaseLabel => switch (phase) {
        CompetitionStatus.coming => 'coming'.tr,
        CompetitionStatus.onGoing => 'on_going'.tr,
        CompetitionStatus.done => 'done'.tr,
        CompetitionStatus.unknown => 'unknown'.tr,
      };

  Color get phaseColor => switch (phase) {
        CompetitionStatus.onGoing => AppColors.statusInProgress, // amber
        CompetitionStatus.done => AppColors.textMuted, // grey
        CompetitionStatus.coming => AppColors.primary, // blue
        CompetitionStatus.unknown => AppColors.textMuted,
      };
}
```

- [ ] **Step 2: Verify**

Run: `flutter analyze lib/app/presentation/modules/home/competition_formatting.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/app/presentation/modules/home/competition_formatting.dart
git commit -m "feat(home): add CompetitionFormatting extension

Extension on the new Competition domain providing the formatted-string
and Color getters that the legacy CompetitionModel had inline. Status
strings now go through typed enums + .tr; colors come from AppColors."
```

---

## Task 9: HomeController refactor (with TDD)

**Files:**
- Modify (rewrite): `lib/app/module/home/controllers/home_controller.dart`
- Create: `test/presentation/modules/home/controllers/home_controller_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/presentation/modules/home/controllers/home_controller_test.dart` with EXACTLY this content:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/enum/enum.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/core/services/language_service.dart';
import 'package:live_ffss/app/data/repositories/competition_repository.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/module/home/controllers/home_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements CompetitionRepository {}

class _MockUserService extends Mock implements UserService {}

class _MockLanguageService extends Mock implements LanguageService {}

void main() {
  late _MockRepo repo;
  late _MockUserService users;
  late _MockLanguageService lang;
  late HomeController controller;

  Competition c(int id, {DateTime? begin}) => Competition(
        id: id,
        name: 'C$id',
        beginDate: begin,
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

  setUp(() {
    repo = _MockRepo();
    users = _MockUserService();
    lang = _MockLanguageService();
    when(() => lang.currentLanguage).thenReturn('fr_FR'.obs);
    controller = HomeController(repo, users, lang);
  });

  group('HomeController.loadCompetitions', () {
    test('loads, sorts by beginDate then name, clears error', () async {
      when(() => repo.getAllCompetitions(
            type: any(named: 'type'),
            visibility: any(named: 'visibility'),
          )).thenAnswer((_) async => [
            c(2, begin: DateTime.utc(2026, 5, 2)),
            c(1, begin: DateTime.utc(2026, 5, 1)),
          ]);

      await controller.loadCompetitions();

      expect(controller.competitions.length, 2);
      expect(controller.competitions.first.id, 1);
      expect(controller.isLoading.value, false);
      expect(controller.hasError.value, false);
    });

    test('on AppException sets hasError and clears loading', () async {
      when(() => repo.getAllCompetitions(
            type: any(named: 'type'),
            visibility: any(named: 'visibility'),
          )).thenThrow(const NetworkException('offline'));

      await controller.loadCompetitions();

      expect(controller.competitions, isEmpty);
      expect(controller.hasError.value, true);
      expect(controller.isLoading.value, false);
    });
  });

  group('HomeController paging slice', () {
    test('carouselCompetitions returns at most first 5', () {
      controller.competitions
          .value = List.generate(8, (i) => c(i + 1));
      expect(controller.carouselCompetitions.length, 5);
      expect(controller.carouselCompetitions.first.id, 1);
    });

    test('listCompetitions returns the rest after first 5', () {
      controller.competitions
          .value = List.generate(8, (i) => c(i + 1));
      expect(controller.listCompetitions.length, 3);
      expect(controller.listCompetitions.first.id, 6);
    });

    test('listCompetitions is empty when fewer than 6 total', () {
      controller.competitions.value = List.generate(3, (i) => c(i + 1));
      expect(controller.listCompetitions, isEmpty);
    });

    test('loadMore increases displayedItems up to listCompetitions.length',
        () {
      controller.competitions
          .value = List.generate(20, (i) => c(i + 1)); // 15 in list slice
      expect(controller.displayedItems.value, 3);
      controller.loadMore();
      expect(controller.displayedItems.value, 6);
    });
  });

  group('HomeController.setFilter', () {
    test('updates selectedFilter', () {
      controller.setFilter(HomeFilter.coastal);
      expect(controller.selectedFilter.value, HomeFilter.coastal);
    });
  });
}
```

- [ ] **Step 2: Run, verify it fails**

Run: `flutter test test/presentation/modules/home/controllers/home_controller_test.dart`
Expected: import errors / type mismatches against the legacy HomeController.

- [ ] **Step 3: Rewrite HomeController**

REPLACE the entire content of `lib/app/module/home/controllers/home_controller.dart` with EXACTLY this content:

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/core/enum/enum.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/core/services/language_service.dart';
import 'package:live_ffss/app/data/repositories/competition_repository.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/routes/app_pages.dart';

enum HomeFilter { all, coastal, pool, mixed }

class HomeController extends GetxController {
  HomeController(
    this._competitionRepo,
    this._userService,
    this._languageService,
  );

  final CompetitionRepository _competitionRepo;
  final UserService _userService;
  final LanguageService _languageService;

  final RxList<Competition> competitions = <Competition>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxInt displayedItems = 3.obs;
  final Rx<HomeFilter> selectedFilter = HomeFilter.all.obs;

  @override
  void onInit() {
    super.onInit();
    loadCompetitions();
  }

  Future<void> loadCompetitions() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      final loaded = await _competitionRepo.getAllCompetitions(
        type: CompetitionType.mixte,
        visibility: CompetitionVisibility.passed,
      );
      loaded.sort((a, b) {
        final dateComparison = (a.beginDate ?? DateTime(0))
            .compareTo(b.beginDate ?? DateTime(0));
        if (dateComparison != 0) return dateComparison;
        return a.name.compareTo(b.name);
      });
      competitions.value = loaded;
    } on AppException {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void loadMore() {
    final maxItems = listCompetitions.length;
    if (displayedItems.value < maxItems) {
      displayedItems.value =
          (displayedItems.value + 3).clamp(0, maxItems);
    }
  }

  void setFilter(HomeFilter filter) {
    selectedFilter.value = filter;
  }

  List<Competition> get carouselCompetitions =>
      competitions.take(5).toList();

  List<Competition> get listCompetitions =>
      competitions.length > 5 ? competitions.skip(5).toList() : [];

  List<Competition> get displayedListCompetitions =>
      listCompetitions.take(displayedItems.value).toList();

  bool get hasMoreToLoad => displayedItems.value < listCompetitions.length;

  bool get isLoggedIn => _userService.isLoggedIn;

  void navigateToCompetitionDetails(Competition competition) {
    Get.toNamed(Routes.competitionDetail, arguments: competition);
  }

  RxString get appTitle => 'app_title'.tr.obs;

  RxString get currentLanguage => _languageService.currentLanguage;

  void changeLanguage(String languageCode) {
    _languageService.changeLanguage(languageCode);
  }

  void refreshAfterLogout() {
    displayedItems.value = 3;
    selectedFilter.value = HomeFilter.all;
    loadCompetitions();
    update();
  }
}
```

Behavioral changes vs. legacy:
- Constructor injection (no `Get.find()` in body).
- `selectedFilter` is `Rx<HomeFilter>` instead of `RxString` (typed enum).
- `loadMore` uses `clamp` instead of the buggy `competitions.length - 5` math (legacy line 59 — `final maxItems = competitions.length - 5;` would over-shoot when fewer than 5 carousel items existed).
- `isLoggedIn` is a plain `bool` getter (was `Rx<bool>` that created a fresh Rx every call — same anti-pattern flagged in the spec's bug list #6).
- `setFilter` no longer does the `'TOUS'` hardcoded string nonsense.
- `loadCompetitions` only catches `AppException` — other throwables propagate.

- [ ] **Step 4: Run, verify pass**

Run: `flutter test test/presentation/modules/home/controllers/home_controller_test.dart`
Expected: `All tests passed!` (6 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/app/module/home/controllers/home_controller.dart \
        test/presentation/modules/home/controllers/home_controller_test.dart
git commit -m "refactor(home): HomeController on CompetitionRepository

Constructor-injects CompetitionRepository, UserService, LanguageService.
selectedFilter becomes a typed HomeFilter enum; isLoggedIn drops the
fresh-Rx-per-call anti-pattern; loadMore uses clamp instead of the
buggy competitions.length - 5 math. AppException is the only caught
exception type."
```

---

## Task 10: HomeBinding + InitialBinding wiring

**Files:**
- Modify: `lib/app/module/home/bindings/home_binding.dart`
- Modify: `lib/app/core/di/initial_binding.dart`

- [ ] **Step 1: Update HomeBinding**

REPLACE `lib/app/module/home/bindings/home_binding.dart` with EXACTLY this content:

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/core/services/language_service.dart';
import 'package:live_ffss/app/data/repositories/competition_repository.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController(
          Get.find<CompetitionRepository>(),
          Get.find<UserService>(),
          Get.find<LanguageService>(),
        ));
  }
}
```

The `Get.lazyPut<ApiService>(...)` from the legacy binding is GONE — `ApiService` lives in `InitialBinding` as a permanent singleton (Batch 1). Per-route bindings only register controllers.

- [ ] **Step 2: Update InitialBinding**

In `lib/app/core/di/initial_binding.dart`, ADD imports at the top:

```dart
import 'package:live_ffss/app/data/datasources/competition_remote_datasource.dart';
import 'package:live_ffss/app/data/repositories/competition_repository.dart';
```

ADD these registrations between the AuthRepository registration and the transitional ApiService line. The new section between `// 4. Auth data layer` and `// Transitional: legacy ApiService` should look like:

```dart
    // 4. Auth data layer
    Get.put<AuthRemoteDataSource>(
      AuthRemoteDataSourceImpl(Get.find<HttpClient>()),
      permanent: true,
    );
    Get.put<AuthRepository>(
      AuthRepositoryImpl(
        dataSource: Get.find<AuthRemoteDataSource>(),
        tokenStorage: Get.find<TokenStorage>(),
        secureStorage: Get.find<FlutterSecureStorage>(),
      ),
      permanent: true,
    );

    // 5. Competition data layer
    Get.put<CompetitionRemoteDataSource>(
      CompetitionRemoteDataSourceImpl(Get.find<HttpClient>()),
      permanent: true,
    );
    Get.put<CompetitionRepository>(
      CompetitionRepositoryImpl(Get.find<CompetitionRemoteDataSource>()),
      permanent: true,
    );

    // Transitional: legacy ApiService stays alive until per-domain data
    // sources replace it in Batches 3b/4/5.
    Get.put<ApiService>(ApiService(), permanent: true);
```

(Renumber subsequent comments — what was `// 5. Long-lived state holders` becomes `// 6. Long-lived state holders`.)

- [ ] **Step 3: Run analyzer + tests**

Run: `flutter analyze`
Expected: zero errors. (`home_view.dart` will still error against the new types — fixed in Task 11.)

Wait — actually, `home_view.dart` uses `competition.formattedBeginDate`, `competition.competitionStatus`, `competition.organizerClub.hasLogo`, etc. Those still work via the formatting extension we created in Task 8 + the ClubX extension from Task 3. But two things will break: (a) the import path of CompetitionModel, and (b) the buggy `competition.competitionStatus == 'EN COURS'` comparison.

So `flutter analyze` WILL report errors here until Task 11 lands. **Run only the test suite for now** to confirm logic correctness:

Run: `flutter test`
Expected: 59 (Batch 0-2) + 5 (mappers) + 4 (repo) + 6 (controller) = 74 tests, all passing.

- [ ] **Step 4: Commit**

```bash
git add lib/app/module/home/bindings/home_binding.dart \
        lib/app/core/di/initial_binding.dart
git commit -m "feat(di): register CompetitionRepository; HomeBinding cleanup

InitialBinding gets a new section (5) for the Competition data layer.
HomeBinding only registers HomeController now — the duplicate ApiService
lazyPut is gone (ApiService is a permanent singleton from InitialBinding).

home_view.dart still compiles against the legacy CompetitionModel API
through the new formatting extension; the import switch happens in the
next commit."
```

---

## Task 11: home_view.dart switch to new types

**Files:**
- Modify: `lib/app/module/home/views/home_view.dart`

- [ ] **Step 1: Switch the imports**

In `lib/app/module/home/views/home_view.dart`, REPLACE the line:

```dart
import 'package:live_ffss/app/data/models/competition_model.dart';
```

with:

```dart
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/data/mappers/club_mapper.dart';
import 'package:live_ffss/app/presentation/modules/home/competition_formatting.dart';
```

The `club_mapper.dart` import brings in the `ClubX` extension (`hasLogo`, `hasCap`).

- [ ] **Step 2: Replace the buggy `'EN COURS'` comparison**

Find the line in `home_view.dart` (around line 245):

```dart
if (competition.competitionStatus == 'EN COURS')
```

REPLACE with:

```dart
if (competition.phase == CompetitionStatus.onGoing)
```

The `CompetitionStatus` enum is in scope through the `competition.dart` import.

- [ ] **Step 3: Replace the `competitionStatus`/`competitionStatusColor` getter calls**

In the same vicinity (around lines 253-257):

```dart
color: competition.competitionStatusColor,
// ...
competition.competitionStatus,
```

REPLACE with:

```dart
color: competition.phaseColor,
// ...
competition.phaseLabel,
```

(The legacy method names `competitionStatus`/`competitionStatusColor` are renamed to `phaseLabel`/`phaseColor` on the new extension to disambiguate from the raw `statusCode`/`statusLabel` fields.)

- [ ] **Step 4: Replace `entryStatus`/`entryStatusColor` getter calls**

Around lines 543-547:

```dart
color: competition.entryStatusColor,
// ...
competition.entryStatus,
```

REPLACE with:

```dart
color: competition.entryStatusColor,
// ...
competition.entryStatusLabel,
```

`entryStatusColor` keeps its name. `entryStatus` (the legacy getter that returned a String) is now `entryStatusLabel` on the extension.

- [ ] **Step 5: Verify the whole project compiles**

Run: `flutter analyze`
Expected: zero errors. Pre-existing legacy warnings/infos in slot/program/etc. unchanged.

(`flutter` may not be on bash PATH — fall back to `C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat` if needed.)

- [ ] **Step 6: Run all tests**

Run: `flutter test`
Expected: 74 tests, all passing.

- [ ] **Step 7: Commit**

```bash
git add lib/app/module/home/views/home_view.dart
git commit -m "refactor(home): home_view uses new Competition domain

Switches imports to domain/Competition + the formatting extension.
Replaces the buggy competitionStatus == 'EN COURS' string comparison
with a typed CompetitionStatus.onGoing check. Renames the
competitionStatus getter to phaseLabel and competitionStatusColor
to phaseColor; entryStatus to entryStatusLabel. No layout changes."
```

---

## Task 12: Final verification

- [ ] **Step 1: Run the full test suite**

Run: `flutter test`
Expected: 74 tests, all green.

- [ ] **Step 2: Run analyzer**

Run: `flutter analyze`
Expected: zero errors. Pre-existing legacy warnings/infos count: 13 baseline (from Batch 2 sanity check).

- [ ] **Step 3: Confirm git state**

- `git log --oneline main..HEAD` — should show ~11 commits for Batch 3a.
- `git branch --show-current` — `refactor/batch-3a-competition`.
- `git status` — clean (only `.claude/` untracked).
- `git diff main..HEAD --stat | tail -25` — total LOC change.

- [ ] **Step 4: Confirm legacy ApiService still alive**

Run: `grep -rn "Get.find<ApiService>()" lib/app/module/`
Expected: hits in `competition_detail_clubs_controller.dart`, `competition_detail_races_controller.dart`, `competition_detail_controller.dart`, `program_controller.dart`, `slot_controller.dart`. NOT in `home_controller.dart` (that's the migration we just did).

The legacy `lib/app/data/services/api_service.dart` and `lib/app/data/models/competition_model.dart` files still exist on disk — they're consumed by the controllers above and get retired in subsequent batches.

- [ ] **Step 5 (manual, by user): Smoke-test the home flow**

`flutter run`. Click through:
- Home loads competitions list (or shows empty state).
- The carousel shows up to 5 competitions.
- The "load more" button below loads more.
- Tapping a competition navigates to detail (CompetitionDetail still uses ApiService — should still work).
- Logout still works.
- Login still works.

Visual regression watch:
- Date formatting in carousel/list cards should be unchanged (DD/MM/YYYY).
- The "EN COURS" badge that NEVER showed in the legacy code (because of the broken string comparison) NOW shows when the user is viewing a competition that's currently in progress. **This is a fix, not a regression** — but it's behaviorally visible.

---

## Self-review

**Spec coverage** (against §14 "Batch 3 — Competition + Race + Club domains" — partial; this plan covers Competition + Home only):
- DTOs, mappers, datasources, repositories for Competition → Tasks 2 + 5 + 6 + 7 ✓
- HomeController switches to repos → Task 9 ✓
- UI side-effects move to views → no new ones; `loadCompetitions` doesn't show snackbars ✓
- Split home_view.dart into widgets → **DEFERRED** to a later cleanup batch (or never; spec is aspirational and home_view is currently 567 LOC but functional)
- Tests for mappers + repos + controllers → Tasks 3 + 6 + 7 + 9 ✓
- Race + Club + the two `CompetitionDetail*Controller`s → moves to Batch 3b

**Placeholder scan:** None. Deferrals (athletes/referees in Club, view splits) documented at the top.

**Type consistency:**
- `CompetitionRepository` constructor: `CompetitionRepositoryImpl(this._dataSource)` — used identically in Task 7 (impl + test) and Task 10 (binding). ✓
- `HomeController` constructor: `HomeController(this._competitionRepo, this._userService, this._languageService)` — same in Task 9 (impl + test) and Task 10 (binding). ✓
- `Competition` field name `statusCode` (NOT `status`) — consistent across mapper (Task 6), formatting extension (Task 8), and tests. ✓
- `phase` enum value names: `coming/onGoing/done/unknown` — consistent. ✓
- The formatting extension's renamed methods: `phaseLabel`, `phaseColor`, `entryStatusLabel`, `entryStatusColor` — used consistently in Task 11's view substitutions. ✓
- `Club.fromJson` and `Club.toJson` round-trip through freezed/json_serializable — `athletes`/`referees` are `List<dynamic>` but with `@Default([])` they always serialize as empty lists, matching the legacy ClubModel behavior. ✓

---

## Done criteria for Batch 3a

- ~11 commits on a feature branch (`refactor/batch-3a-competition`).
- New: 2 domain models (Club, Competition) + 2 DTOs (Club, Competition with nested Organisme) + 2 mappers + 1 datasource + 1 formatting extension + tests for each non-trivial unit.
- Modified: HomeController, HomeBinding, InitialBinding, home_view.dart.
- Replaced: `lib/app/data/repositories/competition_repository.dart` (was a 1:1 wrapper around ApiService, now a real repo).
- `flutter analyze`: zero errors.
- `flutter test`: 74 tests, all green (15 new in this batch).
- Home flow visually unchanged.
- Legacy `ApiService` still registered + still in use by the other controllers.
- Legacy `CompetitionModel`/`ClubModel` files still on disk (Batch 6 deletes).
