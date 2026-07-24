//
//  MedicineAnalyzeResultsGuidance.swift
//  Medsy
//
//  Created by Ehab Salah on 23/07/2026.
//

import SwiftUI

struct MedicineAnalyzeResultsGuidance: View {
    var body: some View {
        VStack(alignment: .leading, spacing: MedsySpacing.sm) {
            Label(
                "medicineAnalyze.results.guidance.title".localized,
                systemImage: "lightbulb.fill"
            )
            .font(MedsyFont.button(14))
            .foregroundStyle(AppColor.green)

            Label(
                "medicineAnalyze.results.guidance.details".localized,
                systemImage: "hand.tap.fill"
            )
            .font(MedsyFont.caption(13))
            .foregroundStyle(AppColor.textSec)

            Label(
                "medicineAnalyze.results.guidance.cart".localized,
                systemImage: "cart.badge.plus"
            )
            .font(MedsyFont.caption(13))
            .foregroundStyle(AppColor.textSec)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(MedsySpacing.md)
        .background(AppColor.card, in: RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                .stroke(AppColor.green.opacity(0.25), lineWidth: 1)
        }
    }
}
