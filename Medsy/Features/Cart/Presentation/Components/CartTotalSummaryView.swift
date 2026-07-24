//
//  CartTotalSummaryView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 18/07/2026.
//

import SwiftUI

struct CartTotalSummaryView: View {
    let estimatedTotal: Double
    let canContinue: Bool
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: MedsySpacing.md) {
            VStack(spacing: MedsySpacing.sm) {
                HStack {
                    Text("cart.estimated_total".localized)
                        .font(MedsyFont.bodyMedium(15))
                        .foregroundStyle(AppColor.textSec)

                    Spacer()

                    Text(formattedPrice(estimatedTotal))
                        .font(MedsyFont.price(22))
                        .foregroundStyle(AppColor.textPrim)
                }

                HStack(alignment: .top, spacing: MedsySpacing.xs) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppColor.warningYellow)

                    Text("cart.estimated_total_disclaimer".localized)
                        .font(MedsyFont.caption(12))
                        .foregroundStyle(AppColor.textSec)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(MedsySpacing.md)
            .background(AppColor.card)
            .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                    .stroke(AppColor.border, lineWidth: 1)
            )

            PrimaryButton(
                title: "cart.continue".localized,
                systemImage: "arrow.forward",
                isDisabled: !canContinue,
                action: onContinue
            )
        }
    }

    private func formattedPrice(_ value: Double) -> String {
        String(format: "%.2f %@", value, "cart.currency".localized)
    }
}
