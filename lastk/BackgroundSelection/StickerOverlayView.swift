//
//  StickerOverlayView.swift
//  lastk
//
//  Renders one sticker on the canvas with drag (reposition) and pinch (resize).
//  Routes to the appropriate layout view via StickerLayoutRouter.
//

import SwiftUI

struct StickerOverlayView: View {
    let sticker: StickerItem
    let canvasSize: CGSize
    let onUpdate: (CGPoint, CGFloat) -> Void

    private let minScale: CGFloat = 0.4
    private let maxScale: CGFloat = 3

    @State private var dragOffset: CGSize = .zero
    @State private var scaleAtPinchStart: CGFloat?

    var body: some View {
        let effectivePosition = CGPoint(
            x: sticker.position.x + dragOffset.width,
            y: sticker.position.y + dragOffset.height
        )

        StickerLayoutRouter(layoutType: sticker.layoutType, data: sticker.data)
            .fixedSize()
            .scaleEffect(sticker.scale)
            .position(effectivePosition)
            .highPriorityGesture(
                MagnificationGesture()
                    .onChanged { value in
                        if scaleAtPinchStart == nil {
                            scaleAtPinchStart = sticker.scale
                        }
                        let newScale = (scaleAtPinchStart ?? sticker.scale) * value
                        onUpdate(sticker.position, newScale.clamped(to: minScale...maxScale))
                    }
                    .onEnded { _ in
                        scaleAtPinchStart = nil
                    }
            )
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation
                    }
                    .onEnded { _ in
                        onUpdate(effectivePosition, sticker.scale)
                        dragOffset = .zero
                    }
            )
    }
}

private extension CGFloat {
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}

/// Renders a single sticker for export (no gestures). Same visual as StickerOverlayView.
struct StickerDrawingView: View {
    let sticker: StickerItem

    var body: some View {
        StickerLayoutRouter(layoutType: sticker.layoutType, data: sticker.data)
            .fixedSize()
            .scaleEffect(sticker.scale)
            .position(sticker.position)
    }
}
