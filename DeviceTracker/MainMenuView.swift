//
//  MainMenuView.swift
//  DeviceTracker
//
//  Created by Jose Castro on 9/23/25.
//

import SwiftUI

struct MainMenuView: View {
    var onOpenInventory: () -> Void
    var onOpenMaintenance: () -> Void
    var onOpenAudit: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("Device Maintenance Tracker")
                .font(.system(size: 24, weight: .semibold))
                .padding(.top, 24)

            HStack(spacing: 20) {
                MenuCard(title: "View Current Inventory",
                         subtitle: "Browse, search, export",
                         icon: "tablecells",
                         action: onOpenInventory)

                MenuCard(title: "Start Maintenance Session",
                         subtitle: "Batch add/edit devices",
                         icon: "wrench.and.screwdriver.fill",
                         action: onOpenMaintenance)

                MenuCard(title: "Audit & Reports",
                         subtitle: "Overdue and upcoming",
                         icon: "chart.bar.fill",
                         action: onOpenAudit)
            }
            .frame(maxWidth: 980)

            Spacer()
        }
        .padding(32)
        .background(.ultraThinMaterial)
    }
}

private struct MenuCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .semibold))
                Text(title).font(.title3).bold()
                Text(subtitle).foregroundStyle(.secondary)
            }
            .padding(20)
            .frame(width: 300, height: 160, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(nsColor: .windowBackgroundColor).opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(.white.opacity(0.07))
            )
            .shadow(radius: 12, y: 6)
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
