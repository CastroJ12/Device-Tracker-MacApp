//
//  SaveSync.swift
//  DeviceTracker
//
//  Created by Jose Castro on 10/6/25.
//

import SwiftData

@MainActor
func saveAndSync(_ ctx: ModelContext) {
    try? ctx.save()
    try? NotificationManager.rebuildBulk(using: ctx, dueMonthMode: .morning(hour: 9))
}
