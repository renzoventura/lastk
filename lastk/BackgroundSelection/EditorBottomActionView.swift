//
//  EditorBottomActionView.swift
//  lastk
//
//  Layer 3: Fixed bottom control panel. Dark theme with clear interaction states.
//

import SwiftUI

/// Fixed bottom action bar for the photo editor.
struct EditorBottomActionView: View {
    let isSaving: Bool
    let onShare: () -> Void
    let onSave: () -> Void
    let onStory: () -> Void

    static let height: CGFloat = 80

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(AppColors.divider)
                .frame(height: 1)

            HStack {
                // Story (disabled for now)
                Button(action: onStory) {
                    Label("Story", systemImage: "rectangle.portrait.and.arrow.forward")
                        .font(AppFont.button)
                }
                .buttonStyle(GhostButtonStyle())
                .disabled(true)
                .opacity(0.4)

                Spacer()

                // Save
                Button(action: onSave) {
                    Label("Save", systemImage: "square.and.arrow.down")
                        .font(AppFont.button)
                }
                .buttonStyle(GhostButtonStyle())
                .disabled(isSaving)
                .opacity(isSaving ? 0.5 : 1)

                Spacer()

                // Share (primary CTA)
                Button(action: onShare) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(AccentButtonStyle())
            }
            .padding(.horizontal, AppSpacing.md)
            .frame(maxHeight: .infinity)
        }
        .frame(height: Self.height)
        .background(AppColors.surfaceElevated)
    }
}
