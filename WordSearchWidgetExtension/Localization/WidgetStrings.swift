import Foundation
import SwiftUI
import Core

enum WidgetStrings {
    static var nextLabel: String {
        localized("widget.next.label", default: "Siguiente:")
    }

    static var understoodAction: String {
        localized("widget.action.understood", default: "Entendido")
    }

    static var completedTitle: String {
        localized("widget.completed.title", default: "Completado")
    }

    static func completedMessage(nextRefreshTimeLabel: String) -> String {
        String(
            format: localized("widget.completed.message", default: "Manana a las %@ se cargara otra sopa de letras."),
            locale: AppLocalization.currentLocale,
            nextRefreshTimeLabel
        )
    }

    static var completedHint: String {
        localized("widget.completed.hint", default: "Cada dia se anade un nuevo juego.")
    }

    static var configurationDisplayName: String {
        localized("widget.configuration.display_name", default: "Sopa de letras")
    }

    static var configurationDescription: String {
        localized("widget.configuration.description", default: "Selecciona una letra inicial y una final para cada palabra.")
    }

    static var intentSelectLetters: LocalizedStringResource {
        LocalizedStringResource("widget.intent.select_letters")
    }

    static var intentRow: LocalizedStringResource {
        LocalizedStringResource("widget.intent.row")
    }

    static var intentColumn: LocalizedStringResource {
        LocalizedStringResource("widget.intent.column")
    }

    static var intentShowHelp: LocalizedStringResource {
        LocalizedStringResource("widget.intent.show_help")
    }

    static var intentHideHint: LocalizedStringResource {
        LocalizedStringResource("widget.intent.hide_hint")
    }

    private static func localized(_ key: String, default value: String) -> String {
        AppLocalization.localized(key, default: value, bundle: .main)
    }
}
