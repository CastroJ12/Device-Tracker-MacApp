//
//  Device.swift
//  DeviceTracker
//
//  Created by Jose Castro on 9/12/25.
//

import Foundation
import SwiftUI

enum DeviceType: String, CaseIterable, Codable, Identifiable {
    case macbook = "MACBOOK"
    case ipad = "IPAD"
    case desktop = "DESKTOP"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .macbook: return "laptopcomputer"
        case .ipad:    return "ipad"
        case .desktop: return "desktopcomputer"
        }
    }

    /// Use built-in system colors so it feels native and supports dark mode.
    var color: Color {
        switch self {
        case .macbook: return .blue
        case .ipad:    return .teal
        case .desktop: return .purple
        }
    }
}

struct Device: Identifiable, Hashable, Codable {
    var id = UUID()
    var serial: String
    var type: DeviceType
    var lastMaintenance: Date
    var nextDue: Date?
}

struct DeviceCounts {
    var byType: [DeviceType: Int]
    var total: Int { byType.values.reduce(0, +) }

    init(devices: [Device]) {
        byType = Dictionary(grouping: devices, by: \.type).mapValues(\.count)
        for t in DeviceType.allCases where byType[t] == nil { byType[t] = 0 }
    }
}

enum SampleData {
    static let seed: [Device] = [
        Device(serial: "FJYP6WT07W", type: .macbook,
               lastMaintenance: ISO8601DateFormatter().date(from: "2025-08-22T00:00:00Z")!,
               nextDue: ISO8601DateFormatter().date(from: "2025-11-22T00:00:00Z")!),
        Device(serial: "AB75231", type: .desktop,
               lastMaintenance: .now.addingTimeInterval(-86_400 * 7),
               nextDue: .now.addingTimeInterval(86_400 * 75))
    ]
}
