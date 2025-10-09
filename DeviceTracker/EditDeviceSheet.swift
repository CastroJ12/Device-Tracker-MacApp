//
//  EditDeviceSheet.swift
//  DeviceTracker
//
//  Created by Codex on 9/12/25.
//

import SwiftUI
import SwiftData

struct EditDeviceSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var device: Device

    @State private var setNext: Bool

    init(device: Device) {
        self.device = device
        _setNext = State(initialValue: device.nextDue != nil)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Edit Device").font(.title2.bold())

            Grid(horizontalSpacing: 12, verticalSpacing: 12) {
                GridRow {
                    Text("Serial Number")
                    TextField("e.g. FJYP6WT07W", text: $device.serial)
                        .textFieldStyle(.roundedBorder)
                }
                GridRow {
                    Text("Type")
                    Picker("", selection: Binding(get: { device.type }, set: { device.type = $0 })) {
                        ForEach(DeviceType.allCases) { t in
                            Label(t.rawValue.capitalized, systemImage: t.icon).tag(t)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                GridRow {
                    Text("Last Maintenance")
                    DatePicker("", selection: $device.lastMaintenance, displayedComponents: .date)
                        .labelsHidden()
                }
                GridRow {
                    Toggle("Set Next Due Date", isOn: $setNext)
                    if setNext {
                        DatePicker("", selection: Binding(get: {
                            device.nextDue ?? Date()
                        }, set: { device.nextDue = $0 }), displayedComponents: .date)
                        .labelsHidden()
                    } else {
                        Spacer()
                    }
                }
            }

            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                Button("Save Changes") {
                    if !setNext { device.nextDue = nil }
                    saveAndSync(modelContext)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(device.serial.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(20)
    }
}

