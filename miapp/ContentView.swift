//
//  ContentView.swift
//  miapp
//
//  Created by Pedro Carrasco lopez brea on 8/2/26.
//

import SwiftUI
import WidgetKit

private enum CelebrationKind {
    case progress
    case complete
}

private enum HostRoute: Hashable {
    case game(dayOffset: Int)
}

private struct SoftGlowBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(.systemGray6),
                    Color(.secondarySystemBackground),
                    Color(.systemBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Circle()
                .fill(Color.white.opacity(0.55))
                .frame(width: 380, height: 380)
                .blur(radius: 70)
                .offset(x: -130, y: -260)
            Circle()
                .fill(Color.blue.opacity(0.14))
                .frame(width: 340, height: 340)
                .blur(radius: 90)
                .offset(x: 170, y: 260)
        }
        .ignoresSafeArea()
    }
}

private struct HomeHeaderView: View {
    let totalCompleted: Int
    let trigger: Int
    let onSettings: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Sopa de letras")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                Text("al dia")
                    .font(.system(size: 22, weight: .semibold, design: .serif))
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            CompletionPill(count: totalCompleted)

            Button(action: onSettings) {
                GlassIconLabel(systemImage: "gearshape", trigger: trigger)
            }
            .buttonStyle(.plain)
        }
    }
}

private struct CompletionPill: View {
    let count: Int

    var body: some View {
        HStack(spacing: 8) {
            Text("\(count)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .frame(width: 30, height: 30)
                .background(Circle().fill(Color.white.opacity(0.72)))

            Text("completadas")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.45), lineWidth: 0.8)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 6)
    }
}

private struct DailyChallengeCard: View {
    let date: Date
    let puzzle: HostPuzzle
    let progress: HostPuzzleProgress
    let isLocked: Bool
    let hoursUntilAvailable: Int?
    let onPlay: () -> Void

    private var totalWords: Int { puzzle.words.count }
    private var foundCount: Int { progress.foundWords.count }
    private var progressRatio: Double {
        guard totalWords > 0 else { return 0 }
        return Double(foundCount) / Double(totalWords)
    }
    private var isCompleted: Bool {
        totalWords > 0 && foundCount >= totalWords
    }

    private var actionTitle: String {
        if isLocked {
            return "Bloqueado"
        }
        if isCompleted {
            return "Ver reto"
        }
        return foundCount > 0 ? "Reanudar" : "Empezar"
    }

    private var actionIcon: String {
        if isLocked {
            return "lock.fill"
        }
        if isCompleted {
            return "checkmark.circle.fill"
        }
        return "play.fill"
    }

    var body: some View {
        ZStack {
            GeometryReader { geo in
                let gridSide = min(geo.size.width * 0.62, geo.size.height * 0.40)

                VStack(spacing: 14) {
                    VStack(spacing: 4) {
                        Text(HostDateFormatter.weekdayName(for: date).capitalized)
                            .font(.system(size: 36, weight: .bold, design: .serif))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)

                        Text(HostDateFormatter.monthDay(for: date))
                            .font(.system(size: 20, weight: .semibold, design: .serif))
                            .foregroundStyle(.secondary)
                    }

                    PuzzleGridPreview(
                        grid: puzzle.grid,
                        words: puzzle.words,
                        foundWords: progress.foundWords,
                        solvedPositions: progress.solvedPositions,
                        sideLength: gridSide
                    )
                    .frame(width: gridSide, height: gridSide)

                    VStack(spacing: 8) {
                        ProgressRingView(progress: progressRatio)
                        Text("\(foundCount) de \(totalWords) encontradas")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.secondary)
                        statusLine
                    }

                    PrimaryActionButton(
                        title: actionTitle,
                        systemImage: actionIcon,
                        isDisabled: isLocked,
                        action: onPlay
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.horizontal, 24)
                .padding(.vertical, 22)
            }
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 34, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .stroke(Color.white.opacity(0.45), lineWidth: 0.8)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 18, x: 0, y: 10)

            if isLocked {
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 34, style: .continuous)
                            .stroke(Color.white.opacity(0.6), lineWidth: 1)
                    )
                    .overlay {
                        VStack(spacing: 8) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 22, weight: .bold))
                            Text("Reto bloqueado")
                                .font(.headline.weight(.bold))
                            Text(lockMessage)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 18)
                    }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isLocked)
    }

    private var lockMessage: String {
        if let hoursUntilAvailable {
            return "Disponible en \(hoursUntilAvailable)h"
        }
        return "Disponible pronto"
    }

    @ViewBuilder
    private var statusLine: some View {
        if isLocked {
            Text(lockMessage)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
        } else if isCompleted {
            Text("Reto completado")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
        } else if foundCount > 0 {
            Text("En progreso")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
        } else {
            Text("Nuevo reto del dia")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
        }
    }
}

private struct DayCarouselView: View {
    let offsets: [Int]
    @Binding var selectedOffset: Int?
    let todayOffset: Int
    let completedOffsets: Set<Int>
    let dateForOffset: (Int) -> Date
    let hoursUntilAvailable: (Int) -> Int?

    var body: some View {
        GeometryReader { geo in
            let itemWidth: CGFloat = 78
            let sidePadding = max((geo.size.width - itemWidth) / 2, 16)
            let activeOffset = selectedOffset ?? todayOffset
            let scrollSelection = Binding<Int?>(
                get: {
                    let current = selectedOffset ?? todayOffset
                    return offsets.contains(current) ? current : nil
                },
                set: { selectedOffset = $0 }
            )

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(offsets, id: \.self) { offset in
                        let date = dateForOffset(offset)
                        let isLocked = offset > todayOffset
                        DayCarouselItem(
                            date: date,
                            isSelected: offset == activeOffset,
                            isLocked: isLocked,
                            isCompleted: completedOffsets.contains(offset),
                            hoursUntilAvailable: hoursUntilAvailable(offset)
                        )
                        .frame(width: itemWidth)
                        .onTapGesture {
                            withAnimation(.snappy(duration: 0.28, extraBounce: 0.02)) {
                                selectedOffset = offset
                            }
                        }
                        .id(offset)
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal, sidePadding)
            }
            .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
            .scrollPosition(id: scrollSelection, anchor: .center)
        }
    }
}

private struct DayCarouselItem: View {
    let date: Date
    let isSelected: Bool
    let isLocked: Bool
    let isCompleted: Bool
    let hoursUntilAvailable: Int?

    var body: some View {
        VStack(spacing: 6) {
            Text(HostDateFormatter.shortWeekday(for: date).uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(.secondary)

            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)

            if isLocked, let hoursUntilAvailable {
                Text("\(hoursUntilAvailable)h")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
            } else if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.blue)
            } else {
                Circle()
                    .fill(Color.primary.opacity(0.18))
                    .frame(width: 6, height: 6)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    isSelected
                    ? AnyShapeStyle(Color.white.opacity(0.75))
                    : AnyShapeStyle(Material.ultraThin)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(isSelected ? 0.7 : 0.35), lineWidth: 0.8)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .scaleEffect(isSelected ? 1.05 : 0.98)
        .animation(.snappy(duration: 0.22), value: isSelected)
    }
}

private struct ProgressRingView: View {
    let progress: Double
    var size: CGFloat = 58
    var lineWidth: CGFloat = 6

    var body: some View {
        let clamped = max(0, min(progress, 1))
        ZStack {
            Circle()
                .stroke(Color.primary.opacity(0.12), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: clamped)
                .stroke(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.85), Color.blue.opacity(0.45)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            Text("\(Int(clamped * 100))%")
                .font(.caption.weight(.bold))
                .foregroundStyle(.primary)
        }
        .frame(width: size, height: size)
        .animation(.easeOut(duration: 0.3), value: progress)
    }
}

private struct PrimaryActionButton: View {
    let title: String
    let systemImage: String
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.system(size: 14, weight: .bold))
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .foregroundStyle(.primary)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.9), Color.white.opacity(0.55)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
            )
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.55 : 1)
    }
}

private struct ProgressBarView: View {
    let progress: Double
    let label: String

    var body: some View {
        let clamped = max(0, min(progress, 1))

        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Progreso")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer(minLength: 0)
                Text(label)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.primary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.black.opacity(0.08))

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.85), Color.blue.opacity(0.45)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * clamped)
                }
            }
            .frame(height: 10)
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.45), lineWidth: 0.8)
        )
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: clamped)
    }
}

private enum HostSelectionFeedbackKind {
    case correct
    case incorrect
}

private struct HostSelectionFeedback: Identifiable {
    let id = UUID()
    let kind: HostSelectionFeedbackKind
    let positions: [HostGridPosition]
}

private struct HostSharedSyncContext {
    let puzzleIndex: Int
}

private struct WordSearchGameView: View {
    @Environment(\.dismiss) private var dismiss

    let dayOffset: Int
    let date: Date
    let puzzle: HostPuzzle
    let gridSize: Int
    let wordHintMode: HostWordHintMode
    let onProgressUpdate: () -> Void
    let sharedSync: HostSharedSyncContext?

    @State private var foundWords: Set<String>
    @State private var solvedPositions: Set<HostGridPosition>
    @State private var startedAt: Date?
    @State private var endedAt: Date?
    @State private var activeSelection: [HostGridPosition] = []
    @State private var dragAnchor: HostGridPosition?
    @State private var selectionFeedback: HostSelectionFeedback?
    @State private var feedbackNonce = 0
    @State private var showResetAlert = false

    init(
        dayOffset: Int,
        date: Date,
        puzzle: HostPuzzle,
        gridSize: Int,
        wordHintMode: HostWordHintMode,
        initialProgress: HostAppProgressRecord?,
        sharedSync: HostSharedSyncContext?,
        onProgressUpdate: @escaping () -> Void
    ) {
        self.dayOffset = dayOffset
        self.date = date
        self.puzzle = puzzle
        self.gridSize = gridSize
        self.wordHintMode = wordHintMode
        self.onProgressUpdate = onProgressUpdate
        self.sharedSync = sharedSync

        let puzzleWords = Set(puzzle.words.map { $0.uppercased() })
        let storedFound = Set((initialProgress?.foundWords ?? []).map { $0.uppercased() })
        let normalizedFound = storedFound.intersection(puzzleWords)

        let maxRow = puzzle.grid.count
        let maxCol = puzzle.grid.first?.count ?? 0
        let storedPositions = initialProgress?.solvedPositions ?? []
        let normalizedPositions = storedPositions.compactMap { position -> HostGridPosition? in
            guard position.row >= 0, position.col >= 0, position.row < maxRow, position.col < maxCol else {
                return nil
            }
            return HostGridPosition(row: position.row, col: position.col)
        }

        _foundWords = State(initialValue: normalizedFound)
        _solvedPositions = State(initialValue: Set(normalizedPositions))
        _startedAt = State(initialValue: initialProgress?.startedDate)
        _endedAt = State(initialValue: initialProgress?.endedDate)
    }

