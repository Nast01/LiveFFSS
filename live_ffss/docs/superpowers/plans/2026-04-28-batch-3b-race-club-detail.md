# Batch 3b — Race + Club Expansion + CompetitionDetail Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Finish the Competition+Race+Club domain trio started in 3a. Add typed `Race`, `Athlete`, `Referee`, `Category` domain models + DTOs + mappers. Expand `Club` to carry typed `List<Athlete>`/`List<Referee>` (replacing the 3a `List<dynamic>` placeholders). Add `ClubRemoteDataSource` + `ClubRepository` and `RaceRemoteDataSource` + `RaceRepository`. Refactor the three `CompetitionDetail*Controller`s to constructor-inject those repos and drop the legacy `ApiService`. Update the corresponding views.

**Architecture:** Per design spec §6-9. Same three-layer pragmatic pattern as Batches 1 and 3a: `Controller → Repository → DataSource`, DTOs at the JSON boundary, mappers translate to domain. View-side formatting (race label by language, distance label) goes in `lib/app/presentation/modules/competitions/race_formatting.dart`.

**Tech Stack:** freezed + json_serializable + build_runner, mocktail, GetX (DI/state). No new dependencies.

---

## Notes & deviations from spec

1. **Continuation of Batch 3 (split).** Original spec §14 batch was Competition + Race + Club; 3a covered Competition + Home; 3b covers everything else.

