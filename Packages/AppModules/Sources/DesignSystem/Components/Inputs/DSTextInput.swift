import SwiftUI

public struct DSTextInput: View {
    private let title: String
    @Binding private var value: String

    public init(title: String, value: Binding<String>) {
        self.title = title
        self._value = value
    }

    public var body: some View {
        TextField(title, text: $value)
            .textFieldStyle(.plain)
            .font(TypographyTokens.body)
            .foregroundStyle(ColorTokens.inkPrimary)
            .padding(SpacingTokens.sm)
            .background(
                RoundedRectangle(cornerRadius: RadiusTokens.buttonRadius, style: .continuous)
                    .fill(ColorTokens.surfaceSecondary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: RadiusTokens.buttonRadius, style: .continuous)
                    .stroke(ColorTokens.borderDefault, lineWidth: 1)
            )
    }
}
