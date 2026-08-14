//  OrderReviewPharmacyCardView.swift
//  Medsy
//
//  Created by Antoneos Philip on 22/07/2026.

import SwiftUI

struct OrderReviewPharmacyCardView: View {
    @Environment(LanguageManager.self) private var languageManager
    let pharmacyName: String
    var managerName: String = ""
    var onTap: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {
            Text("orderReview.section.fulfillingPharmacies".localized)
                .font(AppColor.sans(16, .bold))
                .foregroundStyle(AppColor.textPrim)
                .padding(.horizontal, 4)

            Button {
                onTap?()
            } label: {
                HStack(alignment: .center, spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppColor.green.opacity(0.12))

                        Image(systemName: "storefront.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(AppColor.green)
                    }
                    .frame(width: 48, height: 48)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(pharmacyName)
                            .font(AppColor.sans(17, .bold))
                            .foregroundStyle(AppColor.textPrim)

                        if !managerName.isEmpty {
                            Text(managerName)
                                .font(AppColor.sans(13))
                                .foregroundStyle(AppColor.textSec)
                        }
                    }

                    Spacer()

                    Image(systemName: languageManager.isRTL ? "chevron.left" : "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColor.textSec)
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
            .buttonStyle(.plain)
        }
        .environment(\.layoutDirection, languageManager.isRTL ? .rightToLeft : .leftToRight)
    }
}
