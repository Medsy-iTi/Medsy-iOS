//
//  PharmacyPharmacistInfoCard.swift
//  Medsy-Pharmacy
//
//

import SwiftUI

struct PharmacyPharmacistInfoCard: View {
    let name: String
    let phone: String
    let onContact: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: PharmacySpacing.sm) {
            Text("completed_order.pharmacist".localized)
                .font(PharmacyColor.sans(14, .regular))
                .foregroundStyle(PharmacyColor.textSecondary)

            HStack(alignment: .center) {
                Text(name)
                    .font(PharmacyColor.sans(16, .bold))
                    .foregroundStyle(PharmacyColor.textPrimary)

                Spacer()

                HStack(spacing: PharmacySpacing.sm) {
                    Text(phone)
                        .font(PharmacyColor.sans(14, .medium))
                        .foregroundStyle(PharmacyColor.primary)
                        
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
