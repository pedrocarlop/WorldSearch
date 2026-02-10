import SwiftUI

public struct DSCard<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .padding(SpacingTokens.lg)
            .background(
                RoundedRectangle(cornerRadius: RadiusTokens.cardRadius, style: .continuous)
                    .fill(ColorTokens.surfacePrimary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: RadiusTokens.cardRadius, style: .continuous)
                    .stroke(ColorTokens.borderSoft, lineWidth: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: RadiusTokens.cardRadius, style: .continuous)
                    .stroke(ColorTokens.cardHighlightStroke, lineWidth: 0.8)
            )
            .shadow(color: ShadowTokens.cardAmbient.color, radius: ShadowTokens.cardAmbient.radius, x: 0, y: ShadowTokens.cardAmbient.y)
            .shadow(color: ShadowTokens.cardDrop.color, radius: ShadowTokens.cardDrop.radius, x: 0, y: ShadowTokens.cardDrop.y)
    }
}
