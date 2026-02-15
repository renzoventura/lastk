//
//  RunStickerOption.swift
//  lastk
//
//  Dynamic sticker options derived from a selected run.
//  This is intentionally model-like so the picker UI stays generic.
//

import Foundation

/// A selectable sticker option shown in the sticker picker.
/// Selecting an option adds a `StickerItem` to the canvas.
struct RunStickerOption: Identifiable, Hashable {
    enum Kind: String, Hashable {
        case distance
        case pace
        case movingTime
        case location
        case date
        // Future: heartRate, cadence, splits, elevationGain, etc.
    }

    var id: Kind { kind }
    let kind: Kind
    /// Short label for the picker cell if we ever add subtitles.
    let title: String
    /// What will be rendered on-canvas when placed.
    let stickerText: String
}

extension RunFeedItem {
    /// Sticker options for this run, derived from real Strava data.
    var stickerOptions: [RunStickerOption] {
        var options: [RunStickerOption] = []

        let distanceText = "\(distanceKm.formatted(.number.precision(.fractionLength(2)))) km"
        options.append(.init(kind: .distance, title: "Distance", stickerText: distanceText))

        if let pacePerKmDisplay {
            options.append(.init(kind: .pace, title: "Pace", stickerText: "\(pacePerKmDisplay) /km"))
        }

        let movingDuration = Duration.seconds(movingTimeSeconds)
        let timeText = movingDuration.formatted(.time(pattern: .minuteSecond))
        options.append(.init(kind: .movingTime, title: "Time", stickerText: timeText))

        if let locationDisplay {
            options.append(.init(kind: .location, title: "Location", stickerText: locationDisplay))
        }

        options.append(.init(kind: .date, title: "Date", stickerText: dateDisplay))

        return options
    }
}

