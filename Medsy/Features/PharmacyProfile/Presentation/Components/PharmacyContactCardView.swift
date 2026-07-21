//  PharmacyContactCardView.swift
//  Medsy
//
//  Created by Antoneos Philip on 20/07/2026.

import SwiftUI

struct PharmacyContactCardView: View {
    let phoneNumber: String
    let onCall: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: MedsySpacing.md) {
            Text("Pharmacy Contact Information")
                .font(MedsyFont.title(16))
                .foregroundStyle(AppColor.textPrim)

            infoRow(
                icon: "phone.fill",
                title: "Phone Number",
                subtitle: phoneNumber,
                actionTitle: "Call",
                action: onCall
            )

            Divider()
                .background(AppColor.border)

            infoRow(
                icon: "clock.fill",
                title: "Working Hours",
                subtitle: "Mon - Sun: 24 Hours Open",
                actionTitle: nil,
                action: nil
            )

            Divider()
                .background(AppColor.border)

            infoRow(
                icon: "shippingbox.fill",
                title: "Delivery Coverage",
                subtitle: "Delivers within 5.0 km radius",
                actionTitle: nil,
                action: nil
            )
        }
        .padding(MedsySpacing.md)
        .background(AppColor.card)
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: MedsyRadius.lg)
                .stroke(AppColor.border, lineWidth: 1)
        )
    }

    private func infoRow(
        icon: String,
        title: String,
        subtitle: String,
        actionTitle: String?,
        action: (() -> Void)?
    ) -> some View {
        HStack(spacing: MedsySpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(AppColor.green)
                .frame(width: 32, height: 32)
                .background(AppColor.pill)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(MedsyFont.caption(12))
                    .foregroundStyle(AppColor.textSec)

                Text(subtitle)
                    .font(MedsyFont.bodyMedium(14))
                    .foregroundStyle(AppColor.textPrim)
            }

            Spacer()

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(MedsyFont.button(13))
                        .foregroundStyle(AppColor.green)
                        .padding(.horizontal, MedsySpacing.sm)
                        .padding(.vertical, 6)
                        .background(AppColor.pill)
                        .clipShape(Capsule())
                }
            }
        }
    }
}
