import SwiftUI

public enum ThemeGradients {
    public static let brushWarm = LinearGradient(
        colors: [ColorTokens.accentCoral, ColorTokens.accentAmber],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let brushWarmStrong = LinearGradient(
        colors: [ColorTokens.accentCoralStrong, ColorTokens.accentAmberStrong],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let completionBrush = LinearGradient(
        colors: [
            ColorTokens.accentAmberStrong.opacity(0.95),
            ColorTokens.accentCoralStrong.opacity(0.92)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    public static let paperBackground = LinearGradient(
        colors: [ColorTokens.backgroundPaper, ColorTokens.surfacePaperMuted],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let wordListTopFade = LinearGradient(
        gradient: Gradient(stops: [
            .init(color: .clear, location: 0.0),
            .init(color: .black.opacity(0.62), location: 0.48),
            .init(color: .black, location: 1.0)
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
}
