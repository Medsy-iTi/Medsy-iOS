//  PharmacyCustomerInfoCard.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import SwiftUI

struct PharmacyCustomerInfoCard: View {
    let customer: PharmacyCustomerInfo
    let onContact: () -> Void

    var body: some View {
        VStack(alignment: .trailing, spacing: PharmacySpacing.sm) {
            HStack(spacing: 8) {
                Spacer()

                Text("pharmacy.request.customer_info".localized)
                    .font(PharmacyColor.sans(15, .bold))
                    .foregroundStyle(PharmacyColor.textPrimary)

                Image(systemName: "person")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(PharmacyColor.primary)
            }

            VStack(alignment: .trailing, spacing: 10) {
                HStack(spacing: 10) {
                    Spacer()
                    Text(customer.name)
                        .font(PharmacyColor.sans(14, .semibold))
                        .foregroundStyle(PharmacyColor.textPrimary)
                    Image(systemName: "person")
                        .font(.system(size: 14))
                        .foregroundStyle(PharmacyColor.primary)
                }

                HStack(spacing: 10) {
                    Spacer()
                    Text(customer.phone)
                        .font(PharmacyColor.sans(14, .medium))
                        .foregroundStyle(PharmacyColor.textPrimary)
                    Image(systemName: "phone")
                        .font(.system(size: 14))
                        .foregroundStyle(PharmacyColor.primary)
                }

                HStack(spacing: 10) {
                    Spacer()
                    Text(customer.address)
                        .font(PharmacyColor.sans(14, .medium))
                        .foregroundStyle(PharmacyColor.textPrimary)
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 14))
                        .foregroundStyle(PharmacyColor.primary)
                }
            }

            Button(action: onContact) {
                HStack(spacing: 8) {
                    Spacer()
                    Text("pharmacy.request.contact_customer".localized)
                        .font(PharmacyColor.sans(14, .bold))
                    Image(systemName: "phone.fill")
                        .font(.system(size: 14))
                    Spacer()
                }
                .foregroundStyle(PharmacyColor.primary)
                .padding(.vertical, 12)
                .background(PharmacyColor.primarySoft, in: RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous))
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(PharmacySpacing.md)
        .background(PharmacyColor.card, in: RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous)
                .stroke(PharmacyColor.border, lineWidth: 1)
        )
    }
}
