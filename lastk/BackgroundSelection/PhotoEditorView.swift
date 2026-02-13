//
//  PhotoEditorView.swift
//  lastk
//
//  Full-screen editor: zoom/pan canvas, Back, and bottom action bar (Story disabled, Save, Share).
//

import SwiftUI
import Photos
import UIKit

/// Wraps UIImage for use with .sheet(item:).
struct ShareableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

struct PhotoEditorView: View {
    let image: UIImage
    let onDismiss: () -> Void

    @State private var scaleMultiplier: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var stickers: [StickerItem] = []
    @State private var showStickerPicker = false
    @State private var isSaving = false
    @State private var saveSuccess = false
    @State private var shareItem: ShareableImage?
    @State private var exportCanvasSize: CGSize = CGSize(width: 390, height: 844)
    @Environment(\.displayScale) private var displayScale

    var body: some View {
        ZStack(alignment: .bottom) {
            canvasWithSizeCapture
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .bottom) {
                    floatingStickerButton
                        .padding(.bottom, 24)
                }
            bottomActionBar
        }
        .ignoresSafeArea(edges: .bottom)
        .background(.gray)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Back", systemImage: "chevron.left", action: onDismiss)
            }
        }
        .toolbarBackground(.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(item: $shareItem) { shareable in
            ShareSheetView(activityItems: [shareable.image])
                .onDisappear { shareItem = nil }
        }
        .sheet(isPresented: $showStickerPicker) {
            StickerPickerView(
                onSelect: { addSticker(option: $0) },
                onDismiss: { showStickerPicker = false }
            )
        }
        .overlay {
            if saveSuccess {
                saveSuccessOverlay
            }
        }
    }

    private var bottomActionBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 24) {
                Button("Story", systemImage: "square.and.arrow.up") {}
                    .disabled(true)
                    .foregroundStyle(.secondary)

                Button("Save", systemImage: "square.and.arrow.down") {
                    saveToPhotoLibrary()
                }
                .disabled(isSaving)

                Button("Share", systemImage: "square.and.arrow.up") {
                    exportAndShare()
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
        }
        .frame(minHeight: 72)
        .background(.black)
        .safeAreaPadding(.bottom, 8)
    }

    private var floatingStickerButton: some View {
        Button {
            showStickerPicker = true
        } label: {
            Image(systemName: "plus")
                .font(.title2)
                .bold()
                .foregroundStyle(.primary)
                .frame(width: 56, height: 56)
                .background(.ultraThinMaterial, in: .circle)
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    private var saveSuccessOverlay: some View {
        Text("Saved")
            .font(.subheadline)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.regularMaterial, in: .capsule)
            .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }

    private var canvasWithSizeCapture: some View {
        ZStack {
            ZoomableImageCanvas(
                image: image,
                scaleMultiplier: $scaleMultiplier,
                offset: $offset
            )
            if exportCanvasSize.width > 0, exportCanvasSize.height > 0 {
                stickerOverlayLayer(canvasSize: exportCanvasSize)
            }
        }
        .background(
            GeometryReader { geometry in
                Color.clear
                    .onChange(of: geometry.size) { _, newSize in
                        exportCanvasSize = newSize
                    }
                    .onAppear { exportCanvasSize = geometry.size }
            }
        )
    }

    private func stickerOverlayLayer(canvasSize: CGSize) -> some View {
        ZStack {
            Color.clear
                .frame(width: canvasSize.width, height: canvasSize.height)
                .allowsHitTesting(false)
            ForEach(stickers) { sticker in
                StickerOverlayView(
                    sticker: sticker,
                    canvasSize: canvasSize,
                    onUpdate: { newPosition, newScale in
                        updateSticker(id: sticker.id, position: newPosition, scale: newScale)
                    }
                )
            }
        }
    }

    private func addSticker(option: StickerOption) {
        let center = CGPoint(x: exportCanvasSize.width / 2, y: exportCanvasSize.height / 2)
        let sticker = StickerItem(text: option.displayText, position: center, scale: 1)
        stickers.append(sticker)
    }

    private func updateSticker(id: UUID, position: CGPoint, scale: CGFloat) {
        guard let index = stickers.firstIndex(where: { $0.id == id }) else { return }
        stickers[index].position = position
        stickers[index].scale = scale
    }

    private func exportImage() -> UIImage? {
        let content = ExportCanvasContent(
            image: image,
            scale: scaleMultiplier,
            offset: offset,
            stickers: stickers,
            canvasSize: exportCanvasSize
        )
        let renderer = ImageRenderer(content: content)
        renderer.scale = displayScale
        return renderer.uiImage
    }

    private func saveToPhotoLibrary() {
        guard let rendered = exportImage() else { return }
        isSaving = true
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            Task { @MainActor in
                defer { isSaving = false }
                guard status == .authorized || status == .limited else { return }
                guard let imageData = rendered.jpegData(compressionQuality: 1) else { return }
                PHPhotoLibrary.shared().performChanges {
                    let request = PHAssetCreationRequest.forAsset()
                    request.addResource(with: .photo, data: imageData, options: nil)
                } completionHandler: { success, _ in
                    Task { @MainActor in
                        if success {
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                            withAnimation(.easeOut(duration: 0.2)) { saveSuccess = true }
                            Task {
                                try? await Task.sleep(for: .seconds(1.5))
                                withAnimation { saveSuccess = false }
                            }
                        }
                    }
                }
            }
        }
    }

    private func exportAndShare() {
        guard let rendered = exportImage() else { return }
        shareItem = ShareableImage(image: rendered)
    }
}

/// Wraps UIActivityViewController for sharing.
struct ShareSheetView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        PhotoEditorView(
            image: UIImage(systemName: "photo")!,
            onDismiss: {}
        )
    }
}
