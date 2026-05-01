# Bottom Navigation + Favorites Tab Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a bottom navigation bar to the home screen with two tabs — Home (existing view) and Favorites (new view listing favorited competitions).

**Architecture:** A thin `MainShellView` becomes the new target of `Routes.home`. It owns an `IndexedStack` with `HomeView` and `FavoritesView` children, plus a `BottomNavigationBar`. The existing `_CompetitionCard` and `_HomeWave` widgets get extracted from `home_view.dart` into shared widgets so both tabs can use them.

**Tech Stack:** Flutter 3.22.2 / Dart 3.4.3, GetX (state + routing + DI), mocktail (tests), `flutter_secure_storage` (already wired for favorites).

**Spec:** [docs/superpowers/specs/2026-05-01-bottom-nav-favorites-design.md](../specs/2026-05-01-bottom-nav-favorites-design.md)

---

## File Structure

**Create:**
- `lib/app/presentation/shared/home_wave.dart` — extracted `HomeWave` widget + `WavePainter` (currently private in `home_view.dart`).
- `lib/app/presentation/shared/competition_card.dart` — extracted `CompetitionCard` widget + helpers (currently private `_CompetitionCard` + `_CardThumbnail` + `_DateBlock` + `_CardBody` + `_CardTrailing` in `home_view.dart`). Controller-agnostic — takes callbacks for tap and toggle-favorite, plus a bool for `isFavorite`.
- `lib/app/module/main_shell/controllers/main_shell_controller.dart` — `RxInt selectedIndex`, `void setIndex(int)`.
- `lib/app/module/main_shell/bindings/main_shell_binding.dart` — registers `MainShellController` only.
- `lib/app/module/main_shell/views/main_shell_view.dart` — `Scaffold` with `IndexedStack` body and `BottomNavigationBar`.
- `lib/app/module/favorites/controllers/favorites_controller.dart` — pulls `Competition` objects by filtering `HomeController.competitions` against `UserPreferencesService.favoriteIds`. Triggers `loadCompetitions()` on init if home hasn't loaded.
- `lib/app/module/favorites/bindings/favorites_binding.dart` — registers `FavoritesController`.
- `lib/app/module/favorites/views/favorites_view.dart` — header + body switching loader/error/empty/list.
- `test/presentation/modules/main_shell/controllers/main_shell_controller_test.dart`
- `test/presentation/modules/favorites/controllers/favorites_controller_test.dart`

**Modify:**
- `lib/app/core/translations/en_US.dart` — add `'favorites'` and `'no_favorites_yet'` keys.
- `lib/app/core/translations/fr_FR.dart` — same.
- `lib/app/module/home/views/home_view.dart` — remove inline `_CompetitionCard` family + `_HomeWave` + `_WavePainter`; import shared widgets and use them.
- `lib/app/routes/app_pages.dart` — `Routes.home` page becomes `const MainShellView()` with `bindings: [MainShellBinding(), HomeBinding(), FavoritesBinding(), UserBinding()]`.

---

## Task 1: Add translation keys

**Files:**
- Modify: `lib/app/core/translations/en_US.dart` (around line 79, near the existing `'home'` key)
- Modify: `lib/app/core/translations/fr_FR.dart` (around line 78, near the existing `'home'` key)

- [ ] **Step 1: Add the two keys to en_US.dart**

In `lib/app/core/translations/en_US.dart`, find the line containing `'home': 'Home',` (around line 79) and add two new keys immediately after the `'home'` key:

```dart
  'home': 'Home',
  'favorites': 'Favorites',
  'no_favorites_yet': "You haven't favorited any competition yet",
  'races': 'Races',
```

Note: only the two new lines (`'favorites'` and `'no_favorites_yet'`) are inserted. The surrounding lines are shown for context — do not duplicate them.

- [ ] **Step 2: Add the two keys to fr_FR.dart**

In `lib/app/core/translations/fr_FR.dart`, find the line containing `'home': 'Accueil',` (around line 78) and add the same keys immediately after:

```dart
  'home': 'Accueil',
  'favorites': 'Favoris',
  'no_favorites_yet': "Vous n'avez encore mis aucune compétition en favori",
  'races': 'Epreuves',
```

