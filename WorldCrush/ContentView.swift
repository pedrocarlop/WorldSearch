/*
 BEGINNER NOTES (AUTO):
 - Archivo: WorldCrush/ContentView.swift
 - Rol principal: Define interfaz SwiftUI: estructura visual, estados observados y eventos del usuario.
 - Flujo simplificado: Entrada: estado observable + eventos de usuario. | Proceso: SwiftUI recalcula body y compone vistas. | Salida: interfaz actualizada en pantalla.
 - Tipos clave en este archivo: HostPresentedGame,HomePresentedSheet ContentView
 - Funciones clave en este archivo: refreshDailyPuzzleState,gameOverlay reloadWidgetTimeline,closePresentedGame presentGameFromCard,handleChallengeCardTap
 - Como leerlo sin experiencia:
   1) Busca primero los tipos clave para entender 'quien vive aqui'.
   2) Revisa propiedades (let/var): indican que datos mantiene cada tipo.
   3) Sigue funciones publicas: son la puerta de entrada para otras capas.
   4) Luego mira funciones privadas: implementan detalles internos paso a paso.
   5) Si ves guard/if/switch, son decisiones que controlan el flujo.
 - Recordatorio rapido de sintaxis:
   - let = valor fijo; var = valor que puede cambiar.
   - guard = valida pronto; si falla, sale de la funcion.
   - return = devuelve un resultado y cierra esa funcion.
*/

//
//  ContentView.swift
//  WorldCrush
//
//  Created by Pedro Carrasco lopez brea on 8/2/26.
//

import SwiftUI
import Combine
import WidgetKit
import Core
import DesignSystem
import FeatureSettings
import FeatureHistory
import FeatureDailyPuzzle

private struct HostPresentedGame: Identifiable, Equatable {
    let id: Int
}

private enum HomePresentedSheet: Identifiable {
    case settings
    case counter(HistoryCounterInfoKind)
    case widgetOnboardingGuide

    var id: String {
        switch self {
        case .settings:
            return "settings"
        case .counter(let info):
            return "counter-\(info.id)"
        case .widgetOnboardingGuide:
            return "widget-onboarding-guide"
        }
    }
}

enum WidgetOnboardingBannerState {
    static let firstOpenDateKey = "app.widget_onboarding_first_open_at_v1"
    static let dismissedKey = "app.widget_onboarding_dismissed_v1"
    static let autoHideDays = 7

    static func shouldShow(defaults: UserDefaults, now: Date = Date()) -> Bool {
        guard !defaults.bool(forKey: dismissedKey) else { return false }

        let firstOpenDate = firstSeenOpenDate(defaults: defaults, now: now)
        guard let hideDate = Calendar.current.date(byAdding: .day, value: autoHideDays, to: firstOpenDate) else {
            return false
        }

        return now < hideDate
    }

    static func dismiss(defaults: UserDefaults) {
        defaults.set(true, forKey: dismissedKey)
    }

    @discardableResult
    private static func firstSeenOpenDate(defaults: UserDefaults, now: Date) -> Date {
        if let stored = defaults.object(forKey: firstOpenDateKey) as? Date {
            return stored
        }

        defaults.set(now, forKey: firstOpenDateKey)
        return now
    }
}

struct ContentView: View {
    private enum Constants {
        static let closeGameAnimationDuration: Double = 0.22
        static let launchCardAnimationDuration: Double = 0.18
        static let presentGameAnimationDuration: Double = 0.22
        static let launchCardSettleDelayNanos: UInt64 = 110_000_000
        static let launchCardCleanupDelayNanos: UInt64 = 170_000_000
        static let minimumHomeRefreshInterval: TimeInterval = 0.75
        static let boundaryRefreshPollInterval: TimeInterval = 15
        static let firstLaunchSplashShownKey = "hasShownFirstLaunchSplash"
    }

    @Environment(\.scenePhase) private var scenePhase
    private let container: AppContainer
    private var core: CoreContainer { container.core }

    @State private var presentedSheet: HomePresentedSheet?
    @State private var presentedGame: HostPresentedGame?
    @State private var launchingCardOffset: Int?
    @State private var presentGameTask: Task<Void, Never>?
    @State private var settingsViewModel: SettingsViewModel
    @State private var historyViewModel: HistorySummaryViewModel
    @State private var dailyPuzzleHomeViewModel: DailyPuzzleHomeScreenViewModel
    @State private var lastHomeRefreshAt: Date = .distantPast
    @State private var showFirstLaunchSplash: Bool
    @State private var showsWidgetOnboardingBanner: Bool
    @Namespace private var toolbarActionTransitionNamespace
    private let boundaryRefreshTimer = Timer.publish(
        every: Constants.boundaryRefreshPollInterval,
        on: .main,
        in: .common
    ).autoconnect()

