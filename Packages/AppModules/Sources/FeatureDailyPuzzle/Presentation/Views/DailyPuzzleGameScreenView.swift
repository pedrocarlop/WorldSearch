import SwiftUI
import Core
import DesignSystem

public struct DailyPuzzleSharedSyncContext: Sendable {
    public let puzzleIndex: Int

    public init(puzzleIndex: Int) {
        self.puzzleIndex = puzzleIndex
    }
}

public struct DailyPuzzleCelebrationPreferences: Equatable, Sendable {
    public let enableCelebrations: Bool
    public let enableHaptics: Bool
    public let enableSound: Bool
    public let intensity: CelebrationIntensity

    public init(
        enableCelebrations: Bool,
        enableHaptics: Bool,
        enableSound: Bool,
        intensity: CelebrationIntensity
    ) {
        self.enableCelebrations = enableCelebrations
        self.enableHaptics = enableHaptics
        self.enableSound = enableSound
        self.intensity = intensity
    }
}

private enum DailyPuzzleSelectionFeedbackKind {
    case correct
    case incorrect
}

private struct DailyPuzzleSelectionFeedback: Identifiable {
    let id = UUID()
    let kind: DailyPuzzleSelectionFeedbackKind
    let positions: [GridPosition]
}

private struct DailyPuzzleEntryState {
    var boardVisible = false
    var bottomVisible = false
    var didRun = false
}

private struct DailyPuzzleCompletionOverlayState {
    var isVisible = false
    var showsBackdrop = false
    var showsToast = false
    var streakLabel: String?

    static let hidden = DailyPuzzleCompletionOverlayState()
}

private struct DailyPuzzleCelebrationConfig {
    let brushDuration: TimeInterval
    let waveDuration: TimeInterval
    let sparkleTailDuration: TimeInterval

    static let `default` = DailyPuzzleCelebrationConfig(
        brushDuration: 0.18,
        waveDuration: 0.42,
        sparkleTailDuration: 0.16
    )
}

@MainActor
private final class DailyPuzzleCelebrationController: ObservableObject {
    @Published private(set) var boardCelebrations: [DailyPuzzleBoardCelebration] = []

    private let config = DailyPuzzleCelebrationConfig.default

    func celebrateWord(
        pathCells: [GridPosition],
        preferences: DailyPuzzleCelebrationPreferences,
        reduceMotion: Bool,
        onFeedback: (DailyPuzzleCelebrationPreferences) -> Void
    ) {
        onFeedback(preferences)

        guard preferences.enableCelebrations else { return }
        guard !pathCells.isEmpty else { return }

        let celebration = DailyPuzzleBoardCelebration(
            positions: pathCells,
            intensity: preferences.intensity,
            popDuration: config.brushDuration,
            particleDuration: config.waveDuration,
            reduceMotion: reduceMotion
        )

        boardCelebrations.append(celebration)

        let adjustedWaveDuration = max(
            config.waveDuration * preferences.intensity.sequenceWaveFactor,
            Double(pathCells.count) * 0.045
        )
        let removalDelay = config.brushDuration + adjustedWaveDuration + config.sparkleTailDuration
        Task {
            try? await Task.sleep(nanoseconds: UInt64(removalDelay * 1_000_000_000))
            await MainActor.run {
                withAnimation(.easeOut(duration: 0.18)) {
                    boardCelebrations.removeAll { $0.id == celebration.id }
                }
            }
        }
    }
}

private extension CelebrationIntensity {
    var sequenceWaveFactor: Double {
        switch self {
        case .low:
            return 1.08
        case .medium:
            return 1
        case .high:
            return 0.9
        }
    }
}

public struct DailyPuzzleGameScreenView: View {
    private enum Constants {
        static let entryBoardDuration: Double = 0.22
        static let entryBottomSpringResponse: Double = 0.34
        static let entryBottomSpringDamping: Double = 0.88
        static let entryBottomDelayNanos: UInt64 = 90_000_000

        static let feedbackShowDuration: Double = 0.2
        static let feedbackHideDelayNanos: UInt64 = 650_000_000

