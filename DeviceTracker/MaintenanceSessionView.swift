//
//  MaintenanceSessionView.swift
//  DeviceTracker
//
//  Created by Jose Castro on 9/23/25.
//

import SwiftUI
import SwiftData
import AppKit

// Row model used during a maintenance session
private struct MaintenanceRow: Identifiable, Hashable {
    let id = UUID()
    var serial = ""
    var type: DeviceType = .macbook
    var lastMaintenance = Date()
    var setNextDue = true
    var nextDueDate = Calendar.current.date(byAdding: .month, value: 3, to: .now) ?? .now
}

struct MaintenanceSessionView: View {
    @Environment(\.modelContext) private var modelContext
    var onDone: () -> Void

    @State private var rows: [MaintenanceRow] = [MaintenanceRow()]
    @State private var defaultType: DeviceType = .macbook
    @State private var showValidation = false
    @State private var filterText = ""
    @FocusState private var focusedSerialRow: UUID?

    // Filter + validation
    private var filteredRows: [MaintenanceRow] {
        filterText.isEmpty ? rows :
        rows.filter { $0.serial.localizedCaseInsensitiveContains(filterText) ||
                      $0.type.rawValue.localizedCaseInsensitiveContains(filterText) }
    }
    private var validRows: [MaintenanceRow] {
        var seen = Set<String>()
        return rows.compactMap {
            let s = $0.serial.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
            guard !s.isEmpty, seen.insert(s).inserted else { return nil }
            return MaintenanceRow(serial: s, type: $0.type, lastMaintenance: $0.lastMaintenance,
                                  setNextDue: $0.setNextDue, nextDueDate: $0.nextDueDate)
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            // Row 1 — Title • counter • Add to inventory (mirrors other views)
            HStack {
                Label("Start Maintenance Session", systemImage: "wrench.and.screwdriver.fill")
                    .font(.title3).bold()
                Spacer()
                Text("\(rows.count) rows • \(validRows.count) valid").foregroundStyle(.secondary)
                Button {
                    commitBatch()
                } label: { Label("Add \(validRows.count) to Inventory", systemImage: "tray.and.arrow.down.fill") }
                .keyboardShortcut(.defaultAction)
                .disabled(validRows.isEmpty)
            }

            // Row 2 — Left actions • Center type pills • Right filter/clear (single row)
            HStack(spacing: 12) {
                // Left
                HStack(spacing: 10) {
                    Button { addRow(with: defaultType) } label: {
                        Label("Add Device", systemImage: "plus.circle.fill")
                    }
                    Button { pasteSerials() } label: {
                        Label("Paste Serials", systemImage: "doc.on.clipboard.fill")
                    }
                }

                Spacer()

                // Center
                HStack(spacing: 10) {
                    TypePill("Macbook", .macbook, defaultType) { defaultType = .macbook }
                    TypePill("iPad",    .ipad,    defaultType) { defaultType = .ipad    }
                    TypePill("Desktop", .desktop, defaultType) { defaultType = .desktop }
                }

                Spacer()

                // Right
                HStack(spacing: 10) {
                    TextField("Filter (serial or type)…", text: $filterText)
                        .textFieldStyle(.roundedBorder).frame(width: 240)
                    Button(role: .destructive) { rows.removeAll() } label: {
                        Label("Clear All", systemImage: "trash")
                    }
                    .disabled(rows.isEmpty)
                }
            }

            // Table — editable rows
            Table(filteredRows) {
                TableColumn("Serial Number") { row in
                    TextField("e.g. FJYP6WT07W", text: binding(for: row).serial)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))
                        .focused($focusedSerialRow, equals: row.id)
                        .onSubmit { if row.id == filteredRows.last?.id { addRow(with: defaultType) } }
                }
                TableColumn("Type") { row in
                    Picker("", selection: binding(for: row).type) {
                        ForEach(DeviceType.allCases) { t in Label(t.rawValue.capitalized, systemImage: t.icon).tag(t) }
                    }
                    .labelsHidden().frame(width: 140)
                }
                TableColumn("Last Maintenance") { row in
                    DatePicker("", selection: binding(for: row).lastMaintenance, displayedComponents: .date)
                        .labelsHidden().frame(width: 160)
                }
                TableColumn("Next Due Date?") { row in
                    Toggle("", isOn: binding(for: row).setNextDue).labelsHidden().frame(width: 70)
                }
                TableColumn("Next Due Date") { row in
                    if binding(for: row).setNextDue.wrappedValue {
                        DatePicker("", selection: binding(for: row).nextDueDate, displayedComponents: .date)
                            .labelsHidden().frame(width: 160)
                    } else { Text("—").foregroundStyle(.secondary).frame(width: 160) }
                }
                TableColumn("") { row in
                    Button(role: .destructive) { rows.removeAll { $0.id == row.id } } label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.borderless).frame(width: 32)
                }
            }
            .overlay(alignment: .bottomLeading) {
                if showValidation && validRows.count != rows.count {
                    Text("Some rows are empty or duplicates. Only valid rows will be added.")
                        .font(.footnote).foregroundStyle(.secondary).padding(8)
                }
            }
        }
        .padding(16)
    }

    // MARK: - Helpers
    private func binding(for row: MaintenanceRow) -> Binding<MaintenanceRow> {
        guard let i = rows.firstIndex(where: { $0.id == row.id }) else { return .constant(row) }
        return $rows[i]
    }
    private func addRow(with type: DeviceType) {
        rows.append(MaintenanceRow(type: type)); focusedSerialRow = rows.last?.id
    }
    private func duplicateLastOrAdd() {
        if let last = rows.last {
            rows.append(MaintenanceRow(type: last.type, lastMaintenance: last.lastMaintenance,
                                       setNextDue: last.setNextDue, nextDueDate: last.nextDueDate))
        } else { rows.append(MaintenanceRow(type: defaultType)) }
        focusedSerialRow = rows.last?.id
    }
    private func commitBatch() {
        showValidation = true
        let payload = validRows; guard !payload.isEmpty else { return }
        payload.forEach {
            modelContext.insert(Device(serial: $0.serial, type: $0.type,
                                       lastMaintenance: $0.lastMaintenance,
                                       nextDue: $0.setNextDue ? $0.nextDueDate : nil))
        }
        saveAndSync(modelContext)
        rows = [MaintenanceRow(type: defaultType)]
        showValidation = false
        onDone()
    }
    private func pasteSerials() {
        guard let s = NSPasteboard.general.string(forType: .string) else { return }
        let tokens = s.replacingOccurrences(of: "\r", with: "\n")
            .split { $0.isNewline || $0 == "," || $0 == ";" || $0 == "\t" }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { $0.uppercased() }
        guard !tokens.isEmpty else { return }
        rows.append(contentsOf: tokens.map { MaintenanceRow(serial: $0, type: defaultType) })
        focusedSerialRow = rows.last?.id
    }
}

// MARK: - Type of Device Pill Selection
fileprivate struct TypePill: View {
    let title: String, t: DeviceType, current: DeviceType, action: ()->Void
    init(_ title:String,_ t:DeviceType,_ current:DeviceType, action:@escaping()->Void) {
        self.title=title; self.t=t; self.current=current; self.action=action
    }
    var body: some View {
        let selected = (t == current)
        return Button(action: action) {
            HStack(spacing:6){ Image(systemName: t.icon); Text(title) }
                .padding(.vertical,6).padding(.horizontal,10)
                .background((selected ? Color.accentColor.opacity(0.15) : .clear).clipShape(Capsule()))
                .overlay(Capsule().stroke(selected ? Color.accentColor : .gray.opacity(0.4), lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }
}
