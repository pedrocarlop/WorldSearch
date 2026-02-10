import Foundation
import Core

public enum DailyPuzzleStrings {
    public static var completed: String {
        localized("daily.completed", default: "Completado")
    }

    public static func challengeProgress(found: Int, total: Int) -> String {
        String(
            format: localized("daily.challenge.progress", default: "%d de %d completadas"),
            locale: AppLocalization.currentLocale,
            found,
            total
        )
    }

    public static func challengeAvailableIn(hours: Int) -> String {
        String(
            format: localized("daily.challenge.available_in_hours", default: "Disponible en %dh"),
            locale: AppLocalization.currentLocale,
            hours
        )
    }

    public static var challengeAvailableSoon: String {
        localized("daily.challenge.available_soon", default: "Disponible pronto")
    }

    public static func challengeAccessibilityLabel(number: Int, status: String) -> String {
        String(
            format: localized("daily.challenge.accessibility", default: "Reto %d, %@"),
            locale: AppLocalization.currentLocale,
            number,
            status
        )
    }

    public static var close: String {
        localized("daily.action.close", default: "Cerrar")
    }

    public static var resetChallenge: String {
        localized("daily.action.reset", default: "Reiniciar reto")
    }

    public static var resetAlertTitle: String {
        localized("daily.reset_alert.title", default: "Reiniciar reto")
    }

    public static var resetAlertCancel: String {
        localized("daily.reset_alert.cancel", default: "Cancelar")
    }

    public static var resetAlertConfirm: String {
        localized("daily.reset_alert.confirm", default: "Reiniciar")
    }

    public static var resetAlertMessage: String {
        localized("daily.reset_alert.message", default: "Se borrara el progreso de este dia.")
    }

    public static func streakLabel(_ value: Int) -> String {
        String(
            format: localized("daily.streak_label", default: "Racha %d"),
            locale: AppLocalization.currentLocale,
            value
        )
    }

    public static func completionAccessibility(_ streakLabel: String?) -> String {
        if let streakLabel {
            return String(
                format: localized("daily.completion.accessibility_with_streak", default: "Completado. %@"),
                locale: AppLocalization.currentLocale,
                streakLabel
            )
        }
        return localized("daily.completion.accessibility", default: "Completado")
    }

    public static func hoursShort(_ value: Int) -> String {
        String(
            format: localized("daily.hours_short", default: "%dh"),
            locale: AppLocalization.currentLocale,
            value
        )
    }

    private static func localized(_ key: String, default value: String) -> String {
        AppLocalization.localized(key, default: value, bundle: .module)
    }
}
