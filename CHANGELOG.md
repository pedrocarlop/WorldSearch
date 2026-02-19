# CHANGELOG

## 2026-02-10

### feat(front): SwiftUI visual layer rewrite with DS composition and localization
- Added reusable Design System primitives:
  - `Packages/AppModules/Sources/DesignSystem/Components/Layout/DSPageBackgroundView.swift`
  - `Packages/AppModules/Sources/DesignSystem/Components/Layout/DSSurfacePanel.swift`
  - `Packages/AppModules/Sources/DesignSystem/Components/Layout/DSStatusBadge.swift`
  - `Packages/AppModules/Sources/DesignSystem/Components/Layout/DSCircularProgressRing.swift`
  - `Packages/AppModules/Sources/DesignSystem/Components/Layout/WordSearchBoardStylePreset.swift`
- Updated title typography tokens to use `InstrumentSerif-Regular` with system fallback.
- Refactored home composition into reusable host views:
  - `WorldCrush/Home/HomeScreenLayout.swift`
  - `WorldCrush/ContentView.swift`
- Refactored puzzle UI views for smaller focused files:
  - `Packages/AppModules/Sources/FeatureDailyPuzzle/Presentation/Views/DailyPuzzleGameBoardView.swift`
  - `Packages/AppModules/Sources/FeatureDailyPuzzle/Presentation/Views/DailyPuzzleGameBoardCelebrationViews.swift`
  - `Packages/AppModules/Sources/FeatureDailyPuzzle/Presentation/Views/DailyPuzzleLoupeView.swift`
  - `Packages/AppModules/Sources/FeatureDailyPuzzle/Presentation/Views/DailyPuzzleCompletionOverlayView.swift`
- Refined settings sheet composition while preserving save/cancel behavior:
  - `Packages/AppModules/Sources/FeatureSettings/Presentation/Views/SettingsSheetView.swift`
- Split widget UI by responsibility:
  - `WordSearchWidgetExtension/WordSearchWidget.swift`
  - `WordSearchWidgetExtension/WordSearchWidgetAppearance.swift`
  - `WordSearchWidgetExtension/WordSearchGridWidgetView.swift`
- Added typed localization wrappers and String Catalogs (`es` + `en`) for app, widget and feature/core modules.
- Migrated `WordHintsService` definitions to localized resources and added package resource processing for Core/Feature modules.
- Added widget font registration and bundled `InstrumentSerif-Regular.ttf` for extension rendering.
- Added localization-focused smoke tests:
  - `Packages/AppModules/Tests/CoreTests/WordHintsLocalizationTests.swift`
  - `Packages/AppModules/Tests/FeatureDailyPuzzleTests/DailyPuzzleStringsTests.swift`
  - `Packages/AppModules/Tests/FeatureSettingsTests/SettingsStringsTests.swift`
  - `Packages/AppModules/Tests/FeatureHistoryTests/HistoryStringsTests.swift`

### chore(repo): clean tracked build artifacts and ignores
- Added `.gitignore` with Swift/Xcode/SwiftPM ignores.
- Removed tracked files under `Packages/AppModules/.build` from version control to eliminate build-noise churn.

### perf(home): cache carousel/card computation
- Added `DailyPuzzleChallengeCardState` in `Packages/AppModules/Sources/FeatureDailyPuzzle/Presentation/ViewModels/DailyPuzzleHomeScreenViewModel.swift`.
- Added cached derived state (`carouselOffsets`, `challengeCards`) and centralized rebuild flow on refresh/unlock.
- Updated `WorldCrush/ContentView.swift` to render from cached card states instead of recomputing puzzle/progress per card in `body`.

### perf(core+ui): memoize word path lookups and reduce repeated work
- Added memoization layer in `Packages/AppModules/Sources/Core/Domain/Services/WordPathFinderService.swift`.
- Cached best path resolution by word + grid + solved positions signature to reduce repeated pathfinding in app and widget render paths.

