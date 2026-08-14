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
                    Text("cart.total_price".localized)
                        .font(MedsyFont.bodyMedium(15))
                        .foregroundStyle(AppColor.textSec)

                    Spacer()

                    Text(formattedPrice(estimatedTotal))
                        .font(MedsyFont.price(22))
                        .foregroundStyle(AppColor.textPrim)
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