2. **Club's `List<dynamic>` placeholders become typed** in Task 5. The `@Default(<dynamic>[])` defaults switch to `@Default(<Athlete>[])` and `@Default(<Referee>[])`. This is a **breaking change to the Club domain JSON shape** — but Club isn't persisted yet (only `User` is, via Batch 1's `AuthRepository`), so no migration is needed.

3. **Race `label` becomes language-dependent via extension.** Legacy `RaceModel.fromJson` builds `label` at parse time using `LanguageService.to.isEnglish`. That couples the data layer to a UI concern. New design: domain `Race` carries `name`, `nameEnglish`, typed `Gender` enum, and a `categories` list. A `presentation/modules/competitions/race_formatting.dart` extension provides `label` (and the legacy `gender` translated string) on demand, looking at `LanguageService.to` at call time. Views read `race.label` exactly as before — but the source-of-truth moves out of the data layer.

4. **N+1 fetch in legacy `getClubs` is preserved** — it iterates the club list and re-fetches each club's detail to get the full athletes/referees enumeration. The legacy comment-free reasoning (likely the list endpoint omits some fields the detail endpoint provides) is opaque enough that I'm not optimizing it in this batch. The new `ClubRemoteDataSource.getClubs` keeps the same call pattern. Optimizing to one request belongs in a separate batch when we can verify the API responses.

5. **`competition_detail_home_view.dart` (the "rankings" tab) is NOT touched.** It uses `controller.clubRankingsLimited` which currently returns `List.empty()` — the rankings feature isn't actually wired up. Leaving it alone; future batch / feature work will fix it.

6. **`CompetitionDetailController` is mostly a pass-through** — it just stores the `Competition` from `Get.arguments` and tracks the current tab. Updating it amounts to a type swap (`CompetitionModel` → `Competition`). Same goes for the views' direct `competition.X` field reads.

---

## File map

**Create (production):**
- `lib/app/domain/models/category.dart`
- `lib/app/domain/models/athlete.dart`
- `lib/app/domain/models/referee.dart`
- `lib/app/domain/models/race.dart` — includes `Gender` enum
- `lib/app/data/dtos/category_dto.dart`
- `lib/app/data/dtos/athlete_dto.dart`
- `lib/app/data/dtos/referee_dto.dart`
- `lib/app/data/dtos/race_dto.dart`
- `lib/app/data/mappers/category_mapper.dart`
- `lib/app/data/mappers/athlete_mapper.dart`
- `lib/app/data/mappers/referee_mapper.dart`
- `lib/app/data/mappers/race_mapper.dart`
- `lib/app/data/datasources/club_remote_datasource.dart`
- `lib/app/data/datasources/race_remote_datasource.dart`
- `lib/app/data/repositories/club_repository.dart`
- `lib/app/data/repositories/race_repository.dart`
- `lib/app/presentation/modules/competitions/race_formatting.dart`

**Modify (production):**
- `lib/app/domain/models/club.dart` — types the lists; needs codegen rerun
- `lib/app/data/dtos/club_dto.dart` — adds `athletes`/`officiels` fields
- `lib/app/data/mappers/club_mapper.dart` — fills the typed lists
- `lib/app/module/competitions/controllers/competition_detail_controller.dart` — switch to `Competition`
- `lib/app/module/competitions/controllers/competition_detail_clubs_controller.dart` — constructor-inject `ClubRepository`
- `lib/app/module/competitions/controllers/competition_detail_races_controller.dart` — constructor-inject `RaceRepository`
- `lib/app/module/competitions/bindings/competition_detail_binding.dart` — wire constructor injections
- `lib/app/module/competitions/views/competition_detail_view.dart` — type swap (`CompetitionModel` → `Competition`)
- `lib/app/module/competitions/views/competition_detail_clubs_view.dart` — type swap, ClubX import
- `lib/app/module/competitions/views/competition_detail_races_view.dart` — type swap (RaceModel → Race), import RaceFormatting
- `lib/app/core/di/initial_binding.dart` — register Club + Race data layers

**Tests (create):**
- `test/data/mappers/athlete_mapper_test.dart`
- `test/data/mappers/referee_mapper_test.dart`
- `test/data/mappers/category_mapper_test.dart`
- `test/data/mappers/race_mapper_test.dart`
- `test/data/repositories/club_repository_test.dart`
- `test/data/repositories/race_repository_test.dart`
- `test/presentation/modules/competitions/controllers/competition_detail_clubs_controller_test.dart`
- `test/presentation/modules/competitions/controllers/competition_detail_races_controller_test.dart`

**Not deleted in this batch:**
- `lib/app/data/models/competition_model.dart`, `club_model.dart`, `race_model.dart`, `athlete_model.dart`, `referee_model.dart`, `category_model.dart` — still consumed by `program_controller.dart`, `slot_controller.dart`. Batch 4/5/6 retire them.

---

## Key types

### `Category` (domain)

```dart
@freezed
class Category with _$Category {
  const factory Category({
    required int id,
    required String name,
    int? ageMin,
    int? ageMax,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
}
```

### `Gender` enum

```dart
enum Gender { male, female, mixed, unknown }
```

The FFSS API encodes gender as `'M'` (male/mixte? — see legacy code: `"M"` → `'mixed'`, `"F"` → `'women'`, anything else → `'men'`). That mapping is preserved (treating `M` as "mixte" because that's what the legacy did). This is admittedly weird; we keep the same behavior to avoid behavioral drift.

### `Athlete` (domain)

```dart
@freezed
class Athlete with _$Athlete {
  const factory Athlete({
    required int id,
    required String licenseeNumber,
    required String firstName,
    required String lastName,
    required Gender gender,
    required int year,
    required String nationalityCode,
    required String nationality,
    required bool isValid,
    @Default(false) bool isLicensee,
    @Default(false) bool isGuest,
  }) = _Athlete;

  factory Athlete.fromJson(Map<String, dynamic> json) =>
      _$AthleteFromJson(json);
}
```

Note: no `club` field here. The Club domain holds the list-of-athletes. The legacy `AthleteModel.club` back-reference is dropped (presentation can pass the club separately if needed).

### `Referee` (domain)

```dart
@freezed
class Referee with _$Referee {
  const factory Referee({
    required int id,
    required String licenseeNumber,
    required String firstName,
    required String lastName,
    required Gender gender,
    required int year,
    required String level,
    required String levelMax,
    required String nationalityCode,
    required String nationality,
    required bool isValid,
    @Default(false) bool isLicensee,
    @Default(false) bool isGuest,
    @Default(false) bool isPrincipal,
    @Default(<int>[]) List<int> availabilities,
  }) = _Referee;

  factory Referee.fromJson(Map<String, dynamic> json) =>
      _$RefereeFromJson(json);
}
```

### `Race` (domain)

```dart
@freezed
class Race with _$Race {
  const factory Race({
    required int id,
    required String name,
    required String nameEnglish,
    required int distance,
    required Gender gender,
    required int athletesPerTeam,
    required int specialityId,
    required String specialityLabel,
    required int disciplineId,
    required bool isEligibleToNationalRecord,
    required List<Category> categories,
  }) = _Race;

  factory Race.fromJson(Map<String, dynamic> json) => _$RaceFromJson(json);
}
```

### `Club` (domain — expanded)

```dart
@freezed
class Club with _$Club {
  const factory Club({
    required int id,
    required String name,
    String? shortName,
    String? logoUrl,
    String? capUrl,
    @Default(<Athlete>[]) List<Athlete> athletes,
    @Default(<Referee>[]) List<Referee> referees,
  }) = _Club;

  factory Club.fromJson(Map<String, dynamic> json) => _$ClubFromJson(json);
}
```

### Repositories

```dart
abstract class ClubRepository {
  Future<List<Club>> getClubs(int competitionId);
  Future<Club> getClubDetail(int clubId);
}

abstract class RaceRepository {
  Future<List<Race>> getRaces(int competitionId);
}
```

---

## Task 1: Category domain + DTO + mapper

**Files:**
- Create: `lib/app/domain/models/category.dart`
- Create: `lib/app/data/dtos/category_dto.dart`
- Create: `lib/app/data/mappers/category_mapper.dart`
- Create: `test/data/mappers/category_mapper_test.dart`

- [ ] **Step 1: Create the domain model**

Create `lib/app/domain/models/category.dart` with EXACTLY this content:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';
part 'category.g.dart';

@freezed
class Category with _$Category {
  const factory Category({
    required int id,
    required String name,
    int? ageMin,
    int? ageMax,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
}
```

- [ ] **Step 2: Create the DTO**

Create `lib/app/data/dtos/category_dto.dart` with EXACTLY this content:

```dart
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_dto.freezed.dart';
part 'category_dto.g.dart';

@freezed
class CategoryDto with _$CategoryDto {
  const factory CategoryDto({
    @JsonKey(name: 'Id') required int id,
    @JsonKey(name: 'Nom') required String name,
    @JsonKey(name: 'AgeMin') int? ageMin,
    @JsonKey(name: 'AgeMax') int? ageMax,
  }) = _CategoryDto;

  factory CategoryDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryDtoFromJson(json);
}
```

- [ ] **Step 3: Run codegen**

Run: `dart run build_runner build --delete-conflicting-outputs`

(`dart` may not be on bash PATH — fall back to `C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\dart.bat` if needed.)

- [ ] **Step 4: Write the failing test**

Create `test/data/mappers/category_mapper_test.dart` with EXACTLY this content:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/dtos/category_dto.dart';
import 'package:live_ffss/app/data/mappers/category_mapper.dart';

void main() {
  group('CategoryMapper', () {
    test('maps a full CategoryDto to Category', () {
      const dto = CategoryDto(
        id: 1,
        name: 'Senior',
        ageMin: 18,
        ageMax: 35,
      );

      final c = dto.toDomain();

      expect(c.id, 1);
      expect(c.name, 'Senior');
      expect(c.ageMin, 18);
      expect(c.ageMax, 35);
    });

    test('preserves null ageMin/ageMax', () {
      const dto = CategoryDto(id: 1, name: 'Open');

      final c = dto.toDomain();

      expect(c.ageMin, isNull);
      expect(c.ageMax, isNull);
    });
  });
}
```

- [ ] **Step 5: Run, verify it fails**

Run: `flutter test test/data/mappers/category_mapper_test.dart`
Expected: import error for `category_mapper.dart`.

(`flutter` may not be on bash PATH — fall back to `C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat` if needed.)

- [ ] **Step 6: Create the mapper**

Create `lib/app/data/mappers/category_mapper.dart` with EXACTLY this content:

```dart
import 'package:live_ffss/app/data/dtos/category_dto.dart';
import 'package:live_ffss/app/domain/models/category.dart';

extension CategoryMapper on CategoryDto {
  Category toDomain() => Category(
        id: id,
        name: name,
        ageMin: ageMin,
        ageMax: ageMax,
      );
}
```

- [ ] **Step 7: Run, verify pass**

Run: `flutter test test/data/mappers/category_mapper_test.dart`
Expected: `All tests passed!` (2 tests).

- [ ] **Step 8: Commit**

```bash
git add lib/app/domain/models/category.dart \
        lib/app/domain/models/category.freezed.dart \
        lib/app/domain/models/category.g.dart \
        lib/app/data/dtos/category_dto.dart \
        lib/app/data/dtos/category_dto.freezed.dart \
        lib/app/data/dtos/category_dto.g.dart \
        lib/app/data/mappers/category_mapper.dart \
        test/data/mappers/category_mapper_test.dart
git commit -m "feat(domain): add Category domain + DTO + mapper

Categories are embedded in Race via the FFSS 'categories' array.
Plain id/name/ageMin/ageMax shape; ageMin/ageMax may be null."
```

---

## Task 2: Athlete domain + DTO + mapper

**Files:**
- Create: `lib/app/domain/models/athlete.dart`
- Create: `lib/app/data/dtos/athlete_dto.dart`
- Create: `lib/app/data/mappers/athlete_mapper.dart`
- Create: `test/data/mappers/athlete_mapper_test.dart`

- [ ] **Step 1: Create the domain model**

Create `lib/app/domain/models/athlete.dart` with EXACTLY this content:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'athlete.freezed.dart';
part 'athlete.g.dart';

enum Gender { male, female, mixed, unknown }

@freezed
class Athlete with _$Athlete {
  const factory Athlete({
    required int id,
    required String licenseeNumber,
    required String firstName,
    required String lastName,
    required Gender gender,
    required int year,
    required String nationalityCode,
    required String nationality,
    required bool isValid,
    @Default(false) bool isLicensee,
    @Default(false) bool isGuest,
  }) = _Athlete;

  factory Athlete.fromJson(Map<String, dynamic> json) =>
      _$AthleteFromJson(json);
}
```

`Gender` is defined alongside `Athlete` because Athlete is the first domain to need it. Race and Referee will import `Gender` from here.

- [ ] **Step 2: Create the DTO**

Create `lib/app/data/dtos/athlete_dto.dart` with EXACTLY this content:

```dart
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'athlete_dto.freezed.dart';
part 'athlete_dto.g.dart';

@freezed
class AthleteDto with _$AthleteDto {
  const factory AthleteDto({
    @JsonKey(name: 'Id') @Default(0) int id,
    @JsonKey(name: 'NumeroLicence') required String licenseeNumber,
    @JsonKey(name: 'Prenom') required String firstName,
    @JsonKey(name: 'Nom') required String lastName,
    @JsonKey(name: 'Sexe') required String gender,
    @JsonKey(name: 'Annee', readValue: _readYear) required int year,
    @JsonKey(name: 'nationaliteCode') required String nationalityCode,
    @JsonKey(name: 'nationaliteLabel') required String nationality,
    @JsonKey(name: 'isValid') required bool isValid,
    @JsonKey(name: 'isLicencie') @Default(false) bool isLicensee,
    @JsonKey(name: 'isInvite') @Default(false) bool isGuest,
  }) = _AthleteDto;

  factory AthleteDto.fromJson(Map<String, dynamic> json) =>
      _$AthleteDtoFromJson(json);
}

Object? _readYear(Map<dynamic, dynamic> map, String key) {
  final raw = map[key];
  if (raw is String) return int.tryParse(raw) ?? 0;
  return raw;
}
```

`_readYear` handles the legacy quirk that `Annee` may arrive as either an int or a String (from `legacy: json["Annee"] is String ? int.parse(json["Annee"]) : json["Annee"]`). The `readValue` json_serializable hook lets us normalize at the DTO level.

- [ ] **Step 3: Run codegen**

Run: `dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 4: Write the failing test**

Create `test/data/mappers/athlete_mapper_test.dart` with EXACTLY this content:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/dtos/athlete_dto.dart';
import 'package:live_ffss/app/data/mappers/athlete_mapper.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';

void main() {
  group('AthleteMapper', () {
    test('maps a full AthleteDto to Athlete', () {
      const dto = AthleteDto(
        id: 7,
        licenseeNumber: '12345',
        firstName: 'Alice',
        lastName: 'Doe',
        gender: 'F',
        year: 2000,
        nationalityCode: 'FR',
        nationality: 'France',
        isValid: true,
        isLicensee: true,
        isGuest: false,
      );

      final a = dto.toDomain();

      expect(a.id, 7);
      expect(a.licenseeNumber, '12345');
      expect(a.firstName, 'Alice');
      expect(a.lastName, 'Doe');
      expect(a.gender, Gender.female);
      expect(a.year, 2000);
      expect(a.nationalityCode, 'FR');
      expect(a.nationality, 'France');
      expect(a.isValid, true);
      expect(a.isLicensee, true);
      expect(a.isGuest, false);
    });

    test('"M" maps to Gender.mixed (legacy convention)', () {
      const dto = AthleteDto(
        id: 1,
        licenseeNumber: '0',
        firstName: 'X',
        lastName: 'Y',
        gender: 'M',
        year: 0,
        nationalityCode: '',
        nationality: '',
        isValid: false,
      );

      expect(dto.toDomain().gender, Gender.mixed);
    });

    test('any other gender code maps to Gender.male (legacy default)', () {
      const dto = AthleteDto(
        id: 1,
        licenseeNumber: '0',
        firstName: 'X',
        lastName: 'Y',
        gender: 'H',
        year: 0,
        nationalityCode: '',
        nationality: '',
        isValid: false,
      );

      expect(dto.toDomain().gender, Gender.male);
    });

    test('JSON round-trip parses Annee as String into int', () {
      final dto = AthleteDto.fromJson(const {
        'Id': 42,
        'NumeroLicence': '99',
        'Prenom': 'A',
        'Nom': 'B',
        'Sexe': 'F',
        'Annee': '1995',
        'nationaliteCode': 'FR',
        'nationaliteLabel': 'France',
        'isValid': true,
      });

      expect(dto.year, 1995);
    });
  });
}
```

- [ ] **Step 5: Run, verify it fails**

Run: `flutter test test/data/mappers/athlete_mapper_test.dart`
Expected: import error for `athlete_mapper.dart`.

- [ ] **Step 6: Create the mapper**

Create `lib/app/data/mappers/athlete_mapper.dart` with EXACTLY this content:

```dart
import 'package:live_ffss/app/data/dtos/athlete_dto.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';

extension AthleteMapper on AthleteDto {
  Athlete toDomain() => Athlete(
        id: id,
        licenseeNumber: licenseeNumber,
        firstName: firstName,
        lastName: lastName,
        gender: parseGender(gender),
        year: year,
        nationalityCode: nationalityCode,
        nationality: nationality,
        isValid: isValid,
        isLicensee: isLicensee,
        isGuest: isGuest,
      );
}

Gender parseGender(String raw) => switch (raw) {
      'F' => Gender.female,
      'M' => Gender.mixed, // legacy: "M" was treated as mixte/mixed
      _ => Gender.male,
    };
```

`parseGender` is exported (no leading `_`) so Race and Referee mappers can reuse it.

- [ ] **Step 7: Run, verify pass**

Run: `flutter test test/data/mappers/athlete_mapper_test.dart`
Expected: `All tests passed!` (4 tests).

- [ ] **Step 8: Commit**

```bash
git add lib/app/domain/models/athlete.dart \
        lib/app/domain/models/athlete.freezed.dart \
        lib/app/domain/models/athlete.g.dart \
        lib/app/data/dtos/athlete_dto.dart \
        lib/app/data/dtos/athlete_dto.freezed.dart \
        lib/app/data/dtos/athlete_dto.g.dart \
        lib/app/data/mappers/athlete_mapper.dart \
        test/data/mappers/athlete_mapper_test.dart
git commit -m "feat(domain): add Athlete domain + DTO + mapper

Includes Gender enum (used by Athlete/Referee/Race). 'Annee' field
handles both int and String JSON shapes via json_serializable's
readValue hook. parseGender preserves legacy mapping (F->female,
M->mixed, other->male)."
```

---

## Task 3: Referee domain + DTO + mapper

**Files:**
- Create: `lib/app/domain/models/referee.dart`
- Create: `lib/app/data/dtos/referee_dto.dart`
- Create: `lib/app/data/mappers/referee_mapper.dart`
- Create: `test/data/mappers/referee_mapper_test.dart`

- [ ] **Step 1: Create the domain model**

Create `lib/app/domain/models/referee.dart` with EXACTLY this content:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';

part 'referee.freezed.dart';
part 'referee.g.dart';

@freezed
class Referee with _$Referee {
  const factory Referee({
    required int id,
    required String licenseeNumber,
    required String firstName,
    required String lastName,
    required Gender gender,
    required int year,
    required String level,
    required String levelMax,
    required String nationalityCode,
    required String nationality,
    required bool isValid,
    @Default(false) bool isLicensee,
    @Default(false) bool isGuest,
    @Default(false) bool isPrincipal,
    @Default(<int>[]) List<int> availabilities,
  }) = _Referee;

  factory Referee.fromJson(Map<String, dynamic> json) =>
      _$RefereeFromJson(json);
}
```

`Gender` is imported from `athlete.dart`.

- [ ] **Step 2: Create the DTO**

Create `lib/app/data/dtos/referee_dto.dart` with EXACTLY this content:

```dart
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'referee_dto.freezed.dart';
part 'referee_dto.g.dart';

@freezed
class RefereeDto with _$RefereeDto {
  const factory RefereeDto({
    @JsonKey(name: 'Id') @Default(0) int id,
    @JsonKey(name: 'NumeroLicence') required String licenseeNumber,
    @JsonKey(name: 'Prenom') required String firstName,
    @JsonKey(name: 'Nom') required String lastName,
    @JsonKey(name: 'Sexe') required String gender,
    @JsonKey(name: 'Annee', readValue: _readYear) required int year,
    @JsonKey(name: 'Niveau') @Default('') String level,
    @JsonKey(name: 'NiveauMax') @Default('') String levelMax,
    @JsonKey(name: 'nationaliteCode') required String nationalityCode,
    @JsonKey(name: 'nationaliteLabel') required String nationality,
    @JsonKey(name: 'isValid') required bool isValid,
    @JsonKey(name: 'isLicencie') @Default(false) bool isLicensee,
    @JsonKey(name: 'isInvite') @Default(false) bool isGuest,
    @JsonKey(name: 'Principal') @Default(false) bool isPrincipal,
    @JsonKey(name: 'Jours', readValue: _readAvailabilities)
    @Default(<int>[]) List<int> availabilities,
  }) = _RefereeDto;

  factory RefereeDto.fromJson(Map<String, dynamic> json) =>
      _$RefereeDtoFromJson(json);
}

Object? _readYear(Map<dynamic, dynamic> map, String key) {
  final raw = map[key];
  if (raw is String) return int.tryParse(raw) ?? 0;
  return raw;
}

Object? _readAvailabilities(Map<dynamic, dynamic> map, String key) {
  final raw = map[key];
  if (raw is! List) return const <int>[];
  return raw
      .map((v) => v is int ? v : int.tryParse(v.toString()) ?? 0)
      .toList();
}
```

- [ ] **Step 3: Run codegen**

Run: `dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 4: Write the failing test**

Create `test/data/mappers/referee_mapper_test.dart` with EXACTLY this content:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/dtos/referee_dto.dart';
import 'package:live_ffss/app/data/mappers/referee_mapper.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';

void main() {
  group('RefereeMapper', () {
    test('maps a full RefereeDto to Referee', () {
      const dto = RefereeDto(
        id: 11,
        licenseeNumber: '999',
        firstName: 'Bob',
        lastName: 'Lee',
        gender: 'M',
        year: 1980,
        level: 'A',
        levelMax: 'A+',
        nationalityCode: 'FR',
        nationality: 'France',
        isValid: true,
        isPrincipal: true,
        availabilities: [1, 2, 3],
      );

      final r = dto.toDomain();

      expect(r.id, 11);
      expect(r.firstName, 'Bob');
      expect(r.gender, Gender.mixed);
      expect(r.year, 1980);
      expect(r.level, 'A');
      expect(r.levelMax, 'A+');
      expect(r.isPrincipal, true);
      expect(r.availabilities, [1, 2, 3]);
    });

    test('availabilities parses string entries to ints', () {
      final dto = RefereeDto.fromJson(const {
        'Id': 1,
        'NumeroLicence': '0',
        'Prenom': 'X',
        'Nom': 'Y',
        'Sexe': 'F',
        'Annee': 1990,
        'nationaliteCode': '',
        'nationaliteLabel': '',
        'isValid': true,
        'Jours': ['1', '2', '7'],
      });

      expect(dto.toDomain().availabilities, [1, 2, 7]);
    });

    test('missing optional fields use defaults', () {
      final dto = RefereeDto.fromJson(const {
        'NumeroLicence': '0',
        'Prenom': 'X',
        'Nom': 'Y',
        'Sexe': 'F',
        'Annee': 0,
        'nationaliteCode': '',
        'nationaliteLabel': '',
        'isValid': false,
      });

      final r = dto.toDomain();
      expect(r.id, 0);
      expect(r.level, '');
      expect(r.levelMax, '');
      expect(r.isPrincipal, false);
      expect(r.availabilities, isEmpty);
    });
  });
}
```

- [ ] **Step 5: Run, verify it fails**

Run: `flutter test test/data/mappers/referee_mapper_test.dart`
Expected: import error for `referee_mapper.dart`.

- [ ] **Step 6: Create the mapper**

Create `lib/app/data/mappers/referee_mapper.dart` with EXACTLY this content:

```dart
import 'package:live_ffss/app/data/dtos/referee_dto.dart';
import 'package:live_ffss/app/data/mappers/athlete_mapper.dart';
import 'package:live_ffss/app/domain/models/referee.dart';

extension RefereeMapper on RefereeDto {
  Referee toDomain() => Referee(
        id: id,
        licenseeNumber: licenseeNumber,
        firstName: firstName,
        lastName: lastName,
        gender: parseGender(gender),
        year: year,
        level: level,
        levelMax: levelMax,
        nationalityCode: nationalityCode,
        nationality: nationality,
        isValid: isValid,
        isLicensee: isLicensee,
        isGuest: isGuest,
        isPrincipal: isPrincipal,
        availabilities: availabilities,
      );
}
```

Reuses `parseGender` from `athlete_mapper.dart`.

- [ ] **Step 7: Run, verify pass**

Run: `flutter test test/data/mappers/referee_mapper_test.dart`
Expected: `All tests passed!` (3 tests).

- [ ] **Step 8: Commit**

```bash
git add lib/app/domain/models/referee.dart \
        lib/app/domain/models/referee.freezed.dart \
        lib/app/domain/models/referee.g.dart \
        lib/app/data/dtos/referee_dto.dart \
        lib/app/data/dtos/referee_dto.freezed.dart \
        lib/app/data/dtos/referee_dto.g.dart \
        lib/app/data/mappers/referee_mapper.dart \
        test/data/mappers/referee_mapper_test.dart
git commit -m "feat(domain): add Referee domain + DTO + mapper

Reuses Gender enum + parseGender helper from athlete_mapper.
Availabilities (Jours) coerces String->int defensively."
```

---

## Task 4: Race domain + DTO + mapper + RaceFormatting extension

**Files:**
- Create: `lib/app/domain/models/race.dart`
- Create: `lib/app/data/dtos/race_dto.dart`
- Create: `lib/app/data/mappers/race_mapper.dart`
- Create: `lib/app/presentation/modules/competitions/race_formatting.dart`
- Create: `test/data/mappers/race_mapper_test.dart`

- [ ] **Step 1: Create the domain model**

Create `lib/app/domain/models/race.dart` with EXACTLY this content:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/category.dart';

part 'race.freezed.dart';
part 'race.g.dart';

@freezed
class Race with _$Race {
  const factory Race({
    required int id,
    required String name,
    required String nameEnglish,
    required int distance,
    required Gender gender,
    required int athletesPerTeam,
    required int specialityId,
    required String specialityLabel,
    required int disciplineId,
    required bool isEligibleToNationalRecord,
    required List<Category> categories,
  }) = _Race;

  factory Race.fromJson(Map<String, dynamic> json) => _$RaceFromJson(json);
}
```

- [ ] **Step 2: Create the DTO**

The FFSS `competition/epreuve` JSON has a deeply nested shape: top-level `Id`, `IdDiscipline`, `Genre`, `isEligibleToNationalRecord`, `categories: [...]`, plus a nested `discipline: {Nom, NomEn, Distance, NbAthleteParEquipe, Specialite, specialiteLabel}`. Two DTO classes capture this:

Create `lib/app/data/dtos/race_dto.dart` with EXACTLY this content:

```dart
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/data/dtos/category_dto.dart';

part 'race_dto.freezed.dart';
part 'race_dto.g.dart';

@freezed
class RaceDto with _$RaceDto {
  const factory RaceDto({
    @JsonKey(name: 'Id') required int id,
    @JsonKey(name: 'IdDiscipline') required int disciplineId,
    @JsonKey(name: 'Genre') required String gender,
    @JsonKey(name: 'isEligibleToNationalRecord')
    @Default(false)
    bool isEligibleToNationalRecord,
    @JsonKey(name: 'discipline') required RaceDisciplineDto discipline,
    @JsonKey(name: 'categories') @Default(<CategoryDto>[]) List<CategoryDto> categories,
  }) = _RaceDto;

  factory RaceDto.fromJson(Map<String, dynamic> json) =>
      _$RaceDtoFromJson(json);
}

@freezed
class RaceDisciplineDto with _$RaceDisciplineDto {
  const factory RaceDisciplineDto({
    @JsonKey(name: 'Nom') required String name,
    @JsonKey(name: 'NomEn') required String nameEnglish,
    @JsonKey(name: 'Distance') @Default(0) int distance,
    @JsonKey(name: 'NbAthleteParEquipe') @Default(1) int athletesPerTeam,
    @JsonKey(name: 'Specialite') required int specialityId,
    @JsonKey(name: 'specialiteLabel') required String specialityLabel,
  }) = _RaceDisciplineDto;

  factory RaceDisciplineDto.fromJson(Map<String, dynamic> json) =>
      _$RaceDisciplineDtoFromJson(json);
}
```

- [ ] **Step 3: Run codegen**

Run: `dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 4: Write the failing mapper test**

Create `test/data/mappers/race_mapper_test.dart` with EXACTLY this content:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/dtos/category_dto.dart';
import 'package:live_ffss/app/data/dtos/race_dto.dart';
import 'package:live_ffss/app/data/mappers/race_mapper.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';

void main() {
  group('RaceMapper', () {
    test('maps a full RaceDto to Race', () {
      const dto = RaceDto(
        id: 12,
        disciplineId: 7,
        gender: 'F',
        isEligibleToNationalRecord: true,
        discipline: RaceDisciplineDto(
          name: '100m Surf',
          nameEnglish: '100m Surf Race',
          distance: 100,
          athletesPerTeam: 1,
          specialityId: 2,
          specialityLabel: 'Eau-plate',
        ),
        categories: [
          CategoryDto(id: 1, name: 'Senior', ageMin: 18, ageMax: 35),
        ],
      );

      final r = dto.toDomain();

      expect(r.id, 12);
      expect(r.name, '100m Surf');
      expect(r.nameEnglish, '100m Surf Race');
      expect(r.distance, 100);
      expect(r.gender, Gender.female);
      expect(r.athletesPerTeam, 1);
      expect(r.specialityId, 2);
      expect(r.specialityLabel, 'Eau-plate');
      expect(r.disciplineId, 7);
      expect(r.isEligibleToNationalRecord, true);
      expect(r.categories.length, 1);
      expect(r.categories.first.name, 'Senior');
    });

    test('handles missing distance/athletesPerTeam via defaults', () {
      final dto = RaceDto.fromJson(const {
        'Id': 1,
        'IdDiscipline': 1,
        'Genre': 'M',
        'discipline': {
          'Nom': 'X',
          'NomEn': 'X',
          'Specialite': 0,
          'specialiteLabel': '',
        },
      });

      final r = dto.toDomain();
      expect(r.distance, 0);
      expect(r.athletesPerTeam, 1);
      expect(r.categories, isEmpty);
    });
  });
}
```

- [ ] **Step 5: Run, verify it fails**

Run: `flutter test test/data/mappers/race_mapper_test.dart`
Expected: import error for `race_mapper.dart`.

- [ ] **Step 6: Create the mapper**

Create `lib/app/data/mappers/race_mapper.dart` with EXACTLY this content:

```dart
import 'package:live_ffss/app/data/dtos/race_dto.dart';
import 'package:live_ffss/app/data/mappers/athlete_mapper.dart';
import 'package:live_ffss/app/data/mappers/category_mapper.dart';
import 'package:live_ffss/app/domain/models/race.dart';

extension RaceMapper on RaceDto {
  Race toDomain() => Race(
        id: id,
        name: discipline.name,
        nameEnglish: discipline.nameEnglish,
        distance: discipline.distance,
        gender: parseGender(gender),
        athletesPerTeam: discipline.athletesPerTeam,
        specialityId: discipline.specialityId,
        specialityLabel: discipline.specialityLabel,
        disciplineId: disciplineId,
        isEligibleToNationalRecord: isEligibleToNationalRecord,
        categories: categories.map((c) => c.toDomain()).toList(),
      );
}
```

- [ ] **Step 7: Run, verify pass**

Run: `flutter test test/data/mappers/race_mapper_test.dart`
Expected: `All tests passed!` (2 tests).

- [ ] **Step 8: Create the formatting extension**

Create `lib/app/presentation/modules/competitions/race_formatting.dart` with EXACTLY this content:

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/core/services/language_service.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/race.dart';

extension RaceFormatting on Race {
  String get distanceLabel => '$distance m';

  String get genderLabel => switch (gender) {
        Gender.female => 'women'.tr,
        Gender.mixed => 'mixed'.tr,
        Gender.male => 'men'.tr,
        Gender.unknown => 'men'.tr,
      };

  /// Combined label that mirrors the legacy RaceModel.label format.
  /// Picks French or English race name based on the active LanguageService.
  String get label {
    final isEnglish = LanguageService.to.isEnglish;
    final raceName = isEnglish ? nameEnglish : name;
    final categoriesText = categories.map((c) => c.name).join(', ');
    return '$raceName $genderLabel ($categoriesText)';
  }
}
```

- [ ] **Step 9: Verify**

Run: `flutter analyze lib/app/presentation/modules/competitions/`
Expected: `No issues found!`

- [ ] **Step 10: Commit**

```bash
git add lib/app/domain/models/race.dart \
        lib/app/domain/models/race.freezed.dart \
        lib/app/domain/models/race.g.dart \
        lib/app/data/dtos/race_dto.dart \
        lib/app/data/dtos/race_dto.freezed.dart \
        lib/app/data/dtos/race_dto.g.dart \
        lib/app/data/mappers/race_mapper.dart \
        lib/app/presentation/modules/competitions/race_formatting.dart \
        test/data/mappers/race_mapper_test.dart
git commit -m "feat(domain): add Race domain + DTO + mapper + formatting

Race carries raw fields (name/nameEnglish/distance/Gender/categories
etc.) — language-dependent label moves to RaceFormatting extension
that consults LanguageService.to at call time."
```

---

## Task 5: Expand Club to typed lists + ClubMapper update

**Files:**
- Modify: `lib/app/domain/models/club.dart` — `List<dynamic>` → `List<Athlete>`/`List<Referee>`
- Modify: `lib/app/data/dtos/club_dto.dart` — add `athletes`/`officiels` lists
- Modify: `lib/app/data/mappers/club_mapper.dart` — fill the typed lists

- [ ] **Step 1: Update the Club domain**

REPLACE `lib/app/domain/models/club.dart` with EXACTLY this content:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/referee.dart';

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
    @Default(<Athlete>[]) List<Athlete> athletes,
    @Default(<Referee>[]) List<Referee> referees,
  }) = _Club;

  factory Club.fromJson(Map<String, dynamic> json) => _$ClubFromJson(json);
}
```

- [ ] **Step 2: Update the ClubDto**

REPLACE `lib/app/data/dtos/club_dto.dart` with EXACTLY this content:

```dart
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/data/dtos/athlete_dto.dart';
import 'package:live_ffss/app/data/dtos/referee_dto.dart';

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
    @JsonKey(name: 'athletes')
    @Default(<AthleteDto>[]) List<AthleteDto> athletes,
    @JsonKey(name: 'officiels')
    @Default(<RefereeDto>[]) List<RefereeDto> referees,
  }) = _ClubDto;

  factory ClubDto.fromJson(Map<String, dynamic> json) =>
      _$ClubDtoFromJson(json);
}
```

- [ ] **Step 3: Run codegen**

Run: `dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 4: Update the ClubMapper**

