import SwiftUI

public struct DSChip: View {
    private let text: String
    private let isSelected: Bool

    public init(text: String, isSelected: Bool = false) {
        self.text = text
        self.isSelected = isSelected
    }

    public var body: some View {
        Text(text)
            .font(TypographyTokens.caption)
            .foregroundStyle(ColorTokens.inkPrimary)
            .padding(.horizontal, SpacingTokens.sm)
            .padding(.vertical, SpacingTokens.xs)
            .background(
                RoundedRectangle(cornerRadius: RadiusTokens.chipRadius, style: .continuous)
                    .fill(fillStyle)
            )
            .overlay(
                RoundedRectangle(cornerRadius: RadiusTokens.chipRadius, style: .continuous)
                    .stroke(ColorTokens.chipBorder, lineWidth: 1)
            )
    }

    private var fillStyle: AnyShapeStyle {
        if isSelected {
            return AnyShapeStyle(ThemeGradients.brushWarm.opacity(0.2))
        }
        return AnyShapeStyle(ColorTokens.chipNeutralFill)
    }
}
