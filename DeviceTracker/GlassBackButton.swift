//
//  GlassBackButton.swift
//  DeviceTracker
//
//  Created by Jose Castro on 10/7/25.
//

import SwiftUI

/// A macOS glassy back button (capsule, blur, divider).
struct GlassBackButton: View {
    var title: String? = nil
    var action: () -> Void
    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding(.horizontal, 12)
            .frame(height: 32)
            .contentShape(Capsule())
        }
        .buttonStyle(GlassCapsuleStyle(isHovering: isHovering))
        .onHover { isHovering = $0 }
        .keyboardShortcut(.leftArrow, modifiers: [.command])
        .help("Back")
        .accessibilityLabel("Back")
    }
}

/// Custom glassy capsule style with blur, strokes, and press/hover effects.
private struct GlassCapsuleStyle: ButtonStyle {
    var isHovering: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(.ultraThinMaterial, in: Capsule())
            .overlay {
                Capsule()
                    .strokeBorder(.white.opacity(0.22), lineWidth: 1)
                    .blendMode(.overlay)

                Capsule()
                    .strokeBorder(.black.opacity(0.15), lineWidth: 0.5)
                    .blendMode(.multiply)
            }
            .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 8)
            .brightness(configuration.isPressed ? -0.02 : (isHovering ? 0.02 : 0))
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
            .animation(.easeOut(duration: 0.18), value: isHovering)
    }
}
