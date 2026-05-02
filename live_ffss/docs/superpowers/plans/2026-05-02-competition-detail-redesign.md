# Competition Detail Page Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the white-AppBar + 5-tab `competitionDetail` page with a 3-pill design (Évènements / Clubs / Points) using the home_view's blue+wave visual language. Wire typed seams for the Points tab so the UI is ready when the FFSS rankings backend lands.

**Architecture:** Rebuild `CompetitionDetailView` as a Scaffold with a `_CompetitionDetailHeader` (blue strip + back arrow + favorite + name/dates/location + 3 pills), `HomeWave`, and `IndexedStack` of three children: existing `CompetitionDetailRacesView` content (Évènements), refreshed `CompetitionDetailClubsView` (Clubs), and a new `CompetitionDetailPointsView` with three sub-pills (Clubs/Individuel/Relais) reading from a new `RankingRepository` whose stub returns empty lists today.

**Tech Stack:** Flutter 3.22.2 / Dart 3.4.3, GetX (state + DI + routing), freezed + json_serializable (domain models), mocktail (controller + repo tests).

**Spec:** [docs/superpowers/specs/2026-05-02-competition-detail-redesign-design.md](../specs/2026-05-02-competition-detail-redesign-design.md)

---

## File Structure

**Create:**
- `lib/app/domain/models/individual_ranking.dart` — freezed domain model.
- `lib/app/domain/models/relay_ranking.dart` — freezed domain model.
- `lib/app/data/datasources/ranking_remote_datasource.dart` — abstract interface + `Impl` returning empty lists (matches the user's Q3 → A choice; differs from `ResultRemoteDataSourceImpl`'s `UnimplementedError` because the UI's empty-state path requires successful empty results, not exceptions).
- `lib/app/data/repositories/ranking_repository.dart` — abstract interface + `Impl` (no DTO mapping needed since the data source returns empty domain-shaped lists today; when the backend lands, DTOs + mappers will be added then).
- `lib/app/module/competitions/controllers/competition_detail_points_controller.dart` — GetX controller with three RxLists, isLoading, hasError, selectedPointsTab, onInit-driven loadRankings.
- `lib/app/module/competitions/views/competition_detail_points_view.dart` — Pills row (Clubs/Individuel/Relais) + IndexedStack of three sub-views.
- `test/data/repositories/ranking_repository_test.dart` — verifies repo delegates to data source for all three methods.
- `test/presentation/modules/competitions/controllers/competition_detail_points_controller_test.dart` — verifies state transitions and onInit guard.

**Modify:**
- `lib/app/module/competitions/views/competition_detail_view.dart` — full rewrite (new header, pills, IndexedStack, removed bottom nav).
- `lib/app/module/competitions/views/competition_detail_clubs_view.dart` — visual refresh (design tokens, `withValues` instead of `withOpacity`, shared LoadingIndicator/ErrorState/EmptyState).
- `lib/app/module/competitions/controllers/competition_detail_controller.dart` — drop `clubRankingsLimited` getter, drop `LanguageService` dependency + getters (no consumers), add `UserPreferencesService` for favorite pass-through, keep `currentTabIndex` (now 0/1/2).
- `lib/app/module/competitions/bindings/competition_detail_binding.dart` — register `CompetitionDetailPointsController`, update `CompetitionDetailController` constructor injection (drop LanguageService, add UserPreferencesService), keep existing controllers.
- `lib/app/routes/app_pages.dart` — drop `ProgramBinding()` from the `competitionDetail` route's bindings (the standalone `Routes.program` keeps its binding).
- `lib/app/core/di/initial_binding.dart` — add `RankingRemoteDataSource` + `RankingRepository` after `ResultRepository` (slot 5f).
- `lib/app/core/translations/en_US.dart` + `fr_FR.dart` — 6 new keys.

**Delete:**
- `lib/app/module/competitions/views/competition_detail_home_view.dart` — placeholder Home tab is removed entirely. Grep confirms only `competition_detail_view.dart` references it, and that file is being rewritten.

---

## Task 1: Add translation keys

**Files:**
- Modify: `lib/app/core/translations/en_US.dart` (insert near competition-related keys)
- Modify: `lib/app/core/translations/fr_FR.dart` (mirror placement)

- [ ] **Step 1: Add the six keys to en_US.dart**

In `lib/app/core/translations/en_US.dart`, find the existing line `'no_competitions_found': 'No competitions found',` (around line 76) and insert the six new keys after the `'no_last_viewed'` line that follows it. Result section:

```dart
  'no_competitions_found': 'No competitions found',
  'no_last_viewed': 'No competitions viewed yet',
  'events': 'Events',
  'individual_ranking': 'Individual Ranking',
  'relais_ranking': 'Relay Ranking',
  'no_rankings_yet': 'No rankings yet',
  'no_individual_ranking_yet': 'No individual ranking yet',
  'no_relais_ranking_yet': 'No relay ranking yet',

  'home': 'Home',
```

(Surrounding lines shown for context. Insert ONLY the six new lines.)

- [ ] **Step 2: Add the six keys to fr_FR.dart**

In `lib/app/core/translations/fr_FR.dart`, find the corresponding `'no_last_viewed': 'Aucune compétition consultée',` line (around line 76) and insert:

```dart
  'no_competitions_found': 'Aucune compétition trouvée',
  'no_last_viewed': 'Aucune compétition consultée',
  'events': 'Évènements',
  'individual_ranking': 'Classement Individuel',
  'relais_ranking': 'Classement Relais',
  'no_rankings_yet': 'Aucun classement',
  'no_individual_ranking_yet': 'Aucun classement individuel',
  'no_relais_ranking_yet': 'Aucun classement relais',

  'home': 'Accueil',
```

- [ ] **Step 3: Verify analyzer passes**

Run: `flutter analyze lib/app/core/translations/`

If `flutter` is not on PATH (Windows quirk), use:
`C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat analyze lib/app/core/translations/`

Expected: only the pre-existing `file_names` info warnings. No errors.

- [ ] **Step 4: Commit**

```bash
git add lib/app/core/translations/en_US.dart lib/app/core/translations/fr_FR.dart
git commit -m "feat(i18n): add competition detail redesign translation keys"
```

---

## Task 2: Add IndividualRanking + RelayRanking domain models

**Files:**
- Create: `lib/app/domain/models/individual_ranking.dart`
- Create: `lib/app/domain/models/relay_ranking.dart`
- Codegen will produce: `individual_ranking.freezed.dart`, `individual_ranking.g.dart`, `relay_ranking.freezed.dart`, `relay_ranking.g.dart`

- [ ] **Step 1: Create individual_ranking.dart**

Create `lib/app/domain/models/individual_ranking.dart` with this EXACT content:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'individual_ranking.freezed.dart';
part 'individual_ranking.g.dart';

@freezed
class IndividualRanking with _$IndividualRanking {
  const factory IndividualRanking({
    @Default(0) int position,
    @Default('') String athleteFirstName,
    @Default('') String athleteLastName,
    @Default('') String clubName,
    @Default(0) int points,
  }) = _IndividualRanking;

  factory IndividualRanking.fromJson(Map<String, dynamic> json) =>
      _$IndividualRankingFromJson(json);
}
```

- [ ] **Step 2: Create relay_ranking.dart**

Create `lib/app/domain/models/relay_ranking.dart` with this EXACT content:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'relay_ranking.freezed.dart';
part 'relay_ranking.g.dart';

@freezed
class RelayRanking with _$RelayRanking {
  const factory RelayRanking({
    @Default(0) int position,
    @Default('') String clubName,
    @Default('') String teamName,
    @Default(0) int points,
  }) = _RelayRanking;

  factory RelayRanking.fromJson(Map<String, dynamic> json) =>
      _$RelayRankingFromJson(json);
}
```

- [ ] **Step 3: Run build_runner**

Run: `dart run build_runner build --delete-conflicting-outputs`

(If `dart` is not on PATH: `C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\dart.bat run build_runner build --delete-conflicting-outputs`)

Expected: produces 4 generated files (`individual_ranking.freezed.dart`, `individual_ranking.g.dart`, `relay_ranking.freezed.dart`, `relay_ranking.g.dart`). Output line "Succeeded after Xs with N outputs".

- [ ] **Step 4: Verify analyzer passes on the new models**

Run: `flutter analyze lib/app/domain/models/individual_ranking.dart lib/app/domain/models/relay_ranking.dart`

Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/app/domain/models/individual_ranking.dart lib/app/domain/models/individual_ranking.freezed.dart lib/app/domain/models/individual_ranking.g.dart lib/app/domain/models/relay_ranking.dart lib/app/domain/models/relay_ranking.freezed.dart lib/app/domain/models/relay_ranking.g.dart
git commit -m "feat(domain): add IndividualRanking and RelayRanking models"
```

---

## Task 3: Add RankingRemoteDataSource

**Files:**
- Create: `lib/app/data/datasources/ranking_remote_datasource.dart`

Note: this implementation returns empty lists today (matches the user's Q3 → A choice in the spec — UI shows EmptyState, no exceptions). Differs from `ResultRemoteDataSourceImpl`, which throws `UnimplementedError`. The divergence is intentional and called out in a doc comment on the Impl.

- [ ] **Step 1: Create the file**

Create `lib/app/data/datasources/ranking_remote_datasource.dart` with this EXACT content:

```dart
import 'package:live_ffss/app/domain/models/club_ranking.dart';
import 'package:live_ffss/app/domain/models/individual_ranking.dart';
import 'package:live_ffss/app/domain/models/relay_ranking.dart';

abstract class RankingRemoteDataSource {
  Future<List<ClubRanking>> getClubRankings(int competitionId);
  Future<List<IndividualRanking>> getIndividualRankings(int competitionId);
  Future<List<RelayRanking>> getRelayRankings(int competitionId);
}

/// Stub implementation: returns empty lists for all three rankings.
///
/// FFSS rankings endpoints are not documented yet (see CLAUDE.md "Known
/// gaps"). The Points tab UI is built around the EmptyState path — when the
/// backend lands, swap this stub for a real HTTP-backed impl that maps DTOs
/// to the three domain models. The repository, controller, view, and tests
/// stay as-is.
class RankingRemoteDataSourceImpl implements RankingRemoteDataSource {
  RankingRemoteDataSourceImpl();

  @override
  Future<List<ClubRanking>> getClubRankings(int competitionId) async =>
      const <ClubRanking>[];

  @override
  Future<List<IndividualRanking>> getIndividualRankings(
    int competitionId,
  ) async =>
      const <IndividualRanking>[];

  @override
  Future<List<RelayRanking>> getRelayRankings(int competitionId) async =>
      const <RelayRanking>[];
}
```

- [ ] **Step 2: Verify analyzer passes**

Run: `flutter analyze lib/app/data/datasources/ranking_remote_datasource.dart`

Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/app/data/datasources/ranking_remote_datasource.dart
git commit -m "feat(data): add RankingRemoteDataSource stub returning empty lists"
```

---

## Task 4: Add RankingRepository + tests

**Files:**
- Create: `lib/app/data/repositories/ranking_repository.dart`
- Create: `test/data/repositories/ranking_repository_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/data/repositories/ranking_repository_test.dart` with this EXACT content:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/datasources/ranking_remote_datasource.dart';
import 'package:live_ffss/app/data/repositories/ranking_repository.dart';
import 'package:live_ffss/app/domain/models/club_ranking.dart';
import 'package:live_ffss/app/domain/models/individual_ranking.dart';
import 'package:live_ffss/app/domain/models/relay_ranking.dart';
import 'package:mocktail/mocktail.dart';

class _MockDataSource extends Mock implements RankingRemoteDataSource {}

void main() {
  late _MockDataSource ds;
  late RankingRepository repo;

  setUp(() {
    ds = _MockDataSource();
    repo = RankingRepositoryImpl(ds);
  });

  group('RankingRepository.getClubRankings', () {
    test('forwards competitionId and returns the data source result',
        () async {
      const expected = [
        ClubRanking(position: 1, clubName: 'Alpha', points: 100),
        ClubRanking(position: 2, clubName: 'Bravo', points: 80),
      ];
      when(() => ds.getClubRankings(any())).thenAnswer((_) async => expected);

      final result = await repo.getClubRankings(42);

      expect(result, expected);
      verify(() => ds.getClubRankings(42)).called(1);
    });

    test('returns empty when data source returns empty', () async {
      when(() => ds.getClubRankings(any()))
          .thenAnswer((_) async => const <ClubRanking>[]);

      final result = await repo.getClubRankings(7);

      expect(result, isEmpty);
    });
  });

  group('RankingRepository.getIndividualRankings', () {
    test('forwards competitionId and returns the data source result',
        () async {
      const expected = [
        IndividualRanking(
          position: 1,
          athleteFirstName: 'Alice',
          athleteLastName: 'Doe',
          clubName: 'Alpha',
          points: 200,
        ),
      ];
      when(() => ds.getIndividualRankings(any()))
          .thenAnswer((_) async => expected);

      final result = await repo.getIndividualRankings(42);

      expect(result, expected);
      verify(() => ds.getIndividualRankings(42)).called(1);
    });
  });

  group('RankingRepository.getRelayRankings', () {
    test('forwards competitionId and returns the data source result',
        () async {
      const expected = [
        RelayRanking(
          position: 1,
          clubName: 'Alpha',
          teamName: 'Alpha A',
          points: 150,
        ),
      ];
      when(() => ds.getRelayRankings(any()))
          .thenAnswer((_) async => expected);

      final result = await repo.getRelayRankings(42);

      expect(result, expected);
      verify(() => ds.getRelayRankings(42)).called(1);
    });
  });
}
```

- [ ] **Step 2: Run the tests to verify they FAIL**

Run: `flutter test test/data/repositories/ranking_repository_test.dart`

Expected: FAIL — `Target of URI doesn't exist: 'package:live_ffss/app/data/repositories/ranking_repository.dart'`

This is the TDD RED phase. Capture the failure output.

- [ ] **Step 3: Write the repository**

Create `lib/app/data/repositories/ranking_repository.dart` with this EXACT content:

```dart
import 'package:live_ffss/app/data/datasources/ranking_remote_datasource.dart';
import 'package:live_ffss/app/domain/models/club_ranking.dart';
import 'package:live_ffss/app/domain/models/individual_ranking.dart';
import 'package:live_ffss/app/domain/models/relay_ranking.dart';

abstract class RankingRepository {
  Future<List<ClubRanking>> getClubRankings(int competitionId);
  Future<List<IndividualRanking>> getIndividualRankings(int competitionId);
  Future<List<RelayRanking>> getRelayRankings(int competitionId);
}

class RankingRepositoryImpl implements RankingRepository {
  RankingRepositoryImpl(this._dataSource);

  final RankingRemoteDataSource _dataSource;

  @override
  Future<List<ClubRanking>> getClubRankings(int competitionId) =>
      _dataSource.getClubRankings(competitionId);

  @override
  Future<List<IndividualRanking>> getIndividualRankings(int competitionId) =>
      _dataSource.getIndividualRankings(competitionId);

  @override
  Future<List<RelayRanking>> getRelayRankings(int competitionId) =>
      _dataSource.getRelayRankings(competitionId);
}
```

- [ ] **Step 4: Run the tests to verify they PASS**

Run: `flutter test test/data/repositories/ranking_repository_test.dart`

Expected: PASS — all 4 tests green.

- [ ] **Step 5: Verify analyzer passes**

Run: `flutter analyze lib/app/data/repositories/ranking_repository.dart test/data/repositories/ranking_repository_test.dart`

Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add lib/app/data/repositories/ranking_repository.dart test/data/repositories/ranking_repository_test.dart
git commit -m "feat(data): add RankingRepository with passthrough impl + tests"
```

---

## Task 5: Register RankingRepository in InitialBinding

**Files:**
- Modify: `lib/app/core/di/initial_binding.dart`

- [ ] **Step 1: Add the imports**

In `lib/app/core/di/initial_binding.dart`, add these two imports alphabetically among the existing data layer imports:

```dart
import 'package:live_ffss/app/data/datasources/ranking_remote_datasource.dart';
import 'package:live_ffss/app/data/repositories/ranking_repository.dart';
```

- [ ] **Step 2: Register the data source + repository**

In the `register()` method body, after the existing "5e. Result data layer" block (which ends with `Get.put<ResultRepository>(...)`), insert:

```dart
    // 5f. Ranking data layer (stub returning empty lists — see datasource doc)
    Get.put<RankingRemoteDataSource>(
      RankingRemoteDataSourceImpl(),
      permanent: true,
    );
    Get.put<RankingRepository>(
      RankingRepositoryImpl(Get.find<RankingRemoteDataSource>()),
      permanent: true,
    );
```

- [ ] **Step 3: Verify analyzer passes**

Run: `flutter analyze lib/app/core/di/initial_binding.dart`

Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/app/core/di/initial_binding.dart
git commit -m "feat(di): register RankingRepository in InitialBinding"
```

---

## Task 6: CompetitionDetailPointsController + tests

**Files:**
- Create: `test/presentation/modules/competitions/controllers/competition_detail_points_controller_test.dart`
- Create: `lib/app/module/competitions/controllers/competition_detail_points_controller.dart`

- [ ] **Step 1: Write the failing tests**

Create `test/presentation/modules/competitions/controllers/competition_detail_points_controller_test.dart` with this EXACT content:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/ranking_repository.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/club_ranking.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/individual_ranking.dart';
import 'package:live_ffss/app/domain/models/relay_ranking.dart';
import 'package:live_ffss/app/module/competitions/controllers/competition_detail_points_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements RankingRepository {}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    Get.testMode = true;
  });

  Competition competitionFixture(int id) => Competition(
        id: id,
        name: 'C$id',
        beginDate: null,
        endDate: null,
        location: null,
        statusCode: 0,
        statusLabel: '',
        speciality: 0,
        specialityLabel: '',
        typeWater: 'N/A',
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

  late _MockRepo repo;
  late CompetitionDetailPointsController controller;

  setUp(() {
    repo = _MockRepo();
    when(() => repo.getClubRankings(any()))
        .thenAnswer((_) async => const <ClubRanking>[]);
    when(() => repo.getIndividualRankings(any()))
        .thenAnswer((_) async => const <IndividualRanking>[]);
    when(() => repo.getRelayRankings(any()))
        .thenAnswer((_) async => const <RelayRanking>[]);
    controller = CompetitionDetailPointsController(repo);
  });

  tearDown(() {
    Get.reset();
  });

  group('selectedPointsTab', () {
    test('starts at 0', () {
      expect(controller.selectedPointsTab.value, 0);
    });

    test('setPointsTab updates the value', () {
      controller.setPointsTab(2);
      expect(controller.selectedPointsTab.value, 2);
      controller.setPointsTab(0);
      expect(controller.selectedPointsTab.value, 0);
    });
  });

  group('loadRankings', () {
    test('populates all three RxList fields and clears flags', () async {
      when(() => repo.getClubRankings(any())).thenAnswer((_) async => const [
            ClubRanking(position: 1, clubName: 'Alpha', points: 100),
          ]);
      when(() => repo.getIndividualRankings(any()))
          .thenAnswer((_) async => const [
                IndividualRanking(
                  position: 1,
                  athleteFirstName: 'Alice',
                  athleteLastName: 'Doe',
                  clubName: 'Alpha',
                  points: 200,
                ),
              ]);
      when(() => repo.getRelayRankings(any())).thenAnswer((_) async => const [
            RelayRanking(
              position: 1,
              clubName: 'Alpha',
              teamName: 'A1',
              points: 150,
            ),
          ]);

      await controller.loadRankings(42);

      expect(controller.clubRankings, hasLength(1));
      expect(controller.individualRankings, hasLength(1));
      expect(controller.relayRankings, hasLength(1));
      expect(controller.isLoading.value, false);
      expect(controller.hasError.value, false);
    });

    test('on AppException sets hasError and clears loading', () async {
      when(() => repo.getClubRankings(any()))
          .thenThrow(const NetworkException('offline'));

      await controller.loadRankings(42);

      expect(controller.hasError.value, true);
      expect(controller.isLoading.value, false);
    });
  });

  group('onInit', () {
    test('does NOT load when Get.arguments is not a Competition', () {
      controller.onInit();

      verifyNever(() => repo.getClubRankings(any()));
      expect(controller.competition.value, isNull);
    });
  });

  group('retry', () {
    test('re-runs loadRankings using the stored competition id', () async {
      controller.competition.value = competitionFixture(99);

      await controller.retry();

      verify(() => repo.getClubRankings(99)).called(1);
      verify(() => repo.getIndividualRankings(99)).called(1);
      verify(() => repo.getRelayRankings(99)).called(1);
    });

    test('is a no-op when competition is null', () async {
      await controller.retry();

      verifyNever(() => repo.getClubRankings(any()));
    });
  });
}
```

- [ ] **Step 2: Run the tests to verify they FAIL**

Run: `flutter test test/presentation/modules/competitions/controllers/competition_detail_points_controller_test.dart`

Expected: FAIL — `Target of URI doesn't exist: 'package:live_ffss/app/module/competitions/controllers/competition_detail_points_controller.dart'`

