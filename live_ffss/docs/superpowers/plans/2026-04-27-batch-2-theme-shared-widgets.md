# Batch 2 — Theme + Shared Widgets Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Establish design tokens (colors, spacing, radii, typography) and a small library of reusable presentation widgets (`LoadingIndicator`, `EmptyState`, `ErrorState`, `StatusBadge`, `SectionHeader`) so later view-splitting batches don't keep re-rolling the same patterns. Apply the new tokens/widgets opportunistically — only as 1:1 substitutions for already-duplicated code, no layout redesign.

**Architecture:** Tokens live in `lib/app/core/theme/` and are wired into `appThemeData`. Shared widgets live in `lib/app/presentation/shared/`. Existing `LanguageSelector` relocates from `lib/app/widgets/` to the new home. **No controller changes; no behavior changes.**

**Tech Stack:** Flutter / Material 3-friendly tokens. No new dependencies.

---

## Notes & deviations from spec

1. **Conservative widget application.** The spec says "The big views all use these." For Batch 2 I substitute only the unambiguous 1:1 cases (centered `CircularProgressIndicator`, the `Icon + SizedBox + Text` "empty state" blocks, the run-status pill in slot view). Larger restructures of `slot_view.dart` / `home_view.dart` / `program_view.dart` happen in their own batches (3-5) when those modules are being touched anyway. This keeps Batch 2 to its 2-4h budget and avoids touching code that's about to be rewritten.

2. **No widget tests.** Per the design spec's "pragmatic core coverage" decision (test mappers/repos/controllers, not widgets), the new shared widgets are validated by `flutter analyze` + the existing app launching, not by `testWidgets`. Adding widget tests now would slow this batch by 50% for marginal value on what are essentially layout-only widgets.

