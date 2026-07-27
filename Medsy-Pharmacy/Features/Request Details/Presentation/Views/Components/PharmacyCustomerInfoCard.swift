//
//  PharmacyCustomerInfoCard.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import SwiftUI

struct PharmacyCustomerInfoCard: View {
    let orderId: String
    let createdAt: Date
    let customer: PharmacyCustomerInfo
    let onContact: () -> Void
    var onLocationTap: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: PharmacySpacing.sm) {
            HStack {
                Text("#\(orderId)")
                    .font(PharmacyColor.sans(18, .bold))
                    .foregroundStyle(PharmacyColor.textPrimary)

                Spacer()

                Text(createdAt.relativeTimeString)
                    .font(PharmacyColor.sans(13, .regular))
                    .foregroundStyle(PharmacyColor.textSecondary)
            }

            HStack(alignment: .center) {
                Text(customer.name)
                    .font(PharmacyColor.sans(16, .bold))
                    .foregroundStyle(PharmacyColor.textPrimary)

                Spacer()

                Button(action: onContact) {
                    ZStack {
                        Circle()
                            .fill(PharmacyColor.primarySoft)
                            .frame(width: 36, height: 36)

                        Image(systemName: "phone.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(PharmacyColor.primary)
                    }
                }
                .buttonStyle(.plain)
            }

            HStack(alignment: .center) {
                Text(customer.address.isEmpty ? "string" : customer.address)
                    .font(PharmacyColor.sans(14, .regular))
                    .foregroundStyle(PharmacyColor.textSecondary)
                    .lineLimit(2)

                Spacer()

                Button(action: {
                    onLocationTap?()
                }) {
                    ZStack {
                        Circle()
                            .fill(PharmacyColor.primarySoft)
                            .frame(width: 36, height: 36)

                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(PharmacyColor.primary)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(PharmacySpacing.md)
        .background(PharmacyColor.card, in: RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous)
                .stroke(PharmacyColor.border, lineWidth: 1)
        )
    }
}