- [ ] **Step 3: Write the controller**

Create `lib/app/module/competitions/controllers/competition_detail_points_controller.dart` with this EXACT content:

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/ranking_repository.dart';
import 'package:live_ffss/app/domain/models/club_ranking.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/individual_ranking.dart';
import 'package:live_ffss/app/domain/models/relay_ranking.dart';

class CompetitionDetailPointsController extends GetxController {
  CompetitionDetailPointsController(this._rankingRepo);

  final RankingRepository _rankingRepo;

  final Rxn<Competition> competition = Rxn<Competition>();
  final RxInt selectedPointsTab = 0.obs;
  final RxList<ClubRanking> clubRankings = <ClubRanking>[].obs;
  final RxList<IndividualRanking> individualRankings =
      <IndividualRanking>[].obs;
  final RxList<RelayRanking> relayRankings = <RelayRanking>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;

  void setPointsTab(int index) => selectedPointsTab.value = index;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is Competition) {
      competition.value = arg;
      loadRankings(arg.id);
    }
  }

  Future<void> loadRankings(int competitionId) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      final results = await Future.wait([
        _rankingRepo.getClubRankings(competitionId),
        _rankingRepo.getIndividualRankings(competitionId),
        _rankingRepo.getRelayRankings(competitionId),
      ]);
      clubRankings.value = results[0] as List<ClubRanking>;
      individualRankings.value = results[1] as List<IndividualRanking>;
      relayRankings.value = results[2] as List<RelayRanking>;
    } on AppException {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> retry() async {
    final id = competition.value?.id;
    if (id != null) await loadRankings(id);
  }
}
```

- [ ] **Step 4: Run the tests to verify they PASS**

Run: `flutter test test/presentation/modules/competitions/controllers/competition_detail_points_controller_test.dart`

Expected: PASS — all 7 tests green.

- [ ] **Step 5: Verify analyzer passes**

Run: `flutter analyze lib/app/module/competitions/controllers/competition_detail_points_controller.dart test/presentation/modules/competitions/controllers/competition_detail_points_controller_test.dart`

Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add lib/app/module/competitions/controllers/competition_detail_points_controller.dart test/presentation/modules/competitions/controllers/competition_detail_points_controller_test.dart
git commit -m "feat(competitions): add CompetitionDetailPointsController + tests"
```

