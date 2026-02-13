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

/// Mock sticker options for the picker. Can later be driven by run card data.
enum StickerOption: String, CaseIterable, Identifiable {
    case distance = "5.42 KM"
    case location = "San Francisco"
    case pace = "5:17 /km"
    case elevation = "120 m"
    case time = "32:04"
    case distanceBadge = "42 KM"
    case styledStat = "10K"

    var id: String { rawValue }

    var displayText: String { rawValue }
}
