import SwiftUI

public struct DSStatusBadge: View {
    public enum Kind {
        case locked
        case completed
    }

    private let kind: Kind
    private let size: CGFloat

    public init(kind: Kind, size: CGFloat = 54) {
        self.kind = kind
        self.size = size
    }

    public var body: some View {
        ZStack {
            Circle()
                .fill(ColorTokens.surfacePrimary.opacity(0.78))
                .frame(width: size, height: size)

            Image(systemName: icon)
                .font(TypographyTokens.titleSmall)
                .foregroundStyle(iconStyle)
        }
        .allowsHitTesting(false)
    }

    private var icon: String {
        switch kind {
        case .locked:
            return "lock.fill"
        case .completed:
            return "checkmark.seal.fill"
        }
    }

    private var iconStyle: AnyShapeStyle {
        switch kind {
        case .locked:
            return AnyShapeStyle(ColorTokens.textPrimary)
        case .completed:
            return AnyShapeStyle(ThemeGradients.brushWarm)
        }
    }
}