---

## Task 7: Refresh CompetitionDetailController (drop dead deps + add favorite passthrough)

**Files:**
- Modify: `lib/app/module/competitions/controllers/competition_detail_controller.dart`
- Modify: `lib/app/module/competitions/bindings/competition_detail_binding.dart`

This task removes `clubRankingsLimited` (always-empty placeholder), `LanguageService` dependency (no consumers — verified by grep), and adds `UserPreferencesService` for favorite pass-through used by the new header. Also registers the new `CompetitionDetailPointsController` in the binding.

- [ ] **Step 1: Rewrite the controller**

Overwrite `lib/app/module/competitions/controllers/competition_detail_controller.dart` with this EXACT content:

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/data/services/user_preferences_service.dart';
import 'package:live_ffss/app/domain/models/competition.dart';

class CompetitionDetailController extends GetxController {
  CompetitionDetailController(this._prefs);

  final UserPreferencesService _prefs;

  final Rxn<Competition> competition = Rxn<Competition>();
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

  RxSet<int> get favoriteIds => _prefs.favoriteIds;
  Future<void> toggleFavorite(int id) => _prefs.toggleFavorite(id);

  void changeTab(int index) {
    currentTabIndex.value = index;
  }
}
```

Note: `clubRankingsLimited`, `currentLanguage`, `isFrench`, `isEnglish`, `refreshData` are all dropped. Grep confirmed no callers of these members in `lib/` outside the controller and the soon-to-be-deleted home view.

- [ ] **Step 2: Update the binding**

Overwrite `lib/app/module/competitions/bindings/competition_detail_binding.dart` with this EXACT content:

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/data/repositories/ranking_repository.dart';
import 'package:live_ffss/app/data/services/user_preferences_service.dart';
import '../controllers/competition_detail_clubs_controller.dart';
import '../controllers/competition_detail_controller.dart';
import '../controllers/competition_detail_points_controller.dart';
import '../controllers/competition_detail_races_controller.dart';

class CompetitionDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompetitionDetailController>(
      () => CompetitionDetailController(Get.find<UserPreferencesService>()),
    );
    Get.lazyPut<CompetitionDetailRacesController>(
      () => CompetitionDetailRacesController(Get.find<RaceRepository>()),
    );
    Get.lazyPut<CompetitionDetailClubsController>(
      () => CompetitionDetailClubsController(Get.find<ClubRepository>()),
    );
    Get.lazyPut<CompetitionDetailPointsController>(
      () => CompetitionDetailPointsController(Get.find<RankingRepository>()),
    );
  }
}
```