### refactor(game): task lifecycle safety and clearer UI state grouping
- Refactored `Packages/AppModules/Sources/FeatureDailyPuzzle/Presentation/Views/DailyPuzzleGameScreenView.swift`:
  - Grouped entry/completion overlay flags in typed state structs.
  - Added explicit task handles for entry transition and feedback-dismiss tasks.
  - Added cancellation on disappear/reset to avoid orphan tasks.
  - Moved timing magic numbers to local constants.
- Refactored `WorldCrush/ContentView.swift`:
  - Added cancellable `presentGameTask`.
  - Canceled pending launch tasks on disappear/close.
  - Replaced launch timing magic numbers with constants.

### refactor(core): centralize progress record selection policy
- Added `Packages/AppModules/Sources/Core/Utilities/ProgressRecordResolver.swift`.
- Reused resolver in:
  - `Packages/AppModules/Sources/Core/Data/Repositories/LocalProgressRepository.swift`
  - `Packages/AppModules/Sources/FeatureDailyPuzzle/Presentation/ViewModels/DailyPuzzleHomeScreenViewModel.swift`

### quality(observability): structured logging and debug guardrails
- Added `Packages/AppModules/Sources/Core/Utilities/AppLogger.swift`.
- Added structured error logging in persistence/migration hot paths:
  - `Packages/AppModules/Sources/Core/Data/Persistence/KeyValueStore.swift`
  - `Packages/AppModules/Sources/Core/Data/Repositories/LocalProgressRepository.swift`
  - `Packages/AppModules/Sources/Core/Data/Repositories/LocalSharedPuzzleRepository.swift`

### cleanup: dead code removal and loupe unification
- Added shared loupe models in `Packages/AppModules/Sources/Core/Utilities/LoupeState.swift`.
- Unified app-local loupe wrapper in `WorldCrush/LoupeStateModels.swift` as typealiases to core models.
- Updated `Packages/AppModules/Sources/FeatureDailyPuzzle/Presentation/Views/DailyPuzzleGameBoardView.swift` to use shared core loupe types and removed duplicate local implementation.
- Removed confirmed unused files:
  - `Packages/AppModules/Sources/Core/Domain/Errors/DomainError.swift`
  - `Packages/AppModules/Sources/FeatureDailyPuzzle/Presentation/Views/DailyPuzzleRootView.swift`
  - `Packages/AppModules/Sources/FeatureDailyPuzzle/Presentation/ViewModels/DailyPuzzleHomeViewModel.swift`
  - `Packages/AppModules/Sources/FeatureDailyPuzzle/Presentation/UIModels/DailyPuzzleUIModel.swift`
  - `Packages/AppModules/Sources/FeatureDailyPuzzle/Presentation/Mappers/DailyPuzzleUIMapper.swift`
  - `Packages/AppModules/Sources/FeatureSettings/Presentation/Views/SettingsPanelView.swift`
  - `Packages/AppModules/Sources/FeatureHistory/Presentation/Views/HistorySummaryView.swift`
- Removed now-dead API from `Packages/AppModules/Sources/FeatureDailyPuzzle/DI/DailyPuzzleContainer.swift` (`makeRootViewModel`).

### ux copy consistency
- Normalized settings appearance labels in `Packages/AppModules/Sources/FeatureSettings/Presentation/Views/SettingsSheetView.swift`:
  - `System/Light/Dark` -> `Sistema/Claro/Oscuro`.

### tests
- Expanded tests:
  - `Packages/AppModules/Tests/CoreTests/DataLayerTests.swift`
    - Added `ProgressRecordResolver` behavior coverage.
    - Added integration coverage for shared progress persistence, hint-dismiss persistence, and daily rotation boundary updates.
  - `Packages/AppModules/Tests/FeatureDailyPuzzleTests/DailyPuzzleHomeScreenViewModelTests.swift`
    - Added cached challenge-card state coverage.

