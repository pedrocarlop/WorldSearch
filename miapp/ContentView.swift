//
//  ContentView.swift
//  miapp
//
//  Created by Pedro Carrasco lopez brea on 8/2/26.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    @State private var showResetConfirmation = false
    @State private var installDate = HostPuzzleCalendar.installationDate()
    @State private var selectedOffset = 0
    @State private var maxOffset = 30

    private var todayOffset: Int {
        HostPuzzleCalendar.dayOffset(from: installDate, to: Date())
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Calendario de puzzles")
                        .font(.title3.weight(.semibold))
                    Text("Desliza para ver las sopas por dia desde la instalacion.")
                        .foregroundStyle(.secondary)
                }

                TabView(selection: $selectedOffset) {
                    ForEach(0...maxOffset, id: \.self) { offset in
                        PuzzleDayCard(
                            date: HostPuzzleCalendar.date(from: installDate, dayOffset: offset),
                            dayOffset: offset,
                            todayOffset: todayOffset,
                            puzzle: HostPuzzleCalendar.puzzle(forDayOffset: offset)
                        )
                        .tag(offset)
                        .padding(.horizontal, 8)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))
                .frame(maxHeight: .infinity)

                Button(role: .destructive) {
                    HostMaintenance.resetCurrentPuzzle()
                    showResetConfirmation = true
                } label: {
                    Label("Reiniciar partida del dia", systemImage: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Sopa")
            .onAppear {
                configureCarousel()
            }
            .onChange(of: selectedOffset) { value in
                if value >= maxOffset - 3 {
                    maxOffset += 30
                }
            }
            .alert("Partida reiniciada", isPresented: $showResetConfirmation) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("El widget recargara el puzzle actual sin progreso.")
            }
        }
    }

    private func configureCarousel() {
        installDate = HostPuzzleCalendar.installationDate()
        let today = todayOffset
        selectedOffset = today
        maxOffset = max(today + 30, 30)
    }
}

private struct PuzzleDayCard: View {
    let date: Date
    let dayOffset: Int
    let todayOffset: Int
    let puzzle: HostPuzzle

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(date, format: .dateTime.weekday(.abbreviated).day().month(.abbreviated).year())
                    .font(.headline)
                Spacer()
                if dayOffset == todayOffset {
                    Text("Hoy")
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.16), in: Capsule())
                }
            }

            Text("Puzzle \(puzzle.number)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            PuzzleGridPreview(grid: puzzle.grid)

            Text("Palabras: \(puzzle.words.joined(separator: ", "))")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .lineLimit(3)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

private struct PuzzleGridPreview: View {
    let grid: [[String]]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { col in
                        Text(grid[row][col])
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity, minHeight: 30)
                            .overlay(
                                Rectangle()
                                    .stroke(Color.gray.opacity(0.28), lineWidth: 1)
                            )
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

private enum HostPuzzleCalendar {
    private static let suite = "group.com.pedrocarrasco.miapp"
    private static let installDateKey = "puzzle_installation_date_v1"

    private static let puzzleRows: [[String]] = [
        ["ARBOLIP", "TIERRAX", "NUBELUZ", "MARAZUL", "SOLROCA", "RIOCASA", "FLORNUB"],
        ["QUESOXR", "PANMIEL", "LECHERA", "UVAFRUT", "PERAXYZ", "SALTOMA", "CAFEBAR"],
        ["TRENBUS", "CARROAV", "PUERTAX", "PLAYAQR", "LIBROSO", "CINEZOO", "NUBEVIA"]
    ]

    private static let puzzleWords: [[String]] = [
        ["ARBOL", "TIERRA", "NUBE", "MAR", "SOL", "RIO", "FLOR"],
        ["QUESO", "PAN", "MIEL", "LECHE", "UVA", "PERA", "CAFE"],
        ["TREN", "BUS", "CARRO", "PUERTA", "PLAYA", "LIBRO", "CINE"]
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

    static func puzzle(forDayOffset offset: Int) -> HostPuzzle {
        let normalized = normalizedPuzzleIndex(offset)
        let rows = puzzleRows[normalized].map { row in row.map { String($0) } }
        return HostPuzzle(
            number: normalized + 1,
            grid: rows,
            words: puzzleWords[normalized]
        )
    }

    private static func normalizedPuzzleIndex(_ offset: Int) -> Int {
        let count = max(puzzleRows.count, 1)
        let value = offset % count
        return value >= 0 ? value : value + count
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
}

#Preview {
    ContentView()
}
