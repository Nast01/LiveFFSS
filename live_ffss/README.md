# live_ffss

Flutter app for live tracking of FFSS (Fédération Française de Sauvetage et de Secourisme) competitions.

## Architecture

The app uses a 3-layer pragmatic split: `Controller → Repository → DataSource`. State management and DI go through GetX. Data types are immutable (`freezed`), JSON shapes from the FFSS API live in `lib/app/data/dtos/` and map to clean domain types in `lib/app/domain/models/` via mappers.

Design spec: [`docs/superpowers/specs/2026-04-25-architecture-refactor-design.md`](docs/superpowers/specs/2026-04-25-architecture-refactor-design.md)
Implementation plans: [`docs/superpowers/plans/`](docs/superpowers/plans/)

```
lib/
├── main.dart
├── app/
│   ├── core/
│   │   ├── config/             AppConfig (env-driven)
│   │   ├── di/                 InitialBinding (single GetX registration point)
│   │   ├── enums/
│   │   ├── errors/             AppException sealed hierarchy
│   │   ├── network/            HttpClient (auth header, error mapping), TokenStorage
│   │   ├── theme/              AppColors, AppSpacing, AppRadius, AppTypography
│   │   ├── translations/       fr_FR / en_US arb-style
│   │   └── utils/
│   ├── data/
│   │   ├── dtos/               1:1 with API JSON (freezed + json_serializable)
│   │   ├── datasources/        Per-domain abstract + Impl (HttpClient-backed)
│   │   ├── mappers/            DTO -> domain extensions
│   │   └── repositories/       Per-domain abstract + Impl
│   ├── domain/
│   │   └── models/             Pure domain types (freezed, no JSON keys)
│   ├── presentation/
│   │   ├── shared/             EmptyState, ErrorState, LoadingIndicator, etc.
│   │   └── modules/            Per-feature view-side helpers (formatters, extensions)
│   ├── module/                 GetX modules: auth, home, competitions, program, slot
│   └── routes/
└── ...
```

## Tooling

- **Flutter:** 3.22.2 / Dart 3.4.3
- **Code generation:** `freezed`, `json_serializable`, `build_runner`
- **Testing:** `mocktail` for unit tests on mappers / repositories / controllers (~127 tests)
- **HTTP:** `package:http` wrapped in `lib/app/core/network/http_client.dart`
- **Secure storage:** `flutter_secure_storage` (single `'user'` key for the persisted session)

## Running locally

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

The dev/prod environment is currently single (`https://ffss.fr`) but the seam exists in `AppConfig.fromEnv()` — pass `--dart-define=ENV=...` to switch when more environments are added.

## Tests

```bash
flutter test
```

Test coverage focuses on the logic layers:
- Mappers (`test/data/mappers/`) — DTO → domain transformations.
- Repositories (`test/data/repositories/`) — orchestration with mocked data sources.
- Controllers (`test/presentation/modules/...`) — state transitions with mocked repositories.

UI is not covered (no widget/integration tests).

## Known gaps

- **Live results / mutations:** the four FFSS endpoints used by the slot module (`getRunResults`, `updateBeachRankings`, `updateSwimmingTimes`, `withdrawAthlete`) are not documented. `ResultRepository` throws `UnimplementedError` for these — same as the legacy stubbed state, but behind a clean typed seam ready to wire when the backend story is clarified.
- **Rankings feature:** `CompetitionDetailController.clubRankingsLimited` returns an empty list. The "Rankings" tab in the competition detail view shows no data.

## Localization

`lib/app/core/translations/` holds the French and English string tables. Translation keys are referenced via `'key'.tr` (GetX). The `LanguageService` exposes the current locale and a `changeLanguage()` setter.
