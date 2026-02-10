# CHANGELOG

## 2026-02-10

### feat(front): SwiftUI visual layer rewrite with DS composition and localization
- Added reusable Design System primitives:
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/DesignSystem/Components/Layout/DSPageBackgroundView.swift`
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/DesignSystem/Components/Layout/DSSurfacePanel.swift`
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/DesignSystem/Components/Layout/DSStatusBadge.swift`
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/DesignSystem/Components/Layout/DSCircularProgressRing.swift`
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/DesignSystem/Components/Layout/WordSearchBoardStylePreset.swift`
- Updated title typography tokens to use `InstrumentSerif-Regular` with system fallback.
- Refactored home composition into reusable host views:
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/miapp/Home/HomeScreenLayout.swift`
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/miapp/ContentView.swift`
- Refactored puzzle UI views for smaller focused files:
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/FeatureDailyPuzzle/Presentation/Views/DailyPuzzleGameBoardView.swift`
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/FeatureDailyPuzzle/Presentation/Views/DailyPuzzleGameBoardCelebrationViews.swift`
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/FeatureDailyPuzzle/Presentation/Views/DailyPuzzleLoupeView.swift`
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/FeatureDailyPuzzle/Presentation/Views/DailyPuzzleCompletionOverlayView.swift`
- Refined settings sheet composition while preserving save/cancel behavior:
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/FeatureSettings/Presentation/Views/SettingsSheetView.swift`
- Split widget UI by responsibility:
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/WordSearchWidgetExtension/WordSearchWidget.swift`
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/WordSearchWidgetExtension/WordSearchWidgetAppearance.swift`
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/WordSearchWidgetExtension/WordSearchGridWidgetView.swift`
- Added typed localization wrappers and String Catalogs (`es` + `en`) for app, widget and feature/core modules.
- Migrated `WordHintsService` definitions to localized resources and added package resource processing for Core/Feature modules.
- Added widget font registration and bundled `InstrumentSerif-Regular.ttf` for extension rendering.
- Added localization-focused smoke tests:
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Tests/CoreTests/WordHintsLocalizationTests.swift`
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Tests/FeatureDailyPuzzleTests/DailyPuzzleStringsTests.swift`
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Tests/FeatureSettingsTests/SettingsStringsTests.swift`
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Tests/FeatureHistoryTests/HistoryStringsTests.swift`

### chore(repo): clean tracked build artifacts and ignores
- Added `/Users/pedrocarrascolopezbrea/Projects/miapp/.gitignore` with Swift/Xcode/SwiftPM ignores.
- Removed tracked files under `Packages/AppModules/.build` from version control to eliminate build-noise churn.

### perf(home): cache carousel/card computation
- Added `DailyPuzzleChallengeCardState` in `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/FeatureDailyPuzzle/Presentation/ViewModels/DailyPuzzleHomeScreenViewModel.swift`.
- Added cached derived state (`carouselOffsets`, `challengeCards`) and centralized rebuild flow on refresh/unlock.
- Updated `/Users/pedrocarrascolopezbrea/Projects/miapp/miapp/ContentView.swift` to render from cached card states instead of recomputing puzzle/progress per card in `body`.

### perf(core+ui): memoize word path lookups and reduce repeated work
- Added memoization layer in `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/Core/Domain/Services/WordPathFinderService.swift`.
- Cached best path resolution by word + grid + solved positions signature to reduce repeated pathfinding in app and widget render paths.

### refactor(game): task lifecycle safety and clearer UI state grouping
- Refactored `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/FeatureDailyPuzzle/Presentation/Views/DailyPuzzleGameScreenView.swift`:
  - Grouped entry/completion overlay flags in typed state structs.
  - Added explicit task handles for entry transition and feedback-dismiss tasks.
  - Added cancellation on disappear/reset to avoid orphan tasks.
  - Moved timing magic numbers to local constants.
- Refactored `/Users/pedrocarrascolopezbrea/Projects/miapp/miapp/ContentView.swift`:
  - Added cancellable `presentGameTask`.
  - Canceled pending launch tasks on disappear/close.
  - Replaced launch timing magic numbers with constants.

### refactor(core): centralize progress record selection policy
- Added `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/Core/Utilities/ProgressRecordResolver.swift`.
- Reused resolver in:
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/Core/Data/Repositories/LocalProgressRepository.swift`
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/FeatureDailyPuzzle/Presentation/ViewModels/DailyPuzzleHomeScreenViewModel.swift`

### quality(observability): structured logging and debug guardrails
- Added `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/Core/Utilities/AppLogger.swift`.
- Added structured error logging in persistence/migration hot paths:
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/Core/Data/Persistence/KeyValueStore.swift`
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/Core/Data/Repositories/LocalProgressRepository.swift`
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/Core/Data/Repositories/LocalSharedPuzzleRepository.swift`

