//
//  ContentView.swift
//  DeviceTracker
//
//  Created by Jose Castro on 9/12/25.
//

import SwiftUI
import SwiftData
import AppKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var devices: [Device]
    @State private var showingAdd = false
    @State private var editing: Device?
    @State private var search = ""
    @State private var sortOrder: [KeyPathComparator<Device>] = [
        .init(\.typeRaw, order: .forward),
        .init(\.serial, order: .forward)
    ]

    @State private var selectedTypes: Set<DeviceType> = []
    
    var filtered: [Device] {
        let trimmed = search.trimmingCharacters(in: .whitespacesAndNewlines)
        let base = trimmed.isEmpty
            ? devices
            : devices.filter {
                $0.serial.localizedCaseInsensitiveContains(trimmed) ||
                $0.type.rawValue.localizedCaseInsensitiveContains(trimmed)
            }
        return selectedTypes.isEmpty ? base : base.filter { selectedTypes.contains($0.type) }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Header / Card
            DashboardHeader(
                counts: DeviceCounts(devices: devices),
                selectedTypes: $selectedTypes,
                onAdd: { showingAdd = true },
                onSummary: { exportCSV() }
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
                        .contentShape(Rectangle())
                        .onTapGesture(count: 2) { editing = d }
                        .contextMenu {
                            Button("Edit") { editing = d }
                            Divider()
                            Button(role: .destructive) { deleteDevice(d) } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    TableColumn("Type") { d in
                        Text(d.type.rawValue.capitalized)
                            .frame(maxWidth: .infinity, alignment: .center)
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
        .sheet(isPresented: $showingAdd) {
            AddDeviceSheet { new in
                modelContext.insert(new)
            }
            .frame(width: 520)
        }
        .sheet(item: $editing) { device in
            EditDeviceSheet(device: device)
                .frame(width: 520)
        }
        .onAppear {
            // Seed the store on first run
            if devices.isEmpty {
                for d in SampleData.seed { modelContext.insert(d) }
                try? modelContext.save()
            }
        }
    }
}

// MARK: - Helpers

extension ContentView {
    private func deleteDevice(_ device: Device) {
        modelContext.delete(device)
        try? modelContext.save()
    }

    @MainActor
    private func exportCSV() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.commaSeparatedText]
        panel.nameFieldStringValue = "devices.csv"
        panel.directoryURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
        panel.canCreateDirectories = true
        panel.isExtensionHidden = false

        if let window = NSApp.keyWindow ?? NSApp.windows.first(where: { $0.isKeyWindow }) {
            panel.beginSheetModal(for: window) { response in
                guard response == .OK, let url = panel.url else { return }
                writeCSV(to: url)
            }
        } else {
            let result = panel.runModal()
            guard result == .OK, let url = panel.url else { return }
            writeCSV(to: url)
        }
    }

    private func writeCSV(to url: URL) {
        let csv = makeCSV(from: devices)
        do {
            try csv.data(using: .utf8)?.write(to: url)
        } catch {
            print("CSV export failed:", error.localizedDescription)
        }
    }

    private func makeCSV(from devices: [Device]) -> String {
        var lines: [String] = []
        lines.append("serial,type,lastMaintenance,nextDue")

        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(secondsFromGMT: 0)
        df.dateFormat = "yyyy-MM-dd"

        for d in devices {
            let serial = escape(d.serial)
            let type = escape(d.type.rawValue)
            let last = escape(df.string(from: d.lastMaintenance))
            let next = d.nextDue.map { escape(df.string(from: $0)) } ?? ""
            lines.append("\(serial),\(type),\(last),\(next)")
        }
        return lines.joined(separator: "\n") + "\n"
    }

    private func escape(_ field: String) -> String {
        // Escape quotes and wrap in quotes if needed
        var f = field.replacingOccurrences(of: "\"", with: "\"\"")
        if f.contains(",") || f.contains("\n") || f.contains("\"") {
            f = "\"\(f)\""
        }
        return f
    }
}
