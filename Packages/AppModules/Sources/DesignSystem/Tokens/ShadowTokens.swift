import SwiftUI

public struct DSShadowToken {
    public let color: Color
    public let radius: CGFloat
    public let x: CGFloat
    public let y: CGFloat

    public init(color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }
}

public enum ShadowTokens {
    public static let cardAmbient = DSShadowToken(
        color: ColorTokens.inkPrimary.opacity(0.06),
        radius: 4,
        x: 0,
        y: 1
    )
    public static let cardDrop = DSShadowToken(
        color: ColorTokens.inkPrimary.opacity(0.04),
        radius: 8,
        x: 0,
        y: 3
    )
}