    private var puzzleWords: [String] {
        puzzle.words.map { $0.uppercased() }
    }

    private var puzzleWordSet: Set<String> {
        Set(puzzleWords)
    }

    private var progressCount: Int {
        foundWords.intersection(puzzleWordSet).count
    }

    private var progressRatio: Double {
        guard !puzzleWords.isEmpty else { return 0 }
        return Double(progressCount) / Double(puzzleWords.count)
    }

    private var isCompleted: Bool {
        !puzzleWords.isEmpty && progressCount >= puzzleWords.count
    }

    var body: some View {
        ZStack {
            SoftGlowBackground()

            GeometryReader { geometry in
                let side = min(geometry.size.width - 32, 420)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 18) {
                        headerView
                        progressBarView

                        WordSearchBoardView(
                            grid: puzzle.grid,
                            words: puzzle.words,
                            foundWords: foundWords,
                            solvedPositions: solvedPositions,
                            activePositions: activeSelection,
                            feedback: selectionFeedback,
                            sideLength: side
                        ) { position in
                            guard !isCompleted else { return }
                            handleDragChanged(position)
                        } onDragEnded: {
                            guard !isCompleted else { return }
                            handleDragEnded()
                        }

                        objectivesView
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 28)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if startedAt == nil && !isCompleted {
                startedAt = Date()
                saveProgress()
            }
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

    private var headerView: some View {
        HStack(alignment: .center, spacing: 12) {
            CircleIconButton(systemName: "chevron.left") {
                dismiss()
            }

            Spacer(minLength: 0)

            VStack(spacing: 4) {
                Text(HostDateFormatter.monthDay(for: date))
                    .font(.system(size: 17, weight: .semibold, design: .serif))
            }

            Spacer(minLength: 0)

            CircleIconButton(systemName: "arrow.counterclockwise") {
                showResetAlert = true
            }
        }
    }

    private var progressBarView: some View {
        ProgressBarView(
            progress: progressRatio,
            label: "\(progressCount) de \(puzzleWords.count) palabras"
        )
    }

    private var objectivesView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Objetivos")
                    .font(.headline.weight(.bold))
                Spacer(minLength: 0)
                Text("\(progressCount) / \(puzzleWords.count)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            PuzzleWordsPreview(
                words: puzzle.words,
                foundWords: foundWords,
                displayMode: wordHintMode
            )
            .frame(height: wordHintMode == .definition ? 220 : 180)
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.45), lineWidth: 0.8)
        )
    }

    private func handleDragChanged(_ position: HostGridPosition) {
        if dragAnchor == nil {
            dragAnchor = position
            activeSelection = [position]
            if startedAt == nil && !isCompleted {
                startedAt = Date()
                saveProgress()
            }
            return
        }

        guard let anchor = dragAnchor else { return }
        let direction = snappedDirection(from: anchor, to: position)
        activeSelection = selectionPath(from: anchor, to: position, direction: direction)
    }

    private func handleDragEnded() {
        let selection = activeSelection
        dragAnchor = nil
        activeSelection = []
        guard selection.count >= 2 else { return }
        finalizeSelection(selection)
    }

    private func snappedDirection(from start: HostGridPosition, to end: HostGridPosition) -> (Int, Int) {
        let drRaw = end.row - start.row
        let dcRaw = end.col - start.col
        guard drRaw != 0 || dcRaw != 0 else { return (0, 0) }
        let absRow = abs(drRaw)
        let absCol = abs(dcRaw)

        if drRaw == 0 && dcRaw == 0 {
            return (0, 0)
        }
        let angle = atan2(Double(drRaw), Double(dcRaw))
        let octant = Int(round(angle / (.pi / 4)))
        let index = (octant + 8) % 8
        let directions: [(Int, Int)] = [
            (0, 1), (1, 1), (1, 0), (1, -1),
            (0, -1), (-1, -1), (-1, 0), (-1, 1)
        ]
        return directions[index]
    }

    private func selectionPath(
        from start: HostGridPosition,
        to end: HostGridPosition,
        direction: (Int, Int)
    ) -> [HostGridPosition] {
        let drRaw = end.row - start.row
        let dcRaw = end.col - start.col
        let steps = max(abs(drRaw), abs(dcRaw))
        let rows = puzzle.grid.count
        let cols = puzzle.grid.first?.count ?? 0

        guard steps >= 0 else { return [start] }

        return (0...steps).compactMap { step in
            let r = start.row + direction.0 * step
            let c = start.col + direction.1 * step
            guard r >= 0, c >= 0, r < rows, c < cols else { return nil }
            return HostGridPosition(row: r, col: c)
        }
    }

    private func finalizeSelection(_ positions: [HostGridPosition]) {
        let selectedWord = positions.map { puzzle.grid[$0.row][$0.col] }.joined().uppercased()
        let reversed = String(selectedWord.reversed())

        let match: String?
        if puzzleWordSet.contains(selectedWord) {
            match = selectedWord
        } else if puzzleWordSet.contains(reversed) {
            match = reversed
        } else {
            match = nil
        }

        guard let matched = match else {
            showFeedback(kind: .incorrect, positions: positions)
            return
        }
        guard !foundWords.contains(matched) else {
            showFeedback(kind: .incorrect, positions: positions)
            return
        }

        foundWords.insert(matched)
        solvedPositions.formUnion(positions)
        showFeedback(kind: .correct, positions: positions)

        if isCompleted && endedAt == nil {
            endedAt = Date()
            HostCompletionStore.markCompleted(dayOffset: dayOffset)
        }

        saveProgress()
    }

    private func saveProgress() {
        let record = HostAppProgressRecord(
            dayOffset: dayOffset,
            gridSize: gridSize,
            foundWords: Array(foundWords),
            solvedPositions: solvedPositions.map { HostAppProgressPosition(row: $0.row, col: $0.col) },
            startedAt: startedAt?.timeIntervalSince1970,
            endedAt: endedAt?.timeIntervalSince1970
        )
        if let sharedSync {
            HostSharedPuzzleStateStore.updateProgress(
                puzzleIndex: sharedSync.puzzleIndex,
                gridSize: gridSize,
                foundWords: foundWords,
                solvedPositions: solvedPositions
            )
        } else {
            HostAppProgressStore.save(record)
        }
        onProgressUpdate()
    }

    private func resetProgress() {
        foundWords = []
        solvedPositions = []
        activeSelection = []
        dragAnchor = nil
        startedAt = nil
        endedAt = nil
        if let sharedSync {
            HostSharedPuzzleStateStore.clearProgress(
                puzzleIndex: sharedSync.puzzleIndex,
                gridSize: gridSize
            )
        } else {
            HostAppProgressStore.reset(dayOffset: dayOffset, gridSize: gridSize)
        }
        onProgressUpdate()
    }

    private func showFeedback(kind: HostSelectionFeedbackKind, positions: [HostGridPosition]) {
        feedbackNonce += 1
        let currentNonce = feedbackNonce
        withAnimation(.easeOut(duration: 0.2)) {
            selectionFeedback = HostSelectionFeedback(kind: kind, positions: positions)
        }

        Task {
            try? await Task.sleep(nanoseconds: 650_000_000)
            guard currentNonce == feedbackNonce else { return }
            await MainActor.run {
                withAnimation(.easeOut(duration: 0.2)) {
                    selectionFeedback = nil
                }
            }
        }
    }
}

private struct WordSearchBoardView: View {
    let grid: [[String]]
    let words: [String]
    let foundWords: Set<String>
    let solvedPositions: Set<HostGridPosition>
    let activePositions: [HostGridPosition]
    let feedback: HostSelectionFeedback?
    let sideLength: CGFloat
    let onDragChanged: (HostGridPosition) -> Void
    let onDragEnded: () -> Void

    private struct WordOutline: Identifiable {
        let id: String
        let positions: [HostGridPosition]
    }

    private let directions: [(Int, Int)] = [
        (0, 1), (1, 0), (1, 1), (1, -1),
        (0, -1), (-1, 0), (-1, -1), (-1, 1)
    ]

    private var rows: Int { grid.count }
    private var cols: Int { grid.first?.count ?? 0 }

