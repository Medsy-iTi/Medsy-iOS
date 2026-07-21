//  PharmacyQuickActionsView.swift
//  Medsy
//
//  Created by Antoneos Philip on 20/07/2026.

import SwiftUI

struct PharmacyQuickActionsView: View {
    let onCall: () -> Void
    let onDirections: () -> Void
    let onShare: () -> Void

    var body: some View {
        HStack(spacing: MedsySpacing.md) {
            actionButton(
                title: "Call",
                icon: "phone.fill",
                color: AppColor.green,
                action: onCall
            )

            actionButton(
                title: "Directions",
                icon: "arrow.triangle.turn.up.right.diamond.fill",
                color: AppColor.darkGreen,
                action: onDirections
            )

            actionButton(
                title: "Share",
                icon: "square.and.arrow.up",
                color: AppColor.textSec,
                action: onShare
            )
        }
    }

    private func actionButton(
        title: String,
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: MedsySpacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(color)
                    .clipShape(Circle())
                    .medsyCardShadow()

                Text(title)
                    .font(MedsyFont.caption(12))
                    .fontWeight(.medium)
                    .foregroundStyle(AppColor.textPrim)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, MedsySpacing.xs)
            .background(AppColor.card)
            .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: MedsyRadius.md)
                    .stroke(AppColor.border, lineWidth: 1)
            )
        }
    }
}