- [ ] **Step 3: Verify analyzer passes**

Run: `flutter analyze lib/app/module/competitions/controllers/competition_detail_controller.dart lib/app/module/competitions/bindings/competition_detail_binding.dart`

Expected: `No issues found!`

(The view `competition_detail_view.dart` still references the old controller members and `competition_detail_home_view.dart` still imports the controller. The analyzer will flag these — they're fixed in Task 8 and Task 9. For now scope the analyzer command to just the two files in this task.)

- [ ] **Step 4: Commit**

```bash
git add lib/app/module/competitions/controllers/competition_detail_controller.dart lib/app/module/competitions/bindings/competition_detail_binding.dart
git commit -m "refactor(competitions): drop dead deps, add favorite passthrough to controller"
```

---

## Task 8: Build CompetitionDetailPointsView

**Files:**
- Create: `lib/app/module/competitions/views/competition_detail_points_view.dart`

- [ ] **Step 1: Create the view**

Create `lib/app/module/competitions/views/competition_detail_points_view.dart` with this EXACT content:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/module/competitions/controllers/competition_detail_points_controller.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';
import 'package:live_ffss/app/presentation/shared/error_state.dart';
import 'package:live_ffss/app/presentation/shared/loading_indicator.dart';

class CompetitionDetailPointsView
    extends GetView<CompetitionDetailPointsController> {
  const CompetitionDetailPointsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.md),
        const _PointsPillsRow(),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const LoadingIndicator();
            }
            if (controller.hasError.value) {
              return ErrorState(
                message: 'error_occured'.tr,
                onRetry: controller.retry,
              );
            }
            return IndexedStack(
              index: controller.selectedPointsTab.value,
              children: const [
                _ClubsRankingTab(),
                _IndividualRankingTab(),
                _RelaisRankingTab(),
              ],
            );
          }),
        ),
      ],
    );
  }
}

