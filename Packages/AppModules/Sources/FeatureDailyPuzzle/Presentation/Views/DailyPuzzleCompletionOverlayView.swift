import SwiftUI
import DesignSystem

struct DailyPuzzleCompletionOverlayView: View {
    let showBackdrop: Bool
    let showToast: Bool
    let streakLabel: String?
    let reduceMotion: Bool
    let reduceTransparency: Bool
    let onTapDismiss: () -> Void

    private var toastTransition: AnyTransition {
        reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 0.96))
    }

    var body: some View {
        ZStack {
            if showBackdrop {
                Rectangle()
                    .fill(
                        reduceTransparency
                            ? AnyShapeStyle(ColorTokens.surfacePrimary.opacity(0.9))
                            : AnyShapeStyle(.regularMaterial)
                    )
                    .ignoresSafeArea()
                    .transition(.opacity)

                ColorTokens.overlayDim
                    .ignoresSafeArea()
                    .transition(.opacity)
            }

            if showToast {
                DailyPuzzleCompletionToast(
                    streakLabel: streakLabel,
                    reduceTransparency: reduceTransparency
                )
                .transition(toastTransition)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTapDismiss()
        }
    }
}

private struct DailyPuzzleCompletionToast: View {
    let streakLabel: String?
    let reduceTransparency: Bool

    private var accessibilityText: String {
        DailyPuzzleStrings.completionAccessibility(streakLabel)
    }

    var body: some View {
        DSSurfacePanel(reduceTransparency: reduceTransparency) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            reduceTransparency
                                ? AnyShapeStyle(ColorTokens.surfaceSecondary)
                                : AnyShapeStyle(.thinMaterial)
                        )
                        .frame(width: 54, height: 54)

                    Circle()
                        .stroke(ColorTokens.textPrimary.opacity(0.24), lineWidth: 1)
                        .frame(width: 54, height: 54)

                    Image(systemName: "checkmark")
                        .font(TypographyTokens.titleSmall.weight(.bold))
                        .foregroundStyle(ColorTokens.textPrimary)
                }

                Text(DailyPuzzleStrings.completed)
                    .font(TypographyTokens.titleMedium.weight(.semibold))
                    .foregroundStyle(ColorTokens.textPrimary)

                if let streakLabel {
                    Text(streakLabel)
                        .font(TypographyTokens.callout)
                        .foregroundStyle(ColorTokens.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, SpacingTokens.lg)
            .padding(.vertical, SpacingTokens.lg)
        }
        .shadow(color: ColorTokens.inkPrimary.opacity(0.08), radius: 8, x: 0, y: 3)
        .padding(.horizontal, SpacingTokens.lg)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
    }
}