REPLACE `lib/app/data/mappers/club_mapper.dart` with EXACTLY this content:

```dart
import 'package:live_ffss/app/data/dtos/club_dto.dart';
import 'package:live_ffss/app/data/mappers/athlete_mapper.dart';
import 'package:live_ffss/app/data/mappers/referee_mapper.dart';
import 'package:live_ffss/app/domain/models/club.dart';

extension ClubMapper on ClubDto {
  Club toDomain() => Club(
        id: id,
        name: name,
        shortName: shortName,
        logoUrl: logoUrl,
        capUrl: capUrl,
        athletes: athletes.map((a) => a.toDomain()).toList(),
        referees: referees.map((r) => r.toDomain()).toList(),
      );
}

extension ClubX on Club {
  bool get hasLogo => logoUrl?.isNotEmpty == true;
  bool get hasCap => capUrl?.isNotEmpty == true;
}
```

- [ ] **Step 5: Run all the existing tests to confirm no regression**

Run: `flutter test test/data/mappers/`
Expected: club_mapper_test (5), competition_mapper_test (3), category_mapper_test (2), athlete_mapper_test (4), referee_mapper_test (3), race_mapper_test (2) — all passing.

- [ ] **Step 6: Commit**

```bash
git add lib/app/domain/models/club.dart \
        lib/app/domain/models/club.freezed.dart \
        lib/app/domain/models/club.g.dart \
        lib/app/data/dtos/club_dto.dart \
        lib/app/data/dtos/club_dto.freezed.dart \
        lib/app/data/dtos/club_dto.g.dart \
        lib/app/data/mappers/club_mapper.dart
git commit -m "feat(domain): expand Club with typed athletes/referees

Replaces the List<dynamic> placeholders from Batch 3a with
List<Athlete>/List<Referee>. ClubDto picks up athletes/officiels
arrays; ClubMapper fills them. Existing club_mapper_test still
passes — empty defaults preserve the prior contract."
```