        static let completionBackdropDuration: Double = 0.12
        static let completionToastDelayNanos: UInt64 = 120_000_000
        static let completionAutoDismissDelayNanos: UInt64 = 1_500_000_000
        static let completionHideToastDuration: Double = 0.14
        static let completionHideToastDelayNanos: UInt64 = 100_000_000
        static let completionHideBackdropDuration: Double = 0.1
        static let completionHideBackdropDelayNanos: UInt64 = 110_000_000
    }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    public let core: CoreContainer
    public let dayOffset: Int
    public let todayOffset: Int
    public let navigationTitle: String
    public let puzzle: Puzzle
    public let gridSize: Int
    public let wordHintMode: WordHintMode
    public let initialProgress: AppProgressRecord?
    public let sharedSync: DailyPuzzleSharedSyncContext?
    public let onProgressUpdate: () -> Void
    public let onClose: (() -> Void)?
    public let celebrationPreferencesProvider: () -> DailyPuzzleCelebrationPreferences
    public let onWordFeedback: (DailyPuzzleCelebrationPreferences) -> Void
    public let onCompletionFeedback: (DailyPuzzleCelebrationPreferences) -> Void
    public let onSharedStateMutation: () -> Void

    @StateObject private var celebrationController = DailyPuzzleCelebrationController()
    @State private var gameSession: DailyPuzzleGameSessionViewModel
    @State private var activeSelection: [GridPosition] = []
    @State private var dragAnchor: GridPosition?
    @State private var selectionFeedback: DailyPuzzleSelectionFeedback?
    @State private var feedbackNonce = 0
    @State private var showResetAlert = false
    @State private var entryState = DailyPuzzleEntryState()
    @State private var completionOverlay = DailyPuzzleCompletionOverlayState.hidden
    @State private var entryTransitionTask: Task<Void, Never>?
    @State private var feedbackDismissTask: Task<Void, Never>?
    @State private var completionOverlayTask: Task<Void, Never>?

    public init(
        core: CoreContainer,
        dayOffset: Int,
        todayOffset: Int,
        navigationTitle: String,
        puzzle: Puzzle,
        gridSize: Int,
        wordHintMode: WordHintMode,
        initialProgress: AppProgressRecord?,
        sharedSync: DailyPuzzleSharedSyncContext?,
        onProgressUpdate: @escaping () -> Void,
        onClose: (() -> Void)? = nil,
        celebrationPreferencesProvider: @escaping () -> DailyPuzzleCelebrationPreferences,
        onWordFeedback: @escaping (DailyPuzzleCelebrationPreferences) -> Void = { _ in },
        onCompletionFeedback: @escaping (DailyPuzzleCelebrationPreferences) -> Void = { _ in },
        onSharedStateMutation: @escaping () -> Void = {}
    ) {
        self.core = core
        self.dayOffset = dayOffset
        self.todayOffset = todayOffset
        self.navigationTitle = navigationTitle
        self.puzzle = puzzle
        self.gridSize = gridSize
        self.wordHintMode = wordHintMode
        self.initialProgress = initialProgress
        self.sharedSync = sharedSync
        self.onProgressUpdate = onProgressUpdate
        self.onClose = onClose
        self.celebrationPreferencesProvider = celebrationPreferencesProvider
        self.onWordFeedback = onWordFeedback
        self.onCompletionFeedback = onCompletionFeedback
        self.onSharedStateMutation = onSharedStateMutation

        let initialFoundWords = Set(initialProgress?.foundWords ?? [])
        let initialSolvedPositions = Set(initialProgress?.solvedPositions ?? [])

        _gameSession = State(
            initialValue: DailyPuzzleGameSessionViewModel(
                dayKey: DayKey(offset: dayOffset),
                gridSize: gridSize,
                puzzle: puzzle,
                foundWords: initialFoundWords,
                solvedPositions: initialSolvedPositions,
                startedAt: initialProgress?.startedDate,
                endedAt: initialProgress?.endedDate
            )
        )
    }

    private var isCompleted: Bool {
        gameSession.isCompleted
    }

