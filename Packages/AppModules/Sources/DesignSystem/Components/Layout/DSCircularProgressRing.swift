import SwiftUI

public struct DSCircularProgressRing: View {
    public let progress: Double
    public let lineWidth: CGFloat
    public let size: CGFloat

    public init(
        progress: Double,
        lineWidth: CGFloat = 2,
        size: CGFloat = 14
    ) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.size = size
    }

    public var body: some View {
        let clamped = min(max(progress, 0), 1)

        ZStack {
            Circle()
                .stroke(ColorTokens.gridLine.opacity(0.75), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: clamped)
                .stroke(
                    ThemeGradients.brushWarm,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
        .frame(width: size, height: size)
        .animation(.easeInOut(duration: MotionTokens.fastDuration), value: clamped)
    }
}
