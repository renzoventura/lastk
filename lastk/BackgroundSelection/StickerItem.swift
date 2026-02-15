//
//  StickerItem.swift
//  lastk
//
//  Model for a sticker overlay on the photo canvas. Holds content, transform, and font style.
//

import CoreGraphics
import SwiftUI

/// Available font styles for stickers.
enum StickerFontStyle: String, Equatable, Hashable, CaseIterable {
    /// System default (SF Pro, subheadline bold)
    case system
    /// Humane Bold — tall condensed display font
    case humane
    /// ROUND8-FOUR — rounded display font
    case round8

    /// The SwiftUI Font to use for rendering this style.
    var font: Font {
        switch self {
        case .system:
            return .subheadline.bold()
        case .humane:
            return .custom("Humane-Bold", size: 28)
        case .round8:
            return .custom("ROUND8-FOUR", size: 20)
        }
    }

    /// Display name in the picker.
    var displayName: String {
        switch self {
        case .system: return "Default"
        case .humane: return "Humane"
        case .round8: return "Round 8"
        }
    }
}

struct StickerItem: Identifiable, Equatable {
    let id: UUID
    /// Display text (e.g. "5.42 KM", "San Francisco").
    var text: String
    /// Center position in canvas coordinates.
    var position: CGPoint
    /// Scale factor (1 = default size).
    var scale: CGFloat
    /// Font style for rendering.
    var fontStyle: StickerFontStyle

    init(
        id: UUID = UUID(),
        text: String,
        position: CGPoint,
        scale: CGFloat = 1,
        fontStyle: StickerFontStyle = .system
    ) {
        self.id = id
        self.text = text
        self.position = position
        self.scale = scale
        self.fontStyle = fontStyle
    }
}
