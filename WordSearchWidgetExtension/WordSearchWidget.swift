//
//  WordSearchWidget.swift
//  WordSearchWidgetExtension
//

import WidgetKit
import SwiftUI
import AppIntents

@available(iOS 17.0, *)
struct WordSearchProvider: TimelineProvider {
    typealias Entry = WordSearchEntry

    func placeholder(in context: Context) -> WordSearchEntry {
        WordSearchEntry(date: Date(), state: WordSearchPersistence.loadState(at: Date()))
    }

    func getSnapshot(in context: Context, completion: @escaping (WordSearchEntry) -> Void) {
        let state = WordSearchPersistence.loadState(at: Date())
        completion(WordSearchEntry(date: Date(), state: state))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WordSearchEntry>) -> Void) {
        let now = Date()
        let state = WordSearchPersistence.loadState(at: now)
        let entry = WordSearchEntry(date: now, state: state)
        let refreshAt = WordSearchPersistence.nextRefreshDate(from: now, state: state)
        completion(Timeline(entries: [entry], policy: .after(refreshAt)))
    }
}

@available(iOS 17.0, *)
struct WordSearchEntry: TimelineEntry {
    let date: Date
    let state: WordSearchState
}

@available(iOS 17.0, *)
struct WordSearchWidgetEntryView: View {
    let entry: WordSearchEntry

    var body: some View {
        WordSearchGridWidget(state: entry.state)
            .containerBackground(.fill.tertiary, for: .widget)
    }
}

@available(iOS 17.0, *)
private struct WordSearchGridWidget: View {
    let state: WordSearchState

    private let rows = 7
    private let cols = 7
    private let lineColor = Color.gray.opacity(0.28)
    private let solvedFill = Color.blue.opacity(0.16)
    private let anchorFill = Color.gray.opacity(0.14)
    private let okFill = Color.green.opacity(0.25)
    private let errorFill = Color.red.opacity(0.24)

    var body: some View {
        GeometryReader { geometry in
            let horizontalPadding: CGFloat = 8
            let verticalPadding: CGFloat = 8
            let availableWidth = max(0, geometry.size.width - horizontalPadding * 2)
            let availableHeight = max(0, geometry.size.height - verticalPadding * 2)
            let cellSize = max(40, min(floor(availableWidth / CGFloat(cols)), floor(availableHeight / CGFloat(rows))))
            let boardWidth = cellSize * CGFloat(cols)
            let boardHeight = cellSize * CGFloat(rows)

            ZStack {
                board(cellSize: cellSize)
                    .frame(width: boardWidth, height: boardHeight)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

                if !state.isCompleted {
                    helpButton
                        .padding(8)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                }

                if state.isHelpVisible {
                    helpOverlay
                }

                if state.isCompleted {
                    completionOverlay
                }
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
        }
    }

    private func board(cellSize: CGFloat) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<cols, id: \.self) { col in
                        let position = WordSearchPosition(r: row, c: col)
                        let value = state.grid[row][col]

                        Button(intent: ToggleCellIntent(row: row, col: col)) {
                            Text(value)
                                .font(.system(size: 28, weight: .medium, design: .rounded))
                                .frame(width: cellSize, height: cellSize)
                                .foregroundStyle(.primary)
                                .background(cellFill(for: position))
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .disabled(state.isCompleted || state.isHelpVisible)
                    }
                }
            }
        }
        .overlay(
            GridLines(rows: rows, cols: cols)
                .stroke(lineColor, lineWidth: 1)
        )
    }

    private var helpButton: some View {
        Button(intent: ToggleHelpIntent()) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 26, height: 26)
                .foregroundStyle(.secondary)
                .background(.ultraThinMaterial, in: Circle())
        }
        .buttonStyle(.plain)
    }

    private var helpOverlay: some View {
        ZStack {
            Color.black.opacity(0.18)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                HStack {
                    Spacer()
                    Button(intent: ToggleHelpIntent()) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }

                Text(state.words.joined(separator: "  /  "))
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
            }
            .padding(14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .padding(20)
        }
    }

    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.16)
                .ignoresSafeArea()

            VStack(spacing: 6) {
                Text("Completado")
                    .font(.system(size: 29, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)

                Text("Manana a las 9 se cargara otra sopa de letras.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.center)
                Text("Cada dia se anade un nuevo juego.")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .padding(24)
        }
    }

    private func cellFill(for position: WordSearchPosition) -> Color {
        if let feedback = state.feedback, feedback.positions.contains(position) {
            return feedback.kind == .correct ? okFill : errorFill
        }
        if state.solvedPositions.contains(position) {
            return solvedFill
        }
        if state.anchor == position {
            return anchorFill
        }
        return .clear
    }
}

@available(iOS 17.0, *)
private struct GridLines: Shape {
    let rows: Int
    let cols: Int

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard rows > 0, cols > 0 else { return path }

        let rowHeight = rect.height / CGFloat(rows)
        let colWidth = rect.width / CGFloat(cols)

        for row in 0...rows {
            let y = CGFloat(row) * rowHeight
            path.move(to: CGPoint(x: rect.minX, y: y))
            path.addLine(to: CGPoint(x: rect.maxX, y: y))
        }

        for col in 0...cols {
            let x = CGFloat(col) * colWidth
            path.move(to: CGPoint(x: x, y: rect.minY))
            path.addLine(to: CGPoint(x: x, y: rect.maxY))
        }

        return path
    }
}

@available(iOS 17.0, *)
struct WordSearchWidget: Widget {
    let kind: String = WordSearchConstants.widgetKind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WordSearchProvider()) { entry in
            WordSearchWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Sopa de letras")
        .description("Selecciona una letra inicial y una final para cada palabra.")
        .supportedFamilies([.systemLarge])
        .contentMarginsDisabled()
    }
}
