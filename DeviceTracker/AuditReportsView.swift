//
//  AuditReportsView.swift
//  DeviceTracker
//
//  Created by Jose Castro on 9/24/25.
//

import SwiftUI
import SwiftData
import AppKit

enum AuditScope: String, CaseIterable, Identifiable { case overdue="Overdue", dueSoon="Due Soon", all="All"; var id:String{ rawValue } }

struct AuditReportsView: View {
    @Environment(\.modelContext) private var ctx
    @Query(sort: \Device.nextDue) private var devices: [Device]

    @State private var scope: AuditScope = .all
    @State private var lookaheadDays = 14
    @State private var query = ""
    @State private var editing: Device?                // sheet item
    @State private var selection = Set<Device.ID>()    // Table selection

    private var today: Date { Calendar.current.startOfDay(for: .init()) }
    private var horizon: Date { Calendar.current.date(byAdding: .day, value: lookaheadDays, to: today)! }
    private static let intFmt: NumberFormatter = { let f=NumberFormatter(); f.minimum=1; f.maximum=365; f.allowsFloats=false; return f }()

    private var filtered: [Device] {
        let base: [Device] = switch scope {
            case .overdue: devices.filter { ($0.nextDue ?? .distantFuture) < today }
            case .dueSoon: devices.filter { if let nd=$0.nextDue { nd >= today && nd <= horizon } else { false } }
            case .all:     devices
        }
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return q.isEmpty ? base : base.filter { $0.serial.localizedCaseInsensitiveContains(q) || $0.type.rawValue.localizedCaseInsensitiveContains(q) }
    }

    // Single selected device from the current filtered list
    private var singleSelection: Device? {
        guard selection.count == 1, let id = selection.first else { return nil }
        return filtered.first { $0.id == id }
    }

    private var selectedDevices: [Device] {
        filtered.filter { selection.contains($0.id) }
    }

    private var showEmptyOnly: Bool { (scope == .overdue || scope == .dueSoon) && filtered.isEmpty }