    @MainActor
    init(container: AppContainer) {
        self.container = container
        let settingsViewModel = container.settings.makeViewModel()
        let initialGridSize = settingsViewModel.model.gridSize

        _settingsViewModel = State(initialValue: settingsViewModel)
        _historyViewModel = State(initialValue: container.history.makeViewModel())
        _dailyPuzzleHomeViewModel = State(
            initialValue: container.dailyPuzzle.makeHomeScreenViewModel(
                initialGridSize: initialGridSize
            )
        )
        let defaults = UserDefaults.standard
        _showFirstLaunchSplash = State(initialValue: !defaults.bool(forKey: Constants.firstLaunchSplashShownKey))
        _showsWidgetOnboardingBanner = State(
            initialValue: WidgetOnboardingBannerState.shouldShow(defaults: defaults, now: Date())
        )
    }

    private var todayOffset: Int {
        dailyPuzzleHomeViewModel.todayOffset
    }

    var body: some View {
        NavigationStack {
            ZStack {
                DSPageBackgroundView()

                HomeScreenLayout(
                    challengeCards: dailyPuzzleHomeViewModel.challengeCards,
                    dayCarouselOffsets: dailyPuzzleHomeViewModel.dayCarouselOffsets,
                    selectedOffset: Binding(
                        get: { dailyPuzzleHomeViewModel.selectedOffset },
                        set: { dailyPuzzleHomeViewModel.setSelectedOffset($0) }
                    ),
                    todayOffset: todayOffset,
                    unlockedOffsets: dailyPuzzleHomeViewModel.easterUnlockedOffsets,
                    launchingCardOffset: launchingCardOffset,
                    showsWidgetOnboardingBanner: showsWidgetOnboardingBanner,
                    onCardTap: handleChallengeCardTap(offset:),
                    onWidgetOnboardingTap: { presentedSheet = .widgetOnboardingGuide },
                    onWidgetOnboardingDismiss: dismissWidgetOnboardingBanner,
                    dateForOffset: { dailyPuzzleHomeViewModel.puzzleDate(for: $0) },
                    progressForOffset: {
                        dailyPuzzleHomeViewModel.progressFraction(
                            for: $0,
                            preferredGridSize: settingsViewModel.model.gridSize
                        )
                    },
                    hoursUntilAvailable: { dailyPuzzleHomeViewModel.hoursUntilAvailable(for: $0) }
                )

                if let selection = presentedGame {
                    gameOverlay(for: selection.id)
                        .transition(.scale(scale: 0.94).combined(with: .opacity))
                        .zIndex(50)
                }
                if showFirstLaunchSplash {
                    FirstLaunchSplashView()
                        .transition(.opacity)
                        .zIndex(100)
                }

            }
            .animation(.easeInOut(duration: 0.24), value: presentedGame)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if presentedGame == nil {
                    HomeToolbarContent(
                        completedCount: historyViewModel.model.completedCount,
                        streakCount: historyViewModel.model.currentStreak,
                        onCompletedTap: { presentedSheet = .counter(.completedPuzzles) },
                        onStreakTap: { presentedSheet = .counter(.streak) },
                        onSettingsTap: { presentedSheet = .settings },
                        toolbarActionTransitionNamespace: toolbarActionTransitionNamespace
                    )
                }
            }
            .onAppear {
                refreshHomeData(force: true)
                if showFirstLaunchSplash {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            showFirstLaunchSplash = false
                        }
                        UserDefaults.standard.set(true, forKey: Constants.firstLaunchSplashShownKey)
                    }
                }
            }
            .onChange(of: scenePhase) { _, phase in
                guard phase == .active else { return }
                refreshHomeData(force: false)
            }
            .onReceive(boundaryRefreshTimer) { _ in
                guard scenePhase == .active else { return }
                syncHomeStateForDailyRotation(now: Date())
            }
            .onDisappear {
                presentGameTask?.cancel()
                presentGameTask = nil
            }
            .sheet(item: $presentedSheet) { sheet in
                switch sheet {
                case .settings:
                    SettingsSheetView(
                        values: settingsViewModel.makeSheetValues()
                    ) { updated in
                        settingsViewModel.save(values: updated)
                        reloadWidgetTimeline()
                        refreshDailyPuzzleState()
                    }
                case .counter(let info):
                    HistoryCounterInfoSheetView(
                        core: core,
                        info: info
                    )
                case .widgetOnboardingGuide:
                    WidgetOnboardingGuideSheetView()
                }
            }
        }
        .preferredColorScheme(settingsViewModel.model.appearanceMode.colorScheme)
        .environment(\.locale, settingsViewModel.model.appLanguage.locale)
        .font(TypographyTokens.body)
    }

    private func refreshDailyPuzzleState() {
        dailyPuzzleHomeViewModel.refresh(preferredGridSize: settingsViewModel.model.gridSize)
        historyViewModel.refresh()
    }

    private func refreshHomeData(force: Bool) {
        let now = Date()
        refreshWidgetOnboardingBannerVisibility(now: now)
        if !force,
           now.timeIntervalSince(lastHomeRefreshAt) < Constants.minimumHomeRefreshInterval {
            return
        }

        lastHomeRefreshAt = now
        settingsViewModel.refresh()
        refreshDailyPuzzleState()
        preloadInitialGameData()
    }

    private func preloadInitialGameData() {
        let preferredGridSize = settingsViewModel.model.gridSize
        let launchOffset = dailyPuzzleHomeViewModel.selectedOffset ?? todayOffset
        _ = dailyPuzzleHomeViewModel.puzzleForOffset(
            launchOffset,
            preferredGridSize: preferredGridSize
        )
        _ = dailyPuzzleHomeViewModel.initialProgressRecord(
            for: launchOffset,
            preferredGridSize: preferredGridSize
        )
    }

    private func refreshWidgetOnboardingBannerVisibility(now: Date = Date()) {
        showsWidgetOnboardingBanner = WidgetOnboardingBannerState.shouldShow(defaults: .standard, now: now)
    }

    private func syncHomeStateForDailyRotation(now: Date = Date()) {
        let didRefresh = dailyPuzzleHomeViewModel.refreshIfNeeded(
            preferredGridSize: settingsViewModel.model.gridSize,
            now: now
        )
        guard didRefresh else { return }

        historyViewModel.refresh()
        reloadWidgetTimeline()
    }

    private func dismissWidgetOnboardingBanner() {
        WidgetOnboardingBannerState.dismiss(defaults: .standard)
        withAnimation(.easeInOut(duration: 0.2)) {
            showsWidgetOnboardingBanner = false
        }
    }

    @ViewBuilder
    private func gameOverlay(for offset: Int) -> some View {
        let puzzle = dailyPuzzleHomeViewModel.puzzleForOffset(
            offset,
            preferredGridSize: settingsViewModel.model.gridSize
        )
        let record = dailyPuzzleHomeViewModel.initialProgressRecord(
            for: offset,
            preferredGridSize: settingsViewModel.model.gridSize
        )
        let puzzleGridSize = puzzle.grid.size
        let title = HostDateFormatter.monthDay(for: dailyPuzzleHomeViewModel.puzzleDate(for: offset))
        let sharedSync = dailyPuzzleHomeViewModel.sharedPuzzleIndex(for: offset).map {
            DailyPuzzleSharedSyncContext(puzzleIndex: $0)
        }

        ZStack {
            ColorTokens.surfacePrimary
                .ignoresSafeArea()

            DailyPuzzleGameScreenView(
                core: core,
                dayOffset: offset,
                todayOffset: todayOffset,
                navigationTitle: title,
                puzzle: puzzle,
                gridSize: puzzleGridSize,
                wordHintMode: settingsViewModel.model.wordHintMode,
                initialProgress: record,
                sharedSync: sharedSync,
                onProgressUpdate: {
                    refreshDailyPuzzleState()
                },
                onClose: {
                    closePresentedGame()
                },
                celebrationPreferencesProvider: {
                    currentCelebrationPreferences()
                },
                onWordFeedback: { preferences in
                    playWordFeedback(preferences)
                },
                onCompletionFeedback: { preferences in
                    playCompletionFeedback(preferences)
                },
                onSharedStateMutation: {
                    reloadWidgetTimeline()
                }
            )
        }
    }

    private func reloadWidgetTimeline() {
        Task { @MainActor in
            WidgetCenter.shared.reloadTimelines(ofKind: WordSearchConfig.widgetKind)
        }
    }

    private func closePresentedGame() {
        presentGameTask?.cancel()
        presentGameTask = nil
        withAnimation(.easeInOut(duration: Constants.closeGameAnimationDuration)) {
            presentedGame = nil
        }
        launchingCardOffset = nil
    }

    private func presentGameFromCard(offset: Int) {
        guard presentedGame == nil else { return }

        presentGameTask?.cancel()

        withAnimation(.easeInOut(duration: Constants.launchCardAnimationDuration)) {
            launchingCardOffset = offset
        }

        presentGameTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: Constants.launchCardSettleDelayNanos)
            guard !Task.isCancelled else { return }

            withAnimation(.easeInOut(duration: Constants.presentGameAnimationDuration)) {
                presentedGame = HostPresentedGame(id: offset)
            }

            try? await Task.sleep(nanoseconds: Constants.launchCardCleanupDelayNanos)
            guard !Task.isCancelled else { return }

            if launchingCardOffset == offset {
                launchingCardOffset = nil
            }
        }
    }

    private func handleChallengeCardTap(offset: Int) {
        syncHomeStateForDailyRotation(now: Date())

        switch dailyPuzzleHomeViewModel.handleChallengeCardTap(offset: offset) {
        case .openGame:
            presentGameFromCard(offset: offset)
        case .unlocked, .noAction:
            break
        }
    }

    private func currentCelebrationPreferences() -> DailyPuzzleCelebrationPreferences {
        let settings = core.loadSettingsUseCase.execute()
        return DailyPuzzleCelebrationPreferences(
            enableCelebrations: settings.enableCelebrations,
            enableHaptics: settings.enableHaptics,
            enableSound: settings.enableSound,
            intensity: settings.celebrationIntensity
        )
    }

    private func playWordFeedback(_ preferences: DailyPuzzleCelebrationPreferences) {
        if preferences.enableHaptics {
            HostHaptics.wordSuccess()
        }
        if preferences.enableSound {
            HostSoundPlayer.play(.word)
        }
    }

    private func playCompletionFeedback(_ preferences: DailyPuzzleCelebrationPreferences) {
        if preferences.enableHaptics {
            HostHaptics.completionSuccess()
        }
        if preferences.enableSound {
            HostSoundPlayer.play(.completion)
        }
    }

}

