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
struct DismissHintIntent: AppIntent {
    static var title: LocalizedStringResource = "Ocultar pista"

    init() {}

    func perform() async throws -> some IntentResult {
        var state = WordSearchPersistence.loadState(at: Date())
        state.nextHintWord = nil
        state.nextHintExpiresAt = nil
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
    static let appearanceModeKey = "puzzle_theme_mode_v1"
    static let gridSizeKey = "puzzle_grid_size_v1"
    static let wordHintModeKey = "puzzle_word_hint_mode_v1"
    static let minGridSize = 7
    static let maxGridSize = 12

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
enum WordSearchDifficulty {
    static func clampGridSize(_ value: Int) -> Int {
        min(max(value, WordSearchConstants.minGridSize), WordSearchConstants.maxGridSize)
    }

    static func preferredGridSize(defaults: UserDefaults?) -> Int {
        guard let defaults else { return WordSearchConstants.minGridSize }
        let stored = defaults.integer(forKey: WordSearchConstants.gridSizeKey)
        if stored == 0 {
            defaults.set(WordSearchConstants.minGridSize, forKey: WordSearchConstants.gridSizeKey)
            return WordSearchConstants.minGridSize
        }
        let clamped = clampGridSize(stored)
        if clamped != stored {
            defaults.set(clamped, forKey: WordSearchConstants.gridSizeKey)
        }
        return clamped
    }
}

@available(iOS 17.0, *)
enum WordSearchHintMode: String, CaseIterable, Identifiable {
    case word
    case definition

    var id: String { rawValue }

    static func current(defaults: UserDefaults?) -> WordSearchHintMode {
        guard let defaults else { return .word }
        guard let raw = defaults.string(forKey: WordSearchConstants.wordHintModeKey) else { return .word }
        return WordSearchHintMode(rawValue: raw) ?? .word
    }
}

@available(iOS 17.0, *)
enum WordSearchWordHints {
    static func displayText(for word: String, mode: WordSearchHintMode) -> String {
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
    var gridSize: Int
    var anchor: WordSearchPosition?
    var foundWords: Set<String>
    var solvedPositions: Set<WordSearchPosition>
    var puzzleIndex: Int
    var isHelpVisible: Bool
    var feedback: WordSearchFeedback?
    var pendingWord: String?
    var pendingSolvedPositions: Set<WordSearchPosition>
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

    init(
        grid: [[String]],
        words: [String],
        gridSize: Int,
        anchor: WordSearchPosition?,
        foundWords: Set<String>,
        solvedPositions: Set<WordSearchPosition>,
        puzzleIndex: Int,
        isHelpVisible: Bool,
        feedback: WordSearchFeedback?,
        pendingWord: String?,
        pendingSolvedPositions: Set<WordSearchPosition>,
        nextHintWord: String?,
        nextHintExpiresAt: Date?
    ) {
        self.grid = grid
        self.words = words
        self.gridSize = gridSize
        self.anchor = anchor
        self.foundWords = foundWords
        self.solvedPositions = solvedPositions
        self.puzzleIndex = puzzleIndex
        self.isHelpVisible = isHelpVisible
        self.feedback = feedback
        self.pendingWord = pendingWord
        self.pendingSolvedPositions = pendingSolvedPositions
        self.nextHintWord = nextHintWord
        self.nextHintExpiresAt = nextHintExpiresAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        grid = try container.decode([[String]].self, forKey: .grid)
        words = try container.decode([String].self, forKey: .words)
        let decodedSize = try container.decodeIfPresent(Int.self, forKey: .gridSize) ?? grid.count
        gridSize = WordSearchDifficulty.clampGridSize(decodedSize)
        anchor = try container.decodeIfPresent(WordSearchPosition.self, forKey: .anchor)
        foundWords = try container.decodeIfPresent(Set<String>.self, forKey: .foundWords) ?? []
        solvedPositions = try container.decodeIfPresent(Set<WordSearchPosition>.self, forKey: .solvedPositions) ?? []
        puzzleIndex = try container.decodeIfPresent(Int.self, forKey: .puzzleIndex) ?? 0
        isHelpVisible = try container.decodeIfPresent(Bool.self, forKey: .isHelpVisible) ?? false
        feedback = try container.decodeIfPresent(WordSearchFeedback.self, forKey: .feedback)
        pendingWord = try container.decodeIfPresent(String.self, forKey: .pendingWord)
        pendingSolvedPositions = try container.decodeIfPresent(Set<WordSearchPosition>.self, forKey: .pendingSolvedPositions) ?? []
        nextHintWord = try container.decodeIfPresent(String.self, forKey: .nextHintWord)
        nextHintExpiresAt = try container.decodeIfPresent(Date.self, forKey: .nextHintExpiresAt)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(grid, forKey: .grid)
        try container.encode(words, forKey: .words)
        try container.encode(gridSize, forKey: .gridSize)
        try container.encodeIfPresent(anchor, forKey: .anchor)
        try container.encode(foundWords, forKey: .foundWords)
        try container.encode(solvedPositions, forKey: .solvedPositions)
        try container.encode(puzzleIndex, forKey: .puzzleIndex)
        try container.encode(isHelpVisible, forKey: .isHelpVisible)
        try container.encodeIfPresent(feedback, forKey: .feedback)
        try container.encodeIfPresent(pendingWord, forKey: .pendingWord)
        try container.encode(pendingSolvedPositions, forKey: .pendingSolvedPositions)
        try container.encodeIfPresent(nextHintWord, forKey: .nextHintWord)
        try container.encodeIfPresent(nextHintExpiresAt, forKey: .nextHintExpiresAt)
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

    static func normalizedIndex(_ index: Int) -> Int {
        let count = max(themes.count, 1)
        let value = index % count
        return value >= 0 ? value : value + count
    }

    static func puzzle(at index: Int, gridSize: Int) -> WordSearchPuzzle {
        let normalizedIndex = normalizedIndex(index)
        let size = WordSearchDifficulty.clampGridSize(gridSize)
        let themeWords = themes[normalizedIndex]
        let seed = stableSeed(puzzleIndex: index, gridSize: size)
        let selectedWords = selectWords(from: themeWords, gridSize: size, seed: seed)
        let generated = WordSearchGenerator.generate(gridSize: size, words: selectedWords, seed: seed)
        return generated
    }

    private static func selectWords(from pool: [String], gridSize: Int, seed: UInt64) -> [String] {
        var filtered = pool
            .map { $0.uppercased() }
            .filter { $0.count >= 3 && $0.count <= gridSize }
        if filtered.isEmpty {
            filtered = ["SOL", "MAR", "RIO", "LUNA", "FLOR", "ROCA"]
        }

        var rng = WordSearchGenerator.SeededGenerator(seed: seed ^ 0xA11CE5EED)
        for index in stride(from: filtered.count - 1, through: 1, by: -1) {
            let swapAt = rng.int(upperBound: index + 1)
            if swapAt != index {
                filtered.swapAt(index, swapAt)
            }
        }

        let targetCount = min(filtered.count, max(7, 7 + (gridSize - 7) * 2))
        return Array(filtered.prefix(targetCount))
    }

    private static func stableSeed(puzzleIndex: Int, gridSize: Int) -> UInt64 {
        let a = UInt64(bitPattern: Int64(puzzleIndex))
        let b = UInt64(gridSize) << 32
        return (a &* 0x9E3779B185EBCA87) ^ b ^ 0xC0DEC0FFEE12345F
    }
}

@available(iOS 17.0, *)
enum WordSearchGenerator {
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

    static func generate(gridSize: Int, words: [String], seed: UInt64) -> WordSearchPuzzle {
        let size = WordSearchDifficulty.clampGridSize(gridSize)
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

    private static func makePuzzle(size: Int, words: [String], seed: UInt64, reduction: Int) -> WordSearchPuzzle {
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

        return WordSearchPuzzle(grid: board, words: placedWords)
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

@available(iOS 17.0, *)
enum WordSearchPersistence {
    static func loadState(at now: Date = Date()) -> WordSearchState {
        guard let defaults = UserDefaults(suiteName: WordSearchConstants.suiteName) else {
            return makeState(puzzleIndex: 0, gridSize: WordSearchConstants.minGridSize)
        }

        migrateLegacyIfNeeded(defaults: defaults)

        let preferredGridSize = WordSearchDifficulty.preferredGridSize(defaults: defaults)
        let decoded = decodeState(defaults: defaults)
        var state = decoded ?? makeState(puzzleIndex: 0, gridSize: preferredGridSize)
        state = normalizedState(state, preferredGridSize: preferredGridSize)
        let original = state

        state = applyExternalResetIfNeeded(state: state, defaults: defaults, preferredGridSize: preferredGridSize)
        state = applyDailyRotationIfNeeded(state: state, defaults: defaults, now: now, preferredGridSize: preferredGridSize)
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
        var refreshAt = nextDailyRefreshDate(after: now)
        if let feedback = state.feedback, feedback.expiresAt > now {
            refreshAt = min(refreshAt, feedback.expiresAt)
        }
        if let hintExpiry = state.nextHintExpiresAt, hintExpiry > now {
            refreshAt = min(refreshAt, hintExpiry)
        }
        return refreshAt
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

    private static func makeState(puzzleIndex: Int, gridSize: Int) -> WordSearchState {
        let normalized = WordSearchPuzzleBank.normalizedIndex(puzzleIndex)
        let size = WordSearchDifficulty.clampGridSize(gridSize)
        let puzzle = WordSearchPuzzleBank.puzzle(at: normalized, gridSize: size)
        return WordSearchState(
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

    private static func normalizedState(_ state: WordSearchState, preferredGridSize: Int) -> WordSearchState {
        let targetSize = WordSearchDifficulty.clampGridSize(preferredGridSize)
        guard state.gridSize == targetSize else {
            return makeState(puzzleIndex: state.puzzleIndex, gridSize: targetSize)
        }
        guard state.grid.count == targetSize, state.grid.allSatisfy({ $0.count == targetSize }) else {
            return makeState(puzzleIndex: state.puzzleIndex, gridSize: targetSize)
        }
        return state
    }

    private static func applyExternalResetIfNeeded(
        state: WordSearchState,
        defaults: UserDefaults,
        preferredGridSize: Int
    ) -> WordSearchState {
        let requestToken = defaults.double(forKey: WordSearchConstants.resetRequestKey)
        let appliedToken = defaults.double(forKey: WordSearchConstants.lastAppliedResetKey)
        guard requestToken > appliedToken else {
            return state
        }

        defaults.set(requestToken, forKey: WordSearchConstants.lastAppliedResetKey)
        return clearedState(from: state, preferredGridSize: preferredGridSize)
    }

    private static func clearedState(from state: WordSearchState, preferredGridSize: Int) -> WordSearchState {
        let size = WordSearchDifficulty.clampGridSize(preferredGridSize)
        let puzzle = WordSearchPuzzleBank.puzzle(at: state.puzzleIndex, gridSize: size)
        return WordSearchState(
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
        state: WordSearchState,
        defaults: UserDefaults,
        now: Date,
        preferredGridSize: Int
    ) -> WordSearchState {
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
            let size = WordSearchDifficulty.clampGridSize(puzzle.grid.count)
            let migrated = WordSearchState(
                grid: puzzle.grid,
                words: puzzle.words,
                gridSize: size,
                anchor: nil,
                foundWords: Set(legacy.foundWords.map { $0.uppercased() }),
                solvedPositions: Set(legacy.solvedPositions.map { WordSearchPosition(r: $0.r, c: $0.c) }),
                puzzleIndex: WordSearchPuzzleBank.normalizedIndex(legacy.puzzleIndex),
                isHelpVisible: false,
                feedback: nil,
                pendingWord: nil,
                pendingSolvedPositions: [],
                nextHintWord: nil,
                nextHintExpiresAt: nil
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
            let size = WordSearchDifficulty.clampGridSize(puzzle.grid.count)
            let migrated = WordSearchState(
                grid: puzzle.grid,
                words: puzzle.words,
                gridSize: size,
                anchor: nil,
                foundWords: Set(legacy.foundWords.map { $0.uppercased() }),
                solvedPositions: [],
                puzzleIndex: 0,
                isHelpVisible: false,
                feedback: nil,
                pendingWord: nil,
                pendingSolvedPositions: [],
                nextHintWord: nil,
                nextHintExpiresAt: nil
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
        guard !grid.isEmpty else { return nil }
        let size = grid.count
        guard grid.allSatisfy({ $0.count == size }) else { return nil }
        let safeWords = words
            .map { $0.uppercased() }
            .filter { !$0.isEmpty && $0.count <= size }
        return WordSearchPuzzle(
            grid: grid.map { row in row.map { $0.uppercased() } },
            words: safeWords
        )
    }
}

@available(iOS 17.0, *)
enum WordSearchLogic {
    private static let hintDuration: TimeInterval? = nil

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
            let normalizedWord = matchedWord.uppercased()
            next.foundWords.insert(normalizedWord)
            next.solvedPositions.formUnion(linePath)
            next.feedback = WordSearchFeedback(
                kind: .correct,
                positions: linePath,
                expiresAt: now.addingTimeInterval(0.4)
            )
            next.pendingWord = nil
            next.pendingSolvedPositions.removeAll()
            applyNextHint(into: &next, now: now)
        } else {
            let preview = linePath ?? [anchor, tapped]
            next.feedback = WordSearchFeedback(
                kind: .incorrect,
                positions: preview,
                expiresAt: now.addingTimeInterval(0.4)
            )
            next.pendingWord = nil
            next.pendingSolvedPositions.removeAll()
        }

        next.anchor = nil
        return next
    }

    private static func applyNextHint(into state: inout WordSearchState, now: Date) {
        guard !state.isCompleted else {
            state.nextHintWord = nil
            state.nextHintExpiresAt = nil
            return
        }

        if let nextWord = nextUnfoundWord(in: state) {
            state.nextHintWord = nextWord
            if let hintDuration {
                state.nextHintExpiresAt = now.addingTimeInterval(hintDuration)
            } else {
                state.nextHintExpiresAt = nil
            }
        } else {
            state.nextHintWord = nil
            state.nextHintExpiresAt = nil
        }
    }

    private static func nextUnfoundWord(in state: WordSearchState) -> String? {
        let found = Set(state.foundWords.map { $0.uppercased() })
        for word in state.words {
            let normalized = word.uppercased()
            if !found.contains(normalized) {
                return normalized
            }
        }
        return nil
    }

    static func resolveExpiredFeedback(state: WordSearchState, now: Date) -> WordSearchState {
        var next = state

        if let feedback = state.feedback, now >= feedback.expiresAt {
            // Backward compatibility for states saved before immediate-commit logic.
            if feedback.kind == .correct, let pendingWord = next.pendingWord?.uppercased() {
                next.foundWords.insert(pendingWord)
                next.solvedPositions.formUnion(next.pendingSolvedPositions)
            }
            next.feedback = nil
            next.pendingWord = nil
            next.pendingSolvedPositions.removeAll()
        }

        if let hintExpiry = state.nextHintExpiresAt, now >= hintExpiry {
            next.nextHintWord = nil
            next.nextHintExpiresAt = nil
        }

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
