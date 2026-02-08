//
//  WordSearchIntents.swift
//  WordSearchWidgetExtension
//

import Foundation
import AppIntents
import WidgetKit

@available(iOS 17.0, *)
struct ToggleCellIntent: AppIntent {
    static var title: LocalizedStringResource = "Seleccionar letras"

    @Parameter(title: "Fila") var row: Int
    @Parameter(title: "Columna") var col: Int

    init() {}

    init(row: Int, col: Int) {
        self.row = row
        self.col = col
    }

    func perform() async throws -> some IntentResult {
        var state = WordSearchPersistence.loadState(at: Date())
        state = WordSearchLogic.applyTap(state: state, row: row, col: col, now: Date())
        WordSearchPersistence.save(state)
        WidgetCenter.shared.reloadTimelines(ofKind: WordSearchConstants.widgetKind)
        return .result()
    }
}

@available(iOS 17.0, *)
struct ToggleHelpIntent: AppIntent {
    static var title: LocalizedStringResource = "Mostrar ayuda"

    init() {}

    func perform() async throws -> some IntentResult {
        var state = WordSearchPersistence.loadState(at: Date())
        state = WordSearchLogic.resolveExpiredFeedback(state: state, now: Date())
        state.isHelpVisible.toggle()
        WordSearchPersistence.save(state)
        WidgetCenter.shared.reloadTimelines(ofKind: WordSearchConstants.widgetKind)
        return .result()
    }
}

@available(iOS 17.0, *)
enum WordSearchConstants {
    static let suiteName = "group.com.pedrocarrasco.miapp"
    static let widgetKind = "WordSearchWidget"

    static let stateKey = "puzzle_state_v3"
    static let rotationBoundaryKey = "puzzle_rotation_boundary_v3"
    static let resetRequestKey = "puzzle_reset_request_v1"
    static let lastAppliedResetKey = "puzzle_last_applied_reset_v1"

    static let legacyStateKey = "puzzle_state_v1"
    static let legacyMigrationFlagKey = "puzzle_v2_migrated_legacy"
    static let legacySlotStateKeys = [
        "puzzle_state_v2_a",
        "puzzle_state_v2_b",
        "puzzle_state_v2_c"
    ]
    static let legacySlotIndexKeys = [
        "puzzle_index_v2_a",
        "puzzle_index_v2_b",
        "puzzle_index_v2_c"
    ]
}

@available(iOS 17.0, *)
struct WordSearchPosition: Hashable, Codable {
    let r: Int
    let c: Int
}

@available(iOS 17.0, *)
enum WordSearchFeedbackKind: String, Codable {
    case correct
    case incorrect
}

@available(iOS 17.0, *)
struct WordSearchFeedback: Codable, Equatable {
    var kind: WordSearchFeedbackKind
    var positions: [WordSearchPosition]
    var expiresAt: Date
}

@available(iOS 17.0, *)
struct WordSearchState: Codable, Equatable {
    var grid: [[String]]
    var words: [String]
    var anchor: WordSearchPosition?
    var foundWords: Set<String>
    var solvedPositions: Set<WordSearchPosition>
    var puzzleIndex: Int
    var isHelpVisible: Bool
    var feedback: WordSearchFeedback?
    var pendingWord: String?
    var pendingSolvedPositions: Set<WordSearchPosition>

    private enum CodingKeys: String, CodingKey {
        case grid
        case words
        case anchor
        case foundWords
        case solvedPositions
        case puzzleIndex
        case isHelpVisible
        case feedback
        case pendingWord
        case pendingSolvedPositions
    }

