import Foundation
import Core

enum AppStrings {
    static var homeTitle: String {
        localized("app.home.title", default: "Sopa diaria")
    }

    static func completedCounterAccessibility(_ value: Int) -> String {
        String(
            format: localized("app.counter.completed.accessibility", default: "Retos completados %d"),
            locale: AppLocalization.currentLocale,
            value
        )
    }

    static var completedCounterHint: String {
        localized("app.counter.completed.hint", default: "Pulsa para saber que mide este contador")
    }

    static func streakCounterAccessibility(_ value: Int) -> String {
        String(
            format: localized("app.counter.streak.accessibility", default: "Racha actual %d"),
            locale: AppLocalization.currentLocale,
            value
        )
    }

    static var streakCounterHint: String {
        localized("app.counter.streak.hint", default: "Pulsa para saber que mide este contador")
    }

    static var openSettingsAccessibility: String {
        localized("app.settings.open_accessibility", default: "Abrir ajustes")
    }

    private static func localized(_ key: String, default value: String) -> String {
        AppLocalization.localized(key, default: value, bundle: .main)
    }
}
