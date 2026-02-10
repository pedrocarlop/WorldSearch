import CoreGraphics
import SwiftUI

struct DailyPuzzleGridFramePreferenceKey: PreferenceKey {
    static let defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        let next = nextValue()
        guard next.width > 0, next.height > 0 else { return }
        value = next
    }
}