    var body: some View {
        let isOverdue = (scope == .overdue), isDueSoon = (scope == .dueSoon), isAll = (scope == .all)

        VStack(spacing: 12) {
            HStack {
                Label("Audit & Reports", systemImage: "chart.bar.fill").font(.title3).bold()
                Spacer()
                TextField("Search…", text: $query).textFieldStyle(.roundedBorder).frame(width: 200)
                Button(action: { exportCSV() }) {  // updated to no-arg exporter
                    Label("Export", systemImage: "square.and.arrow.up")
                }
                .disabled(filtered.isEmpty)
            }

            // Row 2 — pills
            HStack(spacing: 10) {
                Spacer()
                Pill(title:"Overdue",
                     count:devices.filter{ ($0.nextDue ?? .distantFuture) < today }.count,
                     systemImage:"exclamationmark.triangle.fill", color:.red,
                     selected:isOverdue) { scope = .overdue }
                Pill(title:"Due Soon",
                     count:devices.filter{ if let nd=$0.nextDue { nd>=today && nd<=horizon } else { false } }.count,
                     systemImage:"clock.badge.exclamationmark", color:.orange,
                     selected:isDueSoon) { scope = .dueSoon }
                Pill(title:"All",
                     count:devices.count,
                     systemImage:"tray.full.fill", color:.blue,
                     selected:isAll) { scope = .all }
                Spacer()
            }

            // Row 3 — look-ahead (when due soon) + actions
            HStack(spacing: 10) {
                Spacer()
                if isDueSoon {
                    HStack(spacing: 6){
                        Text("Look Ahead:")
                        TextField("", value: $lookaheadDays, formatter: Self.intFmt)
                            .frame(width: 36)
                            .multilineTextAlignment(.trailing)
                            .font(.system(.body, design: .monospaced))
                            .onChange(of: lookaheadDays) { _, v in lookaheadDays = max(1, min(365, v)) }
                        Text("days")
                        Stepper("", value: $lookaheadDays, in: 1...365).labelsHidden()
                    }
                    .padding(.trailing, 8)
                }

                Button(action: { maintainToday(selectedDevices) }) {
                    Label("Maintain Today", systemImage: "checkmark.circle.fill")
                }
                .disabled(selectedDevices.isEmpty)

                Button(action: { if let dev = singleSelection { editing = dev } }) {
                    Label("Edit", systemImage: "pencil")
                }
                .disabled(singleSelection == nil)

                Button(role: .destructive, action: { delete(selectedDevices) }) {
                    Label("Delete", systemImage: "trash")
                }
                .disabled(selectedDevices.isEmpty)
                Spacer()
            }

            // Content
            if showEmptyOnly {
                ContentUnavailableView("Nothing to show", systemImage: "tray",
                                       description: Text("Try another scope, search, or increase the look-ahead."))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                GeometryReader { geo in
                    Table(filtered, selection: $selection) {
                        TableColumn("Serial")      { d in Text(d.serial).font(.system(.body, design: .monospaced)) }
                        TableColumn("Type")        { d in Text(d.type.rawValue.capitalized) }
                        TableColumn("Last Maint.") { d in Text(d.lastMaintenance, style: .date).foregroundStyle(.secondary) }
                        TableColumn("Next Due")    { d in
                            if let nd=d.nextDue {
                                Text(nd, style: .date).fontWeight(.semibold)
                                    .foregroundStyle(nd < today ? .red : .primary)
                            } else { Text("—").foregroundStyle(.secondary) }
                        }
                    }
                    .frame(minWidth: geo.size.width, maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding(16)
        .sheet(item: $editing) { dev in EditDeviceSheet(device: dev).frame(width: 500) }
    }

    // MARK: Actions (use saveAndSync to persist + refresh notifications)
    private func maintainToday(_ list: [Device]) {
        guard !list.isEmpty else { return }
        let now = Date()
        for d in list {
            d.lastMaintenance = now
            d.nextDue = Calendar.current.date(byAdding: .month, value: 3, to: now)
        }
        saveAndSync(ctx)
    }

    private func delete(_ list: [Device]) {
        guard !list.isEmpty else { return }
        for d in list { ctx.delete(d) }
        saveAndSync(ctx)
        selection.removeAll()
    }

    // MARK: Export (current filtered)
    @MainActor
    private func exportCSV() {
        guard !filtered.isEmpty else { return }
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.commaSeparatedText]
        panel.nameFieldStringValue = "devices.csv"
        panel.directoryURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
        panel.canCreateDirectories = true
        panel.isExtensionHidden = false

        if let window = NSApp.keyWindow ?? NSApp.windows.first(where: { $0.isKeyWindow }) {
            panel.beginSheetModal(for: window) { r in if r == .OK, let url = panel.url { writeCSV(to: url, list: filtered) } }
        } else {
            if panel.runModal() == .OK, let url = panel.url { writeCSV(to: url, list: filtered) }
        }
    }

    private func writeCSV(to url: URL, list: [Device]) {
        do { try makeCSV(from: list).data(using: .utf8)?.write(to: url) }
        catch { print("CSV export failed:", error.localizedDescription) }
    }

    private func makeCSV(from devices: [Device]) -> String {
        var lines = ["serial,type,lastMaintenance,nextDue"]
        let df = DateFormatter(); df.locale = .init(identifier: "en_US_POSIX"); df.timeZone = .init(secondsFromGMT: 0); df.dateFormat = "yyyy-MM-dd"
        for d in devices {
            let serial = escape(d.serial), type = escape(d.type.rawValue)
            let last = escape(df.string(from: d.lastMaintenance))
            let next = d.nextDue.map { escape(df.string(from: $0)) } ?? ""
            lines.append("\(serial),\(type),\(last),\(next)")
        }
        return lines.joined(separator: "\n") + "\n"
    }

    private func escape(_ s: String) -> String {
        var f = s.replacingOccurrences(of: "\"", with: "\"\"")
        if f.contains(",") || f.contains("\n") || f.contains("\"") { f = "\"\(f)\"" }
        return f
    }
}

// MARK: - Pill
fileprivate struct Pill: View {
    let title:String, count:Int, systemImage:String, color:Color, selected:Bool, action:()->Void
    var body: some View {
        Button(action: action) {
            HStack(spacing:6){ Image(systemName: systemImage); Text(title); Text("\(count)").bold() }
                .padding(.vertical,6).padding(.horizontal,10)
                .background((selected ? color.opacity(0.2) : .clear).clipShape(Capsule()))
                .overlay(Capsule().stroke(selected ? color : .gray.opacity(0.4), lineWidth: 1.5))
        }.buttonStyle(.plain)
    }
}
