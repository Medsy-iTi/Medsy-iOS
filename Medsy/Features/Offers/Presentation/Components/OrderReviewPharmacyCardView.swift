//  OrderReviewPharmacyCardView.swift
//  Medsy
//
//  Created by Antoneos Philip on 22/07/2026.

import SwiftUI

struct OrderReviewPharmacyCardView: View {
    @Environment(LanguageManager.self) private var languageManager
    let pharmacyName: String
    let managerName: String

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .trailing, spacing: 4) {
                Text(pharmacyName)
                    .font(AppColor.sans(17, .bold))
                    .foregroundStyle(AppColor.textPrim)

                Text(managerName)
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