---

## Task 6: ClubRemoteDataSource + ClubRepository (TDD)

**Files:**
- Create: `lib/app/data/datasources/club_remote_datasource.dart`
- Create: `lib/app/data/repositories/club_repository.dart`
- Create: `test/data/repositories/club_repository_test.dart`

- [ ] **Step 1: Create the data source**

Create `lib/app/data/datasources/club_remote_datasource.dart` with EXACTLY this content:

```dart
import 'package:live_ffss/app/core/config/app_config.dart';
import 'package:live_ffss/app/core/network/http_client.dart';
import 'package:live_ffss/app/data/dtos/club_dto.dart';

abstract class ClubRemoteDataSource {
  Future<List<ClubDto>> getClubs(int competitionId);
  Future<ClubDto> getClubDetail(int clubId);
}

class ClubRemoteDataSourceImpl implements ClubRemoteDataSource {
  ClubRemoteDataSourceImpl(this._http);

  final HttpClient _http;

  @override
  Future<List<ClubDto>> getClubs(int competitionId) async {
    final endpoint = ApiEndpoints.replacePath(
      ApiEndpoints.clubList,
      {'id': competitionId.toString()},
    );
    final body = await _http.get(endpoint);
    final list = (body['data'] as List?) ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(ClubDto.fromJson)
        .toList();
  }

  @override
  Future<ClubDto> getClubDetail(int clubId) async {
    final endpoint = ApiEndpoints.replacePath(
      ApiEndpoints.clubDetail,
      {'id': clubId.toString()},
    );
    final body = await _http.get(endpoint);
    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Unexpected club detail shape');
    }
    return ClubDto.fromJson(data);
  }
}
```

