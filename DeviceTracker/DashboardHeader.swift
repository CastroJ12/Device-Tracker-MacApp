//
//  DashboardHeader.swift
//  DeviceTracker
//
//  Created by Jose Castro on 9/12/25.
//

import SwiftUI

struct DashboardHeader: View {
    let counts: DeviceCounts
    @Binding var selectedTypes: Set<DeviceType>   // ⟵ binding to control filters
    var onAdd: () -> Void
    var onSummary: () -> Void

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Total items in inventory").font(.title2.bold())
                        Text("\(counts.total) items")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                    Spacer()
                    HStack(spacing: 8) {
                        Button("Export CSV", action: onSummary) // or your real action
                        Button {
                            onAdd()
                        } label: {
                            Label("Add Device", systemImage: "plus.circle.fill")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }

                // Filter pills row
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        // "All" pill
                        SelectablePill(
                            text: "All",
                            icon: "rectangle.grid.2x2",
                            color: .gray,
                            isOn: selectedTypes.isEmpty
                        ) {
                            selectedTypes.removeAll()
                        }

                        ForEach(DeviceType.allCases) { t in
                            let isOn = selectedTypes.contains(t)
                            SelectablePill(
                                text: "\(t.rawValue.capitalized) \(counts.byType[t] ?? 0)",
                                icon: t.icon,
                                color: t.color,
                                isOn: isOn
                            ) {
                                if isOn {
                                    selectedTypes.remove(t)
                                } else {
                                    selectedTypes.insert(t)        // multi-select
                                    // For single-select behavior instead:
                                    // selectedTypes = [t]
                                }
                            }
                        }
                    }
                }
            }
            .padding(14)
        }
        .groupBoxStyle(.dashboardCard)
    }
}

// Interactive capsule pill
struct SelectablePill: View {
    let text: String
    let icon: String
    let color: Color
    let isOn: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon).imageScale(.small)
                Text(text).font(.footnote.weight(.semibold))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule().fill(isOn ? color : color.opacity(0.12))
            )
            .overlay(
                Capsule().strokeBorder(isOn ? Color.clear : color.opacity(0.35), lineWidth: 0.5)
            )
            .foregroundStyle(isOn ? Color.white : color)
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isOn)
    }
}
