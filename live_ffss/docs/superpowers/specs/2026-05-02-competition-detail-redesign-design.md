# Competition Detail Page Redesign — Design

**Date:** 2026-05-02
**Status:** Approved (pending spec review)

## Goal

Replace the current `competitionDetail` route's white-AppBar + 5-tab
bottom-navigation layout with a 3-pill design that matches the home_view
visual language (blue header + wave). The three pills are **Évènements**,
**Clubs**, and **Points**. Reference visual: Swimify Live screenshot
`Screenshot_20260123_203617_Swimify Live.jpg`.

## Context

Current `CompetitionDetailView`:
- White `AppBar` with the competition name and dates.
- `BottomNavigationBar` with 5 tabs: Home, Races, Program, Rankings, Clubs.
- Home sub-tab shows a placeholder club-rankings table (data is empty —
  `controller.clubRankingsLimited` returns `List.empty()`) plus the embedded
  Races view.
- Rankings tab is unimplemented.
- Visually disagrees with the home_view redesign that just shipped (blue
  header + wave + yellow active pills).

Backend constraint (per CLAUDE.md "Known gaps"):
- FFSS rankings endpoints are not documented. `clubRankingsLimited` is a stub
  returning `List.empty()`. No individual or relay ranking endpoints either.

This redesign matches the new home_view visual language end-to-end and
prepares typed seams for the rankings backend without blocking on it.

## Architecture

`CompetitionDetailView` becomes a `Scaffold` with no `AppBar`, body column =

1. `_CompetitionDetailHeader` (blue strip with back arrow, favorite star,
   organizer logo, name/dates/location, three pills).
2. `HomeWave` (shared widget already in `lib/app/presentation/shared/`).
3. `Expanded(Obx(IndexedStack))` of three children — Évènements / Clubs /
   Points — switched by `controller.currentTabIndex.value`.

The 5-tab `BottomNavigationBar`, the `_buildProgramView` helper, and the
`CompetitionDetailHomeView` placeholder are removed. The `Routes.program`
route + `ProgramBinding` stay registered so the Program view remains
reachable for future integration; only the embed in this page goes away.

`IndexedStack` preserves each child's state when the user switches pills
(matches the home_view + favorites pattern).

## Pill structure

| Index | Pill (FR)   | Content                                                                         |
|-------|-------------|---------------------------------------------------------------------------------|
| 0     | Évènements  | Existing `CompetitionDetailRacesView` content (race list + filter pills)        |
| 1     | Clubs       | Refreshed `CompetitionDetailClubsView` (visual rework, same data + behavior)    |
| 2     | Points      | NEW `CompetitionDetailPointsView` with 3 sub-pills (Clubs/Individuel/Relais)    |

Default tab on entry = Évènements (0). State lives in the existing
`CompetitionDetailController.currentTabIndex` (already present).

The user explicitly answered:
- Q1 → A: Évènements = current Races content (not the Home placeholder).
- Q2 → B: Delete the Home placeholder; keep `Routes.program` reachable.
- Q3 → A: Build Points UI with empty states; wire typed repository seams
  returning empty lists today.
- Q4 → A: Refresh Clubs view to use design tokens.

## Header — `_CompetitionDetailHeader`

Private widget inside `competition_detail_view.dart` (small enough to inline
without its own file). Mirrors the home_view hero pattern:

- Background `AppColors.primary`, padding `EdgeInsets.fromLTRB(md, sm, md, lg)`.
- Top row: white back arrow (`IconButton`, calls `Get.back()`) — `Spacer` —
  `IconButton` with star/star_border (gold = `AppColors.statusWaiting` when
  favorited, white otherwise) wired through `CompetitionDetailController`'s
  new pass-through getter and method (added in this work):
  ```dart
  RxSet<int> get favoriteIds => _prefs.favoriteIds;
  Future<void> toggleFavorite(int id) => _prefs.toggleFavorite(id);
  ```
  This requires adding `UserPreferencesService` as a constructor dependency
  on `CompetitionDetailController` and updating `CompetitionDetailBinding`
  to inject it via `Get.find<UserPreferencesService>()`. The header wraps
  the IconButton in `Obx` so the icon updates reactively when the user
  taps. Reuses the same `UserPreferencesService` already used by the home
  page — favoriting from the detail header reflects on the home list.
- Center row: organizer logo (56×56 `ClipRRect` with `AppRadius.smRadius`,
  fallback = a small date block matching `CompetitionCard._DateBlock`) +
  `Expanded(Column)` with name (`AppTypography.title.copyWith(color: white,
  fontSize: 22)`), formatted date range, and location prefixed with French
  flag emoji (the existing FFSS data is France-only, so we hardcode the flag
  rather than reading it from the API).
- Bottom row: three `_DetailPill` widgets (`Évènements`, `Clubs`, `Points`)
  in a `Row` (or wrapped in `SingleChildScrollView(scrollDirection: horizontal)`
  if the row overflows on narrow screens, matching the Swimify reference).

