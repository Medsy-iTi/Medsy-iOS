//
//  MedicineAnalyzeImagePreview.swift
//  Medsy
//
//  Created by Ehab Salah on 23/07/2026.
//

import SwiftUI

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

            MedicineAnalyzePreviewImage(imageData: imageData)

            Button(action: onChangeImage) {
                Label(
                    "medicineAnalyze.changeImage".localized,
                    systemImage: "arrow.trianglehead.2.clockwise.rotate.90"
                )
                .font(MedsyFont.button(14))
                .foregroundStyle(AppColor.green)
                .frame(height: 40)
                .padding(.horizontal, MedsySpacing.md)
                .background(AppColor.lightGreen.opacity(0.55), in: Capsule())
            }
            .buttonStyle(.plain)

            Spacer()

            PrimaryButton(
                title: "medicineAnalyze.analyze".localized,
                action: onAnalyze
            )
        }
        .padding(MedsySpacing.md)
    }
}