    var body: some View {
        let safeRows = max(rows, 1)
        let safeCols = max(cols, 1)
        let cellSize = sideLength / CGFloat(safeCols)
        let activeSet = Set(activePositions)

        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.35))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.white.opacity(0.55), lineWidth: 1)
                )

            VStack(spacing: 0) {
                ForEach(0..<safeRows, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<safeCols, id: \.self) { col in
                            let position = HostGridPosition(row: row, col: col)
                            let letter = row < rows && col < cols ? grid[row][col] : ""
                            let isActive = activeSet.contains(position)

                            Text(letter)
                                .font(.system(size: max(10, cellSize * 0.45), weight: .semibold, design: .rounded))
                                .foregroundStyle(.primary)
                                .frame(width: cellSize, height: cellSize)
                                .background(cellFill(isActive: isActive))
                                .overlay(
                                    Rectangle()
                                        .stroke(Color.black.opacity(0.08), lineWidth: 1)
                                )
                        }
                    }
                }
            }

            foundWordOutlines(cellSize: cellSize)
                .allowsHitTesting(false)

            if let first = activePositions.first, let last = activePositions.last, activePositions.count > 1 {
                selectionCapsule(from: first, to: last, cellSize: cellSize)
            }

            if let feedback {
                feedbackCapsule(feedback, cellSize: cellSize)
                    .transition(.opacity)
            }
        }
        .frame(width: sideLength, height: sideLength)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if let position = position(for: value.location, cellSize: cellSize) {
                        onDragChanged(position)
                    }
                }
                .onEnded { _ in
                    onDragEnded()
                }
        )
        .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
    }

    private func cellFill(isActive: Bool) -> Color {
        if isActive {
            return Color.orange.opacity(0.24)
        }
        return Color.white.opacity(0.18)
    }

    private func selectionCapsule(from start: HostGridPosition, to end: HostGridPosition, cellSize: CGFloat) -> some View {
        let startPoint = center(for: start, cellSize: cellSize)
        let endPoint = center(for: end, cellSize: cellSize)
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let angle = Angle(radians: atan2(dy, dx))
        let centerPoint = CGPoint(x: (startPoint.x + endPoint.x) / 2, y: (startPoint.y + endPoint.y) / 2)
        let capsuleHeight = cellSize * 0.82
        let capsuleWidth = max(capsuleHeight, hypot(dx, dy) + capsuleHeight)

        return Capsule(style: .continuous)
            .fill(Color.orange.opacity(0.18))
            .frame(width: capsuleWidth, height: capsuleHeight)
            .rotationEffect(angle)
            .position(centerPoint)
    }

    @ViewBuilder
    private func feedbackCapsule(_ feedback: HostSelectionFeedback, cellSize: CGFloat) -> some View {
        if let first = feedback.positions.first, let last = feedback.positions.last {
            let startPoint = center(for: first, cellSize: cellSize)
            let endPoint = center(for: last, cellSize: cellSize)
            let capsuleHeight = cellSize * 0.82
            let lineWidth = max(1.8, min(3.6, cellSize * 0.12))
            let color = feedback.kind == .correct ? Color.green : Color.red

            StretchingFeedbackCapsule(
                start: startPoint,
                end: endPoint,
                capsuleHeight: capsuleHeight,
                lineWidth: lineWidth,
                color: color
            )
        }
    }

    private func foundWordOutlines(cellSize: CGFloat) -> some View {
        let capsuleHeight = cellSize * 0.82
        let lineWidth = max(1.5, min(3.0, cellSize * 0.10))

        return ZStack {
            ForEach(solvedWordOutlines) { outline in
                outlineShape(
                    for: outline.positions,
                    cellSize: cellSize,
                    capsuleHeight: capsuleHeight,
                    lineWidth: lineWidth
                )
            }
        }
    }

    @ViewBuilder
    private func outlineShape(
        for positions: [HostGridPosition],
        cellSize: CGFloat,
        capsuleHeight: CGFloat,
        lineWidth: CGFloat
    ) -> some View {
        if let first = positions.first, let last = positions.last {
            let startPoint = center(for: first, cellSize: cellSize)
            let endPoint = center(for: last, cellSize: cellSize)
            let dx = endPoint.x - startPoint.x
            let dy = endPoint.y - startPoint.y
            let angle = Angle(radians: atan2(dy, dx))
            let centerPoint = CGPoint(x: (startPoint.x + endPoint.x) / 2, y: (startPoint.y + endPoint.y) / 2)
            let capsuleWidth = max(capsuleHeight, hypot(dx, dy) + capsuleHeight)

            Capsule(style: .continuous)
                .fill(Color.blue.opacity(0.14))
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color.blue.opacity(0.9), lineWidth: lineWidth)
                )
                .frame(width: capsuleWidth, height: capsuleHeight)
                .rotationEffect(angle)
                .position(centerPoint)
        }
    }

    private var solvedWordOutlines: [WordOutline] {
        let normalizedFound = Set(foundWords.map { $0.uppercased() })

        return words.enumerated().compactMap { index, rawWord in
            let word = rawWord.uppercased()
            guard normalizedFound.contains(word) else { return nil }
            guard let path = bestPath(for: word) else { return nil }
            let signature = path.map { "\($0.row)-\($0.col)" }.joined(separator: "_")
            return WordOutline(
                id: "\(index)-\(word)-\(signature)",
                positions: path
            )
        }
    }

    private func bestPath(for word: String) -> [HostGridPosition]? {
        let candidates = candidatePaths(for: word)
        guard !candidates.isEmpty else { return nil }
        return candidates.max { pathScore($0) < pathScore($1) }
    }

    private func pathScore(_ path: [HostGridPosition]) -> Int {
        path.reduce(0) { partial, position in
            partial + (solvedPositions.contains(position) ? 1 : 0)
        }
    }

    private func candidatePaths(for word: String) -> [[HostGridPosition]] {
        let upperWord = word.uppercased()
        let letters = upperWord.map { String($0) }
        let reversed = Array(letters.reversed())
        let rowCount = grid.count
        let colCount = grid.first?.count ?? 0

        guard !letters.isEmpty else { return [] }
        guard rowCount > 0, colCount > 0 else { return [] }

        var results: [[HostGridPosition]] = []

        for row in 0..<rowCount {
            for col in 0..<colCount {
                for (dr, dc) in directions {
                    var path: [HostGridPosition] = []
                    var collected: [String] = []
                    var isValid = true

                    for step in 0..<letters.count {
                        let r = row + step * dr
                        let c = col + step * dc
                        if r < 0 || c < 0 || r >= rowCount || c >= colCount {
                            isValid = false
                            break
                        }
                        path.append(HostGridPosition(row: r, col: c))
                        collected.append(grid[r][c].uppercased())
                    }

                    guard isValid else { continue }
                    if collected == letters || collected == reversed {
                        results.append(path)
                    }
                }
            }
        }

        return results
    }

    private func center(for position: HostGridPosition, cellSize: CGFloat) -> CGPoint {
        CGPoint(
            x: CGFloat(position.col) * cellSize + cellSize / 2,
            y: CGFloat(position.row) * cellSize + cellSize / 2
        )
    }

    private func position(for location: CGPoint, cellSize: CGFloat) -> HostGridPosition? {
        let row = Int(location.y / cellSize)
        let col = Int(location.x / cellSize)
        guard row >= 0, col >= 0, row < rows, col < cols else { return nil }
        return HostGridPosition(row: row, col: col)
    }
}

private struct StretchingFeedbackCapsule: View {
    let start: CGPoint
    let end: CGPoint
    let capsuleHeight: CGFloat
    let lineWidth: CGFloat
    let color: Color

    @State private var animate = false

    var body: some View {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let angle = Angle(radians: atan2(dy, dx))
        let centerPoint = CGPoint(x: (start.x + end.x) / 2, y: (start.y + end.y) / 2)
        let capsuleWidth = max(capsuleHeight, hypot(dx, dy) + capsuleHeight)

        return Capsule(style: .continuous)
            .stroke(color, lineWidth: lineWidth)
            .frame(width: capsuleWidth, height: capsuleHeight)
            .scaleEffect(x: animate ? 1 : 0.05, y: 1, anchor: .leading)
            .rotationEffect(angle)
            .position(centerPoint)
            .onAppear {
                withAnimation(.easeOut(duration: 0.22)) {
                    animate = true
                }
            }
    }
}

private struct CircleIconButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 40, height: 40)
                .foregroundStyle(.primary)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.55), lineWidth: 0.8)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

private struct InfoPill: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption.weight(.bold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.45), lineWidth: 0.8)
        )
    }
}

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var showSettings = false
    @State private var installDate = HostPuzzleCalendar.installationDate()
    @State private var selectedOffset: Int?
    @State private var navigationPath: [HostRoute] = []
    @State private var gridSize = HostDifficultySettings.gridSize()
    @State private var appearanceMode = HostAppearanceSettings.mode()
    @State private var wordHintMode = HostWordHintSettings.mode()
    @State private var sharedState = HostSharedPuzzleStateStore.loadState(
        now: Date(),
        preferredGridSize: HostDifficultySettings.gridSize()
    )
    @State private var appProgressRecords = HostAppProgressStore.loadRecords()
    @State private var completedOffsets = HostCompletionStore.load()
    @State private var didAnimateIn = false
    @State private var actionFeedbackTrigger = 0

    private var todayOffset: Int {
        let boundary = HostSharedPuzzleStateStore.currentRotationBoundary(for: Date())
        return HostPuzzleCalendar.dayOffset(from: installDate, to: boundary)
    }

    private var minOffset: Int { 0 }
    private var maxOffset: Int { todayOffset + 1 }

    private var carouselOffsets: [Int] {
        var offsets = completedOffsets
        offsets.insert(todayOffset + 1)
        return offsets
            .filter { $0 >= minOffset && $0 <= maxOffset }
            .sorted()
    }

    private var selectedSafeOffset: Int {
        min(max(selectedOffset ?? todayOffset, minOffset), maxOffset)
    }

    private func puzzleDate(for offset: Int) -> Date {
        let boundary = HostSharedPuzzleStateStore.currentRotationBoundary(for: Date())
        let delta = offset - todayOffset
        return Calendar.current.date(byAdding: .day, value: delta, to: boundary) ?? boundary
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                SoftGlowBackground()

                GeometryReader { geometry in
                    let cardWidth = min(geometry.size.width - 32, 560)
                    let cardHeight = min(max(geometry.size.height * 0.58, 360), 520)

                    VStack(spacing: 18) {
                        HomeHeaderView(
                            totalCompleted: completedOffsets.count,
                            trigger: actionFeedbackTrigger
                        ) {
                            actionFeedbackTrigger += 1
                            showSettings = true
                        }

                        let date = puzzleDate(for: selectedSafeOffset)
                        let puzzle = puzzleForOffset(selectedSafeOffset)
                        let progress = progressForOffset(selectedSafeOffset, puzzle: puzzle)
                        let isLocked = selectedSafeOffset > todayOffset
                        let hoursLeft = hoursUntilAvailable(for: selectedSafeOffset)

                        DailyChallengeCard(
                            date: date,
                            puzzle: puzzle,
                            progress: progress,
                            isLocked: isLocked,
                            hoursUntilAvailable: hoursLeft
                        ) {
                            guard !isLocked else { return }
                            navigationPath.append(.game(dayOffset: selectedSafeOffset))
                        }
                        .frame(width: cardWidth, height: cardHeight)

                        Spacer(minLength: 0)

                        DayCarouselView(
                            offsets: carouselOffsets,
                            selectedOffset: $selectedOffset,
                            todayOffset: todayOffset,
                            completedOffsets: completedOffsets,
                            dateForOffset: { puzzleDate(for: $0) }
                        ) { offset in
                            hoursUntilAvailable(for: offset)
                        }
                        .frame(height: 92)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }

            }
            .opacity(didAnimateIn ? 1 : 0)
            .offset(y: didAnimateIn ? 0 : 14)
            .animation(.spring(response: 0.6, dampingFraction: 0.86), value: didAnimateIn)
            .onAppear {
                installDate = HostPuzzleCalendar.installationDate()
                gridSize = HostDifficultySettings.gridSize()
                appearanceMode = HostAppearanceSettings.mode()
                wordHintMode = HostWordHintSettings.mode()
                refreshAppProgress()
                selectedOffset = todayOffset
                didAnimateIn = false
                withAnimation(.spring(response: 0.6, dampingFraction: 0.86)) {
                    didAnimateIn = true
                }
            }
            .onChange(of: scenePhase) { _, phase in
                guard phase == .active else { return }
                installDate = HostPuzzleCalendar.installationDate()
                gridSize = HostDifficultySettings.gridSize()
                appearanceMode = HostAppearanceSettings.mode()
                wordHintMode = HostWordHintSettings.mode()
                refreshAppProgress()
            }
            .onChange(of: selectedOffset) { _, value in
                guard let value else { return }
                if value > maxOffset {
                    selectedOffset = maxOffset
                }
            }
            .navigationDestination(for: HostRoute.self) { route in
                switch route {
                case .game(let offset):
                    let puzzle = puzzleForOffset(offset)
                    let record = offset == todayOffset
                        ? sharedState.asAppRecord(dayOffset: offset, gridSize: gridSize)
                        : appProgressRecord(for: offset)
                    WordSearchGameView(
                        dayOffset: offset,
                        date: puzzleDate(for: offset),
                        puzzle: puzzle,
                        gridSize: gridSize,
                        wordHintMode: wordHintMode,
                        initialProgress: record,
                        sharedSync: offset == todayOffset
                            ? HostSharedSyncContext(puzzleIndex: sharedState.puzzleIndex)
                            : nil
                    ) {
                        refreshAppProgress()
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                DifficultySettingsView(
                    currentGridSize: gridSize,
                    currentAppearanceMode: appearanceMode,
                    currentWordHintMode: wordHintMode
                ) { newGridSize, newAppearanceMode, newWordHintMode in
                    let clamped = HostDifficultySettings.clampGridSize(newGridSize)

                    if clamped != gridSize {
                        gridSize = clamped
                        HostMaintenance.applyGridSize(clamped)
                    }

                    if newAppearanceMode != appearanceMode {
                        appearanceMode = newAppearanceMode
                        HostMaintenance.applyAppearance(newAppearanceMode)
                    }

                    if newWordHintMode != wordHintMode {
                        wordHintMode = newWordHintMode
                        HostMaintenance.applyWordHintMode(newWordHintMode)
                    }

                    refreshAppProgress()
                }
            }
        }
        .preferredColorScheme(appearanceMode.colorScheme)
    }

    private func puzzleForOffset(_ offset: Int) -> HostPuzzle {
        if offset == todayOffset, !sharedState.grid.isEmpty, !sharedState.words.isEmpty {
            return HostPuzzle(
                number: sharedState.puzzleIndex + 1,
                grid: sharedState.grid,
                words: sharedState.words
            )
        }
        return HostPuzzleCalendar.puzzle(forDayOffset: offset, gridSize: gridSize)
    }

    private func progressForOffset(_ offset: Int, puzzle: HostPuzzle) -> HostPuzzleProgress {
        if offset == todayOffset {
            return sharedState.progress(for: puzzle)
        }
        if let record = appProgressRecord(for: offset) {
            return record.progress(for: puzzle)
        }
        return .empty
    }

    private func appProgressRecord(for offset: Int) -> HostAppProgressRecord? {
        let key = HostAppProgressStore.key(for: offset, gridSize: gridSize)
        return appProgressRecords[key]
    }

    private func refreshAppProgress() {
        sharedState = HostSharedPuzzleStateStore.loadState(
            now: Date(),
            preferredGridSize: gridSize
        )
        appProgressRecords = HostAppProgressStore.loadRecords()
        completedOffsets = HostCompletionStore.load()

        if sharedState.isCompleted {
            HostCompletionStore.markCompleted(dayOffset: todayOffset)
            completedOffsets = HostCompletionStore.load()
        }
    }

    private func hoursUntilAvailable(for offset: Int) -> Int? {
        guard offset > todayOffset else { return nil }
        let availableAt = puzzleDate(for: offset)
        let remaining = availableAt.timeIntervalSince(Date())
        if remaining <= 0 {
            return 0
        }
        return Int(ceil(remaining / 3600))
    }

}

