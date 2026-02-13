//
//  RunCardView.swift
//  lastk
//
//  Single run card: 1:1 map fills the card; distance/pace and date stacked at top-left over the map.
//

import SwiftUI

struct RunCardView: View {
    let item: RunFeedItem

    private var distanceAndPaceText: String {
        let distance = "\(item.distanceKm.formatted(.number.precision(.fractionLength(2)))) km"
        guard let pace = item.pacePerKmDisplay else { return distance }
        return "\(distance) @ \(pace)/km"
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            AppleMapRouteImageView(polyline: item.polyline)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack(alignment: .leading, spacing: 2) {
                Text(distanceAndPaceText)
                    .bold()
//                    .font(.caption)
                    .font(.system(size: 8))
                Text(item.dateDisplay)
//                    .font(.caption2)
                    .font(.system(size: 6))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .padding(8)
            .glassEffect(in: .rect(cornerRadius: 6))
            .opacity(0.5)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    RunCardView(
        item: RunFeedItem(
            id: 1,
            distanceKm: 5.42,
            pacePerKmDisplay: "5:17",
            dateDisplay: "Jan 15, 2024",
            polyline: nil
        )
    )
    .frame(width: 160, height: 160)
}
