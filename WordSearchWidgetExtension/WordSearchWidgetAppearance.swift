import SwiftUI
import DesignSystem
import Core

@available(iOS 17.0, *)
enum WordSearchWidgetColorTokens {
    static func widgetBackground(for colorScheme: ColorScheme) -> LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                colors: [
                    ColorTokens.surfaceSecondary,
                    ColorTokens.surfaceTertiary
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        return LinearGradient(
            colors: [
                ColorTokens.backgroundPrimary,
                ColorTokens.surfaceSecondary
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func hintBlockingOverlay(isDark: Bool) -> Color {
        ColorTokens.surfaceSecondary.opacity(isDark ? 0.55 : 0.35)
    }

    static let hintCTA = ColorTokens.accentPrimary
    static let hintPanelStroke = ColorTokens.borderDefault
    static let completionOverlay = ColorTokens.surfaceSecondary.opacity(0.45)
}

@available(iOS 17.0, *)
enum WordSearchWidgetTypographyTokens {
    static let body = TypographyTokens.body
    static let overlayTitle = TypographyTokens.screenTitle.weight(.bold)
    static let overlayBody = TypographyTokens.caption
    static let hintTitle = TypographyTokens.caption.weight(.semibold)
    static let hintBody = TypographyTokens.bodyStrong
    static let hintCTA = TypographyTokens.footnote.weight(.semibold)
}

@available(iOS 17.0, *)
enum WordSearchWidgetAppearanceMode: String {
    case system
    case light
    case dark

    static func current() -> WordSearchWidgetAppearanceMode {
        switch WordSearchWidgetContainer.shared.settings().appearanceMode {
        case .system:
            return .system
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