private struct WidgetOnboardingGuideSheetView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                ColorTokens.backgroundPrimary
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: SpacingTokens.lg) {
                        Text(AppStrings.widgetOnboardingGuideDescription)
                            .font(TypographyTokens.callout)
                            .foregroundStyle(ColorTokens.textSecondary)

                        VStack(alignment: .leading, spacing: SpacingTokens.md) {
                            WidgetOnboardingStepRow(step: 1, text: AppStrings.widgetOnboardingGuideStep1)
                            WidgetOnboardingStepRow(step: 2, text: AppStrings.widgetOnboardingGuideStep2)
                            WidgetOnboardingStepRow(step: 3, text: AppStrings.widgetOnboardingGuideStep3)
                            WidgetOnboardingStepRow(step: 4, text: AppStrings.widgetOnboardingGuideStep4)
                            WidgetOnboardingStepRow(step: 5, text: AppStrings.widgetOnboardingGuideStep5)
                        }

                        Text(AppStrings.widgetOnboardingGuideFooter)
                            .font(TypographyTokens.footnote)
                            .foregroundStyle(ColorTokens.textSecondary)
                            .padding(.top, SpacingTokens.xs)
                    }
                    .padding(.horizontal, SpacingTokens.lg)
                    .padding(.top, SpacingTokens.lg)
                    .padding(.bottom, SpacingTokens.xxl)
                }
            }
            .navigationTitle(AppStrings.widgetOnboardingGuideTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(AppStrings.widgetOnboardingGuideDone) {
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct WidgetOnboardingStepRow: View {
    let step: Int
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: SpacingTokens.sm) {
            Text("\(step)")
                .font(TypographyTokens.caption.weight(.semibold))
                .foregroundStyle(ColorTokens.textPrimary)
                .frame(width: 24, height: 24)
                .background(
                    ColorTokens.surfaceSecondary,
                    in: Circle()
                )
                .overlay(
                    Circle()
                        .stroke(ColorTokens.borderDefault.opacity(0.55), lineWidth: 1)
                )

            Text(text)
                .font(TypographyTokens.body)
                .foregroundStyle(ColorTokens.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
    }
}

private struct FirstLaunchSplashView: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            ColorTokens.backgroundPrimary
                .ignoresSafeArea()

            Image("AppLaunchIcon") // Add this image to Assets.xcassets with Light/Dark variants
                .resizable()
                .renderingMode(.original)
                .scaledToFit()
                .frame(width: 160, height: 160)
                .scaleEffect(animate ? 1.0 : 0.92)
                .opacity(animate ? 1.0 : 0.0)
                .shadow(color: Color.black.opacity(0.12), radius: 16, x: 0, y: 8)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.35)) {
                        animate = true
                    }
                }
                .accessibilityHidden(true)
        }
    }
}

private extension AppearanceMode {
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

#Preview {
    ContentView(container: AppContainer.live)
}
