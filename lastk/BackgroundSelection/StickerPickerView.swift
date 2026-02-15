//
//  StickerPickerView.swift
//  lastk
//
//  Modal sticker selection: 2-column grid, dark theme with card cells.
//

import SwiftUI

struct StickerPickerView: View {
    let options: [RunStickerOption]
    var onSelect: (RunStickerOption) -> Void
    var onDismiss: () -> Void

    private let columns = [
        GridItem(.flexible(), spacing: AppSpacing.sm),
        GridItem(.flexible(), spacing: AppSpacing.sm)
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Drag indicator
            RoundedRectangle(cornerRadius: 2.5)
                .fill(AppColors.textMuted)
                .frame(width: 36, height: 4)
                .padding(.top, AppSpacing.sm)
                .padding(.bottom, AppSpacing.md)

            Text("Add Sticker")
                .font(AppFont.sectionHeader)
                .foregroundStyle(AppColors.textPrimary)
                .padding(.bottom, AppSpacing.md)

            ScrollView {
                LazyVGrid(columns: columns, spacing: AppSpacing.sm) {
                    ForEach(options) { option in
                        Button {
                            onSelect(option)
                            onDismiss()
                        } label: {
                            VStack(spacing: AppSpacing.xs) {
                                Text(option.stickerText)
                                    .font(AppFont.secondary)
                                    .bold()
                                    .foregroundStyle(AppColors.textPrimary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)

                                Text(option.title)
                                    .font(AppFont.metadata)
                                    .foregroundStyle(AppColors.textMuted)
                            }
                            .padding(.horizontal, AppSpacing.md)
                            .padding(.vertical, AppSpacing.sm + 4)
                            .frame(maxWidth: .infinity)
                            .background(AppColors.card, in: .rect(cornerRadius: AppRadius.md))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, AppSpacing.md + 4)
                .padding(.bottom, AppSpacing.lg)
            }
            .scrollIndicators(.hidden)
        }
        .background(AppColors.surfaceElevated)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(AppColors.surfaceElevated)
    }
}
