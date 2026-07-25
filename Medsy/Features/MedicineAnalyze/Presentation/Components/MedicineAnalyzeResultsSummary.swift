//
//  MedicineAnalyzeResultsSummary.swift
//  Medsy
//
//  Created by Ehab Salah on 23/07/2026.
//

import SwiftUI

struct MedicineAnalyzeResultsSummary: View {
    let imageData: Data?
    let matchCount: Int

    var body: some View {
        HStack(spacing: MedsySpacing.md) {
            MedicineAnalyzeCapturedImage(imageData: imageData)

            VStack(alignment: .leading, spacing: MedsySpacing.xxs) {
                Label(
                    "medicineAnalyze.results.recognized".localized,
                    systemImage: "sparkles"
                )
                .font(MedsyFont.caption(12).weight(.semibold))
                .foregroundStyle(AppColor.green)

                Text("medicineAnalyze.results.count".localized(matchCount))
                    .font(MedsyFont.title(17))
                    .foregroundStyle(AppColor.textPrim)

                Text("medicineAnalyze.results.message".localized)
                    .font(MedsyFont.caption(12))
                    .foregroundStyle(AppColor.textSec)
            }

            Spacer(minLength: 0)
        }
        .padding(MedsySpacing.md)
        .background(AppColor.card, in: RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                .stroke(AppColor.green.opacity(0.3), lineWidth: 1)
        }
    }
}
