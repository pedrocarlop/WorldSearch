import SwiftUI

public struct DSButton: View {
    public enum Style {
        case primary
        case secondary
        case destructive
    }

    private let title: String
    private let style: Style
    private let action: () -> Void

    public init(_ title: String, style: Style = .primary, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(TypographyTokens.bodyStrong)
                .foregroundStyle(foregroundColor)
                .padding(.horizontal, SpacingTokens.md)
                .padding(.vertical, SpacingTokens.sm)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(
                    RoundedRectangle(cornerRadius: RadiusTokens.buttonRadius, style: .continuous)
                        .fill(backgroundStyle)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: RadiusTokens.buttonRadius, style: .continuous)
                        .stroke(borderColor, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private var foregroundColor: Color {
        switch style {
        case .primary, .destructive:
            return ColorTokens.surfacePaper
        case .secondary:
            return ColorTokens.inkPrimary
        }
    }

    private var backgroundStyle: AnyShapeStyle {
        switch style {
        case .primary:
            return AnyShapeStyle(ThemeGradients.brushWarm)
        case .secondary:
            return AnyShapeStyle(ColorTokens.surfacePaper)
        case .destructive:
            return AnyShapeStyle(ColorTokens.error)
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary:
            return ColorTokens.borderSoft.opacity(0.35)
        case .secondary:
            return ColorTokens.borderSoft
        case .destructive:
            return ColorTokens.error.opacity(0.5)
        }
    }
}
