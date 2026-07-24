//
//  MedicineAnalyzeEmptyView.swift
//  Medsy
//
//  Created by Ehab Salah on 23/07/2026.
//

import SwiftUI

struct MedicineAnalyzeEmptyView: View {
    let onRetry: () -> Void
    let onChangeImage: () -> Void

    var body: some View {
        VStack(spacing: MedsySpacing.lg) {
            Spacer()

            Image(systemName: "pills.circle")
                .font(.system(size: 48, weight: .semibold))
                .foregroundStyle(AppColor.green)
                .frame(width: 104, height: 104)
                .background(AppColor.lightGreen.opacity(0.7), in: Circle())

            VStack(spacing: MedsySpacing.xs) {
                Text("medicineAnalyze.empty.title".localized)
                    .font(MedsyFont.title(20))
                    .foregroundStyle(AppColor.textPrim)

                Text("medicineAnalyze.empty.message".localized)
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
