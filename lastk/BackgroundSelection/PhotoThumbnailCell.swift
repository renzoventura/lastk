//
//  PhotoThumbnailCell.swift
//  lastk
//
//  Single cell in the camera roll grid; loads thumbnail asynchronously.
//

import SwiftUI

struct PhotoThumbnailCell: View {
    let assetId: String
    let photoService: PhotoLibraryService
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
            } else {
                Rectangle()
                    .fill(.quaternary)
                    .aspectRatio(1, contentMode: .fill)
                    .overlay { ProgressView() }
            }
        }
        .clipped()
        .task(id: assetId) {
            image = await photoService.loadThumbnail(for: assetId)
        }
    }
}
