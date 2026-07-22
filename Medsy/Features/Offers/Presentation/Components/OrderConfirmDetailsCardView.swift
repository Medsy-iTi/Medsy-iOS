//  OrderConfirmDetailsCardView.swift
//  Medsy
//
//  Created by Antoneos Philip on 22/07/2026.

import SwiftUI

struct OrderConfirmDetailsCardView: View {
    @Environment(LanguageManager.self) private var languageManager
    let model: OrderConfirmPresentationModel

    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .trailing, spacing: 4) {
                    Text(model.pharmacyName)
                        .font(AppColor.sans(17, .bold))
                        .foregroundStyle(AppColor.textPrim)

                    Text(model.managerName)
                        .font(AppColor.sans(13))
                        .foregroundStyle(AppColor.textSec)
                }

                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColor.green.opacity(0.12))

                    Image(systemName: "storefront.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(AppColor.green)
                }
                .frame(width: 48, height: 48)
            }

            Divider()
                .background(AppColor.border)

            VStack(alignment: .trailing, spacing: 14) {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: languageManager.isRTL ? "chevron.left" : "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(AppColor.textPrim)
                        .padding(10)
                        .background(
                            Circle()
                                .fill(AppColor.surface)
                        )

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("orderConfirm.deliveryTo".localized)
                            .font(AppColor.sans(13))
                            .foregroundStyle(AppColor.textSec)

                        Text(model.deliveryAddress)
                            .font(AppColor.sans(13))
                            .foregroundStyle(AppColor.textPrim)
                            .multilineTextAlignment(.trailing)
                    }
                }

                VStack(alignment: .trailing, spacing: 4) {
                    Text("orderConfirm.estimatedTimeLabel".localized)
                        .font(AppColor.sans(13))
                        .foregroundStyle(AppColor.textSec)

                    Text(model.estimatedTime)
                        .font(AppColor.sans(15, .bold))
                        .foregroundStyle(AppColor.textPrim)
                }

                VStack(alignment: .trailing, spacing: 4) {
                    Text("orderConfirm.paymentMethodLabel".localized)
                        .font(AppColor.sans(13))
                        .foregroundStyle(AppColor.textSec)

                    Text(model.paymentMethod)
                        .font(AppColor.sans(15, .bold))
                        .foregroundStyle(AppColor.textPrim)
                }
            }
        }
        .environment(\.layoutDirection, languageManager.isRTL ? .rightToLeft : .leftToRight)
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
}
