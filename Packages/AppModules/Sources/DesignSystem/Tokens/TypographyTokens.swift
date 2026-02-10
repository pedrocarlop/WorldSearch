import SwiftUI

public enum TypographyTokens {
    private enum FontName {
        static let instrumentSerif = "InstrumentSerif-Regular"
    }

    private static func serif(_ size: CGFloat, relativeTo textStyle: Font.TextStyle) -> Font {
        // SwiftUI falls back to a system font if the custom face is unavailable.
        .custom(FontName.instrumentSerif, size: size, relativeTo: textStyle)
    }

    // MARK: - Semantic styles
    public static let displayTitle = serif(38, relativeTo: .largeTitle).weight(.bold)
    public static let screenTitle = serif(30, relativeTo: .title2).weight(.semibold)
    public static let sectionTitle = serif(24, relativeTo: .title3).weight(.semibold)
    public static let body = Font.system(.body, design: .default)
    public static let bodyStrong = Font.system(.body, design: .default).weight(.semibold)
    public static let callout = Font.system(.callout, design: .default)
    public static let footnote = Font.system(.footnote, design: .default)
    public static let caption = Font.system(.caption, design: .default)

    // MARK: - Legacy aliases
    public static let titleLarge = displayTitle
    public static let titleMedium = screenTitle
    public static let titleSmall = sectionTitle
    public static let wordChip = Font.system(.body, design: .rounded).weight(.semibold)
    public static let wordDescription = Font.system(.body, design: .default)

    public static func boardLetter(size: CGFloat) -> Font {
        Font.system(size: size, weight: .semibold, design: .rounded)
    }

    public static let monoBody = Font.system(.body, design: .default).weight(.semibold)
}
