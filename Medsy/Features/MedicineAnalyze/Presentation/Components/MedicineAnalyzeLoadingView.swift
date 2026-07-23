//
//  MedicineAnalyzeLoadingView.swift
//  Medsy
//
//  Created by Ehab Salah on 23/07/2026.
//

import SwiftUI

struct MedicineAnalyzeLoadingView: View {
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: MedsySpacing.xl) {
            ZStack {
                Circle()
                    .fill(AppColor.lightGreen.opacity(0.7))
                    .frame(width: 112, height: 112)

                Image(systemName: "pills.fill")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(AppColor.green)
            }

            ProgressView()
                .controlSize(.large)
                .tint(AppColor.green)

            VStack(spacing: MedsySpacing.xs) {
                Text("medicineAnalyze.loading.title".localized)
                    .font(MedsyFont.title(20))
                    .foregroundStyle(AppColor.textPrim)

                Text("medicineAnalyze.loading.message".localized)
                    .font(MedsyFont.body(14))
                    .foregroundStyle(AppColor.textSec)
                    .multilineTextAlignment(.center)
            }

            Button("common.cancel".localized, action: onCancel)
                .font(MedsyFont.button(14))
                .foregroundStyle(AppColor.green)
        }
        .padding(.horizontal, MedsySpacing.xl)
        .padding(.top, 64)
    }
}
