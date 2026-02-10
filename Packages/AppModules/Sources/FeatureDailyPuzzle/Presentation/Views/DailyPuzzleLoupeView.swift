import SwiftUI
import Core
import DesignSystem

struct DailyPuzzleLoupeView<Content: View>: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    @Binding var state: LoupeState
    let configuration: LoupeConfiguration
    let boardSize: CGSize
    let content: Content

    init(
        state: Binding<LoupeState>,
        configuration: LoupeConfiguration,
        boardSize: CGSize,
        @ViewBuilder content: () -> Content
    ) {
        _state = state
        self.configuration = configuration
        self.boardSize = boardSize
        self.content = content()
    }

    var body: some View {
        if state.isVisible {
            let shape = RoundedRectangle(cornerRadius: configuration.cornerRadius, style: .continuous)
            let size = state.loupeSize
            let offsetX = -state.fingerLocation.x * state.magnification + size.width / 2
            let offsetY = -state.fingerLocation.y * state.magnification + size.height / 2

            ZStack {
                shape
                    .fill(
                        reduceTransparency
                        ? AnyShapeStyle(ColorTokens.surfaceTertiary)
                        : AnyShapeStyle(.thinMaterial)
                    )

                content
                    .frame(width: boardSize.width, height: boardSize.height, alignment: .topLeading)
                    .scaleEffect(state.magnification, anchor: .topLeading)
                    .offset(x: offsetX, y: offsetY)
                    .frame(width: size.width, height: size.height, alignment: .topLeading)
                    .clipShape(shape)
            }
            .frame(width: size.width, height: size.height)
            .overlay(
                shape.stroke(
                    colorSchemeContrast == .increased
                    ? ColorTokens.textPrimary.opacity(0.45)
                    : ColorTokens.textSecondary.opacity(0.22),
                    lineWidth: configuration.borderWidth
                )
            )
            .position(state.loupeScreenPosition)
            .allowsHitTesting(false)
            .transition(.opacity)
        }
    }
}
