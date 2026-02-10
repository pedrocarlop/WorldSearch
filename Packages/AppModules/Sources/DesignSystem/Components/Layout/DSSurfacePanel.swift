import SwiftUI

public struct DSSurfacePanel<Content: View>: View {
    private let cornerRadius: CGFloat
    private let lineWidth: CGFloat
    private let reduceTransparency: Bool
    private let content: Content

    public init(
        cornerRadius: CGFloat = RadiusTokens.overlayRadius,
        lineWidth: CGFloat = 1,
        reduceTransparency: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.lineWidth = lineWidth
        self.reduceTransparency = reduceTransparency
        self.content = content()
    }

    public var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        reduceTransparency
                            ? AnyShapeStyle(ColorTokens.surfaceSecondary)
                            : AnyShapeStyle(.ultraThinMaterial)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(ColorTokens.textPrimary.opacity(0.24), lineWidth: lineWidth)
            )
    }
}
