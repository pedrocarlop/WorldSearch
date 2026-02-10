import Foundation
import WidgetKit
import Core

enum CoreBootstrap {
    static let shared: CoreContainer = CoreContainer.live {
        Task { @MainActor in
            WidgetCenter.shared.reloadTimelines(ofKind: WordSearchConfig.widgetKind)
        }
    }
}
