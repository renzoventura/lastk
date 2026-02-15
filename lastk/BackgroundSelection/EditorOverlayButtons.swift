//
//  EditorOverlayButtons.swift
//  lastk
//
//  Layer 4: Floating overlay buttons that sit above all other content.
//  Contains the close button (top-left) and the add-sticker button (bottom-center).
//

import SwiftUI

/// Floating buttons rendered as an overlay above the canvas and bottom bar.
///
/// Responsibilities:
/// - Close button: top-leading, respects safe area, dismisses the editor.
/// - Add sticker button: bottom-center, floats above the bottom action bar.
/// - Neither button is part of the canvas or the bottom bar structurally.
struct EditorOverlayButtons: View {
    let bottomBarHeight: CGFloat
    let onClose: () -> Void
    let onAddSticker: () -> Void

    var body: some View {
        ZStack {
            // Pass-through background so only the buttons receive taps
            Color.clear
                .allowsHitTesting(false)

            // Close button: top-leading
            closeButton
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .safeAreaPadding(.top)
                .padding(.leading)

            // Add sticker button: bottom-center, above bottom bar
            addStickerButton
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, bottomBarHeight + 16)
        }
    }

    private var closeButton: some View {
        Button("Close", systemImage: "xmark", action: onClose)
            .font(.body)
            .bold()
            .foregroundStyle(.white)
            .frame(width: 36, height: 36)
            .background(.ultraThinMaterial, in: .circle)
    }

    private var addStickerButton: some View {
        Button("Add sticker", systemImage: "plus", action: onAddSticker)
            .labelStyle(.iconOnly)
            .font(.title2)
            .bold()
            .foregroundStyle(.primary)
            .frame(width: 56, height: 56)
            .background(.ultraThinMaterial, in: .circle)
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}