- [ ] **Step 2: Write the failing repository test**

Create `test/data/repositories/club_repository_test.dart` with EXACTLY this content:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/datasources/club_remote_datasource.dart';
import 'package:live_ffss/app/data/dtos/club_dto.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockDataSource extends Mock implements ClubRemoteDataSource {}

void main() {
  late _MockDataSource ds;
  late ClubRepository repo;

  ClubDto makeDto(int id, String name) =>
      ClubDto(id: id, name: name);

  setUp(() {
    ds = _MockDataSource();
    repo = ClubRepositoryImpl(ds);
  });

  group('ClubRepository.getClubs', () {
    test('forwards competitionId and maps DTOs to domain', () async {
      when(() => ds.getClubs(any())).thenAnswer((_) async => [
            makeDto(1, 'Alpha'),
            makeDto(2, 'Bravo'),
          ]);

      final list = await repo.getClubs(42);

      expect(list.length, 2);
      expect(list.first.name, 'Alpha');
      expect(list.first.athletes, isEmpty);
      verify(() => ds.getClubs(42)).called(1);
    });
  });

  group('ClubRepository.getClubDetail', () {
    test('forwards clubId and maps DTO to domain', () async {
      when(() => ds.getClubDetail(any()))
          .thenAnswer((_) async => makeDto(7, 'Solo'));

      final club = await repo.getClubDetail(7);

      expect(club.id, 7);
      expect(club.name, 'Solo');
      verify(() => ds.getClubDetail(7)).called(1);
    });
  });
}
```

- [ ] **Step 3: Run, verify it fails**

Run: `flutter test test/data/repositories/club_repository_test.dart`
Expected: import error for `club_repository.dart`.

- [ ] **Step 4: Create the repository**

Create `lib/app/data/repositories/club_repository.dart` with EXACTLY this content:

```dart
import 'package:live_ffss/app/data/datasources/club_remote_datasource.dart';
import 'package:live_ffss/app/data/mappers/club_mapper.dart';
import 'package:live_ffss/app/domain/models/club.dart';

abstract class ClubRepository {
  Future<List<Club>> getClubs(int competitionId);
  Future<Club> getClubDetail(int clubId);
}

class ClubRepositoryImpl implements ClubRepository {
  ClubRepositoryImpl(this._dataSource);

  final ClubRemoteDataSource _dataSource;

  @override
  Future<List<Club>> getClubs(int competitionId) async {
    final dtos = await _dataSource.getClubs(competitionId);
    return dtos.map((d) => d.toDomain()).toList();
  }

  @override
  Future<Club> getClubDetail(int clubId) async {
    final dto = await _dataSource.getClubDetail(clubId);
    return dto.toDomain();
  }
}
```

- [ ] **Step 5: Run, verify pass**

Run: `flutter test test/data/repositories/club_repository_test.dart`
Expected: `All tests passed!` (2 tests).

- [ ] **Step 6: Commit**

```bash
git add lib/app/data/datasources/club_remote_datasource.dart \
        lib/app/data/repositories/club_repository.dart \
        test/data/repositories/club_repository_test.dart
