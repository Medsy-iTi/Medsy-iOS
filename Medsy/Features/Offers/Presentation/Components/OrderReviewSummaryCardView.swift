//  OrderReviewSummaryCardView.swift
//  Medsy
//
//  Created by Antoneos Philip on 22/07/2026.

import SwiftUI

struct OrderReviewSummaryCardView: View {
    @Environment(LanguageManager.self) private var languageManager
    let medicinesSubtotal: Int
    let deliveryFee: Int
    let totalPrice: Int

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Text("\(medicinesSubtotal) \("offers.list.currency".localized)")
                    .font(AppColor.sans(15, .bold))
                    .foregroundStyle(AppColor.textPrim)

                Spacer()

                Text("orderReview.summary.subtotal".localized)
                    .font(AppColor.sans(14))
                    .foregroundStyle(AppColor.textSec)
            }

            HStack {
                Text("\(deliveryFee) \("offers.list.currency".localized)")
                    .font(AppColor.sans(15, .bold))
                    .foregroundStyle(AppColor.textPrim)

                Spacer()

                Text("orderReview.summary.deliveryFee".localized)
                    .font(AppColor.sans(14))
                    .foregroundStyle(AppColor.textSec)
            }

            HStack {
                Text("\(totalPrice) \("offers.list.currency".localized)")
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
