import Foundation
import XCTest
@testable import Core

final class SpanishLocalizationNormalizationTests: XCTestCase {
    func testNormalizationPreservesEnye() {
        XCTAssertEqual(WordSearchNormalization.normalizedWord("año"), "AÑO")
        XCTAssertEqual(WordSearchNormalization.normalizedWord("mañána"), "MAÑANA")
    }

    func testSpanishPuzzleGridContainsEnye() {
        let puzzle = PuzzleFactory.puzzle(
            for: DayKey(offset: 0),
            gridSize: 9,
            locale: Locale(identifier: "es")
        )

        XCTAssertTrue(puzzle.grid.letters.flatMap(\.self).contains("Ñ"))
    }

    func testEnglishPuzzleGridDoesNotContainEnye() {
        let puzzle = PuzzleFactory.puzzle(
            for: DayKey(offset: 0),
            gridSize: 9,
            locale: Locale(identifier: "en")
        )

        XCTAssertFalse(puzzle.grid.letters.flatMap(\.self).contains("Ñ"))
    }
}
