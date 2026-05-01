# Bottom Navigation + Favorites Tab — Design

**Date:** 2026-05-01
**Status:** Approved (pending spec review)

## Goal

Add a bottom navigation bar to the home screen with two tabs: **Home** (the
existing view, unchanged) and **Favorites** (a new view listing competitions
the user has marked as favorites).

## Context

Favorites infrastructure already exists end-to-end:

- `UserPreferencesService` persists `favoriteIds` (`RxSet<int>`) to secure
  storage and exposes `toggleFavorite(int id)`.
- `HomeController` exposes `favoriteIds`, `isFavorite`, `toggleFavorite`.
- The star button on each competition card in `HomeView`
  (`_CardTrailing`) already toggles favorites and reflects the favored state.

What's missing is a way to see the favorited list as its own screen. This
spec adds the navigation surface and the new screen.

## Architecture

A thin shell, `MainShellView`, becomes the new target for `Routes.home`. It owns:

- `MainShellController` with `RxInt selectedIndex = 0.obs` and a
  `setIndex(int)` mutator.
- A `Scaffold` whose `body` is an `IndexedStack` with two children:
  `HomeView()` and `FavoritesView()`.
- A `BottomNavigationBar` with two items: Home (`Icons.home`) and Favorites
  (`Icons.star`).

`IndexedStack` keeps both subtrees alive so `HomeController` state (filters,
search query, scroll position) survives tab switches and the Favorites tab
doesn't rebuild every time the user returns to it.

`HomeView`'s outer structure (its `Scaffold`, `SafeArea(bottom: false)`,
hero, filters, search, list) is unchanged. It nests inside the shell's
`Scaffold` — two nested `Scaffold`s are valid in Flutter; the inner one
ignores `bottomNavigationBar`. The only edit inside `HomeView` is swapping
the inline private `_CompetitionCard` for the extracted shared
`CompetitionCard` (see CompetitionCard extraction below).

The bottom nav is only visible on the shell's tabs. Pushing
`competitionDetail`, `slot`, etc. via `Get.toNamed` opens a full-screen
route on top, naturally hiding the nav.

## Components

### New files

- `lib/app/module/main_shell/controllers/main_shell_controller.dart` —
  `RxInt selectedIndex`, `void setIndex(int)`.
- `lib/app/module/main_shell/bindings/main_shell_binding.dart` — registers
  `MainShellController`, `HomeController`, and `FavoritesController` so both
  `IndexedStack` children find their controllers when first built.
- `lib/app/module/main_shell/views/main_shell_view.dart` — `Scaffold` with
  `IndexedStack` body and `BottomNavigationBar`.
- `lib/app/module/favorites/controllers/favorites_controller.dart` — see
  Data Wiring below.
- `lib/app/module/favorites/bindings/favorites_binding.dart` — registers
  `FavoritesController`.
- `lib/app/module/favorites/views/favorites_view.dart` — see UI below.
- `lib/app/presentation/shared/competition_card.dart` — extracted from
  `home_view.dart`. Controller-agnostic; takes callbacks/values for
  favorite state and tap handling.

### Modified files

- `lib/app/routes/app_pages.dart` — `Routes.home` page →
  `const MainShellView()`, with `bindings: [MainShellBinding(), UserBinding()]`.
  `UserBinding` stays because `UserAvatar` still lives inside `HomeView`'s hero.
- `lib/app/module/home/views/home_view.dart` — replace inline
  `_CompetitionCard` (and its `_CardThumbnail` / `_DateBlock` / `_CardBody` /
  `_CardTrailing`) with use of the extracted shared `CompetitionCard`. The
  rest of the file is unchanged.
- `lib/app/core/translations/en_US.dart` + `fr_FR.dart` — add keys:
  - `'favorites'` → `"Favorites"` / `"Favoris"`
  - `'no_favorites_yet'` → `"You haven't favorited any competition yet"` /
    `"Vous n'avez encore mis aucune compétition en favori"`
  - The `'home'` key already exists in both files.

## Data Wiring (Favorites pulls from HomeController — Option C)

Favorites are stored as IDs only. To render cards we need full `Competition`
objects. The chosen approach reuses `HomeController.competitions` as the
lookup source AND triggers a load if Home hasn't yet loaded:

