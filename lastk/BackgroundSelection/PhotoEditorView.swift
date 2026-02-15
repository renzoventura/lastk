//
//  PhotoEditorView.swift
//  lastk
//
//  Composition root for the photo editor screen.
//
//  Layer order (back → front):
//    1. Safe area management  – handled by the root layout
//    2. EditingCanvasView     – zoomable image + stickers
//    3. EditorBottomActionView – fixed bottom controls
//    4. EditorOverlayButtons  – floating close & add-sticker buttons
//

import SwiftUI
import Photos
import UIKit

// MARK: - Shareable wrapper

/// Wraps UIImage for use with `.sheet(item:)`.
struct ShareableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

// MARK: - PhotoEditorView

struct PhotoEditorView: View {
    let image: UIImage
    let onDismiss: () -> Void

    // MARK: Canvas state

    @State private var scaleMultiplier: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var stickers: [StickerItem] = []
    @State private var canvasSize: CGSize = .zero

    // MARK: UI state

    @State private var showStickerPicker = false
    @State private var isSaving = false
    @State private var saveSuccess = false
    @State private var shareItem: ShareableImage?

    @Environment(\.displayScale) private var displayScale

    // MARK: Body

    var body: some View {
        // Layer 1: Safe area management
        // The VStack lives inside the safe area; the background bleeds edge-to-edge.
        VStack(spacing: 0) {
            // Layer 2: Editing canvas – fills all space above the bottom bar
            EditingCanvasView(
                image: image,
                scaleMultiplier: $scaleMultiplier,
                offset: $offset,
                stickers: stickers,
                onStickerUpdate: { id, position, scale in
                    updateSticker(id: id, position: position, scale: scale)
                },
                onCanvasSizeChange: { newSize in
                    canvasSize = newSize
                }
            )

            // Layer 3: Fixed bottom controls
            EditorBottomActionView(
                isSaving: isSaving,
                onShare: { exportAndShare() },
                onSave: { saveToPhotoLibrary() },
                onStory: {}
            )
        }
        .background {
            Color.black.ignoresSafeArea()
        }
        // Layer 4: Floating overlay buttons
        .overlay {
            EditorOverlayButtons(
                bottomBarHeight: EditorBottomActionView.height,
                onClose: onDismiss,
                onAddSticker: { showStickerPicker = true }
            )
        }
        // Feedback overlay
        .overlay {
            if saveSuccess {
                savedFeedbackBadge
            }
        }
        // Navigation
        .toolbar(.hidden, for: .navigationBar)
        // Sheets
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
    }

    // MARK: - Sub-views

    private var savedFeedbackBadge: some View {
        Text("Saved")
            .font(.subheadline)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.regularMaterial, in: .capsule)
            .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }

    // MARK: - Sticker management

    private func addSticker(option: StickerOption) {
        let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
        stickers.append(StickerItem(text: option.displayText, position: center))
    }

    private func updateSticker(id: UUID, position: CGPoint, scale: CGFloat) {
        guard let index = stickers.firstIndex(where: { $0.id == id }) else { return }
        stickers[index].position = position
        stickers[index].scale = scale
    }

    // MARK: - Export

    private func exportImage() -> UIImage? {
        guard canvasSize.width > 0, canvasSize.height > 0 else { return nil }
        let content = ExportCanvasContent(
            image: image,
            scale: scaleMultiplier,
            offset: offset,
            stickers: stickers,
            canvasSize: canvasSize
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

// MARK: - Share sheet

/// Wraps UIActivityViewController for sharing.
struct ShareSheetView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PhotoEditorView(
            image: UIImage(systemName: "photo")!,
            onDismiss: {}
        )
    }
}
