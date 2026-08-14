//
//  PrescriptionPreviewView.swift
//  Medsy
//
//  Created by Ehab Salah on 22/07/2026.
//

import SwiftUI
import UIKit

// MARK: - View

struct PrescriptionPreviewView: View {
    let imageData: Data?
    let isAttachmentOnly: Bool
    let isSubmitting: Bool
    let onContinue: () -> Void
    let onChangeImage: () -> Void
    let onDelete: () -> Void
    let onBack: () -> Void

    var body: some View {
        PrescriptionPage(title: "prescription.preview.title".localized, onBack: onBack) {
            VStack(spacing: MedsySpacing.lg) {
                prescriptionImage

                HStack(spacing: MedsySpacing.sm) {
                    Button(action: onChangeImage) {
                        Label("prescription.change".localized, systemImage: "arrow.clockwise")
                            .font(MedsyFont.button(14))
                            .foregroundStyle(AppColor.textPrim)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .overlay {
                                RoundedRectangle(cornerRadius: MedsyRadius.md, style: .continuous)
                                    .stroke(AppColor.border, lineWidth: 1)
                            }
                    }

                    Button(role: .destructive, action: onDelete) {
                        Label("common.delete".localized, systemImage: "trash")
                            .font(MedsyFont.button(14))
                            .foregroundStyle(AppColor.danger)
                            .frame(height: 44)
                            .padding(.horizontal, MedsySpacing.md)
                            .background(AppColor.danger.opacity(0.1))
                            .overlay {
                                RoundedRectangle(cornerRadius: MedsyRadius.md, style: .continuous)
                                    .stroke(AppColor.danger.opacity(0.35), lineWidth: 1)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.md, style: .continuous))
                    }
                }

                Spacer()

                PrimaryButton(
                    title: isAttachmentOnly
                        ? "prescription.attach_to_cart".localized
                        : "prescription.continue".localized,
                    isLoading: isSubmitting,
                    action: onContinue
                )
            }
            .padding()
        }
    }

    @ViewBuilder
    private var prescriptionImage: some View {
        if let imageData, let image = UIImage(data: imageData) {
            ZStack(alignment: .bottom) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 420)
                    .background(AppColor.card)

                HStack(spacing: MedsySpacing.xs) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 15, weight: .semibold))

                    Text("prescription.preview.selected".localized)
                        .font(MedsyFont.button(13))

                    Spacer()
                }
                .foregroundStyle(.white)
                .padding(.horizontal, MedsySpacing.md)
                .padding(.vertical, MedsySpacing.xs)
                .background(AppColor.green.opacity(0.9))
            }
            .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                    .stroke(AppColor.border)
            }
        } else {
            RoundedRectangle(cornerRadius: MedsyRadius.lg)
                .fill(AppColor.card)
                .frame(height: 310)
                .overlay {
                    Image(systemName: "doc.text.image")
                        .font(.system(size: 70))
                        .foregroundStyle(AppColor.green)
                }
        }
    }
}