### cleanup: dead code removal and loupe unification
- Added shared loupe models in `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/Core/Utilities/LoupeState.swift`.
- Unified app-local loupe wrapper in `/Users/pedrocarrascolopezbrea/Projects/miapp/miapp/LoupeStateModels.swift` as typealiases to core models.
- Updated `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/FeatureDailyPuzzle/Presentation/Views/DailyPuzzleGameBoardView.swift` to use shared core loupe types and removed duplicate local implementation.
- Removed confirmed unused files:
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/Core/Domain/Errors/DomainError.swift`
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/FeatureDailyPuzzle/Presentation/Views/DailyPuzzleRootView.swift`
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/FeatureDailyPuzzle/Presentation/ViewModels/DailyPuzzleHomeViewModel.swift`
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/FeatureDailyPuzzle/Presentation/UIModels/DailyPuzzleUIModel.swift`
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/FeatureDailyPuzzle/Presentation/Mappers/DailyPuzzleUIMapper.swift`
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/FeatureSettings/Presentation/Views/SettingsPanelView.swift`
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/FeatureHistory/Presentation/Views/HistorySummaryView.swift`
- Removed now-dead API from `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/FeatureDailyPuzzle/DI/DailyPuzzleContainer.swift` (`makeRootViewModel`).

### ux copy consistency
- Normalized settings appearance labels in `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/FeatureSettings/Presentation/Views/SettingsSheetView.swift`:
  - `System/Light/Dark` -> `Sistema/Claro/Oscuro`.

### tests
- Expanded tests:
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Tests/CoreTests/DataLayerTests.swift`
    - Added `ProgressRecordResolver` behavior coverage.
    - Added integration coverage for shared progress persistence, hint-dismiss persistence, and daily rotation boundary updates.
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Tests/FeatureDailyPuzzleTests/DailyPuzzleHomeScreenViewModelTests.swift`
    - Added cached challenge-card state coverage.

### perf(board+widget): precompute solved outlines and avoid repeated mapping
- Refactored `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/FeatureDailyPuzzle/Presentation/Views/DailyPuzzleGameBoardView.swift`:
  - Precomputes solved word outlines in `init` using a single `PuzzleGrid` instance.
  - Reuses pre-mapped `SharedWordSearchBoardOutline` models instead of rebuilding them during every view refresh.
- Refactored `/Users/pedrocarrascolopezbrea/Projects/miapp/WordSearchWidgetExtension/WordSearchWidget.swift`:
  - Precomputes solved outlines once per widget view init and reuses mapped outline models.
  - Removes repeated uppercase/path lookup work from render path.
- Removed now-unused helper in `/Users/pedrocarrascolopezbrea/Projects/miapp/WordSearchWidgetExtension/WordSearchIntents.swift` (`WordSearchLogic`).

### perf(home): avoid rebuilding carousel offsets when unchanged
- Updated `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/FeatureDailyPuzzle/Presentation/ViewModels/DailyPuzzleHomeScreenViewModel.swift` to skip recreating `carouselOffsets` unless range bounds changed.

### quality(core): add debug guardrail for invalid preferred grid size
- Added debug assertion in `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/Core/Utilities/ProgressRecordResolver.swift` for non-positive `preferredGridSize`.

### quality(lint): add SwiftLint baseline configuration
- Added `/Users/pedrocarrascolopezbrea/Projects/miapp/.swiftlint.yml` with project include/exclude scope and baseline rules/thresholds.
- Added `/Users/pedrocarrascolopezbrea/Projects/miapp/Scripts/lint.sh` to run strict linting in environments where `swiftlint` is installed.

### fix(board): disambiguate domain Grid type
- Qualified domain-grid usages as `Core.PuzzleGrid` in `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/FeatureDailyPuzzle/Presentation/Views/DailyPuzzleGameBoardView.swift` to avoid collision with `SwiftUI.Grid`.
- Applied the same explicit qualification in:
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/WordSearchWidgetExtension/WordSearchWidget.swift`
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/FeatureDailyPuzzle/Presentation/Views/DailyPuzzleChallengeCardView.swift`

### refactor(core): rename `Grid` domain model to `PuzzleGrid`
- Renamed the core domain type to reduce naming collisions and improve semantic clarity across modules.
- Updated all dependent services and call sites:
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/Core/Domain/Entities/WordSearchEntities.swift`
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/Core/Domain/Services/SelectionValidationService.swift`
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/Core/Domain/Services/WordPathFinderService.swift`
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/Core/Domain/Services/PuzzleFactory.swift`
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/Core/Domain/Services/SharedPuzzleLogicService.swift`
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/Core/Data/Repositories/LocalSharedPuzzleRepository.swift`
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/FeatureDailyPuzzle/Presentation/ViewModels/DailyPuzzleHomeScreenViewModel.swift`
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Tests/CoreTests/DomainRulesTests.swift`
  - `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Tests/FeatureDailyPuzzleTests/DailyPuzzleGameSessionViewModelTests.swift`

## Key files modified and why
- `/Users/pedrocarrascolopezbrea/Projects/miapp/miapp/ContentView.swift`: stop expensive card recomputation in `body`, cancel pending transition tasks safely.
- `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/FeatureDailyPuzzle/Presentation/ViewModels/DailyPuzzleHomeScreenViewModel.swift`: precomputed card state cache and central progress resolver.
- `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/Core/Domain/Services/WordPathFinderService.swift`: shared memoization to reduce repeated pathfinding.
- `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/FeatureDailyPuzzle/Presentation/Views/DailyPuzzleGameScreenView.swift`: task lifecycle hardening and grouped UI-state flags.
- `/Users/pedrocarrascolopezbrea/Projects/miapp/Packages/AppModules/Sources/Core/Data/Repositories/LocalSharedPuzzleRepository.swift`: migration/persistence error logging.
