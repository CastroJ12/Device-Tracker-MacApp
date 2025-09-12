//
//  ContentView.swift
//  DeviceTracker
//
//  Created by Jose Castro on 9/12/25.
//

import SwiftUI

struct ContentView: View {
    @State private var devices: [Device] = SampleData.seed
    @State private var showingAdd = false
    @State private var search = ""
    @State private var sortOrder: [KeyPathComparator<Device>] = [
        .init(\.type.rawValue, order: .forward),
        .init(\.serial, order: .forward)
    ]

    var filtered: [Device] {
        let trimmed = search.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return devices }
        return devices.filter {
            $0.serial.localizedCaseInsensitiveContains(trimmed)
            || $0.type.rawValue.localizedCaseInsensitiveContains(trimmed)
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Header / Card
            DashboardHeader(
                counts: DeviceCounts(devices: devices),
                onAdd: { showingAdd = true },
                onSummary: { /* hook up later */ }
            )

            // Search
            HStack(spacing: 8) {
                TextField("Search by serial or type", text: $search)
                    .textFieldStyle(.roundedBorder)
                Spacer(minLength: 0)
            }

            // Devices table
            GroupBox {
                Table(filtered, sortOrder: $sortOrder) {
                    TableColumn("Serial Number", value: \.serial) { d in
                        HStack(spacing: 6) {
                            Image(systemName: "barcode.viewfinder")
                                .foregroundStyle(.secondary)
                            Text(d.serial)
                        }
                        .padding(.vertical, 4)
                    }
                    TableColumn("Type") { d in
                        HStack(spacing: 8) {
                            DeviceTypePill(type: d.type)
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                    TableColumn("Last Maintenance") { d in
                        Text(d.lastMaintenance, style: .date)
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 4)
                    }
                    TableColumn("Next Due Date") { d in
                        if let next = d.nextDue {
                            Text(next, style: .date)
                                .fontWeight(.semibold)
                        } else {
                            Text("—").foregroundStyle(.secondary)
                        }
                    }
                }
                .tableStyle(.inset(alternatesRowBackgrounds: true))
                .animation(.default, value: filtered)
            }
            .groupBoxStyle(.dashboardCard)
        }
        .padding(20)
        .frame(minWidth: 980, minHeight: 640)
        .toolbar {
            ToolbarItemGroup {
                Button {
                    showingAdd = true
                } label: {
                    //Label("Add Device", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAdd) {
            AddDeviceSheet { new in
                devices.append(new)
            }
            .frame(width: 520)
        }
    }
}
