//
//  NotificationManager.swift
//  DeviceTracker
//
//  Created by Jose Castro on 10/6/25.
//

import Foundation
import UserNotifications
import SwiftData
import AppKit

struct NotificationManager {
    enum Mode { case immediate, morning(hour: Int) } // when to fire the “due this month” summary

    static func requestAuthorization() {
        let c = UNUserNotificationCenter.current()
        c.requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }

    /// Build two summary notifications: one for OVERDUE (now), one for DUE THIS MONTH (morning or now).
    /// Call at app launch and after any add/edit/delete/maintain.
    static func rebuildBulk(using ctx: ModelContext, dueMonthMode: Mode = .morning(hour: 9)) throws {
        let c = UNUserNotificationCenter.current()
        c.removeAllPendingNotificationRequests() // clean slate; we replace summaries each rebuild

        let devices = try ctx.fetch(FetchDescriptor<Device>())
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let now = Date()

        // Counts
        let overdueCount = devices.filter { ($0.nextDue ?? .distantFuture) < today }.count
        let monthCount: Int = {
            let y = cal.component(.year,  from: today)
            let m = cal.component(.month, from: today)
            let start = cal.date(from: DateComponents(year: y, month: m, day: 1))!
            let end   = cal.date(byAdding: DateComponents(month: 1, day: -1), to: start)!
            return devices.filter { d in
                guard let nd = d.nextDue else { return false }
                return nd >= today && nd <= end  // due sometime this month (and not overdue yet)
            }.count
        }()

        // Dock badge mirrors overdue count
        DispatchQueue.main.async {
            NSApplication.shared.dockTile.badgeLabel = overdueCount > 0 ? "\(overdueCount)" : nil
        }

        // Overdue summary (fire immediately if any)
        if overdueCount > 0 {
            schedule(center: c,
                     id: "bulk.overdue",
                     title: "Overdue devices",
                     body: "You have \(overdueCount) device\(overdueCount == 1 ? "" : "s") overdue.",
                     fireAt: now.addingTimeInterval(3))
        }

        // Due this month summary (morning or now)
        if monthCount > 0 {
            let fire: Date = {
                switch dueMonthMode {
                case .immediate:
                    return now.addingTimeInterval(3)
                case .morning(let hour):
                    var comps = cal.dateComponents([.year,.month,.day], from: now)
                    comps.hour = hour; comps.minute = 0; comps.second = 0
                    let todayAtHour = cal.date(from: comps)!
                    return todayAtHour > now ? todayAtHour : cal.date(byAdding: .day, value: 1, to: todayAtHour)!
                }
            }()
            schedule(center: c,
                     id: "bulk.month",
                     title: "Maintenance due this month",
                     body: "You have \(monthCount) device\(monthCount == 1 ? "" : "s") due this month.",
                     fireAt: fire)
        }
    }

    // MARK: - Internals

    private static func schedule(center: UNUserNotificationCenter,
                                 id: String,
                                 title: String,
                                 body: String,
                                 fireAt: Date) {
        center.removePendingNotificationRequests(withIdentifiers: [id])
        center.removeDeliveredNotifications(withIdentifiers: [id])

        let content = UNMutableNotificationContent()
        content.title = title
        content.body  = body
        content.sound = .default

        let comps = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: fireAt)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let req = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        center.add(req)
    }
}
