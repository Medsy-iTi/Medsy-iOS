//  OrderReviewAddressCardView.swift
//  Medsy
//
//  Created by Antoneos Philip on 22/07/2026.

import SwiftUI

struct OrderReviewAddressCardView: View {
    @Environment(LanguageManager.self) private var languageManager
    let address: String
    var onEdit: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {
            Text("orderReview.section.deliveryAddress".localized)
                .font(AppColor.sans(16, .bold))
                .foregroundStyle(AppColor.textPrim)
                .padding(.horizontal, 4)

            HStack(alignment: .center, spacing: 12) {
                Button {
                    onEdit?()
                } label: {
                    Text("orderReview.address.edit".localized)
                        .font(AppColor.sans(13, .bold))
                        .foregroundStyle(AppColor.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(AppColor.green)
                        )
                }

                Spacer()

                Text(address)
                    .font(AppColor.sans(13))
                    .foregroundStyle(AppColor.textSec)
                    .multilineTextAlignment(.trailing)
                    .lineSpacing(3)

                ZStack {
                    Circle()
                        .fill(AppColor.green.opacity(0.12))
                        .frame(width: 40, height: 40)

                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(AppColor.green)
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