- [ ] **Step 3: Verify analyzer passes**

Run: `flutter analyze lib/app/core/translations/`
(On Windows where `flutter` may not be on bash PATH: `C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat analyze lib/app/core/translations/`)
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/app/core/translations/en_US.dart lib/app/core/translations/fr_FR.dart
git commit -m "feat(i18n): add favorites + no_favorites_yet translation keys"
```

---

## Task 2: Extract HomeWave widget to shared

The wave painter at the top of the home view needs to be reused by the new Favorites header. Move it to `lib/app/presentation/shared/`. No test added (matches existing convention — no widget tests).

**Files:**
- Create: `lib/app/presentation/shared/home_wave.dart`
- Modify: `lib/app/module/home/views/home_view.dart` (remove `_HomeWave` class + `_WavePainter` class, import the new file, change usage to `HomeWave`)

- [ ] **Step 1: Create the shared widget**

Create `lib/app/presentation/shared/home_wave.dart` with this exact content (copied verbatim from the existing private classes in `home_view.dart`, made public):

```dart
import 'package:flutter/material.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';

class HomeWave extends StatelessWidget {
  const HomeWave({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 24,
      child: CustomPaint(painter: _WavePainter()),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.primary;
    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 2,
        size.width,
        0,
      )
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

- [ ] **Step 2: Update home_view.dart to use the shared widget**

In `lib/app/module/home/views/home_view.dart`:

(a) Add this import at the top (alphabetically, near the other `presentation/shared/` imports):

```dart
import 'package:live_ffss/app/presentation/shared/home_wave.dart';
```

(b) Replace `const _HomeWave()` (around line 28) with `const HomeWave()`:

```dart
            const _HomeHero(),
            const HomeWave(),
            const SizedBox(height: AppSpacing.md),
```

(c) Delete the entire `_HomeWave` class (lines 175–186 in the original) and the entire `_WavePainter` class (lines 188–207 in the original). Both were directly above `_HomeFiltersBar`.

- [ ] **Step 3: Verify analyzer passes**

Run: `flutter analyze lib/app/module/home/views/home_view.dart lib/app/presentation/shared/home_wave.dart`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/app/presentation/shared/home_wave.dart lib/app/module/home/views/home_view.dart
git commit -m "refactor(home): extract HomeWave to shared widget"
```

---

## Task 3: Extract CompetitionCard widget to shared

Same approach for the competition card. The new public widget takes callbacks instead of binding to `HomeController` directly. Both `HomeView` and the upcoming `FavoritesView` will use it.

**Files:**
- Create: `lib/app/presentation/shared/competition_card.dart`
- Modify: `lib/app/module/home/views/home_view.dart`

- [ ] **Step 1: Create the shared widget**

Create `lib/app/presentation/shared/competition_card.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/presentation/modules/home/competition_formatting.dart';

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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.smRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smRadius,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: AppRadius.smRadius,
          ),
          child: Row(
            children: [
              _CardThumbnail(competition: competition),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _CardBody(competition: competition)),
              const SizedBox(width: AppSpacing.sm),
              _CardTrailing(
                competition: competition,
                isFavorite: isFavorite,
                onToggleFavorite: onToggleFavorite,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardThumbnail extends StatelessWidget {
  const _CardThumbnail({required this.competition});

  final Competition competition;

  @override
  Widget build(BuildContext context) {
    final logoUrl = competition.organizerClub.logoUrl;
    if (logoUrl == null || logoUrl.isEmpty) {
      return _DateBlock(competition: competition);
    }
    return ClipRRect(
      borderRadius: AppRadius.smRadius,
      child: Image.network(
        logoUrl,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _DateBlock(competition: competition),
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : _DateBlock(competition: competition),
      ),
    );
  }
}

class _DateBlock extends StatelessWidget {
  const _DateBlock({required this.competition});

  final Competition competition;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadius.smRadius,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            competition.formattedBeginDateMonth,
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            competition.formattedDayBeginDate,
            style: AppTypography.subtitle.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({required this.competition});

  final Competition competition;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          competition.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.title.copyWith(fontSize: 14),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          competition.formattedDateRange,
          style: AppTypography.body.copyWith(fontSize: 12),
        ),
        Text(
          competition.location ?? 'no_location'.tr,
          style: AppTypography.caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _CardTrailing extends StatelessWidget {
  const _CardTrailing({
    required this.competition,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  final Competition competition;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final isLive = competition.phase == CompetitionStatus.onGoing;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isLive ? AppColors.statusError : competition.entryStatusColor,
            borderRadius: AppRadius.pillRadius,
          ),
          child: Text(
            isLive ? 'live'.tr : competition.entryStatusLabel,
            style: AppTypography.badge.copyWith(fontSize: 10),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onToggleFavorite,
              icon: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: isFavorite
                    ? AppColors.statusWaiting
                    : AppColors.textMuted,
                size: 22,
              ),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
              size: 22,
            ),
          ],
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Update home_view.dart to use the shared widget**

In `lib/app/module/home/views/home_view.dart`:

(a) Add this import (alphabetically, near the other `presentation/shared/` imports):

```dart
import 'package:live_ffss/app/presentation/shared/competition_card.dart';
```

(b) Replace the body of `_HomeList.itemBuilder` (around line 332). The original was:

```dart
        itemBuilder: (_, i) => _CompetitionCard(competition: items[i]),
```

Change `_HomeList` to wrap in `Obx` (so the favorite star reactively updates per-card) — replace the entire `_HomeList` class with:

```dart
class _HomeList extends GetView<HomeController> {
  const _HomeList();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.filteredCompetitions;
      if (items.isEmpty) {
        final isLastViewed =
            controller.selectedTemporal.value == TemporalFilter.lastViewed;
        return EmptyState(
          icon: Icons.event_busy,
          title:
              isLastViewed ? 'no_last_viewed'.tr : 'no_competitions_found'.tr,
        );
      }
      return ListView.separated(
        padding: AppSpacing.pageHorizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, i) {
          final competition = items[i];
          return Obx(() => CompetitionCard(
                competition: competition,
                isFavorite: controller.favoriteIds.contains(competition.id),
                onTap: () =>
                    controller.navigateToCompetitionDetails(competition),
                onToggleFavorite: () =>
                    controller.toggleFavorite(competition.id),
              ));
        },
      );
    });
  }
}
```

(c) Delete the now-unused private classes from `home_view.dart`:
- `_CompetitionCard`
- `_CardThumbnail`
- `_DateBlock`
- `_CardBody`
- `_CardTrailing`

After this step, `home_view.dart` no longer contains any of those five classes — they all live in `competition_card.dart`.

(d) Remove imports that are now unused. After the deletions in (c):
- `import 'package:live_ffss/app/domain/models/competition.dart';` — REMOVE. `Competition` is no longer named directly in `home_view.dart` (the var in `_HomeList.itemBuilder` is inferred).
- `import 'package:live_ffss/app/presentation/modules/home/competition_formatting.dart';` — REMOVE. The formatting extensions (`formattedBeginDateMonth`, `formattedDayBeginDate`, `formattedDateRange`, `entryStatusColor`, `entryStatusLabel`) and the `CompetitionStatus` reference all moved into `competition_card.dart`. Note: `TemporalFilter` (used in `_HomeList`) lives in `home_controller.dart`, not this file.
- All other imports stay.

If the analyzer flags any other unused import after the deletions, remove it.

- [ ] **Step 3: Verify analyzer passes**

Run: `flutter analyze lib/app/module/home/ lib/app/presentation/shared/competition_card.dart`
Expected: `No issues found!`

- [ ] **Step 4: Run existing home controller tests to confirm no regression**

Run: `flutter test test/presentation/modules/home/`
Expected: all existing tests pass (controller logic is untouched).

- [ ] **Step 5: Commit**

```bash
git add lib/app/presentation/shared/competition_card.dart lib/app/module/home/views/home_view.dart
git commit -m "refactor(home): extract CompetitionCard to shared widget"
```

---

## Task 4: MainShellController + tests + binding

Tiny controller with one piece of state (`selectedIndex`). TDD-style: test first, implement second.

**Files:**
- Create: `test/presentation/modules/main_shell/controllers/main_shell_controller_test.dart`
- Create: `lib/app/module/main_shell/controllers/main_shell_controller.dart`
- Create: `lib/app/module/main_shell/bindings/main_shell_binding.dart`

- [ ] **Step 1: Write the failing test**

Create `test/presentation/modules/main_shell/controllers/main_shell_controller_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/module/main_shell/controllers/main_shell_controller.dart';

void main() {
  group('MainShellController', () {
    test('selectedIndex starts at 0', () {
      final controller = MainShellController();
      expect(controller.selectedIndex.value, 0);
    });

    test('setIndex updates selectedIndex', () {
      final controller = MainShellController();
      controller.setIndex(1);
      expect(controller.selectedIndex.value, 1);
      controller.setIndex(0);
      expect(controller.selectedIndex.value, 0);
    });
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/presentation/modules/main_shell/controllers/main_shell_controller_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:live_ffss/app/module/main_shell/controllers/main_shell_controller.dart'`

- [ ] **Step 3: Write the controller**

Create `lib/app/module/main_shell/controllers/main_shell_controller.dart`:

```dart
import 'package:get/get.dart';

class MainShellController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  void setIndex(int index) => selectedIndex.value = index;
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/presentation/modules/main_shell/controllers/main_shell_controller_test.dart`
Expected: PASS — both tests green.

- [ ] **Step 5: Write the binding**

Create `lib/app/module/main_shell/bindings/main_shell_binding.dart`:

```dart
import 'package:get/get.dart';
import '../controllers/main_shell_controller.dart';

class MainShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainShellController>(() => MainShellController());
  }
}
```

- [ ] **Step 6: Verify analyzer passes**

Run: `flutter analyze lib/app/module/main_shell/ test/presentation/modules/main_shell/`
Expected: `No issues found!`

- [ ] **Step 7: Commit**

```bash
git add lib/app/module/main_shell/ test/presentation/modules/main_shell/
git commit -m "feat(main_shell): add MainShellController + binding"
```

---

## Task 5: FavoritesController + tests + binding

The Favorites controller filters `HomeController.competitions` by `UserPreferencesService.favoriteIds`, and triggers `loadCompetitions()` on init if home is empty / not loading / not errored.

**Files:**
- Create: `test/presentation/modules/favorites/controllers/favorites_controller_test.dart`
- Create: `lib/app/module/favorites/controllers/favorites_controller.dart`
- Create: `lib/app/module/favorites/bindings/favorites_binding.dart`

- [ ] **Step 1: Write the failing test**

Create `test/presentation/modules/favorites/controllers/favorites_controller_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/data/services/user_preferences_service.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/module/favorites/controllers/favorites_controller.dart';
import 'package:live_ffss/app/module/home/controllers/home_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockHome extends Mock implements HomeController {}

class _MockPrefs extends Mock implements UserPreferencesService {}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    Get.testMode = true;
  });

  Competition c(int id) => Competition(
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

  late _MockHome home;
  late _MockPrefs prefs;
  late FavoritesController controller;

  setUp(() {
    home = _MockHome();
    prefs = _MockPrefs();
    when(() => home.competitions).thenReturn(<Competition>[].obs);
    when(() => home.isLoading).thenReturn(false.obs);
    when(() => home.hasError).thenReturn(false.obs);
    when(() => home.loadCompetitions()).thenAnswer((_) async {});
    when(() => prefs.favoriteIds).thenReturn(<int>{}.obs);
    when(() => prefs.toggleFavorite(any())).thenAnswer((_) async {});
    controller = FavoritesController(home, prefs);
  });

  tearDown(() {
    Get.reset();
  });

  group('favoriteCompetitions', () {
    test('returns competitions whose id is in favoriteIds', () {
      when(() => home.competitions)
          .thenReturn(<Competition>[c(1), c(2), c(3)].obs);
      when(() => prefs.favoriteIds).thenReturn(<int>{1, 3}.obs);

      final result =
          controller.favoriteCompetitions.map((x) => x.id).toList();
      expect(result, [1, 3]);
    });

    test('returns empty when no favorites', () {
      when(() => home.competitions)
          .thenReturn(<Competition>[c(1), c(2)].obs);
      when(() => prefs.favoriteIds).thenReturn(<int>{}.obs);

      expect(controller.favoriteCompetitions, isEmpty);
    });

    test('returns empty when home has no competitions loaded', () {
      when(() => home.competitions).thenReturn(<Competition>[].obs);
      when(() => prefs.favoriteIds).thenReturn(<int>{1, 2}.obs);

      expect(controller.favoriteCompetitions, isEmpty);
    });

    test('excludes favorited ids that are not in home.competitions', () {
      when(() => home.competitions).thenReturn(<Competition>[c(1)].obs);
      when(() => prefs.favoriteIds).thenReturn(<int>{1, 99}.obs);

      final result =
          controller.favoriteCompetitions.map((x) => x.id).toList();
      expect(result, [1]);
    });
  });

  group('onInit', () {
    test('triggers loadCompetitions when home is empty/idle/no-error', () {
      when(() => home.competitions).thenReturn(<Competition>[].obs);
      when(() => home.isLoading).thenReturn(false.obs);
      when(() => home.hasError).thenReturn(false.obs);

      controller.onInit();

      verify(() => home.loadCompetitions()).called(1);
    });

    test('does NOT trigger load when home is already loading', () {
      when(() => home.competitions).thenReturn(<Competition>[].obs);
      when(() => home.isLoading).thenReturn(true.obs);
      when(() => home.hasError).thenReturn(false.obs);

      controller.onInit();

      verifyNever(() => home.loadCompetitions());
    });

    test('does NOT trigger load when home already has competitions', () {
      when(() => home.competitions).thenReturn(<Competition>[c(1)].obs);
      when(() => home.isLoading).thenReturn(false.obs);
      when(() => home.hasError).thenReturn(false.obs);

      controller.onInit();

      verifyNever(() => home.loadCompetitions());
    });

    test('does NOT trigger load when home has errored', () {
      when(() => home.competitions).thenReturn(<Competition>[].obs);
      when(() => home.isLoading).thenReturn(false.obs);
      when(() => home.hasError).thenReturn(true.obs);

      controller.onInit();

      verifyNever(() => home.loadCompetitions());
    });
  });

  group('toggleFavorite', () {
    test('delegates to prefs.toggleFavorite', () async {
      await controller.toggleFavorite(42);
      verify(() => prefs.toggleFavorite(42)).called(1);
    });
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/presentation/modules/favorites/controllers/favorites_controller_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:live_ffss/app/module/favorites/controllers/favorites_controller.dart'`

- [ ] **Step 3: Write the controller**

Create `lib/app/module/favorites/controllers/favorites_controller.dart`:

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/data/services/user_preferences_service.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/module/home/controllers/home_controller.dart';

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
  RxList<Competition> get competitions => _homeController.competitions;
  RxSet<int> get favoriteIds => _prefs.favoriteIds;

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

- [ ] **Step 4: Run the tests to verify they pass**

Run: `flutter test test/presentation/modules/favorites/controllers/favorites_controller_test.dart`
Expected: PASS — all groups green.

- [ ] **Step 5: Write the binding**

Create `lib/app/module/favorites/bindings/favorites_binding.dart`:

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/data/services/user_preferences_service.dart';
import 'package:live_ffss/app/module/home/controllers/home_controller.dart';
import '../controllers/favorites_controller.dart';

class FavoritesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FavoritesController>(
      () => FavoritesController(
        Get.find<HomeController>(),
        Get.find<UserPreferencesService>(),
      ),
    );
  }
}
```

- [ ] **Step 6: Verify analyzer passes**

Run: `flutter analyze lib/app/module/favorites/ test/presentation/modules/favorites/`
Expected: `No issues found!`

- [ ] **Step 7: Commit**

```bash
git add lib/app/module/favorites/ test/presentation/modules/favorites/
git commit -m "feat(favorites): add FavoritesController + binding"
```

---

## Task 6: FavoritesView

The screen that the Favorites tab renders. Header strip, then loader/error/empty/list per the spec's gating rules.

**Files:**
- Create: `lib/app/module/favorites/views/favorites_view.dart`

- [ ] **Step 1: Create the view**

Create `lib/app/module/favorites/views/favorites_view.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/module/favorites/controllers/favorites_controller.dart';
import 'package:live_ffss/app/presentation/shared/competition_card.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';
import 'package:live_ffss/app/presentation/shared/error_state.dart';
import 'package:live_ffss/app/presentation/shared/home_wave.dart';
import 'package:live_ffss/app/presentation/shared/loading_indicator.dart';

class FavoritesView extends GetView<FavoritesController> {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _FavoritesHeader(),
            const HomeWave(),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: Obx(() {
                final hasAnyCompetitions = controller.competitions.isNotEmpty;
                if (controller.isLoading.value && !hasAnyCompetitions) {
                  return const LoadingIndicator();
                }
                if (controller.hasError.value && !hasAnyCompetitions) {
                  return ErrorState(
                    message: 'error_occured'.tr,
                    onRetry: controller.retry,
                  );
                }
                final items = controller.favoriteCompetitions;
                if (items.isEmpty) {
                  return EmptyState(
                    icon: Icons.star_border,
                    title: 'no_favorites_yet'.tr,
                  );
                }
                return ListView.separated(
                  padding: AppSpacing.pageHorizontal,
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (_, i) {
                    final competition = items[i];
                    return Obx(() => CompetitionCard(
                          competition: competition,
                          isFavorite: controller.favoriteIds
                              .contains(competition.id),
                          onTap: () => controller
                              .navigateToCompetitionDetails(competition),
                          onToggleFavorite: () =>
                              controller.toggleFavorite(competition.id),
                        ));
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoritesHeader extends StatelessWidget {
  const _FavoritesHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: Center(
        child: Text(
          'favorites'.tr,
          style: AppTypography.title.copyWith(
            color: Colors.white,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify analyzer passes**

Run: `flutter analyze lib/app/module/favorites/views/favorites_view.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/app/module/favorites/views/favorites_view.dart
git commit -m "feat(favorites): add FavoritesView with loader/error/empty/list states"
```

---

## Task 7: MainShellView

The shell that hosts the bottom nav and the two tab bodies via `IndexedStack`.

**Files:**
- Create: `lib/app/module/main_shell/views/main_shell_view.dart`

- [ ] **Step 1: Create the view**

Create `lib/app/module/main_shell/views/main_shell_view.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/module/favorites/views/favorites_view.dart';
import 'package:live_ffss/app/module/home/views/home_view.dart';
import 'package:live_ffss/app/module/main_shell/controllers/main_shell_controller.dart';

class MainShellView extends GetView<MainShellController> {
  const MainShellView({super.key});

  static const _tabs = <Widget>[
    HomeView(),
    FavoritesView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
            index: controller.selectedIndex.value,
            children: _tabs,
          )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            currentIndex: controller.selectedIndex.value,
            onTap: controller.setIndex,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textMuted,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home),
                label: 'home'.tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.star_border),
                activeIcon: const Icon(Icons.star),
                label: 'favorites'.tr,
              ),
            ],
          )),
    );
  }
}
```

- [ ] **Step 2: Verify analyzer passes**

Run: `flutter analyze lib/app/module/main_shell/views/main_shell_view.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/app/module/main_shell/views/main_shell_view.dart
git commit -m "feat(main_shell): add MainShellView with IndexedStack + BottomNavigationBar"
```

---

## Task 8: Wire route — MainShellView replaces HomeView at `/home`

**Files:**
- Modify: `lib/app/routes/app_pages.dart`

- [ ] **Step 1: Update the home route**

In `lib/app/routes/app_pages.dart`:

(a) Add these imports (alphabetically near the other module imports):

```dart
import 'package:live_ffss/app/module/favorites/bindings/favorites_binding.dart';
import 'package:live_ffss/app/module/main_shell/bindings/main_shell_binding.dart';
import 'package:live_ffss/app/module/main_shell/views/main_shell_view.dart';
```

(b) Replace the existing `Routes.home` `GetPage` block. The original was:

```dart
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      bindings: [
        HomeBinding(),
        UserBinding(),
      ],
    ),
```

Change it to:

```dart
    GetPage(
      name: Routes.home,
      page: () => const MainShellView(),
      bindings: [
        MainShellBinding(),
        HomeBinding(),
        FavoritesBinding(),
        UserBinding(),
      ],
    ),
```

The order in `bindings` is intentional: `MainShellBinding` first (registers `MainShellController`), then `HomeBinding` (registers `HomeController`, which `FavoritesController` depends on), then `FavoritesBinding` (depends on the prior two), then `UserBinding`.

(c) Leave the import for `home_view.dart` in place — it's still indirectly referenced via `MainShellView`'s tab list but the analyzer won't see that. Actually `app_pages.dart` no longer references `HomeView` directly. Remove the now-unused import:

```dart
import 'package:live_ffss/app/module/home/views/home_view.dart';
```

- [ ] **Step 2: Verify analyzer passes**

Run: `flutter analyze lib/app/routes/`
Expected: `No issues found!`

- [ ] **Step 3: Run the full test suite to confirm no regression**

Run: `flutter test`
Expected: all tests pass.

- [ ] **Step 4: Commit**

```bash
git add lib/app/routes/app_pages.dart
git commit -m "feat(routes): wire MainShellView as the /home page"
```

---

## Task 9: Manual smoke test

The architecture has no widget tests, so verify the feature works end-to-end manually. CLAUDE.md is explicit: type checking and unit tests verify code correctness, not feature correctness — if you can't test the UI, say so explicitly.

- [ ] **Step 1: Build & run the app**

Run: `flutter run` (target an emulator or connected device)

- [ ] **Step 2: Smoke test — Home tab**

Verify on the running app:
- [ ] App opens on the Home tab (bottom nav highlights "Home").
- [ ] Hero, filters, search bar, competition list still render and behave as before.
- [ ] Tapping a competition opens the detail view (bottom nav disappears — full-screen push).
- [ ] Back button returns to the shell with the Home tab still selected.
- [ ] Tapping the star on a card toggles the gold/grey state.

- [ ] **Step 3: Smoke test — Favorites tab**

- [ ] Tap "Favorites" in the bottom nav. The tab switches and the title "Favorites" / "Favoris" shows.
- [ ] If you have favorited at least one competition in step 2, it appears in the list.
- [ ] If you unfavorite the last item from the Favorites view (tap the star), the list reactively shows the empty state with the star_border icon and "no_favorites_yet" message.
- [ ] Re-favoriting from Home (switch back to Home tab → tap a star) and switching to Favorites shows the item again.
- [ ] Tap a favorited card → competition detail opens; back returns to Favorites tab (not Home).

- [ ] **Step 4: Smoke test — Cold start on Favorites tab**

This tests Option C's "trigger load on first visit if home not loaded":
- [ ] Stop and restart the app.
- [ ] Immediately tap "Favorites" before the Home list has visibly loaded.
- [ ] Expected: a brief loader, then the favorites list (or empty state if no favorites). No infinite spinner; no error.

- [ ] **Step 5: Smoke test — Logout + login (only if a test account is available)**

- [ ] Log out from the profile menu. Verify the Home tab refreshes and the Favorites tab still shows favorites (favorites are device-scoped, not tied to login per `UserPreferencesService`).

- [ ] **Step 6: Commit (only if you needed to make UI tweaks during smoke test)**

If smoke test surfaced no issues, no commit needed for this task. If a tweak was required, commit it with a descriptive message and re-run the relevant smoke step.

---

## Done

After all tasks complete, the deliverable is:

- A `BottomNavigationBar` on the home screen with Home / Favorites tabs.
- Favorites tab shows competitions the user has starred, sourced from `HomeController.competitions`.
- Tab state preserved across switches (`IndexedStack`).
- Existing Home view behavior unchanged (refactor preserved its semantics).
- New unit tests for `MainShellController` (2 tests) and `FavoritesController` (8+ tests).
- Two new translation keys in both locales.