    init(
        grid: [[String]],
        words: [String],
        anchor: WordSearchPosition?,
        foundWords: Set<String>,
        solvedPositions: Set<WordSearchPosition>,
        puzzleIndex: Int,
        isHelpVisible: Bool,
        feedback: WordSearchFeedback?,
        pendingWord: String?,
        pendingSolvedPositions: Set<WordSearchPosition>
    ) {
        self.grid = grid
        self.words = words
        self.anchor = anchor
        self.foundWords = foundWords
        self.solvedPositions = solvedPositions
        self.puzzleIndex = puzzleIndex
        self.isHelpVisible = isHelpVisible
        self.feedback = feedback
        self.pendingWord = pendingWord
        self.pendingSolvedPositions = pendingSolvedPositions
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        grid = try container.decode([[String]].self, forKey: .grid)
        words = try container.decode([String].self, forKey: .words)
        anchor = try container.decodeIfPresent(WordSearchPosition.self, forKey: .anchor)
        foundWords = try container.decodeIfPresent(Set<String>.self, forKey: .foundWords) ?? []
        solvedPositions = try container.decodeIfPresent(Set<WordSearchPosition>.self, forKey: .solvedPositions) ?? []
        puzzleIndex = try container.decodeIfPresent(Int.self, forKey: .puzzleIndex) ?? 0
        isHelpVisible = try container.decodeIfPresent(Bool.self, forKey: .isHelpVisible) ?? false
        feedback = try container.decodeIfPresent(WordSearchFeedback.self, forKey: .feedback)
        pendingWord = try container.decodeIfPresent(String.self, forKey: .pendingWord)
        pendingSolvedPositions = try container.decodeIfPresent(Set<WordSearchPosition>.self, forKey: .pendingSolvedPositions) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(grid, forKey: .grid)
        try container.encode(words, forKey: .words)
        try container.encodeIfPresent(anchor, forKey: .anchor)
        try container.encode(foundWords, forKey: .foundWords)
        try container.encode(solvedPositions, forKey: .solvedPositions)
        try container.encode(puzzleIndex, forKey: .puzzleIndex)
        try container.encode(isHelpVisible, forKey: .isHelpVisible)
        try container.encodeIfPresent(feedback, forKey: .feedback)
        try container.encodeIfPresent(pendingWord, forKey: .pendingWord)
        try container.encode(pendingSolvedPositions, forKey: .pendingSolvedPositions)
    }

    var isCompleted: Bool {
        let expected = Set(words.map { $0.uppercased() })
        return !expected.isEmpty && expected.isSubset(of: Set(foundWords.map { $0.uppercased() }))
    }
}

@available(iOS 17.0, *)
struct WordSearchPuzzle {
    let grid: [[String]]
    let words: [String]
}

@available(iOS 17.0, *)
enum WordSearchPuzzleBank {
    static let puzzles: [WordSearchPuzzle] = [
        build(
            [
                "ARBOLIP",
                "TIERRAX",
                "NUBELUZ",
                "MARAZUL",
                "SOLROCA",
                "RIOCASA",
                "FLORNUB"
            ],
            words: ["ARBOL", "TIERRA", "NUBE", "MAR", "SOL", "RIO", "FLOR"]
        ),
        build(
            [
                "QUESOXR",
                "PANMIEL",
                "LECHERA",
                "UVAFRUT",
                "PERAXYZ",
                "SALTOMA",
                "CAFEBAR"
            ],
            words: ["QUESO", "PAN", "MIEL", "LECHE", "UVA", "PERA", "CAFE"]
        ),
        build(
            [
                "TRENBUS",
                "CARROAV",
                "PUERTAX",
                "PLAYAQR",
                "LIBROSO",
                "CINEZOO",
                "NUBEVIA"
            ],
            words: ["TREN", "BUS", "CARRO", "PUERTA", "PLAYA", "LIBRO", "CINE"]
        )
    ]

    static func puzzle(at index: Int) -> WordSearchPuzzle {
        puzzles[normalizedIndex(index)]
    }

    static func normalizedIndex(_ index: Int) -> Int {
        let count = max(puzzles.count, 1)
        let value = index % count
        return value >= 0 ? value : value + count
    }

    private static func build(_ rows: [String], words: [String]) -> WordSearchPuzzle {
        let grid = rows.map { row in
            let letters = row.uppercased().map { String($0) }
            if letters.count == 7 {
                return letters
            }
            if letters.count > 7 {
                return Array(letters.prefix(7))
            }
            return letters + Array(repeating: "X", count: 7 - letters.count)
        }
        return WordSearchPuzzle(grid: grid, words: words.map { $0.uppercased() })
    }
}