`_DetailPill` is a small private widget, parallel to `_HeroPill` in
home_view but with yellow-active styling (`AppColors.statusWaiting` background
when active, transparent + white border when inactive) to match the Swimify
reference. The home_view's white-active style is close but not identical;
duplicating ~25 LOC is cheaper than parameterizing.

## Points sub-tabs — `CompetitionDetailPointsView` + controller

New controller `CompetitionDetailPointsController(this._rankingRepo)`:

```dart
class CompetitionDetailPointsController extends GetxController {
  CompetitionDetailPointsController(this._rankingRepo);

  final RankingRepository _rankingRepo;

  final Rxn<Competition> competition = Rxn<Competition>();
  final RxInt selectedPointsTab = 0.obs;
  final RxList<ClubRanking> clubRankings = <ClubRanking>[].obs;
  final RxList<IndividualRanking> individualRankings = <IndividualRanking>[].obs;
  final RxList<RelayRanking> relayRankings = <RelayRanking>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;

  void setPointsTab(int i) => selectedPointsTab.value = i;

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

The controller stores the `Competition` reference (matching the pattern in
`CompetitionDetailClubsController`) so `retry()` can re-trigger the load
without needing the view to thread the id through.

The view: pills row at top (`Clubs` / `Individuel` / `Relais`) using a
private `_PointsPill` (similar style to `_DetailPill` but smaller, since
they're inside the page body, not the header — likely
`AppColors.primary`-active to keep visual hierarchy clear: header pills
yellow, body pills blue), then `Expanded(Obx(IndexedStack))` of three
sub-views. Each sub-view: `Obx`-wrapped switch between `LoadingIndicator` /
`ErrorState` (with retry → `controller.retry`) / `EmptyState` / list. Today
all three render `EmptyState` because the repo returns empty lists.

## Data layer — typed seams for rankings

New domain models (freezed, in `lib/app/domain/models/`):

```dart
// individual_ranking.dart
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

// relay_ranking.dart
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

`ClubRanking` already exists in `lib/app/domain/models/club_ranking.dart` —
no change.

New abstract `RankingRemoteDataSource` + `RankingRemoteDataSourceImpl` in
`lib/app/data/datasources/`. Three methods, each returns `Future<List<XDto>>`.
The `Impl` returns `<>.empty()` today with a `// TODO(post-batch): wire when
FFSS endpoint documented` comment — same pattern as `ResultRemoteDataSource`.

New abstract `RankingRepository` + `RankingRepositoryImpl` in
`lib/app/data/repositories/`. Maps DTOs to domain models via mappers.

DI registration in `InitialBinding` (after `ResultRepository`, slot 5f):

```dart
Get.put<RankingRemoteDataSource>(
  RankingRemoteDataSourceImpl(),  // no HttpClient needed yet
  permanent: true,
);
Get.put<RankingRepository>(
  RankingRepositoryImpl(Get.find<RankingRemoteDataSource>()),
  permanent: true,
);
```

When the FFSS endpoints are documented, only the `Impl` and the DTO classes
change. Domain models, repository interface, controller, view, tests stay.

## Refresh of `CompetitionDetailClubsView`

Same controller (`CompetitionDetailClubsController`), same data flow, new
visuals:

- `Card` + `elevation` → flat container with `Border.all(color: AppColors.border)`
  + `AppRadius.smRadius` (matches `CompetitionCard`).
- `ExpansionTile` stays. Leading `CircleAvatar` becomes a 56×56 thumbnail
  using `ClipRRect` + `AppRadius.smRadius` over `AppColors.surfaceMuted`,
  showing the club logo or fallback group icon.
- Hardcoded colors → design tokens:
  - `Colors.blue` (athlete icon background) → `AppColors.primary`.
  - `Colors.green` (athlete tile) → `AppColors.statusFinished`.
  - `Colors.orange` (referee tile) → `AppColors.statusWaiting`.
- All `withOpacity(...)` → `withValues(alpha: ...)`. Kills the analyzer
  deprecation warnings on lines 156, 180, 204, 228.
- Athlete/referee row: `Row` with thumbnail, name, then a small status pill
  using `AppRadius.pillRadius` styled like `CompetitionCard`'s entry-status
  pill.
- Loading state → shared `LoadingIndicator`.
- Error state → shared `ErrorState` with `onRetry: () =>
  controller.loadClubs(controller.competition.value?.id ?? 0)`.
- Empty state → shared `EmptyState(icon: Icons.group_off, title: 'no_clubs_found'.tr)`.
- `RefreshIndicator` stays (pull-to-refresh).

The unused `_buildAthleteTile`/`_buildRefereeTile` commented-out subtitle
blocks are deleted (license number is currently commented out — leaving
removed).

## File structure

### Create

- `lib/app/domain/models/individual_ranking.dart`
- `lib/app/domain/models/relay_ranking.dart`
- `lib/app/data/datasources/ranking_remote_datasource.dart`
- `lib/app/data/repositories/ranking_repository.dart`
- `lib/app/data/mappers/individual_ranking_mapper.dart` (if a DTO is needed
  separate from the domain model — optional; can also generate domain
  directly until JSON exists)
