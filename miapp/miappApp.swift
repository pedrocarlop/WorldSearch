//
//  miappApp.swift
//  miapp
//
//  Created by Pedro Carrasco lopez brea on 8/2/26.
//

import SwiftUI
import DesignSystem

@main
struct miappApp: App {
    @StateObject private var container = AppContainer.live

    var body: some Scene {
        WindowGroup {
            ThemeProvider {
                ContentView(container: container)
            }
        }
    }
}