3. **`LanguageSelector` relocation.** Existing `lib/app/widgets/language_selector.dart` moves to `lib/app/presentation/shared/`. The legacy `lib/app/widgets/` directory becomes empty and is left for git to delete naturally on the next commit that excludes it. (Dart doesn't track empty dirs, so once the file moves the directory effectively disappears.)

4. **Theme keeps `Colors.blue` as the primary swatch.** The spec doesn't define a new brand color. Tokens just *name* what's already there so future visual rebrand is a one-file change.

---

## File map

**Create (production):**
- `lib/app/core/theme/app_colors.dart`
- `lib/app/core/theme/app_spacing.dart`
- `lib/app/core/theme/app_radius.dart`
- `lib/app/core/theme/app_typography.dart`
- `lib/app/presentation/shared/loading_indicator.dart`
- `lib/app/presentation/shared/empty_state.dart`
- `lib/app/presentation/shared/error_state.dart`
- `lib/app/presentation/shared/status_badge.dart`
- `lib/app/presentation/shared/section_header.dart`

**Modify:**
- `lib/app/core/themes/app_theme.dart` — wire the new tokens into `appThemeData`. (NB: existing path is `themes/` plural; new tokens live in `theme/` singular per spec §5. Both directories will coexist for now; `app_theme.dart` stays at its current path so the import in `main.dart` doesn't change.)
- 1-3 view files for the opportunistic substitution pass (Task 7) — the *exact* set is decided when running the analyzer/grep. Expect at most: `slot_view.dart`, `home_view.dart`, `program_view.dart`, `competition_detail_clubs_view.dart`, `competition_detail_view.dart`, `program_add_meeting_dialog.dart`.

**Move:**
- `lib/app/widgets/language_selector.dart` → `lib/app/presentation/shared/language_selector.dart`. Update its 1-2 importers.

**Delete:**
- (Implicit) `lib/app/widgets/` directory becomes empty.

---

## Token API

### `AppColors` — semantic, not raw color names

```dart
abstract class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF2196F3);          // Material blue 500
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primarySurface = Color(0x1A2196F3);   // 10% alpha (bg fills)

  // Surfaces
  static const Color surface = Colors.white;
  static const Color surfaceMuted = Color(0xFFF5F5F5);     // grey[100]
  static const Color border = Color(0xFFE0E0E0);           // grey[300]

  // Text
  static const Color textPrimary = Color(0xDD000000);      // black87
  static const Color textSecondary = Color(0xFF616161);    // grey[700]
  static const Color textMuted = Color(0xFF9E9E9E);        // grey[500]

  // Status
  static const Color statusWaiting = Color(0xFFFB8C00);    // orange[600]
  static const Color statusMarshalling = Color(0xFF1E88E5);// blue[600]
  static const Color statusInProgress = Color(0xFFFFB300); // amber[600]
  static const Color statusFinished = Color(0xFF43A047);   // green[600]
  static const Color statusError = Color(0xFFE53935);      // red[600]

  // Rank medals
  static const Color rankGold = Color(0xFFFFA000);         // amber[700]
  static const Color rankSilver = Color(0xFF757575);       // grey[600]
  static const Color rankBronze = Color(0xFF6D4C41);       // brown[600]
}
```

### `AppSpacing`

```dart
abstract class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  // Edge insets shortcuts
  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets pageAll = EdgeInsets.all(md);
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
}
```

### `AppRadius`

```dart
abstract class AppRadius {
  AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double pill = 999;

  static final BorderRadius smRadius = BorderRadius.circular(sm);
  static final BorderRadius mdRadius = BorderRadius.circular(md);
  static final BorderRadius lgRadius = BorderRadius.circular(lg);
  static final BorderRadius pillRadius = BorderRadius.circular(pill);
}
```

### `AppTypography`

```dart
abstract class AppTypography {
  AppTypography._();

  static const TextStyle title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textMuted,
  );

  static const TextStyle badge = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}
```

## Shared widget contracts

### `LoadingIndicator`

```dart
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.message, this.compact = false});

  final String? message;
  final bool compact; // when true, small inline progress (no Center wrap)
}
```

Renders a centered `CircularProgressIndicator` with an optional caption underneath. `compact: true` skips the `Center` and uses `strokeWidth: 2`.

### `EmptyState`

```dart
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
  });

  final IconData icon;
  final String title;
  final String? description;
}
```

Centered column: 64-px muted icon → AppSpacing.md gap → title (subtitle style) → optional description (caption).

### `ErrorState`

```dart
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;
}
```

Same centered-column layout as `EmptyState`, red error icon, error message, optional `Retry` button.

### `StatusBadge`

```dart
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.color});

  final String label;
  final Color color;
}
```

Pill-shaped colored chip with white bold text. Used for run status, DSQ markers, etc.

### `SectionHeader`

```dart
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;
}
```

Bold title + optional trailing widget on the right (e.g., a "see all" button).

---

## Task 1: Theme tokens

**Files:**
- Create: `lib/app/core/theme/app_colors.dart`
- Create: `lib/app/core/theme/app_spacing.dart`
- Create: `lib/app/core/theme/app_radius.dart`
- Create: `lib/app/core/theme/app_typography.dart`

- [ ] **Step 1: Create `app_colors.dart`**

Create `lib/app/core/theme/app_colors.dart` with EXACTLY this content:

```dart
import 'package:flutter/material.dart';

abstract class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primarySurface = Color(0x1A2196F3);

  // Surfaces
  static const Color surface = Colors.white;
  static const Color surfaceMuted = Color(0xFFF5F5F5);
  static const Color border = Color(0xFFE0E0E0);

  // Text
  static const Color textPrimary = Color(0xDD000000);
  static const Color textSecondary = Color(0xFF616161);
  static const Color textMuted = Color(0xFF9E9E9E);

  // Status
  static const Color statusWaiting = Color(0xFFFB8C00);
  static const Color statusMarshalling = Color(0xFF1E88E5);
  static const Color statusInProgress = Color(0xFFFFB300);
  static const Color statusFinished = Color(0xFF43A047);
  static const Color statusError = Color(0xFFE53935);

  // Rank medals
  static const Color rankGold = Color(0xFFFFA000);
  static const Color rankSilver = Color(0xFF757575);
  static const Color rankBronze = Color(0xFF6D4C41);
}
```

- [ ] **Step 2: Create `app_spacing.dart`**

```dart
import 'package:flutter/widgets.dart';

abstract class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets pageAll = EdgeInsets.all(md);
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
}
```

- [ ] **Step 3: Create `app_radius.dart`**

```dart
import 'package:flutter/widgets.dart';

abstract class AppRadius {
  AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double pill = 999;

  static final BorderRadius smRadius = BorderRadius.circular(sm);
  static final BorderRadius mdRadius = BorderRadius.circular(md);
  static final BorderRadius lgRadius = BorderRadius.circular(lg);
  static final BorderRadius pillRadius = BorderRadius.circular(pill);
}
```

- [ ] **Step 4: Create `app_typography.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';

abstract class AppTypography {
  AppTypography._();

  static const TextStyle title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textMuted,
  );

  static const TextStyle badge = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}
```

- [ ] **Step 5: Verify**

Run: `flutter analyze lib/app/core/theme/`
Expected: `No issues found!`

(`flutter` may not be on bash PATH — fall back to `C:\Users\nast0\dev\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat` if needed.)

- [ ] **Step 6: Commit**

```bash
git add lib/app/core/theme/
git commit -m "feat(theme): add design tokens

AppColors (brand/surface/text/status/rank), AppSpacing (xs..xl + edge
insets shortcuts), AppRadius (sm/md/lg/pill), AppTypography (title/
subtitle/body/caption/badge). No usages yet — wired into appThemeData
and shared widgets in the next commits."
```

---

## Task 2: Wire tokens into appThemeData

**Files:**
- Modify: `lib/app/core/themes/app_theme.dart`

- [ ] **Step 1: Replace the file**

REPLACE `lib/app/core/themes/app_theme.dart` with EXACTLY this content:

```dart
import 'package:flutter/material.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';

final ThemeData appThemeData = ThemeData(
  primarySwatch: Colors.blue,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceMuted,
    border: OutlineInputBorder(
      borderRadius: AppRadius.smRadius,
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppRadius.smRadius,
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppRadius.smRadius,
      borderSide: const BorderSide(color: AppColors.primary),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: AppRadius.smRadius,
      borderSide: const BorderSide(color: AppColors.statusError),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.md,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.smRadius),
      elevation: 0,
    ),
  ),
);
```

NB: `primarySwatch` keeps `Colors.blue` (Material's MaterialColor swatch — `AppColors.primary` is a single Color and can't replace it without an explicit swatch). The visible behavior is unchanged.

- [ ] **Step 2: Verify**

Run: `flutter analyze lib/app/core/themes/app_theme.dart`
Expected: `No issues found!`

Run: `flutter test`
Expected: still ~59 tests passing — no regression.

- [ ] **Step 3: Commit**

```bash
git add lib/app/core/themes/app_theme.dart
git commit -m "refactor(theme): appThemeData now consumes design tokens

Input decoration borders, fill color, content padding, and button
shape come from AppColors/AppRadius/AppSpacing. Visible behavior
unchanged — primarySwatch stays Colors.blue (MaterialColor)."
```

---

## Task 3: State widgets — LoadingIndicator + EmptyState + ErrorState

**Files:**
- Create: `lib/app/presentation/shared/loading_indicator.dart`
- Create: `lib/app/presentation/shared/empty_state.dart`
- Create: `lib/app/presentation/shared/error_state.dart`

- [ ] **Step 1: Create `loading_indicator.dart`**

Create `lib/app/presentation/shared/loading_indicator.dart` with EXACTLY this content:

```dart
import 'package:flutter/material.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    this.message,
    this.compact = false,
  });

  final String? message;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              message!,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Create `empty_state.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
  });

  final IconData icon;
  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: AppColors.textMuted),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: AppTypography.subtitle,
            textAlign: TextAlign.center,
          ),
          if (description != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              description!,
              style: AppTypography.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Create `error_state.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.statusError,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: AppTypography.subtitle.copyWith(
              color: AppColors.statusError,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: onRetry,
              child: Text('retry'.tr),
            ),
          ],
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Verify**

Run: `flutter analyze lib/app/presentation/shared/`
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/app/presentation/shared/loading_indicator.dart \
        lib/app/presentation/shared/empty_state.dart \
        lib/app/presentation/shared/error_state.dart
git commit -m "feat(shared): add LoadingIndicator, EmptyState, ErrorState

Three centered-column status widgets used across the app. ErrorState
includes an optional retry button using the 'retry' translation key
already in fr_FR/en_US."
```

---

## Task 4: Decoration widgets — StatusBadge + SectionHeader

**Files:**
- Create: `lib/app/presentation/shared/status_badge.dart`
- Create: `lib/app/presentation/shared/section_header.dart`

- [ ] **Step 1: Create `status_badge.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.pillRadius,
      ),
      child: Text(label, style: AppTypography.badge),
    );
  }
}
```

- [ ] **Step 2: Create `section_header.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: AppTypography.title),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Verify**

Run: `flutter analyze lib/app/presentation/shared/`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/app/presentation/shared/status_badge.dart \
        lib/app/presentation/shared/section_header.dart
git commit -m "feat(shared): add StatusBadge and SectionHeader

Pill-shaped colored chip and a row-with-optional-trailing header.
Replace the duplicated containers in slot_view and the section
boundaries in home_view in the next commit."
```

---

## Task 5: Move LanguageSelector to presentation/shared/

**Files:**
- Move: `lib/app/widgets/language_selector.dart` → `lib/app/presentation/shared/language_selector.dart`
- Modify: any file that imports the old path

- [ ] **Step 1: Find importers**

Run grep for the old import path:

```bash
grep -rn "package:live_ffss/app/widgets/language_selector.dart" lib/ test/
```

Expected: 1-2 hits, likely in `home_view.dart` or `profile_view.dart`. Note the files for Step 3.

- [ ] **Step 2: Move the file**

```bash
git mv lib/app/widgets/language_selector.dart \
       lib/app/presentation/shared/language_selector.dart
```

(`git mv` preserves history.)

- [ ] **Step 3: Update importers**

For each file from Step 1, replace:

```dart
import 'package:live_ffss/app/widgets/language_selector.dart';
```

with:

```dart
import 'package:live_ffss/app/presentation/shared/language_selector.dart';
```

- [ ] **Step 4: Verify**

Run: `flutter analyze`
Expected: zero errors. Same pre-existing warnings/infos as before — no new issues from the move.

- [ ] **Step 5: Commit**

```bash
git add lib/app/widgets/language_selector.dart \
        lib/app/presentation/shared/language_selector.dart
# also any file modified in Step 3
git commit -m "refactor: move LanguageSelector to presentation/shared/

Aligns with the new presentation layer layout from the architecture
spec. Old lib/app/widgets/ directory becomes empty."
```

---

## Task 6: Apply tokens & shared widgets opportunistically

This task replaces existing duplicated patterns with the new tokens/widgets — but **only 1:1 swaps**, no layout redesign. View files keep their overall structure. Larger refactors of slot/home/program views happen in their own batches.

**Files (likely candidates — check with grep):**
- `lib/app/module/slot/views/slot_view.dart`
- `lib/app/module/home/views/home_view.dart`
- `lib/app/module/program/views/program_view.dart`
- `lib/app/module/competitions/views/competition_detail_view.dart`
- `lib/app/module/competitions/views/competition_detail_clubs_view.dart`
- `lib/app/module/program/views/program_add_meeting_dialog.dart`
- `lib/app/module/auth/views/login_view.dart`

- [ ] **Step 1: Find candidates**

Grep for the patterns we can replace 1:1:

```bash
# Standalone CircularProgressIndicator wrapped in Center
grep -rn 'Center(child: CircularProgressIndicator())' lib/app/module/

# Same with const variants
grep -rn 'const Center(\s*child: CircularProgressIndicator()' lib/app/module/
```

For EACH match (expected ~5-7 files), substitute:

```dart
// BEFORE
const Center(child: CircularProgressIndicator())
// or
Center(child: CircularProgressIndicator())

// AFTER
const LoadingIndicator()
```

And add the import to the top of the file (only if not already present):

```dart
import 'package:live_ffss/app/presentation/shared/loading_indicator.dart';
```

- [ ] **Step 2: Replace empty-state blocks in slot_view.dart**

In `lib/app/module/slot/views/slot_view.dart`:

**Replacement A — `_buildEmptyRunsView` (currently at ~lines 339-360):**

```dart
// BEFORE
Widget _buildEmptyRunsView() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.event_busy,
          size: 64,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 16),
        Text(
          'no_runs_available'.tr,
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

// AFTER
Widget _buildEmptyRunsView() {
  return EmptyState(
    icon: Icons.event_busy,
    title: 'no_runs_available'.tr,
  );
}
```

**Replacement B — the "no athletes" empty state (currently around `_buildAthletesContent`'s empty branch):**

```dart
// BEFORE — the inner Center(child: Column(...)) block with Icons.people_outline
// AFTER
EmptyState(
  icon: Icons.people_outline,
  title: 'no_athletes_found'.tr,
)
```

**Replacement C — the "no results" empty state in `_buildResultsList`:**

```dart
// BEFORE
Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        Icons.emoji_events_outlined,
        size: 64,
        color: Colors.grey[400],
      ),
      const SizedBox(height: 16),
      Text('no_results_available'.tr, ...),
      const SizedBox(height: 8),
      Text('results_will_appear_here'.tr, ...),
    ],
  ),
);

// AFTER
EmptyState(
  icon: Icons.emoji_events_outlined,
  title: 'no_results_available'.tr,
  description: 'results_will_appear_here'.tr,
);
```

**Replacement D — the run-status pill in `_buildRunInfoHeader`:**

```dart
// BEFORE
Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: _getStatusColor(run.status),
    borderRadius: BorderRadius.circular(20),
  ),
  child: Text(
    run.localizedStatus,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ),
  ),
),

// AFTER
StatusBadge(
  label: run.localizedStatus,
  color: _getStatusColor(run.status),
),
```

(Leave `_getStatusColor` itself alone — its body still uses `Colors.orange` etc. The deeper enum/token migration belongs in Batch 5 when slot is rebuilt.)

**Replacement E — error state in `_buildRunTab`:**

```dart
// BEFORE — the "error_loading_results" Center(child: Column(...)) with retry button
// AFTER
ErrorState(
  message: 'error_loading_results'.tr,
  onRetry: controller.refreshResults,
);
```

Add the imports at the top of `slot_view.dart`:

```dart
import 'package:live_ffss/app/presentation/shared/empty_state.dart';
import 'package:live_ffss/app/presentation/shared/error_state.dart';
import 'package:live_ffss/app/presentation/shared/loading_indicator.dart';
import 'package:live_ffss/app/presentation/shared/status_badge.dart';
```

- [ ] **Step 3: Verify slot_view.dart still compiles**

Run: `flutter analyze lib/app/module/slot/views/slot_view.dart`
Expected: zero new errors. (Pre-existing infos like `sized_box_for_whitespace` may persist.)

- [ ] **Step 4: Apply LoadingIndicator across the project**

For each file in Step 1's grep output, do the LoadingIndicator substitution. If a file's `Center(child: CircularProgressIndicator())` is wrapped in extra structure (e.g., a `SizedBox` with explicit dimensions for an inline indicator like in `home_view.dart:359` — `CircularProgressIndicator(strokeWidth: 2)`), prefer:

```dart
// BEFORE
const SizedBox(
  width: 20,
  height: 20,
  child: CircularProgressIndicator(strokeWidth: 2),
)

// AFTER
const LoadingIndicator(compact: true)
```

For inline indicators inside ElevatedButtons (like in `login_view.dart:105`, `program_add_meeting_dialog.dart`, `beach_ranking_dialog.dart`, `swim_time_dialog.dart`), LEAVE THEM ALONE — they're already minimal and the button-internal sizing is touchy.

- [ ] **Step 5: Verify the full project**

Run: `flutter analyze`
Expected: zero errors; same baseline of warnings/infos as before this batch.

Run: `flutter test`
Expected: 59 tests, all passing.

- [ ] **Step 6: Commit**

```bash
git add lib/app/module/
git commit -m "refactor(views): use shared widgets for empty/loading/status

Replaces in-place Center(CircularProgressIndicator()) and the
duplicated empty/error-state column blocks with LoadingIndicator,
EmptyState, ErrorState, StatusBadge. Layout unchanged."
```

---

## Task 7: Final verification

- [ ] **Step 1: Run full test suite**

Run: `flutter test`
Expected: 59 tests, all green. (No new tests in this batch — Batch 2 doesn't add logic.)

- [ ] **Step 2: Run analyzer**

Run: `flutter analyze`
Expected: zero errors. Pre-existing warnings/infos count should be ≤ pre-batch baseline. If the count INCREASED, investigate the new ones.

- [ ] **Step 3: Confirm git state**

Run: `git log --oneline main..HEAD` (or, if this batch was done directly on main: `git log --oneline -10`)
Expected: ~6 commits for Batch 2.

Run: `git status`
Expected: clean working tree (only `.claude/` untracked).

- [ ] **Step 4: Visual smoke test (manual, by user)**

Run the app: `flutter run`. Click through:
- Home → empty competitions list (if no data) — should show EmptyState
- Competition detail → loading state — should show LoadingIndicator
- Slot view (with no results) → should show EmptyState with "results will appear here"
- Slot view error path (if reachable) → ErrorState with retry button

Visual regressions to check: spacing between icon and text in empty states (should be 16 px, not whatever the old hardcoded value was), pill rounding on status badges (should be fully pill), error message color (red).

If anything looks off, file the visual fix as a follow-up — don't block Batch 3 on it.

---

## Self-review

**Spec coverage** (against §14 "Batch 2 — Theme + shared widgets"):
- `core/theme/`: AppColors, AppSpacing, AppRadius, AppTypography → Task 1 ✓
- Wire into `appThemeData` → Task 2 ✓
- Extract `EmptyState`, `ErrorState`, `LoadingIndicator`, `StatusBadge`, `SectionHeader` → Tasks 3 + 4 ✓
- Apply to big views → Task 6 (opportunistic only — full migration during view-rebuild batches) ✓
- No controller changes → confirmed; no controller files in any task's file list ✓
- Move existing `LanguageSelector` to new home → Task 5 ✓

**Placeholder scan:** None. The deferral of full view migration to later batches is documented at the top in Notes & deviations.

**Type consistency:**
- `AppColors` constants are referenced from `AppTypography` (textPrimary, textSecondary, textMuted, statusError) — names match. ✓
- `AppRadius` has both `double sm` and `BorderRadius smRadius` — naming convention is `<size>` for the double, `<size>Radius` for the BorderRadius. ✓
- Shared widgets import `AppColors`, `AppSpacing`, `AppTypography` consistently. ✓
- `StatusBadge` uses `AppRadius.pillRadius` (BorderRadius), `AppTypography.badge` (TextStyle) — both match the token API. ✓
- `LoadingIndicator(compact: true)` is the documented inline form — applied that way in Task 6 Step 4. ✓

---

## Done criteria for Batch 2

- 6 commits on a feature branch (`refactor/batch-2-theme` or wherever).
- 9 new files (4 tokens + 5 shared widgets).
- 1 file moved (LanguageSelector).
- 2-7 view files modified (token + shared widget application).
- `flutter analyze`: zero errors; warnings/info baseline unchanged or lower.
- `flutter test`: 59 tests, all green.
- App still launches and the screens look effectively unchanged (≤ 4 pixels of spacing drift in any spot is acceptable).