### perf(board+widget): precompute solved outlines and avoid repeated mapping
- Refactored `Packages/AppModules/Sources/FeatureDailyPuzzle/Presentation/Views/DailyPuzzleGameBoardView.swift`:
  - Precomputes solved word outlines in `init` using a single `PuzzleGrid` instance.
  - Reuses pre-mapped `SharedWordSearchBoardOutline` models instead of rebuilding them during every view refresh.
- Refactored `WordSearchWidgetExtension/WordSearchWidget.swift`:
  - Precomputes solved outlines once per widget view init and reuses mapped outline models.
  - Removes repeated uppercase/path lookup work from render path.
- Removed now-unused helper in `WordSearchWidgetExtension/WordSearchIntents.swift` (`WordSearchLogic`).

### perf(home): avoid rebuilding carousel offsets when unchanged
- Updated `Packages/AppModules/Sources/FeatureDailyPuzzle/Presentation/ViewModels/DailyPuzzleHomeScreenViewModel.swift` to skip recreating `carouselOffsets` unless range bounds changed.

### quality(core): add debug guardrail for invalid preferred grid size
- Added debug assertion in `Packages/AppModules/Sources/Core/Utilities/ProgressRecordResolver.swift` for non-positive `preferredGridSize`.

### quality(lint): add SwiftLint baseline configuration
- Added `.swiftlint.yml` with project include/exclude scope and baseline rules/thresholds.
- Added `Scripts/lint.sh` to run strict linting in environments where `swiftlint` is installed.

### fix(board): disambiguate domain Grid type
- Qualified domain-grid usages as `Core.PuzzleGrid` in `Packages/AppModules/Sources/FeatureDailyPuzzle/Presentation/Views/DailyPuzzleGameBoardView.swift` to avoid collision with `SwiftUI.Grid`.
- Applied the same explicit qualification in:
  - `WordSearchWidgetExtension/WordSearchWidget.swift`
  - `Packages/AppModules/Sources/FeatureDailyPuzzle/Presentation/Views/DailyPuzzleChallengeCardView.swift`

### refactor(core): rename `Grid` domain model to `PuzzleGrid`
- Renamed the core domain type to reduce naming collisions and improve semantic clarity across modules.
- Updated all dependent services and call sites:
  - `Packages/AppModules/Sources/Core/Domain/Entities/WordSearchEntities.swift`
  - `Packages/AppModules/Sources/Core/Domain/Services/SelectionValidationService.swift`
  - `Packages/AppModules/Sources/Core/Domain/Services/WordPathFinderService.swift`
  - `Packages/AppModules/Sources/Core/Domain/Services/PuzzleFactory.swift`
  - `Packages/AppModules/Sources/Core/Domain/Services/SharedPuzzleLogicService.swift`
  - `Packages/AppModules/Sources/Core/Data/Repositories/LocalSharedPuzzleRepository.swift`
  - `Packages/AppModules/Sources/FeatureDailyPuzzle/Presentation/ViewModels/DailyPuzzleHomeScreenViewModel.swift`
  - `Packages/AppModules/Tests/CoreTests/DomainRulesTests.swift`
  - `Packages/AppModules/Tests/FeatureDailyPuzzleTests/DailyPuzzleGameSessionViewModelTests.swift`

## Key files modified and why
- `WorldCrush/ContentView.swift`: stop expensive card recomputation in `body`, cancel pending transition tasks safely.
- `Packages/AppModules/Sources/FeatureDailyPuzzle/Presentation/ViewModels/DailyPuzzleHomeScreenViewModel.swift`: precomputed card state cache and central progress resolver.
- `Packages/AppModules/Sources/Core/Domain/Services/WordPathFinderService.swift`: shared memoization to reduce repeated pathfinding.
- `Packages/AppModules/Sources/FeatureDailyPuzzle/Presentation/Views/DailyPuzzleGameScreenView.swift`: task lifecycle hardening and grouped UI-state flags.
- `Packages/AppModules/Sources/Core/Data/Repositories/LocalSharedPuzzleRepository.swift`: migration/persistence error logging.