@available(iOS 17.0, *)
enum WordSearchPersistence {
    static func loadState(at now: Date = Date()) -> WordSearchState {
        guard let defaults = UserDefaults(suiteName: WordSearchConstants.suiteName) else {
            return makeState(puzzleIndex: 0)
        }

        migrateLegacyIfNeeded(defaults: defaults)

        let decoded = decodeState(defaults: defaults)
        var state = decoded ?? makeState(puzzleIndex: 0)
        state = normalizedState(state)
        let original = state

        state = applyExternalResetIfNeeded(state: state, defaults: defaults)
        state = applyDailyRotationIfNeeded(state: state, defaults: defaults, now: now)
        state = WordSearchLogic.resolveExpiredFeedback(state: state, now: now)

        if decoded == nil || state != original {
            save(state, defaults: defaults)
        }

        return state
    }

    static func save(_ state: WordSearchState) {
        guard let defaults = UserDefaults(suiteName: WordSearchConstants.suiteName) else { return }
        save(state, defaults: defaults)
    }

    static func nextRefreshDate(from now: Date, state: WordSearchState) -> Date {
        let dailyRefresh = nextDailyRefreshDate(after: now)
        if let feedback = state.feedback, feedback.expiresAt > now {
            return min(dailyRefresh, feedback.expiresAt)
        }
        return dailyRefresh
    }

