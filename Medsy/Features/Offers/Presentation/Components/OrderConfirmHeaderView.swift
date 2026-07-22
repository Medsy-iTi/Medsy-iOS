//  OrderConfirmHeaderView.swift
//  Medsy
//
//  Created by Antoneos Philip on 22/07/2026.

import SwiftUI

struct OrderConfirmHeaderView: View {
    let orderNumber: String

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppColor.green)
                    .frame(width: 84, height: 84)

                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(AppColor.white)
            }
            .padding(.top, 12)

            Text("orderConfirm.successTitle".localized)
                .font(AppColor.sans(22, .bold))
                .foregroundStyle(AppColor.textPrim)

            VStack(spacing: 6) {
                Text("orderConfirm.orderNumberLabel".localized)
                    .font(AppColor.sans(13))
                    .foregroundStyle(AppColor.textSec)

                Text(orderNumber)
                    .font(AppColor.sans(16, .bold))
                    .foregroundStyle(AppColor.textPrim)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppColor.card)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppColor.border, lineWidth: 1)
                            )
                    )
            }
        }
    }
}
