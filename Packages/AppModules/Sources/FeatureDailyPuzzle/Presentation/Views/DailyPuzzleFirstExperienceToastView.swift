import SwiftUI
import DesignSystem

public struct DailyPuzzleFirstExperienceToastView: View {
    public enum Placement: Equatable {
        case top
        case bottom
    }

    public let message: String
    public let placement: Placement
    public let onNext: () -> Void
    public let onSkipAll: () -> Void

    public init(
        message: String,
        placement: Placement,
        onNext: @escaping () -> Void,
        onSkipAll: @escaping () -> Void
    ) {
        self.message = message
        self.placement = placement
        self.onNext = onNext
        self.onSkipAll = onSkipAll
    }

    public var body: some View {
        VStack(spacing: SpacingTokens.xs) {
            Text(message)
                .font(TypographyTokens.bodyStrong)
                .foregroundStyle(ColorTokens.inkPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)

            HStack(spacing: SpacingTokens.md) {
                Button(action: onSkipAll) {
                    Text(DailyPuzzleStrings.firstExperienceSkipAll)
                        .font(TypographyTokens.callout)
                        .foregroundStyle(ColorTokens.textSecondary)
                        .underline()
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("dailyPuzzle.firstExperience.skipAllButton")

                Spacer(minLength: 0)

                Button(action: onNext) {
                    Text(DailyPuzzleStrings.firstExperienceNext)
                        .font(TypographyTokens.callout.weight(.semibold))
                        .foregroundStyle(ColorTokens.accentPrimary)
                        .underline()
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("dailyPuzzle.firstExperience.nextButton")
            }
        }
        .padding(.horizontal, SpacingTokens.md)
        .padding(.vertical, SpacingTokens.sm)
        .background(
            RoundedRectangle(cornerRadius: RadiusTokens.overlayRadius, style: .continuous)
                .fill(ColorTokens.surfaceSecondary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: RadiusTokens.overlayRadius, style: .continuous)
                .dsInnerStroke(ColorTokens.accentAmberStrong.opacity(0.35), lineWidth: 1)
        )
        .shadow(color: ColorTokens.accentAmberStrong.opacity(0.2), radius: 12, x: 0, y: 8)
        .accessibilityElement(children: .contain)
    }
}