    static func nextDailyRefreshDate(after now: Date) -> Date {
        let calendar = Calendar.current
        let todayNine = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now) ?? now
        if now < todayNine {
            return todayNine
        }
        return calendar.date(byAdding: .day, value: 1, to: todayNine) ?? now.addingTimeInterval(86_400)
    }

    private static func save(_ state: WordSearchState, defaults: UserDefaults) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        defaults.set(data, forKey: WordSearchConstants.stateKey)
    }

    private static func decodeState(defaults: UserDefaults) -> WordSearchState? {
        guard let data = defaults.data(forKey: WordSearchConstants.stateKey) else { return nil }
        return try? JSONDecoder().decode(WordSearchState.self, from: data)
    }

    private static func makeState(puzzleIndex: Int) -> WordSearchState {
        let normalized = WordSearchPuzzleBank.normalizedIndex(puzzleIndex)
        let puzzle = WordSearchPuzzleBank.puzzle(at: normalized)
        return WordSearchState(
            grid: puzzle.grid,
            words: puzzle.words,
            anchor: nil,
            foundWords: [],
            solvedPositions: [],
            puzzleIndex: normalized,
            isHelpVisible: false,
            feedback: nil,
            pendingWord: nil,
            pendingSolvedPositions: []
        )
    }

    private static func normalizedState(_ state: WordSearchState) -> WordSearchState {
        guard state.grid.count == 7, state.grid.allSatisfy({ $0.count == 7 }) else {
            return makeState(puzzleIndex: state.puzzleIndex)
        }
        return state
    }

    private static func applyExternalResetIfNeeded(state: WordSearchState, defaults: UserDefaults) -> WordSearchState {
        let requestToken = defaults.double(forKey: WordSearchConstants.resetRequestKey)
        let appliedToken = defaults.double(forKey: WordSearchConstants.lastAppliedResetKey)
        guard requestToken > appliedToken else {
            return state
        }

        defaults.set(requestToken, forKey: WordSearchConstants.lastAppliedResetKey)
        return clearedState(from: state)
    }

    private static func clearedState(from state: WordSearchState) -> WordSearchState {
        let puzzle = WordSearchPuzzleBank.puzzle(at: state.puzzleIndex)
        return WordSearchState(
            grid: puzzle.grid,
            words: puzzle.words,
            anchor: nil,
            foundWords: [],
            solvedPositions: [],
            puzzleIndex: state.puzzleIndex,
            isHelpVisible: false,
            feedback: nil,
            pendingWord: nil,
            pendingSolvedPositions: []
        )
    }

    private static func applyDailyRotationIfNeeded(state: WordSearchState, defaults: UserDefaults, now: Date) -> WordSearchState {
        let boundary = currentRotationBoundary(for: now)
        let boundaryTimestamp = boundary.timeIntervalSince1970

        guard let existing = defaults.object(forKey: WordSearchConstants.rotationBoundaryKey) as? Double else {
            defaults.set(boundaryTimestamp, forKey: WordSearchConstants.rotationBoundaryKey)
            return state
        }

        if existing >= boundaryTimestamp {
            return state
        }

        let previousBoundary = Date(timeIntervalSince1970: existing)
        let steps = max(rotationSteps(from: previousBoundary, to: boundary), 1)
        let nextIndex = WordSearchPuzzleBank.normalizedIndex(state.puzzleIndex + steps)
        defaults.set(boundaryTimestamp, forKey: WordSearchConstants.rotationBoundaryKey)
        return makeState(puzzleIndex: nextIndex)
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

    private static func currentRotationBoundary(for now: Date) -> Date {
        let calendar = Calendar.current
        let todayNine = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now) ?? now
        if now >= todayNine {
            return todayNine
        }
        return calendar.date(byAdding: .day, value: -1, to: todayNine) ?? todayNine
    }

    private static func migrateLegacyIfNeeded(defaults: UserDefaults) {
        if defaults.data(forKey: WordSearchConstants.stateKey) != nil {
            return
        }

        if let slotData = defaults.data(forKey: WordSearchConstants.legacySlotStateKeys[0]),
           let legacy = try? JSONDecoder().decode(LegacySlotState.self, from: slotData),
           let puzzle = makePuzzleFromLegacy(legacy.grid, words: legacy.words) {
            let migrated = WordSearchState(
                grid: puzzle.grid,
                words: puzzle.words,
                anchor: nil,
                foundWords: Set(legacy.foundWords.map { $0.uppercased() }),
                solvedPositions: Set(legacy.solvedPositions.map { WordSearchPosition(r: $0.r, c: $0.c) }),
                puzzleIndex: WordSearchPuzzleBank.normalizedIndex(legacy.puzzleIndex),
                isHelpVisible: false,
                feedback: nil,
                pendingWord: nil,
                pendingSolvedPositions: []
            )
            save(migrated, defaults: defaults)
            defaults.removeObject(forKey: WordSearchConstants.legacyStateKey)
            defaults.removeObject(forKey: WordSearchConstants.legacyMigrationFlagKey)
            cleanupLegacySlotKeys(defaults: defaults)
            return
        }

        if let legacyData = defaults.data(forKey: WordSearchConstants.legacyStateKey),
           let legacy = try? JSONDecoder().decode(LegacyPuzzleStateV1.self, from: legacyData),
           let puzzle = makePuzzleFromLegacy(legacy.grid, words: legacy.words) {
            let migrated = WordSearchState(
                grid: puzzle.grid,
                words: puzzle.words,
                anchor: nil,
                foundWords: Set(legacy.foundWords.map { $0.uppercased() }),
                solvedPositions: [],
                puzzleIndex: 0,
                isHelpVisible: false,
                feedback: nil,
                pendingWord: nil,
                pendingSolvedPositions: []
            )
            save(migrated, defaults: defaults)
            defaults.removeObject(forKey: WordSearchConstants.legacyStateKey)
            defaults.removeObject(forKey: WordSearchConstants.legacyMigrationFlagKey)
            cleanupLegacySlotKeys(defaults: defaults)
        }
    }

    private static func cleanupLegacySlotKeys(defaults: UserDefaults) {
        for key in WordSearchConstants.legacySlotStateKeys + WordSearchConstants.legacySlotIndexKeys {
            defaults.removeObject(forKey: key)
        }
    }

    private static func makePuzzleFromLegacy(_ grid: [[String]], words: [String]) -> WordSearchPuzzle? {
        guard grid.count == 7, grid.allSatisfy({ $0.count == 7 }) else {
            return nil
        }
        return WordSearchPuzzle(
            grid: grid.map { row in row.map { $0.uppercased() } },
            words: words.map { $0.uppercased() }
        )
    }
}

