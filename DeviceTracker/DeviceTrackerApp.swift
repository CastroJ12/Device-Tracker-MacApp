//
//  DeviceTrackerApp.swift
//  DeviceTracker
//
//  Created by Jose Castro on 9/12/25.
//

import SwiftUI
import SwiftData

@main
struct DeviceTrackerApp: App {
    var body: some Scene {
        WindowGroup ("Device Maintenance Tracker") {
            ContentView()
        }
        .modelContainer(for: Device.self)
    }
}