- `lib/app/data/mappers/relay_ranking_mapper.dart` (same caveat)
- `lib/app/module/competitions/controllers/competition_detail_points_controller.dart`
- `lib/app/module/competitions/views/competition_detail_points_view.dart`
- `test/data/repositories/ranking_repository_test.dart`
- `test/presentation/modules/competitions/controllers/competition_detail_points_controller_test.dart`

### Modify

- `lib/app/module/competitions/views/competition_detail_view.dart` — full
  rewrite (new header, pills, IndexedStack, removed bottom nav).
- `lib/app/module/competitions/views/competition_detail_clubs_view.dart` —
  visual refresh per "Refresh of CompetitionDetailClubsView".
- `lib/app/module/competitions/controllers/competition_detail_controller.dart` —
  drop `clubRankingsLimited`, drop `_languageService` and language getters
  if unused after the rewrite, keep `currentTabIndex` (now 0/1/2 instead of
  0..4).
- `lib/app/module/competitions/bindings/competition_detail_binding.dart` —
  add `CompetitionDetailPointsController` registration. Update
  `CompetitionDetailController` constructor call if `_languageService` was
  dropped.
- `lib/app/routes/app_pages.dart` — drop `ProgramBinding()` from the
  `competitionDetail` route's bindings stack (keeps the standalone
  `Routes.program` route + binding).
- `lib/app/core/di/initial_binding.dart` — register
  `RankingRemoteDataSource` + `RankingRepository` after `ResultRepository`.
- `lib/app/core/translations/en_US.dart` + `fr_FR.dart` — add keys.

### Delete

- `lib/app/module/competitions/views/competition_detail_home_view.dart` —
  the placeholder Home tab is removed entirely.

## Translation keys

Add to both `en_US.dart` and `fr_FR.dart`:

| Key                          | English             | French              |
|------------------------------|---------------------|---------------------|
| `events`                     | Events              | Évènements          |
| `individual_ranking`         | Individual Ranking  | Classement Individuel |
| `relais_ranking`             | Relay Ranking       | Classement Relais   |
| `no_rankings_yet`            | No rankings yet     | Aucun classement    |
| `no_individual_ranking_yet`  | No individual ranking yet | Aucun classement individuel |
| `no_relais_ranking_yet`      | No relay ranking yet | Aucun classement relais |

`clubs`, `clubs_ranking`, `points` keys already exist.

## Testing

Per CLAUDE.md (controller + repo + mapper only, no widget tests):

- `RankingRepositoryImpl` test (`test/data/repositories/ranking_repository_test.dart`):
  - All three methods delegate to the data source and map DTOs to domain.
  - Today the data source returns empty lists; the test verifies the
    contract (mocked data source returns a fixture, repo returns mapped
    domain). When the backend lands the test still works.
- `CompetitionDetailPointsController` test:
  - `selectedPointsTab` starts at 0; `setPointsTab` mutates.
  - `loadRankings` populates all three RxList fields.
  - On `AppException`, `hasError = true` and `isLoading = false`.
  - `onInit` triggers `loadRankings` when `Get.arguments` is a Competition.
- `CompetitionDetailController` already has minimal verification; verify
  `currentTabIndex` starts at 0 and `changeTab(1)`/`changeTab(2)` work.
- No view tests (codebase convention).
- No tests for `CompetitionDetailClubsView` refresh — pure visual change,
  controller logic unchanged.

## Edge cases

- **No organizer logo** → fallback date block (same pattern as
  `CompetitionCard._CardThumbnail`).
- **Pills overflow on narrow screens** → wrap in
  `SingleChildScrollView(scrollDirection: Axis.horizontal)`.
- **Tap Évènements while data is loading** → no-op, the Races view handles
  its own loading state internally.
- **Existing route links to Program** → still work via `Routes.program` +
  `ProgramBinding` (only the embed inside this page goes away).
- **Favorite toggled from header** → reactively updates the star icon AND
  the home page's favorite list (shared `UserPreferencesService`).
- **No rankings data (today's reality)** → all three Points sub-tabs render
  `EmptyState`. No spurious loading spinner — `loadRankings` completes
  immediately because the data source returns synchronously.

## Out of scope

- Wiring real rankings endpoints (Q3 → A: deferred until backend is documented).
- Adding a search bar / filter button on the Clubs or Points tabs (the
  Swimify reference shows them on Swimmers; can be added later).
- Restoring the Program tab into the new pill layout. It stays as an orphan
  route for now.
- Files / Documents tab visible in the Swimify reference (out of scope —
  user asked for 3 pills only).
- Removing the `competition_detail_home_view.dart` import elsewhere — it's
  only referenced by `competition_detail_view.dart`, which is being
  rewritten.
- Adding a SwiperController-like dot-indicator (the Swimify reference shows
  five dots; we render three pills explicitly so dots add no info).

## Known follow-ups (not blocking this work)

- When FFSS rankings endpoints are documented, replace
  `RankingRemoteDataSourceImpl` stub bodies with real HTTP calls. UI, tests,
  and domain models will not need changes.
- The Files / Documents tab from Swimify could be added later if FFSS
  exposes per-competition document URLs.
- Pull-to-refresh on Évènements + Points (Clubs already has it).
