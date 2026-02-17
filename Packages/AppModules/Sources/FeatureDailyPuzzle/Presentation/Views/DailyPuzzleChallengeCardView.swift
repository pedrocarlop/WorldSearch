/*
 BEGINNER NOTES (AUTO):
 - Archivo: Packages/AppModules/Sources/FeatureDailyPuzzle/Presentation/Views/DailyPuzzleChallengeCardView.swift
 - Rol principal: Define interfaz SwiftUI: estructura visual, estados observados y eventos del usuario.
 - Flujo simplificado: Entrada: estado observable + eventos de usuario. | Proceso: SwiftUI recalcula body y compone vistas. | Salida: interfaz actualizada en pantalla.
 - Tipos clave en este archivo: DailyPuzzleChallengeCardView,DailyPuzzleChallengeCardGridPreview
 - Funciones clave en este archivo: (sin funciones directas visibles; revisa propiedades/constantes/extensiones)
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

import SwiftUI
import Core
import DesignSystem

public struct DailyPuzzleChallengeCardView: View {
    private enum PlayButtonSparkle {
        static let repeatIntervalNanos: UInt64 = 5_000_000_000
        static let sweepDuration: Double = 1.0
        static let stripeAngle: Double = 20
        static let stripeOpacity: Double = 0.65
        static let popScale: CGFloat = 1.04
        static let popOffsetY: CGFloat = -1.4
        static let popDuration: Double = 0.58
        static let settleDelayNanos: UInt64 = 470_000_000
        static let settleDuration: Double = 0.64
    }

    private enum LayoutConstants {
        static let challengeStackSpacing: CGFloat = SpacingTokens.sm + 6
        static let maxPreviewSide: CGFloat = 240
    }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var playButtonSparkleProgress: CGFloat = 0
    @State private var playButtonSparkleTask: Task<Void, Never>?
    @State private var playButtonPulseResetTask: Task<Void, Never>?
    @State private var playButtonPulseScale: CGFloat = 1
    @State private var playButtonPulseOffsetY: CGFloat = 0

    public let date: Date
    public let puzzleNumber: Int
    public let grid: [[String]]
    public let words: [String]
    public let foundWords: Set<String>
    public let solvedPositions: Set<GridPosition>
    public let isLocked: Bool
    public let isMissed: Bool
    public let hoursUntilAvailable: Int?
    public let isLaunching: Bool
    public let isFocused: Bool
    public let onPlay: () -> Void

    public init(
        date: Date,
        puzzleNumber: Int,
        grid: [[String]],
        words: [String],
        foundWords: Set<String>,
        solvedPositions: Set<GridPosition>,
        isLocked: Bool,
        isMissed: Bool,
        hoursUntilAvailable: Int?,
        isLaunching: Bool,
        isFocused: Bool = false,
        onPlay: @escaping () -> Void
    ) {
        self.date = date
        self.puzzleNumber = puzzleNumber
        self.grid = grid
        self.words = words
        self.foundWords = foundWords
        self.solvedPositions = solvedPositions
        self.isLocked = isLocked
        self.isMissed = isMissed
        self.hoursUntilAvailable = hoursUntilAvailable
        self.isLaunching = isLaunching
        self.isFocused = isFocused
        self.onPlay = onPlay
    }

    private var totalWords: Int {
        words.count
    }

    private var completedWordsCount: Int {
        min(foundWords.count, totalWords)
    }

    private var progressFraction: CGFloat {
        guard totalWords > 0 else { return 0 }
        return min(max(CGFloat(completedWordsCount) / CGFloat(totalWords), 0), 1)
    }

    private var isCompleted: Bool {
        totalWords > 0 && completedWordsCount >= totalWords
    }

    private var shouldDimPreview: Bool {
        isCompleted || isLocked
    }

    private var showsPlayButton: Bool {
        !isLocked && !isCompleted
    }

    private var shouldAnimatePlayButtonSparkle: Bool {
        showsPlayButton && isFocused && !reduceMotion
    }

    private var statusLabel: String {
        if isMissed {
            return DailyPuzzleStrings.notCompleted
        }
        if isLocked {
            return lockMessage
        }
        if isCompleted {
            return DailyPuzzleStrings.completed
        }
        return DailyPuzzleStrings.challengeProgress(found: completedWordsCount, total: totalWords)
    }

    public var body: some View {
        ZStack {
            DSCard {
                VStack(spacing: LayoutConstants.challengeStackSpacing) {
                    header

                    GeometryReader { geometry in
                        let gridSide = min(
                            min(geometry.size.width, geometry.size.height),
                            LayoutConstants.maxPreviewSide
                        )

                        DailyPuzzleChallengeCardGridPreview(
                            grid: grid,
                            words: words,
                            foundWords: foundWords,
                            solvedPositions: solvedPositions,
                            sideLength: gridSide
                        )
                        .frame(width: gridSide, height: gridSide)
                        .saturation(shouldDimPreview ? 0.22 : 1)
                        .opacity(shouldDimPreview ? 0.72 : 1)
                        .blur(radius: shouldDimPreview ? 3 : 0)
                        .overlay(alignment: .center) {
                            statusBadge
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .scaleEffect(isLaunching ? 1.08 : 1)
                        .animation(.easeInOut(duration: MotionTokens.normalDuration), value: isLaunching)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    challengeProgressBar
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: RadiusTokens.cardRadius, style: .continuous)
                    .dsInnerStroke(ColorTokens.cardHighlightStroke, lineWidth: 1.4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: RadiusTokens.cardRadius, style: .continuous)
                    .dsInnerStroke(ColorTokens.borderDefault, lineWidth: 1)
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(RoundedRectangle(cornerRadius: RadiusTokens.cardRadius, style: .continuous))
        .onTapGesture {
            guard !isCompleted else { return }
            onPlay()
        }
        .onAppear {
            updatePlayButtonSparkleLoop()
        }
        .onDisappear {
            stopPlayButtonSparkleLoop(resetProgress: true)
        }
        .onChange(of: shouldAnimatePlayButtonSparkle) { _, _ in
            updatePlayButtonSparkleLoop()
        }
        .scaleEffect(isLaunching ? 1.02 : 1)
        .animation(.easeInOut(duration: MotionTokens.fastDuration), value: isLocked)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(DailyPuzzleStrings.challengeAccessibilityLabel(number: puzzleNumber, status: statusLabel))
    }

    private var header: some View {
        VStack(spacing: SpacingTokens.xxs - 2) {
            Text(weekdayText)
                .font(TypographyTokens.caption)
                .foregroundStyle(ColorTokens.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.55)

            Text(monthDayText)
                .font(TypographyTokens.challengeCardDate)
                .foregroundStyle(ColorTokens.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }

    @ViewBuilder
    private var statusBadge: some View {
        if isMissed {
            missedStatusBadge
        } else if isLocked {
            DSStatusBadge(kind: .locked, size: badgeSize)
        } else if isCompleted {
            DSStatusBadge(kind: .completed, size: badgeSize)
        } else {
            DSButton(
                DailyPuzzleStrings.playChallenge,
                style: .primary,
                cornerRadius: RadiusTokens.infiniteRadius
            ) {
                onPlay()
            }
            .frame(width: playButtonWidth)
            .overlay {
                playButtonSparkleOverlay
            }
            .scaleEffect(playButtonPulseScale)
            .offset(y: playButtonPulseOffsetY)
        }
    }

    private var badgeSize: CGFloat {
        54
    }

    private var playButtonWidth: CGFloat {
        120
    }

    private var missedStatusBadge: some View {
        Text(DailyPuzzleStrings.notCompleted)
            .font(TypographyTokens.caption.weight(.semibold))
            .foregroundStyle(ColorTokens.textPrimary)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .padding(.horizontal, SpacingTokens.sm)
            .padding(.vertical, SpacingTokens.xxs)
            .background(
                Capsule(style: .continuous)
                    .fill(ColorTokens.surfacePrimary.opacity(0.84))
            )
            .overlay(
                Capsule(style: .continuous)
                    .dsInnerStroke(ColorTokens.borderDefault, lineWidth: 1)
            )
    }

    private var challengeProgressBar: some View {
        ZStack(alignment: .leading) {
            Capsule(style: .continuous)
                .fill(ColorTokens.borderSoft)

            Capsule(style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [ColorTokens.accentCoral, ColorTokens.accentAmber],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 72 * progressFraction)
        }
        .frame(width: 72, height: 6)
        .opacity(isLocked ? 0.45 : 1)
        .accessibilityHidden(true)
    }

    private var playButtonSparkleOverlay: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let stripeWidth = max(24, size.width * 0.28)
            let travelDistance = size.width + (stripeWidth * 2.6)
            let stripeCenterX = (-stripeWidth * 1.3) + (travelDistance * playButtonSparkleProgress)

            LinearGradient(
                colors: [
                    .white.opacity(0),
                    .white.opacity(PlayButtonSparkle.stripeOpacity),
                    .white.opacity(0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: stripeWidth, height: size.height * 1.8)
            .rotationEffect(.degrees(PlayButtonSparkle.stripeAngle))
            .position(x: stripeCenterX, y: size.height / 2)
            .blendMode(.screen)
            .frame(width: size.width, height: size.height)
            .clipShape(RoundedRectangle(cornerRadius: RadiusTokens.infiniteRadius, style: .continuous))
            .opacity(shouldAnimatePlayButtonSparkle ? 1 : 0)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func updatePlayButtonSparkleLoop() {
        guard shouldAnimatePlayButtonSparkle else {
            stopPlayButtonSparkleLoop(resetProgress: true)
            return
        }

        guard playButtonSparkleTask == nil else { return }

        playButtonSparkleTask = Task { @MainActor in
            while !Task.isCancelled {
                triggerPlayButtonSparkle()
                try? await Task.sleep(nanoseconds: PlayButtonSparkle.repeatIntervalNanos)
            }
        }
    }

    private func stopPlayButtonSparkleLoop(resetProgress: Bool) {
        playButtonSparkleTask?.cancel()
        playButtonSparkleTask = nil
        playButtonPulseResetTask?.cancel()
        playButtonPulseResetTask = nil

        if resetProgress {
            playButtonSparkleProgress = 0
            playButtonPulseScale = 1
            playButtonPulseOffsetY = 0
        }
    }

    private func triggerPlayButtonSparkle() {
        playButtonPulseResetTask?.cancel()
        playButtonPulseResetTask = nil

        playButtonSparkleProgress = 0
        withAnimation(.easeInOut(duration: PlayButtonSparkle.sweepDuration)) {
            playButtonSparkleProgress = 1
        }

        withAnimation(.easeInOut(duration: PlayButtonSparkle.popDuration)) {
            playButtonPulseScale = PlayButtonSparkle.popScale
            playButtonPulseOffsetY = PlayButtonSparkle.popOffsetY
        }

        playButtonPulseResetTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: PlayButtonSparkle.settleDelayNanos)
            guard !Task.isCancelled else { return }

            withAnimation(.easeInOut(duration: PlayButtonSparkle.settleDuration)) {
                playButtonPulseScale = 1
                playButtonPulseOffsetY = 0
            }
        }
    }

    private var lockMessage: String {
        if let hoursUntilAvailable {
            return DailyPuzzleStrings.challengeAvailableIn(hours: hoursUntilAvailable)
        }
        return DailyPuzzleStrings.challengeAvailableSoon
    }

    private var monthDayText: String {
        let locale = AppLocalization.currentLocale
        let style = Date.FormatStyle.dateTime
            .locale(locale)
            .day()
            .month(.abbreviated)

        let formatted = date.formatted(style)
        let rawMonth = date.formatted(
            .dateTime
                .locale(locale)
                .month(.abbreviated)
        )
        let normalizedMonth = sentenceCasedMonth(rawMonth, locale: locale)

        guard normalizedMonth != rawMonth else { return formatted }

        var result = formatted
        if let range = result.range(of: rawMonth) {
            result.replaceSubrange(range, with: normalizedMonth)
            return result
        }

        let uppercaseMonth = rawMonth.uppercased(with: locale)
        if let range = result.range(of: uppercaseMonth) {
            result.replaceSubrange(range, with: normalizedMonth)
            return result
        }

        let lowercaseMonth = rawMonth.lowercased(with: locale)
        if let range = result.range(of: lowercaseMonth) {
            result.replaceSubrange(range, with: normalizedMonth)
            return result
        }

        return result
    }

    private var weekdayText: String {
        let locale = AppLocalization.currentLocale
        return date
            .formatted(
                .dateTime
                    .locale(locale)
                    .weekday(.wide)
            )
            .capitalized(with: locale)
    }

    private func sentenceCasedMonth(_ month: String, locale: Locale) -> String {
        let normalized = month.lowercased(with: locale)
        guard let first = normalized.first else { return normalized }
        let head = String(first).uppercased(with: locale)
        let tail = String(normalized.dropFirst())
        return head + tail
    }
}

private struct DailyPuzzleChallengeCardGridPreview: View {
    let grid: [[String]]
    let words: [String]
    let foundWords: Set<String>
    let solvedPositions: Set<GridPosition>
    let sideLength: CGFloat

    private var outlines: [SharedWordSearchBoardOutline] {
        let normalizedFoundWords = Set(foundWords.map(WordSearchNormalization.normalizedWord))
        let coreGrid = Core.PuzzleGrid(letters: grid)

        return words.enumerated().compactMap { index, word in
            let normalized = WordSearchNormalization.normalizedWord(word)
            guard normalizedFoundWords.contains(normalized) else { return nil }
            guard let path = WordPathFinderService.bestPath(
                for: normalized,
                grid: coreGrid,
                prioritizing: solvedPositions
            ) else {
                return nil
            }
            let boardPath = path.map { SharedWordSearchBoardPosition(row: $0.row, col: $0.col) }
            return SharedWordSearchBoardOutline(
                id: "preview-\(index)-\(normalized)",
                word: normalized,
                seed: index,
                positions: boardPath
            )
        }
    }

    var body: some View {
        SharedWordSearchBoardView(
            grid: grid,
            sideLength: sideLength,
            activePositions: [],
            feedback: nil,
            solvedWordOutlines: outlines,
            anchor: nil,
            palette: WordSearchBoardStylePreset.challengePreview
        )
        .scaleEffect(0.96)
    }
}

#Preview("Challenge Card States") {
    PreviewThemeProvider {
        VStack(spacing: SpacingTokens.md) {
            DailyPuzzleChallengeCardView(
                date: .now,
                puzzleNumber: 1,
                grid: Array(repeating: Array(repeating: "A", count: 8), count: 8),
                words: ["ARBOL", "RIO", "LUNA", "NUBE"],
                foundWords: ["ARBOL"],
                solvedPositions: [],
                isLocked: false,
                isMissed: false,
                hoursUntilAvailable: nil,
                isLaunching: false
            ) {}
            .frame(width: 320, height: 360)

            DailyPuzzleChallengeCardView(
                date: .now.addingTimeInterval(86_400),
                puzzleNumber: 2,
                grid: Array(repeating: Array(repeating: "B", count: 8), count: 8),
                words: ["ARBOL", "RIO", "LUNA", "NUBE"],
                foundWords: [],
                solvedPositions: [],
                isLocked: true,
                isMissed: false,
                hoursUntilAvailable: 5,
                isLaunching: false
            ) {}
            .frame(width: 320, height: 360)
        }
    }
}