class _PointsPillsRow extends GetView<CompetitionDetailPointsController> {
  const _PointsPillsRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.pageHorizontal,
      child: Row(
        children: [
          _PointsPill(label: 'clubs_ranking'.tr, index: 0),
          const SizedBox(width: AppSpacing.sm),
          _PointsPill(label: 'individual_ranking'.tr, index: 1),
          const SizedBox(width: AppSpacing.sm),
          _PointsPill(label: 'relais_ranking'.tr, index: 2),
        ],
      ),
    );
  }
}

class _PointsPill extends GetView<CompetitionDetailPointsController> {
  const _PointsPill({required this.label, required this.index});

  final String label;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final active = controller.selectedPointsTab.value == index;
      return GestureDetector(
        onTap: () => controller.setPointsTab(index),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.white,
            borderRadius: AppRadius.pillRadius,
            border: Border.all(color: AppColors.primary),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      );
    });
  }
}

class _ClubsRankingTab extends GetView<CompetitionDetailPointsController> {
  const _ClubsRankingTab();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.clubRankings;
      if (items.isEmpty) {
        return EmptyState(
          icon: Icons.emoji_events_outlined,
          title: 'no_rankings_yet'.tr,
        );
      }
      return ListView.separated(
        padding: AppSpacing.pageHorizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, i) {
          final r = items[i];
          return _RankingRow(
            position: r.position,
            primary: r.clubName,
            secondary: '',
            points: r.points,
          );
        },
      );
    });
  }
}

