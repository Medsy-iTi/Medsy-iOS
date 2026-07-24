//
//  MedicineAnalyzeFailureView.swift
//  Medsy
//
//  Created by Ehab Salah on 23/07/2026.
//

import SwiftUI

struct MedicineAnalyzeFailureView: View {
    let message: String
    let onRetry: () -> Void
    let onChangeImage: () -> Void

    var body: some View {
        VStack(spacing: MedsySpacing.lg) {
            Spacer()

            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(AppColor.danger)
                .frame(width: 104, height: 104)
                .background(AppColor.danger.opacity(0.12), in: Circle())

            VStack(spacing: MedsySpacing.xs) {
                Text("medicineAnalyze.failure.title".localized)
                    .font(MedsyFont.title(20))
                    .foregroundStyle(AppColor.textPrim)

                Text(message)
                    .font(MedsyFont.body(14))
                    .foregroundStyle(AppColor.textSec)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: MedsySpacing.sm) {
                PrimaryButton(
                    title: "error.retry".localized,
                    action: onRetry
                )

                Button("medicineAnalyze.changeImage".localized, action: onChangeImage)
                    .font(MedsyFont.button(14))
                    .foregroundStyle(AppColor.green)
            }

            Spacer()
        }
        .padding(.horizontal, MedsySpacing.xl)
    }
}
