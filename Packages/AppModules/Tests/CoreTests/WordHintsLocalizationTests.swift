import Foundation
import XCTest
@testable import Core

final class WordHintsLocalizationTests: XCTestCase {
    func testDefinitionIsAvailableForKnownWord() {
        let definition = WordHintsService.definition(for: "ARBOL")
        XCTAssertNotNil(definition)
        XCTAssertFalse(definition?.isEmpty ?? true)
    }

    func testDefinitionIsNilForUnknownWord() {
        XCTAssertNil(WordHintsService.definition(for: "PALABRAINEXISTENTE"))
    }

    func testDisplayTextProvidesFallbackForMissingDefinition() {
        let text = WordHintsService.displayText(for: "PALABRAINEXISTENTE", mode: .definition)
        XCTAssertFalse(text.isEmpty)
    }

    func testDefinitionIsAvailableForLocalizedEnglishWord() {
        let definition = WordHintsService.definition(for: "TREE")
        XCTAssertNotNil(definition)
        XCTAssertFalse(definition?.isEmpty ?? true)
    }

    func testPuzzleWordsLocalizeToEnglishAndKeepCanonicalMapping() {
        let spanishPuzzle = PuzzleFactory.puzzle(
            for: DayKey(offset: 0),
            gridSize: 9,
            locale: Locale(identifier: "es")
        )
        let englishPuzzle = PuzzleFactory.puzzle(
            for: DayKey(offset: 0),
            gridSize: 9,
            locale: Locale(identifier: "en")
        )

        let spanishWords = spanishPuzzle.words.map(\.text)
        let englishWords = englishPuzzle.words.map(\.text)
        let canonicalEnglishWords = englishWords.compactMap(PuzzleFactory.canonicalWord(for:))

        XCTAssertEqual(englishWords.count, spanishWords.count)
        XCTAssertEqual(Set(canonicalEnglishWords), Set(spanishWords))
        XCTAssertNotEqual(Set(englishWords), Set(spanishWords))

        for localizedWord in englishWords {
            XCTAssertNotNil(WordHintsService.definition(for: localizedWord))
        }
    }

    func testPuzzleWordsLocalizeToFrenchAndKeepCanonicalMapping() {
        let spanishPuzzle = PuzzleFactory.puzzle(
            for: DayKey(offset: 0),
            gridSize: 9,
            locale: Locale(identifier: "es")
        )
        let frenchPuzzle = PuzzleFactory.puzzle(
            for: DayKey(offset: 0),
            gridSize: 9,
            locale: Locale(identifier: "fr")
        )

        let spanishWords = spanishPuzzle.words.map(\.text)
        let frenchWords = frenchPuzzle.words.map(\.text)
        let canonicalFrenchWords = frenchWords.compactMap(PuzzleFactory.canonicalWord(for:))

        XCTAssertEqual(frenchWords.count, spanishWords.count)
        XCTAssertEqual(Set(canonicalFrenchWords), Set(spanishWords))
        XCTAssertNotEqual(Set(frenchWords), Set(spanishWords))
    }

    func testPuzzleWordsLocalizeToPortugueseAndKeepCanonicalMapping() {
        let spanishPuzzle = PuzzleFactory.puzzle(
            for: DayKey(offset: 0),
            gridSize: 9,
            locale: Locale(identifier: "es")
        )
        let portuguesePuzzle = PuzzleFactory.puzzle(
            for: DayKey(offset: 0),
            gridSize: 9,
            locale: Locale(identifier: "pt")
        )

        let spanishWords = spanishPuzzle.words.map(\.text)
        let portugueseWords = portuguesePuzzle.words.map(\.text)
        let canonicalPortugueseWords = portugueseWords.compactMap(PuzzleFactory.canonicalWord(for:))

        XCTAssertEqual(portugueseWords.count, spanishWords.count)
        XCTAssertEqual(Set(canonicalPortugueseWords), Set(spanishWords))
        XCTAssertNotEqual(Set(portugueseWords), Set(spanishWords))
    }
}