private struct PuzzleDayCard: View {
    let date: Date
    let dayOffset: Int
    let todayOffset: Int
    let puzzle: HostPuzzle
    let progress: HostPuzzleProgress
    let wordHintMode: HostWordHintMode
    let isLocked: Bool
    let isFocused: Bool

    private let cardCornerRadius: CGFloat = 34

    private var progressText: String {
        guard !puzzle.words.isEmpty else { return "--" }
        return "\(progress.foundWords.count) de \(puzzle.words.count) encontradas"
    }

    private var titleText: String {
        if dayOffset == todayOffset {
            return "Hoy, \(date.formatted(.dateTime.day().month(.abbreviated).year()))"
        }
        return date.formatted(.dateTime.day().month(.abbreviated).year())
    }

    var body: some View {
        ZStack {
            GeometryReader { cardGeo in
                let horizontalPadding: CGFloat = 24
                let verticalPadding: CGFloat = 22
                let titleHeight: CGFloat = 72
                let progressHeight: CGFloat = 20
                let chipRows = max(1, Int(ceil(Double(puzzle.words.count) / 2.0)))
                let estimatedWordsHeight = CGFloat(chipRows * 42 + max(chipRows - 1, 0) * 8)
                let wordsHeight = min(max(estimatedWordsHeight, 132), 180)
                let spacingTitleToGrid: CGFloat = 18
                let spacingGridToProgress: CGFloat = 14
                let spacingProgressToWords: CGFloat = 12
                let availableGridWidth = max(0, cardGeo.size.width - horizontalPadding * 2)
                let availableGridHeight = max(
                    0,
                    cardGeo.size.height
                        - verticalPadding * 2
                        - titleHeight
                        - progressHeight
                        - wordsHeight
                        - spacingTitleToGrid
                        - spacingGridToProgress
                        - spacingProgressToWords
                )
                let gridSide = max(1, min(availableGridWidth, availableGridHeight))

                VStack(spacing: 0) {
                    Text(titleText.capitalized)
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.38)
                        .frame(maxWidth: .infinity, minHeight: titleHeight, maxHeight: titleHeight, alignment: .center)

                    PuzzleGridPreview(
                        grid: puzzle.grid,
                        words: puzzle.words,
                        foundWords: progress.foundWords,
                        solvedPositions: progress.solvedPositions,
                        sideLength: gridSide
                    )
                    .frame(width: gridSide, height: gridSide, alignment: .center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, spacingTitleToGrid)

                    Text(progressText)
                        .font(.caption.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: progressHeight, maxHeight: progressHeight, alignment: .leading)
                        .padding(.horizontal, 4)
                        .padding(.top, spacingGridToProgress)
                        .foregroundStyle(.secondary)

                    PuzzleWordsPreview(
                        words: puzzle.words,
                        foundWords: progress.foundWords,
                        displayMode: wordHintMode
                    )
                    .frame(height: wordsHeight)
                    .padding(.top, spacingProgressToWords)
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                    .stroke(Color.gray.opacity(0.26), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
            .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
            .blur(radius: isLocked ? 6 : 0)

            if isLocked {
                RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                            .stroke(Color.white.opacity(0.55), lineWidth: 0.8)
                    )
                    .overlay {
                        VStack(spacing: 10) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 24, weight: .bold))
                            Text("Bloqueado")
                                .font(.headline.weight(.bold))
                            Text("Disponible manana")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 20)
                        .multilineTextAlignment(.center)
                    }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isLocked)
        .scaleEffect(isFocused ? 1 : 0.972)
        .opacity(isFocused ? 1 : 0.95)
        .animation(.snappy(duration: 0.28, extraBounce: 0.02), value: isFocused)
    }
}

private struct CarouselDotsView: View {
    let offsets: [Int]
    let selectedOffset: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(offsets, id: \.self) { offset in
                Circle()
                    .fill(offset == selectedOffset ? Color.primary.opacity(0.34) : Color.primary.opacity(0.14))
                    .frame(
                        width: offset == selectedOffset ? 11 : 8,
                        height: offset == selectedOffset ? 11 : 8
                    )
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.45), lineWidth: 0.8)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .animation(.snappy(duration: 0.22), value: selectedOffset)
    }
}

private struct GlassIconLabel: View {
    let systemImage: String
    let trigger: Int

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: 18, weight: .semibold))
            .symbolEffect(.bounce, value: trigger)
            .frame(width: 46, height: 46)
            .foregroundStyle(.primary)
            .background(
            Circle()
                .fill(.ultraThinMaterial)
            )
            .overlay(
            Circle()
                .stroke(Color.white.opacity(0.55), lineWidth: 0.8)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            .accessibilityLabel(systemImage)
    }
}

private struct CelebrationOverlayView: View {
    let kind: CelebrationKind
    let nonce: Int

    private var title: String {
        switch kind {
        case .progress:
            return "Palabra encontrada"
        case .complete:
            return "Sopa completada"
        }
    }

    private var subtitle: String {
        switch kind {
        case .progress:
            return "Buen ritmo. Sigue asi."
        case .complete:
            return "Excelente. Has terminado el puzzle de hoy."
        }
    }

    private var accent: Color {
        switch kind {
        case .progress:
            return Color.green
        case .complete:
            return Color.blue
        }
    }

    private var symbolName: String {
        switch kind {
        case .progress:
            return "sparkles"
        case .complete:
            return "party.popper.fill"
        }
    }

    var body: some View {
        VStack {
            ZStack {
                PulseHalo(color: accent)
                    .id("halo-\(nonce)")

                VStack(spacing: 10) {
                    Image(systemName: symbolName)
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(accent)
                        .symbolEffect(.bounce.byLayer, value: nonce)

                    Text(title)
                        .font(.headline.weight(.bold))

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(accent.opacity(0.30), lineWidth: 1)
                )
            }
            Spacer()
        }
        .padding(.top, 86)
        .padding(.horizontal, 24)
        .allowsHitTesting(false)
    }
}

private struct PulseHalo: View {
    let color: Color
    @State private var animate = false

    var body: some View {
        Circle()
            .stroke(color.opacity(0.32), lineWidth: 2)
            .frame(width: 104, height: 104)
            .scaleEffect(animate ? 1.55 : 0.55)
            .opacity(animate ? 0 : 1)
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    animate = true
                }
            }
    }
}

private struct PuzzleGridPreview: View {
    let grid: [[String]]
    let words: [String]
    let foundWords: Set<String>
    let solvedPositions: Set<HostGridPosition>
    let sideLength: CGFloat
    
    private struct WordOutline: Identifiable {
        let id: String
        let positions: [HostGridPosition]
    }

    private let directions: [(Int, Int)] = [
        (0, 1), (1, 0), (1, 1), (1, -1),
        (0, -1), (-1, 0), (-1, -1), (-1, 1)
    ]

    var body: some View {
        let size = max(grid.count, 1)
        let cellSize = sideLength / CGFloat(size)
        let fontSize = max(8, min(24, cellSize * 0.48))
        let gridShape = RoundedRectangle(cornerRadius: 18, style: .continuous)

        return ZStack {
            VStack(spacing: 0) {
                ForEach(0..<size, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<size, id: \.self) { col in
                            let value = row < grid.count && col < grid[row].count ? grid[row][col] : ""
                            let position = HostGridPosition(row: row, col: col)
                            Text(value)
                                .font(.system(size: fontSize, weight: .medium, design: .rounded))
                                .frame(width: cellSize, height: cellSize)
                                .background(
                                    solvedPositions.contains(position) ? Color.blue.opacity(0.16) : .clear
                                )
                                .overlay(
                                    Rectangle()
                                        .stroke(Color.gray.opacity(0.23), lineWidth: 1)
                                )
                        }
                    }
                }
            }

