//
//  MedicineAnalyzeImagePreview.swift
//  Medsy
//
//  Created by Ehab Salah on 23/07/2026.
//

import SwiftUI
import UIKit

struct MedicineAnalyzeImagePreview: View {
    let imageData: Data
    let onChangeImage: () -> Void
    let onAnalyze: () -> Void

    var body: some View {
        VStack(spacing: MedsySpacing.lg) {
            VStack(spacing: MedsySpacing.xs) {
                Text("medicineAnalyze.preview.heading".localized)
                    .font(MedsyFont.title(20))
                    .foregroundStyle(AppColor.textPrim)

                Text("medicineAnalyze.preview.message".localized)
                    .font(MedsyFont.body(14))
                    .foregroundStyle(AppColor.textSec)
                    .multilineTextAlignment(.center)
            }

            previewImage

            Button("medicineAnalyze.changeImage".localized, action: onChangeImage)
                .font(MedsyFont.button(14))
                .foregroundStyle(AppColor.green)

            Spacer()

            PrimaryButton(
                title: "medicineAnalyze.analyze".localized,
                action: onAnalyze
            )
        }
        .padding(MedsySpacing.md)
    }

    @ViewBuilder
    private var previewImage: some View {
        if let image = UIImage(data: imageData) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: 430)
                .background(AppColor.card)
                .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                        .stroke(AppColor.border, lineWidth: 1)
                )
        }
    }
}
