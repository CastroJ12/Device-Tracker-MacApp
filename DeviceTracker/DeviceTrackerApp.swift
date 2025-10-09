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
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    let container: ModelContainer = {
        do {
            return try ModelContainer(for: Device.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    init() {
        // Injects the container into the AppDelegate
        appDelegate.modelContainer = container
    }

    var body: some Scene {
        WindowGroup("Device Maintenance Tracker") {
            RootView()
        }
        .modelContainer(container)
    }
}