@available(iOS 17.0, *)
enum WordSearchLogic {
    static func applyTap(state: WordSearchState, row: Int, col: Int, now: Date) -> WordSearchState {
        var next = resolveExpiredFeedback(state: state, now: now)

        guard row >= 0, col >= 0, row < next.grid.count, col < (next.grid.first?.count ?? 0) else {
            return next
        }

        if next.isCompleted {
            return next
        }

        let tapped = WordSearchPosition(r: row, c: col)
        next.isHelpVisible = false

        guard let anchor = next.anchor else {
            next.anchor = tapped
            next.feedback = nil
            next.pendingWord = nil
            next.pendingSolvedPositions.removeAll()
            return next
        }

        if anchor == tapped {
            next.anchor = nil
            next.feedback = nil
            next.pendingWord = nil
            next.pendingSolvedPositions.removeAll()
            return next
        }

        let linePath = path(from: anchor, to: tapped, in: next)
        if let linePath, let matchedWord = wordFromPath(state: next, path: linePath) {
            next.feedback = WordSearchFeedback(
                kind: .correct,
                positions: linePath,
                expiresAt: now.addingTimeInterval(0.33)
            )
            next.pendingWord = matchedWord.uppercased()
            next.pendingSolvedPositions = Set(linePath)
        } else {
            let preview = linePath ?? [anchor, tapped]
            next.feedback = WordSearchFeedback(
                kind: .incorrect,
                positions: preview,
                expiresAt: now.addingTimeInterval(0.33)
            )
            next.pendingWord = nil
            next.pendingSolvedPositions.removeAll()
        }

        next.anchor = nil
        return next
    }

    static func resolveExpiredFeedback(state: WordSearchState, now: Date) -> WordSearchState {
        guard let feedback = state.feedback else { return state }
        guard now >= feedback.expiresAt else { return state }

        var next = state
        if feedback.kind == .correct, let pendingWord = next.pendingWord?.uppercased() {
            next.foundWords.insert(pendingWord)
            next.solvedPositions.formUnion(next.pendingSolvedPositions)
        }
        next.feedback = nil
        next.pendingWord = nil
        next.pendingSolvedPositions.removeAll()
        return next
    }

    static func path(from start: WordSearchPosition, to end: WordSearchPosition, in state: WordSearchState) -> [WordSearchPosition]? {
        let dr = end.r - start.r
        let dc = end.c - start.c
        let absDr = abs(dr)
        let absDc = abs(dc)

        if !(dr == 0 || dc == 0 || absDr == absDc) {
            return nil
        }

        let stepR = dr == 0 ? 0 : dr / absDr
        let stepC = dc == 0 ? 0 : dc / absDc
        let steps = max(absDr, absDc)
        var result: [WordSearchPosition] = []

        for index in 0...steps {
            let r = start.r + index * stepR
            let c = start.c + index * stepC
            if r < 0 || c < 0 || r >= state.grid.count || c >= (state.grid.first?.count ?? 0) {
                return nil
            }
            result.append(WordSearchPosition(r: r, c: c))
        }

        return result
    }

    static func wordFromPath(state: WordSearchState, path: [WordSearchPosition]) -> String? {
        guard path.count >= 2 else { return nil }
        let candidate = path.map { state.grid[$0.r][$0.c] }.joined().uppercased()
        let reversed = String(candidate.reversed())
        let allowed = Set(state.words.map { $0.uppercased() })
        if allowed.contains(candidate) {
            return candidate
        }
        if allowed.contains(reversed) {
            return reversed
        }
        return nil
    }
}

@available(iOS 17.0, *)
private struct LegacyPosition: Codable {
    let r: Int
    let c: Int
}

@available(iOS 17.0, *)
private struct LegacySlotState: Codable {
    var grid: [[String]]
    var words: [String]
    var foundWords: [String]
    var solvedPositions: [LegacyPosition]
    var puzzleIndex: Int
}

@available(iOS 17.0, *)
private struct LegacyPuzzleStateV1: Codable {
    var grid: [[String]]
    var words: [String]
    var foundWords: Set<String>
}