git commit -m "feat(data): add ClubRemoteDataSource + ClubRepository

Two endpoints: getClubs (list with embedded athletes/referees)
and getClubDetail (single full record). Repository maps DTOs to
domain Club. Single round-trip per call — N+1 loop in legacy
getClubs is dropped (athletes are already in the list response)."
```

(NB: this is a **deviation from legacy behavior**. The legacy `ApiService.getClubs` did N+1: fetched the list, then re-fetched each club's detail. Reading the legacy code, athletes/officiels ARE in the list response — the N+1 was unnecessary. The new code skips it. If a runtime issue surfaces — e.g., logo/cap URLs missing in the list response — we add a follow-up to refetch only those, but in a Repository orchestration layer, not the DataSource.)

---

## Task 7: RaceRemoteDataSource + RaceRepository (TDD)

**Files:**
- Create: `lib/app/data/datasources/race_remote_datasource.dart`
- Create: `lib/app/data/repositories/race_repository.dart`
- Create: `test/data/repositories/race_repository_test.dart`

- [ ] **Step 1: Create the data source**

Create `lib/app/data/datasources/race_remote_datasource.dart` with EXACTLY this content:

```dart
import 'package:live_ffss/app/core/config/app_config.dart';
import 'package:live_ffss/app/core/network/http_client.dart';
import 'package:live_ffss/app/data/dtos/race_dto.dart';

abstract class RaceRemoteDataSource {
  Future<List<RaceDto>> getRaces(int competitionId);
}

class RaceRemoteDataSourceImpl implements RaceRemoteDataSource {
  RaceRemoteDataSourceImpl(this._http);

  final HttpClient _http;

  @override
  Future<List<RaceDto>> getRaces(int competitionId) async {
    final body = await _http.get(
      ApiEndpoints.raceList,
      query: {'evenement': competitionId},
    );
    final list = (body['data'] as List?) ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(RaceDto.fromJson)
        .toList();
  }
}
```

- [ ] **Step 2: Write the failing repository test**

Create `test/data/repositories/race_repository_test.dart` with EXACTLY this content:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/datasources/race_remote_datasource.dart';
import 'package:live_ffss/app/data/dtos/race_dto.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockDataSource extends Mock implements RaceRemoteDataSource {}

void main() {
  late _MockDataSource ds;
  late RaceRepository repo;

  RaceDto makeDto(int id, {String specLabel = 'Eau-plate'}) => RaceDto(
        id: id,
        disciplineId: 1,
        gender: 'M',
        discipline: RaceDisciplineDto(
          name: 'Race$id',
          nameEnglish: 'Race$id (en)',
          specialityId: 1,
          specialityLabel: specLabel,
        ),
      );

  setUp(() {
    ds = _MockDataSource();
    repo = RaceRepositoryImpl(ds);
  });

  group('RaceRepository.getRaces', () {
    test('forwards competitionId and maps DTOs to domain', () async {
      when(() => ds.getRaces(any())).thenAnswer((_) async => [
            makeDto(1),
            makeDto(2, specLabel: 'Côtier'),
          ]);

      final list = await repo.getRaces(42);

      expect(list.length, 2);
      expect(list.first.name, 'Race1');
      expect(list.last.specialityLabel, 'Côtier');
      verify(() => ds.getRaces(42)).called(1);
    });
  });
}
```

- [ ] **Step 3: Run, verify it fails**

Run: `flutter test test/data/repositories/race_repository_test.dart`
Expected: import error for `race_repository.dart`.

- [ ] **Step 4: Create the repository**

Create `lib/app/data/repositories/race_repository.dart` with EXACTLY this content:

```dart
import 'package:live_ffss/app/data/datasources/race_remote_datasource.dart';
import 'package:live_ffss/app/data/mappers/race_mapper.dart';
import 'package:live_ffss/app/domain/models/race.dart';

abstract class RaceRepository {
  Future<List<Race>> getRaces(int competitionId);
}

class RaceRepositoryImpl implements RaceRepository {
  RaceRepositoryImpl(this._dataSource);

  final RaceRemoteDataSource _dataSource;

  @override
  Future<List<Race>> getRaces(int competitionId) async {
    final dtos = await _dataSource.getRaces(competitionId);
    return dtos.map((d) => d.toDomain()).toList();
  }
}
```

- [ ] **Step 5: Run, verify pass**

Run: `flutter test test/data/repositories/race_repository_test.dart`
Expected: `All tests passed!` (1 test).

- [ ] **Step 6: Commit**

```bash
git add lib/app/data/datasources/race_remote_datasource.dart \
        lib/app/data/repositories/race_repository.dart \
        test/data/repositories/race_repository_test.dart
git commit -m "feat(data): add RaceRemoteDataSource + RaceRepository

Single endpoint (competition/epreuve?evenement=:id). Repository
maps RaceDto -> Race domain via RaceMapper."
```

---

## Task 8: CompetitionDetailRacesController refactor

**Files:**
- Modify: `lib/app/module/competitions/controllers/competition_detail_races_controller.dart`
- Modify: `lib/app/module/competitions/views/competition_detail_races_view.dart`
- Create: `test/presentation/modules/competitions/controllers/competition_detail_races_controller_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/presentation/modules/competitions/controllers/competition_detail_races_controller_test.dart` with EXACTLY this content:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/race.dart';
import 'package:live_ffss/app/module/competitions/controllers/competition_detail_races_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements RaceRepository {}

void main() {
  late _MockRepo repo;
  late CompetitionDetailRacesController controller;

  Race race(int id, {String specLabel = 'Eau-plate'}) => Race(
        id: id,
        name: 'Race$id',
        nameEnglish: 'Race$id (en)',
        distance: 100,
        gender: Gender.male,
        athletesPerTeam: 1,
        specialityId: 1,
        specialityLabel: specLabel,
        disciplineId: 1,
        isEligibleToNationalRecord: false,
        categories: const [],
      );

  setUp(() {
    repo = _MockRepo();
    controller = CompetitionDetailRacesController(repo);
  });

  group('CompetitionDetailRacesController.loadRaces', () {
    test('loads, sorts by specialityId then name', () async {
      when(() => repo.getRaces(any())).thenAnswer((_) async => [
            race(2, specLabel: 'Côtier'),
            race(1),
          ]);

      await controller.loadRaces(99);

      expect(controller.allRaces.length, 2);
      // specialityId is 1 for both fixtures, so name tiebreak kicks in.
      expect(controller.allRaces.first.id, 1);
      expect(controller.isLoading.value, false);
      expect(controller.hasError.value, false);
    });

    test('on AppException sets hasError', () async {
      when(() => repo.getRaces(any())).thenThrow(Exception('boom'));

      await controller.loadRaces(99);

      expect(controller.hasError.value, true);
      expect(controller.isLoading.value, false);
    });
  });

  group('CompetitionDetailRacesController filtering', () {
    test('setFilterIndex(1) keeps only beach races', () async {
      controller.allRaces.value = [
        race(1, specLabel: 'Côtier'),
        race(2, specLabel: 'Eau-plate'),
        race(3, specLabel: 'Côtier'),
      ];
      controller.setFilterIndex(1);
      expect(controller.filteredRaces.length, 2);
      expect(controller.filteredRaces.every((r) => r.specialityLabel == 'Côtier'),
          isTrue);
    });

    test('setFilterIndex(2) keeps only eau-plate races', () {
      controller.allRaces.value = [
        race(1, specLabel: 'Côtier'),
        race(2, specLabel: 'Eau-plate'),
      ];
      controller.setFilterIndex(2);
      expect(controller.filteredRaces.length, 1);
      expect(controller.filteredRaces.first.specialityLabel, 'Eau-plate');
    });

    test('setFilterIndex(0) shows all', () {
      controller.allRaces.value = [
        race(1, specLabel: 'Côtier'),
        race(2, specLabel: 'Eau-plate'),
      ];
      controller.setFilterIndex(0);
      expect(controller.filteredRaces.length, 2);
    });
  });
}
```

- [ ] **Step 2: Run, verify it fails**

Run: `flutter test test/presentation/modules/competitions/controllers/competition_detail_races_controller_test.dart`
Expected: import / type errors against the legacy controller.

- [ ] **Step 3: Rewrite the controller**

REPLACE `lib/app/module/competitions/controllers/competition_detail_races_controller.dart` with EXACTLY this content:

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/race.dart';

class CompetitionDetailRacesController extends GetxController {
  CompetitionDetailRacesController(this._raceRepo);

  final RaceRepository _raceRepo;

  Rxn<Competition> competition = Rxn<Competition>();
  final RxList<Race> allRaces = <Race>[].obs;
  final RxList<Race> filteredRaces = <Race>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxInt selectedFilterIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is Competition) {
      competition.value = arg;
      loadRaces(arg.id);
    } else {
      isLoading.value = false;
    }
  }

  void setFilterIndex(int index) {
    selectedFilterIndex.value = index;
    _applyRaceFilter();
  }

  Future<void> loadRaces(int competitionId) async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final loaded = await _raceRepo.getRaces(competitionId);
      loaded.sort((a, b) {
        final typeCompare = a.specialityId.compareTo(b.specialityId);
        if (typeCompare != 0) return typeCompare;
        return a.name.compareTo(b.name);
      });

      selectedFilterIndex.value = 0;
      allRaces.value = loaded;
      _applyRaceFilter();
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void _applyRaceFilter() {
    switch (selectedFilterIndex.value) {
      case 0:
        filteredRaces.value = List.from(allRaces);
      case 1:
        filteredRaces.value =
            allRaces.where((r) => r.specialityLabel == 'Côtier').toList();
      case 2:
        filteredRaces.value =
            allRaces.where((r) => r.specialityLabel == 'Eau-plate').toList();
      default:
        filteredRaces.value = List.from(allRaces);
    }
  }
}
```

