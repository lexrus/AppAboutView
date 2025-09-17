//
// GlassButton.swift
// LiveExtractor
//
// Created by Cascade on 2025-05-22.
// Copyright 2025 Cascade. All rights reserved.
//

// Wireframe:
// (Subtle white highlight on top & left edges)
// +---------------------------------------+
// |                                       |
// |           [ Button Title ]            |
// |                                       |
// +---------------------------------------+
// (Subtle dark shadow on bottom & right edges)

import SwiftUI

public struct GlassButton: View {
    let text: Text?
    let systemImage: String? // Optional system image name
    let isProminent: Bool
    let action: () -> Void

    private let cornerRadius: CGFloat = 24 // Soft rounded corners

    public init(
        _ text: Text? = nil,
        systemImage: String? = nil,
        isProminent: Bool = false,
        action: @escaping () -> Void
    ) {
        self.text = text
        self.systemImage = systemImage
        self.isProminent = isProminent
        self.action = action
    }

    @State private var animateGradient = false
    @State private var isHovered = false

    public var body: some View {
        Group {
            if #available(iOS 26.0, macOS 26.0, *) {
                // Prefer system button style on newer OS versions
                Button(action: action) {
                    HStack {
                        if let systemImage, let text {
                            Label { text } icon: { Image(systemName: systemImage) }
                        } else if let text {
                            text
                        } else if let systemImage {
                            Image(systemName: systemImage)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(GlassButtonStyle())
            } else {
                // Existing custom "glass" style for older systems
                Button(action: action) {
                    HStack {
                        if let systemImage {
                            Image(systemName: systemImage)
                                .foregroundStyle(.primary)
                        }
                        if let text {
                            text
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .fontDesign(.rounded)
                                .fontWeight(.medium)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(8)
#if !os(tvOS)
                    .background(.ultraThinMaterial) // Ground glass effect
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)) // Soft rounded corners
                    .overlay( // Top-left highlight
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: .white.opacity(0.4), location: 0), // Highlight color
                                        .init(color: .clear, location: 0.7)             // Fade to transparent
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: UnitPoint(x: 0.01, y: 0.6) // Control gradient spread
                                ),
                                lineWidth: 1
                            )
                            .allowsHitTesting(false) // Ensure it doesn't interfere with button interaction
                    )
                    .overlay( // This is the existing border
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2) // Subtle shadow
                    .overlay(
                        // Neon Glow - only when hovered
                        Group {
                            if isHovered {
                                TimelineView(.animation) { context in
                                    let time = context.date.timeIntervalSince1970

                                    // Oscillates between 0.1 and 0.4
                                    let glowOpacity = (sin(time * 2) + 1) / 2 * 0.6 + 0.1

                                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 0.2, green: 0.5, blue: 1.0).opacity(glowOpacity),
                                                    Color(red: 0.2, green: 0.5, blue: 1.0).opacity(0)
                                                ],
                                                // Blueish glow
                                                startPoint: .bottom,
                                                // Glow starts from the bottom
                                                endPoint: .center    // Fades towards the center
                                            ),
                                            lineWidth: 2
                                        )
                                        .blur(radius: 5)
                                        .blendMode(.plusLighter) // Brighter glow effect
                                }
                            }
                        }
                    )
                    .foregroundStyle(.primary) // Ensure text is legible
#endif
                }
//                .buttonStyle(.plain) // Use plain to allow custom styling to take full effect
#if !os(tvOS)
                .onHover { hovering in
                    isHovered = hovering
                }
#endif
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        VStack(spacing: 20) {
            GlassButton(Text("Extract Audio"), systemImage: "waveform.and.magnifyingglass", action: {
                print("Extract Audio tapped")
            })

            GlassButton(Text("Cancel"), action: {
                print("Cancel tapped")
            })

            GlassButton(Text("Supercalifragilisticexpialidocious"), action: {
                print("Cancel tapped")
            })
            .frame(maxWidth: 200)
        }
        .preferredColorScheme(.dark)
    }
    .frame(maxHeight: .infinity)
    .padding(30)
    .background(Color.gray.opacity(0.12)) // Example background to see the glass effect
}