class _IndividualRankingTab
    extends GetView<CompetitionDetailPointsController> {
  const _IndividualRankingTab();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.individualRankings;
      if (items.isEmpty) {
        return EmptyState(
          icon: Icons.person_outline,
          title: 'no_individual_ranking_yet'.tr,
        );
      }
      return ListView.separated(
        padding: AppSpacing.pageHorizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, i) {
          final r = items[i];
          return _RankingRow(
            position: r.position,
            primary: '${r.athleteFirstName} ${r.athleteLastName}',
            secondary: r.clubName,
            points: r.points,
          );
        },
      );
    });
  }
}

class _RelaisRankingTab extends GetView<CompetitionDetailPointsController> {
  const _RelaisRankingTab();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.relayRankings;
      if (items.isEmpty) {
        return EmptyState(
          icon: Icons.groups_outlined,
          title: 'no_relais_ranking_yet'.tr,
        );
      }
      return ListView.separated(
        padding: AppSpacing.pageHorizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, i) {
          final r = items[i];
          return _RankingRow(
            position: r.position,
            primary: r.teamName,
            secondary: r.clubName,
            points: r.points,
          );
        },
      );
    });
  }
}

class _RankingRow extends StatelessWidget {
  const _RankingRow({
    required this.position,
    required this.primary,
    required this.secondary,
    required this.points,
  });