Key changes from legacy:
- Constructor injection of `RaceRepository`.
- `competition` is the new domain `Competition`.
- `loadRaces(int)` takes the id explicitly so the test can control it.
- The filter cases use Dart 3 switch-without-`break` syntax (matches the existing modern code style).
- The legacy `Get.find<ApiService>()` is gone.

- [ ] **Step 4: Update the view's type imports**

In `lib/app/module/competitions/views/competition_detail_races_view.dart`, the view reads `race.label` and `race.raceType` (legacy field names).

REPLACE the line:
```dart
return _buildRaceItem(race.label, race.raceType);
```

with:
```dart
return _buildRaceItem(race.label, race.specialityLabel);
```

(`race.label` works because `RaceFormatting` extension provides it. `race.raceType` was renamed to `race.specialityLabel` in the new domain.)

ADD this import to the top of the file (alongside existing imports):
```dart
import 'package:live_ffss/app/presentation/modules/competitions/race_formatting.dart';
```

If the view file imports `data/models/race_model.dart` anywhere, REMOVE that import.

- [ ] **Step 5: Run, verify the test passes**

Run: `flutter test test/presentation/modules/competitions/controllers/competition_detail_races_controller_test.dart`
Expected: `All tests passed!` (5 tests).

- [ ] **Step 6: Commit**

```bash
git add lib/app/module/competitions/controllers/competition_detail_races_controller.dart \
        lib/app/module/competitions/views/competition_detail_races_view.dart \
        test/presentation/modules/competitions/controllers/competition_detail_races_controller_test.dart
git commit -m "refactor(competition): RacesController on RaceRepository

Constructor-injects RaceRepository. loadRaces takes the competition
id explicitly. Filter logic preserved verbatim (still string-matches
'Côtier'/'Eau-plate' — typed Discipline enum is a Batch 5 concern).
View uses race.label via RaceFormatting and race.specialityLabel."
```

---

## Task 9: CompetitionDetailClubsController refactor

**Files:**
- Modify: `lib/app/module/competitions/controllers/competition_detail_clubs_controller.dart`
- Modify: `lib/app/module/competitions/views/competition_detail_clubs_view.dart`
- Create: `test/presentation/modules/competitions/controllers/competition_detail_clubs_controller_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/presentation/modules/competitions/controllers/competition_detail_clubs_controller_test.dart` with EXACTLY this content:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/module/competitions/controllers/competition_detail_clubs_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements ClubRepository {}

void main() {
  late _MockRepo repo;
  late CompetitionDetailClubsController controller;

  Club c(int id, String name) => Club(id: id, name: name);

  setUp(() {
    repo = _MockRepo();
    controller = CompetitionDetailClubsController(repo);
  });

  group('CompetitionDetailClubsController.loadClubs', () {
    test('loads, sorts by name', () async {
      when(() => repo.getClubs(any())).thenAnswer((_) async => [
            c(1, 'Beta'),
            c(2, 'Alpha'),
          ]);

      await controller.loadClubs(99);

      expect(controller.allClubs.length, 2);
      expect(controller.allClubs.first.name, 'Alpha');
      expect(controller.filteredClubs.length, 2);
      expect(controller.isLoading.value, false);
      expect(controller.hasError.value, false);
    });

    test('on error sets hasError', () async {
      when(() => repo.getClubs(any())).thenThrow(Exception('offline'));

      await controller.loadClubs(99);

      expect(controller.hasError.value, true);
      expect(controller.allClubs, isEmpty);
    });
  });
}
```

- [ ] **Step 2: Run, verify it fails**

Run: `flutter test test/presentation/modules/competitions/controllers/competition_detail_clubs_controller_test.dart`
Expected: import / type errors against the legacy controller.

- [ ] **Step 3: Rewrite the controller**

REPLACE `lib/app/module/competitions/controllers/competition_detail_clubs_controller.dart` with EXACTLY this content:

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/competition.dart';

class CompetitionDetailClubsController extends GetxController {
  CompetitionDetailClubsController(this._clubRepo);

  final ClubRepository _clubRepo;

  Rxn<Competition> competition = Rxn<Competition>();
  final RxList<Club> allClubs = <Club>[].obs;
  final RxList<Club> filteredClubs = <Club>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is Competition) {
      competition.value = arg;
      loadClubs(arg.id);
    } else {
      isLoading.value = false;
    }
  }

  Future<void> loadClubs(int competitionId) async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final loaded = await _clubRepo.getClubs(competitionId);
      loaded.sort((a, b) => a.name.compareTo(b.name));

      allClubs.value = loaded;
      _applyClubFilter();
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void _applyClubFilter() {
    filteredClubs.value = List.from(allClubs);
  }
}
```

- [ ] **Step 4: Update the view's type imports**

In `lib/app/module/competitions/views/competition_detail_clubs_view.dart`, the view's `buildClubCard(BuildContext, ClubModel)` signature uses the legacy type. Update it.

In the imports at the top, REPLACE:
```dart
import 'package:live_ffss/app/data/models/athlete_model.dart';
import 'package:live_ffss/app/data/models/club_model.dart';
```

with:
```dart
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/data/mappers/club_mapper.dart';
```

The `club_mapper.dart` import brings in `ClubX` (`hasLogo`, `hasCap`).

In the file, find every reference to `ClubModel` and replace with `Club`. Find references to `AthleteModel` and replace with `Athlete`. (You can use a single find-and-replace for each.)

- [ ] **Step 5: Run, verify the test passes**

Run: `flutter test test/presentation/modules/competitions/controllers/competition_detail_clubs_controller_test.dart`
Expected: `All tests passed!` (2 tests).

- [ ] **Step 6: Commit**

```bash
git add lib/app/module/competitions/controllers/competition_detail_clubs_controller.dart \
        lib/app/module/competitions/views/competition_detail_clubs_view.dart \
        test/presentation/modules/competitions/controllers/competition_detail_clubs_controller_test.dart
git commit -m "refactor(competition): ClubsController on ClubRepository

Constructor-injects ClubRepository. loadClubs takes competitionId
explicitly. View switches to domain Club/Athlete imports."
```

---

## Task 10: CompetitionDetailController refactor + competition_detail_view.dart

**Files:**
- Modify: `lib/app/module/competitions/controllers/competition_detail_controller.dart`
- Modify: `lib/app/module/competitions/views/competition_detail_view.dart`
- Modify: `lib/app/module/competitions/views/competition_detail_home_view.dart` (type-swap only)

- [ ] **Step 1: Update CompetitionDetailController**

REPLACE `lib/app/module/competitions/controllers/competition_detail_controller.dart` with EXACTLY this content:

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/core/services/language_service.dart';
import 'package:live_ffss/app/data/models/club_ranking.dart';
import 'package:live_ffss/app/domain/models/competition.dart';

class CompetitionDetailController extends GetxController {
  CompetitionDetailController(this._languageService);

  final LanguageService _languageService;

