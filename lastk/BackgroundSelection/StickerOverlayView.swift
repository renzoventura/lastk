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
    private let nominalSize = CGSize(width: 160, height: 60)

    @State private var dragOffset: CGSize = .zero
    @State private var scaleAtPinchStart: CGFloat?

    var body: some View {
        let effectivePosition = CGPoint(
            x: sticker.position.x + dragOffset.width,
            y: sticker.position.y + dragOffset.height
        )
        let effectiveScale = sticker.scale
        let clampedPosition = clampPosition(effectivePosition, scale: effectiveScale)

        StickerLayoutRouter(layoutType: sticker.layoutType, data: sticker.data)
            .fixedSize()
            .scaleEffect(effectiveScale)
            .position(clampedPosition)
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
                        let newPosition = clampPosition(effectivePosition, scale: sticker.scale)
                        onUpdate(newPosition, sticker.scale)
                        dragOffset = .zero
                    }
            )
    }

    private func clampPosition(_ center: CGPoint, scale: CGFloat) -> CGPoint {
        let w = nominalSize.width * scale / 2
        let h = nominalSize.height * scale / 2
        let minX = w
        let maxX = canvasSize.width - w
        let minY = h
        let maxY = canvasSize.height - h
        return CGPoint(
            x: center.x.clamped(to: minX...maxX),
            y: center.y.clamped(to: minY...maxY)
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
