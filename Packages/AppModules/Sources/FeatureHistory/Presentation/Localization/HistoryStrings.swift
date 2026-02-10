import Foundation
import Core

public enum HistoryStrings {
    public static var completedPuzzlesTitle: String {
        localized("history.completed.title", default: "Puzzles completados")
    }

    public static var streakTitle: String {
        localized("history.streak.title", default: "Racha actual")
    }

    public static var completedPuzzlesExplanation: String {
        localized(
            "history.completed.explanation",
            default: "Muestra cuantos retos diarios has terminado en total desde que instalaste la app."
        )
    }

    public static var streakExplanation: String {
        localized(
            "history.streak.explanation",
            default: "Cuenta los dias seguidos en los que completas el reto del dia actual. Si un dia no lo completas, la racha se reinicia."
        )
    }

    private static func localized(_ key: String, default value: String) -> String {
        AppLocalization.localized(key, default: value, bundle: .module)
    }
}
