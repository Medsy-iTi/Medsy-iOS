//
//  CartAddedBanner.swift
//  Medsy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import SwiftUI

struct CartAddedBanner: View {
    let productName: String

    var body: some View {
        HStack(spacing: MedsySpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(AppColor.green)

            Text("cart.added_message".localized(productName))
                .font(MedsyFont.bodyMedium(14))
                .foregroundStyle(AppColor.textPrim)
                .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "cart.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColor.green)
        }
        .padding(MedsySpacing.md)
        .background(AppColor.card)
        .overlay(
            RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                .stroke(AppColor.green.opacity(0.3), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 12, y: 5)
    }
}
