//
//  OrderReviewSummaryCardView.swift
//  Medsy
//
//  Created by Antoneos Philip on 25/07/2026.
//

import SwiftUI

struct OrderReviewSummaryCardView: View {
    @Environment(LanguageManager.self) private var languageManager
    let medicinesSubtotal: Double
    let deliveryFee: Double
    let totalPrice: Double

    private func formatAmount(_ amount: Double) -> String {
        amount.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(amount))" : String(format: "%.2f", amount)
    }

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Text("\(formatAmount(medicinesSubtotal)) \("offers.list.currency".localized)")
                    .font(AppColor.sans(15, .bold))
                    .foregroundStyle(AppColor.textPrim)

                Spacer()

                Text("orderReview.summary.subtotal".localized)
                    .font(AppColor.sans(14))
                    .foregroundStyle(AppColor.textSec)
            }


            HStack {
                Text("\(formatAmount(totalPrice)) \("offers.list.currency".localized)")
                    .font(AppColor.sans(18, .bold))
                    .foregroundStyle(AppColor.green)

                Spacer()

                Text("orderReview.summary.total".localized)
                    .font(AppColor.sans(18, .bold))
                    .foregroundStyle(AppColor.textPrim)
            }
        }
        .environment(\.layoutDirection, languageManager.isRTL ? .rightToLeft : .leftToRight)
        .padding(.horizontal, 4)
        .padding(.vertical, 8)
    }
}
