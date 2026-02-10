import SwiftUI

public struct DSGridBackgroundView: View {
    private let spacing: CGFloat
    private let lineWidth: CGFloat
    private let opacity: Double

    public init(
        spacing: CGFloat = SpacingTokens.lg,
        lineWidth: CGFloat = 0.8,
        opacity: Double = 0.2
    ) {
        self.spacing = spacing
        self.lineWidth = lineWidth
        self.opacity = opacity
    }

    public var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                var path = Path()

                var x: CGFloat = 0
                while x <= size.width {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                    x += spacing
                }

                var y: CGFloat = 0
                while y <= size.height {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                    y += spacing
                }

                context.stroke(
                    path,
                    with: .color(ColorTokens.gridLine.opacity(opacity)),
                    lineWidth: lineWidth
                )
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .allowsHitTesting(false)
    }
}
