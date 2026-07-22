//  OfferCardView.swift
//  Medsy
//
//  Created by Antoneos Philip on 22/07/2026.

import SwiftUI

struct OfferCardView: View {
    let offer: OfferPresentationModel
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(offer.badgeType.title)
                        .font(AppColor.sans(11, .bold))
                        .foregroundStyle(AppColor.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(offer.badgeType.backgroundColor)
                        )

                    Spacer().frame(height: 8)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("من")
                            .font(AppColor.sans(11))
                            .foregroundStyle(AppColor.textSec)

                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(offer.price)")
                                .font(AppColor.sans(26, .bold))
                                .foregroundStyle(AppColor.textPrim)

                            Text("جنيه")
                                .font(AppColor.sans(12, .medium))
                                .foregroundStyle(AppColor.textSec)
                        }
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Text(offer.pharmacyName)
                        .font(AppColor.sans(17, .bold))
                        .foregroundStyle(AppColor.textPrim)
                        .multilineTextAlignment(.trailing)

                    Text(offer.subtitle)
                        .font(AppColor.sans(13))
                        .foregroundStyle(AppColor.textSec)
                        .multilineTextAlignment(.trailing)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColor.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                offer.isBestOption ? AppColor.green : AppColor.border,
                                lineWidth: offer.isBestOption ? 1.5 : 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
