/*
 BEGINNER NOTES (AUTO):
 - Archivo: WorldCrush/Localization/AppStrings.swift
 - Rol principal: Centraliza textos traducibles y acceso seguro a mensajes de UI.
 - Flujo simplificado: Entrada: clave de texto e idioma activo. | Proceso: resolver recurso localizado. | Salida: string final para mostrar en UI.
 - Tipos clave en este archivo: AppStrings
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
import Core

enum AppStrings {
    static let homeTitle = "WordCrush"

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

    static var widgetOnboardingBannerTitle: String {
        localized("app.widget.banner.title", default: "Add the WordCrush widget")
    }

    static var widgetOnboardingBannerDescription: String {
        localized(
            "app.widget.banner.description",
            default: "Play today in one tap from your iPhone Home Screen."
        )
    }

    static var widgetOnboardingBannerAccessibilityLabel: String {
        localized(
            "app.widget.banner.accessibility_label",
            default: "Open widget setup guide"
        )
    }

    static var widgetOnboardingBannerAccessibilityHint: String {
        localized(
            "app.widget.banner.accessibility_hint",
            default: "Opens the steps to add the WordCrush Home Screen widget"
        )
    }

    static var widgetOnboardingBannerCloseAccessibility: String {
        localized(
            "app.widget.banner.close_accessibility",
            default: "Dismiss widget setup banner"
        )
    }

    static var widgetOnboardingGuideTitle: String {
        localized("app.widget.guide.title", default: "Add Home Screen widget")
    }

    static var widgetOnboardingGuideDescription: String {
        localized(
            "app.widget.guide.description",
            default: "Follow these steps to add the WordCrush widget on your iPhone."
        )
    }

    static var widgetOnboardingGuideStep1: String {
        localized(
            "app.widget.guide.step_1",
            default: "Touch and hold an empty area on your Home Screen until apps start to jiggle."
        )
    }

    static var widgetOnboardingGuideStep2: String {
        localized(
            "app.widget.guide.step_2",
            default: "Tap Edit in the top-left corner, then tap Add Widget."
        )
    }

    static var widgetOnboardingGuideStep3: String {
        localized(
            "app.widget.guide.step_3",
            default: "Search for WordCrush and select the widget."
        )
    }

    static var widgetOnboardingGuideStep4: String {
        localized(
            "app.widget.guide.step_4",
            default: "Choose your preferred widget size and tap Add Widget."
        )
    }

    static var widgetOnboardingGuideStep5: String {
        localized(
            "app.widget.guide.step_5",
            default: "Tap Done to finish. Open the widget anytime to play the daily puzzle."
        )
    }

    static var widgetOnboardingGuideFooter: String {
        localized(
            "app.widget.guide.footer",
            default: "Tip: Place it near your dock so it is always easy to reach."
        )
    }

    static var widgetOnboardingGuideDone: String {
        localized("app.widget.guide.done", default: "Done")
    }

    private static func localized(_ key: String, default value: String) -> String {
        AppLocalization.localized(key, default: value, bundle: .main)
    }
}
