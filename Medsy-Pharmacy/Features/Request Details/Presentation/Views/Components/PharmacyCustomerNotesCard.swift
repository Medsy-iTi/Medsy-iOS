//  PharmacyCustomerNotesCard.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import SwiftUI

struct PharmacyCustomerNotesCard: View {
    let notes: String

    var body: some View {
        VStack(alignment: .trailing, spacing: PharmacySpacing.xs) {
            HStack(spacing: 8) {
                Spacer()

                Text("pharmacy.request.customer_notes".localized)
                    .font(PharmacyColor.sans(15, .bold))
                    .foregroundStyle(PharmacyColor.textPrimary)

                Image(systemName: "message")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(PharmacyColor.primary)
            }

            HStack {
                Spacer()

                Text(notes)
                    .font(PharmacyColor.sans(13, .medium))
                    .foregroundStyle(PharmacyColor.textSecondary)
                    .multilineTextAlignment(.trailing)
            }
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
