//
//  AppDelegate.swift
//  DeviceTracker
//
//  Created by Jose Castro on 10/6/25.
//

import SwiftUI
import SwiftData
import UserNotifications

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, @MainActor UNUserNotificationCenterDelegate {
    // Injected from DeviceTrackerApp.init()
    var modelContainer: ModelContainer!
    private var dailyTimer: Timer?

    private var modelContext: ModelContext { modelContainer.mainContext }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // UNUserNotificationCenter delegate callbacks are not guaranteed on main.
        // Do all UI/SwiftData work on the main actor.
        Task { @MainActor in
            UNUserNotificationCenter.current().delegate = self
            NotificationManager.requestAuthorization()

            // Initial build (SwiftData => main actor)
            try? NotificationManager.rebuildBulk(using: modelContext, dueMonthMode: .morning(hour: 9))

            // Schedule the daily refresh
            scheduleDailyRefresh(hour: 9, minute: 5)
        }
    }

    private func scheduleDailyRefresh(hour: Int, minute: Int) {
        dailyTimer?.invalidate()

        func nextFireDate() -> Date {
            var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            comps.hour = hour; comps.minute = minute; comps.second = 0
            let todayAt = Calendar.current.date(from: comps)!
            return todayAt > Date() ? todayAt : Calendar.current.date(byAdding: .day, value: 1, to: todayAt)!
        }

        dailyTimer = Timer(
            fireAt: nextFireDate(),
            interval: 00*00*10,
            target: BlockOperation { [weak self] in
                guard let self else { return }
                // Hop to main for SwiftData work
                Task { @MainActor in
                    try? NotificationManager.rebuildBulk(using: self.modelContext, dueMonthMode: .morning(hour: 9))
                }
            },
            selector: #selector(Operation.main),
            userInfo: nil,
            repeats: true
        )
        if let dailyTimer { RunLoop.main.add(dailyTimer, forMode: .common) }
    }

    // Delegate may be called off-main; hop to main before touching AppKit
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        Task { @MainActor in
            NSApp.activate(ignoringOtherApps: true)
            completionHandler()
        }
    }
}
