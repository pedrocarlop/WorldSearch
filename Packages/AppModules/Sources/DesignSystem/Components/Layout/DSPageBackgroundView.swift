import SwiftUI

public struct DSPageBackgroundView: View {
    private let gridSpacing: CGFloat
    private let gridOpacity: Double

    public init(
        gridSpacing: CGFloat = SpacingTokens.xxxl,
        gridOpacity: Double = 0.08
    ) {
        self.gridSpacing = gridSpacing
        self.gridOpacity = gridOpacity
    }

    public var body: some View {
        ZStack {
            ThemeGradients.paperBackground
                .ignoresSafeArea()

            DSGridBackgroundView(spacing: gridSpacing, opacity: gridOpacity)
                .ignoresSafeArea()
        }
    }
}
