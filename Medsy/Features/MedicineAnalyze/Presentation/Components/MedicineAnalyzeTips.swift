//
//  MedicineAnalyzeTips.swift
//  Medsy
//
//  Created by Ehab Salah on 23/07/2026.
//

import SwiftUI

struct MedicineAnalyzeTips: View {
    var body: some View {
        VStack(alignment: .leading, spacing: MedsySpacing.sm) {
            Label("medicineAnalyze.tips.title".localized, systemImage: "lightbulb.fill")
                .font(MedsyFont.button(14))
                .foregroundStyle(AppColor.green)

            MedicineAnalyzeTipRow(text: "medicineAnalyze.tips.clear".localized)
            MedicineAnalyzeTipRow(text: "medicineAnalyze.tips.single".localized)
            MedicineAnalyzeTipRow(text: "medicineAnalyze.tips.light".localized)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(MedsySpacing.md)
        .background(AppColor.pill, in: RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                .stroke(AppColor.warningBorder, lineWidth: 1)
        )
    }
}
