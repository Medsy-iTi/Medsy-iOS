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
    let onContinue: () -> Void
    let onChangeImage: () -> Void
    let onDelete: () -> Void
    let onBack: () -> Void

    var body: some View {
        PrescriptionPage(title: "prescription.preview.title".localized, onBack: onBack) {
            VStack(spacing: MedsySpacing.lg) {
                prescriptionImage

                HStack {
                    Button("prescription.change".localized, action: onChangeImage)
                    Spacer()
                    Button("common.delete".localized, role: .destructive, action: onDelete)
                }
                .font(.body.weight(.semibold))

                Spacer()

                PrimaryButton(title: "prescription.continue".localized, action: onContinue)
            }
            .padding()
        }
    }

    @ViewBuilder
    private var prescriptionImage: some View {
        if let imageData, let image = UIImage(data: imageData) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: 420)
                .background(AppColor.card)
                .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg))
                .overlay(
                    RoundedRectangle(cornerRadius: MedsyRadius.lg)
                        .stroke(AppColor.border)
                )
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