```dart
class FavoritesController extends GetxController {
  FavoritesController(this._homeController, this._prefs);

  final HomeController _homeController;
  final UserPreferencesService _prefs;

  List<Competition> get favoriteCompetitions {
    final ids = _prefs.favoriteIds;
    return _homeController.competitions
        .where((c) => ids.contains(c.id))
        .toList();
  }

  RxBool get isLoading => _homeController.isLoading;
  RxBool get hasError => _homeController.hasError;

  @override
  void onInit() {
    super.onInit();
    if (_homeController.competitions.isEmpty &&
        !_homeController.isLoading.value &&
        !_homeController.hasError.value) {
      _homeController.loadCompetitions();
    }
  }

  Future<void> retry() => _homeController.loadCompetitions();
  Future<void> toggleFavorite(int id) => _prefs.toggleFavorite(id);
  void navigateToCompetitionDetails(Competition c) =>
      _homeController.navigateToCompetitionDetails(c);
}
```

`favoriteCompetitions` is a getter, not an `Rx`. The view wraps the list in
`Obx`, which auto-tracks `_prefs.favoriteIds` and `_homeController.competitions`
because both are read inside the Obx scope. No manual listeners needed.

This couples Favorites to HomeController, which the codebase generally avoids.
The alternative (duplicating the load) wastes a network call and risks the two
lists drifting. The coupling is contained, one direction, well-named.

## UI: FavoritesView

Layout (top to bottom):

- **Header strip** — `AppColors.primary` background like Home's hero, but
  compact: just centered title `'favorites'.tr` in white. No language
  selector / no avatar (those live on Home). Reuse `_HomeWave` painter
  underneath for visual continuity (extract to shared if needed for a clean
  import).
- **Body** — `Obx` evaluates in this priority order, gating on
  `homeController.competitions.isEmpty` (NOT on
  `favoriteCompetitions.isEmpty`) so a user with zero favorites doesn't see
  spurious loading/error states while home loads:
  1. `LoadingIndicator` when `isLoading.value && competitions.isEmpty`
  2. `ErrorState` (retry → `controller.retry`) when
     `hasError.value && competitions.isEmpty`
  3. `EmptyState(icon: Icons.star_border, title: 'no_favorites_yet'.tr)`
     when `favoriteCompetitions.isEmpty`
  4. `ListView.separated` of `CompetitionCard` widgets otherwise

Rationale: if home has cached competitions but a background refresh fails,
the user still sees their favorites — the error doesn't block the list. If
home has no competitions yet, we show loader/error regardless of favorite
count, since favorites depend on home's data.

## CompetitionCard extraction

The existing private `_CompetitionCard` (and its `_CardThumbnail`,
`_DateBlock`, `_CardBody`, `_CardTrailing`) becomes a public
`CompetitionCard` widget under `lib/app/presentation/shared/`. It takes:

```dart
class CompetitionCard extends StatelessWidget {
  const CompetitionCard({
    required this.competition,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
    super.key,
  });

  final Competition competition;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
}
```

Both `HomeView` and `FavoritesView` import and use it. The favorite-star
`Obx` moves into the card's call site (caller wraps the card in `Obx` so it
re-renders when the favorite state for that id changes).

## Testing

Per CLAUDE.md: controller-level only, no widget tests.

- `test/presentation/modules/favorites/controllers/favorites_controller_test.dart`:
  - `favoriteCompetitions` returns competitions whose ids are in `favoriteIds`
  - returns empty list when no favorites
  - returns empty list when home has no competitions loaded
  - excludes favorited ids that aren't in home's competition list (graceful degrade)
  - `onInit` triggers `loadCompetitions` when home is empty / not loading / not errored
  - `onInit` does NOT trigger load when home is already loading
  - `onInit` does NOT trigger load when home already has competitions
  - `toggleFavorite` delegates to prefs
- `test/presentation/modules/main_shell/controllers/main_shell_controller_test.dart`:
  - `setIndex` updates `selectedIndex`

## Edge cases

- **Favorited competition not in loaded list** (older than
  `getAllCompetitions(visibility: passed)` returns) → silently omitted.
  Documented as a known gap. Matches Option C trade-off.
- **User unfavorites the last item from Favorites view** → list reactively
  shrinks → `EmptyState` shows. No special handling needed.
- **Logout** → `HomeController.refreshAfterLogout` clears `competitions` and
  reloads. Favorites view auto-reflects via Obx.

## Out of scope

- Search / filter on Favorites (Q2 answer: A — minimal list only).
- Material 3 `NavigationBar` (theme is Material 2; using classic
  `BottomNavigationBar` for visual consistency).
- A standalone deep-linkable `/favorites` route. Tab state lives in the
  shell controller.
- Backfilling competitions older than the home list — fix only if it bites.

## Translation keys

Add to both `en_US.dart` and `fr_FR.dart`:

| Key                | English                                          | French                                                          |
|--------------------|--------------------------------------------------|-----------------------------------------------------------------|
| `favorites`        | Favorites                                        | Favoris                                                         |
| `no_favorites_yet` | You haven't favorited any competition yet        | Vous n'avez encore mis aucune compétition en favori             |