            foundWordOutlines(cellSize: cellSize)
        }
        .frame(width: sideLength, height: sideLength, alignment: .center)
        .clipShape(gridShape)
        .overlay(
            gridShape
                .stroke(Color.gray.opacity(0.28), lineWidth: 1)
        )
    }

    private func foundWordOutlines(cellSize: CGFloat) -> some View {
        let capsuleHeight = cellSize * 0.82
        let lineWidth = max(1.5, min(3.0, cellSize * 0.10))

        return ZStack {
            ForEach(solvedWordOutlines) { outline in
                outlineShape(
                    for: outline.positions,
                    cellSize: cellSize,
                    capsuleHeight: capsuleHeight,
                    lineWidth: lineWidth
                )
            }
        }
    }

    @ViewBuilder
    private func outlineShape(
        for positions: [HostGridPosition],
        cellSize: CGFloat,
        capsuleHeight: CGFloat,
        lineWidth: CGFloat
    ) -> some View {
        if let first = positions.first, let last = positions.last {
            let start = center(for: first, cellSize: cellSize)
            let end = center(for: last, cellSize: cellSize)
            let dx = end.x - start.x
            let dy = end.y - start.y
            let angle = Angle(radians: atan2(dy, dx))
            let centerPoint = CGPoint(x: (start.x + end.x) / 2, y: (start.y + end.y) / 2)
            let capsuleWidth = max(capsuleHeight, hypot(dx, dy) + capsuleHeight)

            Capsule(style: .continuous)
                .stroke(Color.blue.opacity(0.86), lineWidth: lineWidth)
                .frame(width: capsuleWidth, height: capsuleHeight)
                .rotationEffect(angle)
                .position(centerPoint)
        }
    }

    private func center(for position: HostGridPosition, cellSize: CGFloat) -> CGPoint {
        CGPoint(
            x: CGFloat(position.col) * cellSize + cellSize / 2,
            y: CGFloat(position.row) * cellSize + cellSize / 2
        )
    }

    private var solvedWordOutlines: [WordOutline] {
        let normalizedFoundWords = Set(foundWords.map { $0.uppercased() })

        return words.enumerated().compactMap { index, rawWord in
            let word = rawWord.uppercased()
            guard normalizedFoundWords.contains(word) else { return nil }
            guard let path = bestPath(for: word) else { return nil }
            let signature = path.map { "\($0.row)-\($0.col)" }.joined(separator: "_")
            return WordOutline(
                id: "\(index)-\(word)-\(signature)",
                positions: path
            )
        }
    }

    private func bestPath(for word: String) -> [HostGridPosition]? {
        let candidates = candidatePaths(for: word)
        guard !candidates.isEmpty else { return nil }
        return candidates.max { pathScore($0) < pathScore($1) }
    }

    private func pathScore(_ path: [HostGridPosition]) -> Int {
        path.reduce(0) { partial, position in
            partial + (solvedPositions.contains(position) ? 1 : 0)
        }
    }

    private func candidatePaths(for word: String) -> [[HostGridPosition]] {
        let upperWord = word.uppercased()
        let letters = upperWord.map { String($0) }
        let reversed = Array(letters.reversed())
        let rowCount = grid.count
        let colCount = grid.first?.count ?? 0

        guard !letters.isEmpty else { return [] }
        guard rowCount > 0, colCount > 0 else { return [] }

        var results: [[HostGridPosition]] = []

        for row in 0..<rowCount {
            for col in 0..<colCount {
                for (dr, dc) in directions {
                    var path: [HostGridPosition] = []
                    var collected: [String] = []
                    var isValid = true

                    for step in 0..<letters.count {
                        let r = row + step * dr
                        let c = col + step * dc
                        if r < 0 || c < 0 || r >= rowCount || c >= colCount {
                            isValid = false
                            break
                        }
                        path.append(HostGridPosition(row: r, col: c))
                        collected.append(grid[r][c].uppercased())
                    }

                    guard isValid else { continue }
                    if collected == letters || collected == reversed {
                        results.append(path)
                    }
                }
            }
        }

        return results
    }
}

private struct PuzzleWordsPreview: View {
    let words: [String]
    let foundWords: Set<String>
    let displayMode: HostWordHintMode

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            if displayMode == .definition {
                LazyVStack(spacing: 8) {
                    ForEach(Array(words.enumerated()), id: \.offset) { _, word in
                        let displayText = HostWordHints.displayText(for: word, mode: displayMode)
                        WordChip(
                            word: displayText,
                            isFound: foundWords.contains(word.uppercased()),
                            allowMultiline: true
                        )
                    }
                }
                .padding(.trailing, 4)
            } else {
                let columns = [
                    GridItem(.flexible(minimum: 120), spacing: 8),
                    GridItem(.flexible(minimum: 120), spacing: 8)
                ]
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(Array(words.enumerated()), id: \.offset) { _, word in
                        let displayText = HostWordHints.displayText(for: word, mode: displayMode)
                        WordChip(
                            word: displayText,
                            isFound: foundWords.contains(word.uppercased()),
                            allowMultiline: false
                        )
                    }
                }
                .padding(.trailing, 4)
            }
        }
    }

    private struct WordChip: View {
        let word: String
        let isFound: Bool
        let allowMultiline: Bool

        private var chipFill: Color {
            isFound ? Color.blue.opacity(0.16) : Color.white.opacity(0.32)
        }

        private var chipStroke: Color {
            isFound ? Color.blue.opacity(0.42) : Color.gray.opacity(0.30)
        }

        private var labelColor: Color {
            isFound ? Color.blue.opacity(0.9) : .primary
        }

        var body: some View {
            HStack(spacing: 6) {
                Text(word)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .lineLimit(allowMultiline ? nil : 1)
                    .minimumScaleFactor(allowMultiline ? 1 : 0.45)
                    .allowsTightening(true)
                    .fixedSize(horizontal: false, vertical: allowMultiline)
                    .strikethrough(isFound, color: .blue)
                    .foregroundStyle(labelColor)

                if isFound && !allowMultiline {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.blue)
                        .symbolEffect(.bounce, value: isFound)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity, alignment: allowMultiline ? .leading : .center)
            .background(Capsule().fill(chipFill))
            .overlay(
                Capsule()
                    .stroke(chipStroke, lineWidth: 1)
            )
            .scaleEffect(isFound ? 1.0 : 0.98)
            .animation(.spring(response: 0.35, dampingFraction: 0.74), value: isFound)
        }
    }
}

