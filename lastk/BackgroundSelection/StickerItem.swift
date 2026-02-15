//
//  StickerItem.swift
//  lastk
//
//  Model for a sticker overlay on the photo canvas. Holds content and transform (position, scale).
//

import CoreGraphics
import SwiftUI

struct StickerItem: Identifiable, Equatable {
    let id: UUID
    /// Display text (e.g. "5.42 KM", "San Francisco").
    var text: String
    /// Center position in canvas coordinates.
    var position: CGPoint
    /// Scale factor (1 = default size).
    var scale: CGFloat

    init(id: UUID = UUID(), text: String, position: CGPoint, scale: CGFloat = 1) {
        self.id = id
        self.text = text
        self.position = position
        self.scale = scale
    }
}
