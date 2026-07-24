//
//  CartUndoBanner.swift
//  Medsy
//
//  Created by Ahmed Elkady on 18/07/2026.
//

import SwiftUI

struct CartUndoBanner: View {
    let message: String
    let onUndo: () -> Void

    var body: some View {
        HStack(spacing: MedsySpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(AppColor.successGreen)

            Text(message)
                .font(MedsyFont.bodyMedium(14))
                .foregroundStyle(AppColor.textPrim)
                .lineLimit(2)

            Spacer()

            Button("cart.undo".localized, action: onUndo)
                .font(MedsyFont.button(14))
                .foregroundStyle(AppColor.green)
        }
        .padding(MedsySpacing.md)
        .background(AppColor.card)
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: MedsyRadius.md, style: .continuous)
                .stroke(AppColor.border, lineWidth: 1)
        )
        .medsyCardShadow()
    }
}
