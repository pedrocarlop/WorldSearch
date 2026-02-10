import SwiftUI

public enum TypographyTokens {
    // MARK: - Semantic styles
    public static let displayTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
    public static let screenTitle = Font.system(.title2, design: .rounded).weight(.semibold)
    public static let sectionTitle = Font.system(.title3, design: .rounded).weight(.semibold)
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
