import SwiftUI

public struct DSSurfaceModifier: ViewModifier {
    public init() {}

    public func body(content: Content) -> some View {
        content
            .background(ThemeGradients.paperBackground)
    }
}

public extension View {
    func dsSurface() -> some View {
        modifier(DSSurfaceModifier())
    }
}
