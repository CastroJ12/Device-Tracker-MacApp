//
//  DashboardHeader.swift
//  DeviceTracker
//
//  Created by Jose Castro on 9/12/25.
//

import SwiftUI

struct DashboardHeader: View {
    let counts: DeviceCounts
    var onAdd: () -> Void
    var onSummary: () -> Void

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Total items in inventory")
                            .font(.title2.bold())
                        Text("\(counts.total) items")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    HStack(spacing: 8) {
                        Button("Export CSV", action: onSummary)
                        Button {
                            onAdd()
                        } label: {
                            Label("Add Device", systemImage: "plus.circle.fill")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }

                // Pills row
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(DeviceType.allCases) { t in
                            CountPill(
                                text: "\(t.rawValue.capitalized) \(counts.byType[t] ?? 0)",
                                color: t.color,
                                icon: t.icon
                            )
                        }
                    }
                }
            }
            .padding(14)
        }
        .groupBoxStyle(.dashboardCard)
    }
}

struct CountPill: View {
    let text: String
    let color: Color
    let icon: String
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon).imageScale(.small)
            Text(text).font(.footnote.weight(.semibold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule().fill(color.opacity(0.12))
        )
        .overlay(
            Capsule().strokeBorder(color.opacity(0.35), lineWidth: 0.5)
        )
        .foregroundStyle(color)
    }
}

struct DeviceTypePill: View {
    let type: DeviceType
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: type.icon).imageScale(.small)
            Text(type.rawValue.capitalized).font(.footnote.weight(.semibold))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Capsule().fill(type.color.opacity(0.12)))
        .overlay(Capsule().strokeBorder(type.color.opacity(0.35), lineWidth: 0.5))
        .foregroundStyle(type.color)
    }
}
