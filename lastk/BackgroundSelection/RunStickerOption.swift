//
//  RunStickerOption.swift
//  lastk
//
//  Dynamic sticker options derived from a selected run.
//  Each option can carry a specific font style for rendering.
//

import Foundation

/// A selectable sticker option shown in the sticker picker.
struct RunStickerOption: Identifiable, Hashable {
    enum Kind: String, Hashable {
        case distance
        case pace
        case movingTime
        case location
        case date
        // Future: heartRate, cadence, splits, elevationGain, etc.
    }

    /// Unique id combining kind + font style so the same metric in different fonts are distinct.
    var id: String { "\(kind.rawValue)-\(fontStyle.rawValue)" }
    let kind: Kind
    /// Short label for the picker cell subtitle.
    let title: String
    /// What will be rendered on-canvas when placed.
    let stickerText: String
    /// Font style for this sticker option.
    let fontStyle: StickerFontStyle
}

extension RunFeedItem {
    /// Sticker options for this run, derived from real Strava data.
    /// Includes the default system font options plus font-styled distance variants.
    var stickerOptions: [RunStickerOption] {
        var options: [RunStickerOption] = []

        let distanceText = "\(distanceKm.formatted(.number.precision(.fractionLength(2)))) km"

        // Default system-font stickers
        options.append(.init(kind: .distance, title: "Distance", stickerText: distanceText, fontStyle: .system))

        if let pacePerKmDisplay {
            options.append(.init(kind: .pace, title: "Pace", stickerText: "\(pacePerKmDisplay) /km", fontStyle: .system))
        }

        let movingDuration = Duration.seconds(movingTimeSeconds)
        let timeText = movingDuration.formatted(.time(pattern: .minuteSecond))
        options.append(.init(kind: .movingTime, title: "Time", stickerText: timeText, fontStyle: .system))

        if let locationDisplay {
            options.append(.init(kind: .location, title: "Location", stickerText: locationDisplay, fontStyle: .system))
        }

        options.append(.init(kind: .date, title: "Date", stickerText: dateDisplay, fontStyle: .system))

        // Font-styled distance variants
        options.append(.init(kind: .distance, title: "Distance · Humane", stickerText: distanceText, fontStyle: .humane))
        options.append(.init(kind: .distance, title: "Distance · Round 8", stickerText: distanceText, fontStyle: .round8))

        return options
    }
}
