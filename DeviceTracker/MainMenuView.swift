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
    
    // inside MainMenuView
    private let idealCardWidth: CGFloat = 300
    private let gridSpacing: CGFloat = 20
    private let outerPadding: CGFloat = 32
    private let maxContentWidth: CGFloat = 1100   // Keeps everything at the center of the screen
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Device Maintenance Tracker")
                .font(.system(size: 24, weight: .semibold))
                .padding(.top, 24)
            
            let columns = [GridItem(.adaptive(minimum: idealCardWidth), spacing: gridSpacing)]
            
            ScrollView {
                // ***** Center the grid *****
                HStack(spacing: 0) {
                    Spacer(minLength: 0)
                    LazyVGrid(columns: columns, spacing: gridSpacing) {
                        MenuCard(
                            title: "View Current Inventory",
                            subtitle: "Browse, search, export",
                            icon: "tablecells",
                            cardBaseWidth: idealCardWidth,
                            action: onOpenInventory
                        )
                        MenuCard(
                            title: "Start Maintenance Session",
                            subtitle: "Batch add/edit devices",
                            icon: "wrench.and.screwdriver.fill",
                            cardBaseWidth: idealCardWidth,
                            action: onOpenMaintenance
                        )
                        MenuCard(
                            title: "Audit & Reports",
                            subtitle: "Overdue and upcoming",
                            icon: "chart.bar.fill",
                            cardBaseWidth: idealCardWidth,
                            action: onOpenAudit
                        )
                    }
                    .frame(maxWidth: maxContentWidth)   // <- prevents over-wide stretching
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, outerPadding)
                .padding(.bottom, outerPadding)
            }
        }
        .padding(.horizontal, outerPadding)
        .background(.ultraThinMaterial)
    }
}

private struct MenuCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let cardBaseWidth: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            // Card content
            VStack(alignment: .leading, spacing: 10) {
                // Icon scales relative to base card width
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: iconSize(forBase: cardBaseWidth),
                        height: iconSize(forBase: cardBaseWidth)
                    )
                    .foregroundStyle(.primary)

                Text(title)
                    .font(.title3).bold()
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                Text(subtitle)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.9)

                Spacer(minLength: 8)
            }
            .padding(20)
            // Fill available width in the grid cell; height adapts from base
            .frame(maxWidth: .infinity, minHeight: cardBaseWidth * 0.55, alignment: .leading)
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

    // Keeps icons at different sizes
    private func iconSize(forBase base: CGFloat) -> CGFloat {
        let proposed = base * 0.18
        return min(max(proposed, 28), 64)
    }
}
