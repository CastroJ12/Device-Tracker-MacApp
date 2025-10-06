//
//  RootView.swift
//  DeviceTracker
//
//  Created by Jose Castro on 9/24/25.
//

import SwiftUI

enum AppRoute: Hashable {
    case menu, inventory, maintenance, audit
}

struct RootView: View {
    @State private var route: AppRoute = .menu

    var body: some View {
        switch route {
        case .menu:
            MainMenuView(
                onOpenInventory: { route = .inventory },
                onOpenMaintenance: { route = .maintenance },
                onOpenAudit: { route = .audit }
            )
        case .inventory:
            VStack(spacing: 0) {
                HStack {
                    Button("◀︎ Back") { route = .menu }
                        .buttonStyle(.link)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                ContentView()
            }
        case .maintenance:
            VStack(spacing: 0) {
                HStack {
                    Button("◀︎ Back") { route = .menu }
                        .buttonStyle(.link)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                MaintenanceSessionView {
                    route = .inventory
                }
                .frame(minWidth: 980, minHeight: 620)
            }
        case .audit:
            VStack(spacing: 0) {
                HStack {
                    Button("◀︎ Back") { route = .menu }
                        .buttonStyle(.link)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                AuditReportsView()
                    .frame(minWidth: 880, minHeight: 560)
            }
        }
    }
}
