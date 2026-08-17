//
//  OrderReviewPaymentMethodCardView.swift
//  Medsy
//
//  Created by Antoneos Philip on 25/07/2026.
//

import SwiftUI

struct OrderReviewPaymentMethodCardView: View {
    @Environment(LanguageManager.self) private var languageManager
    let paymentMethod: String

    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {
            Text("orderReview.section.paymentMethod".localized)
                .font(AppColor.sans(16, .bold))
                .foregroundStyle(AppColor.textPrim)
                .padding(.horizontal, 4)

            HStack(alignment: .center, spacing: 12) {
                Image(systemName: paymentMethod.uppercased() == "CARD" ? "creditcard.fill" : "banknote.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(AppColor.green)

                Text(paymentMethod.uppercased() == "CARD" ? "orderReview.payment.card".localized : "orderReview.payment.cash".localized)
                    .font(AppColor.sans(15, .bold))
                    .foregroundStyle(AppColor.textPrim)

                Spacer()
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