  final int position;
  final String primary;
  final String secondary;
  final int points;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: AppRadius.smRadius,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '$position',
              style: AppTypography.title.copyWith(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  primary,
                  style: AppTypography.title.copyWith(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (secondary.isNotEmpty)
                  Text(
                    secondary,
                    style: AppTypography.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '$points',
            style: AppTypography.title.copyWith(
              fontSize: 14,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Verify analyzer passes**

Run: `flutter analyze lib/app/module/competitions/views/competition_detail_points_view.dart`

Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/app/module/competitions/views/competition_detail_points_view.dart
git commit -m "feat(competitions): add CompetitionDetailPointsView with 3 sub-tabs"
```

---

## Task 9: Refresh CompetitionDetailClubsView (visual rework)

**Files:**
- Modify: `lib/app/module/competitions/views/competition_detail_clubs_view.dart`

Same controller, same data flow, refreshed visuals using design tokens. Replaces `Card`+`elevation`, hardcoded `Colors.blue/green/orange`, and `withOpacity` calls. Reuses shared `LoadingIndicator` / `ErrorState` / `EmptyState` widgets.

- [ ] **Step 1: Overwrite the file**

Replace the entire contents of `lib/app/module/competitions/views/competition_detail_clubs_view.dart` with this EXACT content:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/referee.dart';
import 'package:live_ffss/app/module/competitions/controllers/competition_detail_clubs_controller.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';
import 'package:live_ffss/app/presentation/shared/error_state.dart';
import 'package:live_ffss/app/presentation/shared/loading_indicator.dart';

class CompetitionDetailClubsView
    extends GetView<CompetitionDetailClubsController> {
  const CompetitionDetailClubsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const LoadingIndicator();
      }
      if (controller.hasError.value) {
        return ErrorState(
          message: 'error_occured'.tr,
          onRetry: () =>
              controller.loadClubs(controller.competition.value?.id ?? 0),
        );
      }
      if (controller.filteredClubs.isEmpty) {
        return EmptyState(
          icon: Icons.group_off,
          title: 'no_clubs_found'.tr,
        );
      }
      return RefreshIndicator(
        onRefresh: () =>
            controller.loadClubs(controller.competition.value?.id ?? 0),
        child: ListView.separated(
          padding: AppSpacing.pageHorizontal,
          itemCount: controller.filteredClubs.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (_, i) => _ClubCard(club: controller.filteredClubs[i]),
        ),
      );
    });
  }
}

class _ClubCard extends StatelessWidget {
  const _ClubCard({required this.club});

  final Club club;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: AppRadius.smRadius,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          childrenPadding: const EdgeInsets.only(bottom: AppSpacing.sm),
          leading: _ClubThumbnail(club: club),
          title: Text(
            club.name,
            style: AppTypography.title.copyWith(fontSize: 14),
          ),
          subtitle: Text(
            'athletes_and_referees'.trParams({
              'athleteCount': '${club.athletes.length}',
              'refereeCount': '${club.referees.length}',
            }),
            style: AppTypography.caption,
          ),
          children: [
            if (club.athletes.isNotEmpty) ...[
              const _SectionLabel(
                label: 'athletes_upper',
                color: AppColors.statusFinished,
              ),
              ...club.athletes.map(_AthleteTile.new),
            ],
            if (club.referees.isNotEmpty) ...[
              const _SectionLabel(
                label: 'referees_upper',
                color: AppColors.statusWaiting,
              ),
              ...club.referees.map(_RefereeTile.new),
            ],
          ],
        ),
      ),
    );
  }
}

class _ClubThumbnail extends StatelessWidget {
  const _ClubThumbnail({required this.club});

  final Club club;

  @override
  Widget build(BuildContext context) {
    final logoUrl = club.logoUrl;
    if (logoUrl == null || logoUrl.isEmpty) {
      return _ClubThumbnailFallback();
    }
    return ClipRRect(
      borderRadius: AppRadius.smRadius,
      child: Image.network(
        logoUrl,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _ClubThumbnailFallback(),
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : _ClubThumbnailFallback(),
      ),
    );
  }
}

class _ClubThumbnailFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadius.smRadius,
      ),
      child: const Icon(
        Icons.groups,
        color: AppColors.primary,
        size: 24,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label.tr,
          style: AppTypography.caption.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _AthleteTile extends StatelessWidget {
  const _AthleteTile(this.athlete);

  final Athlete athlete;

  @override
  Widget build(BuildContext context) {
    return _LicenseeRow(
      icon: Icons.pool,
      iconColor: AppColors.statusFinished,
      name: '${athlete.firstName} ${athlete.lastName}',
      badgeLabel: 'athlete_upper',
    );
  }
}

class _RefereeTile extends StatelessWidget {
  const _RefereeTile(this.referee);

  final Referee referee;

  @override
  Widget build(BuildContext context) {
    return _LicenseeRow(
      icon: Icons.sports_score,
      iconColor: AppColors.statusWaiting,
      name: '${referee.firstName} ${referee.lastName} (${referee.level})',
      badgeLabel: 'referee_upper',
    );
  }
}

class _LicenseeRow extends StatelessWidget {
  const _LicenseeRow({
    required this.icon,
    required this.iconColor,
    required this.name,
    required this.badgeLabel,
  });

  final IconData icon;
  final Color iconColor;
  final String name;
  final String badgeLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: AppRadius.smRadius,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              name,
              style: AppTypography.body.copyWith(fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: AppRadius.pillRadius,
              border: Border.all(color: iconColor),
            ),
            child: Text(
              badgeLabel.tr,
              style: AppTypography.badge.copyWith(
                color: iconColor,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Verify analyzer passes**

Run: `flutter analyze lib/app/module/competitions/views/competition_detail_clubs_view.dart`

Expected: `No issues found!` (the four `withOpacity` deprecation warnings on lines 156/180/204/228 of the original are gone — the new file uses `withValues(alpha: ...)` instead).

- [ ] **Step 3: Run existing controller tests to confirm no regression**

Run: `flutter test test/presentation/modules/competitions/`

Expected: all existing tests pass (controller logic untouched).

- [ ] **Step 4: Commit**

```bash
git add lib/app/module/competitions/views/competition_detail_clubs_view.dart
git commit -m "refactor(competitions): refresh ClubsView visuals to use design tokens"
```

---

## Task 10: Rewrite CompetitionDetailView + delete home view

**Files:**
- Modify: `lib/app/module/competitions/views/competition_detail_view.dart` (full rewrite)
- Delete: `lib/app/module/competitions/views/competition_detail_home_view.dart`

This is the biggest task — replaces the white-AppBar + 5-tab bottom nav with the new blue header + wave + 3 pills + IndexedStack. The old `competition_detail_home_view.dart` becomes unused after this rewrite (Task 7 already dropped its `clubRankingsLimited` source) and is deleted.

- [ ] **Step 1: Overwrite competition_detail_view.dart**

Replace the entire contents of `lib/app/module/competitions/views/competition_detail_view.dart` with this EXACT content:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/module/competitions/controllers/competition_detail_controller.dart';
import 'package:live_ffss/app/module/competitions/views/competition_detail_clubs_view.dart';
import 'package:live_ffss/app/module/competitions/views/competition_detail_points_view.dart';
import 'package:live_ffss/app/module/competitions/views/competition_detail_races_view.dart';
import 'package:live_ffss/app/presentation/modules/competitions/competition_formatting.dart';
import 'package:live_ffss/app/presentation/shared/home_wave.dart';

class CompetitionDetailView extends GetView<CompetitionDetailController> {
  const CompetitionDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          final competition = controller.competition.value;
          if (competition == null) {
            return Center(
              child: Text(
                'no_competition_selected'.tr,
                style: AppTypography.subtitle,
              ),
            );
          }
          return Column(
            children: [
              _CompetitionDetailHeader(competition: competition),
              const HomeWave(),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: Obx(() => IndexedStack(
                      index: controller.currentTabIndex.value,
                      children: const [
                        CompetitionDetailRacesView(),
                        CompetitionDetailClubsView(),
                        CompetitionDetailPointsView(),
                      ],
                    )),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _CompetitionDetailHeader extends GetView<CompetitionDetailController> {
  const _CompetitionDetailHeader({required this.competition});

  final Competition competition;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.lg,
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: Get.back,
              ),
              const Spacer(),
              Obx(() {
                final favored =
                    controller.favoriteIds.contains(competition.id);
                return IconButton(
                  icon: Icon(
                    favored ? Icons.star : Icons.star_border,
                    color: favored ? AppColors.statusWaiting : Colors.white,
                    size: 28,
                  ),
                  onPressed: () => controller.toggleFavorite(competition.id),
                );
              }),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _HeaderThumbnail(competition: competition),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        competition.name,
                        style: AppTypography.title.copyWith(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        competition.formattedDateRange,
                        style: AppTypography.body.copyWith(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '🇫🇷 ${competition.location ?? 'no_location'.tr}',
                        style: AppTypography.caption.copyWith(
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: AppSpacing.pageHorizontal,
            child: Row(
              children: [
                _DetailPill(label: 'events'.tr, index: 0),
                const SizedBox(width: AppSpacing.sm),
                _DetailPill(label: 'clubs'.tr, index: 1),
                const SizedBox(width: AppSpacing.sm),
                _DetailPill(label: 'points'.tr, index: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderThumbnail extends StatelessWidget {
  const _HeaderThumbnail({required this.competition});

  final Competition competition;

  @override
  Widget build(BuildContext context) {
    final logoUrl = competition.organizerClub.logoUrl;
    if (logoUrl == null || logoUrl.isEmpty) {
      return _HeaderDateBlock(competition: competition);
    }
    return ClipRRect(
      borderRadius: AppRadius.smRadius,
      child: Image.network(
        logoUrl,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            _HeaderDateBlock(competition: competition),
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : _HeaderDateBlock(competition: competition),
      ),
    );
  }
}

class _HeaderDateBlock extends StatelessWidget {
  const _HeaderDateBlock({required this.competition});

  final Competition competition;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.smRadius,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            competition.formattedBeginDateMonth,
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Text(
            competition.formattedDayBeginDate,
            style: AppTypography.title.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailPill extends GetView<CompetitionDetailController> {
  const _DetailPill({required this.label, required this.index});

  final String label;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final active = controller.currentTabIndex.value == index;
      return GestureDetector(
        onTap: () => controller.changeTab(index),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.statusWaiting : Colors.transparent,
            borderRadius: AppRadius.pillRadius,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? AppColors.textPrimary : Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      );
    });
  }
}
```

- [ ] **Step 2: Delete the placeholder home view**

Delete `lib/app/module/competitions/views/competition_detail_home_view.dart`. (Grep confirmed only `competition_detail_view.dart` referenced it; the rewrite above does not import it.)

```bash
git rm lib/app/module/competitions/views/competition_detail_home_view.dart
```

- [ ] **Step 3: Verify analyzer passes**

Run: `flutter analyze lib/app/module/competitions/`

Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/app/module/competitions/views/competition_detail_view.dart
git commit -m "refactor(competitions): rewrite CompetitionDetailView with 3-pill header"
```

(`git rm` from Step 2 was already staged, so it lands in the same commit.)

---

## Task 11: Drop ProgramBinding from competitionDetail route

**Files:**
- Modify: `lib/app/routes/app_pages.dart`

The `Routes.program` route + its `ProgramBinding` stays for any external link to the Program view; only the embedded use inside `CompetitionDetailView` goes away. This task removes the no-longer-needed `ProgramBinding()` from the `competitionDetail` route's bindings stack.

- [ ] **Step 1: Update the route**

In `lib/app/routes/app_pages.dart`, find the `Routes.competitionDetail` `GetPage` block. The current version is:

```dart
    GetPage(
      name: Routes.competitionDetail,
      page: () => const CompetitionDetailView(),
      bindings: [
        CompetitionDetailBinding(),
        ProgramBinding(), // Ensure ProgramBinding is included if needed
      ],
    ),
```

Change it to:

```dart
    GetPage(
      name: Routes.competitionDetail,
      page: () => const CompetitionDetailView(),
      binding: CompetitionDetailBinding(),
    ),
```

(Use `binding:` singular since there's now only one binding. Drop the inline comment about ProgramBinding — no longer accurate.)

- [ ] **Step 2: Check if ProgramBinding import is still needed**

The `Routes.program` page below in the same file still uses `binding: ProgramBinding()`. So the `ProgramBinding` import stays. Leave it alone.

- [ ] **Step 3: Verify analyzer passes**

Run: `flutter analyze lib/app/routes/`

Expected: `No issues found!`

- [ ] **Step 4: Run the full test suite**

Run: `flutter test`

Expected: all tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/app/routes/app_pages.dart
git commit -m "refactor(routes): drop ProgramBinding from competitionDetail route"
```

---

## Task 12: Whole-repo verification

**Files:** none (verification only)

- [ ] **Step 1: Whole-repo analyzer**

Run: `flutter analyze lib/ test/`

Expected: a finite count of pre-existing info issues only (mostly `withOpacity` deprecations in OTHER files — `slot_view.dart`, `program_view.dart`, etc.). The `competition_detail_clubs_view.dart` warnings (originally lines 156/180/204/228) should be GONE. NO new errors or new warnings introduced by this work.

- [ ] **Step 2: Whole-repo test suite**

Run: `flutter test`

Expected: all tests pass. Report the count (should be 168 baseline + 4 new repo tests + 7 new controller tests = ~179).

- [ ] **Step 3: No commit**

This task is verification only.

---

## Task 13: Manual smoke test (handoff to user)

**Files:** none — manual verification on a device.

There are no widget tests in this codebase per CLAUDE.md, so the redesign needs human eyes on a real device before shipping.

Run: `flutter run` from `c:\Users\nast0\Git\LiveFFSS\live_ffss` against an emulator or connected device.

- [ ] **Step 1: Smoke test — Évènements pill (default)**

- [ ] App opens at home, tap any competition card — competition detail opens.
- [ ] Header shows: back arrow (top-left, white), favorite star (top-right), organizer logo (or fallback date block) on left, name/dates/location column on right, three pills below (Évènements active, Clubs / Points inactive).
- [ ] Wave decoration appears below the header.
- [ ] Body shows the existing races list with filter pills (All / Beach / Swimming).
- [ ] Tap back arrow — returns to home with state preserved.

- [ ] **Step 2: Smoke test — Clubs pill**

- [ ] Tap "Clubs" pill — pill becomes yellow, body switches to clubs list.
- [ ] Each club row uses flat border + rounded corners (no Material elevation/Card shadow). Logo or fallback group icon on left.
- [ ] Tap a row to expand — athletes section (green badge) and referees section (orange badge) appear.
- [ ] Pull down to refresh — refresh indicator triggers `loadClubs`.

- [ ] **Step 3: Smoke test — Points pill**

- [ ] Tap "Points" pill — pill becomes yellow, body switches to Points view with 3 sub-pills (Clubs / Individuel / Relais).
- [ ] All three sub-tabs render the EmptyState (no rankings yet) — that's expected since the backend stub returns empty lists.
- [ ] Sub-pill tapping correctly switches between the three sub-views.

- [ ] **Step 4: Smoke test — Favorite from header**

- [ ] Tap the star in the header — icon fills with gold.
- [ ] Tap back to home — the same competition's star icon in the home list is also filled (shared `UserPreferencesService`).
- [ ] Reopen the same competition — header star is still gold.
- [ ] Tap star again — icon empties; home list reflects this.

- [ ] **Step 5: Smoke test — Language switch**

- [ ] Switch language from the home tab header (FR ↔ EN).
- [ ] Reopen a competition — the three pills now read "Events / Clubs / Points" or "Évènements / Clubs / Points" depending on locale.

- [ ] **Step 6: Smoke test — Edge cases**

- [ ] Tap a competition whose organizer has no logo — the fallback date block (white box with month + day in primary color) shows in the header thumbnail position.
- [ ] On a narrow phone, the three header pills may overflow — confirm they scroll horizontally cleanly.

If any check fails, file the issue and fix before shipping. If they all pass, the redesign is ready to merge.

---

## Done

After all tasks complete, the deliverable is:
- 3-pill competition detail page with home_view visual language.
- Évènements (existing races content), Clubs (refreshed visuals), Points (3 sub-tabs).
- Typed `RankingRepository` seam ready for the FFSS backend (4 new repo tests).
- New `CompetitionDetailPointsController` with full state coverage (7 new controller tests).
- 4 deprecation warnings (`withOpacity` in clubs view) eliminated.
- Favorite toggle from the detail header reflects on the home list.
- The placeholder `competition_detail_home_view.dart` is gone.
