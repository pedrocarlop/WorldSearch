/*
 BEGINNER NOTES (AUTO):
 - Archivo: Packages/AppModules/Sources/Core/Domain/Services/PuzzleFactory.swift
 - Rol principal: Implementa reglas de negocio puras del dominio (logica principal del producto).
 - Flujo simplificado: Entrada: entidades/parametros de negocio. | Proceso: aplicar reglas y restricciones del dominio. | Salida: decision o resultado de negocio.
 - Tipos clave en este archivo: PuzzleFactory,WordSearchGenerator
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

import Foundation

public enum PuzzleFactory {
    private static let minimumPuzzleCount = 365
    private static let wordsPerTheme = 30
    private static let fallbackTheme = ["SOL", "MAR", "RIO", "LUNA", "FLOR", "ROCA"]

    private static let canonicalWordBank: [String] = PuzzleWordBankData.pairs.map(\.spanish)

    private static let canonicalThemes: [[String]] = makeCanonicalThemes()
    private static let randomizedPuzzleOrder: [Int] = makeRandomizedPuzzleOrder(
        count: max(canonicalThemes.count, 1)
    )

    private static let englishTranslations: [String: String] = {
        var map: [String: String] = [:]
        map.reserveCapacity(PuzzleWordBankData.pairs.count)
        for pair in PuzzleWordBankData.pairs {
            map[pair.spanish] = pair.english
        }
        return map
    }()

    private static let spanishThemes: [[String]] = canonicalThemes.map { theme in
        theme.map(WordSearchNormalization.normalizedWord)
    }

    private static let englishThemes: [[String]] = localizedThemes(using: englishTranslations)

    private static func localizedThemes(using translations: [String: String]) -> [[String]] {
        canonicalThemes.map { theme in
            theme.map { rawWord in
                let canonical = WordSearchNormalization.normalizedWord(rawWord)
                let translated = translations[canonical] ?? canonical
                return WordSearchNormalization.normalizedWord(translated)
            }
        }
    }

    private static func makeCanonicalThemes() -> [[String]] {
        var seenWords: Set<String> = []
        let uniqueWordBank = canonicalWordBank
            .map(WordSearchNormalization.normalizedWord)
            .filter { seenWords.insert($0).inserted }

        guard !uniqueWordBank.isEmpty else {
            return Array(repeating: fallbackTheme, count: minimumPuzzleCount)
        }

        let targetThemeCount = max(minimumPuzzleCount, 1)
        let wordsInTheme = min(wordsPerTheme, uniqueWordBank.count)
        let maximumAttempts = max(targetThemeCount * 20, targetThemeCount)

        var themes: [[String]] = []
        themes.reserveCapacity(targetThemeCount)
        var signatures: Set<String> = []
        var attempt = 0

        while themes.count < targetThemeCount && attempt < maximumAttempts {
            let seed = stableSeed(dayOffset: attempt + 1, gridSize: uniqueWordBank.count) ^ 0x51A7EA5ED
            let candidate = shuffledWords(
                from: uniqueWordBank,
                seed: seed,
                take: wordsInTheme
            )
            let signature = candidate.joined(separator: "|")
            if signatures.insert(signature).inserted {
                themes.append(candidate)
            }
            attempt += 1
        }

        var rng = WordSearchGenerator.SeededGenerator(seed: 0x0BADC0DE1234ABCD)
        while themes.count < targetThemeCount {
            let start = rng.int(upperBound: uniqueWordBank.count)
            let step = max(1, rng.int(upperBound: uniqueWordBank.count))
            var candidate: [String] = []
            candidate.reserveCapacity(wordsInTheme)
            var used: Set<String> = []
            var index = start

            while candidate.count < wordsInTheme && used.count < uniqueWordBank.count {
                let word = uniqueWordBank[index % uniqueWordBank.count]
                if used.insert(word).inserted {
                    candidate.append(word)
                }
                index += step
            }

            if candidate.count < wordsInTheme {
                for word in uniqueWordBank where candidate.count < wordsInTheme {
                    if used.insert(word).inserted {
                        candidate.append(word)
                    }
                }
            }

            let signature = candidate.joined(separator: "|")
            if signatures.insert(signature).inserted {
                themes.append(candidate)
            }
        }

        return themes
    }

    private static func makeRandomizedPuzzleOrder(count: Int) -> [Int] {
        guard count > 1 else { return [0] }
        var order = Array(0..<count)
        var rng = WordSearchGenerator.SeededGenerator(seed: 0xD1A1222365ABCDEF)

        for index in stride(from: order.count - 1, through: 1, by: -1) {
            let swapAt = rng.int(upperBound: index + 1)
            if swapAt != index {
                order.swapAt(index, swapAt)
            }
        }

        return order
    }

    private static func shuffledWords(from words: [String], seed: UInt64, take count: Int) -> [String] {
        guard !words.isEmpty else { return fallbackTheme }

        var shuffled = words
        var rng = WordSearchGenerator.SeededGenerator(seed: seed)
        for index in stride(from: shuffled.count - 1, through: 1, by: -1) {
            let swapAt = rng.int(upperBound: index + 1)
            if swapAt != index {
                shuffled.swapAt(index, swapAt)
            }
        }

        return Array(shuffled.prefix(max(1, count)))
    }

    private static func randomizedPuzzleIndex(for normalizedIndex: Int) -> Int {
        guard !randomizedPuzzleOrder.isEmpty else { return 0 }
        let index = normalizedPuzzleIndex(normalizedIndex)
        return randomizedPuzzleOrder[index]
    }

    private static let canonicalByLocalizedWord: [String: String] = {
        var map: [String: String] = [:]
        for theme in canonicalThemes {
            for rawWord in theme {
                let canonical = WordSearchNormalization.normalizedWord(rawWord)
                map[canonical] = canonical
            }
        }

        for translations in [englishTranslations] {
            for (canonical, translated) in translations {
                map[WordSearchNormalization.normalizedWord(translated)] = canonical
            }
        }
        return map
    }()

    public static func canonicalWord(for localizedWord: String) -> String? {
        let normalized = WordSearchNormalization.normalizedWord(localizedWord)
        return canonicalByLocalizedWord[normalized]
    }

    public static func puzzleNumber(for dayKey: DayKey) -> Int {
        let normalizedIndex = normalizedPuzzleIndex(dayKey.offset)
        let randomizedIndex = randomizedPuzzleIndex(for: normalizedIndex)
        return randomizedIndex + 1
    }

    public static func normalizedPuzzleIndex(_ offset: Int) -> Int {
        let count = max(canonicalThemes.count, 1)
        let value = offset % count
        return value >= 0 ? value : value + count
    }

    public static func puzzle(for dayKey: DayKey, gridSize: Int, locale: Locale? = nil) -> Puzzle {
        let normalizedIndex = normalizedPuzzleIndex(dayKey.offset)
        let randomizedIndex = randomizedPuzzleIndex(for: normalizedIndex)
        let clampedGridSize = clampGridSize(gridSize)
        let resolvedLocale = locale ?? AppLocalization.currentLocale
        let language = AppLanguage.resolved(from: resolvedLocale)
        let wordsPool = themedWords(for: randomizedIndex, language: language)
        let seed = stableSeed(dayOffset: dayKey.offset, gridSize: clampedGridSize)

        let selectedWords = selectWords(from: wordsPool, gridSize: clampedGridSize, seed: seed)
        let generated = WordSearchGenerator.generate(
            gridSize: clampedGridSize,
            words: selectedWords,
            seed: seed,
            language: language
        )

        return Puzzle(
            number: randomizedIndex + 1,
            dayKey: dayKey,
            grid: PuzzleGrid(letters: generated.grid),
            words: generated.words.map(Word.init(text:))
        )
    }

    public static func clampGridSize(_ value: Int) -> Int {
        min(max(value, WordSearchConfig.minGridSize), WordSearchConfig.maxGridSize)
    }

    private static func stableSeed(dayOffset: Int, gridSize: Int) -> UInt64 {
        let a = UInt64(bitPattern: Int64(dayOffset))
        let b = UInt64(gridSize) << 32
        return (a &* 0x9E3779B185EBCA87) ^ b ^ 0xC0DEC0FFEE12345F
    }

    private static func targetWordCount(for gridSize: Int) -> Int {
        let size = clampGridSize(gridSize)
        return min(10, max(5, 5 + (size - WordSearchConfig.minGridSize)))
    }

    private static func themedWords(for index: Int, language: AppLanguage) -> [String] {
        switch language {
        case .spanish:
            return spanishThemes[index]
        case .english:
            return englishThemes[index]
        }
    }

    private static func selectWords(from pool: [String], gridSize: Int, seed: UInt64) -> [String] {
        var filtered = pool
            .map(WordSearchNormalization.normalizedWord)
            .filter { $0.count >= 3 && $0.count <= gridSize }

        if filtered.isEmpty {
            filtered = fallbackTheme
        }

        var rng = WordSearchGenerator.SeededGenerator(seed: seed ^ 0xA11CE5EED)
        for index in stride(from: filtered.count - 1, through: 1, by: -1) {
            let swapAt = rng.int(upperBound: index + 1)
            if swapAt != index {
                filtered.swapAt(index, swapAt)
            }
        }

        let targetCount = min(filtered.count, targetWordCount(for: gridSize))
        return Array(filtered.prefix(targetCount))
    }
}

public enum WordSearchGenerator {
    private static let directions: [(Int, Int)] = [
        (0, 1), (1, 0), (1, 1), (1, -1),
        (0, -1), (-1, 0), (-1, -1), (-1, 1)
    ]
    private static let englishAlphabet: [String] = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ").map { String($0) }
    private static let spanishAlphabet: [String] = Array("ABCDEFGHIJKLMNÑOPQRSTUVWXYZ").map { String($0) }
    private static let enye = "Ñ"

    public struct SeededGenerator {
        private var state: UInt64

        public init(seed: UInt64) {
            state = seed == 0 ? 0x1234ABCD5678EF90 : seed
        }

        public mutating func next() -> UInt64 {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return state
        }

        public mutating func int(upperBound: Int) -> Int {
            guard upperBound > 0 else { return 0 }
            return Int(next() % UInt64(upperBound))
        }
    }

    public struct GeneratedPuzzle {
        public let grid: [[String]]
        public let words: [String]

        public init(grid: [[String]], words: [String]) {
            self.grid = grid
            self.words = words
        }
    }

    public static func generate(
        gridSize: Int,
        words: [String],
        seed: UInt64,
        language: AppLanguage = .english
    ) -> GeneratedPuzzle {
        let size = PuzzleFactory.clampGridSize(gridSize)
        let sortedWords = words
            .map(WordSearchNormalization.normalizedWord)
            .filter { !$0.isEmpty && $0.count <= size }
            .sorted { $0.count > $1.count }

        var fallback = makePuzzle(size: size, words: sortedWords, seed: seed, reduction: 0, language: language)
        if fallback.words.count >= 4 {
            return fallback
        }

        for reduction in [2, 4, 6] {
            let reduced = Array(sortedWords.prefix(max(4, sortedWords.count - reduction)))
            let attempt = makePuzzle(
                size: size,
                words: reduced,
                seed: seed,
                reduction: reduction,
                language: language
            )
            if attempt.words.count > fallback.words.count {
                fallback = attempt
            }
            if attempt.words.count >= max(4, reduced.count - 1) {
                return attempt
            }
        }

        return fallback
    }

    private static func makePuzzle(
        size: Int,
        words: [String],
        seed: UInt64,
        reduction: Int,
        language: AppLanguage
    ) -> GeneratedPuzzle {
        var rng = SeededGenerator(seed: seed ^ UInt64(reduction) ^ 0xFEEDBEEF15)
        var board = Array(repeating: Array(repeating: "", count: size), count: size)
        var placedWords: [String] = []
        let alphabet = alphabet(for: language)
        let reservedEnyePosition = language == .spanish
            ? GridPosition(row: rng.int(upperBound: size), col: rng.int(upperBound: size))
            : nil

        for word in words {
            if place(
                word: word,
                on: &board,
                size: size,
                reservedPosition: reservedEnyePosition,
                rng: &rng
            ) {
                placedWords.append(word)
            }
        }

        var fillerPositions: [GridPosition] = []
        for row in 0..<size {
            for col in 0..<size where board[row][col].isEmpty {
                fillerPositions.append(GridPosition(row: row, col: col))
                board[row][col] = alphabet[rng.int(upperBound: alphabet.count)]
            }
        }

        if language == .spanish {
            injectEnyeIfMissing(
                on: &board,
                fillerPositions: fillerPositions,
                reservedPosition: reservedEnyePosition,
                rng: &rng
            )
        }

        return GeneratedPuzzle(grid: board, words: placedWords)
    }

    private static func place(
        word: String,
        on board: inout [[String]],
        size: Int,
        reservedPosition: GridPosition?,
        rng: inout SeededGenerator
    ) -> Bool {
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
                if let reservedPosition,
                   reservedPosition.row == r,
                   reservedPosition.col == c {
                    canPlace = false
                    break
                }
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

    private static func alphabet(for language: AppLanguage) -> [String] {
        switch language {
        case .spanish:
            return spanishAlphabet
        case .english:
            return englishAlphabet
        }
    }

    private static func injectEnyeIfMissing(
        on board: inout [[String]],
        fillerPositions: [GridPosition],
        reservedPosition: GridPosition?,
        rng: inout SeededGenerator
    ) {
        guard !board.contains(where: { $0.contains(enye) }) else { return }

        if !fillerPositions.isEmpty {
            let position = fillerPositions[rng.int(upperBound: fillerPositions.count)]
            board[position.row][position.col] = enye
            return
        }

        if let reservedPosition {
            board[reservedPosition.row][reservedPosition.col] = enye
        }
    }
}
