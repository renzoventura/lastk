//
//  RunFeedItem.swift
//  lastk
//
//  Display model for a single run in the feed (distance, pace, date, optional route polyline for Apple Maps).
//

import Foundation

struct RunFeedItem: Identifiable, Hashable {
    let id: Int
    /// Distance in kilometers, 2 decimal places for display.
    let distanceKm: Double
    /// Pace string per km, e.g. "5:17"; nil if distance or moving time is zero.
    let pacePerKmDisplay: String?
    /// Activity date formatted for display (e.g. "Jan 15, 2024").
    let dateDisplay: String
    /// Strava map.summary_polyline for route; nil if none. Used by AppleMapRouteImageView to draw the route.
    let polyline: String?

    init(id: Int, distanceKm: Double, pacePerKmDisplay: String?, dateDisplay: String, polyline: String?) {
        self.id = id
        self.distanceKm = distanceKm
        self.pacePerKmDisplay = pacePerKmDisplay
        self.dateDisplay = dateDisplay
        self.polyline = polyline
    }
}

extension RunFeedItem {
    /// Builds a feed item from a Strava activity summary. Only use for type == "Run".
    init(activity: StravaActivitySummary) {
        id = activity.id
        distanceKm = (activity.distance / 1000).rounded(toPlaces: 2)
        pacePerKmDisplay = Self.formatPacePerKm(movingTimeSeconds: activity.movingTime, distanceMeters: activity.distance)
        dateDisplay = Self.formatActivityDate(activity.startDate)
        polyline = activity.map?.summaryPolyline
    }

    private static func formatActivityDate(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .omitted)
    }

    /// Returns "M:SS" per km, or nil if pace cannot be computed.
    private static func formatPacePerKm(movingTimeSeconds: Int, distanceMeters: Double) -> String? {
        guard distanceMeters > 0, movingTimeSeconds > 0 else { return nil }
        let distanceKm = distanceMeters / 1000
        let secondsPerKm = Double(movingTimeSeconds) / distanceKm
        let totalSeconds = Int(secondsPerKm.rounded())
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

private extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