private struct DifficultySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var gridSize: Int
    @State private var appearanceMode: HostAppearanceMode
    @State private var wordHintMode: HostWordHintMode
    let onSave: (Int, HostAppearanceMode, HostWordHintMode) -> Void

    init(
        currentGridSize: Int,
        currentAppearanceMode: HostAppearanceMode,
        currentWordHintMode: HostWordHintMode,
        onSave: @escaping (Int, HostAppearanceMode, HostWordHintMode) -> Void
    ) {
        _gridSize = State(initialValue: HostDifficultySettings.clampGridSize(currentGridSize))
        _appearanceMode = State(initialValue: currentAppearanceMode)
        _wordHintMode = State(initialValue: currentWordHintMode)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Dificultad") {
                    Stepper(value: $gridSize, in: HostDifficultySettings.minGridSize...HostDifficultySettings.maxGridSize) {
                        Text("Tamano de sopa: \(gridSize)x\(gridSize)")
                    }
                    Text("A mayor tamano, mas dificultad. En el widget las letras y el area tactil se reducen para que entre la cuadricula.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("Apariencia") {
                    Picker("Tema", selection: $appearanceMode) {
                        ForEach(HostAppearanceMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Pistas") {
                    Picker("Modo", selection: $wordHintMode) {
                        ForEach(HostWordHintMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    Text("En definicion, veras la descripcion sin mostrar la palabra.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Guardar") {
                        onSave(gridSize, appearanceMode, wordHintMode)
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct HostPuzzle {
    let number: Int
    let grid: [[String]]
    let words: [String]
}

private struct HostGridPosition: Hashable {
    let row: Int
    let col: Int
}

private struct HostPuzzleProgress {
    let foundWords: Set<String>
    let solvedPositions: Set<HostGridPosition>

    static let empty = HostPuzzleProgress(foundWords: [], solvedPositions: [])
}

private struct HostSharedPosition: Codable, Hashable {
    let r: Int
    let c: Int
}

private enum HostSharedFeedbackKind: String, Codable {
    case correct
    case incorrect
}

private struct HostSharedFeedback: Codable, Equatable {
    var kind: HostSharedFeedbackKind
    var positions: [HostSharedPosition]
    var expiresAt: Date
}

private struct HostSharedPuzzleState: Codable, Equatable {
    var grid: [[String]]
    var words: [String]
    var gridSize: Int
    var anchor: HostSharedPosition?
    var foundWords: Set<String>
    var solvedPositions: Set<HostSharedPosition>
    var puzzleIndex: Int
    var isHelpVisible: Bool
    var feedback: HostSharedFeedback?
    var pendingWord: String?
    var pendingSolvedPositions: Set<HostSharedPosition>
    var nextHintWord: String?
    var nextHintExpiresAt: Date?

    private enum CodingKeys: String, CodingKey {
        case grid
        case words
        case gridSize
        case anchor
        case foundWords
        case solvedPositions
        case puzzleIndex
        case isHelpVisible
        case feedback
        case pendingWord
        case pendingSolvedPositions
        case nextHintWord
        case nextHintExpiresAt
    }

    var isCompleted: Bool {
        let expected = Set(words.map { $0.uppercased() })
        return !expected.isEmpty && expected.isSubset(of: Set(foundWords.map { $0.uppercased() }))
    }

    func progress(for puzzle: HostPuzzle) -> HostPuzzleProgress {
        let puzzleWords = Set(puzzle.words.map { $0.uppercased() })
        let normalizedFound = Set(foundWords.map { $0.uppercased() }).intersection(puzzleWords)
        let maxRow = puzzle.grid.count
        let maxCol = puzzle.grid.first?.count ?? 0
        let normalizedPositions = solvedPositions.compactMap { position -> HostGridPosition? in
            guard position.r >= 0, position.c >= 0, position.r < maxRow, position.c < maxCol else {
                return nil
            }
            return HostGridPosition(row: position.r, col: position.c)
        }
        return HostPuzzleProgress(
            foundWords: normalizedFound,
            solvedPositions: Set(normalizedPositions)
        )
    }

    func asAppRecord(dayOffset: Int, gridSize: Int) -> HostAppProgressRecord {
        let positions = solvedPositions.map { HostAppProgressPosition(row: $0.r, col: $0.c) }
        return HostAppProgressRecord(
            dayOffset: dayOffset,
            gridSize: gridSize,
            foundWords: Array(foundWords),
            solvedPositions: positions,
            startedAt: nil,
            endedAt: nil
        )
    }
}

private struct HostAppProgressPosition: Codable, Hashable {
    let row: Int
    let col: Int
}

private struct HostAppProgressRecord: Codable {
    let dayOffset: Int
    let gridSize: Int
    let foundWords: [String]
    let solvedPositions: [HostAppProgressPosition]
    let startedAt: TimeInterval?
    let endedAt: TimeInterval?

    var startedDate: Date? {
        startedAt.map { Date(timeIntervalSince1970: $0) }
    }

    var endedDate: Date? {
        endedAt.map { Date(timeIntervalSince1970: $0) }
    }

    func progress(for puzzle: HostPuzzle) -> HostPuzzleProgress {
        let puzzleWords = Set(puzzle.words.map { $0.uppercased() })
        let normalizedFound = Set(foundWords.map { $0.uppercased() }).intersection(puzzleWords)
        let maxRow = puzzle.grid.count
        let maxCol = puzzle.grid.first?.count ?? 0
        let normalizedPositions = solvedPositions.compactMap { position -> HostGridPosition? in
            guard position.row >= 0, position.col >= 0, position.row < maxRow, position.col < maxCol else {
                return nil
            }
            return HostGridPosition(row: position.row, col: position.col)
        }
        return HostPuzzleProgress(
            foundWords: normalizedFound,
            solvedPositions: Set(normalizedPositions)
        )
    }
}

private enum HostSharedPuzzleStateStore {
    private static let suite = "group.com.pedrocarrasco.miapp"
    private static let stateKey = "puzzle_state_v3"
    private static let rotationBoundaryKey = "puzzle_rotation_boundary_v3"
    private static let resetRequestKey = "puzzle_reset_request_v1"
    private static let lastAppliedResetKey = "puzzle_last_applied_reset_v1"
    private static let widgetKind = "WordSearchWidget"

    static func loadState(now: Date, preferredGridSize: Int) -> HostSharedPuzzleState {
        guard let defaults = UserDefaults(suiteName: suite) else {
            return makeState(puzzleIndex: 0, gridSize: preferredGridSize)
        }

        let clampedSize = HostDifficultySettings.clampGridSize(preferredGridSize)
        let decoded = decodeState(defaults: defaults)
        var state = decoded ?? makeState(puzzleIndex: 0, gridSize: clampedSize)
        let original = state

        state = normalizedState(state, preferredGridSize: clampedSize)
        state = applyExternalResetIfNeeded(state: state, defaults: defaults, preferredGridSize: clampedSize)
        state = applyDailyRotationIfNeeded(state: state, defaults: defaults, now: now, preferredGridSize: clampedSize)

        if decoded == nil || state != original {
            save(state, defaults: defaults)
        }

        return state
    }

    static func updateProgress(
        puzzleIndex: Int,
        gridSize: Int,
        foundWords: Set<String>,
        solvedPositions: Set<HostGridPosition>
    ) {
        let now = Date()
        var state = loadState(now: now, preferredGridSize: gridSize)
        guard state.puzzleIndex == puzzleIndex else { return }

        let puzzleWords = Set(state.words.map { $0.uppercased() })
        let normalizedFound = Set(foundWords.map { $0.uppercased() }).intersection(puzzleWords)
        let maxRow = state.grid.count
        let maxCol = state.grid.first?.count ?? 0
        let normalizedPositions = solvedPositions.compactMap { position -> HostSharedPosition? in
            guard position.row >= 0, position.col >= 0, position.row < maxRow, position.col < maxCol else {
                return nil
            }
            return HostSharedPosition(r: position.row, c: position.col)
        }

        state.foundWords = normalizedFound
        state.solvedPositions = Set(normalizedPositions)
        save(state)
        WidgetCenter.shared.reloadTimelines(ofKind: widgetKind)
    }

    static func clearProgress(puzzleIndex: Int, gridSize: Int) {
        let now = Date()
        let state = loadState(now: now, preferredGridSize: gridSize)
        guard state.puzzleIndex == puzzleIndex else { return }
        let cleared = clearedState(from: state, preferredGridSize: gridSize)
        save(cleared)
        WidgetCenter.shared.reloadTimelines(ofKind: widgetKind)
    }

    static func currentRotationBoundary(for now: Date) -> Date {
        let calendar = Calendar.current
        let todayNine = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now) ?? now
        if now >= todayNine {
            return todayNine
        }
        return calendar.date(byAdding: .day, value: -1, to: todayNine) ?? todayNine
    }

    private static func save(_ state: HostSharedPuzzleState) {
        guard let defaults = UserDefaults(suiteName: suite) else { return }
        save(state, defaults: defaults)
    }

    private static func save(_ state: HostSharedPuzzleState, defaults: UserDefaults) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        defaults.set(data, forKey: stateKey)
    }

    private static func decodeState(defaults: UserDefaults) -> HostSharedPuzzleState? {
        guard let data = defaults.data(forKey: stateKey) else { return nil }
        return try? JSONDecoder().decode(HostSharedPuzzleState.self, from: data)
    }

    private static func makeState(puzzleIndex: Int, gridSize: Int) -> HostSharedPuzzleState {
        let normalized = HostPuzzleCalendar.normalizedPuzzleIndex(puzzleIndex)
        let size = HostDifficultySettings.clampGridSize(gridSize)
        let puzzle = HostPuzzleCalendar.puzzle(forDayOffset: normalized, gridSize: size)
        return HostSharedPuzzleState(
            grid: puzzle.grid,
            words: puzzle.words,
            gridSize: size,
            anchor: nil,
            foundWords: [],
            solvedPositions: [],
            puzzleIndex: normalized,
            isHelpVisible: false,
            feedback: nil,
            pendingWord: nil,
            pendingSolvedPositions: [],
            nextHintWord: nil,
            nextHintExpiresAt: nil
        )
    }

    private static func normalizedState(_ state: HostSharedPuzzleState, preferredGridSize: Int) -> HostSharedPuzzleState {
        let targetSize = HostDifficultySettings.clampGridSize(preferredGridSize)
        guard state.gridSize == targetSize else {
            return makeState(puzzleIndex: state.puzzleIndex, gridSize: targetSize)
        }
        guard state.grid.count == targetSize, state.grid.allSatisfy({ $0.count == targetSize }) else {
            return makeState(puzzleIndex: state.puzzleIndex, gridSize: targetSize)
        }
        return state
    }

    private static func applyExternalResetIfNeeded(
        state: HostSharedPuzzleState,
        defaults: UserDefaults,
        preferredGridSize: Int
    ) -> HostSharedPuzzleState {
        let requestToken = defaults.double(forKey: resetRequestKey)
        let appliedToken = defaults.double(forKey: lastAppliedResetKey)
        guard requestToken > appliedToken else {
            return state
        }

        defaults.set(requestToken, forKey: lastAppliedResetKey)
        return clearedState(from: state, preferredGridSize: preferredGridSize)
    }

    private static func clearedState(from state: HostSharedPuzzleState, preferredGridSize: Int) -> HostSharedPuzzleState {
        let size = HostDifficultySettings.clampGridSize(preferredGridSize)
        let puzzle = HostPuzzleCalendar.puzzle(forDayOffset: state.puzzleIndex, gridSize: size)
        return HostSharedPuzzleState(
            grid: puzzle.grid,
            words: puzzle.words,
            gridSize: size,
            anchor: nil,
            foundWords: [],
            solvedPositions: [],
            puzzleIndex: state.puzzleIndex,
            isHelpVisible: false,
            feedback: nil,
            pendingWord: nil,
            pendingSolvedPositions: [],
            nextHintWord: nil,
            nextHintExpiresAt: nil
        )
    }

    private static func applyDailyRotationIfNeeded(
        state: HostSharedPuzzleState,
        defaults: UserDefaults,
        now: Date,
        preferredGridSize: Int
    ) -> HostSharedPuzzleState {
        let boundary = currentRotationBoundary(for: now)
        let boundaryTimestamp = boundary.timeIntervalSince1970

        guard let existing = defaults.object(forKey: rotationBoundaryKey) as? Double else {
            defaults.set(boundaryTimestamp, forKey: rotationBoundaryKey)
            return state
        }

        if existing >= boundaryTimestamp {
            return state
        }

        let previousBoundary = Date(timeIntervalSince1970: existing)
        let steps = max(rotationSteps(from: previousBoundary, to: boundary), 1)
        let nextIndex = HostPuzzleCalendar.normalizedPuzzleIndex(state.puzzleIndex + steps)
        defaults.set(boundaryTimestamp, forKey: rotationBoundaryKey)
        return makeState(puzzleIndex: nextIndex, gridSize: preferredGridSize)
    }

    private static func rotationSteps(from previousBoundary: Date, to currentBoundary: Date) -> Int {
        let calendar = Calendar.current
        var steps = 0
        var marker = previousBoundary

        while marker < currentBoundary {
            guard let next = calendar.date(byAdding: .day, value: 1, to: marker) else { break }
            marker = next
            steps += 1
            if steps > 3660 {
                break
            }
        }

        return steps
    }
}

private enum HostAppProgressStore {
    private static let suite = "group.com.pedrocarrasco.miapp"
    private static let stateKey = "puzzle_app_progress_v1"

    static func key(for dayOffset: Int, gridSize: Int) -> String {
        "\(dayOffset)-\(gridSize)"
    }

    static func loadRecords() -> [String: HostAppProgressRecord] {
        guard let defaults = UserDefaults(suiteName: suite) else { return [:] }
        guard let data = defaults.data(forKey: stateKey) else { return [:] }
        guard let decoded = try? JSONDecoder().decode([String: HostAppProgressRecord].self, from: data) else {
            return [:]
        }
        return decoded
    }

    static func save(_ record: HostAppProgressRecord) {
        var records = loadRecords()
        records[key(for: record.dayOffset, gridSize: record.gridSize)] = record
        saveRecords(records)
    }

    static func reset(dayOffset: Int, gridSize: Int) {
        var records = loadRecords()
        records.removeValue(forKey: key(for: dayOffset, gridSize: gridSize))
        saveRecords(records)
    }

    private static func saveRecords(_ records: [String: HostAppProgressRecord]) {
        guard let defaults = UserDefaults(suiteName: suite) else { return }
        guard let data = try? JSONEncoder().encode(records) else { return }
        defaults.set(data, forKey: stateKey)
    }
}

private enum HostCompletionStore {
    private static let suite = "group.com.pedrocarrasco.miapp"
    private static let key = "puzzle_completed_offsets_v1"

    static func load() -> Set<Int> {
        guard let defaults = UserDefaults(suiteName: suite) else { return [] }
        let stored = defaults.array(forKey: key) as? [Int] ?? []
        return Set(stored)
    }

    static func markCompleted(dayOffset: Int) {
        var current = load()
        current.insert(dayOffset)
        save(current)
    }

    private static func save(_ offsets: Set<Int>) {
        guard let defaults = UserDefaults(suiteName: suite) else { return }
        defaults.set(Array(offsets).sorted(), forKey: key)
    }
}

private enum HostDateFormatter {
    private static let weekdays = [
        "domingo", "lunes", "martes", "miercoles", "jueves", "viernes", "sabado"
    ]
    private static let shortWeekdays = [
        "dom", "lun", "mar", "mie", "jue", "vie", "sab"
    ]
    private static let months = [
        "enero", "febrero", "marzo", "abril", "mayo", "junio",
        "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"
    ]

    static func weekdayName(for date: Date) -> String {
        let index = max(0, min(weekdays.count - 1, Calendar.current.component(.weekday, from: date) - 1))
        return weekdays[index]
    }

    static func shortWeekday(for date: Date) -> String {
        let index = max(0, min(shortWeekdays.count - 1, Calendar.current.component(.weekday, from: date) - 1))
        return shortWeekdays[index]
    }

    static func monthDay(for date: Date) -> String {
        let day = Calendar.current.component(.day, from: date)
        let monthIndex = max(0, min(months.count - 1, Calendar.current.component(.month, from: date) - 1))
        return "\(day) de \(months[monthIndex])"
    }
}

private enum HostTimeFormatter {
    static func clock(from interval: TimeInterval) -> String {
        let totalSeconds = max(0, Int(interval.rounded()))
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

private struct HostGeneratedPuzzle {
    let grid: [[String]]
    let words: [String]
}

private struct HostWidgetProgressSnapshot {
    let grid: [[String]]
    let words: [String]
    let foundWords: Set<String>
    let solvedPositions: Set<HostGridPosition>
}

private enum HostWidgetProgressStore {
    private static let suite = "group.com.pedrocarrasco.miapp"
    private static let stateKey = "puzzle_state_v3"

    static func loadSnapshot() -> HostWidgetProgressSnapshot? {
        guard let defaults = UserDefaults(suiteName: suite) else { return nil }
        guard let data = defaults.data(forKey: stateKey) else { return nil }
        guard let decoded = try? JSONDecoder().decode(SharedWidgetState.self, from: data) else { return nil }

        let normalizedGrid = decoded.grid.map { row in row.map { $0.uppercased() } }
        let normalizedWords = decoded.words.map { $0.uppercased() }
        let normalizedFoundWords = Set(decoded.foundWords.map { $0.uppercased() })
        let solvedPositions = Set(decoded.solvedPositions.map { HostGridPosition(row: $0.r, col: $0.c) })

        return HostWidgetProgressSnapshot(
            grid: normalizedGrid,
            words: normalizedWords,
            foundWords: normalizedFoundWords,
            solvedPositions: solvedPositions
        )
    }

    private struct SharedWidgetState: Decodable {
        let grid: [[String]]
        let words: [String]
        let foundWords: Set<String>
        let solvedPositions: Set<SharedWidgetPosition>

        private enum CodingKeys: String, CodingKey {
            case grid
            case words
            case foundWords
            case solvedPositions
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            grid = try container.decodeIfPresent([[String]].self, forKey: .grid) ?? []
            words = try container.decodeIfPresent([String].self, forKey: .words) ?? []
            foundWords = try container.decodeIfPresent(Set<String>.self, forKey: .foundWords) ?? []
            solvedPositions = try container.decodeIfPresent(Set<SharedWidgetPosition>.self, forKey: .solvedPositions) ?? []
        }
    }

    private struct SharedWidgetPosition: Hashable, Decodable {
        let r: Int
        let c: Int
    }
}

private enum HostDifficultySettings {
    static let suite = "group.com.pedrocarrasco.miapp"
    static let gridSizeKey = "puzzle_grid_size_v1"
    static let minGridSize = 7
    static let maxGridSize = 12

    static func clampGridSize(_ value: Int) -> Int {
        min(max(value, minGridSize), maxGridSize)
    }

    static func gridSize() -> Int {
        guard let defaults = UserDefaults(suiteName: suite) else {
            return minGridSize
        }
        let stored = defaults.integer(forKey: gridSizeKey)
        if stored == 0 {
            defaults.set(minGridSize, forKey: gridSizeKey)
            return minGridSize
        }
        let clamped = clampGridSize(stored)
        if clamped != stored {
            defaults.set(clamped, forKey: gridSizeKey)
        }
        return clamped
    }

    static func setGridSize(_ value: Int) {
        guard let defaults = UserDefaults(suiteName: suite) else { return }
        defaults.set(clampGridSize(value), forKey: gridSizeKey)
    }
}

private enum HostAppearanceMode: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system:
            return "System"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }

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

private enum HostAppearanceSettings {
    private static let suite = "group.com.pedrocarrasco.miapp"
    private static let appearanceModeKey = "puzzle_theme_mode_v1"

    static func mode() -> HostAppearanceMode {
        guard let defaults = UserDefaults(suiteName: suite) else {
            return .system
        }
        guard let raw = defaults.string(forKey: appearanceModeKey) else {
            return .system
        }
        return HostAppearanceMode(rawValue: raw) ?? .system
    }

    static func setMode(_ mode: HostAppearanceMode) {
        guard let defaults = UserDefaults(suiteName: suite) else { return }
        defaults.set(mode.rawValue, forKey: appearanceModeKey)
    }
}

private enum HostWordHintMode: String, CaseIterable, Identifiable {
    case word
    case definition

    var id: String { rawValue }

    var title: String {
        switch self {
        case .word:
            return "Palabra"
        case .definition:
            return "Definicion"
        }
    }
}

private enum HostWordHintSettings {
    private static let suite = "group.com.pedrocarrasco.miapp"
    private static let wordHintModeKey = "puzzle_word_hint_mode_v1"

    static func mode() -> HostWordHintMode {
        guard let defaults = UserDefaults(suiteName: suite) else {
            return .word
        }
        guard let raw = defaults.string(forKey: wordHintModeKey) else {
            return .word
        }
        return HostWordHintMode(rawValue: raw) ?? .word
    }

    static func setMode(_ mode: HostWordHintMode) {
        guard let defaults = UserDefaults(suiteName: suite) else { return }
        defaults.set(mode.rawValue, forKey: wordHintModeKey)
    }
}

private enum HostWordHints {
    static func displayText(for word: String, mode: HostWordHintMode) -> String {
        switch mode {
        case .word:
            return word
        case .definition:
            return definition(for: word) ?? "Sin definicion"
        }
    }

    static func definition(for word: String) -> String? {
        let normalized = word.uppercased()
        return definitions[normalized]
    }

    private static let definitions: [String: String] = [
        "ARBOL": "Planta grande con tronco y ramas.",
        "TIERRA": "Suelo donde crecen las plantas.",
        "NUBE": "Masa de vapor de agua en el cielo.",
        "MAR": "Gran extension de agua salada.",
        "SOL": "Estrella que ilumina la Tierra.",
        "RIO": "Corriente natural de agua.",
        "FLOR": "Parte de la planta que produce semillas.",
        "LUNA": "Satelite natural de la Tierra.",
        "MONTE": "Elevacion natural del terreno.",
        "VALLE": "Zona baja entre montes.",
        "BOSQUE": "Conjunto denso de arboles.",
        "RAMA": "Parte del arbol que sale del tronco.",
        "ROCA": "Piedra grande y dura.",
        "PLAYA": "Orilla de arena junto al mar.",
        "NIEVE": "Agua congelada que cae del cielo.",
        "VIENTO": "Movimiento del aire.",
        "TRUENO": "Sonido fuerte tras un rayo.",
        "FUEGO": "Combustion que produce calor y luz.",
        "ARENA": "Granitos que forman playas o desiertos.",
        "ISLA": "Tierra rodeada de agua.",
        "CIELO": "Espacio visible sobre la Tierra.",
        "SELVA": "Bosque tropical muy denso.",
        "LLUVIA": "Agua que cae de las nubes.",
        "CAMINO": "Via o senda para ir de un lugar a otro.",
        "MUSGO": "Planta pequena que crece en lugares humedos.",
        "LAGO": "Cuerpo de agua interior.",
        "PRIMAVERA": "Estacion del anio entre invierno y verano.",
        "HORIZONTE": "Linea donde parece unirse cielo y tierra.",
        "ESTRELLA": "Cuerpo celeste que emite luz.",
        "PLANETA": "Cuerpo que orbita una estrella.",
        "QUESO": "Lacteo curado o fresco hecho de leche.",
        "PAN": "Alimento horneado a base de harina.",
        "MIEL": "Sustancia dulce producida por abejas.",
        "LECHE": "Liquido blanco nutritivo de mamiferos.",
        "UVA": "Fruto pequeno que crece en racimos.",
        "PERA": "Fruta dulce de forma alargada.",
        "CAFE": "Bebida hecha con granos tostados.",
        "TOMATE": "Fruto rojo usado en ensaladas y salsas.",
        "ACEITE": "Liquido graso usado para cocinar.",
        "SAL": "Condimento mineral que realza el sabor.",
        "PASTA": "Masa alimenticia de harina y agua.",
        "ARROZ": "Cereal en grano muy usado en comidas.",
        "PAPAYA": "Fruta tropical de pulpa naranja.",
        "MANGO": "Fruta tropical dulce y jugosa.",
        "BANANA": "Fruta alargada y amarilla.",
        "NARANJA": "Fruta citrica redonda y dulce.",
        "CEREZA": "Fruta pequena roja con hueso.",
        "SOPA": "Comida liquida y caliente.",
        "TORTILLA": "Preparacion de huevo o de masa de maiz.",
        "GALLETA": "Dulce horneado y crujiente.",
        "CHOCOLATE": "Dulce hecho con cacao.",
        "YOGUR": "Lacteo fermentado y cremoso.",
        "MANZANA": "Fruta redonda y crujiente.",
        "AVENA": "Cereal usado en desayunos.",
        "ENSALADA": "Mezcla de vegetales frescos.",
        "PIMIENTO": "Hortaliza de piel lisa y colorida.",
        "LIMON": "Fruta citrica muy acida.",
        "COCO": "Fruto tropical con cascara dura.",
        "ALMENDRA": "Semilla comestible con cascara dura.",
        "ALBAHACA": "Hierba aromatica usada en cocina.",
        "TREN": "Vehiculo que va sobre vias.",
        "BUS": "Vehiculo grande para pasajeros.",
        "CARRO": "Vehiculo de cuatro ruedas.",
        "PUERTA": "Elemento que abre o cierra un paso.",
        "LIBRO": "Conjunto de paginas encuadernadas.",
        "CINE": "Lugar para ver peliculas.",
        "PUENTE": "Estructura que cruza un rio o via.",
        "CALLE": "Via urbana entre edificios.",
        "METRO": "Transporte subterraneo en ciudades.",
        "AVION": "Vehiculo que vuela.",
        "BARRIO": "Zona de una ciudad con identidad propia.",
        "PLAZA": "Espacio publico abierto en la ciudad.",
        "PARQUE": "Area verde para ocio.",
        "TORRE": "Construccion alta y estrecha.",
        "MUSEO": "Lugar donde se exhibe arte o historia.",
        "MAPA": "Representacion grafica de un lugar.",
        "RUTA": "Camino planificado para ir a un destino.",
        "BICICLETA": "Vehiculo de dos ruedas con pedales.",
        "TRAFICO": "Circulacion de vehiculos.",
        "SEMAFORO": "Senal luminosa para regular el paso.",
        "ESTACION": "Lugar de salida y llegada de transporte.",
        "AUTOPISTA": "Via rapida de varios carriles.",
        "TAXI": "Vehiculo de servicio publico individual.",
        "MOTOR": "Maquina que genera movimiento.",
        "VIAJE": "Desplazamiento de un lugar a otro.",
        "MOCHILA": "Bolso que se lleva en la espalda.",
        "PASEO": "Actividad de caminar o recorrer.",
        "CIUDAD": "Asentamiento grande y urbano.",
        "CARTEL": "Placa o anuncio con informacion."
    ]
}

private enum HostPuzzleCalendar {
    private static let suite = "group.com.pedrocarrasco.miapp"
    private static let installDateKey = "puzzle_installation_date_v1"
    private static let themes: [[String]] = [
        [
            "ARBOL", "TIERRA", "NUBE", "MAR", "SOL", "RIO", "FLOR", "LUNA", "MONTE", "VALLE",
            "BOSQUE", "RAMA", "ROCA", "PLAYA", "NIEVE", "VIENTO", "TRUENO", "FUEGO", "ARENA",
            "ISLA", "CIELO", "SELVA", "LLUVIA", "CAMINO", "MUSGO", "LAGO", "PRIMAVERA",
            "HORIZONTE", "ESTRELLA", "PLANETA"
        ],
        [
            "QUESO", "PAN", "MIEL", "LECHE", "UVA", "PERA", "CAFE", "TOMATE", "ACEITE", "SAL",
            "PASTA", "ARROZ", "PAPAYA", "MANGO", "BANANA", "NARANJA", "CEREZA", "SOPA",
            "TORTILLA", "GALLETA", "CHOCOLATE", "YOGUR", "MANZANA", "AVENA", "ENSALADA",
            "PIMIENTO", "LIMON", "COCO", "ALMENDRA", "ALBAHACA"
        ],
        [
            "TREN", "BUS", "CARRO", "PUERTA", "PLAYA", "LIBRO", "CINE", "PUENTE", "CALLE",
            "METRO", "AVION", "BARRIO", "PLAZA", "PARQUE", "TORRE", "MUSEO", "MAPA", "RUTA",
            "BICICLETA", "TRAFICO", "SEMAFORO", "ESTACION", "AUTOPISTA", "TAXI", "MOTOR",
            "VIAJE", "MOCHILA", "PASEO", "CIUDAD", "CARTEL"
        ]
    ]

    static func installationDate() -> Date {
        let calendar = Calendar.current
        let fallback = calendar.startOfDay(for: Date())
        guard let defaults = UserDefaults(suiteName: suite) else {
            return fallback
        }

        if let stored = defaults.object(forKey: installDateKey) as? Date {
            return calendar.startOfDay(for: stored)
        }

        defaults.set(fallback, forKey: installDateKey)
        return fallback
    }

    static func dayOffset(from start: Date, to target: Date) -> Int {
        let calendar = Calendar.current
        let startDay = calendar.startOfDay(for: start)
        let targetDay = calendar.startOfDay(for: target)
        return max(calendar.dateComponents([.day], from: startDay, to: targetDay).day ?? 0, 0)
    }

    static func date(from start: Date, dayOffset: Int) -> Date {
        let calendar = Calendar.current
        let startDay = calendar.startOfDay(for: start)
        return calendar.date(byAdding: .day, value: dayOffset, to: startDay) ?? startDay
    }

    static func puzzle(forDayOffset offset: Int, gridSize: Int) -> HostPuzzle {
        let normalized = normalizedPuzzleIndex(offset)
        let size = HostDifficultySettings.clampGridSize(gridSize)
        let seed = stableSeed(dayOffset: offset, gridSize: size)
        let words = selectWords(from: themes[normalized], gridSize: size, seed: seed)
        let generated = HostPuzzleGenerator.generate(gridSize: size, words: words, seed: seed)
        return HostPuzzle(number: normalized + 1, grid: generated.grid, words: generated.words)
    }

    static func normalizedPuzzleIndex(_ offset: Int) -> Int {
        let count = max(themes.count, 1)
        let value = offset % count
        return value >= 0 ? value : value + count
    }

    private static func stableSeed(dayOffset: Int, gridSize: Int) -> UInt64 {
        let a = UInt64(bitPattern: Int64(dayOffset))
        let b = UInt64(gridSize) << 32
        return (a &* 0x9E3779B185EBCA87) ^ b ^ 0xC0DEC0FFEE12345F
    }

    private static func selectWords(from pool: [String], gridSize: Int, seed: UInt64) -> [String] {
        var filtered = pool
            .map { $0.uppercased() }
            .filter { $0.count >= 3 && $0.count <= gridSize }
        if filtered.isEmpty {
            filtered = ["SOL", "MAR", "RIO", "LUNA", "FLOR", "ROCA"]
        }

        var rng = HostPuzzleGenerator.SeededGenerator(seed: seed ^ 0xA11CE5EED)
        for index in stride(from: filtered.count - 1, through: 1, by: -1) {
            let swapAt = rng.int(upperBound: index + 1)
            if swapAt != index {
                filtered.swapAt(index, swapAt)
            }
        }

        let targetCount = min(filtered.count, max(7, 7 + (gridSize - 7) * 2))
        return Array(filtered.prefix(targetCount))
    }
}

private enum HostPuzzleGenerator {
    private static let directions: [(Int, Int)] = [
        (0, 1), (1, 0), (1, 1), (1, -1),
        (0, -1), (-1, 0), (-1, -1), (-1, 1)
    ]
    private static let alphabet: [String] = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ").map { String($0) }

    struct SeededGenerator {
        private var state: UInt64

        init(seed: UInt64) {
            state = seed == 0 ? 0x1234ABCD5678EF90 : seed
        }

        mutating func next() -> UInt64 {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return state
        }

        mutating func int(upperBound: Int) -> Int {
            guard upperBound > 0 else { return 0 }
            return Int(next() % UInt64(upperBound))
        }
    }

    static func generate(gridSize: Int, words: [String], seed: UInt64) -> HostGeneratedPuzzle {
        let size = HostDifficultySettings.clampGridSize(gridSize)
        let sortedWords = words
            .map { $0.uppercased() }
            .filter { !$0.isEmpty && $0.count <= size }
            .sorted { $0.count > $1.count }

        var fallback = makePuzzle(size: size, words: sortedWords, seed: seed, reduction: 0)
        if fallback.words.count >= 4 {
            return fallback
        }

        for reduction in [2, 4, 6] {
            let reduced = Array(sortedWords.prefix(max(4, sortedWords.count - reduction)))
            let attempt = makePuzzle(size: size, words: reduced, seed: seed, reduction: reduction)
            if attempt.words.count > fallback.words.count {
                fallback = attempt
            }
            if attempt.words.count >= max(4, reduced.count - 1) {
                return attempt
            }
        }

        return fallback
    }

    private static func makePuzzle(size: Int, words: [String], seed: UInt64, reduction: Int) -> HostGeneratedPuzzle {
        var rng = SeededGenerator(seed: seed ^ UInt64(reduction) ^ 0xFEEDBEEF15)
        var board = Array(repeating: Array(repeating: "", count: size), count: size)
        var placedWords: [String] = []

        for word in words {
            if place(word: word, on: &board, size: size, rng: &rng) {
                placedWords.append(word)
            }
        }

        for row in 0..<size {
            for col in 0..<size where board[row][col].isEmpty {
                board[row][col] = alphabet[rng.int(upperBound: alphabet.count)]
            }
        }

        return HostGeneratedPuzzle(grid: board, words: placedWords)
    }

    private static func place(word: String, on board: inout [[String]], size: Int, rng: inout SeededGenerator) -> Bool {
        let letters = word.map { String($0) }
        let count = letters.count
        guard count > 1 else { return false }

        for _ in 0..<300 {
            let direction = directions[rng.int(upperBound: directions.count)]
            let dr = direction.0
            let dc = direction.1

            let minRow = dr < 0 ? count - 1 : 0
            let maxRow = dr > 0 ? size - count : size - 1
            let minCol = dc < 0 ? count - 1 : 0
            let maxCol = dc > 0 ? size - count : size - 1

            if maxRow < minRow || maxCol < minCol {
                continue
            }

            let startRow = minRow + rng.int(upperBound: maxRow - minRow + 1)
            let startCol = minCol + rng.int(upperBound: maxCol - minCol + 1)

            var canPlace = true
            for index in 0..<count {
                let r = startRow + index * dr
                let c = startCol + index * dc
                let existing = board[r][c]
                if !existing.isEmpty && existing != letters[index] {
                    canPlace = false
                    break
                }
            }

            if !canPlace {
                continue
            }

            for index in 0..<count {
                let r = startRow + index * dr
                let c = startCol + index * dc
                board[r][c] = letters[index]
            }
            return true
        }

        return false
    }
}

private enum HostMaintenance {
    private static let suite = "group.com.pedrocarrasco.miapp"
    private static let widgetKind = "WordSearchWidget"
    private static let resetRequestKey = "puzzle_reset_request_v1"

    static func resetCurrentPuzzle() {
        guard let defaults = UserDefaults(suiteName: suite) else { return }
        defaults.set(Date().timeIntervalSince1970, forKey: resetRequestKey)
        WidgetCenter.shared.reloadTimelines(ofKind: widgetKind)
    }

    static func applyGridSize(_ gridSize: Int) {
        HostDifficultySettings.setGridSize(gridSize)
        resetCurrentPuzzle()
    }

    static func applyAppearance(_ mode: HostAppearanceMode) {
        HostAppearanceSettings.setMode(mode)
        WidgetCenter.shared.reloadTimelines(ofKind: widgetKind)
    }

    static func applyWordHintMode(_ mode: HostWordHintMode) {
        HostWordHintSettings.setMode(mode)
        WidgetCenter.shared.reloadTimelines(ofKind: widgetKind)
    }
}

#Preview {
    ContentView()
}
