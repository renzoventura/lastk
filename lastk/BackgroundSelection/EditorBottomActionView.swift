//
//  EditorBottomActionView.swift
//  lastk
//
//  Layer 3: Fixed bottom control panel. Structurally independent from the canvas.
//  Contains Share, Save, and Story buttons in a horizontal layout.
//

import SwiftUI

/// Fixed bottom action bar for the photo editor.
///
/// Responsibilities:
/// - Provides Share, Save, Story buttons.
/// - Visually distinct from the canvas (opaque black background).
/// - Fixed height, does not scroll or respond to canvas gestures.
struct EditorBottomActionView: View {
    let isSaving: Bool
    let onShare: () -> Void
    let onSave: () -> Void
    let onStory: () -> Void

    static let height: CGFloat = 88

    var body: some View {
        VStack(spacing: 0) {
            Divider()

            HStack {
                actionButton("Story", systemImage: "rectangle.portrait.and.arrow.forward", action: onStory)
                    .disabled(true)
                    .foregroundStyle(.secondary)

                Spacer()

                actionButton("Save", systemImage: "square.and.arrow.down", action: onSave)
                    .disabled(isSaving)

                Spacer()

                actionButton("Share", systemImage: "square.and.arrow.up", action: onShare)
                    .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal, 24)
            .frame(maxHeight: .infinity)
        }
        .frame(height: Self.height)
        .background(.black)
    }

    private func actionButton(
        _ title: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(title, systemImage: systemImage, action: action)
    }
}
