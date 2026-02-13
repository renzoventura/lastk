//
//  AppleMapRouteImageView.swift
//  lastk
//
//  Renders a static map image of a route using MapKit (MKMapSnapshotter).
//  Decodes the Strava summary_polyline, fits the map to the route with padding, draws the route on the snapshot.
//  If polyline is nil or empty, shows a placeholder. Images are generated asynchronously and cached per view.
//

import MapKit
import SwiftUI
import UIKit

struct AppleMapRouteImageView: View {
    let polyline: String?

    var body: some View {
        Group {
            if let polyline, !polyline.isEmpty {
                AppleMapRouteImageContent(polyline: polyline)
            } else {
                routePlaceholder
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .clipped()
    }

    private var routePlaceholder: some View {
        Image(systemName: "map")
            .font(.title2)
            .foregroundStyle(.tertiary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct AppleMapRouteImageContent: View {
    let polyline: String?
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task(id: polyline) {
            guard let polyline else { return }
            let coords = PolylineDecoder.decode(polyline)
            guard !coords.isEmpty else { return }
            let size = CGSize(width: 400, height: 400)
            let snapshotImage = await makeSnapshot(coordinates: coords, size: size)
            await MainActor.run { image = snapshotImage }
        }
    }

    /// Uses MKMapSnapshotter to capture a map region that fits the route, then draws a minimal dark overlay and orange polyline.
    private func makeSnapshot(coordinates: [CLLocationCoordinate2D], size: CGSize) async -> UIImage? {
        let region = regionThatFits(coordinates: coordinates)
        let options = MKMapSnapshotter.Options()
        options.region = region
        options.size = size
        options.scale = 0
//        options.mapType = .standard
        options.mapType = .mutedStandard
        let snapshotter = MKMapSnapshotter(options: options)
        return await withCheckedContinuation { continuation in
            snapshotter.start { snapshot, error in
                guard let snapshot else {
                    continuation.resume(returning: nil)
                    return
                }
                let image = drawDarkMinimalWithPolyline(on: snapshot, coordinates: coordinates)
                continuation.resume(returning: image)
            }
        }
    }

    private func regionThatFits(coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        guard !coordinates.isEmpty else {
            return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        }
        var minLat = coordinates[0].latitude
        var maxLat = minLat
        var minLng = coordinates[0].longitude
        var maxLng = minLng
        for c in coordinates.dropFirst() {
            minLat = min(minLat, c.latitude)
            maxLat = max(maxLat, c.latitude)
            minLng = min(minLng, c.longitude)
            maxLng = max(maxLng, c.longitude)
        }
        let padding = 0.01
        let span = MKCoordinateSpan(
            latitudeDelta: max(maxLat - minLat, padding) * 1.2,
            longitudeDelta: max(maxLng - minLng, padding) * 1.2
        )
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLng + maxLng) / 2
        )
        return MKCoordinateRegion(center: center, span: span)
    }

    /// Draws the map snapshot, a dark overlay for minimal black/grey tones, then the route in orange.
    private func drawDarkMinimalWithPolyline(on snapshot: MKMapSnapshotter.Snapshot, coordinates: [CLLocationCoordinate2D]) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: snapshot.image.size)
        return renderer.image { context in
            snapshot.image.draw(at: .zero)
            let rect = CGRect(origin: .zero, size: snapshot.image.size)
            context.cgContext.setFillColor(CGColor(red: 0.1, green: 0.1, blue: 0.12, alpha: 0.4))
            context.cgContext.fill(rect)
            guard coordinates.count >= 2 else { return }
            let points = coordinates.map { snapshot.point(for: $0) }
            context.cgContext.setStrokeColor(CGColor(red: 1, green: 0.45, blue: 0, alpha: 1))
            context.cgContext.setLineWidth(3)
            context.cgContext.setLineCap(.round)
            context.cgContext.setLineJoin(.round)
            context.cgContext.addLines(between: points)
            context.cgContext.strokePath()
        }
    }
}
