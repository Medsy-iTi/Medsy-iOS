//  PharmacyOrderAcceptedBannerView.swift
//  Medsy
//
//  Created by Antoneos Philip on 20/07/2026.

import SwiftUI

struct PharmacyOrderAcceptedBannerView: View {
    let orderNumber: String

    var body: some View {
        HStack(spacing: MedsySpacing.md) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(AppColor.successGreen)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("Order \(orderNumber) Accepted")
                        .font(MedsyFont.title(15))
                        .foregroundStyle(AppColor.textPrim)

                    Spacer()

                    Text("Preparing")
                        .font(MedsyFont.caption(11))
                        .fontWeight(.semibold)
                        .foregroundStyle(AppColor.green)
                        .padding(.horizontal, MedsySpacing.xs)
                        .padding(.vertical, 3)
                        .background(AppColor.pill)
                        .clipShape(Capsule())
                }

                Text("Pharmacy accepted your prescription & preparing items.")
                    .font(MedsyFont.caption(12))
                    .foregroundStyle(AppColor.textSec)
            }
        }
        .padding(MedsySpacing.md)
        .background(AppColor.lightGreen.opacity(AppSettings.shared.isDarkMode ? 0.15 : 0.6))
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: MedsyRadius.lg)
                .stroke(AppColor.green.opacity(0.3), lineWidth: 1)
        )
    }
}