    public var body: some View {
        ZStack {
            ThemeGradients.paperBackground
                .ignoresSafeArea()

            DSGridBackgroundView(spacing: SpacingTokens.xxxl, opacity: 0.09)
                .ignoresSafeArea()

            GeometryReader { geometry in
                let side = min(geometry.size.width - SpacingTokens.xl, 420)

                VStack(spacing: SpacingTokens.lg) {
                    DailyPuzzleGameBoardView(
                        grid: puzzle.grid.letters,
                        words: puzzle.words.map(\.text),
                        foundWords: gameSession.foundWords,
                        solvedPositions: gameSession.solvedPositions,
                        activePositions: activeSelection,
                        feedback: selectionFeedback.map {
                            DailyPuzzleBoardFeedback(
                                id: $0.id,
                                kind: $0.kind == .correct ? .correct : .incorrect,
                                positions: $0.positions
                            )
                        },
                        celebrations: celebrationController.boardCelebrations,
                        sideLength: side
                    ) { position in
                        guard !isCompleted else { return }
                        handleDragChanged(position)
                    } onDragEnded: {
                        guard !isCompleted else { return }
                        handleDragEnded()
                    }
                    .opacity(entryState.boardVisible ? 1 : 0)
                    .scaleEffect(entryState.boardVisible ? 1 : 0.98)

                    objectivesView
                        .offset(y: entryState.bottomVisible ? 0 : 24)
                        .opacity(entryState.bottomVisible ? 1 : 0)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .clipped()
                }
                .padding(.horizontal, SpacingTokens.md)
                .padding(.top, SpacingTokens.sm)
                .padding(.bottom, 0)
            }
            .allowsHitTesting(!completionOverlay.isVisible)

            if completionOverlay.isVisible {
                DailyPuzzleCompletionOverlayView(
                    showBackdrop: completionOverlay.showsBackdrop,
                    showToast: completionOverlay.showsToast,
                    streakLabel: completionOverlay.streakLabel,
                    reduceMotion: reduceMotion,
                    reduceTransparency: reduceTransparency,
                    onTapDismiss: {
                        Task { @MainActor in
                            await dismissCompletionOverlay()
                        }
                    }
                )
                .transition(.opacity)
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let onClose {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: onClose) {
                        Image(systemName: "chevron.down")
                    }
                    .accessibilityLabel("Cerrar")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showResetAlert = true
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                }
                .accessibilityLabel("Reiniciar reto")
            }
        }
        .onAppear {
            if gameSession.startIfNeeded() {
                saveProgress()
            }
            runEntryTransition()
        }
        .onDisappear {
            entryTransitionTask?.cancel()
            entryTransitionTask = nil
            feedbackDismissTask?.cancel()
            feedbackDismissTask = nil
            completionOverlayTask?.cancel()
            completionOverlayTask = nil
        }
        .alert("Reiniciar reto", isPresented: $showResetAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Reiniciar", role: .destructive) {
                resetProgress()
            }
        } message: {
            Text("Se borrara el progreso de este dia.")
        }
    }

    private var objectivesView: some View {
        DailyPuzzleWordsView(
            words: puzzle.words.map(\.text),
            foundWords: gameSession.foundWords,
            displayMode: wordHintMode
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func handleDragChanged(_ position: GridPosition) {
        if dragAnchor == nil {
            dragAnchor = position
            activeSelection = [position]
            if gameSession.startIfNeeded() {
                saveProgress()
            }
            return
        }

        guard let anchor = dragAnchor else { return }
        let direction = SelectionValidationService.snappedDirection(from: anchor, to: position)
        activeSelection = SelectionValidationService.selectionPath(
            from: anchor,
            to: position,
            direction: direction,
            grid: puzzle.grid
        )
    }

    private func handleDragEnded() {
        let selection = activeSelection
        dragAnchor = nil
        activeSelection = []
        guard selection.count >= 2 else { return }
        finalizeSelection(selection)
    }

    private func finalizeSelection(_ positions: [GridPosition]) {
        let outcome = gameSession.finalizeSelection(positions)
        switch outcome.kind {
        case .ignored:
            return
        case .incorrect:
            showFeedback(kind: .incorrect, positions: positions)
            return
        case .correct:
            showFeedback(kind: .correct, positions: positions)
        }

        let completedNow = outcome.completedPuzzleNow
        var completionStreak: Int?
        if completedNow {
            core.markCompletedDayUseCase.execute(dayKey: DayKey(offset: dayOffset))
            if dayOffset == todayOffset {
                let streakState = core.updateStreakUseCase.markCompleted(
                    dayKey: DayKey(offset: dayOffset),
                    todayKey: DayKey(offset: todayOffset)
                )
                completionStreak = streakState.current
                _ = core.rewardCompletionHintUseCase.execute(
                    dayKey: DayKey(offset: dayOffset),
                    todayKey: DayKey(offset: todayOffset)
                )
            }
        }

        guard case .correct = outcome.kind else { return }

        onWordValidated(pathCells: positions, isPuzzleComplete: completedNow)
        saveProgress()
        if completedNow {
            let preferences = celebrationPreferencesProvider()
            presentCompletionOverlay(streakCount: completionStreak, preferences: preferences)
        }
    }

    private func saveProgress() {
        let record = AppProgressRecord(
            dayOffset: dayOffset,
            gridSize: gridSize,
            foundWords: Array(gameSession.foundWords),
            solvedPositions: Array(gameSession.solvedPositions),
            startedAt: gameSession.startedAt?.timeIntervalSince1970,
            endedAt: gameSession.endedAt?.timeIntervalSince1970
        )
        if let sharedSync {
            core.updateSharedProgressUseCase.execute(
                puzzleIndex: sharedSync.puzzleIndex,
                gridSize: gridSize,
                foundWords: gameSession.foundWords,
                solvedPositions: gameSession.solvedPositions
            )
            onSharedStateMutation()
        } else {
            core.saveProgressRecordUseCase.execute(record)
        }
        onProgressUpdate()
    }

    private func resetProgress() {
        entryTransitionTask?.cancel()
        entryTransitionTask = nil
        feedbackDismissTask?.cancel()
        feedbackDismissTask = nil
        completionOverlayTask?.cancel()
        completionOverlayTask = nil
        completionOverlay = .hidden
        gameSession.reset()
        activeSelection = []
        dragAnchor = nil
        if let sharedSync {
            core.clearSharedProgressUseCase.execute(
                puzzleIndex: sharedSync.puzzleIndex,
                preferredGridSize: core.loadSettingsUseCase.execute().gridSize
            )
            onSharedStateMutation()
        } else {
            core.resetProgressRecordUseCase.execute(
                dayKey: DayKey(offset: dayOffset),
                gridSize: gridSize
            )
        }
        onProgressUpdate()
    }

    private func runEntryTransition() {
        guard !entryState.didRun else { return }
        entryState.didRun = true

        if reduceMotion {
            entryState.boardVisible = true
            entryState.bottomVisible = true
            return
        }

        entryTransitionTask?.cancel()
        entryTransitionTask = Task { @MainActor in
            withAnimation(.easeInOut(duration: Constants.entryBoardDuration)) {
                entryState.boardVisible = true
            }
            try? await Task.sleep(nanoseconds: Constants.entryBottomDelayNanos)
            guard !Task.isCancelled else { return }
            withAnimation(
                .spring(
                    response: Constants.entryBottomSpringResponse,
                    dampingFraction: Constants.entryBottomSpringDamping
                )
            ) {
                entryState.bottomVisible = true
            }
        }
    }

    private func showFeedback(kind: DailyPuzzleSelectionFeedbackKind, positions: [GridPosition]) {
        feedbackNonce += 1
        let currentNonce = feedbackNonce
        withAnimation(.easeOut(duration: Constants.feedbackShowDuration)) {
            selectionFeedback = DailyPuzzleSelectionFeedback(kind: kind, positions: positions)
        }

        feedbackDismissTask?.cancel()
        feedbackDismissTask = Task {
            try? await Task.sleep(nanoseconds: Constants.feedbackHideDelayNanos)
            guard !Task.isCancelled else { return }
            guard currentNonce == feedbackNonce else { return }
            await MainActor.run {
                withAnimation(.easeOut(duration: Constants.feedbackShowDuration)) {
                    selectionFeedback = nil
                }
            }
        }
    }

    private func onWordValidated(pathCells: [GridPosition], isPuzzleComplete: Bool) {
        let preferences = celebrationPreferencesProvider()
        celebrationController.celebrateWord(
            pathCells: pathCells,
            preferences: preferences,
            reduceMotion: reduceMotion,
            onFeedback: onWordFeedback
        )
        _ = isPuzzleComplete
    }

    private func presentCompletionOverlay(
        streakCount: Int?,
        preferences: DailyPuzzleCelebrationPreferences
    ) {
        completionOverlayTask?.cancel()
        completionOverlay = DailyPuzzleCompletionOverlayState(
            isVisible: true,
            showsBackdrop: false,
            showsToast: false,
            streakLabel: streakCount.map { "Racha \($0)" }
        )

        onCompletionFeedback(preferences)

        withAnimation(.easeInOut(duration: Constants.completionBackdropDuration)) {
            completionOverlay.showsBackdrop = true
        }

        completionOverlayTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: Constants.completionToastDelayNanos)
            guard !Task.isCancelled else { return }
            withAnimation(reduceMotion ? .easeInOut(duration: 0.16) : .easeOut(duration: 0.2)) {
                completionOverlay.showsToast = true
            }

            try? await Task.sleep(nanoseconds: Constants.completionAutoDismissDelayNanos)
            guard !Task.isCancelled else { return }
            await dismissCompletionOverlay(cancelScheduledTask: false)
        }
    }

    @MainActor
    private func dismissCompletionOverlay(cancelScheduledTask: Bool = true) async {
        if cancelScheduledTask {
            completionOverlayTask?.cancel()
            completionOverlayTask = nil
        }

        withAnimation(.easeInOut(duration: Constants.completionHideToastDuration)) {
            completionOverlay.showsToast = false
        }

        try? await Task.sleep(nanoseconds: Constants.completionHideToastDelayNanos)

        withAnimation(.easeInOut(duration: Constants.completionHideBackdropDuration)) {
            completionOverlay.showsBackdrop = false
        }

        try? await Task.sleep(nanoseconds: Constants.completionHideBackdropDelayNanos)

        completionOverlay.isVisible = false
        completionOverlay.streakLabel = nil
        if !cancelScheduledTask {
            completionOverlayTask = nil
        }
    }
}