  Rxn<Competition> competition = Rxn<Competition>();

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxInt currentTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is Competition) {
      competition.value = arg;
    }
  }

  List<ClubRanking> get clubRankingsLimited => List.empty();

  RxString get currentLanguage => _languageService.currentLanguage;
  bool get isFrench => _languageService.isFrench;
  bool get isEnglish => _languageService.isEnglish;

  void changeTab(int index) {
    currentTabIndex.value = index;
  }

  Future<void> refreshData() async {
    // No-op until rankings are wired up.
  }
}
```

`ClubRanking` legacy model is unchanged — the rankings feature isn't implemented and `clubRankingsLimited` returns empty. Touching it is out of scope.

- [ ] **Step 2: Update competition_detail_view.dart**

In `lib/app/module/competitions/views/competition_detail_view.dart`, the view uses `competition.formattedBeginDate` and `competition.formattedEndDate`. These are extension getters from `competition_formatting.dart` (created in Batch 3a).

ADD this import at the top of the file:
```dart
import 'package:live_ffss/app/presentation/modules/home/competition_formatting.dart';
```

That's the only change — `competition.name` works on the new domain unchanged.

- [ ] **Step 3: Update competition_detail_home_view.dart**

The home view uses `controller.competition.value` — the type changed from `CompetitionModel` to `Competition` automatically through the controller refactor. No code changes needed unless legacy field names are used.

Quick grep:
```bash
grep -n 'competition_model\|CompetitionModel' lib/app/module/competitions/views/competition_detail_home_view.dart
```

If no matches, no edit needed. If there are matches, replace `CompetitionModel` with `Competition` and remove the legacy import.

- [ ] **Step 4: Verify everything compiles**

Run: `flutter analyze lib/app/module/competitions/`
Expected: zero errors.

(`flutter` may not be on bash PATH — fall back to `C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat` if needed.)

- [ ] **Step 5: Commit**

```bash
git add lib/app/module/competitions/controllers/competition_detail_controller.dart \
        lib/app/module/competitions/views/competition_detail_view.dart \
        lib/app/module/competitions/views/competition_detail_home_view.dart
git commit -m "refactor(competition): CompetitionDetailController on Competition

Constructor-injects LanguageService. competition is now the new
domain type. View imports the formatting extension. Rankings
feature still stubbed (clubRankingsLimited returns empty)."
```

---

## Task 11: CompetitionDetailBinding + InitialBinding + final wiring

**Files:**
- Modify: `lib/app/module/competitions/bindings/competition_detail_binding.dart`
- Modify: `lib/app/core/di/initial_binding.dart`

- [ ] **Step 1: Update CompetitionDetailBinding**

REPLACE `lib/app/module/competitions/bindings/competition_detail_binding.dart` with EXACTLY this content:

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/core/services/language_service.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import '../controllers/competition_detail_clubs_controller.dart';
import '../controllers/competition_detail_controller.dart';
import '../controllers/competition_detail_races_controller.dart';

class CompetitionDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompetitionDetailController>(
      () => CompetitionDetailController(Get.find<LanguageService>()),
    );
    Get.lazyPut<CompetitionDetailRacesController>(
      () => CompetitionDetailRacesController(Get.find<RaceRepository>()),
    );
    Get.lazyPut<CompetitionDetailClubsController>(
      () => CompetitionDetailClubsController(Get.find<ClubRepository>()),
    );
  }
}
```

The legacy `Get.lazyPut<ApiService>(...)` is gone — `ApiService` lives in `InitialBinding` as a permanent singleton (since Batch 1).

- [ ] **Step 2: Add Club + Race registrations to InitialBinding**

In `lib/app/core/di/initial_binding.dart`, ADD imports at the top (alongside existing imports):

```dart
import 'package:live_ffss/app/data/datasources/club_remote_datasource.dart';
import 'package:live_ffss/app/data/datasources/race_remote_datasource.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
```

Then ADD registrations IMMEDIATELY AFTER the existing `Competition data layer` section (5) and BEFORE the transitional `ApiService` line:

```dart
    // 5b. Club data layer
    Get.put<ClubRemoteDataSource>(
      ClubRemoteDataSourceImpl(Get.find<HttpClient>()),
      permanent: true,
    );
    Get.put<ClubRepository>(
      ClubRepositoryImpl(Get.find<ClubRemoteDataSource>()),
      permanent: true,
    );

    // 5c. Race data layer
    Get.put<RaceRemoteDataSource>(
      RaceRemoteDataSourceImpl(Get.find<HttpClient>()),
      permanent: true,
    );
    Get.put<RaceRepository>(
      RaceRepositoryImpl(Get.find<RaceRemoteDataSource>()),
      permanent: true,
    );
```

- [ ] **Step 3: Run analyzer + tests**

Run: `flutter analyze`
Expected: zero errors.

Run: `flutter test`
Expected: all tests pass — Batch 0 (44) + Batch 1 (15) + Batch 2 (0) + Batch 3a (16) + Batch 3b (~17 new) = ~92 tests.

- [ ] **Step 4: Commit**

```bash
git add lib/app/module/competitions/bindings/competition_detail_binding.dart \
        lib/app/core/di/initial_binding.dart
git commit -m "feat(di): wire Club + Race repositories into bindings

InitialBinding gets two new sections (5b: Club data, 5c: Race data).
CompetitionDetailBinding constructor-injects LanguageService,
RaceRepository, ClubRepository into the three controllers.
ApiService stays registered transitionally for Batch 4/5."
```

---

## Task 12: Final verification

- [ ] **Step 1: Run full test suite**

Run: `flutter test`
Expected: ~92 tests passing.

- [ ] **Step 2: Run analyzer**

Run: `flutter analyze`
Expected: zero errors. Pre-existing warnings/info baseline should be at 12 (Batch 3a baseline) or lower.

- [ ] **Step 3: Confirm legacy ApiService usage scope**

Run: `grep -rn "Get.find<ApiService>()" lib/app/module/`
Expected: hits in `program_controller.dart`, `slot_controller.dart` ONLY. No more in `competition_detail_*_controller.dart` or `home_controller.dart`.

Run: `grep -rn "data/models/competition_model.dart\|data/models/club_model.dart\|data/models/race_model.dart\|data/models/athlete_model.dart\|data/models/referee_model.dart\|data/models/category_model.dart" lib/app/module/`
Expected: only `program/` and `slot/` modules still import legacy models.

- [ ] **Step 4: Confirm git state**

- `git log --oneline main..HEAD` — ~11 commits.
- `git branch --show-current` — `refactor/batch-3b-race-club-detail`.
- `git status` — clean (only `.claude/` untracked).
- `git diff main..HEAD --stat | tail -25` — total LOC change.

- [ ] **Step 5 (manual, by user): Smoke-test the competition detail flow**

`flutter run`. Click through:
- Home → competition card → detail screen loads.
- Tap "Races" tab → list loads.
- Tap a filter (Plage / Mer) → list filters.
- Tap "Clubs" tab → club list loads with logos.
- Expand a club → athletes appear.

Visual regressions to watch for:
- Race labels should be language-aware (FR uses `Nom`, EN uses `NomEn`).
- Filter behavior identical to legacy.
- Club expansion shows the expected athletes/referees.

If anything is broken, paste the error and we'll diagnose before Batch 4.

---

## Self-review

**Spec coverage** (against §14 "Batch 3 — Competition + Race + Club domains" — completing Batch 3 here):
- DTOs, mappers, datasources, repositories for Race + Club expansion → Tasks 1, 2, 3, 4, 5, 6, 7 ✓
- CompetitionDetailController switches to repos → Tasks 8 + 9 + 10 ✓
- UI side-effects move to views → no new ones; controllers only manage state ✓
- Tests for mappers + repos + controllers → Tasks 1, 2, 3, 4, 6, 7, 8, 9 ✓
- Split competition_detail_view.dart into widgets → **DEFERRED** (the view is already small enough that splitting isn't urgent)

**Placeholder scan:** None. Deferrals (rankings feature, view splits, N+1 fetch optimization) documented at the top.

**Type consistency:**
- `Gender` enum is defined ONCE in `athlete.dart` and imported by `referee.dart` and `race.dart`. ✓
- `parseGender` is exported from `athlete_mapper.dart` and reused by `race_mapper.dart` and `referee_mapper.dart`. ✓
- `Club` is updated in Task 5 to use `List<Athlete>`/`List<Referee>` — matches what Tasks 6 and 8 produce. ✓
- All controller constructors take their repository as the first positional arg (`CompetitionDetailRacesController(this._raceRepo)`, `CompetitionDetailClubsController(this._clubRepo)`, `CompetitionDetailController(this._languageService)`). ✓
- `CompetitionDetailRacesController.loadRaces(int competitionId)` and `CompetitionDetailClubsController.loadClubs(int competitionId)` take the id explicitly — matches the test expectations. ✓
- Repository abstract classes match impl: `ClubRepository`/`ClubRepositoryImpl`, `RaceRepository`/`RaceRepositoryImpl`. ✓

---

## Done criteria for Batch 3b

- ~11 commits on `refactor/batch-3b-race-club-detail`.
- New: 4 domain models (Category, Athlete, Referee, Race) + 4 DTOs + 4 mappers + 2 datasources + 2 repositories + 1 RaceFormatting extension + 6 test files.
- Modified: Club domain + DTO + mapper (typed lists), 3 CompetitionDetail controllers, 3 corresponding views, CompetitionDetailBinding, InitialBinding.
- `flutter analyze`: zero errors.
- `flutter test`: ~92 tests, all green.
- The CompetitionDetail flow works end-to-end via the new repos.
- Legacy `ApiService` and legacy models still on disk + still consumed by `program/` and `slot/` modules. Batch 4 + 5 retire them.
