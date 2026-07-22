//  OrderReviewDeliveryDetailsCardView.swift
//  Medsy
//
//  Created by Antoneos Philip on 22/07/2026.

import SwiftUI

struct OrderReviewDeliveryDetailsCardView: View {
    @Environment(LanguageManager.self) private var languageManager
    let fee: Int

    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {
            Text("orderReview.section.deliveryDetails".localized)
                .font(AppColor.sans(16, .bold))
                .foregroundStyle(AppColor.textPrim)
                .padding(.horizontal, 4)

            HStack(alignment: .center, spacing: 12) {
                Text("\(fee) \("offers.list.currency".localized)")
                    .font(AppColor.sans(15, .bold))
                    .foregroundStyle(AppColor.textPrim)

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("orderReview.delivery.type".localized)
                        .font(AppColor.sans(14))
                        .foregroundStyle(AppColor.textPrim)

                    Text("orderReview.delivery.feeLabel".localized)
                        .font(AppColor.sans(12))
                        .foregroundStyle(AppColor.textSec)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColor.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColor.border, lineWidth: 1)
                    )
            )
        }
        .environment(\.layoutDirection, languageManager.isRTL ? .rightToLeft : .leftToRight)
    }
}