private struct DailyPuzzleCompletionOverlayView: View {
    let showBackdrop: Bool
    let showToast: Bool
    let streakLabel: String?
    let reduceMotion: Bool
    let reduceTransparency: Bool
    let onTapDismiss: () -> Void

    private var toastTransition: AnyTransition {
        reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 0.96))
    }

    var body: some View {
        ZStack {
            if showBackdrop {
                Rectangle()
                    .fill(
                        reduceTransparency
                            ? AnyShapeStyle(ColorTokens.surfacePrimary.opacity(0.9))
                            : AnyShapeStyle(.regularMaterial)
                    )
                    .ignoresSafeArea()
                    .transition(.opacity)

                ColorTokens.overlayDim
                    .ignoresSafeArea()
                    .transition(.opacity)
            }

            if showToast {
                DailyPuzzleCompletionToast(
                    streakLabel: streakLabel,
                    reduceTransparency: reduceTransparency
                )
                .transition(toastTransition)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTapDismiss()
        }
    }
}

private struct DailyPuzzleCompletionToast: View {
    let streakLabel: String?
    let reduceTransparency: Bool

    private var accessibilityText: String {
        if let streakLabel {
            return "Completado. \(streakLabel)"
        }
        return "Completado"
    }

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        reduceTransparency
                            ? AnyShapeStyle(ColorTokens.surfaceSecondary)
                            : AnyShapeStyle(.thinMaterial)
                    )
                    .frame(width: 54, height: 54)

                Circle()
                    .stroke(ColorTokens.textPrimary.opacity(0.24), lineWidth: 1)
                    .frame(width: 54, height: 54)

                Image(systemName: "checkmark")
                    .font(TypographyTokens.titleSmall.weight(.bold))
                    .foregroundStyle(ColorTokens.textPrimary)
            }

            Text("Completado")
                .font(TypographyTokens.titleMedium.weight(.semibold))
                .foregroundStyle(ColorTokens.textPrimary)

            if let streakLabel {
                Text(streakLabel)
                    .font(TypographyTokens.callout)
                    .foregroundStyle(ColorTokens.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, SpacingTokens.lg)
        .padding(.vertical, SpacingTokens.lg)
        .background(
            RoundedRectangle(cornerRadius: RadiusTokens.overlayRadius, style: .continuous)
                .fill(
                    reduceTransparency
                        ? AnyShapeStyle(ColorTokens.surfaceSecondary)
                        : AnyShapeStyle(.ultraThinMaterial)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: RadiusTokens.overlayRadius, style: .continuous)
                .stroke(ColorTokens.textPrimary.opacity(0.24), lineWidth: 1)
        )
        .shadow(color: ColorTokens.inkPrimary.opacity(0.08), radius: 8, x: 0, y: 3)
        .padding(.horizontal, SpacingTokens.lg)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
    }
}
