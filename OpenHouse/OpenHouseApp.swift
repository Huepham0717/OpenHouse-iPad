//
//  OpenHouseApp.swift
//  OpenHouse
//
//  Created by Hue Pham.
//

import SwiftUI

@main
struct OpenHouseApp: App {
    @StateObject private var state = AppState()
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(state)
        }
    }
}
