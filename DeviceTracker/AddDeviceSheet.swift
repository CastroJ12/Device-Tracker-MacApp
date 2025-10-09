//
//  AddDeviceSheet.swift
//  DeviceTracker
//
//  Created by Jose Castro on 9/12/25.
//

import SwiftUI

struct AddDeviceSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var serial = ""
    @State private var type: DeviceType = .macbook
    @State private var lastMaintenance = Date()
    @State private var setNext = true
    @State private var nextDue = Calendar.current.date(byAdding: .day, value: 90, to: Date())

    var onSave: (Device) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add Device").font(.title2.bold())

            Grid(horizontalSpacing: 12, verticalSpacing: 12) {
                GridRow {
                    Text("Serial Number")
                    TextField("e.g. FJYP6WT07W", text: $serial)
                        .textFieldStyle(.roundedBorder)
                }
                GridRow {
                    Text("Type")
                    Picker("", selection: $type) {
                        ForEach(DeviceType.allCases) { t in
                            Label(t.rawValue.capitalized, systemImage: t.icon).tag(t)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                GridRow {
                    Text("Last Maintenance")
                    DatePicker("", selection: $lastMaintenance, displayedComponents: .date)
                        .labelsHidden()
                }
                GridRow {
                    Toggle("Set Next Due Date", isOn: $setNext)
                    if setNext {
                        DatePicker("", selection: Binding(get: {
                            nextDue ?? Date()
                        }, set: { nextDue = $0 }), displayedComponents: .date)
                        .labelsHidden()
                    } else {
                        Spacer()
                    }
                }
            }

            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                Button("Add Device") {
                    let new = Device(
                        serial: serial.trimmingCharacters(in: .whitespacesAndNewlines),
                        type: type,
                        lastMaintenance: lastMaintenance,
                        nextDue: setNext ? nextDue : nil
                    )
                    onSave(new)
                    saveAndSync(modelContext)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(serial.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(20)
    }
}
