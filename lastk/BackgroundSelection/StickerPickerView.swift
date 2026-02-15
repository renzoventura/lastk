//
//  StickerPickerView.swift
//  lastk
//
//  Modal sticker selection: 2-column grid, dismissible by tap outside or swipe down.
//

import SwiftUI

struct StickerPickerView: View {
    let options: [RunStickerOption]
    var onSelect: (RunStickerOption) -> Void
    var onDismiss: () -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2.5)
                .fill(.secondary.opacity(0.5))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 16)

            Text("Add Sticker")
                .font(.headline)
                .padding(.bottom, 16)

            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(options) { option in
                        Button {
                            onSelect(option)
                            onDismiss()
                        } label: {
                            Text(option.stickerText)
                                .font(.subheadline)
                                .bold()
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .background(.regularMaterial, in: .rect(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(.ultraThinMaterial)
    }
}
