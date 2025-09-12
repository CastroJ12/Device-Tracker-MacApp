//
//  DashboardCardStyle.swift
//  DeviceTracker
//
//  Created by Jose Castro on 9/12/25.
//

import SwiftUI

struct DashboardCardStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if let label = configuration.label as? Text, !label.string.isEmpty {
                Text(label.string).font(.headline)
                    .padding(.horizontal, 14)
                    .padding(.top, 12)
            }
            configuration.content
        }
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.regularMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(.quaternary, lineWidth: 0.5)
        )
    }
}

extension GroupBoxStyle where Self == DashboardCardStyle {
    static var dashboardCard: DashboardCardStyle { .init() }
}

private extension Text {
    /// Extract raw string (for optional label usage)
    var string: String {
        Mirror(reflecting: self).descendant("storage", "anyTextStorage", "storage") as? String ?? ""
    }
}
