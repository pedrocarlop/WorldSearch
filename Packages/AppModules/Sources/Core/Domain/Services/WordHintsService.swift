import Foundation

public enum WordHintsService {
    public static func displayText(for word: String, mode: WordHintMode) -> String {
        switch mode {
        case .word:
            return WordSearchNormalization.normalizedWord(word)
        case .definition:
            return definition(for: word) ?? missingDefinition
        }
    }

    public static func definition(for word: String) -> String? {
        let normalized = WordSearchNormalization.normalizedWord(word)
        let canonical = PuzzleFactory.canonicalWord(for: normalized) ?? normalized
        let key = "word_hint.\(canonical)"
        let value = localized(key, default: key)
        return value == key ? nil : value
    }

    private static var missingDefinition: String {
        localized("word_hint.missing", default: "Sin definición")
    }

    private static func localized(_ key: String, default value: String) -> String {
        AppLocalization.localized(key, default: value, bundle: .module)
    }
}
