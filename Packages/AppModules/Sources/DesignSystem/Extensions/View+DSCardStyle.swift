import SwiftUI

public extension View {
    func dsCardStyle() -> some View {
        padding(SpacingTokens.md)
            .background(
                RoundedRectangle(cornerRadius: RadiusTokens.cardRadius, style: .continuous)
                    .fill(ColorTokens.surfacePrimary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: RadiusTokens.cardRadius, style: .continuous)
                    .stroke(ColorTokens.borderSoft, lineWidth: 1)
            )
    }
}
